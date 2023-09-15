#if W1FN002A
report 60001 "YNS Repayment Summary"
{
    DefaultRenderingLayout = RDLC;
    Caption = 'Repayment Summary';

    dataset
    {
        dataitem(TempRepaHead; "YNS Repayment Header")
        {
            DataItemTableView = sorting("No.");
            MaxIteration = 1;
            UseTemporary = true;

            dataitem(TempRepaCalc; "YNS Repayment Line")
            {
                DataItemTableView = sorting("Line No.") where("Line Type" = const(Calculation));
                DataItemLink = "Repayment No." = field("No.");
                DataItemLinkReference = TempRepaHead;
                UseTemporary = true;

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
                column(Delay_Days; "Delay Days")
                {
                    IncludeCaption = true;
                }
                column(Remaining_Principal_Amount; "Remaining Principal Amount")
                {
                    IncludeCaption = true;
                }
                column(Interest_Overflow; "Interest Overflow") { }
                column(Inst_Due_Date; "Due Date") { }
                column(Description; Description) { }
                column(Payment_Method_Code; "Payment Method Code") { }
                column(Installment_Line_No_; "Installment Line No.") { }
                column(Entry_No_; "Entry No.") { }
                column(Inst_Description; TempRepaInstallment.Description) { }

                dataitem(TempRepaEntry; "YNS Repayment Line")
                {
                    DataItemTableView = sorting("Line No.") where("Line Type" = const(Entry));
                    DataItemLink = "Repayment No." = field("Repayment No."), "Entry No." = field("Entry No.");
                    DataItemLinkReference = TempRepaCalc;
                    UseTemporary = true;

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

                trigger OnAfterGetRecord()
                begin
                    TempRepaInstallment.Get(TempRepaCalc."Repayment No.", TempRepaInstallment."Line Type"::Installment, TempRepaCalc."Installment Line No.");
                end;
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
                FormatAddr.FormatAddr(SourceAddrArray, TempRepaHead."Source Name", '', '', TempRepaHead."Source Address",
                    '', TempRepaHead."Source City", TempRepaHead."Source Post Code", TempRepaHead."Source County",
                    TempRepaHead."Source Country/Region Code");

                InterestTxt := '';
                if TempRepaHead."Finance Charge Terms" > '' then begin
                    FinTerms.Get(TempRepaHead."Finance Charge Terms");
                    InterestTxt := StrSubstNo(InterestLbl, Format(FinTerms."Interest Rate") + '%', FinTerms."Interest Period (Days)");
                end;
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(options)
                {
                    Caption = 'Options';

                    field(TableCaptCtl; TableCapt)
                    {
                        Caption = 'Type';
                        ApplicationArea = all;
                        Editable = false;
                    }
                    field(TableRecNoCtl; TableRecNo)
                    {
                        ApplicationArea = all;
                        Caption = 'No.';
                        Editable = false;
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
            LayoutFile = 'Finance/Repayment/RepaymentSummary.Report.rdl';
        }
    }

    trigger OnPreReport()
    begin
        CompInfo.Get();
        FormatAddr.Company(CompAddrArray, CompInfo);
    end;

    procedure LoadRepayment(var RepaHead2: Record "YNS Repayment Header")
    var
        RepaLine2: Record "YNS Repayment Line";
    begin
        RepaMgmt.Calculate(RepaHead2);
        Commit();

        TempRepaHead := RepaHead2;
        TempRepaHead.Insert();

        RepaLine2.Reset();
        RepaLine2.SetRange("Repayment No.", RepaHead2."No.");
        if RepaLine2.FindSet() then
            repeat
                case RepaLine2."Line Type" of
                    RepaLine2."Line Type"::Calculation:
                        begin
                            TempRepaCalc := RepaLine2;
                            TempRepaCalc.Insert();
                        end;
                    RepaLine2."Line Type"::Installment:
                        begin
                            TempRepaInstallment := RepaLine2;
                            TempRepaInstallment.Insert();
                        end;
                    RepaLine2."Line Type"::Entry:
                        begin
                            TempRepaEntry := RepaLine2;
                            TempRepaEntry.Insert();
                        end;
                end;
            until RepaLine2.Next() = 0;

        TableCapt := RepaHead2.TableCaption;
        TableRecNo := RepaHead2."No.";
    end;

    procedure LoadRepayment(var RepaHead2: Record "YNS Issued Repayment Header")
    var
        RepaLine2: Record "YNS Issued Repayment Line";
    begin
        TempRepaHead.TransferFields(RepaHead2);
        TempRepaHead.Insert();

        RepaLine2.Reset();
        RepaLine2.SetRange("Issued Repayment No.", RepaHead2."No.");
        if RepaLine2.FindSet() then
            repeat
                case RepaLine2."Line Type" of
                    RepaLine2."Line Type"::Calculation:
                        begin
                            TempRepaCalc.TransferFields(RepaLine2);
                            TempRepaCalc.Insert();
                        end;
                    RepaLine2."Line Type"::Installment:
                        begin
                            TempRepaInstallment.TransferFields(RepaLine2);
                            TempRepaInstallment.Insert();
                        end;
                    RepaLine2."Line Type"::Entry:
                        begin
                            TempRepaEntry.TransferFields(RepaLine2);
                            TempRepaEntry.Insert();
                        end;
                end;
            until RepaLine2.Next() = 0;

        TableCapt := RepaHead2.TableCaption;
        TableRecNo := RepaHead2."No.";
    end;

    var
        CompInfo: Record "Company Information";
        TempRepaInstallment: Record "YNS Repayment Line" temporary;
        RepaMgmt: Codeunit "YNS Repayment Management";
        FormatAddr: Codeunit "Format Address";
        CompAddrArray: array[8] of Text[100];
        SourceAddrArray: array[8] of Text[100];
        InterestTxt: Text;
        TableCapt: Text;
        TableRecNo: Text;
        TitleLbl: Label 'Repayment Summary';
        InterestLbl: Label 'Interest rate of %1 every %2 days';


}
#endif