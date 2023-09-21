pageextension 60004 YNSPostedSalesInvoices extends "Posted Sales Invoices"
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
                    SalesInvHead: Record "Sales Invoice Header";
                    DocXMgmt: Codeunit "YNS Doc. Exchange Management";
                    RecRef: RecordRef;
                begin
                    CurrPage.SetSelectionFilter(SalesInvHead);
                    RecRef.GetTable(SalesInvHead);
                    DocXMgmt.ManualProcessDocuments(RecRef);
                end;
            }
#endif
        }
    }
}