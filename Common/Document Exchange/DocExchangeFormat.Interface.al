#if W1XX004A
/// <summary>
/// Interface for format a document
/// </summary>
interface "YNS Doc. Exchange Format"
{
    /// <summary>
    /// For the profile and the selected documents, get the available options
    /// as choices in a List Select Page
    /// </summary>
    procedure GetManualProcessOptions(var ExProfile: Record "YNS Doc. Exchange Profile"; var ListSelect: Page "YNS List Select"; var DocRefs: RecordRef)

    /// <summary>
    /// Execute the specified action for the selected document in exchange profile
    /// </summary>
    /// <param name="ProcessAction">The action code returned by GetManualProcessOptions</param>
    procedure Process(var ExProfile: Record "YNS Doc. Exchange Profile"; ProcessAction: Text; var DocRefs: RecordRef)
}
#endif