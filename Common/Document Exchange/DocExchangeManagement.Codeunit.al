#if W1XX004A
/// <summary>
/// Various functions for document exchange
/// </summary>
codeunit 60007 "YNS Doc. Exchange Management"
{
    /// <summary>
    /// Show to the user the document exchange choices for the selected documents
    /// Use it in varius page as Posted Sales Invoice passing SETSELECTIONFILTER as RECORDREF
    /// </summary>
    procedure ManualProcessDocuments(var DocRefs: RecordRef)
    var
        ExchProf: Record "YNS Doc. Exchange Profile";
        ListSelect: Page "YNS List Select";
        ExFormat: Interface "YNS Doc. Exchange Format";
        NoProfileAvailableErr: Label 'No profile available for %1';
        CaptionLbl: Label 'Document Exchange';
    begin
        ExchProf.Reset();
        ExchProf.SetRange(Enabled, true);
        ExchProf.SetFilter("Exchange Format", '>0');
        ExchProf.SetFilter("Exchange Transport", '>0');
        if ExchProf.FindSet() then
            repeat
                ExFormat := ExchProf."Exchange Format";
                ExFormat.GetManualProcessOptions(ExchProf, ListSelect, DocRefs);
            until ExchProf.Next() = 0;

        if ListSelect.GetCount() = 0 then
            Error(NoProfileAvailableErr, DocRefs.Caption);

        ListSelect.SetCaption(CaptionLbl);
        ListSelect.SetColumns(true);
        ListSelect.LookupMode(true);
        if ListSelect.RunModal() <> Action::LookupOK then
            exit;

        ExchProf.Get(ListSelect.GetSelectedNo());
        ExFormat := ExchProf."Exchange Format";
        ExFormat.Process(ExchProf, ListSelect.GetSelectedTag(), DocRefs);
    end;
}
#endif