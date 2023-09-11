codeunit 60000 "YNS Finance Management"
{
    Permissions = tabledata "G/L Entry" = rimd,
        tabledata "Cust. Ledger Entry" = rimd,
        tabledata "Detailed Cust. Ledg. Entry" = rimd;

#if FN0001A or ALL

#endif
}