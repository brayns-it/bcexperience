pageextension 60015 YNSSalesReceivablesSetup extends "Sales & Receivables Setup"
{
    layout
    {
#if ITXX006A
        addlast(content)
        {
            group(YNSFatturaStamp)
            {
                Caption = 'Fattura Stamp';

                field("YNS Def. Fattura Stamp Amount"; Rec."YNS Def. Fattura Stamp Amount")
                {
                    ApplicationArea = All;
                }
                field("YNS Fattura Stamp Threshold"; Rec."YNS Fattura Stamp Threshold")
                {
                    ApplicationArea = All;
                }
                field("YNS Fattura Stamp G/L Acc."; Rec."YNS Fattura Stamp G/L Acc.")
                {
                    ApplicationArea = All;
                }
                field("YNS Fattura Stamp Description"; Rec."YNS Fattura Stamp Description")
                {
                    ApplicationArea = All;
                }
            }
        }
#endif
    }
}