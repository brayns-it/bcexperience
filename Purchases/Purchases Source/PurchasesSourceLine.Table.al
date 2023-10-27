#if W1PU002A
table 60023 "YNS Purchases Source Line"
{
    DataClassification = CustomerContent;
    Caption = 'Purchases Source Line';
    DrillDownPageId = "YNS Purchases Source Lines";
    LookupPageId = "YNS Purchases Source Lines";

    fields
    {
        field(1; "Purchases Source No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Purchases Source No.';
            TableRelation = "YNS Purchases Source";
            NotBlank = true;
        }
        field(2; "Location Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(10; "Vendor No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Vendor No.';
            TableRelation = Vendor;
        }
        field(11; "Purchaser Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Purchaser Code';
            TableRelation = "Salesperson/Purchaser";
        }
        field(12; "Repository No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Repository No.';
            TableRelation = "YNS Purchases Repository";
        }
#if W1PH003A
        field(500; "Dafne ID"; Code[35])
        {
            DataClassification = CustomerContent;
            Caption = 'Dafne ID';
        }
#endif
    }

    keys
    {
        key(PK; "Purchases Source No.", "Location Code")
        {
            Clustered = true;
        }
    }
}
#endif