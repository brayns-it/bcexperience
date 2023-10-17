pageextension 60012 YNSUserSetup extends "User Setup"
{
    layout
    {
        addlast(Control1)
        {
#if W1XX008A
            field("YNS Allow Ledger Deletion"; Rec."YNS Allow Ledger Deletion")
            {
                ApplicationArea = all;
            }
#endif
        }
    }
}