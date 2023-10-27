#if W1SA003A
table 60018 "YNS Store Setup"
{
    DataClassification = CustomerContent;
    Caption = 'Store Setup';

    fields
    {
        field(1; "Primary Key"; code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Primary Key';
        }
        field(10; "Document Nos."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Document Nos.';
            TableRelation = "No. Series";
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}
#endif