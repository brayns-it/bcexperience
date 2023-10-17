pageextension 60003 YNSSalesInvoice extends "Sales Invoice"
{
    layout
    {
#if ITXX006A
        modify("Fattura Stamp Amount")
        {
            trigger OnAssistEdit()
            var
                ITMgmt: Codeunit "YNS Italy Management";
            begin
                ITMgmt.SalesFatturaStampAssistEdit(Rec);
            end;
        }
#endif
        addlast("Invoice Details")
        {
#if W1FN005A
            field("YNS Posting No."; Rec."Posting No.")
            {
                ApplicationArea = All;
                Editable = PostingNoEditable;

                trigger OnAssistEdit()
                begin
                    PostingNoEditable := not PostingNoEditable;
                end;
            }
#endif
        }
    }

    var
        PostingNoEditable: Boolean;
}