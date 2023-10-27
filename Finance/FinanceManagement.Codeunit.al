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

    #region UTILITIES
    /// <summary>
    /// Returns temporary journal with applied customer entries and amount
    /// Logic from page 9106 "Customer Ledger Entry FactBox"
    /// </summary>
    procedure GetCustomerAppliedEntries(var FromCustLedg: Record "Cust. Ledger Entry"; var TempJournal: Record "Gen. Journal Line" temporary)
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        DtldCustLedgEntry1: Record "Detailed Cust. Ledg. Entry";
        DtldCustLedgEntry2: Record "Detailed Cust. Ledg. Entry";
    begin
        TempJournal.Reset();
        TempJournal.DeleteAll();

        DtldCustLedgEntry1.SetCurrentKey("Cust. Ledger Entry No.");
        DtldCustLedgEntry1.SetRange("Cust. Ledger Entry No.", FromCustLedg."Entry No.");
        DtldCustLedgEntry1.SetRange(Unapplied, false);
        if DtldCustLedgEntry1.FindSet() then
            repeat
                if DtldCustLedgEntry1."Cust. Ledger Entry No." =
                   DtldCustLedgEntry1."Applied Cust. Ledger Entry No."
                then begin
                    DtldCustLedgEntry2.Init();
                    DtldCustLedgEntry2.SetCurrentKey("Applied Cust. Ledger Entry No.", "Entry Type");
                    DtldCustLedgEntry2.SetRange(
                      "Applied Cust. Ledger Entry No.", DtldCustLedgEntry1."Applied Cust. Ledger Entry No.");
                    DtldCustLedgEntry2.SetRange("Entry Type", DtldCustLedgEntry2."Entry Type"::Application);
                    DtldCustLedgEntry2.SetRange(Unapplied, false);
                    if DtldCustLedgEntry2.Find('-') then
                        repeat
                            if DtldCustLedgEntry2."Cust. Ledger Entry No." <>
                               DtldCustLedgEntry2."Applied Cust. Ledger Entry No."
                            then begin
                                CustLedgerEntry.SetCurrentKey("Entry No.");
                                CustLedgerEntry.SetRange("Entry No.", DtldCustLedgEntry2."Cust. Ledger Entry No.");
                                if CustLedgerEntry.FindFirst() then
                                    InsertCustomerAppliedEntries(CustLedgerEntry, TempJournal, DtldCustLedgEntry2.Amount, DtldCustLedgEntry2."Amount (LCY)");
                            end;
                        until DtldCustLedgEntry2.Next() = 0;
                end else begin
                    CustLedgerEntry.SetCurrentKey("Entry No.");
                    CustLedgerEntry.SetRange("Entry No.", DtldCustLedgEntry1."Applied Cust. Ledger Entry No.");
                    if CustLedgerEntry.FindFirst() then
                        InsertCustomerAppliedEntries(CustLedgerEntry, TempJournal, DtldCustLedgEntry1.Amount, DtldCustLedgEntry1."Amount (LCY)");
                end;
            until DtldCustLedgEntry1.Next() = 0;

        CustLedgerEntry.SetCurrentKey("Entry No.");
        CustLedgerEntry.SetRange("Entry No.");

        if FromCustLedg."Closed by Entry No." <> 0 then begin
            CustLedgerEntry.Get(FromCustLedg."Closed by Entry No.");
            CustLedgerEntry.CalcFields(Amount, "Amount (LCY)");
            InsertCustomerAppliedEntries(CustLedgerEntry, TempJournal, -CustLedgerEntry.Amount, -CustLedgerEntry."Amount (LCY)");
        end;

        CustLedgerEntry.SetCurrentKey("Closed by Entry No.");
        CustLedgerEntry.SetRange("Closed by Entry No.", FromCustLedg."Entry No.");
        if CustLedgerEntry.FindSet() then
            repeat
                CustLedgerEntry.CalcFields(Amount, "Amount (LCY)");
                InsertCustomerAppliedEntries(CustLedgerEntry, TempJournal, -CustLedgerEntry.Amount, -CustLedgerEntry."Amount (LCY)");
            until CustLedgerEntry.Next() = 0;
    end;

    local procedure InsertCustomerAppliedEntries(var ToCustLedg: Record "Cust. Ledger Entry";
        var TempJournal: Record "Gen. Journal Line" temporary; Amount: Decimal; AmountLCY: Decimal)
    begin
        TempJournal.Reset();
        TempJournal.SetRange("Dimension Set ID", ToCustLedg."Entry No.");
        if not TempJournal.IsEmpty() then exit;

        TempJournal.Reset();
        if TempJournal.FindLast() then;

        TempJournal.Init();
        TempJournal."Line No." += 1;
        TempJournal."Document Type" := ToCustLedg."Document Type";
        TempJournal."Posting Date" := ToCustLedg."Posting Date";
        TempJournal."Document Date" := ToCustLedg."Document Date";
        TempJournal."Document No." := ToCustLedg."Document No.";
        TempJournal.Description := ToCustLedg.Description;
        TempJournal.Amount := Amount;
        TempJournal."Amount (LCY)" := AmountLCY;
        TempJournal."Dimension Set ID" := ToCustLedg."Entry No.";
        TempJournal.Insert();
    end;
    #endregion

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

