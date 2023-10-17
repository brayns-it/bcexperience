#if W1XX004A
page 60015 "YNS Doc. Exchange Ref. Values"
{
    Caption = 'Document Exchange Reference Values';
    PageType = List;
    AutoSplitKey = true;
    SourceTable = "YNS Doc. Exchange Ref. Line";
    SourceTableView = sorting("Reference Code", "Reference Type", "Value Type", "Value 1", "Value 2")
        where("Reference Type" = const(Value));
    ContextSensitiveHelpPage = '/page/document-exchange';

    layout
    {
        area(Content)
        {
            repeater(control1)
            {
                field("Value Type"; Rec."Value Type")
                {
                    ApplicationArea = All;
                }
                field("Value 1"; Rec."Value 1")
                {
                    ApplicationArea = All;
                }
                field("Value 2"; Rec."Value 2")
                {
                    ApplicationArea = All;
                }
                field("Table ID"; Rec."Table ID")
                {
                    ApplicationArea = All;
                }
                field("Primary Key 1"; Rec."Primary Key 1")
                {
                    ApplicationArea = All;
                }
                field("Primary Key 2"; Rec."Primary Key 2")
                {
                    ApplicationArea = All;
                }
                field("Source Type"; Rec."Source Type")
                {
                    ApplicationArea = All;
                }
                field("Source No."; Rec."Source No.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}

#endif