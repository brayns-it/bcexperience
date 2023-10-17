#if W1FN008A
report 60004 "YNS Customer Detailed Aging 2"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    Caption = 'Customer Detailed Aging 2';
    DefaultRenderingLayout = RDLC;

    dataset
    {
        dataitem(Customer; Customer)
        {
            RequestFilterFields = "No.", "Customer Posting Group", "Date Filter";
            MaxIteration = 1;

            column(CompAddr1; CompAddr[1]) { }
            column(CompAddr2; CompAddr[2]) { }
            column(CompAddr3; CompAddr[3]) { }
            column(CompAddr4; CompAddr[4]) { }
            column(CompAddr5; CompAddr[5]) { }
            column(CompAddr6; CompAddr[6]) { }
            column(CompAddr7; CompAddr[7]) { }
            column(CompAddr8; CompAddr[8]) { }
            column(CustAddr1; CustAddr[1]) { }
            column(CustAddr2; CustAddr[2]) { }
            column(CustAddr3; CustAddr[3]) { }
            column(CustAddr4; CustAddr[4]) { }
            column(CustAddr5; CustAddr[5]) { }
            column(CustAddr6; CustAddr[6]) { }
            column(CustAddr7; CustAddr[7]) { }
            column(CustAddr8; CustAddr[8]) { }
            column(EndingDateTxt; EndingDateTxt) { }
            column(ReportFilters; ReportFilters) { }

            dataitem(CustLedgerEntry; "Cust. Ledger Entry")
            {
                DataItemLinkReference = Customer;
                DataItemLink = "Customer No." = field("No.");
                RequestFilterFields = Open, "Due Date", "Payment Method Code";
                CalcFields = Amount, "Remaining Amount";

                column(Currency_Code; "Currency Code")
                {
                    IncludeCaption = true;
                }
                column(Document_Date; "Document Date")
                {
                    IncludeCaption = true;
                }
                column(Due_Date; "Due Date")
                {
                    IncludeCaption = true;
                }
                column(Payment_Method_Code; "Payment Method Code")
                {
                    IncludeCaption = true;
                }
                column(Description; Description)
                {
                    IncludeCaption = true;
                }
                column(Document_Type; "Document Type")
                {
                    IncludeCaption = true;
                }
                column(Document_No_; "Document No.")
                {
                    IncludeCaption = true;
                }
                column(Amount; Amount)
                {
                    IncludeCaption = true;
                }
                column(Remaining_Amount; "Remaining Amount")
                {
                    IncludeCaption = true;
                }
                column(PastDue; PastDue) { }
                column(FutureDue; FutureDue) { }
                column(Entry_No_; "Entry No.") { }
                column(Sequence; Sequence) { }

                dataitem(TempAppliedEntries; "Gen. Journal Line")
                {
                    DataItemTableView = sorting("Journal Template Name", "Journal Batch Name", "Line No.");

                    column(AppliedDocType; "Document Type") { }
                    column(AppliedDocNo; "Document No.") { }
                    column(AppliedDescription; Description) { }
                    column(AppliedDate; "Posting Date") { }
                    column(AppliedAmount; Amount) { }

                    trigger OnAfterGetRecord()
                    begin
                        Sequence += 1;

                        if Sequence > 1 then begin
                            CustLedgerEntry.Amount := 0;
                            CustLedgerEntry."Remaining Amount" := 0;
                        end;
                    end;
                }

                trigger OnPreDataItem()
                begin
                    SetFilter("Remaining Amount", '<>0');
                end;

                trigger OnAfterGetRecord()
                begin
                    if "Currency Code" = '' then
                        "Currency Code" := GLSetup."LCY Code";

                    PastDue := 0;
                    FutureDue := 0;
                    if "Due Date" > EndingDate then
                        FutureDue := "Remaining Amount"
                    else
                        PastDue := "Remaining Amount";

                    if ShowApplied then
                        FinMgmt.GetCustomerAppliedEntries(CustLedgerEntry, TempAppliedEntries);

                    Sequence := 0;
                end;
            }

            trigger OnPreDataItem()
            begin
                SetRange("Date Filter", 0D, EndingDate);
                ReportFilters := CustLedgerEntry.GetFilters();
            end;

            trigger OnAfterGetRecord()
            begin
                FormatAddr.Customer(CustAddr, Customer);
            end;
        }
    }

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

                    field(ShowAppliedCtl; ShowApplied)
                    {
                        Caption = 'Show applied entries';
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
            LayoutFile = 'Finance/CustomerDetailedAging2.Report.rdl';
        }
    }

    labels
    {
        ReportTitle = 'Customer Detailed Aging';
        CustNo = 'Customer No.';
        GeneralTotal = 'General Total';
        PastDueTotal = 'Past Due Total';
        DueTotal = 'Due Total';
    }

    trigger OnPreReport()
    begin
        CompInfo.Get();
        GLSetup.Get();
        FormatAddr.Company(CompAddr, CompInfo);

        if Customer.GetFilter("Date Filter") > '' then
            EndingDate := Customer.GetRangeMax("Date Filter")
        else
            EndingDate := WorkDate();

        EndingDateTxt := StrSubstNo(EndingDateLbl, EndingDate);
    end;

    var
        CompInfo: Record "Company Information";
        GLSetup: Record "General Ledger Setup";
        FormatAddr: Codeunit "Format Address";
        FinMgmt: Codeunit "YNS Finance Management";
        CompAddr: array[8] of Text[100];
        CustAddr: array[8] of Text[100];
        EndingDate: Date;
        EndingDateTxt: Text;
        EndingDateLbl: Label 'Entries at %1';
        ReportFilters: Text;
        PastDue: Decimal;
        FutureDue: Decimal;
        ShowApplied: Boolean;
        Sequence: Integer;
}
#endif