#if W1FN002A
page 60008 "YNS Issued Repayment"
{
    PageType = Document;
    SourceTable = "YNS Issued Repayment Header";
    Caption = 'Issued Repayment';
    Editable = false;
    ContextSensitiveHelpPage = '/page/repayments';

    layout
    {
        area(Content)
        {
            group(general)
            {
                Caption = 'General';

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
                field("Source Address"; Rec."Source Address")
                {
                    ApplicationArea = All;
                }
                field("Source Post Code"; Rec."Source Post Code")
                {
                    ApplicationArea = All;
                }
                field("Source County"; Rec."Source County")
                {
                    ApplicationArea = All;
                }
                field("Source Country/Region Code"; Rec."Source Country/Region Code")
                {
                    ApplicationArea = All;
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; Rec."Posting Date")
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
                field("Charges Amount"; Rec."Charges Amount")
                {
                    ApplicationArea = All;
                }
            }
            part(lines; "YNS Issued Repayment Lines")
            {
                Caption = 'Lines';
                ApplicationArea = All;
                SubPageLink = "Issued Repayment No." = field("No.");
            }
            part(inst; "YNS Issued Repayment Inst.")
            {
                Caption = 'Installments';
                ApplicationArea = All;
                SubPageLink = "Issued Repayment No." = field("No.");
            }
            group(posting)
            {
                Caption = 'Posting';

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group")
                {
                    ApplicationArea = All;
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = All;
                }
                field("Finance Charge Terms"; Rec."Finance Charge Terms")
                {
                    ApplicationArea = All;
                }
                field("Company Bank Account Code"; Rec."Company Bank Account Code")
                {
                    ApplicationArea = All;
                }
                field("Payment Method Code"; Rec."Payment Method Code")
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
                    RepaSumm: Report "YNS Repayment Summary";
                begin
                    RepaSumm.LoadRepayment(Rec);
                    RepaSumm.Run();
                end;
            }
        }
        area(Navigation)
        {
            action(charges)
            {
                Caption = 'Charges';
                Image = Cost;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    Rec.OpenCharges();
                end;
            }
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
    }
}
#endif