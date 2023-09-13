#if W1FN002A
page 60002 "YNS Repayment"
{
    PageType = Document;
    SourceTable = "YNS Repayment Header";
    Caption = 'Repayment';
    ApplicationArea = All;
    UsageCategory = Documents;

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
            }
            part(lines; "YNS Repayment Lines")
            {
                Caption = 'Lines';
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
            }
        }
    }
}
#endif