#if W1XX009A
page 60027 "YNS Partner Group"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "YNS Partner Group";
    Caption = 'Partner Group';
    ContextSensitiveHelpPage = '/page/partner-group';

    layout
    {
        area(Content)
        {
            repeater(control1)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
#endif
