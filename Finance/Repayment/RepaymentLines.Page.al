#if W1FN002A
page 60003 "YNS Repayment Lines"
{
    PageType = ListPart;
    SourceTable = "YNS Repayment Line";
    Caption = 'Repayment Lines';

    layout
    {
        area(Content)
        {
            repeater(control1)
            {
            }
        }
    }
}
#endif