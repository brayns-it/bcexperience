#if W1XX004A
table 60006 "YNS Doc. Exchange Ref. Line"
{
    Caption = 'Document Exchange Reference Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Reference Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Reference Code';
            TableRelation = "YNS Doc. Exchange Reference";
        }
        field(2; "Reference Type"; Enum "YNS Doc. Exchange Ref. Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Reference Type';
        }
        field(3; "Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Line No.';
        }
        field(5; "Priority"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Priority';
            BlankZero = true;
        }
        field(20; "Table ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Table ID';
        }
        field(21; "Primary Key 1"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Primary Key 1';
        }
        field(22; "Primary Key 2"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Primary Key 2';
        }
        field(40; "Value Type"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Value Type';
        }
        field(41; "Value 1"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Value 1';
        }
        field(42; "Value 2"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Value 2';
        }
        field(60; "Source Type"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Source Type';
            OptionMembers = " ",Customer,Vendor;
            OptionCaption = ' ,Customer,Vendor';
        }
        field(61; "Source No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Source No.';
            TableRelation = if ("Source Type" = const(Customer)) Customer
            else
            if ("Source Type" = const(Vendor)) Vendor;
        }
        field(100; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            TableRelation = "VAT Product Posting Group";
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Reference Code", "Reference Type", "Line No.")
        {
            Clustered = true;
        }
        key(K1; "Reference Code", "Reference Type", "Table ID", "Primary Key 1", "Primary Key 2") { }
        key(K2; "Reference Code", "Reference Type", "Value Type", "Value 1", "Value 2") { }
        key(K3; "Reference Code", "Reference Type", "Source Type", "Source No.", "Priority", "Value 1") { }
    }
}
#endif