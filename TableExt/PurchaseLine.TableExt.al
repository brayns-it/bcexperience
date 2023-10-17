tableextension 60017 YNSPurchaseLine extends "Purchase Line"
{
    fields
    {
#if W1PU001A
        field(60000; "YNS Incoming Line"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Incoming Line';
        }
#endif
    }
}