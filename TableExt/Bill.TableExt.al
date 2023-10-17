#if LOCALEIT
tableextension 60021 YNSBill extends Bill
{
    fields
    {
#if ITXX007A
        field(60000; "YNS Dishonored Acc. No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Dishonored Acc. No.';
            TableRelation = "G/L Account";
        }
        field(60001; "YNS Dishonored Payment Method"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Dishonored Payment Method';
            TableRelation = "Payment Method";
        }
#endif
    }
}
#endif