#if LOCALEIT
tableextension 60028 YNSPeriodicSettlementVATEntry extends "Periodic Settlement VAT Entry"
{
    fields
    {
#if ITXX008A
        field(60000; "YNS Sales Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Sales Amount';
        }
        field(60001; "YNS Purchase Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Purchase Amount';
        }
        field(60002; "YNS Sales Base"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Sales Base';
        }
        field(60003; "YNS Purchase Base"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Purchase Base';
        }
        field(60004; "YNS Periodic Communication No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Periodic Communication No.';
            BlankZero = true;
        }
#endif
    }
}
#endif