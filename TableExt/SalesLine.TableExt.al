tableextension 60005 YNSSalesLine extends "Sales Line"
{
    fields
    {
        modify("Job Task No.")
        {
            trigger OnBeforeValidate()
            begin
#if W1JB001A
                if not (Type in [Type::Resource, type::Item, type::"G/L Account"]) then
                    FieldError(Type);
#endif
            end;
        }
#if W1SA002A
        field(60001; "YNS System-Created Source"; Code[35])
        {
            DataClassification = CustomerContent;
            Caption = 'System-Created Source';
        }
#endif
#if W1JB001A
        field(60002; "YNS Sys.-Created Job Contract"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'System-Created Job Contract';
        }
#endif
    }
}