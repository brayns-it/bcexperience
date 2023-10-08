tableextension 60012 YNSPurchaseHeader extends "Purchase Header"
{
#if ITXX002A
    trigger OnDelete()
    var
        ITInvoice: Record "YNS Italy E-Invoice";
    begin
        ITInvoice.Reset();
        ITInvoice.SetRange("Purchase Document Type", "Document Type");
        ITInvoice.SetRange("Purchase Document No.", "No.");
        if ITInvoice.FindFirst() then begin
            ITInvoice."Purchase Document No." := '';
            ITInvoice.Modify();
        end;
    end;
#endif
}