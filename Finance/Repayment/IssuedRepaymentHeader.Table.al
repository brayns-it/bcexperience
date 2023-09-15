#if W1FN002A
table 60002 "YNS Issued Repayment Header"
{
    DataClassification = CustomerContent;
    Caption = 'Issued Repayment Header';

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'No.';
        }
        field(2; "Source Type"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Source Type';
            OptionMembers = Customer,Vendor;
            OptionCaption = 'Customer,Vendor';
        }
        field(3; "Source No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Source No.';
            TableRelation = if ("Source Type" = const(Customer)) Customer
            else
            if ("Source Type" = const(Vendor)) Vendor;
        }
        field(10; "Document Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Document Date';
        }
        field(11; "Posting Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Posting Date';
        }
        field(12; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
            DataClassification = CustomerContent;
        }
        field(20; "Description"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(21; "Source Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Source Name';
        }
        field(22; "Source Address"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Source Address';
        }
        field(23; "Source City"; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Source City';
        }
        field(24; "Source Post Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Source Post Code';
        }
        field(25; "Source County"; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Source County';
        }
        field(26; "Source Country/Region Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(30; "Company Bank Account Code"; Code[20])
        {
            Caption = 'Company Bank Account Code';
            TableRelation = "Bank Account" where("Currency Code" = FIELD("Currency Code"));
            DataClassification = CustomerContent;
        }
        field(31; "Payment Method Code"; code[10])
        {
            Caption = 'Payment Method Code';
            TableRelation = "Payment Method";
            DataClassification = CustomerContent;
        }
        field(32; "Finance Charge Terms"; Code[10])
        {
            Caption = 'Finance Charge Terms';
            TableRelation = "Finance Charge Terms";
            DataClassification = CustomerContent;
        }
        field(40; "Gen. Prod. Posting Group"; Code[20])
        {
            Caption = 'Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group";
            DataClassification = CustomerContent;
        }
        field(41; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            TableRelation = "VAT Product Posting Group";
            DataClassification = CustomerContent;
        }
        field(50; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(100; "Interest Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Interest Amount';
            BlankZero = true;
            Editable = false;
        }
        field(101; "Principal Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Principal Amount';
            BlankZero = true;
            Editable = false;
        }
        field(102; "Charges Amount"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("YNS Issued Repayment Line".Amount where("Issued Repayment No." = field("No."), "Line Type" = const(Charge)));
            Caption = 'Charges Amount';
            BlankZero = true;
            Editable = false;
        }
        field(300; "Issued Fin. Charge Memo No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Issued Fin. Charge Memo No.';
            TableRelation = "Issued Fin. Charge Memo Header";
        }
        field(301; "Repayment Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Repayment Document No.';
        }
    }
    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }

    procedure OpenIssuedFinCharge()
    var
        IssuedChg: Record "Issued Fin. Charge Memo Header";
    begin
        if "Issued Fin. Charge Memo No." > '' then begin
            IssuedChg.Get("Issued Fin. Charge Memo No.");
            Page.Run(Page::"Issued Finance Charge Memo", IssuedChg);
        end;
    end;

    procedure OpenCharges()
    var
        RepaLine2: Record "YNS Issued Repayment Line";
    begin
        RepaLine2.Reset();
        RepaLine2.FilterGroup(2);
        RepaLine2.SetRange("Issued Repayment No.", Rec."No.");
        RepaLine2.SetRange("Line Type", RepaLine2."Line Type"::Charge);
        RepaLine2.FilterGroup(0);
        Page.Run(page::"YNS Issued Repayment Charges", RepaLine2);
    end;
}
#endif