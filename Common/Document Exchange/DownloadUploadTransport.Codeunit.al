#if W1XX004A
codeunit 60013 "YNS Download/Upload Transport" implements "YNS Doc. Exchange Transport"
{
    var
        GlobalProfile: Record "YNS Doc. Exchange Profile";
        Functions: Codeunit "YNS Functions";
        NotSupportedErr: Label 'Not supported';

    procedure BatchAllowed(): Boolean
    begin
        exit(false);
    end;

    procedure SetProfile(var ExProfile: Record "YNS Doc. Exchange Profile")
    begin
        GlobalProfile := ExProfile;
    end;

    procedure Receive(StreamName: Text; StreamType: Text) Result: Text
    begin
        Functions.UploadText('', Functions.GetFileFilter(StreamType), StreamName, Result);
    end;

    procedure Send(StreamName: Text; StreamType: Text; StreamContent: Text) Result: Text
    begin
        Functions.DownloadText('', Functions.GetFileFilter(StreamType), StreamName, StreamContent);
    end;

    procedure ReceiveConfirm()
    begin
        // not necessary
    end;

    procedure OpenSetup()
    begin
        // no setup
    end;

    procedure BatchReceiveStart(Category: Text)
    begin
        Error(NotSupportedErr);
    end;

    procedure BatchReceive(var Streams: Dictionary of [Text, Text]) Result: Boolean
    begin
        Error(NotSupportedErr);
    end;

    procedure BatchReceiveStop()
    begin
        Error(NotSupportedErr);
    end;

    procedure BatchReceiveConfirm()
    begin
        Error(NotSupportedErr);
    end;
}
#endif