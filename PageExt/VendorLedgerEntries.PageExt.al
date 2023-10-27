pageextension 60001 YNSVendorLedgerEntries extends "Vendor Ledger Entries"
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
                    ArrangePage.LoadFromVendorEntry(Rec);
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
        VendLedg: Record "Vendor Ledger Entry";
        Amt: Decimal;
    begin
        Amt := 0;
        Clear(TempBalance);

        VendLedg.Copy(Rec);
        VendLedg.SetAutoCalcFields("Amount", "Remaining Amount");
        if VendLedg.FindSet() then
            repeat
                if VendLedg.GetFilter(Open) > '' then
                    if VendLedg.GetRangeMax(Open) then
                        Amt += VendLedg."Remaining Amount"
                    else
                        Amt += VendLedg.Amount
                else
                    Amt += VendLedg.Amount;

                TempBalance.Add(VendLedg."Entry No.", Amt);
            until VendLedg.Next() = 0;
    end;
#endif

    var
#if W1FN009A    
        TempBalance: Dictionary of [Integer, Decimal];
#endif    
}