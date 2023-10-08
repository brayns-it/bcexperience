#if LOCALEIT
tableextension 60011 YNSReprintInfoFiscalReports extends "Reprint Info Fiscal Reports"
{
    fields
    {
#if ITXX003A
        field(60000; "YNS Ending Debit Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Ending Debit Amount';
        }
        field(60001; "YNS Ending Credit Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Ending Credit Amount';
        }
#endif
    }
}
#endif