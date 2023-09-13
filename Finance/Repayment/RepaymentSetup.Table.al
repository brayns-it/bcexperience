#if W1FN002A
table 60004 "YNS Repayment Setup"
{
    DataClassification = CustomerContent;
    Caption = 'Repayment Setup';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Primary Key';
        }
        field(10; "Repayment No. Series"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Repayment No. Series';
        }
        field(11; "Issued Repayment No. Series"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Issued Repayment No. Series';
        }
        field(20; "Def. Gen. Prod. Posting Group"; Code[20])
        {
            Caption = 'Default Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group";
            DataClassification = CustomerContent;
        }
        field(21; "Def. VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'Default VAT Prod. Posting Group';
            TableRelation = "VAT Product Posting Group";
            DataClassification = CustomerContent;
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