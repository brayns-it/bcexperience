#if W1XX004A
/// <summary>
/// Interface for format a document
/// </summary>
interface "YNS Doc. Exchange Format"
{
    /// <summary>
    /// Set working profile
    /// </summary>
    procedure SetProfile(var ExProfile: Record "YNS Doc. Exchange Profile")

    /// <summary>
    /// For the profile and the selected documents and the current page, get the available options
    /// as choices in a buffer
    /// </summary>
    procedure GetManualProcessOptions(var SelectedProfile: Record "YNS Doc. Exchange Profile"; var TempOptions: Record "Name/Value Buffer" temporary; var DocRefs: RecordRef; PageID: Integer)

    /// <summary>
    /// Execute the specified action for the selected document in exchange profile
    /// </summary>
    /// <param name="ProcessAction">The action code returned by GetManualProcessOptions</param>
    procedure Process(Parameters: List of [Text]; var DocRefs: RecordRef)

    /// <summary>
    /// Open setup page if defined
    /// </summary>
    procedure OpenSetup()

    /// <summary>
    /// Set current record log to append informations, warnings and errors
    /// </summary>
    procedure SetLog(var Log: Record "YNS Doc. Exchange Log")
}
#endif