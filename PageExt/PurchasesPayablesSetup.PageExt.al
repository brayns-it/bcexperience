pageextension 60038 YNSPurchasesPayablesSetup extends "Purchases & Payables Setup"
{
    layout
    {
        addlast("Number Series")
        {
#if W1PU002A
            field("YNS Purchases Source Nos."; Rec."YNS Purchases Source Nos.")
            {
                ApplicationArea = All;
            }
#endif
        }
    }
}