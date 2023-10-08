#if ITXX003A
report 60003 "YNS VAT Register - Print"
{
    DefaultRenderingLayout = RDLC;
    Caption = 'VAT Register - Print';

    dataset
    {
        dataitem(RegisterLoop; "VAT Register")
        {
            DataItemTableView = sorting(Code) order(ascending);

            column(ReportTitleTxt; ReportTitleTxt) { }
            column(ReportHeadTxt; ReportHeadTxt) { }
            column(EntriesTxt; EntriesTxt) { }
            column(PaymentsTxt; PaymentsTxt) { }
            column(SummaryTxt; SummaryTxt) { }
            column(LastPageNo; LastPageNo) { }

            dataitem(NoSeriesLoop; "No. Series")
            {
                DataItemLink = "VAT Register" = FIELD(Code);
                DataItemLinkReference = RegisterLoop;
                DataItemTableView = sorting("VAT Reg. Print Priority") order(ascending);
                PrintOnlyIfDetail = true;

                column(NoSeries_NoSeries_Description; NoSeriesLoop.Description) { }
                column(NoSeries_NoSeries__VAT_Reg__Print_Priority_; NoSeriesLoop."VAT Reg. Print Priority") { }
                column(NoSeries_Code; Code) { }
                column(TotalCodeTxt; TotalCodeTxt) { }
                column(UnrealizedTotalTxt; UnrealizedTotalTxt) { }

                dataitem(BookLoop; "VAT Book Entry")
                {
                    CalcFields = "Document Type", Base, Amount, "VAT Calculation Type", "Sell-to/Buy-from No.",
                        "External Document No.", "No. Series", "Nondeductible Amount", "Document Date",
                        "VAT Difference", "Nondeductible Base", "Unrealized Base", "Unrealized Amount";
                    DataItemTableView = sorting("Entry No.");

                    column(VAT_Book_Entry__VAT_Book_Entry___Document_No__; VATBookData."Document No.") { }
                    column(VAT_Book_Entry__VAT_Book_Entry___Posting_Date_; VATBookData."Posting Date") { }
                    column(VAT_Book_Entry__VAT_Book_Entry___OpOccurred_Date_; VATBookData."Operation Occurred Date") { }
                    column(VAT_Book_Entry__VAT_Book_Entry__Type; VATBookData.Type) { }
                    column(CVName; CustVendName) { }
                    column(VAT_Book_Entry__VAT_Book_Entry___VAT_Calculation_Type_; VATBookData."VAT Calculation Type") { }
                    column(VAT_Book_Entry__VAT_Book_Entry__Base; VATBookData.Base) { }
                    column(VAT_Book_Entry__VAT_Book_Entry__Amount; VATBookData.Amount) { }
                    column(VAT_Book_Entry__VAT_Book_Entry___Nondeductible_Base_; VATBookData."Nondeductible Base") { }
                    column(VAT_Book_Entry__VAT_Book_Entry___Nondeductible_Amount_; VATBookData."Nondeductible Amount") { }
                    column(VAT_Book_Entry__VAT_Book_Entry___Document_Date_; VATBookData."Document Date") { }
                    column(VATIdent_Description; VATIdent.Description) { }
                    column(VAT_Book_Entry__VAT_Book_Entry___VAT_Identifier_; VATBookData."VAT Identifier") { }
                    column(VAT_Book_Entry__ExternalDoc; VATBookData."External Document No.") { }
                    column(EntryTotal; EntryTotal) { }
                    column(EntryBase; EntryBase) { }
                    column(EntryAmount; EntryAmount) { }
                    column(UnrealizedFlag; UnrealizedFlag) { }
                    column(VAT_Book_Entry__VAT_Book_Entry___Unrealized_Amount_; VATBookData."Unrealized Amount") { }
                    column(VAT_Book_Entry__VAT_Book_Entry___Unrealized_Base_; VATBookData."Unrealized Base") { }
                    column(DocKey; DocKey) { }
                    column(VAT_Book_Entry_Entry_No_; "Entry No.") { }
                    column(VAT_Book_Entry_Document_No_; "Document No.") { }
                    column(OtherPeriodTxt; OtherPeriodTxt) { }

                    trigger OnAfterGetRecord()
                    begin
                        if (Base = 0) and (Amount = 0) and
                           ("Nondeductible Amount" = 0) and ("Nondeductible Base" = 0) and
                           ("Unrealized Base" = 0) and ("Unrealized Amount" = 0)
                        then begin
                            if (PrintingType = PrintingType::Final) and (not CurrReport.PREVIEW) then begin
                                VATBook.GET("Entry No.");
                                VATBook."Printing Date" := EndDate;
                                VATBook.MODIFY();
                            end;

                            CurrReport.SKIP();
                        end;

                        VATBookData := BookLoop;
                        DocKey := FORMAT("Posting Date") + FORMAT("Document Type") + FORMAT(Type) + "Document No.";

                        if VATBookData."Unrealized VAT" then begin
                            VATEntry.GET(VATBookData."Unrealized VAT Entry No.");
                            VATBookData."Document No." := VATEntry."Document No.";
                            VATBookData."Posting Date" := VATEntry."Posting Date";
                            VATBookData."Document Type" := VATEntry."Document Type";
                        end;

                        VATEntry.Get("Entry No.");

                        case Type of
                            Type::Purchase:
                                begin
                                    if Vendor."No." <> "Sell-to/Buy-from No." then
                                        Vendor.GET("Sell-to/Buy-from No.");
                                    CustVendName := Vendor.Name;
                                end;
                            type::Sale:
                                if VATEntry."Reverse Sales VAT" then begin
                                    if Vendor."No." <> "Sell-to/Buy-from No." then
                                        Vendor.GET("Sell-to/Buy-from No.");
                                    CustVendName := Vendor.Name;
                                end else begin
                                    if Customer."No." <> "Sell-to/Buy-from No." then
                                        Customer.GET("Sell-to/Buy-from No.");
                                    CustVendName := Customer.Name;
                                end;
                        end;

                        EntryTotal := 0;
                        VATEntry.RESET();
                        VATEntry.SETRANGE("Posting Date", "Posting Date");
                        VATEntry.SETRANGE("Document Type", "Document Type");
                        VATEntry.SETRANGE(Type, Type);
                        VATEntry.SETRANGE("Document No.", "Document No.");
                        VATEntry.CalcSums(Base, Amount, "Nondeductible Base", "Nondeductible Amount", "Unrealized Base", "Unrealized Amount");

                        EntryTotal := VATEntry.Base + VATEntry.Amount +
                                      VATEntry."Nondeductible Base" + VATEntry."Nondeductible Amount" +
                                      VATEntry."Unrealized Base" + VATEntry."Unrealized Amount";

                        if Type = Type::Sale then begin
                            EntryTotal := EntryTotal * -1;

                            VATBookData.Base := VATBookData.Base * -1;
                            VATBookData.Amount := VATBookData.Amount * -1;
                            VATBookData."Nondeductible Amount" := VATBookData."Nondeductible Amount" * -1;
                            VATBookData."Nondeductible Base" := VATBookData."Nondeductible Base" * -1;
                            VATBookData."Unrealized Base" := VATBookData."Unrealized Base" * -1;
                            VATBookData."Unrealized Amount" := VATBookData."Unrealized Amount" * -1;
                            VATBookData."External Document No." := VATBookData."Document No.";
                        end;

                        EntryAmount := VATBookData.Amount + VATBookData."Nondeductible Amount" + VATBookData."Unrealized Amount";
                        EntryBase := VATBookData.Base + VATBookData."Nondeductible Base" + VATBookData."Unrealized Base";

                        if VATBookData."Unrealized VAT" then
                            UnrealizedFlag := 2
                        else
                            if VATBookData."Unrealized Amount" <> 0 then
                                UnrealizedFlag := 1
                            else
                                UnrealizedFlag := 0;

                        VATIdent.GET("VAT Identifier");

                        OtherPeriodTxt := '';
                        if FORMAT(VATBookData."Operation Occurred Date", 0, '<Year4><Month,2>') <> FORMAT(VATBookData."Posting Date", 0, '<Year4><Month,2>') then
                            OtherPeriodTxt := StrSubstNo(OtherPeriodLbl, FORMAT(VATBookData."Operation Occurred Date", 0, '<Year4>-<Month,2>'));

                        if (PrintingType = PrintingType::Final) and (not CurrReport.PREVIEW) then begin
                            VATBook.GET("Entry No.");
                            VATBook."Printing Date" := EndDate;
                            VATBook.Modify();
                        end;
                    end;

                    trigger OnPreDataItem()
                    begin
                        BookLoop.RESET();
                        BookLoop.SETRANGE("No. Series", NoSeriesLoop.Code);
                        BookLoop.SETRANGE("Posting Date", StartDate, EndDate);
                        BookLoop.SETFILTER(Type, '<>%1', Type::Settlement);
                        if BookLoop.IsEmpty() then
                            CurrReport.SKIP();
                    end;
                }

                trigger OnAfterGetRecord()
                var
                    UnprintedEntriesErr: Label 'Previous not printed entries exists';
                begin
                    if PrintingType = PrintingType::Final then begin
                        VATBook.RESET();
                        VATBook.SETRANGE("No. Series", NoSeriesLoop.Code);
                        VATBook.SETFILTER("Posting Date", '<%1', StartDate);
                        VATBook.SETFILTER(Type, '<>%1', VATBook.Type::Settlement);
                        VATBook.SETRANGE("Unrealized VAT", false);
                        VATBook.SETRANGE("Printing Date", 0D);
                        if not VATBook.IsEmpty then
                            ERROR(UnprintedEntriesErr);
                    end;

                    TotalCodeTxt := StrSubstNo(TotalCodeLbl, NoSeriesLoop.Description);
                    UnrealizedTotalTxt := StrSubstNo(UnrealizedTotalLbl, NoSeriesLoop.Description);
                end;
            }

            trigger OnPostDataItem()
            begin
                if (PrintingType = PrintingType::Final) and (not CurrReport.PREVIEW) then begin
                    RegisterLoop."Last Printing Date" := EndDate;
                    MODIFY();

                    Reprint.INIT();
                    Reprint.Report := Reprint.Report::"VAT Register - Print";
                    Reprint."Start Date" := StartDate;
                    Reprint."End Date" := EndDate;
                    Reprint."Vat Register Code" := RegisterLoop.Code;
                    Reprint.INSERT();
                end;
            end;

            trigger OnPreDataItem()
            var
                AlreadyPrintedErr: Label 'Final registry already printed';
                NeverPrintedErr: Label 'Final registry never printed';
            begin
                RegisterLoop.SETRANGE(Code, VATRegisterCode);

                case PrintingType of
                    PrintingType::Final:
                        begin
                            Reprint.RESET();
                            Reprint.SETRANGE(Report, Reprint.Report::"VAT Register - Print");
                            Reprint.SETRANGE("Start Date", StartDate);
                            Reprint.SETRANGE("End Date", EndDate);
                            Reprint.SETRANGE("Vat Register Code", RegisterLoop.Code);
                            if not Reprint.ISEMPTY then
                                ERROR(AlreadyPrintedErr);
                        end;
                    PrintingType::Reprint:
                        begin
                            Reprint.RESET();
                            Reprint.SETRANGE(Report, Reprint.Report::"VAT Register - Print");
                            Reprint.SETRANGE("Start Date", StartDate);
                            Reprint.SETRANGE("End Date", EndDate);
                            Reprint.SETRANGE("Vat Register Code", RegisterLoop.Code);
                            if Reprint.ISEMPTY then
                                ERROR(NeverPrintedErr);
                        end;
                end;
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

                    field(VATRegisterCodeCtl; VATRegisterCode)
                    {
                        Caption = 'VAT Register';
                        TableRelation = "VAT Register" where(Type = filter(Sale | Purchase));
                        ApplicationArea = All;

                        trigger OnValidate()
                        begin
                            VATReg.GET(VATRegisterCode);
                            if VATReg."Last Printing Date" > 0D then
                                StartDate := CALCDATE('<1D>', VATReg."Last Printing Date")
                            else
                                StartDate := CALCDATE('<-CY>', WORKDATE());

                            EndDate := CALCDATE('<CM>', StartDate);
                        end;
                    }
                    field(StartDateCtl; StartDate)
                    {
                        Caption = 'Starting Date';
                        ApplicationArea = All;

                        trigger OnValidate()
                        begin
                            if EndDate > 0D then
                                EndDate := CALCDATE('<CM>', EndDate);
                        end;
                    }
                    field(EndDateCtl; EndDate)
                    {
                        Caption = 'Ending Date';
                        ApplicationArea = All;
                    }
                    field(PrintingTypeCtl; PrintingType)
                    {
                        Caption = 'Printing Type';
                        OptionCaption = 'Test,Final,Reprint';
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
            LayoutFile = 'Localization/Italy/VATRegisterPrint.Report.rdl';
        }
    }

    labels
    {
        OffNo = 'Off. no.';
        PostDate = 'Post. date';
        DocNo = 'Doc. no.';
        DocDate = 'Doc. date';
        Name = 'Name';
        VatIdent = 'VAT id.';
        VatDescr = 'VAT descr.';
        DocTotal = 'Doc. total';
        Base = 'Base';
        TaxAmount = 'Tax amt.';
        GeneralTotal = 'General totals';
        UnrealizedTotal = 'Unrealized totals';
        NonDeductAmount = 'Non ded. tax';
        UnrealizBase = 'Unreal. base';
        UnrealizAmount = 'Unreal. tax';
    }

    trigger OnPreReport()
    var
        FinalModeQst: Label 'Execute report in final mode?';
        AddressTxt: Text;
    begin
        if PrintingType = PrintingType::Final then
            if not CONFIRM(FinalModeQst) then
                Error('');

        CompanyInfo.GET();

        if PrintHeadings then begin
            VATReg.GET(VATRegisterCode);
            ReportTitleTxt := StrSubstNo(ReportTitleLbl, VATReg.Description, Format(StartDate, 0, '<Year4>'));

            AddressTxt := CompanyInfo.Name + ' - ' + CompanyInfo.Address + ' - ' + CompanyInfo.City;
            if CompanyInfo.County > '' then
                AddressTxt += ' ' + CompanyInfo.County;
            ReportHeadTxt := StrSubstNo(ReportHeadLbl, AddressTxt, CompanyInfo."Fiscal Code", CompanyInfo."VAT Registration No.");
        end;

        EntriesTxt := StrSubstNo(EntriesLbl, StartDate, EndDate);
        PaymentsTxt := StrSubstNo(PaymentsLbl, StartDate, EndDate);
        SummaryTxt := StrSubstNo(SummaryLbl, StartDate, EndDate);
    end;

    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        VATIdent: Record "VAT Identifier";
        VATBook: Record "VAT Book Entry";
        VATBookData: Record "VAT Book Entry";
        CompanyInfo: Record "Company Information";
        VATReg: Record "VAT Register";
        Reprint: Record "Reprint Info Fiscal Reports";
        VATEntry: Record "VAT Entry";
        StartDate: Date;
        EndDate: Date;
        VATRegisterCode: Code[20];
        PrintingType: Option Test,Final,Reprint;
        CustVendName: Text;
        PrintHeadings: Boolean;
        LastPageNo: Integer;
        EntryTotal: Decimal;
        EntryBase: Decimal;
        EntryAmount: Decimal;
        UnrealizedFlag: Integer;
        DocKey: Text;
        ReportTitleLbl: Label 'VAT Register %1 - Page %2 / {page}';
        ReportTitleTxt: Text;
        ReportHeadLbl: Label '%1 - Fiscal Code %2 - VAT Registration No. %3';
        ReportHeadTxt: Text;
        EntriesLbl: Label 'VAT Entries %1 - %2';
        EntriesTxt: Text;
        PaymentsLbl: Label 'Unrealized VAT payments %1 - %2';
        PaymentsTxt: Text;
        SummaryLbl: Label 'VAT summary by identifier %1 - %2';
        SummaryTxt: Text;
        OtherPeriodLbl: Label 'Entries of period %1';
        OtherPeriodTxt: Text;
        TotalCodeLbl: Label 'Totals %1';
        TotalCodeTxt: Text;
        UnrealizedTotalLbl: Label 'Unrealized totals %1';
        UnrealizedTotalTxt: Text;
}
#endif