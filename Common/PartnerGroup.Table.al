#if W1XX009A
table 60016 "YNS Partner Group"
{
    DataClassification = CustomerContent;
    Caption = 'Partner Group';
    DrillDownPageId = "YNS Partner Group";
    LookupPageId = "YNS Partner Group";

    fields
    {
        field(1; Code; Code[10])
        {
            DataClassification = CustomerContent;
            Description = 'Code';
        }
        field(2; Description; Text[30])
        {
            DataClassification = CustomerContent;
            Description = 'Description';
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
