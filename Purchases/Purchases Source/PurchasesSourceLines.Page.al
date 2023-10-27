#if W1PU002A
page 60035 "YNS Purchases Source Lines"
{
    PageType = List;
    Caption = 'Purchases Source Lines';
    SourceTable = "YNS Purchases Source Line";
    Editable = false;
    CardPageId = "YNS Purchases Source Line";

    layout
    {
        area(Content)
        {
            repeater(control1)
            {
                field("Purchases Source No."; Rec."Purchases Source No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                }
                field("Purchaser Code"; Rec."Purchaser Code")
                {
                    ApplicationArea = All;
                }
                field("Repository No."; Rec."Repository No.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
#endif