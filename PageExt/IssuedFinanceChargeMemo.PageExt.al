pageextension 60014 YNSIssuedFinanceChargeMemo extends "Issued Finance Charge Memo"
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
                    LedgDeletion.DeleteFinChargeMemoYN(Rec);
                end;
            }
#endif
        }
    }
}