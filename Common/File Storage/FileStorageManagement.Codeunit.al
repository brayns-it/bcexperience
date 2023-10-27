#if W1XX005A
codeunit 60012 "YNS File Storage Management"
{
    var
        FileStorage: Record "YNS File Storage";
        Functions: Codeunit "YNS Functions";

    procedure NormalizePath(Path: Text) Result: Text;
    var
        InvalidPathErr: Label 'Invalid path %1';
        Parts: List of [Text];
        PathPart: Text;
        N: Integer;
    begin
        Path := Path.Trim();
        if (Path = '') or
           Path.Contains('<') or Path.Contains('>') or
           Path.Contains(':') or Path.Contains('|') or
           Path.Contains('?') or Path.Contains('"')
        then
            Error(InvalidPathErr, Path);

        Path := Path.Replace('\', '/');
        if not Path.StartsWith('/') then
            Error(InvalidPathErr);

        N := 0;
        Parts := Path.Split('/');
        foreach PathPart in Parts do
            if PathPart.Trim() > '' then begin
                Result += '/' + PathPart.Trim();
                N += 1;
            end;

        if N < 1 then
            Error(InvalidPathErr);
    end;

    procedure FileExists(Path: Text): Boolean
    begin
        FileStorage.Reset();
        FileStorage.SetRange(Path, NormalizePath(Path));
        FileStorage.SetRange(Type, FileStorage.Type::File);
        exit(not FileStorage.IsEmpty());
    end;

    procedure GetCurrentPath(): Text[2048]
    begin
        exit(FileStorage.Path);
    end;

    procedure GetCurrentFileName(): Text
    begin
        exit(GetCurrentFileName(false));
    end;

    procedure GetCurrentFileName(StripExtension: Boolean) Result: Text
    var
        N: Integer;
    begin
        N := FileStorage.Path.LastIndexOf('/');
        Result := FileStorage.Path.Substring(N + 1);

        if StripExtension then begin
            N := Result.LastIndexOf('.');
            if N > 0 then
                Result := Result.Substring(1, N - 1);
        end;
    end;

    procedure GetFileAsText(FileName: Text): Text
    var
        IStream: InStream;
    begin
        FileStorage.Reset();
        FileStorage.SetRange(Path, NormalizePath(FileName));
        FileStorage.SetRange(Type, FileStorage.Type::File);
        FileStorage.SetAutoCalcFields(Content);
        FileStorage.FindFirst();

        FileStorage.Content.CreateInStream(IStream);
        exit(Functions.ConvertStreamToText(IStream));
    end;

    procedure DeleteFile(FileName: Text)
    begin
        FileStorage.Reset();
        FileStorage.SetRange(Path, NormalizePath(FileName));
        FileStorage.SetRange(Type, FileStorage.Type::File);
        if FileStorage.FindFirst() then
            FileStorage.Delete();
    end;

    procedure SaveFile(FileName: Text; ContentType: Text; Content: Text)
    var
        InvalidFileNameErr: Label 'Invalid file name %1';
        Depth: Integer;
        OStream: OutStream;
    begin
        FileName := NormalizePath(FileName);
        if FileName.EndsWith('/') then
            Error(InvalidFileNameErr, FileName);

        CreatePath(FileName);
        Depth := FileStorage.Depth;

        FileStorage.Init();
        FileStorage.Path := CopyStr(FileName, 1, MaxStrLen(FileStorage.Path));
        FileStorage.Type := FileStorage.Type::File;
        FileStorage.Depth := Depth + 1;
        FileStorage."Content Type" := CopyStr(ContentType, 1, MaxStrLen(FileStorage."Content Type"));
        FileStorage.Size := StrLen(Content);
        FileStorage.Content.CreateOutStream(OStream, TextEncoding::UTF8);
        OStream.WriteText(Content);
        FileStorage.Insert(true);
    end;

    procedure CreatePath(Path: Text)
    var
        Parts: List of [Text];
        PathPart: Text;
        ProgPath: Text;
        N: Integer;
    begin
        ProgPath := '';
        Path := NormalizePath(Path);
        Parts := Path.Split('/');

        for N := 1 to Parts.Count() - 1 do begin
            Parts.Get(N, PathPart);
            if not ProgPath.EndsWith('/') then ProgPath += '/';
            ProgPath += PathPart;

            if not FileStorage.Get(ProgPath) then begin
                FileStorage.Init();
                FileStorage.Path := CopyStr(ProgPath, 1, MaxStrLen(FileStorage.Path));
                FileStorage.Type := FileStorage.Type::Folder;
                FileStorage.Depth := N - 1;
                FileStorage.Insert(true);
            end;
        end;
    end;
}
#endif