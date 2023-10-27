pageextension 60028 YNSVATEntries extends "VAT Entries"
{
    layout
    {
        addlast(Control1)
        {
#if ITXX002A            
            field("YNS Fattura Document Type"; Rec."Fattura Document Type")
            {
                ApplicationArea = All;
            }
#endif            
        }
    }
}