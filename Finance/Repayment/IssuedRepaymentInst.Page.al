#if W1FN002A
page 60011 "YNS Issued Repayment Inst."
{
    PageType = ListPart;
    SourceTable = "YNS Issued Repayment Line";
    AutoSplitKey = true;
    SourceTableView = where("Line Type" = const(Installment));
    Caption = 'Repayment Installments';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(control1)
            {
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                }
                field("Additional Amount"; Rec."Additional Amount")
                {
                    ApplicationArea = All;
                }
                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = All;
                }
                field("Payment Method Code"; Rec."Payment Method Code")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
#endif