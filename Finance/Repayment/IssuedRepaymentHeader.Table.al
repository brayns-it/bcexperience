#if W1FN002A
table 60002 "YNS Issued Repayment Header"
{
    DataClassification = CustomerContent;
    Caption = 'Issued Repayment Header';

    fields
    {
        field(1; "Repayment No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'No.';
        }
    }

    keys
    {
        key(PK; "Repayment No.")
        {
            Clustered = true;
        }
    }
}
#endif