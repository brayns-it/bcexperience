#if W1XX004A
/// <summary>
/// Simple download upload interface
/// </summary>
codeunit 60008 "YNS Doc. Exch. Download/Upload" implements "YNS Doc. Exchange Transport"
{
    var
        Functions: Codeunit "YNS Functions";
        TypeNotSupportedErr: Label 'Type %1 not supported';

    procedure GetDescription(): Text
    var
        DescriptionLbl: label 'Download/Upload';
    begin
        exit(DescriptionLbl);
    end;

    procedure Receive(StreamName: Text; StreamType: Text): Text
    begin
        Error('TODO');
    end;

    procedure Send(StreamName: Text; StreamType: Text; StreamContent: Text);
    var

    begin
        if not (StreamType.ToLower() in [
            'text/plain', 'application/json', 'application/xml'
        ]) then
            Error(TypeNotSupportedErr, StreamType);

        Functions.DownloadText('', GetFileFilter(StreamType), AssertFileExtension(StreamName, StreamType), StreamContent);
    end;

    local procedure AssertFileExtension(StreamName: Text; StreamType: Text): Text
    var
        Ext: Text;
    begin
        case StreamType of
            'text/plain':
                Ext := '.txt';
            'application/json':
                Ext := '.json';
            'application/xml':
                Ext := '.xml';
            else
                exit(StreamName)
        end;

        if not StreamName.ToLower().EndsWith(Ext) then
            StreamName += Ext;

        exit(StreamName);
    end;

    local procedure GetFileFilter(StreamType: Text): Text
    begin
        case StreamType of
            'text/plain':
                exit('Text File|*.txt');
            'application/json':
                exit('JSON File|*.json');
            'application/xml':
                exit('XML File|*.xml');
            else
                exit('Any File|*.*');
        end;
    end;
}
#endif