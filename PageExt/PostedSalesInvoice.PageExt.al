pageextension 60013 YNSPostedSalesInvoice extends "Posted Sales Invoice"
{
    actions
    {
        addlast(processing)
        {
#if W1XX008A            
            action(YNSDeleteDoc)
            {
                Image = Delete;
                Caption = 'Delete Document';
                ApplicationArea = All;

                trigger OnAction()
                var
                    LedgDeletion: Codeunit "YNS Ledger Deletion";
                begin
                    LedgDeletion.DeleteSalesInvoiceYN(Rec);
                end;
            }
#endif
        }
    }
}