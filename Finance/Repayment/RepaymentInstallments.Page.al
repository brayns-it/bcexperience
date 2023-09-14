#if W1FN002A
page 60004 "YNS Repayment Installments"
{
    PageType = ListPart;
    SourceTable = "YNS Repayment Line";
    AutoSplitKey = true;
    SourceTableView = where("Line Type" = const(Installment));
    Caption = 'Repayment Lines';

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