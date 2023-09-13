#if W1FN001A
page 60000 "YNS Arrange CV Entries"
{
    PageType = List;
    SourceTable = "Gen. Journal Line";
    SourceTableTemporary = true;
    Caption = 'Arrange Customer/Vendor Entries';
    AutoSplitKey = true;
    DelayedInsert = false;
    ContextSensitiveHelpPage = '/page/arrange-customervendor-entries';

    layout
    {
        area(Content)
        {
            group(document)
            {
                ShowCaption = false;

                field("Source No."; Rec."Source No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(DocumentAmt; DocumentAmt)
                {
                    ApplicationArea = All;
                    Editable = false;

                    Caption = 'Document Amount';
                }
                field(InstallmentsAmt; InstallmentsAmt)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Installments Amount';
                }
            }
            repeater(Control1)
            {
                field(Amount; Rec.Amount)
                {
                    Caption = 'Remaining Amount';
                    ApplicationArea = All;
                }
                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = All;
                }
                field("Payment Method Code"; Rec."Payment Method Code")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(applyentr)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                Image = ApplyEntries;
                Caption = 'Apply';

                trigger OnAction()
                var
                    ApplyQst: Label 'Apply arranged entries?';
                begin
                    if Confirm(ApplyQst) then begin
                        FinMgmt.ApplyArrangedCustomerEntries(Rec);
                        Close();
                    end;
                end;
            }
        }
    }

    var
        OrigCustLedg: Record "Cust. Ledger Entry";
        GenBatch: Record "Gen. Journal Batch";
        FinMgmt: Codeunit "YNS Finance Management";
        DataSource: Option Customer,Vendor;
        DocumentAmt: Decimal;
        InstallmentsAmt: Decimal;

    local procedure Reload()
    var
        CustLedg2: Record "Cust. Ledger Entry";
        LineNo: Integer;
        CannotArrangeErr: Label 'Cannot arrange entries of %1 %2';
    begin
        Rec.Reset();
        Rec.DeleteAll();
        LineNo := 0;
        DocumentAmt := 0;

        case DataSource of
            DataSource::Customer:
                begin
                    CustLedg2.Reset();
                    CustLedg2.SetRange("Customer No.", OrigCustLedg."Customer No.");
                    CustLedg2.SetRange("Document Type", OrigCustLedg."Document Type");
                    CustLedg2.SetRange("Document No.", OrigCustLedg."Document No.");
                    CustLedg2.SetRange("Posting Date", OrigCustLedg."Posting Date");
                    CustLedg2.SetRange("Currency Code", OrigCustLedg."Currency Code");
                    CustLedg2.SetRange(Open, true);
                    CustLedg2.SetAutoCalcFields("Remaining Amount");
                    if CustLedg2.IsEmpty then
                        Error(CannotArrangeErr, OrigCustLedg."Document Type", OrigCustLedg."Document No.");

                    if CustLedg2.FindSet() then
                        repeat
                            Rec.SetRange("Due Date", CustLedg2."Due Date");
                            Rec.SetRange("Payment Method Code", CustLedg2."Payment Method Code");
                            if Rec.FindFirst() then begin
                                Rec.Amount += CustLedg2."Remaining Amount";
                                Rec.Modify();
                            end
                            else begin
                                LineNo += 10000;
                                Rec.Init();
                                CopyRecFromCustomerEntry();
                                Rec."Line No." := LineNo;
                                Rec.Amount := CustLedg2."Remaining Amount";
                                Rec."Due Date" := CustLedg2."Due Date";
                                Rec."Payment Method Code" := CustLedg2."Payment Method Code";
                                Rec.Insert();
                            end;

                            DocumentAmt += CustLedg2."Remaining Amount";
                        until CustLedg2.Next() = 0;
                end;
        end;

        Rec.Reset();
    end;

    local procedure CopyRecFromCustomerEntry()
    begin
        Rec."Journal Template Name" := GenBatch."Journal Template Name";
        Rec."Journal Batch Name" := GenBatch.Name;
        Rec."Source Type" := Rec."Source Type"::Customer;
        Rec."Source No." := OrigCustLedg."Customer No.";
        Rec."Document Type" := OrigCustLedg."Document Type";
        Rec."Document No." := OrigCustLedg."Document No.";
        Rec."Posting Date" := OrigCustLedg."Posting Date";
        Rec."Currency Code" := OrigCustLedg."Currency Code";
    end;

    trigger OnOpenPage()
    begin
        GenBatch.Reset();
        GenBatch.SetRange("Template Type", GenBatch."Template Type"::General);
        GenBatch.FindFirst();
    end;

    procedure LoadFromCustomerEntry(var CustLedg: Record "Cust. Ledger Entry")
    begin
        OrigCustLedg := CustLedg;
        DataSource := DataSource::Customer;
        Reload();
    end;

    procedure LoadFromVendorEntry(var VendLedg: Record "Vendor Ledger Entry")
    begin
        Error('TODO');
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        case DataSource of
            DataSource::Customer:
                CopyRecFromCustomerEntry();
        end;
    end;

    trigger OnAfterGetCurrRecord()
    var
        TempJnlLine2: Record "Gen. Journal Line" temporary;
    begin
        TempJnlLine2.Copy(Rec, true);
        TempJnlLine2.CalcSums(Amount);
        InstallmentsAmt := TempJnlLine2.Amount;
    end;
}
#endif