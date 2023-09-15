#if W1FN002A
page 60007 "YNS Issued Repayment List"
{
    PageType = List;
    SourceTable = "YNS Issued Repayment Header";
    Caption = 'Issued Repayments';
    ApplicationArea = All;
    UsageCategory = History;
    CardPageId = "YNS Issued Repayment";
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
        area(Navigation)
        {
            action(finchg)
            {
                Caption = 'Issued Finance Charge Memo';
                Image = FinChargeMemo;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    Rec.OpenIssuedFinCharge();
                end;
            }
        }
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
                    RepaSumm: Report "YNS Repayment Summary";
                begin
                    RepaSumm.LoadRepayment(Rec);
                    RepaSumm.Run();
                end;
            }
        }
    }
}
#endif