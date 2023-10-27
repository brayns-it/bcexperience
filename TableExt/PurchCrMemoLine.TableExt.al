tableextension 60030 YNSPurchCrMemoLine extends "Purch. Cr. Memo Line"
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