pageextension 60000 YNSCustomerLedgerEntries extends "Customer Ledger Entries"
{
    actions
    {
        addlast("F&unctions")
        {
#if FN0001A or ALL
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
}