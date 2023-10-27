#if W1XX008A
codeunit 60019 "YNS Ledger Deletion"
{
    Permissions = tabledata "G/L Entry" = rimd,
        tabledata "Cust. Ledger Entry" = rimd,
        tabledata "Detailed Cust. Ledg. Entry" = rimd,
        tabledata "Vendor Ledger Entry" = rimd,
        tabledata "Detailed Vendor Ledg. Entry" = rimd,
        tabledata "VAT Entry" = rimd,
        tabledata "G/L Entry - VAT Entry Link" = rimd,
        tabledata "Issued Fin. Charge Memo Header" = rimd,
        tabledata "Issued Fin. Charge Memo Line" = rimd,
        tabledata "Sales Invoice Header" = rimd,
        tabledata "Sales Invoice Line" = rimd,
        tabledata "Purch. Inv. Header" = rimd,
        tabledata "Purch. Inv. Line" = rimd,
        tabledata "Item Ledger Entry" = rimd,
        tabledata "Value Entry" = rimd,
        tabledata "Warehouse Entry" = rimd,
        tabledata "Item Application Entry" = rimd;

    procedure AssertPermission()
    var
        UserSetup: Record "User Setup";
    begin
        UserSetup.Get(UserId());
        UserSetup.TestField("YNS Allow Ledger Deletion");
    end;

    procedure DeleteCustomerLedger(var CustLedg: Record "Cust. Ledger Entry")
    var
        DetCustLedg: Record "Detailed Cust. Ledg. Entry";
    begin
        AssertPermission();

        CustLedg.TestField(Open);
        CustLedg.TestField("Remaining Amount", CustLedg.Amount);
        CustLedg.CalcFields(Amount, "Remaining Amount");

        DetCustLedg.Reset();
        DetCustLedg.SetRange("Cust. Ledger Entry No.", CustLedg."Entry No.");
        if DetCustLedg.FindSet() then
            repeat
                if not (DetCustLedg."Entry Type" in [DetCustLedg."Entry Type"::"Initial Entry", DetCustLedg."Entry Type"::Application]) then
                    DetCustLedg.FieldError("Entry Type");

                DetCustLedg.Delete();
            until DetCustLedg.Next() = 0;

        CustLedg.Delete();
    end;

    procedure DeleteVendorLedger(var VendLedg: Record "Vendor Ledger Entry")
    var
        DetVendLedg: Record "Detailed Vendor Ledg. Entry";
    begin
        AssertPermission();

        VendLedg.TestField(Open);
        VendLedg.TestField("Remaining Amount", VendLedg.Amount);
        VendLedg.CalcFields(Amount, "Remaining Amount");

        DetVendLedg.Reset();
        DetVendLedg.SetRange("Vendor Ledger Entry No.", VendLedg."Entry No.");
        if DetVendLedg.FindSet() then
            repeat
                if not (DetVendLedg."Entry Type" in [DetVendLedg."Entry Type"::"Initial Entry", DetVendLedg."Entry Type"::Application]) then
                    DetVendLedg.FieldError("Entry Type");

                DetVendLedg.Delete();
            until DetVendLedg.Next() = 0;

        VendLedg.Delete();
    end;

    procedure DeleteGLEntryYN(var GLEntry: Record "G/L Entry")
    var
        SalesInv: Record "Sales Invoice Header";
        SalesCrMemo: Record "Sales Cr.Memo Header";
        PurchInv: Record "Purch. Inv. Header";
        PurchCrMemo: Record "Purch. Cr. Memo Hdr.";
        IssuedFin: Record "Issued Fin. Charge Memo Header";
        DeleteFirstErr: Label 'Delete first %1 %2';
        DeleteQst: Label 'Delete %1 %2?';
    begin
        if not Confirm(DeleteQst, false, GLEntry.TableCaption, GLEntry."Document No.") then
            Error('');

        case GLEntry."Document Type" of
            GLEntry."Document Type"::Invoice:
                case GLEntry."Source Type" of
                    GLEntry."Source Type"::Customer:
                        if SalesInv.Get(GLEntry."Document No.") then
                            Error(DeleteFirstErr, SalesInv.TableCaption, GLEntry."Document No.");
                    GLEntry."Source Type"::Vendor:
                        if PurchInv.Get(GLEntry."Document No.") then
                            Error(DeleteFirstErr, PurchInv.TableCaption, GLEntry."Document No.");
                end;
            GLEntry."Document Type"::"Credit Memo":
                case GLEntry."Source Type" of
                    GLEntry."Source Type"::Customer:
                        if SalesCrMemo.Get(GLEntry."Document No.") then
                            Error(DeleteFirstErr, SalesCrMemo.TableCaption, GLEntry."Document No.");
                    GLEntry."Source Type"::Vendor:
                        if PurchCrMemo.Get(GLEntry."Document No.") then
                            Error(DeleteFirstErr, PurchCrMemo.TableCaption, GLEntry."Document No.");
                end;
            GLEntry."Document Type"::"Finance Charge Memo":
                if IssuedFin.Get(GLEntry."Document No.") then
                    Error(DeleteFirstErr, IssuedFin.TableCaption, GLEntry."Document No.");
        end;

        DeleteLedgers(GLEntry."Document No.", GLEntry."Document Type", GLEntry."Posting Date", GLEntry."Transaction No.");
    end;

    procedure DeleteLedgers(DocumentNo: Code[20]; DocumentType: Enum "Gen. Journal Document Type"; PostingDate: Date; TransactionNo: Integer)
    var
        GLEntry: Record "G/L Entry";
        GLVatLink: Record "G/L Entry - VAT Entry Link";
        VatEntry: Record "VAT Entry";
        CustLedg: Record "Cust. Ledger Entry";
        VendLedg: Record "Vendor Ledger Entry";
#if LOCALEIT
        GLBook: Record "GL Book Entry";
#endif
        InconsistentErr: Label 'Inconsistent G/L Entry';
        Amount: Decimal;
    begin
        AssertPermission();

        GLEntry.Reset();
        GLEntry.SetRange("Document No.", DocumentNo);
        GLEntry.SetRange("Document Type", DocumentType);
        GLEntry.SetRange("Posting Date", PostingDate);
        GLEntry.SetRange("Transaction No.", TransactionNo);

        Amount := 0;
        if GLEntry.FindSet() then
            repeat
                Amount += GLEntry.Amount;

                GLVatLink.Reset();
                GLVatLink.SetRange("G/L Entry No.", GLEntry."Entry No.");
                GLVatLink.DeleteAll();

#if LOCALEIT
                if GLBook.Get(GLEntry."Entry No.") then
                    GLBook.Delete();
#endif
                GLEntry.Delete();

                if CustLedg.Get(GLEntry."Entry No.") then
                    DeleteCustomerLedger(CustLedg);

                if VendLedg.Get(GLEntry."Entry No.") then
                    DeleteVendorLedger(VendLedg);
            until GLEntry.Next() = 0;

        if Amount <> 0 then
            Error(InconsistentErr);

        VatEntry.Reset();
        VatEntry.SetRange("Document No.", GLEntry."Document No.");
        VatEntry.SetRange("Document Type", GLEntry."Document Type");
        VatEntry.SetRange("Posting Date", GLEntry."Posting Date");
        VatEntry.SetRange("Transaction No.", GLEntry."Transaction No.");
        DeleteVatEntry(VatEntry);

        VatEntry.Reset();
        VatEntry.SetRange("Bill-to/Pay-to No.", GLEntry."Source No.");
        VatEntry.SetRange("External Document No.", GLEntry."External Document No.");
        VatEntry.SetRange("Document Type", GLEntry."Document Type");
        VatEntry.SetRange("Posting Date", GLEntry."Posting Date");
        VatEntry.SetRange("Reverse Sales VAT", true);
        VatEntry.SetRange("Transaction No.", GLEntry."Transaction No.");
        DeleteVatEntry(VatEntry);
    end;

    procedure DeleteVatEntry(var VatEntry: Record "VAT Entry")
    var
#if LOCALEIT
        VatBook: Record "VAT Book Entry";
#endif
    begin
        AssertPermission();

        if VatEntry.FindSet() then
            repeat
                VatEntry.TestField(Closed, false);

#if LOCALEIT
                if VatBook.Get(VatEntry."Entry No.") then
                    VatBook.Delete();
#endif
                VatEntry.Delete();
            until VatEntry.Next() = 0;
    end;

    procedure DeletePurchaseInvoiceYN(var PurchInvHeader: Record "Purch. Inv. Header")
    var
        DeleteQst: Label 'Delete %1 %2?';
    begin
        if not Confirm(DeleteQst, false, PurchInvHeader.TableCaption, PurchInvHeader."No.") then
            Error('');

        DeletePurchaseInvoice(PurchInvHeader);
    end;

    procedure DeletePurchaseInvoice(var PurchInvHeader: Record "Purch. Inv. Header")
    var
        VendLedg: Record "Vendor Ledger Entry";
        PurchInvLine: Record "Purch. Inv. Line";
#if LOCALEIT        
        PostedPaym: Record "Posted Payment Lines";
#endif        
        TransNo: Integer;
    begin
        AssertPermission();

        VendLedg.Reset();
        VendLedg.SetRange("Vendor No.", PurchInvHeader."Pay-to Vendor No.");
        VendLedg.SetRange("Document No.", PurchInvHeader."No.");
        VendLedg.SetRange("Document Type", VendLedg."Document Type"::Invoice);
        VendLedg.SetRange("Posting Date", PurchInvHeader."Posting Date");
        VendLedg.FindFirst();
        TransNo := VendLedg."Transaction No.";

        PurchInvLine.Reset();
        PurchInvLine.SetRange("Document No.", PurchInvHeader."No.");
        if PurchInvLine.FindSet() then
            repeat
                if not (PurchInvLine.Type in [PurchInvLine.Type::" ", PurchInvLine.Type::"G/L Account", PurchInvLine.Type::Item]) then
                    PurchInvLine.FieldError(Type);
                PurchInvLine.Delete();
            until PurchInvLine.Next() = 0;

        DeleteLedgers(PurchInvHeader."No.", Enum::"Gen. Journal Document Type"::Invoice, PurchInvHeader."Posting Date", TransNo);
        DeleteInventoryLedgers(PurchInvHeader."No.", Enum::"Item Ledger Document Type"::"Purchase Invoice", PurchInvHeader."Posting Date");

#if LOCALEIT
        PostedPaym.Reset();
        PostedPaym.SetRange("Sales/Purchase", PostedPaym."Sales/Purchase"::Purchase);
        PostedPaym.SetRange(Type, PostedPaym.Type::Invoice);
        PostedPaym.SetRange(Code, PurchInvHeader."No.");
        PostedPaym.DeleteAll();
#endif  

        PurchInvHeader.Delete();
    end;

    procedure DeleteSalesInvoiceYN(var SalesInvHeader: Record "Sales Invoice Header")
    var
        DeleteQst: Label 'Delete %1 %2?';
    begin
        if not Confirm(DeleteQst, false, SalesInvHeader.TableCaption, SalesInvHeader."No.") then
            Error('');

        DeleteSalesInvoice(SalesInvHeader);
    end;

    procedure DeleteSalesInvoice(var SalesInvHeader: Record "Sales Invoice Header")
    var
        CustLedg: Record "Cust. Ledger Entry";
        SalesInvLine: Record "Sales Invoice Line";
#if LOCALEIT        
        PostedPaym: Record "Posted Payment Lines";
#endif        
        TransNo: Integer;
    begin
        AssertPermission();

        CustLedg.Reset();
        CustLedg.SetRange("Customer No.", SalesInvHeader."Bill-to Customer No.");
        CustLedg.SetRange("Document No.", SalesInvHeader."No.");
        CustLedg.SetRange("Document Type", CustLedg."Document Type"::Invoice);
        CustLedg.SetRange("Posting Date", SalesInvHeader."Posting Date");
        CustLedg.FindFirst();
        TransNo := CustLedg."Transaction No.";

        SalesInvLine.Reset();
        SalesInvLine.SetRange("Document No.", SalesInvHeader."No.");
        if SalesInvLine.FindSet() then
            repeat
                if not (SalesInvLine.Type in [SalesInvLine.Type::" ", SalesInvLine.Type::"G/L Account", SalesInvLine.Type::Item]) then
                    SalesInvLine.FieldError(Type);
                SalesInvLine.Delete();
            until SalesInvLine.Next() = 0;

        DeleteLedgers(SalesInvHeader."No.", Enum::"Gen. Journal Document Type"::Invoice, SalesInvHeader."Posting Date", TransNo);
        DeleteInventoryLedgers(SalesInvHeader."No.", Enum::"Item Ledger Document Type"::"Sales Invoice", SalesInvHeader."Posting Date");

#if LOCALEIT
        PostedPaym.Reset();
        PostedPaym.SetRange("Sales/Purchase", PostedPaym."Sales/Purchase"::Sales);
        PostedPaym.SetRange(Type, PostedPaym.Type::Invoice);
        PostedPaym.SetRange(Code, SalesInvHeader."No.");
        PostedPaym.DeleteAll();
#endif  

        SalesInvHeader.Delete();
    end;

    procedure DeleteFinChargeMemoYN(var IssuedFinCharge: Record "Issued Fin. Charge Memo Header")
    var
        DeleteQst: Label 'Delete %1 %2?';
    begin
        if not Confirm(DeleteQst, false, IssuedFinCharge.TableCaption, IssuedFinCharge."No.") then
            Error('');

        DeleteFinChargeMemo(IssuedFinCharge);
    end;

    procedure DeleteFinChargeMemo(var IssuedFinCharge: Record "Issued Fin. Charge Memo Header")
    var
        CustLedg: Record "Cust. Ledger Entry";
        FinChargeLine: Record "Issued Fin. Charge Memo Line";
        TransNo: Integer;
    begin
        AssertPermission();

        CustLedg.Reset();
        CustLedg.SetRange("Customer No.", IssuedFinCharge."Customer No.");
        CustLedg.SetRange("Document No.", IssuedFinCharge."No.");
        CustLedg.SetRange("Document Type", CustLedg."Document Type"::"Finance Charge Memo");
        CustLedg.SetRange("Posting Date", IssuedFinCharge."Posting Date");
        CustLedg.FindFirst();
        TransNo := CustLedg."Transaction No.";

        FinChargeLine.Reset();
        FinChargeLine.SetRange("Finance Charge Memo No.", IssuedFinCharge."No.");
        FinChargeLine.DeleteAll();

        DeleteLedgers(IssuedFinCharge."No.", Enum::"Gen. Journal Document Type"::"Finance Charge Memo", IssuedFinCharge."Posting Date", TransNo);

        IssuedFinCharge.Delete();
    end;

    procedure DeleteInventoryLedgers(DocumentNo: Code[20]; DocumentType: Enum "Item Ledger Document Type"; PostingDate: Date)
    var
        ValueEntry: Record "Value Entry";
        ItemLedg: Record "Item Ledger Entry";
        ItemAppl: Record "Item Application Entry";
        WhseEntry: Record "Warehouse Entry";
    begin
        ValueEntry.Reset();
        ValueEntry.SetRange("Document No.", DocumentNo);
        ValueEntry.SetRange("Posting Date", PostingDate);
        ValueEntry.SetRange("Document Type", DocumentType);
        if ValueEntry.FindSet() then
            repeat
                if ValueEntry."Item Ledger Entry Quantity" = 0 then
                    ValueEntry.FieldError(ValueEntry."Item Ledger Entry Quantity")     // TODO
                else begin
                    ItemLedg.Get(ValueEntry."Item Ledger Entry No.");
                    ItemLedg.Delete();

                    ItemAppl.Reset();
                    ItemAppl.SetRange("Outbound Item Entry No.", ValueEntry."Item Ledger Entry No.");
                    if ItemAppl.FindSet() then
                        repeat
                            if ItemLedg.Get(ItemAppl."Inbound Item Entry No.") then begin
                                ItemLedg.Open := true;
                                ItemLedg."Remaining Quantity" -= ItemAppl.Quantity;
                                ItemLedg.Modify();
                            end;

                            ItemAppl.Delete();
                        until ItemAppl.Next() = 0;

                    ItemAppl.Reset();
                    ItemAppl.SetRange("Inbound Item Entry No.", ValueEntry."Item Ledger Entry No.");
                    if ItemAppl.FindSet() then
                        repeat
                            if ItemLedg.Get(ItemAppl."Outbound Item Entry No.") then begin
                                ItemLedg.Open := true;
                                ItemLedg."Remaining Quantity" += ItemAppl.Quantity;
                                ItemLedg.Modify();
                            end;

                            ItemAppl.Delete();
                        until ItemAppl.Next() = 0;

                    WhseEntry.Reset();
                    WhseEntry.SetRange("Reference No.", DocumentNo);
                    WhseEntry.SetRange("Registering Date", PostingDate);
                    case DocumentType of
                        Enum::"Item Ledger Document Type"::"Sales Invoice":
                            WhseEntry.SetRange("Reference Document", Enum::"Whse. Reference Document Type"::"Posted S. Inv.");
                        Enum::"Item Ledger Document Type"::"Purchase Invoice":
                            WhseEntry.SetRange("Reference Document", Enum::"Whse. Reference Document Type"::"Posted P. Inv.");
                        else
                            ValueEntry.FieldError("Document Type");
                    end;
                    WhseEntry.DeleteAll();
                end;

                ValueEntry.Delete();
            until ValueEntry.Next() = 0;
    end;
}
#endif