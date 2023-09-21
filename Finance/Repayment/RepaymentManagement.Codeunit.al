#if W1FN002A
codeunit 60002 "YNS Repayment Management"
{
    var
        ChargeTerms: Record "Finance Charge Terms";
        Currency: Record Currency;
        RepaSetup: Record "YNS Repayment Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;

    procedure IssueRepaymentYesNo(var RepaHead: Record "YNS Repayment Header")
    var
        IssuedRepa: Record "YNS Issued Repayment Header";
        IssueQst: label 'Issue repayment %1?';
        IssuedLbl: Label 'Repayment %1 has been issued';
    begin
        if not Confirm(IssueQst, false, RepaHead."No.") then
            Error('');

        IssuedRepa := IssueRepayment(RepaHead);

        Message(IssuedLbl, IssuedRepa."No.");
    end;

    procedure IssueRepayment(var RepaHead: Record "YNS Repayment Header") Result: Record "YNS Issued Repayment Header"
    var
        RepaLine: Record "YNS Repayment Line";
        IssuedRepa: Record "YNS Issued Repayment Header";
        IssuedRepaLine: Record "YNS Issued Repayment Line";
    begin
        Calculate(RepaHead);

        RepaSetup.Get();
        RepaSetup.TestField("Issued Repayment No. Series");

        RepaHead.TestField("Posting Date");
        RepaHead.TestField("Document Date");
        RepaHead.TestField("Source No.");

        IssuedRepa.Init();
        IssuedRepa.TransferFields(RepaHead);
        if RepaHead."Posting No." = '' then begin
            RepaHead.TestField("Posting No. Series");
            IssuedRepa."No." := NoSeriesMgt.GetNextNo(RepaHead."Posting No. Series", RepaHead."Posting Date", true);
        end else
            IssuedRepa."No." := RepaHead."Posting No.";
        IssuedRepa."Repayment Document No." := RepaHead."No.";
        IssuedRepa.Insert();

        RepaLine.Reset();
        RepaLine.SetRange("Repayment No.", RepaHead."No.");
        if RepaLine.FindSet() then
            repeat
                IssuedRepaLine.Init();
                IssuedRepaLine.TransferFields(RepaLine);
                IssuedRepaLine."Issued Repayment No." := IssuedRepa."No.";
                IssuedRepaLine.Insert();
            until RepaLine.Next() = 0;

        case RepaHead."Source Type" of
            RepaHead."Source Type"::Customer:
                IssueCustomerRepayment(IssuedRepa);
        end;

        RepaHead.Delete(true);

        exit(IssuedRepa);
    end;

    local procedure SplitCustomerEntry(var IssuedRepa: Record "YNS Issued Repayment Header"; CustLedgNoFilter: Text; IsFinCharge: Boolean)
    var
        TempEntries: record "Gen. Journal Line" temporary;
        IssuedRepaLine: Record "YNS Issued Repayment Line";
        IssuedRepaCalc: Record "YNS Issued Repayment Line";
        FinMgmt: Codeunit "YNS Finance Management";
        LineNo: Integer;
    begin
        LineNo := 0;

        IssuedRepaLine.Reset();
        IssuedRepaLine.SetRange("Issued Repayment No.", IssuedRepa."No.");
        IssuedRepaLine.SetRange("Line Type", IssuedRepaLine."Line Type"::Installment);
        IssuedRepaLine.FindSet();
        repeat
            LineNo += 10000;
            TempEntries.Init();
            TempEntries."Line No." := LineNo;
            TempEntries."Due Date" := IssuedRepaLine."Due Date";
            TempEntries."Payment Method Code" := IssuedRepaLine."Payment Method Code";

            IssuedRepaCalc.Reset();
            IssuedRepaCalc.SetRange("Issued Repayment No.", IssuedRepa."No.");
            IssuedRepaCalc.SetRange("Line Type", IssuedRepaLine."Line Type"::Calculation);
            IssuedRepaCalc.SetRange("Installment Line No.", IssuedRepaLine."Line No.");
            if IssuedRepaCalc.FindSet() then
                repeat
                    if IsFinCharge then begin
                        if IssuedRepaCalc."Entry No." = 0 then
                            TempEntries.Amount += IssuedRepaCalc."Additional Amount";
                        TempEntries.Amount += IssuedRepaCalc."Interest Amount" + IssuedRepaCalc."Interest Overflow";
                    end else
                        if IssuedRepaCalc."Entry No." > 0 then
                            TempEntries.Amount += IssuedRepaCalc."Principal Amount" + IssuedRepaCalc."Additional Amount";
                until IssuedRepaCalc.Next() = 0;

            if TempEntries.Amount > 0 then
                TempEntries.Insert();

        until IssuedRepaLine.Next() = 0;

        TempEntries.Reset();
        TempEntries.FindSet();
        FinMgmt.ApplyArrangedCustomerEntries(TempEntries, CustLedgNoFilter);
    end;

    local procedure IssueCustomerRepayment(var IssuedRepa: Record "YNS Issued Repayment Header")
    var
        IssuedFinChg: record "Issued Fin. Charge Memo Header";
        IssuedRepaLine: Record "YNS Issued Repayment Line";
        CustLedgEntry: Record "Cust. Ledger Entry";
        CustLedgNoFilter: Text;
    begin
        IssuedRepa.CalcFields("Charges Amount");

        Clear(IssuedFinChg);
        if (IssuedRepa."Charges Amount" > 0) or (IssuedRepa."Interest Amount" > 0) then begin
            IssuedFinChg := IssueFinanceCharge(IssuedRepa);

            IssuedRepa."Issued Fin. Charge Memo No." := IssuedFinChg."No.";
            IssuedRepa.Modify();

            CustLedgNoFilter := '';
            CustLedgEntry.Reset();
            CustLedgEntry.SetRange("Customer No.", IssuedRepa."Source No.");
            CustLedgEntry.SetRange("Document Type", CustLedgEntry."Document Type"::"Finance Charge Memo");
            CustLedgEntry.SetRange("Document No.", IssuedFinChg."No.");
            CustLedgEntry.SetRange("Posting Date", IssuedFinChg."Posting Date");
            CustLedgEntry.FindSet();
            repeat
                if CustLedgNoFilter > '' then CustLedgNoFilter += '|';
                CustLedgNoFilter += Format(CustLedgEntry."Entry No.", 0, 9);
            until CustLedgEntry.Next() = 0;

            SplitCustomerEntry(IssuedRepa, CustLedgNoFilter, true);
        end;

        IssuedRepaLine.Reset();
        IssuedRepaLine.SetCurrentKey("Document Type", "Document No.", "Posting Date");
        IssuedRepaLine.SetRange("Issued Repayment No.", IssuedRepa."No.");
        IssuedRepaLine.SetRange("Line Type", IssuedRepaLine."Line Type"::Entry);
        IssuedRepaLine.FindSet();
        repeat
            IssuedRepaLine.SetRange("Document Type", IssuedRepaLine."Document Type");
            IssuedRepaLine.SetRange("Document No.", IssuedRepaLine."Document No.");
            IssuedRepaLine.SetRange("Posting Date", IssuedRepaLine."Posting Date");

            CustLedgNoFilter := '';
            repeat
                if CustLedgNoFilter > '' then CustLedgNoFilter += '|';
                CustLedgNoFilter += Format(IssuedRepaLine."Entry No.", 0, 9);
            until IssuedRepaLine.Next() = 0;

            SplitCustomerEntry(IssuedRepa, CustLedgNoFilter, false);

            IssuedRepaLine.SetRange("Document Type");
            IssuedRepaLine.SetRange("Document No.");
            IssuedRepaLine.SetRange("Posting Date");
        until IssuedRepaLine.Next() = 0;
    end;

    local procedure IssueFinanceCharge(var IssuedRepa: Record "YNS Issued Repayment Header") Result: Record "Issued Fin. Charge Memo Header"
    var
        Cust: Record Customer;
        GenPostSetup: Record "General Posting Setup";
        FinCharge: Record "Finance Charge Memo Header";
        FinChgLine: Record "Finance Charge Memo Line";
        IssuedRepaLine: Record "YNS Issued Repayment Line";
        FinChgIssue: Codeunit "FinChrgMemo-Issue";
        LineNo: Integer;
        InterestLbl: Label 'Interest repayment %1';
    begin
        IssuedRepa.TestField("Gen. Prod. Posting Group");
        IssuedRepa.TestField("VAT Prod. Posting Group");

        Cust.Get(IssuedRepa."Source No.");
        GenPostSetup.Get(Cust."Gen. Bus. Posting Group", IssuedRepa."Gen. Prod. Posting Group");
        GenPostSetup.TestField("Sales Account");

        FinCharge.Init();
        FinCharge."No." := '';
        FinCharge.Insert(true);

        FinCharge.Validate("Customer No.", IssuedRepa."Source No.");
        FinCharge."Document Date" := IssuedRepa."Document Date";
        FinCharge."Posting Date" := IssuedRepa."Posting Date";
        FinCharge."VAT Reporting Date" := IssuedRepa."Posting Date";
        FinCharge."Fin. Charge Terms Code" := IssuedRepa."Finance Charge Terms";
        FinCharge.Validate("Currency Code", IssuedRepa."Currency Code");

        // avoid commit
        FinCharge.TestField("Issuing No. Series");
        FinCharge."Issuing No." := NoSeriesMgt.GetNextNo(FinCharge."Issuing No. Series", FinCharge."Posting Date", true);

        FinCharge.Modify(true);

        LineNo := 10000;

        if IssuedRepa."Interest Amount" > 0 then begin
            FinChgLine.Init();
            FinChgLine."Finance Charge Memo No." := FinCharge."No.";
            FinChgLine."Line No." := LineNo;
            FinChgLine.Type := FinChgLine.Type::"G/L Account";
            FinChgLine.Validate("No.", GenPostSetup."Sales Account");
            FinChgLine."Gen. Prod. Posting Group" := IssuedRepa."Gen. Prod. Posting Group";
            FinChgLine.Validate("VAT Prod. Posting Group", IssuedRepa."VAT Prod. Posting Group");
            FinChgLine.Validate(Amount, IssuedRepa."Interest Amount");
            FinChgLine.Description := StrSubstNo(InterestLbl, IssuedRepa."No.");
            FinChgLine.Insert(true);
            LineNo += 10000;
        end;

        IssuedRepaLine.Reset();
        IssuedRepaLine.SetRange("Issued Repayment No.", IssuedRepa."No.");
        IssuedRepaLine.SetRange("Line Type", IssuedRepaLine."Line Type"::Charge);
        if IssuedRepaLine.FindSet() then
            repeat
                IssuedRepaLine.TestField("Charge Account No.");

                FinChgLine.Init();
                FinChgLine."Finance Charge Memo No." := FinCharge."No.";
                FinChgLine."Line No." := LineNo;
                FinChgLine.Type := FinChgLine.Type::"G/L Account";
                FinChgLine.Validate("No.", IssuedRepaLine."Charge Account No.");
                FinChgLine.Validate("VAT Prod. Posting Group", IssuedRepaLine."VAT Prod. Posting Group");
                FinChgLine.Validate(Amount, IssuedRepaLine.Amount);
                FinChgLine.Description := IssuedRepaLine.Description;
                FinChgLine.Insert(true);
                LineNo += 10000;
            until IssuedRepaLine.Next() = 0;

        FinChgIssue.Set(FinCharge, false, 0D);
        FinChgIssue.Run();
        FinChgIssue.GetIssuedFinChrgMemo(Result);
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
        InstNos: Decimal;
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
        InstNos := RepaLine.Count();

        RepaLine.FindSet();
        repeat
            RepaLine.TestField(Description);
            RepaLine.TestField(Amount);
            RepaLine.TestField("Due Date");

            TempInstallments := RepaLine;
            TempInstallments.Insert();
        until RepaLine.Next() = 0;

        LineNo := 10000;
        TempCalculation.Reset();
        TempCalculation.DeleteAll();

        RepaLine.Reset();
        RepaLine.SetRange("Repayment No.", RepaHead."No.");
        RepaLine.SetRange("Line Type", RepaLine."Line Type"::Charge);
        if RepaLine.FindSet() then
            repeat
                TempInstallments.Reset();
                TempInstallments.SetCurrentKey("Due Date");
                TempInstallments.SetFilter(Amount, '>0');

                case RepaLine."Charges Application" of
                    RepaLine."Charges Application"::"First Installment":
                        begin
                            TempInstallments.FindFirst();
                            AddChargeLine(TempCalculation, TempInstallments, RepaLine, LineNo);
                        end;
                    RepaLine."Charges Application"::"Last Installment":
                        begin
                            TempInstallments.FindLast();
                            AddChargeLine(TempCalculation, TempInstallments, RepaLine, LineNo);
                        end;
                    RepaLine."Charges Application"::Divide:
                        begin
                            RepaLine.Amount := Round(RepaLine.Amount / InstNos, Currency."Amount Rounding Precision");
                            TempInstallments.FindSet();
                            repeat
                                AddChargeLine(TempCalculation, TempInstallments, RepaLine, LineNo);
                            until TempInstallments.Next() = 0;
                        end;
                end;
            until RepaLine.Next() = 0;

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
            if TempCalculation.Amount <> RepaLine.Amount then
                if (TempCalculation.Amount = 0) and (RepaLine."Additional Amount" = 0) then
                    RepaLine.Delete()
                else begin
                    RepaLine.Amount := TempCalculation.Amount;
                    RepaLine.Modify();
                end;
        until RepaLine.Next() = 0;
    end;

    local procedure AddChargeLine(
        var TempCalculationLine: Record "YNS Repayment Line" temporary;
        var TempInstallmentLine: Record "YNS Repayment Line" temporary;
        var ChargeLine: Record "YNS Repayment Line";
        var LineNo: Integer)
    var
        NoInstSpaceErr: Label 'Insufficient remaining amount %1 for charge %2';
    begin
        TempCalculationLine.Init();
        TempCalculationLine."Installment Line No." := TempInstallmentLine."Line No.";
        TempCalculationLine."Line No." := LineNo;
        TempCalculationLine."Charge Line No." := ChargeLine."Line No.";
        TempCalculationLine.Description := ChargeLine.Description;
        TempCalculationLine."Due Date" := TempInstallmentLine."Due Date";
        TempCalculationLine."Payment Method Code" := TempInstallmentLine."Payment Method Code";
        TempCalculationLine."Additional Amount" := ChargeLine.Amount;
        if TempCalculationLine."Additional Amount" > TempInstallmentLine.Amount then
            Error(NoInstSpaceErr, TempInstallmentLine.Description, ChargeLine.Description);

        TempCalculationLine.Amount := TempCalculationLine."Additional Amount";
        TempCalculationLine.Insert();
        LineNo += 10000;

        TempInstallmentLine.Amount -= TempCalculationLine.Amount;
        TempInstallmentLine.Modify();
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
            TempCalculationLine."Remaining Principal Amount" := EntryAmount;
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

        TempInstallmentLine.Amount -= TempCalculationLine.Amount;
        TempInstallmentLine.Modify();
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