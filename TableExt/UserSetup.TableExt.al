tableextension 60019 YNSUserSetup extends "User Setup"
{
    fields
    {
#if W1XX008A
        field(60000; "YNS Allow Ledger Deletion"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Allow Ledger Deletion';
        }
#endif
    }
}