pageextension 60010 YNSGeneralJournal extends "General Journal"
{
    actions
    {
        addlast("F&unctions")
        {
#if W1XX004A            
            action(YNSDocExchange)
            {
                Image = SwitchCompanies;
                Caption = 'Document Exchange';
                ApplicationArea = All;

                trigger OnAction()
                var
                    GenJnlLine: Record "Gen. Journal Line";
                    DocXMgmt: Codeunit "YNS Doc. Exchange Management";
                    RecRef: RecordRef;
                begin
                    CurrPage.SetSelectionFilter(GenJnlLine);
                    RecRef.GetTable(GenJnlLine);
                    DocXMgmt.ManualProcessDocuments(RecRef, Page::"General Journal");
                end;
            }
#endif
        }
    }
}