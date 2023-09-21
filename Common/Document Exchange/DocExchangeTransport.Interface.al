#if W1XX004A
/// <summary>
/// Interface for transport a document
/// </summary>
interface "YNS Doc. Exchange Transport"
{
    /// <summary>
    /// Get the interface description
    /// </summary>
    procedure GetDescription(): Text;

    /// <summary>
    /// Send a stream via transport
    /// </summary>
    procedure Send(StreamName: Text; StreamType: Text; StreamContent: Text);
}
#endif