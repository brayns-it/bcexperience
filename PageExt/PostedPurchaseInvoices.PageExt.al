pageextension 60029 YNSPostedPurchaseInvoices extends "Posted Purchase Invoices"
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
                    PurchInv: Record "Purch. Inv. Header";
                    DocXMgmt: Codeunit "YNS Doc. Exchange Management";
                    RecRef: RecordRef;
                begin
                    CurrPage.SetSelectionFilter(PurchInv);
                    RecRef.GetTable(PurchInv);
                    DocXMgmt.ManualProcessDocuments(RecRef, Page::"Posted Purchase Invoices");
                end;
            }
#endif
        }
    }
}