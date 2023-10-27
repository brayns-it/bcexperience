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
#if ITXX007A
    value(60021; "YNS Customer Bill Format")
    {
        Implementation = "YNS Doc. Exchange Format" = "YNS Customer Bill Format";
        Caption = 'Customer Bill';
    }
#endif
#if ITXX008A
    value(60022; "YNS Italy Periodic VAT Settl.")
    {
        Implementation = "YNS Doc. Exchange Format" = "YNS Italy Periodic VAT Settl.";
        Caption = 'Italy Periodic VAT Settlement';
    }
#endif
}
#endif