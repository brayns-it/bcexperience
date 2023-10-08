#if W1XX004A
page 60017 "YNS Doc. Exchange Profiles"
{
    Caption = 'Document Exchange Profiles';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "YNS Doc. Exchange Profile";
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
                field("Exchange Format"; Rec."Exchange Format")
                {
                    ApplicationArea = All;
                }
                field("Exchange Transport"; Rec."Exchange Transport")
                {
                    ApplicationArea = All;
                }
                field(Enabled; Rec.Enabled)
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
            action(log)
            {
                Caption = 'Activity Log';
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Image = Log;
                RunObject = page "YNS Doc. Exchange Log";
                RunPageLink = "Profile Code" = field(Code);
            }
        }
        area(Processing)
        {
            action(fmtsetup)
            {
                Caption = 'Format Setup';
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Image = Setup;

                trigger OnAction()
                begin
                    Rec.OpenFormatSetup();
                end;
            }
            action(trasetup)
            {
                Caption = 'Transport Setup';
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Image = Setup;

                trigger OnAction()
                begin
                    Rec.OpenTransportSetup();
                end;
            }
        }
    }
}

#endif