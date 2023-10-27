pageextension 60040 YNSPurchaseOrders extends "Purchase Orders"
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
                    PurchHead: Record "Purchase Header";
                    DocXMgmt: Codeunit "YNS Doc. Exchange Management";
                    RecRef: RecordRef;
                begin
                    CurrPage.SetSelectionFilter(PurchHead);
                    RecRef.GetTable(PurchHead);
                    DocXMgmt.ManualProcessDocuments(RecRef, Page::"Purchase Orders");
                end;
            }
#endif
        }
    }
}