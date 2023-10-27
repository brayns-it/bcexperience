#if W1XX004A
table 60015 "YNS FileSystem Transport Setup"
{
    DataClassification = CustomerContent;
    Caption = 'FileSystem Transport Setup';

    fields
    {
        field(1; "Profile Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Reference Code';
            TableRelation = "YNS Doc. Exchange Profile";
        }
        field(5; "Protocol"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Protocol';
            OptionMembers = "FileSystem";
            OptionCaption = 'FileSystem';
        }
        field(10; "Receving Base Path"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Receving Base Path';
        }
        field(11; "Receving Base Path (archive)"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Receving Base Path (archive)';
        }
        field(12; "Archive Received Files"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Archive Received Files';
        }
        field(15; "Sending Base Path"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Sending Base Path';
        }
        field(20; "Remote Functions Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Remote Functions Code';
            TableRelation = "YNS Remote Functions";
        }
        field(30; "Text Encoding"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Text Encoding';
            OptionMembers = "UTF-8","UTF-8 with BOM";
            OptionCaption = 'UTF-8,UTF-8 with BOM';
        }
    }

    keys
    {
        key(PK; "Profile Code")
        {
            Clustered = true;
        }
    }
}
#endif