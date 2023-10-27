tableextension 60012 YNSPurchaseHeader extends "Purchase Header"
{
    fields
    {
#if W1PU002A
        field(60000; "YNS Purchases Source No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Purchases Source No.';
            TableRelation = "YNS Purchases Source";
        }
        field(60001; "YNS Repository No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Repository No.';
            TableRelation = "YNS Purchases Repository";
        }
#endif
    }

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