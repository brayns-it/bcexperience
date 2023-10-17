tableextension 60020 YNSSalesReceivablesSetup extends "Sales & Receivables Setup"
{
    fields
    {
#if ITXX006A
        field(60000; "YNS Def. Fattura Stamp Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Default Fattura Stamp Amount';
            BlankZero = true;
        }
        field(60001; "YNS Fattura Stamp Threshold"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Fattura Stamp Threshold';
            BlankZero = true;
        }
        field(60002; "YNS Fattura Stamp G/L Acc."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Fattura Stamp G/L Account';
            TableRelation = "G/L Account" where("Account Type" = const(Posting));
        }
        field(60003; "YNS Fattura Stamp Description"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Fattura Stamp Description';
        }
#endif
    }
}