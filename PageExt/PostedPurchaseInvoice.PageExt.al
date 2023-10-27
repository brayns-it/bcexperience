pageextension 60022 YNSPostedPurchaseInvoice extends "Posted Purchase Invoice"
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
                    LedgDeletion.DeletePurchaseInvoiceYN(Rec);
                end;
            }
#endif
        }
    }
}