#if W1XX004A
table 60010 "YNS Doc. Exchange Metadata"
{
    Caption = 'Document Exchange Metadata';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
            TableRelation = "YNS Doc. Exchange Entry";
        }
        field(2; "Exchange Transport"; Enum "YNS Doc. Exchange Transport")
        {
            DataClassification = CustomerContent;
            Caption = 'Exchange Transport';
        }
        field(3; "Metadata ID"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Metadata ID';
        }
        field(10; "Metadata Value"; Text[200])
        {
            DataClassification = CustomerContent;
            Caption = 'Metadata Value';
        }
    }

    keys
    {
        key(PK; "Entry No.", "Exchange Transport", "Metadata ID")
        {
            Clustered = true;
        }
    }
}
#endif