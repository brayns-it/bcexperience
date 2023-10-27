#if W1SA003A
page 60028 "YNS Store Documents"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "YNS Store Document";
    Editable = false;
    Caption = 'Store Documents';
    CardPageId = "YNS Store Document";

    layout
    {
        area(Content)
        {
            repeater(control1)
            {
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = All;
                }
                field("Document Date"; Rec."Document Date")
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
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
#if W1XX004A
            action(YNSDocExchange)
            {
                Image = SwitchCompanies;
                Caption = 'Document Exchange';
                ApplicationArea = All;

                trigger OnAction()
                var
                    StoreDoc: Record "YNS Store Document";
                    DocXMgmt: Codeunit "YNS Doc. Exchange Management";
                    RecRef: RecordRef;
                begin
                    CurrPage.SetSelectionFilter(StoreDoc);
                    RecRef.GetTable(StoreDoc);
                    DocXMgmt.ManualProcessDocuments(RecRef, Page::"YNS Store Documents");
                end;
            }
#endif 
        }
    }

}
#endif