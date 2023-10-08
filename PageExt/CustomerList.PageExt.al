pageextension 60007 YNSCustomerList extends "Customer List"
{
    actions
    {
        addlast(processing)
        {
#if W1XX004A            
            action(YNSDocExchange)
            {
                Image = SwitchCompanies;
                Caption = 'Document Exchange';
                ApplicationArea = All;

                trigger OnAction()
                var
                    Cust: Record Customer;
                    DocXMgmt: Codeunit "YNS Doc. Exchange Management";
                    RecRef: RecordRef;
                begin
                    CurrPage.SetSelectionFilter(Cust);
                    RecRef.GetTable(Cust);
                    DocXMgmt.ManualProcessDocuments(RecRef, Page::"Customer List");
                end;
            }
#endif   
        }
    }
}