#if W1XX004A
/// <summary>
/// Enumeration for document exchange format
/// </summary>
enum 60001 "YNS Doc. Exchange Format" implements "YNS Doc. Exchange Format"
{
#if ITXX002A
    value(60009; "YNS Italy E-Invoice Format")
    {
        Implementation = "YNS Doc. Exchange Format" = "YNS Italy E-Invoice Format";
        Caption = 'Italy E-Invoice';
    }
#endif
}
#endif