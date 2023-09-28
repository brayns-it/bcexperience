#if W1XX007A
page 60022 "YNS Remote Functions"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "YNS Remote Functions";
    Caption = 'Remote Functions';

    layout
    {
        area(Content)
        {
            repeater(control1)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("API Endpoint"; Rec."API Endpoint")
                {
                    ApplicationArea = All;
                }
                field(Token; Token)
                {
                    ApplicationArea = All;
                    Caption = 'Token';
                    ExtendedDatatype = Masked;

                    trigger OnValidate()
                    begin
                        Rec.SetToken(Token);
                    end;
                }
                field(Preferred; Rec.Preferred)
                {
                    ApplicationArea = All;
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Token := Rec.GetToken();
    end;

    var
        Token: Text;

}
#endif