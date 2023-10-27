tableextension 60031 YNSSalespersonPurchaser extends "Salesperson/Purchaser"
{
    fields
    {
#if ITXX009A
        field(60000; "YNS Fiscal Code"; code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Fiscal Code';
        }
#endif
    }
}