#if W1FN002A
codeunit 60002 "YNS Repayment Management"
{
    var
        ChargeTerms: Record "Finance Charge Terms";
        Currency: Record Currency;

    local procedure InstallAndUpgrade()
    var
        RepaSetup: Record "YNS Repayment Setup";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        if not UpgradeTagMgt.HasUpgradeTag('YNS-W1FN002A-Install-20230913') then begin
            if not RepaSetup.Get() then begin
                Clear(RepaSetup);
                RepaSetup.Insert();
            end;
            UpgradeTagMgt.SetUpgradeTag('YNS-W1FN002A-Install-20230913');
            Commit();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"YNS Experience Install", 'OnAfterInstallAppPerCompany', '', false, false)]
    local procedure OnAfterInstallAppPerCompany()
    begin
        InstallAndUpgrade();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"YNS Experience Upgrade", 'OnAfterUpgradePerCompany', '', false, false)]
    local procedure OnAfterUpgradePerCompany()
    begin
        InstallAndUpgrade();
    end;

    procedure Calculate(var RepaHead: Record "YNS Repayment Header")
    var
        RepaLine: Record "YNS Repayment Line";
        TempInstallments: Record "YNS Repayment Line" temporary;
        TempCalculation: Record "YNS Repayment Line" temporary;
        TempOverflow: Record "YNS Repayment Line" temporary;
        LineNo: Integer;
        PostingDateErr: Label 'Document %1 posting date cannot be greater than %2';
        EntryAmt: Decimal;
    begin
        if RepaHead."Finance Charge Terms" > '' then begin
            ChargeTerms.Get(RepaHead."Finance Charge Terms");
            ChargeTerms.TestField("Interest Period (Days)");
            ChargeTerms.TestField("Interest Rate");
        end else begin
            Clear(ChargeTerms);
            ChargeTerms."Interest Rate" := 0;
            ChargeTerms."Interest Period (Days)" := 1;
        end;

        TempInstallments.Reset();
        TempInstallments.DeleteAll();

        if RepaHead."Currency Code" = '' then
            Currency.InitRoundingPrecision()
        else begin
            Currency.Get(RepaHead."Currency Code");
            Currency.TestField("Amount Rounding Precision");
        end;

        RepaLine.Reset();
        RepaLine.SetRange("Repayment No.", RepaHead."No.");
        RepaLine.SetRange("Line Type", RepaLine."Line Type"::Installment);
        RepaLine.FindSet();
        repeat
            RepaLine.TestField(Description);
            RepaLine.TestField(Amount);
            RepaLine.TestField("Due Date");

            TempInstallments := RepaLine;
            TempInstallments.Insert();
        until RepaLine.Next() = 0;

        LineNo := 10000;

        RepaLine.Reset();
        RepaLine.SetRange("Repayment No.", RepaHead."No.");
        RepaLine.SetRange("Line Type", RepaLine."Line Type"::Entry);
        RepaLine.SetCurrentKey("Posting Date");
        RepaLine.FindSet();
        repeat
            EntryAmt := RepaLine.Amount;

            TempInstallments.Reset();
            TempInstallments.SetCurrentKey("Due Date");
            TempInstallments.SetFilter(Amount, '>0');
            if TempInstallments.FindSet() then
                repeat
                    if RepaLine."Posting Date" > TempInstallments."Due Date" then
                        Error(PostingDateErr, RepaLine."Document No.", RepaLine."Posting Date");

                    AddCalculationLine(TempCalculation, TempInstallments, RepaLine, LineNo, EntryAmt, false);

                    TempInstallments.Amount -= TempCalculation.Amount;
                    TempInstallments.Modify();
                until (TempInstallments.Next() = 0) or (EntryAmt <= 0);

            if EntryAmt > 0 then begin
                TempOverflow := RepaLine;
                TempOverflow.Amount := EntryAmt;
                TempOverflow.Insert();
            end;
        until RepaLine.Next() = 0;

        TempOverflow.Reset();
        if TempOverflow.FindSet() then begin
            TempInstallments.Reset();
            TempInstallments.SetCurrentKey("Due Date");
            TempInstallments.FindLast();

            repeat
                AddCalculationLine(TempCalculation, TempInstallments, TempOverflow, LineNo, TempOverflow.Amount, true);
            until TempOverflow.Next() = 0;
        end;

        RepaLine.Reset();
        RepaLine.SetRange("Repayment No.", RepaHead."No.");
        RepaLine.SetRange("Line Type", RepaLine."Line Type"::Calculation);
        if not RepaLine.IsEmpty() then
            RepaLine.DeleteAll();

        RepaHead."Interest Amount" := 0;
        RepaHead."Principal Amount" := 0;

        LineNo := 10000;
        TempCalculation.Reset();
        TempCalculation.SetCurrentKey("Installment Line No.", "Entry No.");
        TempCalculation.FindSet();
        repeat
            RepaLine := TempCalculation;
            RepaLine."Repayment No." := RepaHead."No.";
            RepaLine."Line Type" := RepaLine."Line Type"::Calculation;
            RepaLine."Line No." := LineNo;
            RepaLine.Insert();
            LineNo += 10000;

            RepaHead."Interest Amount" += RepaLine."Interest Amount" + RepaLine."Interest Overflow";
            RepaHead."Principal Amount" += RepaLine."Principal Amount";
        until TempCalculation.Next() = 0;

        RepaHead.Modify();

        RepaLine.Reset();
        RepaLine.SetRange("Repayment No.", RepaHead."No.");
        RepaLine.SetRange("Line Type", RepaLine."Line Type"::Installment);
        RepaLine.FindSet();
        repeat
            TempCalculation.Reset();
            TempCalculation.SetRange("Installment Line No.", RepaLine."Line No.");
            TempCalculation.CalcSums(Amount);
            if TempCalculation.Amount <> RepaLine.Amount then begin
                RepaLine.Amount := TempCalculation.Amount;
                RepaLine.Modify();
            end;
        until RepaLine.Next() = 0;
    end;

    local procedure AddCalculationLine(
        var TempCalculationLine: Record "YNS Repayment Line" temporary;
        var TempInstallmentLine: Record "YNS Repayment Line" temporary;
        var EntryLine: Record "YNS Repayment Line";
        var LineNo: Integer;
        var EntryAmount: Decimal;
        Overflow: Boolean)
    var
        xCalculationLine: Record "YNS Repayment Line";
        InterestFactor: Decimal;
    begin
        Clear(xCalculationLine);
        TempCalculationLine.Reset();
        TempCalculationLine.SetRange("Entry No.", EntryLine."Entry No.");
        if TempCalculationLine.FindLast() then
            xCalculationLine := TempCalculationLine;

        TempCalculationLine.Init();
        TempCalculationLine."Installment Line No." := TempInstallmentLine."Line No.";
        TempCalculationLine."Line No." := LineNo;
        TempCalculationLine."Entry No." := EntryLine."Entry No.";
        TempCalculationLine.Description := TempInstallmentLine.Description;
        TempCalculationLine."Payment Method Code" := TempInstallmentLine."Payment Method Code";

        if xCalculationLine."Due Date" = 0D then
            if EntryLine."Due Date" > TempInstallmentLine."Due Date" then
                xCalculationLine."Due Date" := EntryLine."Posting Date"
            else
                xCalculationLine."Due Date" := EntryLine."Due Date";

        TempCalculationLine."Due Date" := TempInstallmentLine."Due Date";
        TempCalculationLine."Delay Days" := TempInstallmentLine."Due Date" - xCalculationLine."Due Date";

        InterestFactor := (ChargeTerms."Interest Rate" / ChargeTerms."Interest Period (Days)" * TempCalculationLine."Delay Days" / 100);

        if EntryLine."Principal Amount Base" then begin
            TempCalculationLine."Interest Amount" := Round(EntryAmount * InterestFactor, Currency."Amount Rounding Precision") +
                xCalculationLine."Interest Overflow";

            if Overflow then
                TempCalculationLine."Principal Amount" := EntryAmount

            else begin
                if TempCalculationLine."Interest Amount" > TempInstallmentLine.Amount then begin
                    TempCalculationLine."Interest Overflow" := TempCalculationLine."Interest Amount" - TempInstallmentLine.Amount;
                    TempCalculationLine."Interest Amount" := TempInstallmentLine.Amount;
                end;

                TempCalculationLine."Principal Amount" := TempInstallmentLine.Amount - TempCalculationLine."Interest Amount";
                if TempCalculationLine."Principal Amount" > EntryAmount then
                    TempCalculationLine."Principal Amount" := EntryAmount;
            end;

            EntryAmount -= TempCalculationLine."Principal Amount";

        end else begin
            TempCalculationLine."Additional Amount" := EntryAmount;

            if not Overflow then
                if TempCalculationLine."Additional Amount" > EntryAmount then
                    TempCalculationLine."Additional Amount" := EntryAmount;

            EntryAmount -= TempCalculationLine."Additional Amount";
        end;

        TempCalculationLine.Amount := TempCalculationLine."Principal Amount" + TempCalculationLine."Interest Amount" + TempCalculationLine."Additional Amount";
        TempCalculationLine.Insert();
        LineNo += 10000;
    end;

    procedure GetEntries(var RepaHead: Record "YNS Repayment Header")
    begin
        RepaHead.TestField("Source No.");

        case RepaHead."Source Type" of
            RepaHead."Source Type"::Customer:
                GetCustomerEntries(RepaHead);
        end;
    end;

    local procedure GetCustomerEntries(var RepaHead: Record "YNS Repayment Header")
    var
        RepaLine: Record "YNS Repayment Line";
        CustLeg: Record "Cust. Ledger Entry";
        CustLeg2: Record "Cust. Ledger Entry";
        CustLegPage: Page "Customer Ledger Entries";
        LineNo: Integer;
    begin
        CustLeg.Reset();
        CustLeg.FilterGroup(2);
        CustLeg.SetRange("Customer No.", RepaHead."Source No.");
        CustLeg.SetRange(Open, true);
        CustLeg.SetRange("Currency Code", RepaHead."Currency Code");
        CustLeg.SetRange(Positive, true);
        CustLeg.FilterGroup(0);

        CustLegPage.LookupMode(true);
        CustLegPage.SetTableView(CustLeg);
        if CustLegPage.RunModal() <> Action::LookupOK then
            exit;

        CustLegPage.SetSelectionFilter(CustLeg2);

        LineNo := 10000;
        RepaLine.Reset();
        RepaLine.SetRange("Repayment No.", RepaHead."No.");
        RepaLine.SetRange("Line Type", RepaLine."Line Type"::Entry);
        if RepaLine.FindLast() then
            LineNo += RepaLine."Line No.";

        CustLeg2.SetAutoCalcFields("Remaining Amount");
        if CustLeg2.FindSet() then
            repeat
                RepaLine.Reset();
                RepaLine.SetRange("Repayment No.", RepaHead."No.");
                RepaLine.SetRange("Line Type", RepaLine."Line Type"::Entry);
                RepaLine.SetRange("Entry No.", CustLeg2."Entry No.");
                if RepaLine.IsEmpty then begin
                    RepaLine.Init();
                    RepaLine."Repayment No." := RepaHead."No.";
                    RepaLine."Line Type" := RepaLine."Line Type"::Entry;
                    RepaLine."Line No." := LineNo;
                    RepaLine.Description := CustLeg2.Description;
                    RepaLine."Document Type" := CustLeg2."Document Type";
                    RepaLine."Document No." := CustLeg2."Document No.";
                    RepaLine."External Document No." := CustLeg2."External Document No.";
                    RepaLine."Document Date" := CustLeg2."Document Date";
                    RepaLine."Posting Date" := CustLeg2."Posting Date";
                    RepaLine."Due Date" := CustLeg2."Due Date";
                    RepaLine."Entry No." := CustLeg2."Entry No.";
                    RepaLine.Amount := CustLeg2."Remaining Amount";
                    if CustLeg2."Document Type" = CustLeg2."Document Type"::"Finance Charge Memo" then
                        RepaLine."Principal Amount Base" := false
                    else
                        RepaLine."Principal Amount Base" := true;
                    RepaLine.Insert();
                    LineNo += 10000;
                end;
            until CustLeg2.Next() = 0;
    end;
}
#endif