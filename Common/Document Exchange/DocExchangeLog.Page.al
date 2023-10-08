#if W1XX004A
page 60024 "YNS Doc. Exchange Log"
{
    Caption = 'Document Exchange Log';
    PageType = List;
    Editable = false;
    SourceTable = "YNS Doc. Exchange Log";
    ContextSensitiveHelpPage = '/page/document-exchange';

    layout
    {
        area(Content)
        {
            repeater(control1)
            {
                field("Profile Code"; Rec."Profile Code")
                {
                    ApplicationArea = All;
                    Visible = False;
                }
                field("Activity Date/Time"; Rec."Activity Date/Time")
                {
                    ApplicationArea = All;
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                }
                field("Log Type"; Rec."Log Type")
                {
                    ApplicationArea = All;
                }
                field("Activity Name"; Rec."Activity Name")
                {
                    ApplicationArea = All;
                }
                field("Log Message"; Rec."Log Message")
                {
                    ApplicationArea = All;
                }
                field(Parameters; Rec.Parameters)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
#endif