#if LOCALEIT
pageextension 60020 YNSBill extends Bill
{
    layout
    {
#if ITXX007A
        addlast(Control1)
        {
            field("YNS Dishonored Acc. No."; Rec."YNS Dishonored Acc. No.")
            {
                ApplicationArea = All;
            }
            field("YNS Dishonored Payment Method"; Rec."YNS Dishonored Payment Method")
            {
                ApplicationArea = All;
            }
        }
#endif
    }
}
#endif