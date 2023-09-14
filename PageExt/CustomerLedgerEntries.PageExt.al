pageextension 60000 YNSCustomerLedgerEntries extends "Customer Ledger Entries"
{
    layout
    {
        addlast(Control1)
        {
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
}