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
    }
}