#if W1FN001A or W1FN002A
    procedure ApplyArrangedCustomerEntriesYesNo(var TempEntries: record "Gen. Journal Line" temporary; var CustLedgNoFilter: Text)
    var
        ApplyQst: Label 'Apply arranged entries?';
    begin
        if not Confirm(ApplyQst) then
            Error('');

        ApplyArrangedCustomerEntries(TempEntries, CustLedgNoFilter);
    end;

    procedure ApplyArrangedCustomerEntries(var TempEntries: record "Gen. Journal Line" temporary; var CustLedgNoFilter: Text)
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
        InvalidFilterErr: Label 'Invalid customer entries filter';
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

        if StrLen(CustLedgNoFilter.Trim()) = 0 then
            Error(InvalidFilterErr);

        CustLedg2.Reset();
        CustLedg2.LockTable();
        CustLedg2.SetFilter("Entry No.", CustLedgNoFilter);
        CustLedg2.SetAutoCalcFields("Remaining Amount", "Remaining Amt. (LCY)", Amount, "Amount (LCY)");
        CustLedg2.FindSet();
        xCustLedg2 := CustLedg2;
        repeat
            CustLedg2.TestField(Open, true);
            CustLedg2.TestField("Original Currency Factor", xCustLedg2."Original Currency Factor");
            CustLedg2.TestField("Customer No.", xCustLedg2."Customer No.");
            CustLedg2.TestField("Document Type", xCustLedg2."Document Type");
            CustLedg2.TestField("Document No.", xCustLedg2."Document No.");
            CustLedg2.TestField("Posting Date", xCustLedg2."Posting Date");
            CustLedg2.TestField("Currency Code", xCustLedg2."Currency Code");

            TempSumCustLedg2."Remaining Amount" += CustLedg2."Remaining Amount";
            TempSumCustLedg2."Remaining Amt. (LCY)" += CustLedg2."Remaining Amt. (LCY)";
            TempSumCustLedg2.Amount += CustLedg2.Amount;
            TempSumCustLedg2."Amount (LCY)" += CustLedg2."Amount (LCY)";
            TempSumCustLedg2."Sales (LCY)" += CustLedg2."Sales (LCY)";
            TempSumCustLedg2."Profit (LCY)" += CustLedg2."Profit (LCY)";
            TempSumCustLedg2."Inv. Discount (LCY)" += CustLedg2."Inv. Discount (LCY)";
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

                CustLedgNoFilter += '|' + Format(GLEntryNo, 0, 9);

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
                DetEntryNo += 1;

                GLEntry := xGLEntry;
                GLEntry."Entry No." := GLEntryNo;
                GLEntry.Amount := DetCustLedg2."Amount (LCY)";
                GLEntry."Debit Amount" := DetCustLedg2."Debit Amount (LCY)";
                GLEntry."Credit Amount" := DetCustLedg2."Credit Amount (LCY)";
                GLEntry.Insert();
                GLAdded := true;
                GLEntryNo += 1;
            until TempEntries.Next() = 0;

        CustLedg2.SetFilter("Entry No.", CustLedgNoFilter);
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
    [EventSubscriber(ObjectType::Table, database::"Sales Header", 'OnAfterSetCompanyBankAccount', '', false, false)]
    local procedure OnAfterSetCompanyBankAccount(var SalesHeader: Record "Sales Header"; xSalesHeader: Record "Sales Header")
    var
        CompInfo: Record "Company Information";
    begin
        if SalesHeader."Company Bank Account Code" = '' then begin
            CompInfo.Get();
            if CompInfo."YNS Preferred Bank Account" > '' then
                SalesHeader."Company Bank Account Code" := CompInfo."YNS Preferred Bank Account";
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cust. Entry-Edit", 'OnBeforeCustLedgEntryModify', '', false, false)]
    local procedure OnCustEntryEditBeforeCustLedgEntryModify(var CustLedgEntry: Record "Cust. Ledger Entry"; FromCustLedgEntry: Record "Cust. Ledger Entry")
    begin
        CustLedgEntry."YNS Company Bank Account" := FromCustLedgEntry."YNS Company Bank Account";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Vend. Entry-Edit", 'OnBeforeVendLedgEntryModify', '', false, false)]
    local procedure OnBeforeVendLedgEntryModify(var VendLedgEntry: Record "Vendor Ledger Entry"; FromVendLedgEntry: Record "Vendor Ledger Entry")
    begin
        VendLedgEntry."YNS Company Bank Account" := FromVendLedgEntry."YNS Company Bank Account";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnPostCustOnAfterInitCustLedgEntry', '', false, false)]
    local procedure OnPostCustOnAfterInitCustLedgEntry(var GenJournalLine: Record "Gen. Journal Line"; var CustLedgEntry: Record "Cust. Ledger Entry"; Cust: Record Customer; CustPostingGr: Record "Customer Posting Group")
    begin
        CustLedgEntry."YNS Company Bank Account" := Cust."YNS Company Bank Account";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeVendLedgEntryInsert', '', false, false)]
    local procedure OnBeforeVendLedgEntryInsert(var VendorLedgerEntry: Record "Vendor Ledger Entry"; var GenJournalLine: Record "Gen. Journal Line"; GLRegister: Record "G/L Register"; PaymentTermsLine: Record "Payment Lines")
    var
        Vend: Record Vendor;
    begin
        Vend.Get(VendorLedgerEntry."Vendor No.");
        VendorLedgerEntry."YNS Company Bank Account" := Vend."YNS Company Bank Account";
    end;
