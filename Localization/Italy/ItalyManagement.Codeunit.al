codeunit 60015 "YNS Italy Management"
{
#if ITXX006A
    procedure SalesFatturaStampAssistEdit(var SalesHeader: Record "Sales Header")
    var
        SRSetup: Record "Sales & Receivables Setup";
        SalesLine: Record "Sales Line";
        S: Integer;
        LineNo: Integer;
        StampModeQst: label 'Only declare stamp,Declare and apply stamp refund';
    begin
        SRSetup.Get();
        SalesHeader.TestField("Document Type", SalesHeader."Document Type"::Invoice);

        S := 1;
        if SRSetup."YNS Fattura Stamp G/L Acc." > '' then S := 2;
        S := StrMenu(StampModeQst, S);
        if S = 0 then exit;

        SRSetup.TestField("YNS Def. Fattura Stamp Amount");

        SalesLine.Reset();
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange("YNS System-Created Source", 'ITAPPLIEDSTAMP');
        SalesLine.DeleteAll(true);

        SalesHeader."Fattura Stamp" := false;
        SalesHeader."Fattura Stamp Amount" := 0;

        SalesLine.Reset();
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange("VAT %", 0);
        SalesLine.CalcSums(Amount);
        if SalesLine.Amount <= SRSetup."YNS Fattura Stamp Threshold" then
            exit;

        SalesHeader."Fattura Stamp" := true;
        SalesHeader."Fattura Stamp Amount" := SRSetup."YNS Def. Fattura Stamp Amount";

        if S = 2 then begin
            SRSetup.TestField("YNS Fattura Stamp G/L Acc.");

            LineNo := 10000;
            SalesLine.Reset();
            SalesLine.SetRange("Document Type", SalesHeader."Document Type");
            SalesLine.SetRange("Document No.", SalesHeader."No.");
            if SalesLine.FindLast() then
                LineNo += SalesLine."Line No.";

            SalesLine.Init();
            SalesLine."Document Type" := SalesHeader."Document Type";
            SalesLine."Document No." := SalesHeader."No.";
            SalesLine."Line No." := LineNo;
            SalesLine.Type := SalesLine.Type::"G/L Account";
            SalesLine.Validate("No.", SRSetup."YNS Fattura Stamp G/L Acc.");
            if SRSetup."YNS Fattura Stamp Description" > '' then
                SalesLine.Description := SRSetup."YNS Fattura Stamp Description";
            SalesLine.Validate(Quantity, 1);
            SalesLine.Validate("Unit Price", SRSetup."YNS Def. Fattura Stamp Amount");
            SalesLine."YNS System-Created Source" := 'ITAPPLIEDSTAMP';
            SalesLine.Insert();
        end;
    end;
#endif

#if ITXX003A
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Reporting Triggers", 'SubstituteReport', '', false, false)]
    local procedure SubstituteReport(ReportId: Integer; RunMode: Option Normal,ParametersOnly,Execute,Print,SaveAs,RunModal; RequestPageXml: Text; RecordRef: RecordRef; var NewReportId: Integer)
    begin
        case ReportId of
            Report::"G/L Book - Print":
                NewReportId := report::"YNS G/L Book - Print";
            Report::"VAT Register - Print":
                NewReportId := Report::"YNS VAT Register - Print";
        end;
    end;
#endif

#if ITXX005A
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Vendor Mgt.", 'OnAfterSetFilterForExternalDocNo', '', false, false)]
    local procedure OnAfterSetFilterForExternalDocNo(var VendorLedgerEntry: Record "Vendor Ledger Entry"; DocumentDate: Date)
    begin
        VendorLedgerEntry.SetRange("Document Date", CalcDate('<-CY>', DocumentDate), CalcDate('<CY>', DocumentDate));
    end;
#endif

#if ITXX007A
    [EventSubscriber(ObjectType::Codeunit, codeunit::"Gen. Jnl.-Post Line", 'OnHandleBillOnBeforeUpdateCustLedgEntryBankRcpt', '', false, false)]
    local procedure OnHandleBillOnBeforeUpdateCustLedgEntryBankRcpt(var OldCustLedgEntry2: Record "Cust. Ledger Entry"; var CustLedgEntry: Record "Cust. Ledger Entry"; IsUnApply: Boolean)
    var
        IssuedCustBill: Record "Issued Customer Bill Header";
        PaymMethod: Record "Payment Method";
        Bill: Record Bill;
    begin
        if (not IsUnApply) and (CustLedgEntry."Document Type" = CustLedgEntry."Document Type"::Payment) and
            OldCustLedgEntry2.Open and (not CustLedgEntry.Open) and (CustLedgEntry."Bank Receipts List No." > '')
        then begin
            IssuedCustBill.Get(CustLedgEntry."Bank Receipts List No.");

            PaymMethod.Get(IssuedCustBill."Payment Method Code");
            PaymMethod.TestField("Bill Code");

            Bill.Get(PaymMethod."Bill Code");
            if Bill."YNS Dishonored Payment Method" > '' then
                OldCustLedgEntry2."Payment Method Code" := Bill."YNS Dishonored Payment Method";
        end;
    end;

    [EventSubscriber(ObjectType::Table, database::"Customer Bill Line", 'OnBeforeValidateCumulativeBankReceipts', '', false, false)]
    local procedure OnBeforeValidateCumulativeBankReceipts(var CustomerBillLine: Record "Customer Bill Line"; xCustomerBillLine: Record "Customer Bill Line"; var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, database::"Customer Bill Line", 'OnBeforeValidateCumulativeBankReceipts', '', false, false)]
    local procedure OnBeforeValidateDirectDebitMandateID(var CustomerBillLine: Record "Customer Bill Line"; xCustomerBillLine: Record "Customer Bill Line"; var IsHandled: Boolean)
    var
        SEPADirectDebitMandate: Record "SEPA Direct Debit Mandate";
    begin
        IsHandled := true;
        if CustomerBillLine."Direct Debit Mandate ID" > '' then begin
            SEPADirectDebitMandate.Get(CustomerBillLine."Direct Debit Mandate ID");
            CustomerBillLine."Customer Bank Acc. No." := SEPADirectDebitMandate."Customer Bank Account Code";
        end;
    end;
#endif    
}