#if W1XX004A
page 60025 "YNS Doc. Ex. Ref. Val. Account"
{
    Caption = 'Document Exchange Reference Value to Account';
    PageType = List;
    AutoSplitKey = true;
    SourceTable = "YNS Doc. Exchange Ref. Line";
    SourceTableView = sorting("Reference Code", "Reference Type", "Source Type", "Source No.", "Priority", "Value 1")
        where("Reference Type" = const("Value to Account"));
    ContextSensitiveHelpPage = '/page/document-exchange';

    layout
    {
        area(Content)
        {
            repeater(control1)
            {
                field("Source Type"; Rec."Source Type")
                {
                    ApplicationArea = All;
                }
                field("Source No."; Rec."Source No.")
                {
                    ApplicationArea = All;
                }
                field(Priority; Rec.Priority)
                {
                    ApplicationArea = all;
                }
                field("Value 1"; Rec."Value 1")
                {
                    ApplicationArea = All;
                }
                field("Primary Key 1"; Rec."Primary Key 1")
                {
                    ApplicationArea = All;
                    TableRelation = "G/L Account" where("Account Type" = const(Posting));
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Table ID" := database::"G/L Account";
    end;
}
#endif