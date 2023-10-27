pageextension 60006 YNSItemCard extends "Item Card"
{
    layout
    {
#if W1PU002A
        addafter("Vendor No.")
        {
            field("YNS Purchases Source No."; Rec."YNS Purchases Source No.")
            {
                ApplicationArea = All;
            }
        }
#endif
    }
}