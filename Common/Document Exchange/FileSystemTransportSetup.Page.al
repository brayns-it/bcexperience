#if W1XX004A
page 60026 "YNS FileSystem Transport Setup"
{
    PageType = Card;
    SourceTable = "YNS FileSystem Transport Setup";
    Caption = 'FileSystem Transport Setup';

    layout
    {
        area(Content)
        {
            group(general)
            {
                Caption = 'General';

                field("Profile Code"; Rec."Profile Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Remote Functions Code"; Rec."Remote Functions Code")
                {
                    ApplicationArea = All;
                }
                field(Protocol; Rec.Protocol)
                {
                    ApplicationArea = All;
                }
                field("Text Encoding"; Rec."Text Encoding")
                {
                    ApplicationArea = All;
                }
                field("Receving Base Path"; Rec."Receving Base Path")
                {
                    ApplicationArea = All;
                }
                field("Archive Received Files"; Rec."Archive Received Files")
                {
                    ApplicationArea = All;
                }
                field("Receving Base Path (archive)"; Rec."Receving Base Path (archive)")
                {
                    ApplicationArea = All;
                }
                field("Sending Base Path"; Rec."Sending Base Path")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
#endif