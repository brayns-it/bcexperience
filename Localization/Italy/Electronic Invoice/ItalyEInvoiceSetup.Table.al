#if ITXX002A
table 60008 "YNS Italy E-Invoice Setup"
{
    DataClassification = CustomerContent;
    Caption = 'Italy E-Invoice Setup';

    fields
    {
        field(1; "Primary Key"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Primary Key';
        }
        field(10; "Last Progressive No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Last Progressive No.';
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