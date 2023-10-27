#if W1SA003A
table 60021 "YNS Store Document Payment"
{
    DataClassification = CustomerContent;
    Caption = 'Store Document Payment';

    fields
    {
        field(1; "Document Type"; Enum "YNS Store Document Type")
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
        }
        field(2; "Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'No.';
            TableRelation = "YNS Store Document" where("Document Type" = field("Document Type"), "No." = field("Document No."));
        }
        field(3; "Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Line No.';
        }
        field(10; "Type"; Enum "YNS Store Doc. Payment Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Type';
        }
        field(11; "No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'No.';

            TableRelation = if (type = const(Payment)) "Payment Method";
        }
        field(15; Description; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(20; "Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Amount';
            BlankZero = true;
        }
        field(51; "Apply to Document Type"; Enum "YNS Store Document Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Apply to Document Type';
        }
        field(52; "Apply to Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Apply to Document No.';
            TableRelation = "YNS Store Document" where("Document Type" = field("Apply to Document Type"), "No." = field("Apply to Document No."));
        }
    }

    keys
    {
        key(PK; "Document Type", "Document No.", "Line No.")
        {
            Clustered = true;
        }
    }
}
#endif