#if W1FN002A
page 60005 "YNS Repayment List"
{
    PageType = List;
    SourceTable = "YNS Repayment Header";
    Caption = 'Repayments';
    ApplicationArea = All;
    UsageCategory = Documents;
    CardPageId = "YNS Repayment";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(control1)
            {
                field("No."; Rec."No.")
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
                field("Source Name"; Rec."Source Name")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Finance Charge Terms"; Rec."Finance Charge Terms")
                {
                    ApplicationArea = All;
                }
                field("Principal Amount"; Rec."Principal Amount")
                {
                    ApplicationArea = All;
                }
                field("Interest Amount"; Rec."Interest Amount")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Reporting)
        {
            action(summary)
            {
                Caption = 'Summary';
                Image = Report;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                var
                    RepaHead2: Record "YNS Repayment Header";
                begin
                    RepaHead2 := Rec;
                    RepaHead2.SetRecFilter();
                    Report.Run(report::"YNS Repayment Summary", true, true, RepaHead2);
                end;
            }
        }
    }
}
#endif