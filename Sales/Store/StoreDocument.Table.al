#if W1SA003A
table 60017 "YNS Store Document"
{
    DataClassification = CustomerContent;
    Caption = 'Store Document';

    fields
    {
        field(1; "Document Type"; Enum "YNS Store Document Type")
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "No." <> xRec."No." then begin
                    StoreSetup.Get();
                    if StoreSetup."Document Nos." > '' then
                        NoSeriesMgt.TestManual(StoreSetup."Document Nos.");
                    "No. Series" := '';
                end;
            end;
        }
        field(2; "No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'No.';
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
        field(12; "External Document No."; Text[35])
        {
            DataClassification = CustomerContent;
            Caption = 'External Document No.';
        }
        field(15; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser";
        }
        field(20; "Location-from Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Location-from Code';
            TableRelation = Location;
        }
        field(21; "Location-from Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Location-from Name';
        }
        field(30; "Do not Invoice"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Do not Invoice';
        }
        field(31; "Document Time"; Time)
        {
            DataClassification = CustomerContent;
            Caption = 'Document Time';
        }
        field(33; "Reason Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Reason Code';
        }
        field(50; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(100; "Amount"; Decimal)
        {
            Caption = 'Amount';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = sum("YNS Store Document Line"."Line Amount" where("Document Type" = field("Document Type"), "Document No." = field("No.")));
        }
    }

    keys
    {
        key(PK; "Document Type", "No.")
        {
            Clustered = true;
        }
        key(K1; "Document Type", "External Document No.") { }
    }

    var
        StoreSetup: Record "YNS Store Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;

    trigger OnInsert()
    begin
        if "No." = '' then begin
            StoreSetup.Get();
            StoreSetup.TestField("Document Nos.");
            NoSeriesMgt.InitSeries(StoreSetup."Document Nos.", xRec."No. Series", "Document Date", "No.", "No. Series");
        end;
    end;
}
#endif