#if W1XX004A
/// <summary>
/// Various functions for document exchange
/// </summary>
codeunit 60007 "YNS Doc. Exchange Management"
{
    /// <summary>
    /// Add a process option to choises temporary table avoiding duplicates
    /// </summary>
    procedure AddProcessOption(ProfileCode: Text; IFormat: Enum "YNS Doc. Exchange Format";
        Parameter: Text; Description: Text; var TempOptions: Record "Name/Value Buffer" temporary)
    var
        ID: Integer;
        OptKey: Text;
    begin
        OptKey := ProfileCode + ',' + Format(IFormat.AsInteger(), 0, 9) + ',' + Parameter;

        TempOptions.Reset();
        TempOptions.SetRange("Value Long", OptKey);
        if TempOptions.IsEmpty() then begin
            ID := 1;
            TempOptions.Reset();
            if TempOptions.FindLast() then
                ID += TempOptions.ID;

            TempOptions.Init();
            TempOptions.ID := ID;
            TempOptions.Name := CopyStr(Description, 1, MaxStrLen(TempOptions.Name));
            TempOptions."Value Long" := CopyStr(OptKey, 1, MaxStrLen(TempOptions."Value Long"));
            TempOptions.Insert();
        end;
    end;

    /// <summary>
    /// Show to the user the document exchange choices for the selected documents
    /// Use it in varius page as Posted Sales Invoice passing SETSELECTIONFILTER as RECORDREF
    /// </summary>
    procedure ManualProcessDocuments(var DocRefs: RecordRef; PageID: Integer)
    var
        ExchProf: Record "YNS Doc. Exchange Profile";
        TempOptions: Record "Name/Value Buffer" temporary;
        ListSelect: Page "YNS List Select";
        ExFormat: Interface "YNS Doc. Exchange Format";
        NoProfileAvailableErr: Label 'No profile available for %1';
        CaptionLbl: Label 'Document Exchange';
        TempI: Integer;
    begin
        ExchProf.Reset();
        ExchProf.SetRange(Enabled, true);
        ExchProf.SetFilter("Exchange Format", '>0');
        ExchProf.SetFilter("Exchange Transport", '>0');
        if ExchProf.FindSet() then
            repeat
                ExFormat := ExchProf."Exchange Format";
                ExFormat.GetManualProcessOptions(ExchProf, TempOptions, DocRefs, PageID);
            until ExchProf.Next() = 0;

        TempOptions.Reset();
        if TempOptions.FindSet() then
            repeat
                ListSelect.AddOption(TempOptions."Value Long", TempOptions.Name);
            until TempOptions.Next() = 0
        else
            Error(NoProfileAvailableErr, DocRefs.Caption);

        ListSelect.SetCaption(CaptionLbl);
        ListSelect.SetColumns(true);
        ListSelect.LookupMode(true);
        if ListSelect.RunModal() <> Action::LookupOK then
            exit;

        Evaluate(TempI, SelectStr(2, ListSelect.GetSelectedNo()));
        ExFormat := Enum::"YNS Doc. Exchange Format".FromInteger(TempI);

        if SelectStr(1, ListSelect.GetSelectedNo()) > '' then begin
            ExchProf.Get(SelectStr(1, ListSelect.GetSelectedNo()));
            ExFormat.SetProfile(ExchProf);
        end;

        ExFormat.Process(SelectStr(3, ListSelect.GetSelectedNo()), DocRefs);
    end;
}
#endif