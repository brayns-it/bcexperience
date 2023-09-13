#if W1FN002A
table 60001 "YNS Repayment Line"
{
    DataClassification = CustomerContent;
    Caption = 'Repayment Line';

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
        key(PK; "Repayment No.", "Line No.")
        {
            Clustered = true;
        }
    }
}
#endif