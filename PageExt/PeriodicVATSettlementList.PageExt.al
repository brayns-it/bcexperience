#if LOCALEIT
pageextension 60030 YNSPeriodicVATSettlementList extends "Periodic VAT Settlement List"
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
                    VatSettl: Record "Periodic Settlement VAT Entry";
                    DocXMgmt: Codeunit "YNS Doc. Exchange Management";
                    RecRef: RecordRef;
                begin
                    CurrPage.SetSelectionFilter(VatSettl);
                    RecRef.GetTable(VatSettl);
                    DocXMgmt.ManualProcessDocuments(RecRef, Page::"Periodic VAT Settlement List");
                end;
            }
#endif
        }
    }
}
#endif