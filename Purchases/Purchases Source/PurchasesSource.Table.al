#if W1PU002A
table 60022 "YNS Purchases Source"
{
    DataClassification = CustomerContent;
    Caption = 'Purchases Source';
    LookupPageId = "YNS Purchases Sources";
    DrillDownPageId = "YNS Purchases Sources";

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'No.';
            NotBlank = true;

            trigger OnValidate()
            begin
                if "No." <> xRec."No." then begin
                    PPSetup.Get();
                    if PPSetup."YNS Purchases Source Nos." > '' then
                        NoSeriesMgt.TestManual(PPSetup."YNS Purchases Source Nos.");
                end;
            end;
        }
        field(3; "Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Name';
        }
        field(10; "Vendor No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Vendor No.';
            TableRelation = Vendor;
        }
        field(11; "Purchaser Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Purchaser Code';
            TableRelation = "Salesperson/Purchaser";
        }
        field(12; "Repository No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Repository No.';
            TableRelation = "YNS Purchases Repository";
        }
        field(13; "Obsolete"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Obsolete';
        }
        field(30; "Lines"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("YNS Purchases Source Line" where("Purchases Source No." = field("No.")));
            Editable = false;
            BlankZero = true;
        }
#if W1PH003A
        field(500; "Dafne ID"; Code[35])
        {
            DataClassification = CustomerContent;
            Caption = 'Dafne ID';
        }
#endif
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }

    var
        PPSetup: Record "Purchases & Payables Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;

    trigger OnInsert()
    var
        NoSeries: Code[20];
    begin
        if "No." = '' then begin
            PPSetup.Get();
            PPSetup.TestField("YNS Purchases Source Nos.");
            NoSeriesMgt.InitSeries(PPSetup."YNS Purchases Source Nos.", '', WorkDate(), "No.", NoSeries);
        end;
    end;

    trigger OnDelete()
    var
        SrcLines: Record "YNS Purchases Source Line";
        Item: Record Item;
        UsedItemErr: Label 'Purchases Source %1 used in items';
    begin
        Item.Reset();
        Item.SetRange("YNS Purchases Source No.", Rec."No.");
        if not Item.IsEmpty() then
            Error(UsedItemErr, Rec."No.");

        SrcLines.Reset();
        SrcLines.SetRange("Purchases Source No.", Rec."No.");
        if not SrcLines.IsEmpty() then
            SrcLines.DeleteAll();
    end;
}
#endif