#endif

#if W1FN004A
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnPostCustOnBeforeResetCustLedgerEntryAppliesToFields', '', false, false)]
    local procedure OnGenJnlPostLinePostCustOnBeforeResetCustLedgerEntryAppliesToFields(var CustLedgEntry: Record "Cust. Ledger Entry"; var IsHandled: Boolean)
    begin
        CustLedgEntry."YNS Original Due Date" := CustLedgEntry."Due Date";
    end;
#endif

#if W1FN010A
    [EventSubscriber(ObjectType::Table, database::"Purchase Header", 'OnValidateBuyFromVendorNoOnAfterValidatePayToVendor', '', false, false)]
    local procedure OnValidateBuyFromVendorNoOnAfterValidatePayToVendor(var PurchaseHeader: Record "Purchase Header")
    begin
        PurchaseHeader."Posting Description" := CopyStr(Format(PurchaseHeader."Document Type") + ' ' + PurchaseHeader."Pay-to Name", 1, MaxStrLen(PurchaseHeader."Posting Description"));
    end;

    [EventSubscriber(ObjectType::Table, database::"Purchase Header", 'OnBeforeInitPostingDescription', '', false, false)]
    local procedure OnPurchHeadBeforeInitPostingDescription(var PurchaseHeader: Record "Purchase Header"; var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, database::"Sales Header", 'OnValidateSellToCustomerNoOnBeforeUpdateSellToCont', '', false, false)]
    local procedure OnValidateSellToCustomerNoOnBeforeUpdateSellToCont(var SalesHeader: Record "Sales Header"; xSalesHeader: Record "Sales Header"; SellToCustomer: Record Customer; var SkipSellToContact: Boolean)
    begin
        SalesHeader."Posting Description" := CopyStr(Format(SalesHeader."Document Type") + ' ' + SalesHeader."Bill-to Name", 1, MaxStrLen(SalesHeader."Posting Description"));
    end;

    [EventSubscriber(ObjectType::Table, database::"Sales Header", 'OnBeforeInitPostingDescription', '', false, false)]
    local procedure OnSalesHeadBeforeInitPostingDescription(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;
#endif

#if W1FN011A
    [EventSubscriber(ObjectType::Codeunit, codeunit::"Gen. Jnl.-Check Line", 'OnBeforeErrorIfNegativeAmt', '', false, false)]
    local procedure OnBeforeErrorIfNegativeAmt(GenJnlLine: Record "Gen. Journal Line"; var RaiseError: Boolean)
    begin
        if GenJnlLine."YNS Skip Pos./Neg. Error" then
            RaiseError := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, codeunit::"Gen. Jnl.-Check Line", 'OnBeforeErrorIfPositiveAmt', '', false, false)]
    local procedure OnBeforeErrorIfPositiveAmt(GenJnlLine: Record "Gen. Journal Line"; var RaiseError: Boolean)
    begin
        if GenJnlLine."YNS Skip Pos./Neg. Error" then
            RaiseError := false;
    end;
