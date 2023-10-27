tableextension 60033 YNSPurchasesPayablesSetup extends "Purchases & Payables Setup"
{
    fields
    {
#if W1PU002A
        field(60000; "YNS Purchases Source Nos."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Purchases Source Nos.';
        }
        field(60001; "YNS Purchases Repository Nos."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Purchases Repository Nos.';
        }
#endif
    }
}