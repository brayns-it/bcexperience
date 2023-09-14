#if W1FN002A
report 60001 "YNS Repayment Summary"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = RDLC;
    Caption = 'Repayment Summary';

    dataset
    {
        dataitem(RepaHead; "YNS Repayment Header")
        {
            MaxIteration = 1;

            dataitem(RepaCalc; "YNS Repayment Line")
            {
                DataItemTableView = sorting("Line No.") where("Line Type" = const(Calculation));
                DataItemLink = "Repayment No." = field("No.");
                DataItemLinkReference = RepaHead;

                column(Amount; Amount) { }
                column(Principal_Amount; "Principal Amount")
                {
                    IncludeCaption = true;
                }
                column(Interest_Amount; "Interest Amount")
                {
                    IncludeCaption = true;
                }
                column(Additional_Amount; "Additional Amount")
                {
                    IncludeCaption = true;
                }
                column(Interest_Overflow; "Interest Overflow") { }
                column(Inst_Due_Date; "Due Date") { }
                column(Description; Description) { }
                column(Payment_Method_Code; "Payment Method Code") { }
                column(Installment_Line_No_; "Installment Line No.") { }

                dataitem(RepaEntry; "YNS Repayment Line")
                {
                    DataItemTableView = sorting("Line No.") where("Line Type" = const(Entry));
                    DataItemLink = "Repayment No." = field("Repayment No."), "Entry No." = field("Entry No.");
                    DataItemLinkReference = RepaCalc;


                    column(Document_Type; "Document Type")
                    {
                        IncludeCaption = true;
                    }
                    column(Entry_Due_Date; "Due Date")
                    {
                        IncludeCaption = true;
                    }
                    column(Document_No_; "Document No.")
                    {
                        IncludeCaption = true;
                    }
                    column(Document_Date; "Document Date")
                    {
                        IncludeCaption = true;
                    }
                }
            }

            column(CompAddrArray1; CompAddrArray[1]) { }
            column(CompAddrArray2; CompAddrArray[2]) { }
            column(CompAddrArray3; CompAddrArray[3]) { }
            column(CompAddrArray4; CompAddrArray[4]) { }
            column(CompAddrArray5; CompAddrArray[5]) { }
            column(CompAddrArray6; CompAddrArray[6]) { }
            column(CompAddrArray7; CompAddrArray[7]) { }
            column(CompAddrArray8; CompAddrArray[8]) { }
            column(SourceAddrArray1; SourceAddrArray[1]) { }
            column(SourceAddrArray2; SourceAddrArray[2]) { }
            column(SourceAddrArray3; SourceAddrArray[3]) { }
            column(SourceAddrArray4; SourceAddrArray[4]) { }
            column(SourceAddrArray5; SourceAddrArray[5]) { }
            column(SourceAddrArray6; SourceAddrArray[6]) { }
            column(SourceAddrArray7; SourceAddrArray[7]) { }
            column(SourceAddrArray8; SourceAddrArray[8]) { }
            column(TitleLbl; TitleLbl) { }
            column(No_; "No.") { }
            column(Posting_Date; "Posting Date") { }
            column(InterestTxt; InterestTxt) { }

            trigger OnAfterGetRecord()
            var
                FinTerms: Record "Finance Charge Terms";
            begin
                RepaMgmt.Calculate(RepaHead);

                FormatAddr.FormatAddr(SourceAddrArray, RepaHead."Source Name", '', '', RepaHead."Source Address",
                    '', RepaHead."Source City", RepaHead."Source Post Code", RepaHead."Source County",
                    RepaHead."Source Country/Region Code");

                InterestTxt := '';
                if RepaHead."Finance Charge Terms" > '' then begin
                    FinTerms.Get(RepaHead."Finance Charge Terms");
                    InterestTxt := StrSubstNo(InterestLbl, Format(FinTerms."Interest Rate") + '%', FinTerms."Interest Period (Days)");
                end;
            end;
        }
    }

    rendering
    {
        layout(RDLC)
        {
            Type = RDLC;
            LayoutFile = 'Finance/Repayment/RepaymentSummary.Report.rdl';
        }
    }

    trigger OnPreReport()
    begin
        CompInfo.Get();
        FormatAddr.Company(CompAddrArray, CompInfo);
    end;

    var
        CompInfo: Record "Company Information";
        RepaMgmt: Codeunit "YNS Repayment Management";
        FormatAddr: Codeunit "Format Address";
        CompAddrArray: array[8] of Text[100];
        SourceAddrArray: array[8] of Text[100];
        InterestTxt: Text;
        TitleLbl: Label 'Repayment Summary';
        InterestLbl: Label 'Interest rate of %1 every %2 days';

}
#endif