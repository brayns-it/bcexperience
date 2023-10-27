pageextension 60036 YNSPostedPurchInvoiceSubform extends "Posted Purch. Invoice Subform"
{
    layout
    {
        addlast(Control1)
        {
#if W1FN012A
            field("YNS Accrual Starting Date"; Rec."YNS Accrual Starting Date")
            {
                ApplicationArea = All;
            }
            field("YNS Accrual Ending Date"; Rec."YNS Accrual Ending Date")
            {
                ApplicationArea = All;
            }
#endif
        }
    }
}