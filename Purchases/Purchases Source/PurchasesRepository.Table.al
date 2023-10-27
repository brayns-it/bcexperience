#if W1PU002A
table 60024 "YNS Purchases Repository"
{
    DataClassification = CustomerContent;
    Caption = 'Purchases Repository';

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
                    if PPSetup."YNS Purchases Repository Nos." > '' then
                        NoSeriesMgt.TestManual(PPSetup."YNS Purchases Repository Nos.");
                end;
            end;
        }
        field(2; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(4; "Name 2"; Text[50])
        {
            Caption = 'Name 2';
            DataClassification = CustomerContent;
        }
        field(5; Address; Text[100])
        {
            Caption = 'Address';
            DataClassification = CustomerContent;
        }
        field(6; "Address 2"; Text[50])
        {
            Caption = 'Address 2';
            DataClassification = CustomerContent;
        }
        field(7; City; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'City';
            TableRelation = if ("Country/Region Code" = const('')) "Post Code".City
            else
            if ("Country/Region Code" = filter(<> '')) "Post Code".City where("Country/Region Code" = field("Country/Region Code"));
            ValidateTableRelation = false;

            trigger OnLookup()
            begin
#pragma warning disable AA0139
                PostCode.LookupPostCode(City, "Post Code", County, "Country/Region Code");
#pragma warning restore
            end;

            trigger OnValidate()
            begin
                PostCode.ValidateCity(City, "Post Code", County, "Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
            end;
        }
        field(35; "Country/Region Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Country/Region Code';
            TableRelation = "Country/Region";

            trigger OnValidate()
            begin
#pragma warning disable AA0139
                PostCode.CheckClearPostCodeCityCounty(City, "Post Code", County, "Country/Region Code", xRec."Country/Region Code");
#pragma warning restore
            end;
        }
        field(91; "Post Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Post Code';
            TableRelation = if ("Country/Region Code" = const('')) "Post Code"
            else
            if ("Country/Region Code" = filter(<> '')) "Post Code" where("Country/Region Code" = field("Country/Region Code"));
            ValidateTableRelation = false;

            trigger OnLookup()
            begin
#pragma warning disable AA0139
                PostCode.LookupPostCode(City, "Post Code", County, "Country/Region Code");
#pragma warning restore
            end;

            trigger OnValidate()
            begin
                PostCode.ValidatePostCode(City, "Post Code", County, "Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
            end;
        }
        field(92; County; Text[30])
        {
            CaptionClass = '5,1,' + "Country/Region Code";
            Caption = 'County';
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
        PPSetup: Record "Purchases & Payables Setup";
        PostCode: Record "Post Code";
        NoSeriesMgt: Codeunit NoSeriesManagement;

    trigger OnInsert()
    var
        NoSeries: Code[20];
    begin
        if "No." = '' then begin
            PPSetup.Get();
            PPSetup.TestField("YNS Purchases Repository Nos.");
            NoSeriesMgt.InitSeries(PPSetup."YNS Purchases Repository Nos.", '', WorkDate(), "No.", NoSeries);
        end;
    end;
}
#endif