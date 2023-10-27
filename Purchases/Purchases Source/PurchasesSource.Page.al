#if W1PU002A
page 60034 "YNS Purchases Source"
{
    PageType = Card;
    Caption = 'Purchases Source';
    SourceTable = "YNS Purchases Source";

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
                field(Name; Rec.Name)
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
                field(Lines; Rec.Lines)
                {
                    ApplicationArea = All;
                }
                field(Obsolete; Rec.Obsolete)
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

    actions
    {
        area(Navigation)
        {
            action(actlines)
            {
                Image = AllLines;
                Caption = 'Lines';
                ApplicationArea = All;
                RunObject = page "YNS Purchases Source Lines";
                RunPageLink = "Purchases Source No." = field("No.");
            }
        }
    }
}
#endif