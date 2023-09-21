#if W1XX004A
table 60009 "YNS Doc. Exchange Entry"
{
    Caption = 'Document Exchange Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(5; "Profile Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Profile Code';
            TableRelation = "YNS Doc. Exchange Profile";
        }
        field(6; "Direction"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Direction';
            OptionMembers = " ",Inbound,Outbound;
            OptionCaption = ' ,Inbound,Outbound';
        }
        field(7; "Exchange Format"; Enum "YNS Doc. Exchange Format")
        {
            DataClassification = CustomerContent;
            Caption = 'Exchange Format';
        }
        field(10; "Source Type"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Source Type';
            OptionMembers = " ",Customer,Vendor;
            OptionCaption = ' ,Customer,Vendor';
        }
        field(11; "Source No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Source No.';
            TableRelation = if ("Source Type" = const(Customer)) Customer
            else
            if ("Source Type" = const(Vendor)) Vendor;
        }
        field(20; "Document ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Document ID';
        }
        field(21; "Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Document No.';
        }
        field(22; "External Document No."; Code[35])
        {
            DataClassification = CustomerContent;
            Caption = 'External Document No.';
        }
        field(30; "Document Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Document Date';
        }
        field(31; "Posting Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Posting Date';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}
#endif