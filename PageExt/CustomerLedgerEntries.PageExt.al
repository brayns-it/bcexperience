pageextension 60000 YNSCustomerLedgerEntries extends "Customer Ledger Entries"
{
    layout
    {
        addlast(Control1)
        {
#if W1FN009A
            field(YNSBalance; GetEntryBalanceYNS(Rec."Entry No."))
            {
                Caption = 'Balance';
                Editable = false;
                ApplicationArea = All;
                BlankZero = true;
            }
#endif
#if W1FN003A
            field("YNS Company Bank Account"; Rec."YNS Company Bank Account")
            {
                ApplicationArea = All;
            }
#endif
#if W1FN004A
            field("YNS Original Due Date"; Rec."YNS Original Due Date")
            {
                ApplicationArea = All;
                Editable = false;
            }
#endif
        }
    }
    actions
    {
        addlast("F&unctions")
        {
#if W1FN009A
            action(YNSCalculateBalance)
            {
                Image = Balance;
                Caption = 'Calculate Balance';
                ApplicationArea = All;

                trigger OnAction()
                begin
                    CalculateBalanceYNS();
                    CurrPage.Update(false);
                end;
            }
#endif            
#if W1XX004A            
            action(YNSDocExchange)
            {
                Image = SwitchCompanies;
                Caption = 'Document Exchange';
                ApplicationArea = All;

                trigger OnAction()
                var
                    CustLedg: Record "Cust. Ledger Entry";
                    DocXMgmt: Codeunit "YNS Doc. Exchange Management";
                    RecRef: RecordRef;
                begin
                    CurrPage.SetSelectionFilter(CustLedg);
                    RecRef.GetTable(CustLedg);
                    DocXMgmt.ManualProcessDocuments(RecRef, Page::"Customer Ledger Entries");
                end;
            }
#endif            
#if W1FN001A
            action(YNSArrangeEntries)
            {
                ApplicationArea = All;
                Caption = 'Arrange Entries';
                Ellipsis = true;
                Image = AdjustEntries;

                trigger OnAction()
                var
                    ArrangePage: Page "YNS Arrange CV Entries";
                begin
                    ArrangePage.LoadFromCustomerEntry(Rec);
                    ArrangePage.Run();
                end;
            }
#endif
        }
    }

#if W1FN009A
    local procedure GetEntryBalanceYNS(EntryNo: Integer) Result: Decimal
    begin
        if not TempBalance.Get(EntryNo, Result) then
            Result := 0;
    end;

    local procedure CalculateBalanceYNS()
    var
        CustLedg: Record "Cust. Ledger Entry";
        Amt: Decimal;
    begin
        Amt := 0;
        Clear(TempBalance);

        CustLedg.Copy(Rec);
        CustLedg.SetAutoCalcFields("Amount", "Remaining Amount");
        if CustLedg.FindSet() then
            repeat
                if CustLedg.GetFilter(Open) > '' then
                    if not CustLedg.GetRangeMax(Open) then
                        Amt += CustLedg."Remaining Amount"
                    else
                        Amt += CustLedg.Amount
                else
                    Amt += CustLedg.Amount;

                TempBalance.Add(CustLedg."Entry No.", Amt);
            until CustLedg.Next() = 0;
    end;
#endif

    var
#if W1FN009A    
        TempBalance: Dictionary of [Integer, Decimal];
#endif

}