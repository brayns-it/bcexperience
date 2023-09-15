#if W1FN002A
page 60010 "YNS Issued Repayment Lines"
{
    PageType = ListPart;
    SourceTable = "YNS Issued Repayment Line";
    AutoSplitKey = true;
    SourceTableView = where("Line Type" = const(Entry));
    Caption = 'Issued Repayment Lines';
    Editable = false;

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
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                }
                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
#endif