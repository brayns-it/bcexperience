/// <summary>
/// This page allows to show to the user a list of choices, each choice can have a code,
/// a description and a decription 2. It's possible to mark each choice with a tag.
/// Use it with RUNMODAL
/// </summary>
page 60016 "YNS List Select"
{
    PageType = StandardDialog;
    SourceTable = "Name/Value Buffer";
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
                field("Value Long"; Rec."Value Long")
                {
                    Caption = 'Code';
                    ApplicationArea = All;
                    Visible = NoVisible;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    Visible = DescriptionVisible;
                }
                field(Value; Rec.Value)
                {
                    ApplicationArea = All;
                    Visible = Description2Visible;
                }
            }
        }
    }

    procedure GetSelectedNo(): Text
    begin
        exit(Rec."Value Long");
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
        Rec.SetRange("Value Long", OptNo);
        if not Rec.IsEmpty() then
            exit;

        ID += 1;

        Rec.Init();
        Rec.ID := ID;
        Rec."Value Long" := CopyStr(OptNo, 1, MaxStrLen(Rec."Value Long"));
        Rec.Name := CopyStr(OptDescription, 1, MaxStrLen(Rec.Name));
        Rec.Value := CopyStr(OptDescription2, 1, MaxStrLen(Rec.Value));
        Rec.Insert();
    end;

    trigger OnOpenPage()
    begin
        Rec.Reset();
    end;

    var
        PageCapt: Text;
        ID: Integer;
        NoVisible: Boolean;
        DescriptionVisible: Boolean;
        Description2Visible: Boolean;
}