#if FN0001A or ALL
page 60000 "YNS Arrange CV Entries"
{
    PageType = List;
    SourceTable = "Gen. Journal Line";
    SourceTableTemporary = true;
    Caption = 'Arrange Customer/Vendor Entries';
    AutoSplitKey = true;

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
                field("Total"; Total)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Total';
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

    var
        OrigCustLedg: Record "Cust. Ledger Entry";
        DataSource: Option Customer,Vendor;
        Total: Decimal;

    local procedure Reload()
    var
        CustLedg2: Record "Cust. Ledger Entry";
        LineNo: Integer;
        CannotArrangeErr: Label 'Cannot arrange entries of %1 %2';
    begin
        Rec.Reset();
        Rec.DeleteAll();
        LineNo := 10000;
        Total := 0;

        case DataSource of
            DataSource::Customer:
                begin
                    CustLedg2.Reset();
                    CustLedg2.SetRange("Customer No.", OrigCustLedg."Customer No.");
                    CustLedg2.SetRange("Document Type", OrigCustLedg."Document Type");
                    CustLedg2.SetRange("Document No.", OrigCustLedg."Document No.");
                    CustLedg2.SetRange("Posting Date", OrigCustLedg."Posting Date");
                    CustLedg2.SetRange(Open, true);
                    CustLedg2.SetAutoCalcFields("Remaining Amount");
                    if CustLedg2.IsEmpty then
                        Error(CannotArrangeErr, OrigCustLedg."Document Type", OrigCustLedg."Document No.");

                    if CustLedg2.FindSet() then
                        repeat
                            Rec.Init();
                            Rec."Line No." := LineNo;
                            Rec."Source Type" := Rec."Source Type"::Customer;
                            Rec."Source No." := CustLedg2."Customer No.";
                            Rec."Document Type" := CustLedg2."Document Type";
                            Rec."Document No." := CustLedg2."Document No.";
                            Rec.Amount := CustLedg2."Remaining Amount";
                            Rec."Posting Date" := CustLedg2."Posting Date";
                            Rec."Currency Code" := CustLedg2."Currency Code";
                            Rec."Due Date" := CustLedg2."Due Date";
                            Rec."Payment Method Code" := CustLedg2."Payment Method Code";
                            Rec.Insert();
                            LineNo += 10000;
                            Total += CustLedg2."Remaining Amount";
                        until CustLedg2.Next() = 0;
                end;
        end;
    end;

    procedure LoadFromCustomerEntry(var CustLedg: Record "Cust. Ledger Entry")
    begin
        OrigCustLedg := CustLedg;
        DataSource := DataSource::Customer;
        Reload();
    end;

}
#endif