#if W1XX007A
codeunit 60008 "YNS Remote Functions Mgmt."
{
    var
        CurrentProfile: Record "YNS Remote Functions";
        Functions: Codeunit "YNS Functions";

    procedure SetProfile(var NewProfile: Record "YNS Remote Functions")
    begin
        CurrentProfile := NewProfile;
    end;

    procedure SetProfile(ProfileCode: Text)
    begin
        CurrentProfile.Get(ProfileCode);
        CurrentProfile.TestField(Enabled);
    end;

    procedure GetPreferredProfile()
    begin
        if CurrentProfile.Code = '' then begin
            CurrentProfile.Reset();
            CurrentProfile.SetRange(Preferred, true);
            CurrentProfile.SetRange(Enabled, true);
            CurrentProfile.FindFirst();
        end;
    end;

    procedure Execute(ReqSystem: Text; ReqFunction: Text; Request: JsonObject) Response: JsonObject
    var
        Client: HttpClient;
        Content: HttpContent;
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        URI: Text;
        BodyTxt: Text;
        JTok: JsonToken;
    begin
        GetPreferredProfile();
        CurrentProfile.TestField("API Endpoint");
        URI := CurrentProfile."API Endpoint";
        if not URI.EndsWith('/') then URI += '/';
        URI += ReqSystem + '/' + ReqFunction;

        RequestMessage.SetRequestUri(URI);
        RequestMessage.Method := 'POST';

        Request.WriteTo(BodyTxt);
        Content.WriteFrom(BodyTxt);
        Content.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('Content-Type', 'application/json');
        RequestMessage.Content := Content;

        RequestMessage.GetHeaders(Headers);
        Headers.Add('Authorization', 'Bearer ' + CurrentProfile.GetToken());

        Client.Send(RequestMessage, ResponseMessage);

        ResponseMessage.Content.ReadAs(BodyTxt);
        Response.ReadFrom(BodyTxt);

        if Response.Get('error', JTok) then begin
            JTok.AsObject().Get('message', JTok);
            Error(JTok.AsValue().AsText());
        end;
    end;

    #region GENERIC
    procedure GetPkcs7Message(var IStream: InStream) Result: Text
    var
        Base64Convert: Codeunit "Base64 Convert";
        Req: JsonObject;
        Res: JsonObject;
        JTok: JsonToken;
    begin
        Req.Add('envelope', Base64Convert.ToBase64(IStream));
        Res := Execute('generic', 'GetPkcs7Message', Req);
        Res.Get('content', JTok);
        Result := Functions.ConvertBase64ToText(JTok.AsValue().AsText());
    end;
    #endregion
}
#endif