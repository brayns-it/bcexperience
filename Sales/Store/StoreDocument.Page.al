#if W1SA003A
page 60029 "YNS Store Document"
{
    PageType = Card;
    SourceTable = "YNS Store Document";
    Editable = false;
    Caption = 'Store Document';

    layout
    {
        area(Content)
        {
            group(general)
            {
                Caption = 'General';

                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = All;
                }
                field("Document Time"; Rec."Document Time")
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = All;
                }
                field("Location-from Code"; Rec."Location-from Code")
                {
                    ApplicationArea = All;
                }
                field("Location-from Name"; Rec."Location-from Name")
                {
                    ApplicationArea = All;
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = All;
                }
                field("Reason Code"; Rec."Reason Code")
                {
                    ApplicationArea = All;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                }
            }
            part(Lines; "YNS Store Document Line")
            {
                Caption = 'Lines';
                ApplicationArea = All;
                SubPageLink = "Document Type" = field("Document Type"), "Document No." = field("No.");
            }
            part(Payments; "YNS Store Document Payment")
            {
                Caption = 'Payments';
                ApplicationArea = All;
                SubPageLink = "Document Type" = field("Document Type"), "Document No." = field("No.");
            }
        }
    }
}
#endif