pageextension 60002 YNSBins extends Bins
{
    layout
    {
        addlast(Control1)
        {
#if W1WH001A
            field("YNS Allow Negative Quantity"; Rec."YNS Allow Negative Quantity")
            {
                ApplicationArea = All;
            }
#endif
        }
    }
}