pageextension 60033 YNSSalespersonPurchaserCard extends "Salesperson/Purchaser Card"
{
    layout
    {
        addlast(General)
        {
#if ITXX009A
            field("YNS Fiscal Code"; Rec."YNS Fiscal Code")
            {
                ApplicationArea = All;
            }
#endif
        }
    }
}