tableextension 60004 YNSItem extends Item
{
    fields
    {
#if W1PU002A
        field(60001; "YNS Purchases Source No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Purchases Source No.';

            trigger OnValidate()
            var
                PurchSrc: Record "YNS Purchases Source";
            begin
                if (xRec."YNS Purchases Source No." <> Rec."YNS Purchases Source No.") and
                    (rec."YNS Purchases Source No." > '')
                then begin
                    PurchSrc.Get(rec."YNS Purchases Source No.");
                    if PurchSrc."Vendor No." > '' then
                        Validate("Vendor No.", PurchSrc."Vendor No.");
                end;
            end;
        }
#endif
    }
}