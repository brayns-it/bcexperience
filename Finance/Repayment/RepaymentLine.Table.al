#if W1FN002A
table 60001 "YNS Repayment Line"
{
    DataClassification = CustomerContent;
    Caption = 'Repayment Line';

    fields
    {
        field(1; "Repayment No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'No.';
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

            trigger OnValidate()
            var
                GLAcc: Record "G/L Account";
                RepaHead: Record "YNS Repayment Header";
            begin
                if (xRec."Charge Account No." <> Rec."Charge Account No.") and (Rec."Charge Account No." > '') then begin
                    RepaHead.Get("Repayment No.");
                    GLAcc.Get(Rec."Charge Account No.");
                    Description := GLAcc.Name;
                    "Gen. Prod. Posting Group" := RepaHead."Gen. Prod. Posting Group";
                    "VAT Prod. Posting Group" := RepaHead."VAT Prod. Posting Group";
                end;
            end;
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
        key(PK; "Repayment No.", "Line Type", "Line No.")
        {
            Clustered = true;
        }
        key(S1; "Repayment No.", "Line Type")
        {
            SumIndexFields = Amount;
        }
    }

    trigger OnInsert()
    var
        RepaHead: Record "YNS Repayment Header";
    begin
        if Rec."Payment Method Code" = '' then
            if Rec."Repayment No." > '' then
                if RepaHead.Get(Rec."Repayment No.") then
                    Rec."Payment Method Code" := RepaHead."Payment Method Code";
    end;
}
#endif