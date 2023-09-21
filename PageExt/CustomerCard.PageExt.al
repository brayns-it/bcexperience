pageextension 60005 YNSCustomerCard extends "Customer Card"
{
    layout
    {
#if W1FN003A
        addafter("Preferred Bank Account Code")
        {
            field("YNS Company Bank Account"; Rec."YNS Company Bank Account")
            {
                ApplicationArea = All;
            }
        }
#endif        
#if ITXX002A        
        addafter("PEC E-Mail Address")
        {
            field("YNS Send E-Invoice via PEC"; Rec."YNS Send E-Invoice via PEC")
            {
                ApplicationArea = All;
            }
        }
#endif    
    }
}