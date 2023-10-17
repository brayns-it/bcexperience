#if LOCALEIT
pageextension 60018 YNSIssuedCustomerBillCard extends "Issued Customer Bill Card"
{
    actions
    {
#if ITXX007A        
        modify(ExportIssuedBillToFile)
        {
            Enabled = false;
            Visible = false;
        }
        modify(ExportIssuedBillToFloppyFile)
        {
            Enabled = false;
            Visible = false;
        }
        addlast(processing)
        {
            action(YNSDocExchange)
            {
                Image = SwitchCompanies;
                Caption = 'Document Exchange';
                ApplicationArea = All;

                trigger OnAction()
                var
                    IsbbBill: Record "Issued Customer Bill Header";
                    DocXMgmt: Codeunit "YNS Doc. Exchange Management";
                    RecRef: RecordRef;
                begin
                    IsbbBill.Get(Rec."No.");
                    IsbbBill.SetRecFilter();
                    RecRef.GetTable(IsbbBill);
                    DocXMgmt.ManualProcessDocuments(RecRef, Page::"Issued Customer Bill Card");
                end;
            }

        }
#endif
    }
}
#endif