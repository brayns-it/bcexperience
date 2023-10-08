#if ITXX003A
report 60002 "YNS G/L Book - Print"
{
    DefaultRenderingLayout = RDLC;
    Caption = 'G/L Book - Print';

    dataset
    {
        dataitem(TempReport; "G/L Entry")
        {
            DataItemTableView = sorting("Entry No.") order(ascending);
            UseTemporary = true;

            column(ReportTitleTxt; ReportTitleTxt) { }
            column(ReportHeadTxt; ReportHeadTxt) { }
            column(TotalPrintTxt; TotalPrintTxt) { }
            column(StartingTotalTxt; StartingTotalTxt) { }
            column(EntriesTxt; EntriesTxt) { }
            column(StartDebit; StartDebit) { }
            column(StartCredit; StartCredit) { }
            column(LastPageNo; LastPageNo) { }
            column(GL_Book_Entry__Credit_Amount_; "Credit Amount") { }
            column(GL_Book_Entry__Debit_Amount_; "Debit Amount") { }
            column(Descr1; Description1) { }
            column(Descr2; Description2) { }
            column(Descr3; Description3) { }
            column(GL_Book_Entry__G_L_Account_No__; "G/L Account No.") { }
            column(GL_Book_Entry__External_Document_No__; "External Document No.") { }
            column(GL_Book_Entry__Document_Date_; "Document Date") { }
            column(GL_Book_Entry__Document_Type_; "Document Type") { }
            column(GL_Book_Entry__Document_No__; "Document No.") { }
            column(GL_Book_Entry__Official_Date_; "Posting Date") { }
            column(LastNo; "Transaction No.") { }
            column(GroupNo; "Close Income Statement Dim. ID") { }
            column(GL_Book_Entry_Entry_No_; "Entry No.") { }
            column(RegCounts; NoOfDocuments) { }
            column(RegKey; RegKey) { }
            column(RegSort; RegSort) { }

            trigger OnAfterGetRecord()
            begin
                RegKey := Format("Posting Date", 0, '<Year4><Month,2><Day,2>') + PadStr("Document No.", 20, ' ');
                RegSort := PadStr(Format("Source Type".AsInteger(), 0, 9), 5, ' ') + PadStr("Source No.", 20, ' ');

                // description
                if GLAcc."No." <> "G/L Account No." then
                    GLAcc.GET("G/L Account No.");
                Description1 := GLAcc.Name;

                case "Source Type" of
                    "Source Type"::Customer:
                        begin
                            if Cust."No." <> "Source No." then
                                Cust.GET("Source No.");
                            Description2 := Cust.Name;
                        end;
                    "Source Type"::Vendor:
                        begin
                            if Vend."No." <> "Source No." then
                                Vend.GET("Source No.");
                            Description2 := Vend.Name;
                        end;
                    "Source Type"::"Bank Account":
                        begin
                            if BankAccount."No." <> "Source No." then
                                BankAccount.GET("Source No.");
                            Description2 := BankAccount.Name;
                        end;
                    "Source Type"::"Fixed Asset":
                        begin
                            if FA."No." <> "Source No." then
                                FA.GET("Source No.");
                            Description2 := FA.Description;
                        end;
                    else
                        Description2 := "Source No.";
                end;

                Description3 := Description;
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';

                    field(ReportTypeCtl; ReportType)
                    {
                        Caption = 'Report Type';
                        OptionCaption = 'Test Print,Final Print,Reprint';
                        ApplicationArea = All;
                    }
                    field(StartDateCtl; StartDate)
                    {
                        Caption = 'Starting Date';
                        ApplicationArea = All;

                        trigger OnValidate()
                        begin
                            AccPeriod.RESET();
                            AccPeriod.SETFILTER("Starting Date", '>%1', StartDate);
                            AccPeriod.FINDFIRST();
                            EndDate := CALCDATE('<-1D>', AccPeriod."Starting Date");
                        end;
                    }
                    field(EndDateCtl; EndDate)
                    {
                        Caption = 'Ending Date';
                        ApplicationArea = All;
                    }
                    field(PrintHeadingsCtl; PrintHeadings)
                    {
                        Caption = 'Print Headings';
                        ApplicationArea = All;
                    }
                    field(LastPageNoCtl; LastPageNo)
                    {
                        Caption = 'Last Page No.';
                        ApplicationArea = All;
                    }
                }
            }
        }
    }

    rendering
    {
        layout(RDLC)
        {
            Type = RDLC;
            LayoutFile = 'Localization/Italy/GLBookPrint.Report.rdl';
        }
    }

    labels
    {
        RegNo = 'Reg. No.';
        PostDate = 'Post. Date';
        GLAcc = 'Acc. No.';
        DocNo = 'Document No.';
        DocDate = 'Doc. Date';
        ExtDoc = 'Ext. Document';
        Descr = 'Description';
        Debit = 'Debit';
        Credit = 'Credit';
        GeneralTotals = 'General Totals';
        NumberOfRegs = 'Number of Entries';
    }

    trigger OnInitReport()
    begin
        GLSetup.GET();
        if GLSetup."Last Gen. Jour. Printing Date" = 0D then begin
            AccPeriod.RESET();
            AccPeriod.SETFILTER("Starting Date", '<=%1', WORKDATE());
            AccPeriod.SETRANGE("New Fiscal Year", TRUE);
            AccPeriod.FINDFIRST();
            StartDate := AccPeriod."Starting Date";
        end else
            StartDate := CALCDATE('<1D>', GLSetup."Last Gen. Jour. Printing Date");

        AccPeriod.RESET();
        AccPeriod.SETFILTER("Starting Date", '>%1', StartDate);
        AccPeriod.FINDFIRST();
        EndDate := CALCDATE('<-1D>', AccPeriod."Starting Date");
    end;

    trigger OnPostReport()
    var
        GLBookEntry: Record "GL Book Entry";
        GLMarkingLbl: Label 'Marking GL entries...';
        GLMarkedLbl: Label 'The G/L entries printed have been marked.';
        Progress: Dialog;
        N: Integer;
        C: Integer;
    begin
        if (not CurrReport.PREVIEW) and (ReportType = ReportType::"Final Print") then begin
            if GuiAllowed then begin
                Progress.Open('#1####\#2####');
                Progress.Update(1, GLMarkingLbl);
            end;

            TempSkipped.Reset();
            if TempSkipped.FindSet() then
                repeat
                    GLBookEntry.Get(TempSkipped."Entry No.");
                    GLBookEntry."Progressive No." := -1;
                    GLBookEntry.Modify();
                until TempSkipped.Next() = 0;

            TempReport.Reset();
            TempReport.SetFilter("Entry No.", '>0');
            N := 0;
            C := TempReport.Count();
            if TempReport.FindSet() then
                repeat
                    if GuiAllowed then
                        Progress.Update(2, Format(Round((N * 100) / C, 1) + '%'));
                    GLBookEntry.Get(TempReport."Entry No.");
                    GLBookEntry."Progressive No." := TempReport."Transaction No.";
                    GLBookEntry."YNS Registration No." := TempReport."Close Income Statement Dim. ID";
                    GLBookEntry.Modify();
                until TempReport.Next() = 0;

            ReprintInfo.INIT();
            ReprintInfo.Report := ReprintInfo.Report::"G/L Book - Print";
            ReprintInfo."Start Date" := StartDate;
            ReprintInfo."End Date" := EndDate;
            ReprintInfo."Vat Register Code" := '';
            ReprintInfo."YNS Ending Debit Amount" := EndDebit;
            ReprintInfo."YNS Ending Credit Amount" := EndCredit;
            ReprintInfo.INSERT();

            GLSetup."Last Gen. Jour. Printing Date" := EndDate;
            GLSetup."Last General Journal No." := ProgressiveNo;
            GLSetup."YNS Last Gen. Jnl. Reg. No." := RegistrationNo;
            GLSetup.MODIFY();

            MESSAGE(GLMarkedLbl);
        end;
    end;

    trigger OnPreReport()
    var
        GLBookEntry: Record "GL Book Entry";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        AddressTxt: Text;
        PrevEntryNotPrintedErr: Label 'Not printed entries before %1 exists';
        EntriesNotPrintedErr: Label 'Not printed entries between %1 and %2 exists';
        AlreadyPrintedErr: Label 'G/L Book already printed (%1)';
    begin
        NoSeriesMgt.CheckSalesDocNoGaps(EndDate);
        NoSeriesMgt.CheckPurchDocNoGaps(EndDate);

        AccPeriod.RESET();
        AccPeriod.SETRANGE("New Fiscal Year", true);
        AccPeriod.SETFILTER("Starting Date", '<=%1', StartDate);
        if AccPeriod.FIND('+') then
            FiscalYearStartDate := AccPeriod."Starting Date"
        else
            FiscalYearStartDate := CALCDATE('<-CY>', StartDate);

        CompanyInfo.GET();

        if ReportType <> ReportType::"Test Print" then begin
            GLBookEntry.RESET();
            GLBookEntry.SETFILTER("Posting Date", '<%1', StartDate);
            GLBookEntry.SETRANGE("Progressive No.", 0);
            if not GLBookEntry.IsEmpty() then
                ERROR(PrevEntryNotPrintedErr, StartDate);
        end;

        if ReportType = ReportType::Reprint then begin
            GLBookEntry.RESET();
            GLBookEntry.SETFILTER("Posting Date", '%1..%2', StartDate, ClosingDate(EndDate));
            GLBookEntry.SETRANGE("Progressive No.", 0);
            if not GLBookEntry.IsEmpty() then
                ERROR(EntriesNotPrintedErr, StartDate, EndDate);
        end;

        if ReportType = ReportType::"Final Print" then
            if StartDate <= GLSetup."Last Gen. Jour. Printing Date" then
                error(AlreadyPrintedErr, GLSetup."Last Gen. Jour. Printing Date");

        RegistrationNo := 0;
        ProgressiveNo := 0;
        StartDebit := 0;
        StartCredit := 0;
        if FiscalYearStartDate <> StartDate then begin
            ProgressiveNo := GLSetup."Last General Journal No.";
            RegistrationNo := GLSetup."YNS Last Gen. Jnl. Reg. No.";

            ReprintInfo.Reset();
            ReprintInfo.SETRANGE(Report, ReprintInfo.Report::"G/L Book - Print");
            ReprintInfo.SETRANGE("End Date", CALCDATE('<-1D>', StartDate));
            if ReprintInfo.FINDLAST() then begin
                StartDebit := ReprintInfo."YNS Ending Debit Amount";
                StartCredit := ReprintInfo."YNS Ending Credit Amount";
            end;
        end;

        EndDebit := StartDebit;
        EndCredit := StartCredit;

        PrepareBuffer();

        if PrintHeadings then begin
            ReportTitleTxt := StrSubstNo(ReportTitleLbl, Format(StartDate, 0, '<Year4>'));

            AddressTxt := CompanyInfo.Name + ' - ' + CompanyInfo.Address + ' - ' + CompanyInfo.City;
            if CompanyInfo.County > '' then
                AddressTxt += ' ' + CompanyInfo.County;
            ReportHeadTxt := StrSubstNo(ReportHeadLbl, AddressTxt, CompanyInfo."Fiscal Code", CompanyInfo."VAT Registration No.");
        end;

        EntriesTxt := StrSubstNo(EntriesLbl, StartDate, EndDate);
        TotalPrintTxt := StrSubstNo(TotalPrintLbl, StartDate, EndDate);
        StartingTotalTxt := StrSubstNo(StartingTotalLbl, StartDate);
    end;

    local procedure PrepareBuffer()
    var
        GLBookEntry: Record "GL Book Entry";
        TempAccs: Record "G/L Entry" temporary;
        Progress: Dialog;
        N: Integer;
        C: Integer;
        Skip: Boolean;
        BufferingLbl: Label 'Buffering...';
        DocNumberingLbl: Label 'Document numbering...';
        InconsistendDocErr: Label 'Document no. %1 of %2 is inconsistent %3';
        xProgressiveNo: Integer;
        xRegistrationNo: Integer;
        RegAmt: Decimal;
    begin
        if GuiAllowed then
            Progress.Open('#1####\#2####');

        TempReport.Reset();
        TempReport.DeleteAll();

        TempSkipped.Reset();
        TempSkipped.DeleteAll();

        TempDocuments.Reset();
        TempDocuments.DeleteAll();

        GLBookEntry.Reset();
        GLBookEntry.SetAutoCalcFields("Debit Amount", "Credit Amount", Description);
        GLBookEntry.SetRange("Posting Date", StartDate, ClosingDate(EndDate));
        if ReportType = ReportType::Reprint then
            GLBookEntry.SetFilter("Progressive No.", '>0');

        if GuiAllowed then
            Progress.Update(1, BufferingLbl);

        N := 0;
        C := GLBookEntry.Count();
        if GLBookEntry.FindSet() then
            repeat
                N += 1;
                if GuiAllowed then
                    Progress.Update(2, Format(Round((N * 100) / C, 1) + '%'));

                Skip := false;
                if ReportType <> ReportType::Reprint then
                    if (GLBookEntry."Debit Amount" = 0) and (GLBookEntry."Credit Amount" = 0) then
                        Skip := true;

                if Skip then begin
                    TempSkipped.Init();
                    TempSkipped."Entry No." := GLBookEntry."Entry No.";
                    TempSkipped."Progressive No." := -1;
                    TempSkipped.Insert();
                end else begin
                    TempReport.Init();
                    TempReport."Entry No." := GLBookEntry."Entry No.";
                    TempReport."G/L Account No." := GLBookEntry."G/L Account No.";
                    TempReport."Debit Amount" := GLBookEntry."Debit Amount";
                    TempReport."Credit Amount" := GLBookEntry."Credit Amount";
                    TempReport."Document No." := GLBookEntry."Document No.";
                    TempReport."Posting Date" := GLBookEntry."Posting Date";
                    TempReport."Document Date" := GLBookEntry."Document Date";
                    TempReport."Document Type" := GLBookEntry."Document Type";
                    TempReport."External Document No." := GLBookEntry."External Document No.";
                    TempReport."Source No." := GLBookEntry."Source No.";
                    TempReport."Source Type" := GLBookEntry."Source Type";
                    TempReport.Description := GLBookEntry.Description;
                    if ReportType = ReportType::Reprint then begin
                        TempReport."Transaction No." := GLBookEntry."Progressive No.";
                        TempReport."Close Income Statement Dim. ID" := GLBookEntry."YNS Registration No.";
                    end;
                    TempReport.Insert();

                    TempDocuments.Reset();
                    TempDocuments.SetRange("Document No.", GLBookEntry."Document No.");
                    TempDocuments.SetRange("Posting Date", GLBookEntry."Posting Date");
                    if TempDocuments.IsEmpty() then begin
                        TempDocuments.Init();
                        TempDocuments."Entry No." := GLBookEntry."Entry No.";
                        TempDocuments."Document No." := GLBookEntry."Document No.";
                        TempDocuments."Posting Date" := GLBookEntry."Posting Date";
                        TempDocuments.Insert();
                    end;

                    EndDebit += GLBookEntry."Debit Amount";
                    EndCredit += GLBookEntry."Credit Amount";
                end;
            until GLBookEntry.Next() = 0;

        if ReportType <> ReportType::Reprint then begin
            if GuiAllowed then
                Progress.Update(1, DocNumberingLbl);

            TempDocuments.Reset();
            C := TempDocuments.Count();
            N := 0;

            TempDocuments.SetCurrentKey("Posting Date", "Document No.");
            if TempDocuments.FindSet() then
                repeat
                    N += 1;
                    if GuiAllowed then
                        Progress.Update(2, Format(Round((N * 100) / C, 1) + '%'));

                    xRegistrationNo := RegistrationNo;
                    xProgressiveNo := ProgressiveNo;
                    RegistrationNo += 1;
                    RegAmt := 0;

                    TempAccs.Reset();
                    TempAccs.DeleteAll();

                    TempReport.Reset();
                    TempReport.SetRange("Document No.", TempDocuments."Document No.");
                    TempReport.SetRange("Posting Date", TempDocuments."Posting Date");
                    if TempReport.FindSet() then
                        repeat
                            ProgressiveNo += 1;
                            TempReport."Transaction No." := ProgressiveNo;
                            TempReport."Close Income Statement Dim. ID" := RegistrationNo;
                            TempReport.Modify();

                            RegAmt += TempReport."Debit Amount" - TempReport."Credit Amount";

                            TempAccs.Reset();
                            TempAccs.SetRange("G/L Account No.", TempReport."G/L Account No.");
                            if not TempAccs.FindFirst() then begin
                                TempAccs.Init();
                                TempAccs."Entry No." := TempReport."Entry No.";
                                TempAccs."G/L Account No." := TempReport."G/L Account No.";
                                TempAccs.Insert();
                            end;
                            TempAccs.Amount += TempReport."Debit Amount" - TempReport."Credit Amount";
                            TempAccs.Modify();
                        until TempReport.Next() = 0;

                    if RegAmt <> 0 then
                        Error(InconsistendDocErr, TempDocuments."Document No.", TempDocuments."Posting Date", RegAmt);

                    TempAccs.Reset();
                    TempAccs.SetFilter(Amount, '<>0');
                    if TempAccs.IsEmpty() then begin
                        if TempReport.FindSet() then
                            repeat
                                TempSkipped.Init();
                                TempSkipped."Entry No." := TempReport."Entry No.";
                                TempSkipped."Progressive No." := -1;
                                TempSkipped.Insert();

                                TempReport.Delete();
                            until TempReport.Next() = 0;

                        RegistrationNo := xRegistrationNo;
                        ProgressiveNo := xProgressiveNo;
                        TempDocuments.Delete();
                    end;

                until TempDocuments.Next() = 0;
        end;

        TempDocuments.Reset();
        NoOfDocuments := TempDocuments.Count();

        if GuiAllowed then
            Progress.Close();

        TempReport.Reset();
        if TempReport.IsEmpty then begin
            Clear(TempReport);
            TempReport.Insert();
        end;
    end;

    var
        GLSetup: Record "General Ledger Setup";
        GLAcc: Record "G/L Account";
        TempSkipped: Record "GL Book Entry" temporary;
        TempDocuments: Record "GL Book Entry" temporary;
        Cust: Record Customer;
        Vend: Record Vendor;
        BankAccount: Record "Bank Account";
        FA: Record "Fixed Asset";
        CompanyInfo: Record "Company Information";
        AccPeriod: Record "Accounting Period";
        ReprintInfo: Record "Reprint Info Fiscal Reports";
        ReportType: Option "Test Print","Final Print",Reprint;
        StartDate: Date;
        EndDate: Date;
        FiscalYearStartDate: Date;
        ProgressiveNo: Integer;
        RegistrationNo: Integer;
        Description1: Text;
        Description2: Text;
        Description3: Text;
        StartDebit: Decimal;
        StartCredit: Decimal;
        EndDebit: Decimal;
        EndCredit: Decimal;
        PrintHeadings: Boolean;
        LastPageNo: Integer;
        RegKey: Text;
        RegSort: Text;
        NoOfDocuments: Integer;
        ReportTitleLbl: Label 'G/L Book - Page %1 / {page}';
        ReportTitleTxt: Text;
        ReportHeadLbl: Label '%1 - Fiscal Code %2 - VAT Registration No. %3';
        ReportHeadTxt: Text;
        EntriesLbl: Label 'G/L Entries %1 - %2';
        EntriesTxt: Text;
        TotalPrintLbl: Label 'Print Totals %1 - %2';
        TotalPrintTxt: Text;
        StartingTotalLbl: Label 'Starting Totals at %1';
        StartingTotalTxt: Text;
}
#endif