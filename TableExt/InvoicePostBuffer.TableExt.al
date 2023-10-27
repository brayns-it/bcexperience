#pragma warning disable AL0432
// TODO (New Posting Buffer)
tableextension 60032 YNSInvoicePostBuffer extends "Invoice Post. Buffer"
{
    fields
    {
#if W1FN012A
        field(60002; "YNS Accrual Starting Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Accrual Starting Date';
        }
        field(60003; "YNS Accrual Ending Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Accrual Ending Date';
        }
#endif
    }
}
#pragma warning restore