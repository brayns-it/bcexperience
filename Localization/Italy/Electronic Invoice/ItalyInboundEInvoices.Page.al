#if ITXX002A
page 60021 "YNS Italy Inbound E-Invoices"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "YNS Italy E-Invoice";
    Caption = 'Italy Inbound E-Invoices';
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = true;
    ContextSensitiveHelpPage = '/page/electronic-invoicing-it';

    layout
    {
        area(Content)
        {
            repeater(control1)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = All;
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = All;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Source No."; Rec."Source No.")
                {
                    ApplicationArea = All;
                }
                field("Source Description"; Rec."Source Description")
                {
                    ApplicationArea = All;
                }
                field("Partner Group"; Rec."Partner Group")
                {
                    ApplicationArea = All;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                }
                field("Send/Receive Date/Time"; Rec."Send/Receive Date/Time")
                {
                    ApplicationArea = All;
                }
                field("Source VAT Registration No."; Rec."Source VAT Registration No.")
                {
                    ApplicationArea = All;
                }
                field("Source Fiscal Code"; Rec."Source Fiscal Code")
                {
                    ApplicationArea = All;
                }
                field("SdI Number"; Rec."SdI Number")
                {
                    ApplicationArea = All;
                }
                field("Purchase Document No."; Rec."Purchase Document No.")
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
            action(createvendor)
            {
                Caption = 'Create Vendor';
                Image = Suggest;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    if Rec."Entry No." > 0 then
                        ItInvFmt.CreateVendorFromInvoice(Rec);
                end;
            }
            action(createinvoice)
            {
                Caption = 'Create Document';
                Image = SuggestPayment;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    if Rec."Entry No." > 0 then
                        ItInvFmt.CreateDocumentFromEInvoice(Rec);
                end;
            }
            action(htmlexport)
            {
                Caption = 'Export in HTML';
                Image = ExportFile;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    if Rec."Entry No." > 0 then
                        ItInvFmt.ExportEInvoiceInHtml(Rec);
                end;
            }
            action(upload)
            {
                Caption = 'Upload';
                Image = Import;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    ItInvFmt.ManualUploadEInvoice();
                end;
            }
            action(download)
            {
                Caption = 'Download';
                Image = Download;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    if Rec."Entry No." > 0 then
                        ItInvFmt.DownloadEInvoice(Rec);
                end;
            }
            action(YNSDocExchange)
            {
                Image = SwitchCompanies;
                Caption = 'Document Exchange';
                ApplicationArea = All;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    EInvoice: Record "YNS Italy E-Invoice";
                    DocXMgmt: Codeunit "YNS Doc. Exchange Management";
                    RecRef: RecordRef;
                begin
                    CurrPage.SetSelectionFilter(EInvoice);
                    RecRef.GetTable(Rec);
                    DocXMgmt.ManualProcessDocuments(RecRef, Page::"YNS Italy Inbound E-Invoices");
                end;
            }
        }
    }

    var
        ItInvFmt: Codeunit "YNS Italy E-Invoice Format";

    trigger OnOpenPage()
    begin
        Rec.FilterGroup(2);
        Rec.SetRange(Direction, Rec.Direction::Inbound);
        Rec.FilterGroup(0);
    end;
}
#endif