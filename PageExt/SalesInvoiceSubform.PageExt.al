pageextension 60016 YNSSalesInvoiceSubform extends "Sales Invoice Subform"
{
    layout
    {
        modify("Job No.")
        {
#if W1JB001A
            Editable = true;
#endif
        }
        modify("Job Task No.")
        {
#if W1JB001A
            Editable = true;
#endif
        }
    }
}