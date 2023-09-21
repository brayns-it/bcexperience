tableextension 60002 YNSBin extends Bin
{
    fields
    {
#if W1WH001A
        field(60000; "YNS Allow Negative Quantity"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Allow Negative Quantity';
        }
#endif
    }
}