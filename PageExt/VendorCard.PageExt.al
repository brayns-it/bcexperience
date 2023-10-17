pageextension 60021 YNSVendorCard extends "Vendor Card"
{
    layout
    {
#if W1XX009A
        addlast(General)
        {
            field("YNS Partner Group"; Rec."YNS Partner Group")
            {
                ApplicationArea = All;
            }
        }
#endif 
    }
}