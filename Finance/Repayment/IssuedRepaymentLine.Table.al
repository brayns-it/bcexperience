#if W1FN002A
table 60003 "YNS Issued Repayment Line"
{
    DataClassification = CustomerContent;
    Caption = 'Issued Repayment Line';

    fields
    {
        field(1; "Repayment No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'No.';
        }
        field(2; "Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Line No.';
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