#endif

#if W1FN012A
    [EventSubscriber(ObjectType::Codeunit, codeunit::"Purch.-Post", 'OnCopyToTempLinesLoop', '', false, false)]
    local procedure OnPurchPostCopyToTempLinesLoop(var PurchLine: Record "Purchase Line")
    begin
        if (PurchLine."YNS Accrual Starting Date" > 0D) and (PurchLine."YNS Accrual Ending Date" < PurchLine."YNS Accrual Starting Date") then
            PurchLine.FieldError("YNS Accrual Ending Date");

        if (PurchLine."YNS Accrual Ending Date" > 0D) and (PurchLine."YNS Accrual Starting Date" = 0D) then
            PurchLine.FieldError("YNS Accrual Starting Date");

        if (PurchLine."YNS Accrual Starting Date" > 0D) and (PurchLine.Type <> PurchLine.Type::"G/L Account") then
            PurchLine.FieldError(Type);
    end;

    [EventSubscriber(ObjectType::Table, database::"G/L Entry", 'OnAfterCopyGLEntryFromGenJnlLine', '', false, false)]
    local procedure OnAfterCopyGLEntryFromGenJnlLine(var GLEntry: Record "G/L Entry"; var GenJournalLine: Record "Gen. Journal Line")
    begin
        GLEntry."YNS Accrual Starting Date" := GenJournalLine."YNS Accrual Starting Date";
        GLEntry."YNS Accrual Ending Date" := GenJournalLine."YNS Accrual Ending Date";
    end;

#pragma warning disable AL0432

    // TODO (New Posting Buffer)
    [EventSubscriber(ObjectType::Table, database::"Invoice Post. Buffer", 'OnAfterCopyToGenJnlLine', '', false, false)]
    local procedure OnInvBuffAfterCopyToGenJnlLine(var GenJnlLine: Record "Gen. Journal Line"; InvoicePostBuffer: Record "Invoice Post. Buffer");
    begin
        GenJnlLine."YNS Accrual Starting Date" := InvoicePostBuffer."YNS Accrual Starting Date";
        GenJnlLine."YNS Accrual Ending Date" := InvoicePostBuffer."YNS Accrual Ending Date";
    end;

    // TODO (New Posting Buffer)
    [EventSubscriber(ObjectType::Table, database::"Invoice Post. Buffer", 'OnAfterInvPostBufferPreparePurchase', '', false, false)]
    local procedure OnAfterInvPostBufferPreparePurchase(var PurchaseLine: Record "Purchase Line"; var InvoicePostBuffer: Record "Invoice Post. Buffer")
    begin
        InvoicePostBuffer."YNS Accrual Starting Date" := PurchaseLine."YNS Accrual Starting Date";
        InvoicePostBuffer."YNS Accrual Ending Date" := PurchaseLine."YNS Accrual Ending Date";
    end;

#if LOCALEIT
    // TODO (New Posting Buffer)
    [EventSubscriber(ObjectType::Table, database::"Invoice Post. Buffer", 'OnAfterFillInvPostingBufferPrimaryKey', '', false, false)]
    local procedure OnAfterFillInvPostingBufferPrimaryKey(var InvoicePostBuffer: Record "Invoice Post. Buffer")
    begin
        InvoicePostBuffer."Primary Key" += Format(InvoicePostBuffer."YNS Accrual Starting Date") +
            Format(InvoicePostBuffer."YNS Accrual Ending Date");
    end;
#endif

#pragma warning restore
#endif
}