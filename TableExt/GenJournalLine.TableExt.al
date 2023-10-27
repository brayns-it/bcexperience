tableextension 60016 YNSGenJournalLine extends "Gen. Journal Line"
{
    fields
    {
#if W1FN011A
        field(60001; "YNS Skip Pos./Neg. Error"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Skip Positive/Negative Error';
        }
#endif
#if W1FN012A
        field(60002; "YNS Accrual Starting Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Accrual Starting Date';

            trigger OnValidate()
            begin
                if (xRec."YNS Accrual Starting Date" <> Rec."YNS Accrual Starting Date") then
                    if Rec."YNS Accrual Starting Date" = 0D then
                        Rec."YNS Accrual Ending Date" := 0D
                    else begin
                        if Rec."Account Type" <> Rec."Account Type"::"G/L Account" then
                            Rec.FieldError("Account Type");
                        if (Rec."YNS Accrual Ending Date" > 0D) and (Rec."YNS Accrual Ending Date" < Rec."YNS Accrual Starting Date") then
                            Rec.FieldError("YNS Accrual Ending Date");
                    end;
            end;
        }
        field(60003; "YNS Accrual Ending Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Accrual Ending Date';

            trigger OnValidate()
            begin
                if (xRec."YNS Accrual Ending Date" <> Rec."YNS Accrual Ending Date") then
                    if Rec."YNS Accrual Ending Date" > 0D then begin
                        if Rec."Account Type" <> Rec."Account Type"::"G/L Account" then
                            Rec.FieldError("Account Type");
                        if (Rec."YNS Accrual Ending Date" > 0D) and (Rec."YNS Accrual Ending Date" < Rec."YNS Accrual Starting Date") then
                            Rec.FieldError("YNS Accrual Ending Date");
                    end;
            end;
        }
#endif

    }
}
