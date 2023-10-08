#if W1XX001A
/// <summary>
/// Enumeration for generic API interface
/// </summary>
enum 60000 "YNS Generic API" implements "YNS Generic API"
{
    Extensible = true;
#if W1XX003A
    value(60005; "YNS Bulk Importer")
    {
        Implementation = "YNS Generic API" = "YNS Bulk Importer";
        Caption = 'Bulk Importer';
    }
#endif 
}
#endif