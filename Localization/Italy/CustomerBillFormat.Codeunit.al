#if ITXX007A
codeunit 60021 "YNS Customer Bill Format" implements "YNS Doc. Exchange Format"
{
    var
        GlobalProfile: Record "YNS Doc. Exchange Profile";
        GlobalLog: Record "YNS Doc. Exchange Log";
        PaymMethod: Record "Payment Method";
        Customer: Record Customer;
        CustBank: Record "Customer Bank Account";
        GenJnlBatch: Record "Gen. Journal Batch";
        CompanyInfo: Record "Company Information";
        BankAcc: Record "Bank Account";
        Functions: Codeunit "YNS Functions";
        DocExMgmt: Codeunit "YNS Doc. Exchange Management";
        StringBuilder: Codeunit DotNet_StringBuilder;
        GlobalTransport: Interface "YNS Doc. Exchange Transport";
        CurrCode: Text;
        ProcessAction: Text;
        DishonoredAmount: Decimal;
        ModuleNo: Integer;

    procedure SetLog(var Log: Record "YNS Doc. Exchange Log")
    begin
        GlobalLog := Log;
    end;

    procedure OpenSetup()
    begin
        // do nothing
    end;

    procedure GetManualProcessOptions(var SelectedProfile: Record "YNS Doc. Exchange Profile"; var TempOptions: Record "Name/Value Buffer" temporary; var DocRefs: RecordRef; PageID: Integer)
    var
        GenJnlLine: Record "Gen. Journal Line";
        Param: Text;
        ImportDishonoredLbl: Label 'Import CBI Dishonored';
        ExportCbiLbl: Label 'Export CBI Customer Bill';
    begin
        case DocRefs.Number of
            Database::"Issued Customer Bill Header":
                DocExMgmt.AddProcessOption(SelectedProfile.Code, SelectedProfile."Exchange Format", 'EXPORT_CBI_BILL', ExportCbiLbl, TempOptions);
        end;

        case PageID of
            page::"Cash Receipt Journal":
                begin
                    DocRefs.SetTable(GenJnlLine);
                    Param := 'IMPORT_CBI_DISH,' + GenJnlLine.GetRangeMax("Journal Template Name") + ',' + GenJnlLine.GetRangeMax("Journal Batch Name");
                    DocExMgmt.AddProcessOption(SelectedProfile.Code, SelectedProfile."Exchange Format", Param, ImportDishonoredLbl, TempOptions);
                end;
        end;
    end;

    procedure SetProfile(var ExProfile: Record "YNS Doc. Exchange Profile")
    begin
        GlobalProfile := ExProfile;
    end;

    procedure Process(Parameters: List of [Text]; var DocRefs: RecordRef)
    begin
        Parameters.Get(1, ProcessAction);

        GlobalTransport := GlobalProfile."Exchange Transport";
        GlobalTransport.SetProfile(GlobalProfile);

        case ProcessAction of
            'EXPORT_CBI_BILL':
                ExportCBIBill(DocRefs);
            'IMPORT_CBI_DISH':
                ImportCBIDishonored(Parameters);
        end;
    end;

    procedure ImportCBIDishonored(Parameters: List of [Text])
    var
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlLine2: Record "Gen. Journal Line";
        TempBlob: Codeunit "Temp Blob";
        IStream: InStream;
        TemplateName: Text;
        BatchName: Text;
        Stream: Text;
        Line: Text;
        PostDateTxt: Text;
        LineNo: Integer;
        StartingLineNo: Integer;
    begin
        Stream := GlobalTransport.Receive('INSOLUTI.TXT', 'text/plain');
        TempBlob := Functions.ConvertTextToBlob(Stream);
        IStream := TempBlob.CreateInStream(TextEncoding::UTF8);

        Parameters.Get(2, TemplateName);
        Parameters.Get(3, BatchName);

        GenJnlLine.Reset();
        GenJnlLine.SetRange("Journal Template Name", TemplateName);
        GenJnlLine.SetRange("Journal Batch Name", BatchName);
        GenJnlLine.DeleteAll(true);

        GenJnlLine2.CopyFilters(GenJnlLine);

        GenJnlBatch.Get(TemplateName, BatchName);

        LineNo := 10000;
        StartingLineNo := 0;

        while not IStream.EOS() do begin
            IStream.ReadText(Line);
            Line := PADSTR(Line, 120, ' ');

            if ImportCBIDishonoredLine(GenJnlLine, LineNo, Line) then begin
                if StartingLineNo = 0 then
                    StartingLineNo := GenJnlLine."Line No.";
            end else
                if Line.StartsWith(' 1') then begin
                    PostDateTxt := Line.Substring(11, 6).Trim();
                    if PostDateTxt > '' then begin
                        GenJnlLine2.SetRange("Line No.", StartingLineNo, GenJnlLine."Line No.");
                        GenJnlLine2.ModifyAll("Posting Date", Functions.ConvertTextToDate(PostDateTxt, 'ddMMyy'));
                    end;
                    StartingLineNo := 0;
                end;
        end;

        if not GlobalLog.HasErrors() then
            GlobalTransport.ReceiveConfirm();
    end;

    procedure ImportCBIDishonoredLine(var GenJnlLine: Record "Gen. Journal Line"; var LineNo: Integer; Line: Text): Boolean
    var
        CustLedg: Record "Cust. Ledger Entry";
        DirectDebit: Record "SEPA Direct Debit Mandate";
        IssuedCustBill: Record "Issued Customer Bill Header";
        Bill: Record Bill;
        DirectID: Text;
        BillNo: Text;
        CustomerNo: Text;
        NotFoundErr: Label '%1 %2 not found';
        BillNotFoundErr: Label 'Customer %1 bill %2 not found';
        PaymentMismatchErr: Label 'Customer %1 payment bill %2 must be %3';
        DishonoredTxt: Label 'Dishonored %1 %2 %3';
        DoNotApply: Boolean;
    begin
        if Line.StartsWith(' 10') then begin
            Clear(Customer);
            DirectID := Line.Substring(98, 16).Trim();
            if DirectID = '' then
                exit(false);

            if not DirectDebit.Get(DirectID) then begin
                GlobalLog.AppendError(ProcessAction, StrSubstNo(NotFoundErr, DirectDebit.TableCaption, DirectID));
                exit(false);
            end;

            Customer.Get(DirectDebit."Customer No.");
            Evaluate(DishonoredAmount, Line.Substring(34, 13).Trim());
            DishonoredAmount := DishonoredAmount / 100;
        end;

        if Line.StartsWith(' 14') then begin
            Clear(Customer);
            CustomerNo := Line.Substring(98, 16).Trim();
            if CustomerNo = '' then
                exit(false);
            if not Customer.Get(CustomerNo) then begin
                GlobalLog.AppendError(ProcessAction, StrSubstNo(NotFoundErr, Customer.TableCaption, CustomerNo));
                exit(false);
            end;
            Evaluate(DishonoredAmount, Line.Substring(34, 13).Trim());
            DishonoredAmount := DishonoredAmount / 100;
        end;

        if (Line.StartsWith(' 70') or (Line.StartsWith(' 51'))) and (Customer."No." > '') then begin
            BillNo := Line.Substring(11, 10).Trim();
            if BillNo = '' then
                exit(false);

            if not FindPaymentCustLedgerByBillNo(BillNo, CustLedg) then begin
                GlobalLog.AppendError(ProcessAction, StrSubstNo(BillNotFoundErr, Customer."No.", BillNo));
                exit(false);
            end;

            DoNotApply := false;
            CustLedg.CalcFields("Remaining Amount");
            if CustLedg."Remaining Amount" <> -DishonoredAmount then begin
                GlobalLog.AppendWarning(ProcessAction, StrSubstNo(PaymentMismatchErr, Customer."No.", BillNo, DishonoredAmount));
                DoNotApply := true;
            end;

            IssuedCustBill.Get(CustLedg."Document No.");
            PaymMethod.Get(IssuedCustBill."Payment Method Code");
            PaymMethod.TestField("Bill Code");
            Bill.Get(PaymMethod."Bill Code");

            GenJnlLine.Init();
            GenJnlLine."Journal Template Name" := GenJnlBatch."Journal Template Name";
            GenJnlLine."Journal Batch Name" := GenJnlBatch.Name;
            GenJnlLine."Line No." := LineNo;
            GenJnlLine."Document No." := CustLedg."Document No.";
            GenJnlLine."Posting Date" := CustLedg."Due Date";
            GenJnlLine."Due Date" := CustLedg."Due Date";
            GenJnlLine."Account Type" := GenJnlLine."Account Type"::Customer;
            GenJnlLine.Validate("Account No.", Customer."No.");
            GenJnlLine.Description := CopyStr(StrSubstNo(DishonoredTxt, CustLedg."Document Type to Close", CustLedg."Document No. to Close", Customer.Name), 1, MaxStrLen(GenJnlLine.Description));
            GenJnlLine."Document Type" := GenJnlLine."Document Type"::Dishonored;
            GenJnlLine.Validate(Amount, DishonoredAmount);

            if not DoNotApply then begin
                GenJnlLine."Applies-to Doc. Type" := CustLedg."Document Type";
                GenJnlLine."Applies-to Doc. No." := CustLedg."Document No.";
                GenJnlLine."Applies-to Occurrence No." := CustLedg."Document Occurrence";
            end;

            GenJnlLine."Gen. Posting Type" := GenJnlLine."Gen. Posting Type"::" ";
            GenJnlLine."Gen. Bus. Posting Group" := '';
            GenJnlLine."Gen. Prod. Posting Group" := '';
            GenJnlLine."VAT Bus. Posting Group" := '';
            GenJnlLine."VAT Prod. Posting Group" := '';

            if Bill."YNS Dishonored Acc. No." > '' then begin
                GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"G/L Account";
                GenJnlLine."Bal. Account No." := Bill."YNS Dishonored Acc. No.";
            end else begin
                GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"Bank Account";
                GenJnlLine."Bal. Account No." := IssuedCustBill."Bank Account No.";
            end;

            GenJnlLine.Insert();
            LineNo += 10000;
            exit(true);
        end;
    end;

    local procedure FindPaymentCustLedgerByBillNo(BillNo: Text; var CustLedg: Record "Cust. Ledger Entry"): Boolean
    var
        FilterTxt: Text;
    begin
        BillNo := DelChr(BillNo, '<', '0');
        FilterTxt := '';

        while StrLen(BillNo) <= 10 do begin
            if FilterTxt > '' then FilterTxt += '|';
            FilterTxt += BillNo;
            BillNo := '0' + BillNo;
        end;

        CustLedg.Reset();
        CustLedg.SetRange("Customer No.", Customer."No.");
        CustLedg.SetRange(Positive, true);
        CustLedg.SetFilter("Customer Bill No.", FilterTxt);     // bill on invoice
        if not CustLedg.FindFirst() then begin
            CustLedg.Reset();
            CustLedg.SetRange("Customer No.", Customer."No.");
            CustLedg.SetRange("Document Type", CustLedg."Document Type"::Payment);
            CustLedg.SetFilter("Customer Bill No.", FilterTxt);     // bill on payment
            if CustLedg.FindFirst() then
                exit(true)
            else
                exit(false);
        end;

        CustLedg.Reset();
        CustLedg.SetRange("Customer No.", Customer."No.");
        CustLedg.SetRange("Document Type", CustLedg."Document Type"::Payment);
        CustLedg.SetRange("Document Type to Close", CustLedg."Document Type");
        CustLedg.SetRange("Document No. to Close", CustLedg."Document No.");
        CustLedg.SetRange("Document Occurrence to Close", CustLedg."Document Occurrence");
        CustLedg.SetRange("Document No.", CustLedg."Bank Receipts List No.");
        if not CustLedg.FindFirst() then
            exit(false);

        exit(true);
    end;

    procedure ExportCBIBill(var DocRef: RecordRef)
    var
        BillHeader: Record "Issued Customer Bill Header";
        BillLine: Record "Issued Customer Bill Line";
        GenSetup: Record "General Ledger Setup";
        Line: Text;
        LineAmount: Decimal;
        BillAmount: Decimal;
        Description: Text;
        BillNo: Integer;
        NumericErr: Label '%1 must be numeric';
        InvLbl: Label 'Inv.';
        Comma: Boolean;
        IsCumulative: Boolean;
    begin
        DocRef.SetTable(BillHeader);

        BillHeader.TestField("Payment Method Code");
        BillHeader.TestField("Bank Account No.");

        BankAcc.Get(BillHeader."Bank Account No.");
        BankAcc.TestField(ABI);

        PaymMethod.Get(BillHeader."Payment Method Code");
        PaymMethod.TestField("Bill Code");

        GenSetup.Get();
        GenSetup.TestField("LCY Code", 'EUR');
        CurrCode := 'E';

        CompanyInfo.Get();
        CompanyInfo.TestField("SIA Code");

        StringBuilder.InitStringBuilder('');
        ModuleNo := 0;
        BillAmount := 0;

        // header
        if PaymMethod."Direct Debit" then
            Line := ' IR' +
                       FORMAT(CompanyInfo."SIA Code", 5) +
                       CONVERTSTR(FORMAT(BankAcc.ABI, 5), ' ', '0') +
                       FORMAT(BillHeader."Posting Date", 6, 5) +
                       FORMAT(BillHeader."No.", 20) +
                       PadStr('', 73, ' ') +
                       'V' +
                       CurrCode
        else
            Line := ' IB' +
                       FORMAT(CompanyInfo."SIA Code", 5) +
                       CONVERTSTR(FORMAT(BankAcc.ABI, 5), ' ', '0') +
                       FORMAT(BillHeader."Posting Date", 6, 5) +
                       FORMAT(BillHeader."No.", 20) +
                       PadStr('', 74, ' ') +
                       CurrCode;

        StringBuilder.Append(PADSTR(Line, 120, ' '));
        StringBuilder.AppendLine();

        // lines
        BillLine.Reset();
        BillLine.SetCurrentKey("Customer No.", "Due Date", "Customer Bank Acc. No.", "Cumulative Bank Receipts");
        BillLine.SetRange("Customer Bill No.", BillHeader."No.");
        BillLine.SetRange("Recalled by", '');
        BillLine.FindSet();
        repeat
            BillLine.TestField("Customer Bank Acc. No.");
            if PaymMethod."Direct Debit" then
                BillLine.TestField("Direct Debit Mandate ID");

            BillLine.TestField("Final Cust. Bill No.");
            Evaluate(BillNo, BillLine."Final Cust. Bill No.");
            if Format(BillNo, 0, 9) <> BillLine."Final Cust. Bill No." then
                Error(NumericErr, BillLine.FieldCaption("Final Cust. Bill No."));

            Description := '';
            LineAmount := 0;
            IsCumulative := false;

            if BillLine."Cumulative Bank Receipts" then begin
                BillLine.SetRange("Customer No.", BillLine."Customer No.");
                BillLine.SetRange("Due Date", BillLine."Due Date");
                BillLine.SetRange("Customer Bank Acc. No.", BillLine."Customer Bank Acc. No.");
                BillLine.SetRange("Cumulative Bank Receipts", BillLine."Cumulative Bank Receipts");

                if BillLine.Count > 1 then begin
                    IsCumulative := true;
                    Comma := false;
                    Description += InvLbl + ' ';
                    repeat
                        LineAmount += BillLine.Amount;
                        if Comma then Description += '; ';
                        Description += BillLine."Document No.";
                        Comma := true;
                    until BillLine.Next() = 0;
                end;

                BillLine.SetRange("Customer No.");
                BillLine.SetRange("Due Date");
                BillLine.SetRange("Customer Bank Acc. No.");
                BillLine.SetRange("Cumulative Bank Receipts");
            end;

            if not IsCumulative then begin
                LineAmount := BillLine.Amount;
                Description := InvLbl + ' ' + BillLine."Document No." + ' ' + Format(BillLine."Document Date", 0, '<Day,2>/<Month,2>/<Year,2>');
            end;

            Customer.Get(BillLine."Customer No.");
            CustBank.Get(BillLine."Customer No.", BillLine."Customer Bank Acc. No.");

            ExportCBILine(BillLine, Description, LineAmount);

            BillAmount += LineAmount;
        until BillLine.Next() = 0;

        // footer
        BillAmount := Round(BillAmount * 100, 1);
        Line := ' EF';
        Line +=
           FORMAT(CompanyInfo."SIA Code", 5) +
           CONVERTSTR(FORMAT(BankAcc.ABI, 5), ' ', '0') +
           FORMAT(BillHeader."Posting Date", 6, 5) +
           FORMAT(BillHeader."No.", 20) +
           PadStr('', 6, ' ') +
           CONVERTSTR(FORMAT(ModuleNo, 7), ' ', '0') +
           CONVERTSTR(FORMAT(ABS(BillAmount), 15, 1), ' ', '0') +
           CONVERTSTR(FORMAT(0, 15, 1), ' ', '0') +
           CONVERTSTR(FORMAT((ModuleNo * 7 + 2), 7), ' ', '0');

        if PaymMethod."Direct Debit" then
            Line += PadStr('', 23, ' ') + 'V' + CurrCode
        else
            Line += PadStr('', 24, ' ') + CurrCode;

        StringBuilder.Append(PADSTR(Line, 120, ' '));
        StringBuilder.AppendLine();

        GlobalTransport.Send(BillHeader."No." + '.TXT', 'text/plain', StringBuilder.ToString());
    end;

    local procedure WriteCBI10(var BillLine: Record "Issued Customer Bill Line"; LineAmount: Decimal)
    var
        Line: Text;
        Sign: Text;
    begin
        Sign := '-';
        LineAmount := Round(LineAmount * 100, 1);

        if PaymMethod."Direct Debit" then
            Line := ' 10' +
                CONVERTSTR(FORMAT(ModuleNo, 7), ' ', '0') +
                PadStr('', 12, ' ') +
                FORMAT(BillLine."Due Date", 6, 5) +
                '50000' +
                CONVERTSTR(FORMAT(ABS(LineAmount), 13, 1), ' ', '0') +
                Sign +
                CONVERTSTR(FORMAT(BankAcc.ABI, 5), ' ', '0') +
                CONVERTSTR(FORMAT(BankAcc.CAB, 5), ' ', '0') +
                FORMAT(BankAcc."Bank Account No.", 12)
        else
            Line := ' 14' +
               CONVERTSTR(FORMAT(ModuleNo, 7), ' ', '0') +
               PadStr('', 12, ' ') +
               FORMAT(BillLine."Due Date", 6, 5) +
               '30000' +
               CONVERTSTR(FORMAT(ABS(LineAmount), 13, 1), ' ', '0') +
               Sign +
               CONVERTSTR(FORMAT(BankAcc.ABI, 5), ' ', '0') +
               CONVERTSTR(FORMAT(BankAcc.CAB, 5), ' ', '0') +
               FORMAT(BankAcc."Bank Account No.", 12);

        Line +=
                CONVERTSTR(FORMAT(CustBank.ABI, 5), ' ', '0') +
                CONVERTSTR(FORMAT(CustBank.CAB, 5), ' ', '0') +
                PadStr('', 12, ' ') +
                FORMAT(CompanyInfo."SIA Code", 5) +
                '4';

        if PaymMethod."Direct Debit" then
            Line +=
                PadStr(BillLine."Direct Debit Mandate ID", 16, ' ') +
                PadStr('', 5, ' ') +
                'V' +
                CurrCode
        else
            Line +=
                PadStr(BillLine."Customer No.", 16, ' ') +
                PadStr('', 6, ' ') +
                CurrCode;

        StringBuilder.Append(PADSTR(Line, 120, ' '));
        StringBuilder.AppendLine();
    end;

    local procedure WriteCBI16()
    var
        Line: Text;
    begin
        BankAcc.TestField(IBAN);
        BankAcc.TestField("Creditor No.");

        Line := ' 16' +
            CONVERTSTR(FORMAT(ModuleNo, 7), ' ', '0') +
            FORMAT(BankAcc.IBAN, 34);

        if PaymMethod."Direct Debit" then
            Line +=
                PadStr('', 7, ' ') +
                PadStr(BankAcc."Creditor No.", 35, ' ');

        StringBuilder.Append(PADSTR(Line, 120, ' '));
        StringBuilder.AppendLine();
    end;

    local procedure WriteCBI17(var BillLine: Record "Issued Customer Bill Line")
    var
        DirectDebit: Record "SEPA Direct Debit Mandate";
        Line: Text;
    begin
        BillLine.TestField("Direct Debit Mandate ID");
        DirectDebit.Get(BillLine."Direct Debit Mandate ID");
        DirectDebit.TestField("Date of Signature");

        Line := ' 17' +
            CONVERTSTR(FORMAT(ModuleNo, 7), ' ', '0') +
            FORMAT(CustBank.IBAN, 27);

        case DirectDebit."Type of Payment" of
            DirectDebit."Type of Payment"::OneOff:
                Line += 'OOFF'
            else
                Line += 'RCUR';
        end;

        Line += FORMAT(DirectDebit."Date of Signature", 0, '<day,2><month,2><year>');

        StringBuilder.Append(PADSTR(Line, 120, ' '));
        StringBuilder.AppendLine();
    end;

    local procedure WriteCBI20()
    var
        Line: Text;
    begin
        CompanyInfo.TestField(Name);
        CompanyInfo.TestField(Address);
        CompanyInfo.TestField("Post Code");
        CompanyInfo.TestField(City);

        Line := ' 20' +
            CONVERTSTR(FORMAT(ModuleNo, 7), ' ', '0') +
            FORMAT(CompanyInfo.Name, 24) +
            FORMAT(CompanyInfo.Address, 24) +
            FORMAT(FORMAT(CompanyInfo."Post Code"), 24) +
            FORMAT(CompanyInfo.City, 24);

        StringBuilder.Append(PADSTR(Line, 120, ' '));
        StringBuilder.AppendLine();
    end;

    local procedure WriteCBI30()
    var
        Line: Text;
        NoVatFiscalCodeErr: label 'Customer %1 no VAT or Fiscal Code specified';
    begin
        if (Customer."VAT Registration No." = '') and (Customer."Fiscal Code" = '') then
            Error(NoVatFiscalCodeErr, Customer."No.");

        Line := ' 30' + CONVERTSTR(FORMAT(ModuleNo, 7), ' ', '0') +
            FORMAT(Customer.Name, 30) + FORMAT(Customer."Name 2", 30);

        if Customer."VAT Registration No." > '' then
            Line += FORMAT(StripCountryVatNo(Customer."VAT Registration No."), 30)
        else
            Line += FORMAT(Customer."Fiscal Code", 30);

        StringBuilder.Append(PADSTR(Line, 120, ' '));
        StringBuilder.AppendLine();
    end;

    local procedure WriteCBI40()
    var
        Line: Text;
    begin
        Customer.TestField(Address);
        Customer.TestField("Post Code");
        Customer.TestField(City);
        Customer.TestField(County);

        CustBank.TestField(ABI);
        CustBank.TestField(CAB);

        Line := ' 40' +
            CONVERTSTR(FORMAT(ModuleNo, 7), ' ', '0') +
            FORMAT(Customer.Address, 30) +
            FORMAT(Customer."Post Code", 5) +
            FORMAT(Customer.City, 23) +
            FORMAT(Customer.County, 2) +
            CONVERTSTR(FORMAT(CustBank.ABI, 5), ' ', '0') +
            ' ' +
            CONVERTSTR(FORMAT(CustBank.CAB, 5), ' ', '0');

        StringBuilder.Append(PADSTR(Line, 120, ' '));
        StringBuilder.AppendLine();
    end;

    local procedure WriteCBI50(Description: Text)
    var
        Line: Text;
    begin
        CompanyInfo.TestField("VAT Registration No.");

        Line := ' 50' +
            CONVERTSTR(FORMAT(ModuleNo, 7), ' ', '0');

        if PaymMethod."Direct Debit" then
            Line += Format(Description, 90)
        else
            Line += Format(Description, 80) +
                PadStr('', 10, ' ') +
                Format(StripCountryVatNo(CompanyInfo."VAT Registration No."), 16);

        StringBuilder.Append(PADSTR(Line, 120, ' '));
        StringBuilder.AppendLine();
    end;

    local procedure WriteCBI51(var BillLine: Record "Issued Customer Bill Line")
    var
        Line: Text;
    begin
        CompanyInfo.TestField("Signature on Bill");

        Line := ' 51' +
            CONVERTSTR(FORMAT(ModuleNo, 7), ' ', '0') +
            CONVERTSTR(FORMAT(BillLine."Final Cust. Bill No.", 10), ' ', '0') +
            FORMAT(CompanyInfo."Signature on Bill", 20);

        if CompanyInfo."Authority County" > '' then
            Line += FORMAT(CompanyInfo."Authority County", 15)
        else
            Line += PadStr('', 15, ' ');

        if CompanyInfo."Autoriz. No." > '' then
            Line += FORMAT(FORMAT(CompanyInfo."Autoriz. No."), 10)
        else
            Line += PadStr('', 10, ' ');

        if CompanyInfo."Autoriz. Date" > 0D then
            Line += FORMAT(CompanyInfo."Autoriz. Date", 6, 5);

        StringBuilder.Append(PADSTR(Line, 120, ' '));
        StringBuilder.AppendLine();
    end;

    local procedure WriteCBI70(var BillLine: Record "Issued Customer Bill Line")
    var
        Line: Text;
    begin
        Line := ' 70' +
            CONVERTSTR(FORMAT(ModuleNo, 7), ' ', '0') +
            CONVERTSTR(FORMAT(BillLine."Final Cust. Bill No.", 10), ' ', '0');

        if PaymMethod."Direct Debit" then begin
            Customer.TestField("Partner Type");

            Line += PadStr('', 95, ' ');
            case Customer."Partner Type" of
                Customer."Partner Type"::Person:
                    Line += '8';
                Customer."Partner Type"::Company:
                    Line += '3';
            end;
        end;

        StringBuilder.Append(PADSTR(Line, 120, ' '));
        StringBuilder.AppendLine();
    end;

    procedure StripCountryVatNo(VatNo: Text): Text
    var
        NotItalianVatErr: Label 'Invalid Italian VAT No. %1';
    begin
        if (not VatNo.StartsWith('IT')) or (StrLen(VatNo) <> 13) then
            Error(NotItalianVatErr, VatNo);

        exit(VatNo.Substring(3));
    end;

    procedure ExportCBILine(var BillLine: Record "Issued Customer Bill Line"; Description: Text; LineAmount: Decimal)
    begin
        ModuleNo += 1;
        WriteCBI10(BillLine, LineAmount);

        if PaymMethod."Direct Debit" then begin
            WriteCBI16();
            WriteCBI17(BillLine);
        end;

        WriteCBI20();
        WriteCBI30();
        WriteCBI40();
        WriteCBI50(Description);

        if not PaymMethod."Direct Debit" then
            WriteCBI51(BillLine);

        WriteCBI70(BillLine);

    end;
}
#endif