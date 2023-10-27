#if W1XX004A
codeunit 60018 "YNS FileSystem Transport" implements "YNS Doc. Exchange Transport"
{
    var
        GlobalProfile: Record "YNS Doc. Exchange Profile";
        FSSetup: Record "YNS FileSystem Transport Setup";
        Functions: Codeunit "YNS Functions";
        RemFunctions: Codeunit "YNS Remote Functions Mgmt.";
        NotSupportedErr: Label 'Not supported';
        UnsupportedProtoErr: Label 'Unsupported protocol %1';
        LastStreamName: Text;

    procedure BatchAllowed(): Boolean
    begin
        exit(false);
    end;

    procedure SetProfile(var ExProfile: Record "YNS Doc. Exchange Profile")
    begin
        GlobalProfile := ExProfile;
    end;

    procedure Receive(StreamName: Text; StreamType: Text) Result: Text
    var
        TempBlob: Codeunit "Temp Blob";
        IStream: InStream;
        Path: Text;
    begin
        FSSetup.Get(GlobalProfile.Code);
        FSSetup.TestField("Receving Base Path");

        Path := FSSetup."Receving Base Path";
        if not Path.EndsWith('/') then Path += '/';
        Path += StreamName;

        Clear(RemFunctions);
        if FSSetup."Remote Functions Code" > '' then
            RemFunctions.SetProfile(FSSetup."Remote Functions Code");

        case FSSetup.Protocol of
            FSSetup.Protocol::FileSystem:
                TempBlob := RemFunctions.ReadFile(Path);
            else
                Error(UnsupportedProtoErr, FSSetup.Protocol);
        end;

        LastStreamName := StreamName;

        TempBlob.CreateInStream(IStream);
        exit(Functions.ConvertStreamToText(IStream));
    end;

    local procedure CreateUniquePath(var Path: Text)
    var
        IDTxt: Text;
        P: Integer;
        Ext: Text;
    begin
        P := Path.LastIndexOf('.');
        if P > 1 then begin
            Ext := '.' + Path.Substring(P + 1);
            Path := Path.Substring(1, P - 1);
        end;

        IDTxt := Format(CurrentDateTime, 0, '<Year4><Month,2><Day,2><Hours24,2><Filler Character,0><Minutes,2><Seconds,2><Second dec.><Comma,_>');
        Path := Path + '_' + IDTxt + Ext;
    end;

    procedure ReceiveConfirm()
    var
        OldPath: Text;
        NewPath: Text;
    begin
        FSSetup.Get(GlobalProfile.Code);
        if not FSSetup."Archive Received Files" then
            exit;

        FSSetup.TestField("Receving Base Path");
        FSSetup.TestField("Receving Base Path (archive)");

        OldPath := FSSetup."Receving Base Path";
        if not OldPath.EndsWith('/') then OldPath += '/';
        OldPath += LastStreamName;

        NewPath := FSSetup."Receving Base Path (archive)";
        if not NewPath.EndsWith('/') then NewPath += '/';
        NewPath += LastStreamName;
        CreateUniquePath(NewPath);

        Clear(RemFunctions);
        if FSSetup."Remote Functions Code" > '' then
            RemFunctions.SetProfile(FSSetup."Remote Functions Code");

        case FSSetup.Protocol of
            FSSetup.Protocol::FileSystem:
                RemFunctions.MoveFile(OldPath, NewPath);
            else
                Error(UnsupportedProtoErr, FSSetup.Protocol);
        end;
    end;

    procedure Send(StreamName: Text; StreamType: Text; StreamContent: Text) Result: Text
    var
        TempBlob: Codeunit "Temp Blob";
        Path: Text;
    begin
        FSSetup.Get(GlobalProfile.Code);
        FSSetup.TestField("Sending Base Path");

        Path := FSSetup."Sending Base Path";
        if not Path.EndsWith('/') then Path += '/';
        Path += StreamName;

        Clear(RemFunctions);
        if FSSetup."Remote Functions Code" > '' then
            RemFunctions.SetProfile(FSSetup."Remote Functions Code");

        case FSSetup."Text Encoding" of
            FSSetup."Text Encoding"::"UTF-8":
        TempBlob := Functions.ConvertTextToBlob(StreamContent);
            FSSetup."Text Encoding"::"UTF-8 with BOM":
                TempBlob := Functions.ConvertTextToBlob(StreamContent, true);
        end;

        case FSSetup.Protocol of
            FSSetup.Protocol::FileSystem:
                begin
                    RemFunctions.DeleteFile(Path);
                    RemFunctions.WriteFile(Path, TempBlob);
                end
            else
                Error(UnsupportedProtoErr, FSSetup.Protocol);
        end;
    end;

    procedure OpenSetup()
    begin
        if not FSSetup.Get(GlobalProfile.Code) then begin
            FSSetup.Init();
            FSSetup."Profile Code" := GlobalProfile.Code;
            FSSetup.Insert();
        end;
        Page.Run(page::"YNS FileSystem Transport Setup", FSSetup);
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