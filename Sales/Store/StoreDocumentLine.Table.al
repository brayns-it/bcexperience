#if W1SA003A
table 60019 "YNS Store Document Line"
{
    DataClassification = CustomerContent;
    Caption = 'Store Document Line';

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
        field(10; "External Line No."; Text[35])
        {
            DataClassification = CustomerContent;
            Caption = 'External Line No.';
        }
        field(11; "External Group No."; Text[35])
        {
            DataClassification = CustomerContent;
            Caption = 'External Group No.';
        }
        field(20; "Type"; Enum "YNS Store Document Line Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Type';
        }
        field(21; "No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'No.';

            TableRelation = if (Type = const(Item)) Item
            else
            if (Type = const("Item (adjustment)")) Item;
        }
        field(22; "Quantity"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Quantity';
            BlankZero = true;
        }
        field(23; "List Price (incl. VAT)"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'List Price (incl. VAT)';
            BlankZero = true;
        }
        field(24; "VAT %"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'VAT %';
            BlankZero = true;
        }
        field(30; "Description"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(50; "Related to Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Related to Line No.';
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
        field(60; "Reason Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Reason Code';
        }
        field(70; "Line Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Line Amount';
            BlankZero = true;
        }
#if W1PH001A
        field(120; "Health Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Health Amount';
            BlankZero = true;
        }
        field(121; "Health Discount Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Health Discount Amount';
            BlankZero = true;
        }
#endif
#if W1PH001A
        field(1000; "YNS AIC Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'AIC Code';
        }
#endif     
#if LOCALEIT
        field(12000; "VAT Nature"; Code[4])
        {
            TableRelation = "VAT Transaction Nature";
            Caption = 'VAT Nature';
            DataClassification = CustomerContent;
        }
#endif   
    }

    keys
    {
        key(PK; "Document Type", "Document No.", "Line No.")
        {
            Clustered = true;
        }
        key(K1; "Document Type", "Document No.")
        {
            SumIndexFields = "Line Amount";
        }
    }
}
#endif