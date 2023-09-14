#if W1FN002A
report 60000 "YNS Suggest Repayment Inst."
{
    ProcessingOnly = true;
    Caption = 'Suggest Repayment Installments';

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(Content)
            {
                group(options)
                {
                    Caption = 'Options';

                    field(StartingDateCtl; StartingDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Starting Date';
                    }
                    field(DueDateFmlaCtl; DueDateFmla)
                    {
                        ApplicationArea = All;
                        Caption = 'Due Date Formula';
                    }
                    field(InstallmentAmountCtl; InstallmentAmount)
                    {
                        ApplicationArea = All;
                        Caption = 'Maximum Amount';
                        BlankZero = true;
                    }
                }
            }
        }
    }

    trigger OnPreReport()
    var
        StartingDateErr: Label 'Missing starting date';
        DueDateFmlaErr: Label 'Missing due date formula';
        InstallmentAmountErr: Label 'Missing installment amount';
        InstallResetQst: Label 'All installments will be deleted. Continue?';
    begin
        if StartingDate = 0D then
            Error(StartingDateErr);
        if Format(DueDateFmla) = '' then
            Error(DueDateFmlaErr);
        if InstallmentAmount <= 0 then
            Error(InstallmentAmountErr);
        if not Confirm(InstallResetQst) then
            Error('');
    end;

    trigger OnPostReport()
    var
        FinTerms: Record "Finance Charge Terms";
        RepaLine: Record "YNS Repayment Line";
        RepaMgmt: Codeunit "YNS Repayment Management";
        MinDate: Date;
        ApproxAmount: Decimal;
        Days: Integer;
        LineNo: Integer;
        N: Integer;
        InstallLbl: Label 'Installment %1';
    begin
        ApproxAmount := 0;
        MinDate := 0D;
        LineNo := 10000;

        RepaLine.Reset();
        RepaLine.SetRange("Repayment No.", RepaHead."No.");
        RepaLine.SetRange("Line Type", RepaLine."Line Type"::Entry);
        RepaLine.FindSet();
        repeat
            ApproxAmount += RepaLine.Amount;
            if (MinDate = 0D) or (RepaLine."Posting Date" < MinDate) then
                MinDate := RepaLine."Posting Date";
        until RepaLine.Next() = 0;

        Clear(FinTerms);
        if RepaHead."Finance Charge Terms" > '' then
            FinTerms.Get(RepaHead."Finance Charge Terms");

        if FinTerms."Interest Period (Days)" > 0 then begin
            Days := StartingDate - MinDate;
            if Days > 0 then
                ApproxAmount := ApproxAmount + (FinTerms."Interest Rate" / FinTerms."Interest Period (Days)" * Days / 100 * ApproxAmount);
        end;

        RepaLine.Reset();
        RepaLine.SetRange("Repayment No.", RepaHead."No.");
        RepaLine.SetRange("Line Type", RepaLine."Line Type"::Installment);
        if not RepaLine.IsEmpty() then
            RepaLine.DeleteAll();

        N := 1;
        repeat
            RepaLine.Init();
            RepaLine."Repayment No." := RepaHead."No.";
            RepaLine."Line Type" := RepaLine."Line Type"::Installment;
            RepaLine."Line No." := LineNo;
            RepaLine.Description := StrSubstNo(InstallLbl, N);
            RepaLine.Amount := InstallmentAmount;
            RepaLine."Payment Method Code" := RepaHead."Payment Method Code";
            RepaLine."Due Date" := StartingDate;
            RepaLine.Insert();
            LineNo += 10000;
            N += 1;
            StartingDate := CalcDate(DueDateFmla, StartingDate);
            ApproxAmount -= InstallmentAmount;
        until ApproxAmount <= 0;

        RepaMgmt.Calculate(RepaHead);
    end;

    procedure SetRepaymentHeader(var NewRepaHead: Record "YNS Repayment Header")
    begin
        RepaHead := NewRepaHead;
    end;

    var
        RepaHead: Record "YNS Repayment Header";
        DueDateFmla: DateFormula;
        StartingDate: Date;
        InstallmentAmount: Decimal;
}
#endif