#if ITXX002A
codeunit 60009 "YNS Italy E-Invoice Format" implements "YNS Doc. Exchange Format"
{
    procedure GetManualProcessOptions(var ExProfile: Record "YNS Doc. Exchange Profile"; var ListSelect: Page "YNS List Select"; var DocRefs: RecordRef)
    var
        ExportSdiLbl: label 'Export Italy E-Invoice via %1';
        ExTransport: Interface "YNS Doc. Exchange Transport";
    begin
        ExTransport := ExProfile."Exchange Transport";

        case DocRefs.Number of
            Database::"Sales Invoice Header",
            Database::"Sales Cr.Memo Header":
                begin
                    ListSelect.AddOption(ExProfile.Code, StrSubstNo(ExportSdiLbl, ExTransport.GetDescription()));
                    ListSelect.SetTag('EXPORT');
                end;
        end;
    end;

    procedure Process(var ExProfile: Record "YNS Doc. Exchange Profile"; ProcessAction: Text; var DocRefs: RecordRef)
    var
        ExTransport: Interface "YNS Doc. Exchange Transport";
        XmlDoc: XmlDocument;
        FileName: Text;
        FileContent: Text;
    begin
        ExTransport := ExProfile."Exchange Transport";

        case ProcessAction of
            'EXPORT':
                begin
                    DocRefs.FindFirst();
                    CreateEInvoice(DocRefs, XmlDoc, FileName);
                    XmlDoc.WriteTo(FileContent);
                    ExTransport.Send(FileName, 'application/xml', FileContent);
                end;
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
        XmlNsMgr: XmlNamespaceManager;
        XmlNod: XmlNode;
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
                end;
            database::"Sales Cr.Memo Header":
                begin
                    DocRef.SetTable(SalesCrMemo);
                    TempSalesHeader.TransferFields(SalesCrMemo);
                    TempSalesHeader."Document Type" := TempSalesHeader."Document Type"::"Credit Memo";
                end;
        end;

        XmlDocument.ReadFrom(
            '<?xml version="1.0" encoding="UTF-8"?>' +
            '<p:FatturaElettronica versione="FPR12" xmlns:ds="http://www.w3.org/2000/09/xmldsig#" ' +
            'xmlns:p="http://ivaservizi.agenziaentrate.gov.it/docs/xsd/fatture/v1.2" ' +
            'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ' +
            'xsi:schemaLocation="http://ivaservizi.agenziaentrate.gov.it/docs/xsd/fatture/v1.2 http://www.fatturapa.gov.it/export/fatturazione/sdi/fatturapa/v1.2/Schema_del_file_xml_FatturaPA_versione_1.2.xsd"> ' +
            '</p:FatturaElettronica>',
            XmlDoc);

        XmlNsMgr.NameTable(XmlDoc.NameTable);
        XmlNsMgr.AddNamespace('p', 'http://ivaservizi.agenziaentrate.gov.it/docs/xsd/fatture/v1.2');

        XmlDoc.SelectSingleNode('p:FatturaElettronica', XmlNsMgr, XmlNod);
        XmlNod.AsXmlElement().Add(CreateEInvoiceHeader(TempSalesHeader));

        XmlDoc.SelectSingleNode('/p:FatturaElettronica/FatturaElettronicaHeader/DatiTrasmissione/ProgressivoInvio', XmlNsMgr, XmlNod);
        XmlNod.AsXmlElement().Add(XmlText.Create(AssignProgressiveNo(DocRef.Number, TempSalesHeader)));

        FileName := Country."ISO Code" + '_' + CompInfo."Fiscal Code" + '_' + 'xx' + '.xml';
    end;

    procedure AssignProgressiveNo(DocID: Integer; var TempSalesHeader: Record "Sales Header" temporary): Text
    var
        DocXEntry: Record "YNS Doc. Exchange Entry";
        DocXMeta: Record "YNS Doc. Exchange Metadata";
        ItInvSetup: Record "YNS Italy E-Invoice Setup";
    begin
        DocXEntry.Reset();
        DocXEntry.SetRange("Exchange Format", Enum::"YNS Doc. Exchange Format"::"YNS Italy E-Invoice Format");
        DocXEntry.SetRange(Direction, DocXEntry.Direction::Outbound);
        DocXEntry.SetRange("Document ID", DocID);
        DocXEntry.SetRange("Document No.", TempSalesHeader."No.");
        if not DocXEntry.FindFirst() then begin
            DocXEntry.Init();
            DocXEntry."Entry No." := 0;
            DocXEntry."Exchange Format" := Enum::"YNS Doc. Exchange Format"::"YNS Italy E-Invoice Format";
            DocXEntry.Direction := DocXEntry.Direction::Outbound;
            DocXEntry."Document ID" := DocID;
            DocXEntry."Document No." := TempSalesHeader."No.";
            DocXEntry.Insert();
        end;

        if not DocXMeta.Get(DocXEntry."Entry No.", 0, 'SDI_PROGRESSIVE_NO') then begin
            ItInvSetup.LockTable();
            ItInvSetup.Get();
            ItInvSetup."Last Progressive No." += 1;
            ItInvSetup.Modify();

            DocXMeta.Init();
            DocXMeta."Entry No." := DocXEntry."Entry No.";
            DocXMeta."Metadata ID" := 'SDI_PROGRESSIVE_NO';
            DocXMeta."Metadata Value" := Format(ItInvSetup."Last Progressive No.", 0, 9);
            DocXMeta.Insert();

            Commit();
        end;

        exit(DocXMeta."Metadata Value");
    end;

    local procedure AppendXmlElement(Name: Text; Parent: XmlElement) Result: XmlElement
    begin
        Result := XmlElement.Create(Name);
        Parent.Add(Result);
    end;

    local procedure AppendXmlText(Name: Text; Parent: XmlElement; Content: Text)
    var
        XmlEl: XmlElement;
    begin
        XmlEl := XmlElement.Create(Name);
        XmlEl.Add(XmlText.Create(Content));
        Parent.Add(XmlEl);
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
    begin
        CompInfo.Get();

        CompInfo.TestField("VAT Registration No.");
        if StrLen(CompInfo."VAT Registration No.") < 3 then
            CompInfo.FieldError("VAT Registration No.");

        Cust.Get(TempSalesHeader."Bill-to Customer No.");
        Cust.TestField("PA Code");

        Result := XmlElement.Create('FatturaElettronicaHeader');

        DatiTrasmissione := AppendXmlElement('DatiTrasmissione', Result);

        IdTrasmittente := AppendXmlElement('IdTrasmittente', DatiTrasmissione);

        Country.Reset();
        Country.SetRange("ISO Code", CompInfo."VAT Registration No.".Substring(1, 2));
        if not Country.FindFirst() then
            CompInfo.FieldError("VAT Registration No.");

        AppendXmlText('IdPaese', IdTrasmittente, Country."ISO Code");
        AppendXmlText('IdCodice', IdTrasmittente, CompInfo."VAT Registration No.".Substring(3));

        AppendXmlText('ProgressivoInvio', DatiTrasmissione, '');

        case StrLen(Cust."PA Code") of
            6:
                AppendXmlText('FormatoTrasmissione', DatiTrasmissione, 'FPA12');
            7:
                AppendXmlText('FormatoTrasmissione', DatiTrasmissione, 'FPR12');
            else
                Cust.FieldError("PA Code");
        end;

        AppendXmlText('CodiceDestinatario', DatiTrasmissione, Cust."PA Code");

        if (CompInfo."Phone No." > '') or (CompInfo."E-Mail" > '') then begin
            ContattiTrasmittente := AppendXmlElement('ContattiTrasmittente', DatiTrasmissione);

            if CompInfo."Phone No." > '' then
                AppendXmlText('Telefono', ContattiTrasmittente, CompInfo."Phone No.");

            if CompInfo."E-Mail" > '' then
                AppendXmlText('Email', ContattiTrasmittente, CompInfo."E-Mail");
        end;

        if Cust."YNS Send E-Invoice via PEC" then begin
            Cust.TestField("PEC E-Mail Address");
            AppendXmlText('PECDestinatario', DatiTrasmissione, cust."PEC E-Mail Address");
        end;

        CedentePrestatore := AppendXmlElement('CedentePrestatore', Result);

        DatiAnagrafici := AppendXmlElement('DatiAnagrafici', CedentePrestatore);

        IdFiscaleIVA := AppendXmlElement('IdFiscaleIVA', DatiAnagrafici);

        Country.Reset();
        Country.SetRange("ISO Code", CompInfo."VAT Registration No.".Substring(1, 2));
        if not Country.FindFirst() then
            CompInfo.FieldError("VAT Registration No.");

        AppendXmlText('IdPaese', IdFiscaleIVA, Country."ISO Code");
        AppendXmlText('IdCodice', IdFiscaleIVA, CompInfo."VAT Registration No.".Substring(3));

        if CompInfo."Fiscal Code" > '' then
            AppendXmlText('CodiceFiscale', DatiAnagrafici, CompInfo."Fiscal Code");

        Anagrafica := AppendXmlElement('Anagrafica', DatiAnagrafici);

        CompInfo.TestField(Name);
        AppendXmlText('Denominazione', Anagrafica, CopyStr(CompInfo.Name, 1, 80));

        CompInfo.TestField("Company Type");
        AppendXmlText('RegimeFiscale', DatiAnagrafici, 'RF' + CompInfo."Company Type");

        Sede := AppendXmlElement('Sede', CedentePrestatore);

        CompInfo.TestField(Address);
        AppendXmlText('Indirizzo', Sede, CopyStr(CompInfo.Address, 1, 60));

        CompInfo.TestField("Post Code");
        AppendXmlText('CAP', Sede, CopyStr(CompInfo."Post Code", 1, 5));

        CompInfo.TestField(City);
        AppendXmlText('Comune', Sede, CopyStr(CompInfo.City, 1, 60));

        CompInfo.TestField("Country/Region Code");
        Country.Get(CompInfo."Country/Region Code");
        Country.TestField("ISO Code");
        if Country."ISO Code" = 'IT' then begin
            CompInfo.TestField(County);
            AppendXmlText('Provincia', Sede, CopyStr(CompInfo.County, 1, 2));
        end;

        AppendXmlText('Nazione', Sede, Country."ISO Code");

        if CompInfo."REA No." > '' then begin
            IscrizioneREA := AppendXmlElement('IscrizioneREA', CedentePrestatore);

            CompInfo.TestField("Registry Office Province");
            AppendXmlText('Ufficio', IscrizioneREA, CompInfo."Registry Office Province");

            AppendXmlText('NumeroREA', IscrizioneREA, CompInfo."REA No.");

            if CompInfo."Liquidation Status" = CompInfo."Liquidation Status"::"Not in Liquidation" then
                AppendXmlText('StatoLiquidazione', IscrizioneREA, 'LN')
            else
                AppendXmlText('StatoLiquidazione', IscrizioneREA, 'LS');
        end;

        CessionarioCommittente := AppendXmlElement('CessionarioCommittente', Result);

        DatiAnagrafici := AppendXmlElement('DatiAnagrafici', CessionarioCommittente);

        IdFiscaleIVA := AppendXmlElement('IdFiscaleIVA', DatiAnagrafici);

        if Cust."VAT Registration No." = '' then
            Cust.TestField("Fiscal Code");

        if Cust."VAT Registration No." > '' then begin
            if StrLen(Cust."VAT Registration No.") < 3 then
                Cust.FieldError("VAT Registration No.");

            Country.Reset();
            Country.SetRange("ISO Code", Cust."VAT Registration No.".Substring(1, 2));
            if not Country.FindFirst() then
                Cust.FieldError("VAT Registration No.");

            AppendXmlText('IdPaese', IdFiscaleIVA, Country."ISO Code");
            AppendXmlText('IdCodice', IdFiscaleIVA, Cust."VAT Registration No.".Substring(3));
        end;

        if Cust."Fiscal Code" > '' then
            AppendXmlText('CodiceFiscale', DatiAnagrafici, Cust."Fiscal Code");

        Anagrafica := AppendXmlElement('Anagrafica', DatiAnagrafici);

        Cust.TestField(Name);
        AppendXmlText('Denominazione', Anagrafica, CopyStr(Cust.Name, 1, 80));

        Sede := AppendXmlElement('Sede', CessionarioCommittente);

        Cust.TestField(Address);
        AppendXmlText('Indirizzo', Sede, CopyStr(Cust.Address, 1, 60));

        Cust.TestField("Post Code");
        AppendXmlText('CAP', Sede, CopyStr(Cust."Post Code", 1, 5));

        Cust.TestField(City);
        AppendXmlText('Comune', Sede, CopyStr(Cust.City, 1, 60));

        Cust.TestField("Country/Region Code");
        Country.Get(Cust."Country/Region Code");
        Country.TestField("ISO Code");
        if Country."ISO Code" = 'IT' then begin
            Cust.TestField(County);
            AppendXmlText('Provincia', Sede, CopyStr(Cust.County, 1, 2));
        end;

        AppendXmlText('Nazione', Sede, Country."ISO Code");
    end;
}
#endif