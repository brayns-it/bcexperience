#if W1PU002A
page 60033 "YNS Purchases Sources"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'Purchases Sources';
    SourceTable = "YNS Purchases Source";
    Editable = false;
    CardPageId = "YNS Purchases Source";

    layout
    {
        area(Content)
        {
            repeater(control1)
            {
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