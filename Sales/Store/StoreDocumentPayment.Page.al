#if W1SA003A
page 60032 "YNS Store Document Payment"
{
    PageType = ListPart;
    SourceTable = "YNS Store Document Payment";
    Editable = false;
    Caption = 'Store Document Payment';

    layout
    {
        area(Content)
        {
            repeater(control1)
            {
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                }
                field("No."; Rec."No.")
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
                field("Apply to Document No."; Rec."Apply to Document No.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
#endif