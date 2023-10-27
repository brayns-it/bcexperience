tableextension 60001 YNSCustLedgerEntry extends "Cust. Ledger Entry"
{
    fields
    {
#if W1FN003A
        field(60000; "YNS Company Bank Account"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Company Bank Account';
            TableRelation = "Bank Account";
        }
#endif
#if W1FN004A
        field(60001; "YNS Original Due Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Original Due Date';
        }
#endif
#if W1FN002A
        field(60003; "YNS Last Repayment No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Last Repayment No.';
            TableRelation = "YNS Issued Repayment Header";
            Editable = false;
        }
#endif
    }
}