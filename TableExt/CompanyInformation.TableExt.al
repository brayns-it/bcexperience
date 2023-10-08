tableextension 60003 YNSCompanyInformation extends "Company Information"
{
    fields
    {
#if W1FN007A
        field(60000; "YNS Preferred Bank Account"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Preferred Bank Account';
            TableRelation = "Bank Account";

            trigger OnValidate()
            var
                Bank: Record "Bank Account";
            begin
                if xRec."YNS Preferred Bank Account" <> "YNS Preferred Bank Account" then
                    if "YNS Preferred Bank Account" > '' then begin
                        bank.get("YNS Preferred Bank Account");
                        rec."Bank Account No." := bank."Bank Account No.";
                        rec."Bank Branch No." := bank."Bank Branch No.";
                        rec."Bank Name" := bank.Name;
                        rec.IBAN := Bank.IBAN;
                        rec.BBAN := Bank.BBAN;
                    end;
            end;
        }
#endif
    }
}