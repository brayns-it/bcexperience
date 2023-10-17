#if W1XX004A
page 60013 "YNS Doc. Exchange Ref. List"
{
    Caption = 'Document Exchange References';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "YNS Doc. Exchange Reference";
    ContextSensitiveHelpPage = '/page/document-exchange';

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
                    Lines.Reset();
                    Lines.FilterGroup(2);
                    Lines.SetRange("Reference Code", Rec.Code);
                    Lines.SetRange("Reference Type", Lines."Reference Type"::Table);
                    Page.Run(page::"YNS Doc. Exchange Ref. Tables", Lines);
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
                    Lines.Reset();
                    Lines.FilterGroup(2);
                    Lines.SetRange("Reference Code", Rec.Code);
                    Lines.SetRange("Reference Type", Lines."Reference Type"::Value);
                    Page.Run(page::"YNS Doc. Exchange Ref. Tables", Lines);
                end;
            }
            action(valtoacc)
            {
                ApplicationArea = All;
                Image = InteractionTemplate;
                Caption = 'Values to Accounts';
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    Lines.Reset();
                    Lines.FilterGroup(2);
                    Lines.SetRange("Reference Code", Rec.Code);
                    Lines.SetRange("Reference Type", Lines."Reference Type"::"Value to Account");
                    Page.Run(page::"YNS Doc. Ex. Ref. Val. Account", Lines);
                end;
            }
        }
    }

    var
        Lines: Record "YNS Doc. Exchange Ref. Line";
}

#endif