#if W1XX004A
page 60014 "YNS Data Exchange Ref. Tables"
{
    Caption = 'Data Exchange Reference Tables';
    PageType = List;
    ApplicationArea = All;
    AutoSplitKey = true;
    SourceTable = "YNS Data Exchange Ref. Line";
    SourceTableView = sorting("Table ID", "Primary Key 1", "Primary Key 2") where("Reference Type" = const(Table));

    layout
    {
        area(Content)
        {
            repeater(control1)
            {
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
            }
        }
    }
}

#endif