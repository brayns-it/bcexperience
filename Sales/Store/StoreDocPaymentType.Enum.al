#if W1SA003A
enum 60006 "YNS Store Doc. Payment Type"
{
    Extensible = true;

    value(0; Payment)
    {
        Caption = 'Payment';
    }
    value(1; Credit)
    {
        Caption = 'Credit';
    }
    value(2; "Credit (closing)")
    {
        Caption = 'Credit (closing)';
    }
    value(3; "Rounding")
    {
        Caption = 'Rounding';
    }
}
#endif