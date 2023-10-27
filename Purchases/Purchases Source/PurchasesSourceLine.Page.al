#if W1PU002A
page 60036 "YNS Purchases Source Line"
{
    PageType = Card;
    Caption = 'Purchases Source Line';
    SourceTable = "YNS Purchases Source Line";

    layout
    {
        area(Content)
        {
            group(general)
            {
                Caption = 'General';

                field("Purchases Source No."; Rec."Purchases Source No.")
                {
                    ApplicationArea = All;
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
#if W1PH003A
                field("Dafne ID"; Rec."Dafne ID")
                {
                    ApplicationArea = All;
                }
#endif
            }
        }
    }
}
#endif