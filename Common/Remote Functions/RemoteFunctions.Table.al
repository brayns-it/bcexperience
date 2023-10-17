#if W1XX007A
table 60010 "YNS Remote Functions"
{
    DataClassification = CustomerContent;
    Caption = 'Remote Functions';
    DataPerCompany = false;

    fields
    {
        field(1; Code; Code[10])
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
        field(5; "API Endpoint"; Text[512])
        {
            DataClassification = CustomerContent;
            Caption = 'API Endpoint';
        }
        field(10; "Preferred"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Preferred';
        }
        field(11; Enabled; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Enabled';
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    begin
        IsolatedStorage.Delete('YNS60010-RemoteFunctions-' + Rec.Code + '-Token', DataScope::Module);
    end;

    procedure SetToken(NewToken: Text)
    begin
        IsolatedStorage.Set('YNS60010-RemoteFunctions-' + Rec.Code + '-Token', NewToken, DataScope::Module);
    end;

    procedure GetToken() Result: Text
    begin
        if not IsolatedStorage.Get('YNS60010-RemoteFunctions-' + Rec.Code + '-Token', DataScope::Module, Result) then
            Result := '';
    end;

}
#endif