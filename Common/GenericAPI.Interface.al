#if W1XX001A
/// <summary>
/// Interface for generic API
/// </summary>
interface "YNS Generic API"
{
    /// <summary>
    /// Entrypoint for generic API call
    /// </summary>
    /// <param name="ProcedureName">Requested procedures</param>
    /// <param name="Request">Custom request as JSON object</param>
    /// <returns>Custom response as JSON object</returns>
    procedure Invoke(ProcedureName: Text; Request: JsonObject): JsonObject
}
#endif