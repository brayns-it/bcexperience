#if LOCALEIT
pageextension 60017 YNSCustomerBillCard extends "Customer Bill Card"
{
    actions
    {
#if ITXX007A        
        modify(ExportBillToFloppyFile)
        {
            Enabled = false;
            Visible = false;
        }
        modify(ExportBillToFile)
        {
            Enabled = false;
            Visible = false;
        }
#endif
    }
}
#endif