pageextension 60010 YNSGeneralJournal extends "General Journal"
{
    layout
    {
        addlast(Control1)
        {
#if W1FN012A
            field("YNS Accrual Starting Date"; Rec."YNS Accrual Starting Date")
            {
                ApplicationArea = All;
            }
            field("YNS Accrual Ending Date"; Rec."YNS Accrual Ending Date")
            {
                ApplicationArea = All;
            }
#endif
        }
    }
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