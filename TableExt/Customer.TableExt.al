tableextension 60000 YNSCustomer extends Customer
{
    fields
    {
#if W1FN003A
        field(60000; "YNS Company Bank Account"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Company Bank Account';
            TableRelation = "Bank Account";
        }
#endif
#if ITXX002A
        field(60001; "YNS Send E-Invoice via PEC"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Send E-Invoice via PEC';
        }
#endif
    }
}