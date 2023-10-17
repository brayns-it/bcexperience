tableextension 60006 YNSSalesInvoiceLine extends "Sales Invoice Line"
{
    fields
    {
#if W1SA002A
        field(60001; "YNS System-Created Source"; Code[35])
        {
            DataClassification = CustomerContent;
            Caption = 'System-Created Source';
        }
#endif
#if W1JB001A
        field(60002; "YNS Sys.-Created Job Contract"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'System-Created Job Contract';
        }
#endif
    }
}