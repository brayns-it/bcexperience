#if W1XX004A
page 60013 "YNS Data Exchange Ref. List"
{
    Caption = 'Data Exchange References';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "YNS Data Exchange Reference";

    layout
    {
        area(Content)
        {
            repeater(control1)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(tables)
            {
                ApplicationArea = All;
                Image = InteractionTemplate;
                Caption = 'Tables';
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    Rec.OpenTablesPage();
                end;
            }
            action(values)
            {
                ApplicationArea = All;
                Image = InteractionTemplate;
                Caption = 'Values';
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    Rec.OpenValuesPage();
                end;
            }
        }
    }
}

#endif