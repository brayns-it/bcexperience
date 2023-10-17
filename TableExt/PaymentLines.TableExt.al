#if LOCALEIT
tableextension 60018 YNSPaymentLines extends "Payment Lines"
{
#if ITXX004A
    procedure YNSRecalculatePercent()
    var
        PaymLine2: Record "Payment Lines";
        TotAmt: Decimal;
    begin
        PaymLine2.Reset();
        PaymLine2.SetRange("Sales/Purchase", Rec."Sales/Purchase");
        PaymLine2.SetRange(Type, Rec.Type);
        PaymLine2.SetRange(Code, Rec.Code);
        PaymLine2.SetRange("Journal Template Name", rec."Journal Template Name");
        PaymLine2.SetRange("Journal Line No.", rec."Journal Line No.");
        PaymLine2.CalcSums(Amount);
        TotAmt := PaymLine2.Amount;

        if TotAmt <> 0 then
            if PaymLine2.FindSet() then
                repeat
                    PaymLine2."Payment %" := PaymLine2.Amount / TotAmt * 100;
                    PaymLine2.Modify();
                until PaymLine2.Next() = 0;
    end;
#endif
}
#endif