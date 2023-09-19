#if W1XX001A
/// <summary>
/// This page is a generic entrypoint for API calls with custom JSON body.
/// 
/// "subsystem" is the enum value that refers to API implementation
/// "procedureName" is passed to API implementation to dispatch the requests
/// "body" is the custom JSON body base64 encoded
/// 
/// The client has only to POST this generic page.
/// The server has to implement the generic interface.
/// </summary>
page 60012 "YNS Generic API"
{
    PageType = API;
    APIPublisher = 'brayns';
    APIGroup = 'api';
    APIVersion = 'v2.0';
    DelayedInsert = true;
    SourceTable = "Dimension Set Entry Buffer";
    SourceTableTemporary = true;
    EntityName = 'generic';
    EntitySetName = 'generic';
    ODataKeyFields = SystemId;

    layout
    {
        area(Content)
        {
            repeater(control1)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(subsystem; SubsystemVar)
                {
                    Caption = 'Subsystem';
                }
                field(procedureName; ProcedureNameVar)
                {
                    Caption = 'Procedure';
                }
                field(body; BodyVar)
                {
                    Caption = 'Body';

                    trigger OnValidate()
                    begin
                        BodyValidate();
                    end;

                }
            }
        }
    }

    local procedure BodyValidate()
    var
        NoSubsystemErr: Label 'Missing subsystem';
        NoProcedureErr: Label 'Missing procedure name';
        NoBodyErr: Label 'Missing body';
        JRequest: JsonObject;
        JResponse: JsonObject;
        ResponseTxt: Text;
        Subsys: Interface "YNS Generic API";
    begin
        if SubsystemVar <= 0 then Error(NoSubsystemErr);
        if ProcedureNameVar.Trim() = '' then Error(NoProcedureErr);
        if BodyVar.Trim() = '' then Error(NoBodyErr);

        Subsys := Enum::"YNS Generic API".FromInteger(SubsystemVar);

        JRequest.ReadFrom(Functions.ConvertBase64ToText(BodyVar));
        JResponse := Subsys.Invoke(ProcedureNameVar, JRequest);
        JResponse.WriteTo(ResponseTxt);
        BodyVar := Functions.ConvertTextToBase64(ResponseTxt);
    end;

    var
        Functions: Codeunit "YNS Functions";
        SubsystemVar: Integer;
        ProcedureNameVar: Text;
        BodyVar: Text;

}
#endif