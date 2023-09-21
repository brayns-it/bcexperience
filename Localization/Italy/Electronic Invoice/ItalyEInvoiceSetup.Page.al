#if ITXX002A
page 60018 "YNS Italy E-Invoice Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "YNS Italy E-Invoice Setup";
    Caption = 'Italy E-Invoice Setup';

    layout
    {
        area(Content)
        {
            group(general)
            {
                Caption = 'General';

                field("Last Progressive No."; Rec."Last Progressive No.")
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