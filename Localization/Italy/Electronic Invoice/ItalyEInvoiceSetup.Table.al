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
        field(11; "Document No. Strip Chars"; Text[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Document No. Strip Chars';
        }
        field(12; "Description Lines VAT Nature"; Code[4])
        {
            DataClassification = CustomerContent;
            Caption = 'Description Lines VAT Nature';
            TableRelation = "VAT Transaction Nature";
        }
        field(13; "Descr. Lines VAT Reference"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Description Lines VAT Reference';
        }
        field(14; "Send Description Lines"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Send Description Lines';
        }
        field(20; "Item No. Tag Name"; Text[35])
        {
            DataClassification = CustomerContent;
            Caption = 'Item No. Tag Name';
        }
        field(21; "Item Barcode Tag Name"; Text[35])
        {
            DataClassification = CustomerContent;
            Caption = 'Item Barcode Tag Name';
        }
        field(25; "Sending Exchange Reference"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Sending Exchange Reference';
            TableRelation = "YNS Doc. Exchange Reference";
        }
        field(30; "Working Path"; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Working Path';
        }
        field(31; "Stylesheet Path"; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Stylesheet Path';
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