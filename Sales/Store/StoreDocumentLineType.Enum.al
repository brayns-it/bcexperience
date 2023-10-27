#if W1SA003A
enum 60005 "YNS Store Document Line Type"
{
    Extensible = true;

    value(0; Item)
    {
        Caption = 'Item';
    }
    value(1; Prepayment)
    {
        Caption = 'Prepayment';
    }
    value(2; Discount)
    {
        Caption = 'Discount';
    }
    value(3; "Item (adjustment)")
    {
        Caption = 'Item (adjustment)';
    }
    value(4; "Discount (total)")
    {
        Caption = 'Discount (total)';
    }
}
#endif