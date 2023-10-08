#if LOCALEIT
tableextension 60013 YNSGLBookEntry extends "GL Book Entry"
{
    fields
    {
#if ITXX003A
        field(60000; "YNS Registration No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Registration No.';
        }
#endif
    }
}
#endif