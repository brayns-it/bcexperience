pageextension 60001 YNSVendorLedgerEntries extends "Vendor Ledger Entries"
{
    actions
    {
        addlast("F&unctions")
        {
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
}