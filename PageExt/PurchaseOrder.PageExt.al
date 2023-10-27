pageextension 60039 YNSPurchaseOrder extends "Purchase Order"
{
    layout
    {
#if W1PU002A
        addlast("Shipping and Payment")
        {
            field("YNS Purchases Source No."; Rec."YNS Purchases Source No.")
            {
                ApplicationArea = all;
            }
            field("YNS Repository No."; Rec."YNS Repository No.")
            {
                ApplicationArea = all;
            }
        }
#endif
    }
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
                    DocXMgmt.ManualProcessDocuments(RecRef, Page::"Purchase Order");
                end;
            }
#endif
        }
    }
}