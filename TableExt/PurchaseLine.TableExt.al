tableextension 60017 YNSPurchaseLine extends "Purchase Line"
{
    fields
    {
#if W1PU001A
        field(60000; "YNS Incoming Line"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Incoming Line';
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
                        if Rec.Type <> Rec.Type::"G/L Account" then
                            Rec.FieldError(Type);
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
                        if Rec.Type <> Rec.Type::"G/L Account" then
                            Rec.FieldError(Type);
                        if (Rec."YNS Accrual Ending Date" > 0D) and (Rec."YNS Accrual Ending Date" < Rec."YNS Accrual Starting Date") then
                            Rec.FieldError("YNS Accrual Ending Date");
                    end;
            end;
        }
#endif
    }
}