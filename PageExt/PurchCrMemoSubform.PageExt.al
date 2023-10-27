pageextension 60035 YNSPurchCrMemoSubform extends "Purch. Cr. Memo Subform"
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