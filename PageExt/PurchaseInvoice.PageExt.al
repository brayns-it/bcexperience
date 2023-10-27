pageextension 60032 YNSPurchaseInvoice extends "Purchase Invoice"
{
    layout
    {
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