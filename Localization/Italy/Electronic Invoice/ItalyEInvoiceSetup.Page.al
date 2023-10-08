#if ITXX002A
page 60018 "YNS Italy E-Invoice Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "YNS Italy E-Invoice Setup";
    Caption = 'Italy E-Invoice Setup';
    ContextSensitiveHelpPage = '/page/electronic-invoicing-it';

    layout
    {
        area(Content)
        {
            group(general)
            {
                Caption = 'General';

                field("Working Path"; Rec."Working Path")
                {
                    ApplicationArea = All;
                }
                field("Stylesheet Path"; Rec."Stylesheet Path")
                {
                    ApplicationArea = All;
                }
            }
            group(outbound)
            {
                Caption = 'Outbound Documents';

                field("Last Progressive No."; Rec."Last Progressive No.")
                {
                    ApplicationArea = All;
                }
                field("Document No. Strip Chars"; Rec."Document No. Strip Chars")
                {
                    ApplicationArea = All;
                }
                field("Descr. Lines VAT Reference"; Rec."Descr. Lines VAT Reference")
                {
                    ApplicationArea = All;
                }
                field("Description Lines VAT Nature"; Rec."Description Lines VAT Nature")
                {
                    ApplicationArea = All;
                }
                field("Send Description Lines"; Rec."Send Description Lines")
                {
                    ApplicationArea = All;
                }
                field("Item No. Tag Name"; Rec."Item No. Tag Name")
                {
                    ApplicationArea = All;
                }
                field("Item Barcode Tag Name"; Rec."Item Barcode Tag Name")
                {
                    ApplicationArea = All;
                }
                field("Sending Exchange Reference"; Rec."Sending Exchange Reference")
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
            action(uploadxslt)
            {
                Caption = 'Upload stylesheet';
                Image = Import;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    ItInvFmt.UploadStylesheet();
                    CurrPage.Update(false);
                end;
            }
        }
    }

    var
        ItInvFmt: Codeunit "YNS Italy E-Invoice Format";

    trigger OnOpenPage()
    begin
        if not Rec.Get() then
            Rec.Insert();
    end;
}
#endif