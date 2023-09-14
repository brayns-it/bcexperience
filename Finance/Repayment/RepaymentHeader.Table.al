#if W1FN002A
table 60000 "YNS Repayment Header"
{
    DataClassification = CustomerContent;
    Caption = 'Repayment Header';

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'No.';

            trigger OnValidate()
            begin
                if "No." <> xRec."No." then begin
                    RepaSetup.Get();
                    if RepaSetup."Repayment No. Series" > '' then
                        NoSeriesMgt.TestManual(RepaSetup."Repayment No. Series");
                    "No. Series" := '';
                end;
            end;
        }
        field(2; "Source Type"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Source Type';
            OptionMembers = Customer,Vendor;
            OptionCaption = 'Customer,Vendor';

            trigger OnValidate()
            begin
                if xRec."Source Type" <> "Source Type" then
                    TestNoLineExists();

                "Source No." := '';
                "Source Name" := '';
                "Source Address" := '';
                "Source City" := '';
                "Source Post Code" := '';
                "Source County" := '';
                "Source Country/Region Code" := '';
                "Currency Code" := '';
                "Company Bank Account Code" := '';
                "Payment Method Code" := '';
            end;
        }
        field(3; "Source No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Source No.';
            TableRelation = if ("Source Type" = const(Customer)) Customer
            else
            if ("Source Type" = const(Vendor)) Vendor;

            trigger OnValidate()
            var
                Cust: Record Customer;
                DefDescriptionLbl: Label 'Repayment plan for %1';
            begin
                if xRec."Source No." <> "Source No." then
                    TestNoLineExists();

                if "Source No." > '' then
                    case "Source Type" of
                        "Source Type"::Customer:
                            begin
                                Cust.Get("Source No.");
                                "Source Name" := Cust.Name;
                                "Source Address" := Cust.Address;
                                "Source City" := Cust.City;
                                "Source Post Code" := Cust."Post Code";
                                "Source County" := Cust.County;
                                "Source Country/Region Code" := Cust."Country/Region Code";
                                "Currency Code" := Cust."Currency Code";
                                "Company Bank Account Code" := Cust."YNS Company Bank Account";
                                "Payment Method Code" := Cust."Payment Method Code";
                            end;
                        "Source Type"::Vendor:
                            Error('TODO');
                    end;

                if "Document Date" = 0D then
                    "Document Date" := WorkDate();
                if "Posting Date" = 0D then
                    "Posting Date" := WorkDate();

                RepaSetup.Get();
                if "Gen. Prod. Posting Group" = '' then
                    "Gen. Prod. Posting Group" := RepaSetup."Def. Gen. Prod. Posting Group";
                if "VAT Prod. Posting Group" = '' then
                    "VAT Prod. Posting Group" := RepaSetup."Def. VAT Prod. Posting Group";
                if Description = '' then
                    Description := CopyStr(StrSubstNo(DefDescriptionLbl, "Source Name"), 1, MaxStrLen(Description));
            end;
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
    }
    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }

    var
        RepaSetup: Record "YNS Repayment Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;

    trigger OnInsert()
    begin
        if "No." = '' then begin
            RepaSetup.Get();
            RepaSetup.TestField("Repayment No. Series");
            NoSeriesMgt.InitSeries(RepaSetup."Repayment No. Series", xRec."No. Series", "Posting Date", "No.", "No. Series");
        end;
    end;

    trigger OnDelete()
    var
        RepaLine: Record "YNS Repayment Line";
    begin
        RepaLine.Reset();
        RepaLine.SetRange("Repayment No.", "No.");
        if not RepaLine.IsEmpty() then
            RepaLine.DeleteAll();
    end;

    procedure TestNoLineExists()
    var
        RepaLine: Record "YNS Repayment Line";
        RepaMustBeEmptyErr: Label 'Repayment %1 must be empty';
    begin
        RepaLine.Reset();
        RepaLine.SetRange("Repayment No.", "No.");
        if not RepaLine.IsEmpty() then
            Error(RepaMustBeEmptyErr, "No.");
    end;
}
#endif