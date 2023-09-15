#if W1FN002A
page 60006 "YNS Repayment Charges"
{
    PageType = List;
    SourceTable = "YNS Repayment Line";
    AutoSplitKey = true;
    SourceTableView = where("Line Type" = const(Charge));
    Caption = 'Repayment Charges';
    ContextSensitiveHelpPage = '/page/repayments';

    layout
    {
        area(Content)
        {
            repeater(control1)
            {
                field("Charge Account No."; Rec."Charge Account No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                }
                field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = All;
                }
                field("Charges Application"; Rec."Charges Application")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
#endif