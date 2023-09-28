#if W1XX004A
table 60007 "YNS Doc. Exchange Profile"
{
    Caption = 'Document Exchange Profile';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Code';
        }
        field(2; "Description"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(10; "Exchange Format"; Enum "YNS Doc. Exchange Format")
        {
            DataClassification = CustomerContent;
            Caption = 'Exchange Format';
        }
        field(20; "Exchange Transport"; Enum "YNS Doc. Exchange Transport")
        {
            DataClassification = CustomerContent;
            Caption = 'Exchange Transport';
        }
        field(30; Enabled; Boolean)
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

    procedure OpenFormatSetup()
    var
        XFmt: Interface "YNS Doc. Exchange Format";
    begin
        if "Exchange Format".AsInteger() > 0 then begin
            XFmt := "Exchange Format";
            XFmt.SetProfile(Rec);
            XFmt.OpenSetup();
        end;
    end;

    procedure OpenTransportSetup()
    var
        XTra: Interface "YNS Doc. Exchange Transport";
    begin
        if "Exchange Transport".AsInteger() > 0 then begin
            XTra := "Exchange Transport";
            XTra.SetProfile(Rec);
            XTra.OpenSetup();
        end;
    end;
}
#endif