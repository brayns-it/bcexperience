#if W1FN002A
page 60002 "YNS Repayment"
{
    PageType = Document;
    SourceTable = "YNS Repayment Header";
    Caption = 'Repayment';
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

                    trigger OnDrillDown()
                    begin
                        Rec.OpenCharges();
                    end;
                }
            }
            part(lines; "YNS Repayment Lines")
            {
                Caption = 'Lines';
                ApplicationArea = All;
                SubPageLink = "Repayment No." = field("No.");
            }
            part(inst; "YNS Repayment Installments")
            {
                Caption = 'Installments';
                ApplicationArea = All;
                SubPageLink = "Repayment No." = field("No.");
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
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(getentries)
            {
                Caption = 'Get Entries';
                Image = GetEntries;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    RepaMgmt.GetEntries(Rec);
                end;
            }
            action(suggest)
            {
                Caption = 'Suggest Installments';
                Image = Suggest;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                var
                    SuggRep: Report "YNS Suggest Repayment Inst.";
                begin
                    SuggRep.SetRepaymentHeader(Rec);
                    SuggRep.RunModal();
                end;
            }
            action(calculate)
            {
                Caption = 'Calculate';
                Image = Calculate;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    RepaMgmt.Calculate(Rec);
                end;
            }
            action(issue)
            {
                Caption = 'Issue';
                Image = IssueFinanceCharge;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    RepaMgmt.IssueRepaymentYesNo(Rec);
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
        }
    }

    var
        RepaMgmt: Codeunit "YNS Repayment Management";
}
#endif