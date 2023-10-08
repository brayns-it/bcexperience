#if W1XX004A
/// <summary>
/// Interface for transport a document
/// </summary>
interface "YNS Doc. Exchange Transport"
{
    /// <summary>
    /// True if batch processing (no GUI) is allowed
    /// </summary>
    procedure BatchAllowed(): Boolean;

    /// <summary>
    /// Set working profile
    /// </summary>
    procedure SetProfile(var ExProfile: Record "YNS Doc. Exchange Profile")

    /// <summary>
    /// Receive a stream via transport
    /// </summary>
    procedure Receive(StreamName: Text; StreamType: Text): Text;

    /// <summary>
    /// Send a stream via transport
    /// </summary>
    procedure Send(StreamName: Text; StreamType: Text; StreamContent: Text);

    /// <summary>
    /// Start the batch receiving process for the selected category
    /// </summary>
    procedure BatchReceiveStart(Category: Text);

    /// <summary>
    /// Receive a complete set of stream from the endpoint. Each set can contains several
    /// text streams.
    /// </summary>
    /// <returns>False when there is no set to receive</returns>
    procedure BatchReceive(var Streams: Dictionary of [Text, Text]) Result: Boolean;

    /// <summary>
    /// Confirm to the endpoint the successful receving of a stream set
    /// </summary>
    procedure BatchReceiveConfirm();

    /// <summary>
    /// Stop the batch receiving process
    /// </summary>
    procedure BatchReceiveStop();

    /// <summary>
    /// Open setup page if defined
    /// </summary>
    procedure OpenSetup()
}
#endif