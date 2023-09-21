#if W1XX004A
table 60007 "YNS Doc. Exchange Profile"
{
    Caption = 'Document Exchange Profile';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Code';
        }
        field(2; "Description"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(10; "Exchange Format"; Enum "YNS Doc. Exchange Format")
        {
            DataClassification = CustomerContent;
            Caption = 'Exchange Format';
        }
        field(20; "Exchange Transport"; Enum "YNS Doc. Exchange Transport")
        {
            DataClassification = CustomerContent;
            Caption = 'Exchange Transport';
        }
        field(30; Enabled; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Enabled';
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }
}
#endif