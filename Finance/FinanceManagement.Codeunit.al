codeunit 60000 "YNS Finance Management"
{
    Permissions = tabledata "G/L Entry" = rimd,
        tabledata "Cust. Ledger Entry" = rimd,
        tabledata "Detailed Cust. Ledg. Entry" = rimd;

    local procedure InstallAndUpgrade()
    var
#if W1FN004A       
        CustLedg: Record "Cust. Ledger Entry";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
#endif
    begin
#if W1FN004A        
        if not UpgradeTagMgt.HasUpgradeTag('YNS-W1FN004A-Install-20230914') then begin
            CustLedg.Reset();
            if CustLedg.FindSet() then
                repeat
                    CustLedg."YNS Original Due Date" := CustLedg."Due Date";
                    CustLedg.Modify();
                until CustLedg.Next() = 0;

            UpgradeTagMgt.SetUpgradeTag('YNS-W1FN004A-Install-20230914');
            Commit();
        end;
#endif
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

#if ITXX001A
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterSetOperationType', '', false, false)]
    local procedure OnSalesHeaderAfterSetOperationType(var SalesHeader: Record "Sales Header")
    var
        CompInfo: Record "Company Information";
    begin
        if SalesHeader."Activity Code" = '' then
            if CompInfo.Get() then
                if CompInfo."Activity Code" > '' then
                    SalesHeader."Activity Code" := CompInfo."Activity Code";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterSetOperationType', '', false, false)]
    local procedure OnPurchaseHeaderAfterSetOperationType(var PurchaseHeader: Record "Purchase Header")
    var
        CompInfo: Record "Company Information";
    begin
        if PurchaseHeader."Activity Code" = '' then
            if CompInfo.Get() then
                if CompInfo."Activity Code" > '' then
                    PurchaseHeader."Activity Code" := CompInfo."Activity Code";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Finance Charge Memo Header", 'OnValidateCustomerNoOnAfterAssignCustomerValues', '', false, false)]
    local procedure OnFinanceChargeHeaderValidateCustomerNoOnAfterAssignCustomerValues(var FinanceChargeMemoHeader: Record "Finance Charge Memo Header"; Customer: Record "Customer")
    var
        CompInfo: Record "Company Information";
    begin
        if FinanceChargeMemoHeader."Activity Code" = '' then
            if CompInfo.Get() then
                if CompInfo."Activity Code" > '' then
                    FinanceChargeMemoHeader."Activity Code" := CompInfo."Activity Code";
    end;
#endif

#if W1FN001A
    procedure ApplyArrangedCustomerEntries(var TempEntries: record "Gen. Journal Line" temporary)
    var
        xCustLedg2: Record "Cust. Ledger Entry";
        CustLedg2: Record "Cust. Ledger Entry";
        DetCustLedg2: Record "Detailed Cust. Ledg. Entry";
        xDetCustLedg2: Record "Detailed Cust. Ledg. Entry";
        TempSumCustLedg2: Record "Cust. Ledger Entry" temporary;
        GLEntry: Record "G/L Entry";
        xGLEntry: Record "G/L Entry";
        LocalCY: Record Currency;
        InstAmt: Decimal;
        NewAmt: Decimal;
        AmountMismatchErr: Label 'Installments amount must be %1';
        GLEntryNo: Integer;
        DetEntryNo: Integer;
        LastTransNo: Integer;
        GLAdded: Boolean;
    begin
        InstAmt := 0;
        TempEntries.Reset();
        TempEntries.FindSet();
        repeat
            TempEntries.TestField(Amount);
            TempEntries.TestField("Due Date");
            InstAmt += TempEntries.Amount;
        until TempEntries.Next() = 0;

        CustLedg2.Reset();
        CustLedg2.LockTable();
        CustLedg2.SetRange("Customer No.", TempEntries."Source No.");
        CustLedg2.SetRange("Document Type", TempEntries."Document Type");
        CustLedg2.SetRange("Document No.", TempEntries."Document No.");
        CustLedg2.SetRange("Posting Date", TempEntries."Posting Date");
        CustLedg2.SetRange("Currency Code", TempEntries."Currency Code");
        CustLedg2.SetRange(Open, true);
        CustLedg2.SetAutoCalcFields("Remaining Amount", "Remaining Amt. (LCY)", Amount, "Amount (LCY)");
        CustLedg2.FindSet();
        xCustLedg2 := CustLedg2;
        repeat
            TempSumCustLedg2."Remaining Amount" += CustLedg2."Remaining Amount";
            TempSumCustLedg2."Remaining Amt. (LCY)" += CustLedg2."Remaining Amt. (LCY)";
            TempSumCustLedg2.Amount += CustLedg2.Amount;
            TempSumCustLedg2."Amount (LCY)" += CustLedg2."Amount (LCY)";
            TempSumCustLedg2."Sales (LCY)" += CustLedg2."Sales (LCY)";
            TempSumCustLedg2."Profit (LCY)" += CustLedg2."Profit (LCY)";
            TempSumCustLedg2."Inv. Discount (LCY)" += CustLedg2."Inv. Discount (LCY)";

            CustLedg2.TestField("Original Currency Factor", xCustLedg2."Original Currency Factor");
        until CustLedg2.Next() = 0;

        if InstAmt <> TempSumCustLedg2."Remaining Amount" then
            Error(AmountMismatchErr, TempSumCustLedg2."Remaining Amount");

        GLAdded := false;
        GLEntryNo := 1;
        LastTransNo := 0;
        GLEntry.Reset();
        GLEntry.LockTable();
        if GLEntry.FindLast() then begin
            GLEntryNo += GLEntry."Entry No.";
            LastTransNo := GLEntry."Transaction No.";
        end;
        xGLEntry.Get(CustLedg2."Entry No.");

        LocalCY.InitRoundingPrecision();
        if xCustLedg2."Currency Code" = '' then
            xCustLedg2."Original Currency Factor" := 1;

        DetEntryNo := 1;
        DetCustLedg2.Reset();
        if DetCustLedg2.FindLast() then
            DetEntryNo += DetCustLedg2."Entry No.";

        xDetCustLedg2.Reset();
        xDetCustLedg2.SetRange("Cust. Ledger Entry No.", CustLedg2."Entry No.");
        xDetCustLedg2.SetRange("Entry Type", DetCustLedg2."Entry Type"::"Initial Entry");
        xDetCustLedg2.FindFirst();

        CustLedg2.FindSet();
        repeat
            DetCustLedg2.Reset();
            DetCustLedg2.SetRange("Cust. Ledger Entry No.", CustLedg2."Entry No.");
            DetCustLedg2.SetRange("Entry Type", DetCustLedg2."Entry Type"::"Initial Entry");
            DetCustLedg2.FindFirst();

            NewAmt := 0;

            TempEntries.Reset();
            TempEntries.SetRange("Due Date", CustLedg2."Due Date");
            if TempEntries.IsEmpty then begin
                TempEntries.Reset();
                TempEntries.SetCurrentKey("Due Date");
            end;
            if TempEntries.FindFirst() then begin
                NewAmt := TempEntries.Amount;
                TempEntries.Delete();

                if CustLedg2."Due Date" <> TempEntries."Due Date" then begin
                    CustLedg2."Due Date" := TempEntries."Due Date";
                    CustLedg2.Modify();

                    DetCustLedg2."Initial Entry Due Date" := TempEntries."Due Date";
                    DetCustLedg2.Modify();
                end;

                if CustLedg2."Payment Method Code" <> TempEntries."Payment Method Code" then begin
                    CustLedg2."Payment Method Code" := TempEntries."Payment Method Code";
                    CustLedg2.Modify();
                end;
            end;

            if CustLedg2."Remaining Amount" <> NewAmt then begin
                if (NewAmt = 0) and (CustLedg2."Remaining Amount" = CustLedg2.Amount) then
                    DetCustLedg2.Delete()
                else begin
                    DetCustLedg2.Amount += (NewAmt - CustLedg2."Remaining Amount");
                    DetCustLedg2."Amount (LCY)" := Round(DetCustLedg2.Amount / xCustLedg2."Original Currency Factor", LocalCY."Amount Rounding Precision");
                    if DetCustLedg2.Amount >= 0 then begin
                        DetCustLedg2."Debit Amount" := DetCustLedg2.Amount;
                        DetCustLedg2."Debit Amount (LCY)" := DetCustLedg2."Amount (LCY)";
                        DetCustLedg2."Credit Amount" := 0;
                        DetCustLedg2."Credit Amount (LCY)" := 0;
                    end else begin
                        DetCustLedg2."Debit Amount" := 0;
                        DetCustLedg2."Debit Amount (LCY)" := 0;
                        DetCustLedg2."Credit Amount" := -DetCustLedg2.Amount;
                        DetCustLedg2."Credit Amount (LCY)" := -DetCustLedg2."Amount (LCY)";
                    end;
                    DetCustLedg2.Modify();
                end;

                GLEntry.Get(CustLedg2."Entry No.");
                if (NewAmt = 0) and (CustLedg2."Remaining Amount" = CustLedg2.Amount) then
                    GLEntry.Delete()
                else begin
                    GLEntry.Amount := DetCustLedg2."Amount (LCY)";
                    GLEntry."Debit Amount" := DetCustLedg2."Debit Amount (LCY)";
                    GLEntry."Credit Amount" := DetCustLedg2."Credit Amount (LCY)";
                    GLEntry.Modify();
                end;

                if (NewAmt = 0) and (CustLedg2."Remaining Amount" = CustLedg2.Amount) then
                    CustLedg2.Delete()
                else begin
                    CustLedg2."Sales (LCY)" := Round(DetCustLedg2.Amount / TempSumCustLedg2.Amount * TempSumCustLedg2."Sales (LCY)", LocalCY."Amount Rounding Precision");
                    CustLedg2."Profit (LCY)" := Round(DetCustLedg2.Amount / TempSumCustLedg2.Amount * TempSumCustLedg2."Profit (LCY)", LocalCY."Amount Rounding Precision");
                    CustLedg2."Inv. Discount (LCY)" := Round(DetCustLedg2.Amount / TempSumCustLedg2.Amount * TempSumCustLedg2."Inv. Discount (LCY)", LocalCY."Amount Rounding Precision");
                    CustLedg2.Modify();
                end;
            end;
        until CustLedg2.Next() = 0;

        TempEntries.Reset();
        TempEntries.SetCurrentKey("Due Date");
        if TempEntries.FindSet() then
            repeat
                CustLedg2 := xCustLedg2;
                CustLedg2."Entry No." := GLEntryNo;
                CustLedg2."Due Date" := TempEntries."Due Date";
                CustLedg2."Sales (LCY)" := Round(TempEntries.Amount / TempSumCustLedg2.Amount * TempSumCustLedg2."Sales (LCY)", LocalCY."Amount Rounding Precision");
                CustLedg2."Profit (LCY)" := Round(TempEntries.Amount / TempSumCustLedg2.Amount * TempSumCustLedg2."Profit (LCY)", LocalCY."Amount Rounding Precision");
                CustLedg2."Inv. Discount (LCY)" := Round(TempEntries.Amount / TempSumCustLedg2.Amount * TempSumCustLedg2."Inv. Discount (LCY)", LocalCY."Amount Rounding Precision");
                CustLedg2."Payment Method Code" := TempEntries."Payment Method Code";
                CustLedg2.Insert();

                DetCustLedg2 := xDetCustLedg2;
                DetCustLedg2."Entry No." := DetEntryNo;
                DetCustLedg2."Cust. Ledger Entry No." := GLEntryNo;
                DetCustLedg2.Amount := TempEntries.Amount;
                DetCustLedg2."Amount (LCY)" := Round(TempEntries.Amount / xCustLedg2."Original Currency Factor", LocalCY."Amount Rounding Precision");
                if DetCustLedg2.Amount >= 0 then begin
                    DetCustLedg2."Credit Amount" := 0;
                    DetCustLedg2."Credit Amount (LCY)" := 0;
                    DetCustLedg2."Debit Amount" := DetCustLedg2.Amount;
                    DetCustLedg2."Debit Amount (LCY)" := DetCustLedg2."Amount (LCY)";
                end else begin
                    DetCustLedg2."Credit Amount" := -DetCustLedg2.Amount;
                    DetCustLedg2."Credit Amount (LCY)" := -DetCustLedg2."Amount (LCY)";
                    DetCustLedg2."Debit Amount" := 0;
                    DetCustLedg2."Debit Amount (LCY)" := 0;
                end;
                DetCustLedg2."Initial Entry Due Date" := TempEntries."Due Date";
                DetCustLedg2.Insert();

                GLEntry := xGLEntry;
                GLEntry."Entry No." := GLEntryNo;
                GLEntry.Amount := DetCustLedg2."Amount (LCY)";
                GLEntry."Debit Amount" := DetCustLedg2."Debit Amount (LCY)";
                GLEntry."Credit Amount" := DetCustLedg2."Credit Amount (LCY)";
                GLEntry.Insert();
                GLAdded := true;
                GLEntryNo += 1;
            until TempEntries.Next() = 0;

        CustLedg2.FindSet();
        repeat
            TempSumCustLedg2."Amount (LCY)" -= CustLedg2."Amount (LCY)";
            TempSumCustLedg2."Sales (LCY)" -= CustLedg2."Sales (LCY)";
            TempSumCustLedg2."Profit (LCY)" -= CustLedg2."Profit (LCY)";
            TempSumCustLedg2."Inv. Discount (LCY)" -= CustLedg2."Inv. Discount (LCY)";

            if CustLedg2.Open and (CustLedg2."Remaining Amount" = 0) then begin
                CustLedg2.Open := false;
                CustLedg2.Modify();
            end;
        until CustLedg2.Next() = 0;

        if (TempSumCustLedg2."Sales (LCY)" <> 0) or (TempSumCustLedg2."Profit (LCY)" <> 0) or (TempSumCustLedg2."Inv. Discount (LCY)" <> 0) then begin
            CustLedg2."Sales (LCY)" += TempSumCustLedg2."Sales (LCY)";
            CustLedg2."Profit (LCY)" += TempSumCustLedg2."Profit (LCY)";
            CustLedg2."Inv. Discount (LCY)" += TempSumCustLedg2."Inv. Discount (LCY)";
            CustLedg2.Modify();
        end;

        if (TempSumCustLedg2."Amount (LCY)" <> 0) then begin
            DetCustLedg2.Reset();
            DetCustLedg2.SetRange("Cust. Ledger Entry No.", CustLedg2."Entry No.");
            DetCustLedg2.SetRange("Entry Type", DetCustLedg2."Entry Type"::"Initial Entry");
            DetCustLedg2.FindFirst();
            DetCustLedg2."Amount (LCY)" += TempSumCustLedg2."Amount (LCY)";
            if DetCustLedg2.Amount >= 0 then begin
                DetCustLedg2."Debit Amount (LCY)" := DetCustLedg2."Amount (LCY)";
                DetCustLedg2."Credit Amount (LCY)" := 0;
            end else begin
                DetCustLedg2."Debit Amount (LCY)" := 0;
                DetCustLedg2."Credit Amount (LCY)" := -DetCustLedg2."Amount (LCY)";
            end;
            DetCustLedg2.Modify();
        end;

        if GLAdded then begin
            GLEntry.Init();
            GLEntry."Entry No." := GLEntryNo;
            GLEntry."Transaction No." := LastTransNo;
            GLEntry.Insert();
        end;
    end;
#endif

#if W1FN003A
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cust. Entry-Edit", 'OnBeforeCustLedgEntryModify', '', false, false)]
    local procedure OnCustEntryEditBeforeCustLedgEntryModify(var CustLedgEntry: Record "Cust. Ledger Entry"; FromCustLedgEntry: Record "Cust. Ledger Entry")
    begin
        CustLedgEntry."YNS Company Bank Account" := FromCustLedgEntry."YNS Company Bank Account";
    end;
#endif

#if W1FN004A
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnPostCustOnBeforeResetCustLedgerEntryAppliesToFields', '', false, false)]
    local procedure OnGenJnlPostLinePostCustOnBeforeResetCustLedgerEntryAppliesToFields(var CustLedgEntry: Record "Cust. Ledger Entry"; var IsHandled: Boolean)
    begin
        CustLedgEntry."YNS Original Due Date" := CustLedgEntry."Due Date";
    end;
#endif

}