#if ITXX002A
codeunit 60009 "YNS Italy E-Invoice Format" implements "YNS Doc. Exchange Format"
{
    var
        GlobalProfile: Record "YNS Doc. Exchange Profile";
        GlobalEInvoice: Record "YNS Italy E-Invoice";
        EInvSetup: Record "YNS Italy E-Invoice Setup";
        FileStorMgmt: Codeunit "YNS File Storage Management";
        DocExMgmt: Codeunit "YNS Doc. Exchange Management";
        Functions: Codeunit "YNS Functions";
        EInvSetupGot: Boolean;
        InvalidRecErr: Label 'Invalid record number %1';
        Progress: Dialog;
        ProgressIsOpen: Boolean;

    local procedure GetEInvoiceSetup()
    begin
        if not EInvSetupGot then begin
            EInvSetupGot := true;
            EInvSetup.Get();
        end;
    end;

    procedure OpenSetup()
    begin
        Page.Run(Page::"YNS Italy E-Invoice Setup");
    end;

    procedure GetManualProcessOptions(var SelectedProfile: Record "YNS Doc. Exchange Profile"; var TempOptions: Record "Name/Value Buffer" temporary; var DocRefs: RecordRef; PageID: Integer)
    var
        ITransport: Interface "YNS Doc. Exchange Transport";
        ExportSdiLbl: Label 'Export Italy E-Invoice';
        DownloadFromSdiLbl: Label 'Receive Invoices via %1';
    begin
        case DocRefs.Number of
            Database::"Sales Invoice Header",
            Database::"Sales Cr.Memo Header":
                DocExMgmt.AddProcessOption('', SelectedProfile."Exchange Format", 'EXPORT', ExportSdiLbl, TempOptions);
        end;

        case PageID of
            Page::"YNS Italy Purchases E-Invoices":
                begin
                    ITransport := SelectedProfile."Exchange Transport";
                    if ITransport.BatchAllowed() then
                        DocExMgmt.AddProcessOption(SelectedProfile.Code, SelectedProfile."Exchange Format", 'RECEIVE', StrSubstNo(DownloadFromSdiLbl, SelectedProfile."Exchange Transport"), TempOptions);
                end;
        end;
    end;

    procedure SetProfile(var ExProfile: Record "YNS Doc. Exchange Profile")
    begin
        GlobalProfile := ExProfile;
    end;

    procedure Process(ProcessAction: Text; var DocRefs: RecordRef)
    var
        N: Integer;
        C: Integer;
    begin
        if GuiAllowed then begin
            Progress.Open('#1####\#2####');
            ProgressIsOpen := true;
            N := 0;
            C := 0;
        end;

        case ProcessAction of
            'EXPORT':
                begin
                    C := DocRefs.Count;
                    if DocRefs.FindSet() then
                        repeat
                            N += 1;
                            Progress.Update(2, Format(Round((N * 10000) / C, 1)) + '%');
                            ExportEInvoice(DocRefs);
                        until DocRefs.Next() = 0;
                end;
            'RECEIVE':
                ReceiveEInvoices();
        end;

        if ProgressIsOpen then
            Progress.Close();
    end;

    procedure ReceiveEInvoices()
    var
        ITransport: Interface "YNS Doc. Exchange Transport";
        Streams: Dictionary of [Text, Text];
        StreamTxt: Text;
        Metadata: JsonObject;
        ReceivingLbl: Label 'Receiving invoices...';
    begin
        if ProgressIsOpen then
            Progress.Update(1, ReceivingLbl);

        ITransport := GlobalProfile."Exchange Transport";
        ITransport.SetProfile(GlobalProfile);
        ITransport.BatchReceiveStart('PURCHASE_INVOICE');

        while ITransport.BatchReceive(Streams) do begin
            if Streams.ContainsKey('invoice.xml') then begin
                Streams.Get('metadata.json', StreamTxt);
                Metadata.ReadFrom(StreamTxt);

                if ProgressIsOpen then
                    Progress.Update(2, Functions.GetJsonPropertyAsText(Metadata, 'NomeFile'));

                Streams.Get('invoice.xml', StreamTxt);
                UploadEInvoice(StreamTxt, Functions.GetJsonPropertyAsText(Metadata, 'NomeFile'),
                    Functions.GetJsonPropertyAsText(Metadata, 'IdentificativoSdI'),
                    Functions.GetJsonPropertyAsDateTime(Metadata, 'DataOraRicezione'),
                    true);
            end;

            ITransport.BatchReceiveConfirm();
        end;

        ITransport.BatchReceiveStop();
    end;

    procedure ExportEInvoiceInHtml(var EInvoice2: Record "YNS Italy E-Invoice")
    var
        DomMgmt: Codeunit "XML DOM Management";
        Content: Text;
        Style: Text;
        FileName: Text;
    begin
        EInvoice2.TestField("File Path");
        Content := FileStorMgmt.GetFileAsText(EInvoice2."File Path");
        FileName := FileStorMgmt.GetCurrentFileName(true) + '.html';

        GetEInvoiceSetup();
        EInvSetup.TestField("Stylesheet Path");
        Style := FileStorMgmt.GetFileAsText(EInvSetup."Stylesheet Path");
        Functions.DownloadText('', 'HTML File|*.html', FileName, DomMgmt.TransformXMLText(Content, Style));
    end;

    procedure GetXmlInvoiceFromStream(FileName: Text; var FileStream: InStream) Result: Text
    var
#if W1XX007A
        RemFun: Codeunit "YNS Remote Functions Mgmt.";
#endif
        FileNotSupportedErr: Label 'File %1 not supported';
    begin
        if FileName.ToLower().EndsWith('.xml') then begin
            Result := Functions.ConvertStreamToText(FileStream);
            exit;
        end;
#if W1XX007A     
        if FileName.ToLower().EndsWith('.p7m') then begin
            Result := RemFun.GetPkcs7Message(FileStream);
            exit;
        end;
#endif
        Error(FileNotSupportedErr, FileName);
    end;

    procedure NormalizeFileName(var FileName: Text)
    begin
        if FileName.ToLower().EndsWith('.p7m') then begin
            FileName := FileName.Substring(1, StrLen(FileName) - 4);
            if not FileName.ToLower().EndsWith('.xml') then
                FileName += '.xml';
        end;
    end;

    procedure ManualUploadEInvoice()
    var
        FileName: Text;
        FileStream: InStream;
        FileContent: Text;
    begin
        if not Functions.UploadStream('', 'XML File|*.xml|Signed XML File|*.p7m', FileName, FileStream) then
            exit;

        FileContent := GetXmlInvoiceFromStream(FileName, FileStream);
        UploadEInvoice(FileContent, FileName, '', CurrentDateTime, false);
    end;

    procedure UploadEInvoice(FileContent: Text; FileName: Text; SdiNumber: Text; ReceivedDateTime: DateTime; SkipConfirmation: Boolean)
    var
        CompInfo: Record "Company Information";
        XmlRoot: XmlElement;
        XmlRootNode: XmlNode;
        XmlDoc: XmlDocument;
        XmlNod: XmlNode;
        XmlLst: XmlNodeList;
        ReceiverID: Text;
        ReceiverIDs: Text;
        Path: Text;
        IsForMe: Boolean;
        DocumentForOtherQst: Label 'Invoice %1 is for %2 not for you, import anyway?';
        L: Integer;
    begin
        GetEInvoiceSetup();
        EInvSetup.TestField("Working Path");

        NormalizeFileName(FileName);

        if FileStorMgmt.FileExists(EInvSetup."Working Path" + '/inbound/' + FileName) then
            exit;

        XmlDocument.ReadFrom(FileContent, XmlDoc);
        XmlDoc.GetRoot(XmlRoot);
        XmlRootNode := XmlRoot.AsXmlNode();

        CompInfo.Get();
        IsForMe := false;
        ReceiverIDs := '';

        if not IsForMe then
            if XmlRootNode.SelectSingleNode('FatturaElettronicaHeader/CessionarioCommittente/DatiAnagrafici/IdFiscaleIVA', XmlNod) then begin
                ReceiverID := Functions.GetXmlChildAsText('IdPaese', XmlNod) + Functions.GetXmlChildAsText('IdCodice', XmlNod);
                ReceiverIDs += ReceiverID + ' ';
                CompInfo.TestField("VAT Registration No.");
                if CompInfo."VAT Registration No." = ReceiverID then
                    IsForMe := true;
            end;

        if not IsForMe then
            if XmlRootNode.SelectSingleNode('FatturaElettronicaHeader/CessionarioCommittente/DatiAnagrafici/CodiceFiscale', XmlNod) then begin
                ReceiverID := XmlNod.AsXmlElement().InnerText;
                ReceiverIDs += ReceiverID + ' ';
                CompInfo.TestField("Fiscal Code");
                if CompInfo."Fiscal Code" = ReceiverID then
                    IsForMe := true;
            end;

        if not IsForMe then
            if SkipConfirmation then
                exit
            else
                if not Confirm(DocumentForOtherQst, false, FileName, ReceiverIDs) then
                    exit;

        FileStorMgmt.SaveFile(EInvSetup."Working Path" + '/inbound/' + FileName, 'text/xml', FileContent);
        Path := FileStorMgmt.GetCurrentPath();

        L := 1;
        XmlRootNode.SelectNodes('FatturaElettronicaBody', XmlLst);
        foreach XmlNod in XmlLst do begin
            UploadSingleEInvoice(XmlRootNode, XmlNod, L, Path, SdiNumber, ReceivedDateTime);
            L += 1;
        end;
    end;

    procedure UploadSingleEInvoice(var XmlRootNode: XmlNode; var InvoiceNode: XmlNode; LotNo: Integer; Path: Text; SdiNumber: Text; ReceivedDateTime: DateTime)
    var
        XmlNod: XmlNode;
        DatiGeneraliDocumento: XmlNode;
    begin
        GlobalEInvoice.Init();
        GlobalEInvoice."Entry No." := 0;
        GlobalEInvoice."Source Type" := GlobalEInvoice."Source Type"::Vendor;

        XmlRootNode.SelectSingleNode('FatturaElettronicaHeader/CedentePrestatore/DatiAnagrafici/Anagrafica', XmlNod);
        if Functions.GetXmlChildAsText('Denominazione', XmlNod) > '' then
            GlobalEInvoice."Source Description" := CopyStr(Functions.GetXmlChildAsText('Denominazione', XmlNod), 1, MaxStrLen(GlobalEInvoice."Source Description"))
        else
            GlobalEInvoice."Source Description" := CopyStr(Functions.GetXmlChildAsText('Nome', XmlNod) + ' ' + Functions.GetXmlChildAsText('Cognome', XmlNod), 1, MaxStrLen(GlobalEInvoice."Source Description"));

        if XmlRootNode.SelectSingleNode('FatturaElettronicaHeader/CedentePrestatore/DatiAnagrafici/IdFiscaleIVA', XmlNod) then
            GlobalEInvoice."Source VAT Registration No." := CopyStr(Functions.GetXmlChildAsText('IdPaese', XmlNod) + Functions.GetXmlChildAsText('IdCodice', XmlNod), 1, MaxStrLen(GlobalEInvoice."Source VAT Registration No."));

        if XmlRootNode.SelectSingleNode('FatturaElettronicaHeader/CedentePrestatore/DatiAnagrafici/CodiceFiscale', XmlNod) then
            GlobalEInvoice."Source Fiscal Code" := CopyStr(XmlNod.AsXmlElement().InnerText, 1, MaxStrLen(GlobalEInvoice."Source Fiscal Code"));

        InvoiceNode.SelectSingleNode('DatiGenerali/DatiGeneraliDocumento', DatiGeneraliDocumento);

        GlobalEInvoice."Document Type" := CopyStr(Functions.GetXmlChildAsText('TipoDocumento', DatiGeneraliDocumento), 1, MaxStrLen(GlobalEInvoice."Document Type"));

        GlobalEInvoice."External Document No." := CopyStr(Functions.GetXmlChildAsText('Numero', DatiGeneraliDocumento), 1, MaxStrLen(GlobalEInvoice."External Document No."));
        GlobalEInvoice."Document Date" := Functions.GetXmlChildAsDate('Data', DatiGeneraliDocumento);
        GlobalEInvoice."Currency Code" := CopyStr(Functions.GetXmlChildAsText('Divisa', DatiGeneraliDocumento), 1, MaxStrLen(GlobalEInvoice."Currency Code"));
        GlobalEInvoice.Amount := Functions.GetXmlChildAsDecimal('ImportoTotaleDocumento', DatiGeneraliDocumento);

        XmlRootNode.SelectSingleNode('FatturaElettronicaHeader/DatiTrasmissione', XmlNod);
        GlobalEInvoice."Progressive No." := CopyStr(Functions.GetXmlChildAsText('ProgressivoInvio', XmlNod), 1, MaxStrLen(GlobalEInvoice."Progressive No."));
        GlobalEInvoice."Send/Receive Date/Time" := ReceivedDateTime;
        GlobalEInvoice."SdI Number" := CopyStr(SdiNumber, 1, MaxStrLen(GlobalEInvoice."SdI Number"));
        GlobalEInvoice."File Path" := CopyStr(Path, 1, MaxStrLen(GlobalEInvoice."File Path"));
        GlobalEInvoice."File Lot No." := LotNo;
        GlobalEInvoice.Insert();

        TryIdentifyPurchaseInvoice(GlobalEInvoice);
    end;

    procedure TryIdentifyPurchaseInvoice(var EInvoice2: Record "YNS Italy E-Invoice")
    var
        Vend: Record Vendor;
        VatEntry: Record "VAT Entry";
    begin
        Clear(Vend);

        if Vend."No." = '' then
            if (EInvoice2."Source VAT Registration No." > '') and (EInvoice2."Source Fiscal Code" > '') then begin
                Vend.Reset();
                Vend.SetRange("VAT Registration No.", EInvoice2."Source VAT Registration No.");
                Vend.SetRange("Fiscal Code", EInvoice2."Source Fiscal Code");
                if not Vend.FindFirst() then;
            end;

        if Vend."No." = '' then
            if EInvoice2."Source VAT Registration No." > '' then begin
                Vend.Reset();
                Vend.SetRange("VAT Registration No.", EInvoice2."Source VAT Registration No.");
                if not Vend.FindFirst() then;
            end;

        if Vend."No." = '' then
            if EInvoice2."Source Fiscal Code" > '' then begin
                Vend.Reset();
                Vend.SetRange("Fiscal Code", EInvoice2."Source Fiscal Code");
                if not Vend.FindFirst() then;
            end;

        if Vend."No." = '' then
            exit;

        if EInvoice2."Source No." <> Vend."No." then begin
            EInvoice2."Source No." := Vend."No.";
            EInvoice2.Modify();
        end;

        VatEntry.Reset();
        VatEntry.SetRange("Bill-to/Pay-to No.", Vend."No.");
        VatEntry.SetRange("External Document No.", EInvoice2."External Document No.");
        VatEntry.SetRange("Document Date", EInvoice2."Document Date");
        if VatEntry.FindFirst() then
            if VatEntry."Document No." <> EInvoice2."Document No." then begin
                EInvoice2."Document No." := VatEntry."Document No.";
                EInvoice2."Posting Date" := VatEntry."Posting Date";
                if VatEntry."Document Type" = VatEntry."Document Type"::Invoice then
                    EInvoice2."Document ID" := Database::"Purch. Inv. Header"
                else
                    EInvoice2."Document ID" := Database::"Purch. Cr. Memo Hdr.";
                EInvoice2.Modify();
            end;
    end;

    procedure DownloadEInvoice(var EInvoice2: Record "YNS Italy E-Invoice")
    var
        FileName: Text;
        FileContent: Text;
    begin
        EInvoice2.TestField("File Path");

        FileContent := FileStorMgmt.GetFileAsText(EInvoice2."File Path");
        FileName := FileStorMgmt.GetCurrentFileName();

        Functions.DownloadText('', Functions.GetFileFilter('text/xml'), FileName, FileContent);
    end;

    procedure ExportEInvoice(var DocRef: RecordRef)
    var
        SalesInvoice: Record "Sales Invoice Header";
        SalesCrMemo: Record "Sales Cr.Memo Header";
        XmlDoc: XmlDocument;
        FileName: Text;
        FileContent: Text;
    begin
        GlobalEInvoice.Reset();
        GlobalEInvoice.SetRange("Source Type", GlobalEInvoice."Source Type"::Customer);
        GlobalEInvoice.SetRange("Document ID", DocRef.Number);

        case DocRef.Number of
            database::"Sales Invoice Header":
                begin
                    DocRef.SetTable(SalesInvoice);
                    GlobalEInvoice.SetRange("Document No.", SalesInvoice."No.");
                end;
            database::"Sales Cr.Memo Header":
                begin
                    DocRef.SetTable(SalesCrMemo);
                    GlobalEInvoice.SetRange("Document No.", SalesCrMemo."No.");
                end;
            else
                Error(InvalidRecErr, DocRef.Number);
        end;

        if ProgressIsOpen then
            Progress.Update(1, GlobalEInvoice.GetFilter("Document No."));

        if not GlobalEInvoice.FindFirst() then begin
            GetEInvoiceSetup();
            EInvSetup.TestField("Working Path");

            CreateEInvoice(DocRef, XmlDoc, FileName);
            XmlDoc.WriteTo(FileContent);

            FileStorMgmt.SaveFile(EInvSetup."Working Path" + '/outbound/' + FileName, 'text/xml', FileContent);

            GlobalEInvoice.FindFirst();
            GlobalEInvoice."File Path" := FileStorMgmt.GetCurrentPath();
            GlobalEInvoice.Modify();
            Commit();
        end;
    end;

    procedure CreateEInvoice(var DocRef: RecordRef; var XmlDoc: XmlDocument; var FileName: Text)
    var
        CompInfo: Record "Company Information";
        Country: Record "Country/Region";
        TempSalesHeader: Record "Sales Header" temporary;
        TempSalesLine: Record "Sales Line" temporary;
        SalesInvoice: Record "Sales Invoice Header";
        InvoiceLine: Record "Sales Invoice Line";
        SalesCrMemo: Record "Sales Cr.Memo Header";
        CrMemoLine: Record "Sales Cr.Memo Line";
        XmlRoot: XmlElement;
        XmlNod: XmlNode;
        FatturaElettronicaBody: XmlElement;
        DocType: Enum "Gen. Journal Document Type";
        ProgrNo: Integer;
    begin
        CompInfo.Get();
        CompInfo.TestField("Country/Region Code");
        CompInfo.TestField("Fiscal Code");

        Country.Get(CompInfo."Country/Region Code");
        Country.TestField("ISO Code");

        case DocRef.Number of
            database::"Sales Invoice Header":
                begin
                    DocRef.SetTable(SalesInvoice);
                    TempSalesHeader.TransferFields(SalesInvoice);
                    TempSalesHeader."Document Type" := TempSalesHeader."Document Type"::Invoice;
                    DocType := Enum::"Gen. Journal Document Type"::Invoice;

                    InvoiceLine.Reset();
                    InvoiceLine.SetRange("Document No.", SalesInvoice."No.");
                    if InvoiceLine.FindSet() then
                        repeat
                            TempSalesLine.TransferFields(InvoiceLine);
                            TempSalesLine.Insert();
                        until InvoiceLine.Next() = 0;
                end;
            database::"Sales Cr.Memo Header":
                begin
                    DocRef.SetTable(SalesCrMemo);
                    TempSalesHeader.TransferFields(SalesCrMemo);
                    TempSalesHeader."Document Type" := TempSalesHeader."Document Type"::"Credit Memo";
                    DocType := Enum::"Gen. Journal Document Type"::"Credit Memo";

                    CrMemoLine.Reset();
                    CrMemoLine.SetRange("Document No.", SalesCrMemo."No.");
                    if CrMemoLine.FindSet() then
                        repeat
                            TempSalesLine.TransferFields(CrMemoLine);
                            TempSalesLine.Insert();
                        until CrMemoLine.Next() = 0;
                end;
            else
                Error(InvalidRecErr, DocRef.Number);
        end;

        XmlDocument.ReadFrom(
            '<?xml version="1.0" encoding="UTF-8"?>' +
            '<p:FatturaElettronica versione="FPR12" xmlns:ds="http://www.w3.org/2000/09/xmldsig#" ' +
            'xmlns:p="http://ivaservizi.agenziaentrate.gov.it/docs/xsd/fatture/v1.2" ' +
            'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ' +
            'xsi:schemaLocation="http://ivaservizi.agenziaentrate.gov.it/docs/xsd/fatture/v1.2 http://www.fatturapa.gov.it/export/fatturazione/sdi/fatturapa/v1.2/Schema_del_file_xml_FatturaPA_versione_1.2.xsd"> ' +
            '</p:FatturaElettronica>',
            XmlDoc);

        XmlDoc.GetRoot(XmlRoot);

        XmlRoot.Add(CreateEInvoiceHeader(TempSalesHeader));

        FatturaElettronicaBody := CreateEInvoiceBody(TempSalesHeader, TempSalesLine);
        XmlRoot.Add(FatturaElettronicaBody);

        CreateEInvoicePayments(DocType, TempSalesHeader, FatturaElettronicaBody);

        ProgrNo := AssignProgressiveNo(DocRef.Number, TempSalesHeader, TempSalesLine);

        XmlRoot.AsXmlNode().SelectSingleNode('FatturaElettronicaHeader/DatiTrasmissione/ProgressivoInvio', XmlNod);
        XmlNod.AsXmlElement().Add(XmlText.Create(Format(ProgrNo, 0, 9)));

        FileName := Country."ISO Code" + '_' + CompInfo."Fiscal Code" + '_' + IntegerToString(ProgrNo).PadLeft(5, '0') + '.xml';
    end;

    procedure IntegerToString(Value: Integer) Result: Text
    var
        Dict: Text;
        Ch: Text;
    begin
        Dict := '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        Result := '';

        repeat
            Ch := Dict.Substring((Value mod 36) + 1, 1);
            Result := Ch + Result;
            Value := Round(Value / 36, 1, '<');
        until Value <= 0;
    end;

    procedure AssignProgressiveNo(DocID: Integer; var TempSalesHeader: Record "Sales Header" temporary; var TempSalesLine: Record "Sales Line" temporary) Result: Integer
    var
        ItInvSetup: Record "YNS Italy E-Invoice Setup";
        GLSetup: Record "General Ledger Setup";
        Cust: Record Customer;
        CustFiscalCode: Text;
        CustVatCountry: Text;
        CustVatNumber: Text;
    begin
        GLSetup.Get();
        GLSetup.TestField("LCY Code");

        GlobalEInvoice.Reset();
        GlobalEInvoice.SetRange("Source Type", GlobalEInvoice."Source Type"::Customer);
        GlobalEInvoice.SetRange("Document ID", DocID);
        GlobalEInvoice.SetRange("Document No.", TempSalesHeader."No.");
        if not GlobalEInvoice.FindFirst() then begin
            GlobalEInvoice.Init();
            GlobalEInvoice."Entry No." := 0;
            GlobalEInvoice."Source Type" := GlobalEInvoice."Source Type"::Customer;
            GlobalEInvoice."Document ID" := DocID;
            GlobalEInvoice."Document No." := TempSalesHeader."No.";

            GlobalEInvoice."Source No." := TempSalesHeader."Bill-to Customer No.";
            GlobalEInvoice."Source Description" := TempSalesHeader."Bill-to Name";
            GlobalEInvoice."Document Type" := TempSalesHeader."Fattura Document Type";

            GlobalEInvoice."External Document No." := TempSalesHeader."External Document No.";
            GlobalEInvoice."Posting Date" := TempSalesHeader."Posting Date";
            GlobalEInvoice."Document Date" := TempSalesHeader."Document Date";

            TempSalesLine.Reset();
            TempSalesLine.CalcSums("Amount Including VAT");
            GlobalEInvoice.Amount := TempSalesLine."Amount Including VAT";

            if TempSalesHeader."Currency Code" = '' then
                GlobalEInvoice."Currency Code" := GLSetup."LCY Code"
            else
                GlobalEInvoice."Currency Code" := TempSalesHeader."Currency Code";

            Cust.Get(TempSalesHeader."Bill-to Customer No.");
            GlobalEInvoice."PA Code" := Cust."PA Code";
            GlobalEInvoice."Source VAT Registration No." := Cust."VAT Registration No.";

            GetCustVATIdentifier(TempSalesHeader, CustFiscalCode, CustVatCountry, CustVatNumber);
            GlobalEInvoice."Source VAT Registration No." := CustVatCountry + CustVatNumber;
            GlobalEInvoice."Source Fiscal Code" := CopyStr(CustFiscalCode, 1, MaxStrLen(GlobalEInvoice."Source Fiscal Code"));

            ItInvSetup.LockTable();
            ItInvSetup.Get();
            ItInvSetup."Last Progressive No." += 1;
            ItInvSetup.Modify();

            GlobalEInvoice."Progressive No." := CopyStr(Format(ItInvSetup."Last Progressive No.", 0, 9).PadLeft(10, '0'), 1, MaxStrLen(GlobalEInvoice."Progressive No."));

            GlobalEInvoice.Insert();
        end;

        Evaluate(Result, GlobalEInvoice."Progressive No.");
    end;

    procedure GetCustVATIdentifier(var TempSalesHeader: Record "Sales Header" temporary; var FiscalCode: Text; var VatCountry: Text; var VatNumber: Text)
    var
        Cust: Record Customer;
        Country: Record "Country/Region";
    begin
        Cust.Get(TempSalesHeader."Bill-to Customer No.");

        if Cust."VAT Registration No." = '' then
            Cust.TestField("Fiscal Code");

        if Cust."VAT Registration No." > '' then begin
            if StrLen(Cust."VAT Registration No.") < 3 then
                Cust.FieldError("VAT Registration No.");

            Country.Reset();
            Country.SetRange("ISO Code", Cust."VAT Registration No.".Substring(1, 2));
            if not Country.FindFirst() then
                Cust.FieldError("VAT Registration No.");

            VatCountry := Country."ISO Code";
            VatNumber := Cust."VAT Registration No.".Substring(3);
        end;

        FiscalCode := Cust."Fiscal Code";
    end;

    procedure CreateEInvoiceHeader(var TempSalesHeader: Record "Sales Header" temporary) Result: XmlElement
    var
        Cust: Record Customer;
        CompInfo: Record "Company Information";
        Country: Record "Country/Region";
        DatiTrasmissione: XmlElement;
        IdTrasmittente: XmlElement;
        ContattiTrasmittente: XmlElement;
        CedentePrestatore: XmlElement;
        DatiAnagrafici: XmlElement;
        IdFiscaleIVA: XmlElement;
        Anagrafica: XmlElement;
        Sede: XmlElement;
        CessionarioCommittente: XmlElement;
        IscrizioneREA: XmlElement;
        CustFiscalCode: Text;
        CustVatCountry: Text;
        CustVatNumber: Text;
    begin
        CompInfo.Get();

        CompInfo.TestField("VAT Registration No.");
        if StrLen(CompInfo."VAT Registration No.") < 3 then
            CompInfo.FieldError("VAT Registration No.");

        Cust.Get(TempSalesHeader."Bill-to Customer No.");
        Cust.TestField("PA Code");

        Result := XmlElement.Create('FatturaElettronicaHeader');

        DatiTrasmissione := Functions.AppendXmlElement('DatiTrasmissione', Result);

        IdTrasmittente := Functions.AppendXmlElement('IdTrasmittente', DatiTrasmissione);

        Country.Reset();
        Country.SetRange("ISO Code", CompInfo."VAT Registration No.".Substring(1, 2));
        if not Country.FindFirst() then
            CompInfo.FieldError("VAT Registration No.");

        Functions.AppendXmlText('IdPaese', IdTrasmittente, Country."ISO Code");
        Functions.AppendXmlText('IdCodice', IdTrasmittente, CompInfo."VAT Registration No.".Substring(3));

        Functions.AppendXmlText('ProgressivoInvio', DatiTrasmissione, '');

        case StrLen(Cust."PA Code") of
            6:
                Functions.AppendXmlText('FormatoTrasmissione', DatiTrasmissione, 'FPA12');
            7:
                Functions.AppendXmlText('FormatoTrasmissione', DatiTrasmissione, 'FPR12');
            else
                Cust.FieldError("PA Code");
        end;

        Functions.AppendXmlText('CodiceDestinatario', DatiTrasmissione, Cust."PA Code");

        if (CompInfo."Phone No." > '') or (CompInfo."E-Mail" > '') then begin
            ContattiTrasmittente := Functions.AppendXmlElement('ContattiTrasmittente', DatiTrasmissione);

            if CompInfo."Phone No." > '' then
                Functions.AppendXmlText('Telefono', ContattiTrasmittente, CompInfo."Phone No.");

            if CompInfo."E-Mail" > '' then
                Functions.AppendXmlText('Email', ContattiTrasmittente, CompInfo."E-Mail");
        end;

        if Cust."YNS Send E-Invoice via PEC" then begin
            Cust.TestField("PEC E-Mail Address");
            Functions.AppendXmlText('PECDestinatario', DatiTrasmissione, cust."PEC E-Mail Address");
        end;

        CedentePrestatore := Functions.AppendXmlElement('CedentePrestatore', Result);

        DatiAnagrafici := Functions.AppendXmlElement('DatiAnagrafici', CedentePrestatore);

        IdFiscaleIVA := Functions.AppendXmlElement('IdFiscaleIVA', DatiAnagrafici);

        Country.Reset();
        Country.SetRange("ISO Code", CompInfo."VAT Registration No.".Substring(1, 2));
        if not Country.FindFirst() then
            CompInfo.FieldError("VAT Registration No.");

        Functions.AppendXmlText('IdPaese', IdFiscaleIVA, Country."ISO Code");
        Functions.AppendXmlText('IdCodice', IdFiscaleIVA, CompInfo."VAT Registration No.".Substring(3));

        if CompInfo."Fiscal Code" > '' then
            Functions.AppendXmlText('CodiceFiscale', DatiAnagrafici, CompInfo."Fiscal Code");

        Anagrafica := Functions.AppendXmlElement('Anagrafica', DatiAnagrafici);

        CompInfo.TestField(Name);
        Functions.AppendXmlText('Denominazione', Anagrafica, CopyStr(CompInfo.Name, 1, 80));

        CompInfo.TestField("Company Type");
        Functions.AppendXmlText('RegimeFiscale', DatiAnagrafici, 'RF' + CompInfo."Company Type");

        Sede := Functions.AppendXmlElement('Sede', CedentePrestatore);

        CompInfo.TestField(Address);
        Functions.AppendXmlText('Indirizzo', Sede, CopyStr(CompInfo.Address, 1, 60));

        CompInfo.TestField("Post Code");
        Functions.AppendXmlText('CAP', Sede, CopyStr(CompInfo."Post Code", 1, 5));

        CompInfo.TestField(City);
        Functions.AppendXmlText('Comune', Sede, CopyStr(CompInfo.City, 1, 60));

        CompInfo.TestField("Country/Region Code");
        Country.Get(CompInfo."Country/Region Code");
        Country.TestField("ISO Code");
        if Country."ISO Code" = 'IT' then begin
            CompInfo.TestField(County);
            Functions.AppendXmlText('Provincia', Sede, CopyStr(CompInfo.County, 1, 2));
        end;

        Functions.AppendXmlText('Nazione', Sede, Country."ISO Code");

        if CompInfo."REA No." > '' then begin
            IscrizioneREA := Functions.AppendXmlElement('IscrizioneREA', CedentePrestatore);

            CompInfo.TestField("Registry Office Province");
            Functions.AppendXmlText('Ufficio', IscrizioneREA, CompInfo."Registry Office Province");

            Functions.AppendXmlText('NumeroREA', IscrizioneREA, CompInfo."REA No.");

            if CompInfo."Liquidation Status" = CompInfo."Liquidation Status"::"Not in Liquidation" then
                Functions.AppendXmlText('StatoLiquidazione', IscrizioneREA, 'LN')
            else
                Functions.AppendXmlText('StatoLiquidazione', IscrizioneREA, 'LS');
        end;

        CessionarioCommittente := Functions.AppendXmlElement('CessionarioCommittente', Result);

        DatiAnagrafici := Functions.AppendXmlElement('DatiAnagrafici', CessionarioCommittente);

        IdFiscaleIVA := Functions.AppendXmlElement('IdFiscaleIVA', DatiAnagrafici);

        GetCustVATIdentifier(TempSalesHeader, CustFiscalCode, CustVatCountry, CustVatNumber);

        if CustVatNumber > '' then begin
            Functions.AppendXmlText('IdPaese', IdFiscaleIVA, CustVatCountry);
            Functions.AppendXmlText('IdCodice', IdFiscaleIVA, CustVatNumber);
        end;

        if CustFiscalCode > '' then
            Functions.AppendXmlText('CodiceFiscale', DatiAnagrafici, CustFiscalCode);

        Anagrafica := Functions.AppendXmlElement('Anagrafica', DatiAnagrafici);

        Cust.TestField(Name);
        Functions.AppendXmlText('Denominazione', Anagrafica, CopyStr(Cust.Name, 1, 80));

        Sede := Functions.AppendXmlElement('Sede', CessionarioCommittente);

        Cust.TestField(Address);
        Functions.AppendXmlText('Indirizzo', Sede, CopyStr(Cust.Address, 1, 60));

        Cust.TestField("Post Code");
        Functions.AppendXmlText('CAP', Sede, CopyStr(Cust."Post Code", 1, 5));

        Cust.TestField(City);
        Functions.AppendXmlText('Comune', Sede, CopyStr(Cust.City, 1, 60));

        Cust.TestField("Country/Region Code");
        Country.Get(Cust."Country/Region Code");
        Country.TestField("ISO Code");
        if Country."ISO Code" = 'IT' then begin
            Cust.TestField(County);
            Functions.AppendXmlText('Provincia', Sede, CopyStr(Cust.County, 1, 2));
        end;

        Functions.AppendXmlText('Nazione', Sede, Country."ISO Code");
    end;

    procedure CreateEInvoiceBody(var TempSalesHeader: Record "Sales Header" temporary;
        var TempSalesLine: Record "Sales Line" temporary) Result: XmlElement
    var
        GLSetup: Record "General Ledger Setup";
        DatiGenerali: XmlElement;
        DatiGeneraliDocumento: XmlElement;
        CurrencyFactor: Decimal;
        Amt: Decimal;
        I: Integer;
    begin
        GetEInvoiceSetup();

        Result := XmlElement.Create('FatturaElettronicaBody');

        DatiGenerali := Functions.AppendXmlElement('DatiGenerali', Result);

        DatiGeneraliDocumento := Functions.AppendXmlElement('DatiGeneraliDocumento', DatiGenerali);

        TempSalesHeader.TestField("Fattura Document Type");
        Functions.AppendXmlText('TipoDocumento', DatiGeneraliDocumento, TempSalesHeader."Fattura Document Type");

        GLSetup.Get();
        GLSetup.TestField("LCY Code");
        Functions.AppendXmlText('Divisa', DatiGeneraliDocumento, GLSetup."LCY Code");

        CurrencyFactor := TempSalesHeader."Currency Factor";
        if CurrencyFactor = 0 then CurrencyFactor := 1;

        Functions.AppendXmlDate('Data', DatiGeneraliDocumento, TempSalesHeader."Operation Occurred Date");
        Functions.AppendXmlText('Numero', DatiGeneraliDocumento, DocumentNoStripChars(TempSalesHeader."No."));

        TempSalesLine.Reset();
        TempSalesLine.CalcSums("Amount Including VAT");
        Amt := Round(TempSalesLine."Amount Including VAT" / CurrencyFactor, 0.01);
        Functions.AppendXmlDecimal('ImportoTotaleDocumento', DatiGeneraliDocumento, Amt, 2);

        I := 1;
        TempSalesLine.Reset();
        if TempSalesLine.FindSet() then
            repeat
                if (not EInvSetup."Send Description Lines") and (TempSalesLine.Type = TempSalesLine.Type::" ") then
                    TempSalesLine.Delete()
                else begin
                    TempSalesLine."Appl.-from Item Entry" := I;
                    TempSalesLine.Modify();
                    I += 1;
                end;
            until TempSalesLine.Next() = 0;

        CreateEInvoiceShipments(TempSalesHeader, TempSalesLine, DatiGenerali);

        Result.Add(CreateEInvoiceLines(TempSalesHeader, TempSalesLine, CurrencyFactor));
    end;

    procedure CreateEInvoiceShipments(var TempSalesHeader: Record "Sales Header" temporary;
        var TempSalesLine: Record "Sales Line" temporary;
        var Parent: XmlElement
    )
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        DatiDDT: XmlElement;
    begin
        TempSalesLine.Reset();
        TempSalesLine.SetCurrentKey("Shipment No.", "Appl.-from Item Entry");
        TempSalesLine.SetFilter("Shipment No.", '>''''');
        TempSalesLine.SetFilter(Type, '<>%1', TempSalesLine.Type::" ");
        if TempSalesLine.FindSet() then
            repeat
                TempSalesLine.SetRange("Shipment No.", TempSalesLine."Shipment No.");

                DatiDDT := Functions.AppendXmlElement('DatiDDT', Parent);
                Functions.AppendXmlText('NumeroDDT', DatiDDT, DocumentNoStripChars(TempSalesLine."Shipment No."));

                SalesShipmentHeader.Get(TempSalesLine."Shipment No.");
                Functions.AppendXmlDate('DataDDT', DatiDDT, SalesShipmentHeader."Posting Date");

                repeat
                    Functions.AppendXmlInteger('RiferimentoNumeroLinea', DatiDDT, TempSalesLine."Appl.-from Item Entry");
                until TempSalesLine.Next() = 0;

                TempSalesLine.SetRange("Shipment No.");
            until TempSalesLine.Next() = 0;

        OnAfterWriteEInvoicePart('2.1.8', Parent, TempSalesHeader, TempSalesLine);
    end;

    procedure CreateEInvoicePayments(DocType: Enum "Gen. Journal Document Type"; var TempSalesHeader: Record "Sales Header" temporary; var Parent: XmlElement)
    var
        CustLedg: Record "Cust. Ledger Entry";
        PayMeth: Record "Payment Method";
        DatiPagamento: XmlElement;
        DettaglioPagamento: XmlElement;
        CondPag: Text;
    begin
        CustLedg.Reset();
        CustLedg.SetRange("Customer No.", TempSalesHeader."Bill-to Customer No.");
        CustLedg.SetRange("Document Type", DocType);
        CustLedg.SetRange("Document No.", TempSalesHeader."No.");

        CondPag := 'TP02';
        if CustLedg.Count > 1 then
            CondPag := 'TP01';

        CustLedg.SetAutoCalcFields("Original Amt. (LCY)");
        if CustLedg.FindSet() then
            repeat
                DatiPagamento := Functions.AppendXmlElement('DatiPagamento', Parent);
                Functions.AppendXmlText('CondizioniPagamento', DatiPagamento, CondPag);

                DettaglioPagamento := Functions.AppendXmlElement('DettaglioPagamento', DatiPagamento);

                CustLedg.TestField("Payment Method Code");
                PayMeth.Get(CustLedg."Payment Method Code");
                PayMeth.TestField("Fattura PA Payment Method");
                Functions.AppendXmlText('ModalitaPagamento', DettaglioPagamento, PayMeth."Fattura PA Payment Method");

                Functions.AppendXmlDate('DataScadenzaPagamento', DettaglioPagamento, CustLedg."Due Date");

                Functions.AppendXmlDecimal('ImportoPagamento', DettaglioPagamento, Round(CustLedg."Original Amt. (LCY)", 0.01), 2);
            until CustLedg.Next() = 0;
    end;

    procedure ConvertUoMCode(UoMCode: Text; CustomerNo: Text): Text
    var
        ExRefLine: Record "YNS Doc. Exchange Ref. Line";
    begin
        GetEInvoiceSetup();
        if EInvSetup."Sending Exchange Reference" > '' then begin
            ExRefLine.Reset();
            ExRefLine.SetRange("Reference Code", EInvSetup."Sending Exchange Reference");
            ExRefLine.SetRange("Reference Type", ExRefLine."Reference Type"::Table);
            ExRefLine.SetRange("Table ID", Database::"Unit of Measure");
            ExRefLine.SetRange("Primary Key 1", UoMCode);
            ExRefLine.SetRange("Source Type", ExRefLine."Source Type"::Customer);
            ExRefLine.SetRange("Source No.", CustomerNo);
            if ExRefLine.FindFirst() then
                exit(ExRefLine."Value 1");

            ExRefLine.SetRange("Source Type");
            ExRefLine.SetRange("Source No.");
            if ExRefLine.FindFirst() then
                exit(ExRefLine."Value 1");
        end;
        exit(UoMCode);
    end;

    procedure CreateEInvoiceLines(var TempSalesHeader: Record "Sales Header" temporary;
        var TempSalesLine: Record "Sales Line" temporary; CurrencyFactor: Decimal) Result: XmlElement
    var
        VATSetup: Record "VAT Posting Setup";
        VATIdent: Record "VAT Identifier";
        ItemRef: Record "Item Reference";
        TempSummary: Record "Sales Line" temporary;
        DettaglioLinee: XmlElement;
        ScontoMaggiorazione: XmlElement;
        CodiceArticolo: XmlElement;
        DatiRiepilogo: XmlElement;
        BaseAmt: Decimal;
        VatAmt: Decimal;
        UnitAmt: Decimal;
        ListAmt: Decimal;
        Qty: Decimal;
        MapUoM: Dictionary of [Text, Text];
        TempStr: Text;
    begin
        GetEInvoiceSetup();

        Result := XmlElement.Create('DatiBeniServizi');

        TempSalesLine.Reset();
        if TempSalesLine.FindSet() then
            repeat
                DettaglioLinee := Functions.AppendXmlElement('DettaglioLinee', Result);

                Functions.AppendXmlInteger('NumeroLinea', DettaglioLinee, TempSalesLine."Appl.-from Item Entry");

                if TempSalesLine.Type = TempSalesLine.Type::Item then begin
                    if EInvSetup."Item No. Tag Name" > '' then begin
                        CodiceArticolo := Functions.AppendXmlElement('CodiceArticolo', DettaglioLinee);
                        Functions.AppendXmlText('CodiceTipo', CodiceArticolo, EInvSetup."Item No. Tag Name");
                        Functions.AppendXmlText('CodiceValore', CodiceArticolo, TempSalesLine."No.");
                    end;

                    if EInvSetup."Item Barcode Tag Name" > '' then begin
                        ItemRef.Reset();
                        ItemRef.SetRange("Item No.", TempSalesLine."No.");
                        ItemRef.SetRange("Variant Code", TempSalesLine."Variant Code");
                        ItemRef.SetRange("Unit of Measure", TempSalesLine."Unit of Measure Code");
                        ItemRef.SetRange("Reference Type", ItemRef."Reference Type"::"Bar Code");
                        if ItemRef.FindFirst() then begin
                            CodiceArticolo := Functions.AppendXmlElement('CodiceArticolo', DettaglioLinee);
                            Functions.AppendXmlText('CodiceTipo', CodiceArticolo, EInvSetup."Item Barcode Tag Name");
                            Functions.AppendXmlText('CodiceValore', CodiceArticolo, ItemRef."Reference No.");
                        end;
                    end;

                    OnAfterWriteEInvoiceLinesPart('2.2.1.3', DettaglioLinee, TempSalesHeader, TempSalesLine);
                end;

                if TempSalesLine.Description.Trim() = '' then
                    Functions.AppendXmlText('Descrizione', DettaglioLinee, '.')
                else
                    Functions.AppendXmlText('Descrizione', DettaglioLinee, TempSalesLine.Description);

                Qty := 0;
                if TempSalesLine.Quantity <> 0 then begin
                    Qty := Round(TempSalesLine.Quantity, 0.00000001);
                    Functions.AppendXmlDecimal('Quantita', DettaglioLinee, Qty, 8);
                end;

                if TempSalesLine."Unit of Measure Code" > '' then begin
                    if not MapUoM.ContainsKey(TempSalesLine."Unit of Measure Code") then
                        MapUoM.Add(TempSalesLine."Unit of Measure Code", ConvertUoMCode(TempSalesLine."Unit of Measure Code", TempSalesHeader."Bill-to Customer No."));

                    MapUoM.Get(TempSalesLine."Unit of Measure Code", TempStr);
                    Functions.AppendXmlText('UnitaMisura', DettaglioLinee, TempStr);
                end;

                ListAmt := Round(TempSalesLine."Unit Price" / CurrencyFactor, 0.00000001);
                Functions.AppendXmlDecimal('PrezzoUnitario', DettaglioLinee, ListAmt, 8);

                BaseAmt := TempSalesLine.Amount;
                if TempSalesHeader."Prices Including VAT" then
                    BaseAmt := BaseAmt / (100 + TempSalesLine."VAT %") * 100;
                VatAmt := Round((TempSalesLine."Amount Including VAT" - BaseAmt) / CurrencyFactor, 0.01);
                BaseAmt := BaseAmt / CurrencyFactor;

                UnitAmt := BaseAmt;
                if Qty <> 0 then
                    UnitAmt := BaseAmt / Qty;
                UnitAmt := Round(UnitAmt, 0.00000001);

                if UnitAmt > ListAmt then begin
                    ScontoMaggiorazione := Functions.AppendXmlElement('ScontoMaggiorazione', DettaglioLinee);
                    Functions.AppendXmlText('Tipo', ScontoMaggiorazione, 'MG');
                    Functions.AppendXmlDecimal('Importo', ScontoMaggiorazione, UnitAmt - ListAmt, 8);
                end;

                if UnitAmt < ListAmt then begin
                    ScontoMaggiorazione := Functions.AppendXmlElement('ScontoMaggiorazione', DettaglioLinee);
                    Functions.AppendXmlText('Tipo', ScontoMaggiorazione, 'SC');
                    Functions.AppendXmlDecimal('Importo', ScontoMaggiorazione, ListAmt - UnitAmt, 8);
                end;

                BaseAmt := Round(BaseAmt, 0.01);
                Functions.AppendXmlDecimal('PrezzoTotale', DettaglioLinee, BaseAmt, 2);

                Functions.AppendXmlDecimal('AliquotaIVA', DettaglioLinee, Round(TempSalesLine."VAT %", 0.01), 2);

                if TempSalesLine."VAT %" = 0 then begin
                    if TempSalesLine.Type = TempSalesLine.Type::" " then begin
                        EInvSetup.TestField("Description Lines VAT Nature");
                        EInvSetup.TestField("Descr. Lines VAT Reference");
                        Functions.AppendXmlText('Natura', DettaglioLinee, EInvSetup."Description Lines VAT Nature");

                        AddLineToSummary(TempSalesLine, TempSummary, BaseAmt, VatAmt, EInvSetup."Description Lines VAT Nature", EInvSetup."Descr. Lines VAT Reference");
                    end else begin
                        VATSetup.Get(TempSalesLine."VAT Bus. Posting Group", TempSalesLine."VAT Prod. Posting Group");
                        VATSetup.TestField("VAT Transaction Nature");
                        VATSetup.TestField("VAT Identifier");
                        Functions.AppendXmlText('Natura', DettaglioLinee, VATSetup."VAT Transaction Nature");

                        VATIdent.Get(VATSetup."VAT Identifier");
                        AddLineToSummary(TempSalesLine, TempSummary, BaseAmt, VatAmt, VATSetup."VAT Transaction Nature", VATIdent.Description);
                    end
                end else
                    AddLineToSummary(TempSalesLine, TempSummary, BaseAmt, VatAmt, '', '');
            until TempSalesLine.Next() = 0;

        TempSummary.Reset();
        if TempSummary.FindSet() then
            repeat
                DatiRiepilogo := Functions.AppendXmlElement('DatiRiepilogo', Result);

                Functions.AppendXmlDecimal('AliquotaIVA', DatiRiepilogo, Round(TempSummary."VAT %", 0.01), 2);
                if TempSummary."VAT %" = 0 then
                    Functions.AppendXmlText('Natura', DatiRiepilogo, TempSummary."No.");
                Functions.AppendXmlDecimal('ImponibileImporto', DatiRiepilogo, Round(TempSummary.Amount, 0.01), 2);
                Functions.AppendXmlDecimal('Imposta', DatiRiepilogo, Round(TempSummary."VAT Base Amount", 0.01), 2);
                Functions.AppendXmlText('EsigibilitaIVA', DatiRiepilogo, 'I');
                if TempSummary."VAT %" = 0 then
                    Functions.AppendXmlText('RiferimentoNormativo', DatiRiepilogo, TempSummary.Description);
            until TempSummary.Next() = 0;
    end;

    local procedure AddLineToSummary(var TempSalesLine: Record "Sales Line" temporary;
        var TempSummary: Record "Sales Line" temporary;
        BaseAmount: Decimal; VatAmount: Decimal; Nature: Code[4]; Reference: Text[100])
    begin
        TempSummary.Reset();
        if TempSalesLine.Type = TempSalesLine.Type::" " then
            TempSummary.SetRange(Type, TempSummary.Type::" ")
        else
            TempSummary.SetRange(Type, TempSummary.Type::"G/L Account");
        TempSummary.SetRange("VAT %", TempSalesLine."VAT %");
        TempSummary.SetRange("No.", Nature);
        TempSummary.SetRange(Description, Reference);

        if not TempSummary.FindFirst() then begin
            TempSummary.Init();
            TempSummary."Line No." := TempSalesLine."Line No.";
            if TempSalesLine.Type = TempSalesLine.Type::" " then
                TempSummary.Type := TempSummary.Type::" "
            else
                TempSummary.Type := TempSummary.Type::"G/L Account";
            TempSummary."VAT %" := TempSalesLine."VAT %";
            TempSummary."No." := Nature;
            TempSummary.Description := Reference;
            TempSummary.Insert();
        end;

        TempSummary.Amount += BaseAmount;
        TempSummary."VAT Base Amount" += VatAmount;
        TempSummary.Modify();
    end;

    procedure DocumentNoStripChars(DocNo: Text) Result: Text
    var
        I: Integer;
    begin
        Result := DocNo;

        GetEInvoiceSetup();
        if EInvSetup."Document No. Strip Chars" > '' then
            for I := 1 to StrLen(EInvSetup."Document No. Strip Chars") do
                Result := Result.Replace(EInvSetup."Document No. Strip Chars"[I], '');
    end;

    procedure UploadStylesheet()
    var
        TitleLbl: Label 'Invoice Stylesheet';
        FileName: Text;
        FileContent: Text;
    begin
        GetEInvoiceSetup();
        EInvSetup.TestField("Working Path");

        if Functions.UploadText(TitleLbl, 'XSLT File|*.xsl', FileName, FileContent) then begin
            FileStorMgmt.SaveFile(EInvSetup."Working Path" + '/' + FileName, 'text/xml', FileContent);
            EInvSetup."Stylesheet Path" := FileStorMgmt.GetCurrentPath();
            EInvSetup.Modify();
        end;
    end;

    procedure CreateVendorFromInvoice(var ItInvoice: Record "YNS Italy E-Invoice")
    var
        Vendor: Record Vendor;
        XmlDoc: XmlDocument;
        XmlRoot: XmlElement;
        XmlRootNode: XmlNode;
        XmlNod: XmlNode;
        VendorNotExistQst: Label 'Vendor %1 not exists, create it?';
    begin
        TryIdentifyPurchaseInvoice(ItInvoice);
        if ItInvoice."Source No." > '' then
            exit;

        if not Confirm(VendorNotExistQst, false, ItInvoice."Source Description") then
            exit;

        ItInvoice.TestField("File Path");
        XmlDocument.ReadFrom(FileStorMgmt.GetFileAsText(ItInvoice."File Path"), XmlDoc);
        XmlDoc.GetRoot(XmlRoot);
        XmlRootNode := XmlRoot.AsXmlNode();

        Vendor.Init();
        Vendor."No." := '';

        XmlRootNode.SelectSingleNode('FatturaElettronicaHeader/CedentePrestatore/DatiAnagrafici/Anagrafica', XmlNod);
        Vendor.Name := CopyStr(Functions.GetXmlChildAsText('Denominazione', XmlNod), 1, MaxStrLen(Vendor.Name));
        if Vendor.Name = '' then
            Vendor.Name := CopyStr(Functions.GetXmlChildAsText('Nome', XmlNod) + ' ' +
                Functions.GetXmlChildAsText('Cognome', XmlNod), 1, MaxStrLen(Vendor.Name));
        Vendor.Validate(Name);

        XmlRootNode.SelectSingleNode('FatturaElettronicaHeader/CedentePrestatore/Sede', XmlNod);
        Vendor.Validate("Country/Region Code", CopyStr(Functions.GetXmlChildAsText('Nazione', XmlNod), 1, MaxStrLen(Vendor."Country/Region Code")));
        Vendor.Address := CopyStr(Functions.GetXmlChildAsText('Indirizzo', XmlNod), 1, MaxStrLen(Vendor.Address));
        Vendor."Post Code" := CopyStr(Functions.GetXmlChildAsText('CAP', XmlNod), 1, MaxStrLen(Vendor."Post Code"));
        Vendor.City := CopyStr(Functions.GetXmlChildAsText('Comune', XmlNod), 1, MaxStrLen(Vendor."City"));
        Vendor.County := CopyStr(Functions.GetXmlChildAsText('Provincia', XmlNod), 1, MaxStrLen(Vendor."County"));

        if XmlRootNode.SelectSingleNode('FatturaElettronicaHeader/CedentePrestatore/DatiAnagrafici/IdFiscaleIVA', XmlNod) then
            Vendor."VAT Registration No." := CopyStr(Functions.GetXmlChildAsText('IdPaese', XmlNod) +
                Functions.GetXmlChildAsText('IdCodice', XmlNod), 1, MaxStrLen(Vendor."VAT Registration No."));

        XmlRootNode.SelectSingleNode('FatturaElettronicaHeader/CedentePrestatore/DatiAnagrafici', XmlNod);
        Vendor."Fiscal Code" := CopyStr(Functions.GetXmlChildAsText('CodiceFiscale', XmlNod), 1, MaxStrLen(Vendor."Fiscal Code"));
        Vendor.Insert(true);

        TryIdentifyPurchaseInvoice(ItInvoice);
        Commit();

        Page.Run(page::"Vendor Card", Vendor);
    end;

    procedure CreateDocuementFromInvoice(var ItInvoice: Record "YNS Italy E-Invoice")
    var
        PurchHead: Record "Purchase Header";
        XmlDoc: XmlDocument;
        XmlRoot: XmlElement;
        XmlRootNode: XmlNode;
        XmlLst: XmlNodeList;
        FatturaElettronicaBody: XmlNode;
        DatiGeneraliDocumento: XmlNode;
        TipoDocumento: Text;
        DocumentType: Enum "Purchase Document Type";
        TotalAmount: Decimal;
        CreateDocQst: Label 'Create document %1?';
    begin
        TryIdentifyPurchaseInvoice(ItInvoice);
        if ItInvoice."Document No." > '' then
            exit;

        if not Confirm(CreateDocQst, false, ItInvoice."External Document No.") then
            exit;

        ItInvoice.TestField("File Path");
        XmlDocument.ReadFrom(FileStorMgmt.GetFileAsText(ItInvoice."File Path"), XmlDoc);
        XmlDoc.GetRoot(XmlRoot);
        XmlRootNode := XmlRoot.AsXmlNode();

        XmlRootNode.SelectNodes('FatturaElettronicaBody', XmlLst);
        XmlLst.Get(ItInvoice."File Lot No.", FatturaElettronicaBody);

        FatturaElettronicaBody.SelectSingleNode('DatiGenerali/DatiGeneraliDocumento', DatiGeneraliDocumento);
        TipoDocumento := Functions.GetXmlChildAsText('TipoDocumento', DatiGeneraliDocumento);
        TotalAmount := Functions.GetXmlChildAsDecimal('ImportoTotaleDocumento', DatiGeneraliDocumento);

        DocumentType := DocumentType::Invoice;
        if (TipoDocumento = 'TD04') or (TotalAmount < 0) then
            DocumentType := DocumentType::"Credit Memo";

        PurchHead.Init();
        PurchHead."Document Type" := DocumentType;
        PurchHead."No." := '';
        PurchHead.Insert(true);

        PurchHead.Validate("Buy-from Vendor No.", ItInvoice."Source No.");
        PurchHead."Document Date" := Functions.GetXmlChildAsDate('Data', DatiGeneraliDocumento);

        if DocumentType = DocumentType::Invoice then
            PurchHead."Vendor Invoice No." := CopyStr(Functions.GetXmlChildAsText('Numero', DatiGeneraliDocumento), 1, MaxStrLen(PurchHead."Vendor Invoice No."))
        else
            PurchHead."Vendor Cr. Memo No." := CopyStr(Functions.GetXmlChildAsText('Numero', DatiGeneraliDocumento), 1, MaxStrLen(PurchHead."Vendor Cr. Memo No."));

        PurchHead."Check Total" := Abs(TotalAmount);
        PurchHead.Modify(true);
        Commit();

        if DocumentType = DocumentType::Invoice then
            page.Run(Page::"Purchase Invoice", PurchHead)
        else
            page.Run(Page::"Purchase Credit Memo", PurchHead);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterPostPurchaseDoc', '', false, false)]
    local procedure OnAfterPostPurchaseDoc(var PurchaseHeader: Record "Purchase Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PurchRcpHdrNo: Code[20]; RetShptHdrNo: Code[20]; PurchInvHdrNo: Code[20]; PurchCrMemoHdrNo: Code[20]; CommitIsSupressed: Boolean)
    var
        ItInvoice: Record "YNS Italy E-Invoice";
    begin
        if PurchaseHeader."Document Type" in [Enum::"Purchase Document Type"::Invoice, Enum::"Purchase Document Type"::"Credit Memo"] then begin
            ItInvoice.Reset();
            ItInvoice.SetRange("Source Type", ItInvoice."Source Type"::Vendor);
            ItInvoice.SetRange("Source No.", PurchaseHeader."Pay-to Vendor No.");
            ItInvoice.SetRange("Document Date", PurchaseHeader."Document Date");
            if PurchaseHeader."Document Type" = Enum::"Purchase Document Type"::Invoice then
                ItInvoice.SetRange("External Document No.", PurchaseHeader."Vendor Invoice No.")
            else
                ItInvoice.SetRange("External Document No.", PurchaseHeader."Vendor Cr. Memo No.");
            ItInvoice.SetRange("Document No.", '');

            if ItInvoice.FindFirst() then begin
                ItInvoice."Document No." := PurchaseHeader."Last Posting No.";
                ItInvoice."Posting Date" := PurchaseHeader."Posting Date";
                if PurchaseHeader."Document Type" = Enum::"Purchase Document Type"::Invoice then
                    ItInvoice."Document ID" := Database::"Purch. Inv. Header"
                else
                    ItInvoice."Document ID" := Database::"Purch. Cr. Memo Hdr.";
                ItInvoice.Modify();
            end;
        end;
    end;

    [InternalEvent(false)]
    local procedure OnAfterWriteEInvoicePart(PartNumber: Text; var Parent: XmlElement;
        var TempSalesHeader: Record "Sales Header" temporary;
        var TempSalesLine: Record "Sales Line" temporary)
    begin
    end;

    [InternalEvent(false)]
    local procedure OnAfterWriteEInvoiceLinesPart(PartNumber: Text; var Parent: XmlElement;
        var TempSalesHeader: Record "Sales Header" temporary;
        var TempSalesLine: Record "Sales Line" temporary)
    begin
    end;
}
#endif