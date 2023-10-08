tableextension 60014 YNSGeneralLedgerSetup extends "General Ledger Setup"
{
    fields
    {
#if ITXX003A
        field(60000; "YNS Last Gen. Jnl. Reg. No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Last General Journal Reg. No.';
        }
#endif
    }
}