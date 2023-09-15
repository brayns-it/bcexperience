#if W1FN002A
page 60001 "YNS Repayment Setup"
{
    PageType = Card;
    SourceTable = "YNS Repayment Setup";
    Caption = 'Repayment Setup';
    ApplicationArea = All;
    UsageCategory = Administration;
    ContextSensitiveHelpPage = '/page/repayments';

    layout
    {
        area(Content)
        {
            group(general)
            {
                Caption = 'General';

                field("Repayment No. Series"; Rec."Repayment No. Series")
                {
                    ApplicationArea = All;
                }
                field("Issued Repayment No. Series"; Rec."Issued Repayment No. Series")
                {
                    ApplicationArea = All;
                }
                field("Def. Gen. Prod. Posting Group"; Rec."Def. Gen. Prod. Posting Group")
                {
                    ApplicationArea = All;
                }
                field("Def. VAT Prod. Posting Group"; Rec."Def. VAT Prod. Posting Group")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get() then
            Rec.Insert();
    end;
}
#endif