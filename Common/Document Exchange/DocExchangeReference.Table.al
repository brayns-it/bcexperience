#if W1XX004A
table 60005 "YNS Doc. Exchange Reference"
{
    Caption = 'Document Exchange Reference';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        RefLine: Record "YNS Doc. Exchange Ref. Line";
    begin
        RefLine.Reset();
        RefLine.SetRange("Reference Code", rec.Code);
        if not RefLine.IsEmpty() then
            RefLine.DeleteAll();
    end;
}
#endif