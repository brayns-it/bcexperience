#if ITXX008A
codeunit 60022 "YNS Italy Periodic VAT Settl." implements "YNS Doc. Exchange Format"
{
    var
        GlobalProfile: Record "YNS Doc. Exchange Profile";
        GenLedgSetup: Record "General Ledger Setup";
        DocExMgmt: Codeunit "YNS Doc. Exchange Management";
        Functions: Codeunit "YNS Functions";
        NamespaceUri: Text;

    procedure SetLog(var Log: Record "YNS Doc. Exchange Log")
    begin
        // do nothing
    end;

    procedure OpenSetup()
    begin
        // do nothing
    end;

    procedure GetManualProcessOptions(var SelectedProfile: Record "YNS Doc. Exchange Profile"; var TempOptions: Record "Name/Value Buffer" temporary; var DocRefs: RecordRef; PageID: Integer)
    var
        ExportVatSettlLbl: Label 'Export Italy Periodic VAT Settlement';
    begin
        case DocRefs.Number of
            Database::"Periodic Settlement VAT Entry":
                DocExMgmt.AddProcessOption(SelectedProfile.Code, SelectedProfile."Exchange Format", 'EXPORT', ExportVatSettlLbl, TempOptions);
        end;
    end;

    procedure SetProfile(var ExProfile: Record "YNS Doc. Exchange Profile")
    begin
        GlobalProfile := ExProfile;
    end;

    procedure Process(Parameters: List of [Text]; var DocRefs: RecordRef)
    var
        ProcessAction: Text;
    begin
        Parameters.Get(1, ProcessAction);

        case ProcessAction of
            'EXPORT':
                ExportVatSettlement(DocRefs);
        end;
    end;

    procedure ExportVatSettlement(var DocRef: RecordRef)
    var
        VatSettl: Record "Periodic Settlement VAT Entry";
        VatSettl2: Record "Periodic Settlement VAT Entry";
        xVatSettl: Record "Periodic Settlement VAT Entry";
        RepSetup: Record "VAT Report Setup";
        CompInfo: Record "Company Information";
        CompOffi: Record "Company Officials";
        ITransport: Interface "YNS Doc. Exchange Transport";
        InvalidSelectionErr: Label 'Invalid selection';
        XmlDoc: XmlDocument;
        XmlRoot: XmlElement;
        Intestazione: XmlElement;
        Comunicazione: XmlElement;
        Frontespizio: XmlElement;
        DatiContabili: XmlElement;
        NamespaceMgr: XmlNamespaceManager;
        FileContent: Text;
        FileName: Text;
        CommNo: Integer;
        CommID: Text;
        ModuleNo: Integer;
    begin
        DocRef.SetTable(VatSettl);
        if (VatSettl.Count < 1) or (VatSettl.Count > 3) then
            Error(InvalidSelectionErr);

        VatSettl.FindSet();

        NamespaceUri := 'urn:www.agenziaentrate.gov.it:specificheTecniche:sco:ivp';
        NamespaceMgr.AddNamespace('iv', NamespaceUri);

        XmlDocument.ReadFrom(
            '<?xml version="1.0" encoding="UTF-8"?>' +
            '<iv:Fornitura xmlns:iv="urn:www.agenziaentrate.gov.it:specificheTecniche:sco:ivp" ' +
            'xmlns:ds="http://www.w3.org/2000/09/xmldsi#">' +
            '</iv:Fornitura>',
            XmlDoc);

        XmlDoc.GetRoot(XmlRoot);

        Intestazione := XmlElement.Create('Intestazione', NamespaceUri);
        XmlRoot.Add(Intestazione);

        Functions.AppendXmlText('CodiceFornitura', Intestazione, 'IVP18', NamespaceUri);

        Comunicazione := XmlElement.Create('Comunicazione', NamespaceUri);
        XmlRoot.Add(Comunicazione);

        Frontespizio := XmlElement.Create('Frontespizio', NamespaceUri);
        Comunicazione.Add(Frontespizio);

        CompInfo.Get();
        CompInfo.TestField("Fiscal Code");
        CompInfo.TestField("VAT Registration No.");
        if (not CompInfo."VAT Registration No.".StartsWith('IT')) or (StrLen(CompInfo."VAT Registration No.") <> 13) then
            CompInfo.FieldError("VAT Registration No.");

        Functions.AppendXmlText('CodiceFiscale', Frontespizio, CompInfo."Fiscal Code", NamespaceUri);
        Functions.AppendXmlText('AnnoImposta', Frontespizio, CopyStr(VatSettl."VAT Period", 1, 4), NamespaceUri);
        Functions.AppendXmlText('PartitaIVA', Frontespizio, CopyStr(CompInfo."VAT Registration No.", 3, 11), NamespaceUri);

        CompInfo.TestField("General Manager No.");
        CompOffi.Get(CompInfo."General Manager No.");
        CompOffi.TestField("Appointment Code");
        CompOffi.TestField("Fiscal Code");
        Functions.AppendXmlText('CFDichiarante', Frontespizio, CompOffi."Fiscal Code", NamespaceUri);
        Functions.AppendXmlText('CodiceCaricaDichiarante', Frontespizio, CompOffi."Appointment Code", NamespaceUri);
        Functions.AppendXmlText('FirmaDichiarazione', Frontespizio, '1', NamespaceUri);

        RepSetup.Get();
        if RepSetup."Intermediary VAT Reg. No." > '' then begin
            Functions.AppendXmlText('CFIntermediario', Frontespizio, RepSetup."Intermediary VAT Reg. No.", NamespaceUri);
            Functions.AppendXmlText('ImpegnoPresentazione', Frontespizio, '1', NamespaceUri);
        end;
        if RepSetup."Intermediary Date" > 0D then
            Functions.AppendXmlText('DataImpegno', Frontespizio, Format(RepSetup."Intermediary Date", 0, '<Day,2><Month,2><Year4>'), NamespaceUri);
        if RepSetup."Intermediary VAT Reg. No." > '' then
            Functions.AppendXmlText('FirmaIntermediario', Frontespizio, '1', NamespaceUri);

        DatiContabili := XmlElement.Create('DatiContabili', NamespaceUri);
        Comunicazione.Add(DatiContabili);

        CommNo := 1;
        VatSettl2.Reset();
        VatSettl2.SetCurrentKey("YNS Periodic Communication No.");
        if VatSettl2.FindLast() then
            CommNo += VatSettl2."YNS Periodic Communication No.";

        GenLedgSetup.Get();
        xVatSettl := VatSettl;
        ModuleNo := 1;

        repeat
            if CopyStr(xVatSettl."VAT Period", 1, 4) <> CopyStr(VatSettl."VAT Period", 1, 4) then
                VatSettl.FieldError("VAT Period");

            VatSettl.TestField("YNS Periodic Communication No.", xVatSettl."YNS Periodic Communication No.");

            if VatSettl."YNS Periodic Communication No." = 0 then begin
                VatSettl."YNS Periodic Communication No." := CommNo;
                VatSettl.Modify();
            end else
                CommNo := VatSettl."YNS Periodic Communication No.";

            CreateModule(VatSettl, DatiContabili, ModuleNo);
            ModuleNo += 1;
        until VatSettl.Next() = 0;

        CommID := Functions.PadLeft(Format(CommNo, 0, 9), 5, '0');
        Comunicazione.SetAttribute('identificativo', CommID);

        XmlDoc.WriteTo(FileContent);
        FileName := CompInfo."VAT Registration No." + '_LI_' + CommID + '.xml';

        ITransport := GlobalProfile."Exchange Transport";
        ITransport.Send(FileName, 'text/xml', FileContent);
    end;

    procedure AppendXmlDecimal(Name: Text; Parent: XmlElement; DecValue: Decimal)
    var
        XmlEl: XmlElement;
        Fmt: Text;
    begin
        Fmt := '<Sign><Integer><Decimals,3><Comma,,>';
        XmlEl := XmlElement.Create(Name, NamespaceUri);
        XmlEl.Add(XmlText.Create(Format(DecValue, 0, Fmt)));
        Parent.Add(XmlEl);
    end;

    procedure CreateModule(var VatSettl: Record "Periodic Settlement VAT Entry"; var Parent: XmlElement; ModuleNo: Integer)
    var
        Modulo: XmlElement;
        Period: Integer;
        ToPaid: Decimal;
    begin
        Modulo := XmlElement.Create('Modulo', NamespaceUri);
        Parent.Add(Modulo);

        Functions.AppendXmlInteger('NumeroModulo', Modulo, ModuleNo, NamespaceUri);

        Evaluate(Period, CopyStr(VatSettl."VAT Period", 6, 2));
        if GenLedgSetup."VAT Settlement Period" = GenLedgSetup."VAT Settlement Period"::Month then
            Functions.AppendXmlInteger('Mese', Modulo, Period, NamespaceUri)
        else
            Functions.AppendXmlInteger('Trimestre', Modulo, Period / 3, NamespaceUri);

        AppendXmlDecimal('TotaleOperazioniAttive', Modulo, VatSettl."YNS Sales Base");
        AppendXmlDecimal('TotaleOperazioniPassive', Modulo, VatSettl."YNS Purchase Amount");
        AppendXmlDecimal('IvaEsigibile', Modulo, VatSettl."YNS Sales Amount");
        AppendXmlDecimal('IvaDetratta', Modulo, VatSettl."YNS Purchase Amount");

        if VatSettl."YNS Sales Amount" > VatSettl."YNS Purchase Amount" then
            AppendXmlDecimal('IvaDovuta', Modulo, VatSettl."YNS Sales Amount" - VatSettl."YNS Purchase Amount");

        if VatSettl."YNS Purchase Amount" > VatSettl."YNS Sales Amount" then
            AppendXmlDecimal('IvaCredito', Modulo, VatSettl."YNS Purchase Amount" - VatSettl."YNS Sales Amount");

        if VatSettl."Prior Period Output VAT" > 0 then
            AppendXmlDecimal('DebitoPrecedente', Modulo, VatSettl."Prior Period Output VAT");

        if VatSettl."Prior Period Input VAT" > 0 then
            AppendXmlDecimal('CreditoPeriodoPrecedente', Modulo, VatSettl."Prior Period Input VAT");

        if VatSettl."Prior Year Input VAT" > 0 then
            AppendXmlDecimal('CreditoAnnoPrecedente', Modulo, VatSettl."Prior Year Input VAT");

        if VatSettl."Advanced Amount" > 0 then
            AppendXmlDecimal('Acconto', Modulo, VatSettl."Advanced Amount");

        ToPaid := VatSettl."YNS Sales Amount" - VatSettl."YNS Purchase Amount" + VatSettl."Prior Period Output VAT" -
            VatSettl."Prior Period Input VAT" - VatSettl."Prior Year Input VAT" - VatSettl."Advanced Amount";

        if ToPaid > 0 then
            AppendXmlDecimal('ImportoDaVersare', Modulo, ToPaid);

        if ToPaid < 0 then
            AppendXmlDecimal('ImportoACredito', Modulo, -ToPaid);
    end;

}
#endif