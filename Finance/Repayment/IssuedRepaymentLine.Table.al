#if W1FN002A
table 60003 "YNS Issued Repayment Line"
{
    DataClassification = CustomerContent;
    Caption = 'Issued Repayment Line';

    fields
    {
        field(1; "Issued Repayment No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'No.';
            TableRelation = "YNS Issued Repayment Header";
        }
        field(2; "Line Type"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Line Type';
            OptionCaption = 'Entry,Installment,Calculation,Charge';
            OptionMembers = Entry,Installment,Calculation,Charge;
        }
        field(3; "Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Line No.';
        }
        field(5; "Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Document No.';
        }
        field(6; "Document Type"; Enum "Gen. Journal Document Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Document Type';
        }
        field(7; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
        }
        field(8; "Charge Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Charge Line No.';
        }
        field(10; "Posting Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Posting Date';
        }
        field(11; "Document Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Document Date';
        }
        field(12; "Description"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(13; "External Document No."; Code[35])
        {
            DataClassification = CustomerContent;
            Caption = 'External Document No.';
        }
        field(18; "Payment Method Code"; code[10])
        {
            Caption = 'Payment Method Code';
            TableRelation = "Payment Method";
            DataClassification = CustomerContent;
        }
        field(20; "Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Amount';
        }
        field(21; "Due Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Due Date';
        }
        field(22; "Installment Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Installment Date';
        }
        field(23; "Delay Days"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Delay Days';
            BlankZero = true;
        }
        field(24; "Principal Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Principal Amount';
        }
        field(25; "Interest Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Interest Amount';
        }
        field(26; "Additional Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Additional Amount';
            BlankZero = true;
        }
        field(27; "Interest Overflow"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Interest Overflow';
        }
        field(28; "Remaining Principal Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Remaining Principal Amount';
        }
        field(30; "Principal Amount Base"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Principal Amount Base';
        }
        field(40; "Installment Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Installment Line No.';
            BlankZero = true;
        }
        field(41; "Charges Application"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Charges Application';
            OptionMembers = "First Installment","Last Installment","Divide";
            OptionCaption = 'First Installment,Last Installment,Divide';
        }
        field(42; "Charge Account No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Charge Account No.';
            TableRelation = "G/L Account";
        }
        field(50; "Gen. Prod. Posting Group"; Code[20])
        {
            Caption = 'Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group";
            DataClassification = CustomerContent;
        }
        field(51; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            TableRelation = "VAT Product Posting Group";
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Issued Repayment No.", "Line Type", "Line No.")
        {
            Clustered = true;
        }
        key(S1; "Issued Repayment No.", "Line Type")
        {
            SumIndexFields = Amount;
        }
    }
}
#endif