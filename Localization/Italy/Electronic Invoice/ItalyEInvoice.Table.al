#if ITXX002A
table 60009 "YNS Italy E-Invoice"
{
    DataClassification = CustomerContent;
    Caption = 'Italy E-Invoice';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(5; "Direction"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Direction';
            OptionMembers = " ",Inbound,Outbound;
            OptionCaption = ' ,Inbound,Outbound';
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
        field(12; "Source Description"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Source Description';
        }
        field(13; "Partner Group"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Partner Group';
            TableRelation = "YNS Partner Group";
        }
        field(15; "Document Type"; Code[20])
        {
            Caption = 'Document Type';
            TableRelation = "Fattura Document Type";
            DataClassification = CustomerContent;
        }
        field(18; "PA Code"; Code[7])
        {
            Caption = 'PA Code';
            DataClassification = CustomerContent;
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
        field(23; "Reverse Charge Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Reverse Charge Document No.';
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
        field(40; "Source VAT Registration No."; Text[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Source VAT Registration No.';
        }
        field(41; "Source Fiscal Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Source Fiscal Code';
        }
        field(50; "Send/Receive Date/Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Send/Receive Date/Time';
        }
        field(51; "Progressive No."; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Progressive No.';
        }
        field(52; "SdI Number"; Text[20])
        {
            DataClassification = CustomerContent;
            Caption = 'SdI Number';
        }
        field(53; "Transport ID"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Transport ID';
        }
        field(55; "SdI Status"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'SdI Status';
            OptionMembers = " ","Sent","Delivered to SdI","Delivered to Recipient","Error";
            OptionCaption = ' ,Sent,Delivered to SdI,Delivered to Recipient,Error';
        }
        field(56; "SdI Status Message"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'SdI Status Message';
        }
        field(60; "Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Amount';
        }
        field(61; "Currency Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Currency Code';
        }
        field(100; "File Path"; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'File Path';
        }
        field(101; "File Lot No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'File Lot No.';
        }
        field(150; "Purchase Document Type"; Enum "Purchase Document Type")
        {
            Caption = 'Purchase Document Type';
            DataClassification = CustomerContent;
        }
        field(151; "Purchase Document No."; Code[20])
        {
            Caption = 'Purchase Document No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    var
        FSMgmt: Codeunit "YNS File Storage Management";

    trigger OnDelete()
    begin
        if Direction = Direction::Inbound then begin
            TestField("Document No.", '');
            TestField("Purchase Document No.", '');
            TestField("SdI Number", '');
        end;

        if Direction = Direction::Outbound then
            if not ("SdI Status" in ["SdI Status"::" ", "SdI Status"::Error]) then
                FieldError("SdI Status");

        if "File Path" > '' then
            FSMgmt.DeleteFile("File Path");
    end;
}
#endif