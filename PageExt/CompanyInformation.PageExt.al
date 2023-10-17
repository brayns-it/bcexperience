pageextension 60008 YNSCompanyInformation extends "Company Information"
{
    layout
    {
#if W1FN003A
        addbefore("Bank Name")
        {
            field("YNS Preferred Bank Account"; Rec."YNS Preferred Bank Account")
            {
                ApplicationArea = all;
            }
        }
#endif
    }
}