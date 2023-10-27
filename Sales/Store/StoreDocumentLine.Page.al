#if W1SA003A
page 60030 "YNS Store Document Line"
{
    PageType = ListPart;
    SourceTable = "YNS Store Document Line";
    Editable = false;
    Caption = 'Store Document Line';

    layout
    {
        area(Content)
        {
            repeater(control1)
            {
                field("External Line No."; Rec."External Line No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("External Group No."; Rec."External Group No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
#if W1PH001A
                field("YNS AIC Code"; Rec."YNS AIC Code")
                {
                    ApplicationArea = All;
                }
#endif 
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                }
                field("List Price (incl. VAT)"; Rec."List Price (incl. VAT)")
                {
                    ApplicationArea = All;
                }
#if W1PH001A
                field("Health Amount"; Rec."Health Amount")
                {
                    ApplicationArea = All;
                }
                field("Health Discount Amount"; Rec."Health Discount Amount")
                {
                    ApplicationArea = All;
                }
#endif
                field("Line Amount"; Rec."Line Amount")
                {
                    ApplicationArea = All;
                }
                field("VAT %"; Rec."VAT %")
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