/// <summary>
/// This page allows to show to the user a list of choices, each choice can have a code,
/// a description and a decription 2. It's possible to mark each choice with a tag.
/// Use it with RUNMODAL
/// </summary>
page 60016 "YNS List Select"
{
    PageType = StandardDialog;
    SourceTable = Item;
    SourceTableTemporary = true;
    Caption = 'Select';
    DataCaptionExpression = GetCaption();
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(control1)
            {
                field("Search Description"; Rec."Search Description")
                {
                    Caption = 'Code';
                    ApplicationArea = All;
                    Visible = NoVisible;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Visible = DescriptionVisible;
                }
                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = All;
                    Visible = Description2Visible;
                }
            }
        }
    }

    procedure GetSelectedNo(): Text
    begin
        exit(Rec."Search Description");
    end;

    local procedure GetCaption(): Text
    begin
        exit(PageCapt);
    end;

    procedure SetCaption(NewCapt: Text)
    begin
        PageCapt := NewCapt;
    end;

    procedure GetCount(): Integer
    begin
        Rec.Reset();
        exit(Rec.Count());
    end;

    procedure SetColumns(ShowDescription: Boolean)
    begin
        SetColumns(false, ShowDescription, false);
    end;

    procedure SetColumns(ShowNo: Boolean; ShowDescription: Boolean)
    begin
        SetColumns(ShowNo, ShowDescription, false);
    end;

    procedure SetColumns(ShowNo: Boolean; ShowDescription: Boolean; ShowDescription2: Boolean)
    begin
        NoVisible := ShowNo;
        DescriptionVisible := ShowDescription;
        Description2Visible := ShowDescription2;
    end;

    procedure AddOption(OptDescription: Text)
    begin
        AddOption('', OptDescription, '');
    end;

    procedure AddOption(OptNo: Text; OptDescription: Text)
    begin
        AddOption(OptNo, OptDescription, '');
    end;

    procedure AddOption(OptNo: Text; OptDescription: Text; OptDescription2: Text)
    begin
        Rec.Reset();
        Rec.SetRange("Search Description", OptNo);
        if not Rec.IsEmpty() then
            exit;

        if ID = '' then
            ID := '000001'
        else
            ID := IncStr(ID);

        Rec.Init();
        Rec."No." := ID;
        Rec."Search Description" := CopyStr(OptNo, 1, MaxStrLen(Rec."Search Description"));
        Rec.Description := CopyStr(OptDescription, 1, MaxStrLen(Rec."Description"));
        Rec."Description 2" := CopyStr(OptDescription2, 1, MaxStrLen(Rec."Description 2"));
        Rec.Insert();
    end;

    trigger OnOpenPage()
    begin
        Rec.Reset();
    end;

    var
        PageCapt: Text;
        ID: Code[20];
        NoVisible: Boolean;
        DescriptionVisible: Boolean;
        Description2Visible: Boolean;
}