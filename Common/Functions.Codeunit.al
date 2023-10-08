/// <summary>
/// Various utility functions
/// </summary>
codeunit 60004 "YNS Functions"
{
    #region DIALOG
    /// <summary>
    /// Upload a text file from the client (UTF8)
    /// </summary>
    procedure UploadText(Title: Text; FileFilter: Text; var FileName: Text; var FileContent: Text): Boolean
    var
        IStream: InStream;
    begin
        if UploadIntoStream(Title, '', FileFilter, FileName, IStream) then begin
            FileContent := ConvertStreamToText(IStream);
            exit(true);
        end;
        exit(false);
    end;

    /// <summary>
    /// Upload a binary file from the client 
    /// </summary>
    procedure UploadStream(Title: Text; FileFilter: Text; var FileName: Text; var IStream: InStream): Boolean
    var
    begin
        exit(UploadIntoStream(Title, '', FileFilter, FileName, IStream));
    end;

    /// <summary>
    /// Download a text file to the client (UTF8)
    /// </summary>
    procedure DownloadText(Title: Text; FileFilter: Text; FileName: Text; FileContent: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        IStream: InStream;
        OStream: OutStream;
    begin
        TempBlob.CreateOutStream(OStream, TextEncoding::UTF8);
        OStream.WriteText(FileContent);
        TempBlob.CreateInStream(IStream, TextEncoding::UTF8);
        DownloadFromStream(IStream, Title, '', FileFilter, FileName);
    end;

    /// <summary>
    /// Get dialog file filter for the specified content type
    /// </summary>
    procedure GetFileFilter(ContentType: Text): Text
    begin
        case ContentType of
            'text/plain':
                exit('Text File|*.txt');
            'application/json':
                exit('JSON File|*.json');
            'text/xml',
            'application/xml':
                exit('XML File|*.xml');
            else
                exit('Any File|*.*');
        end;
    end;
    #endregion

    #region XML
    /// <summary>
    /// Return inner text of selected child node
    /// </summary>
    procedure GetXmlChildAsText(Name: Text; var XmlNod: XmlNode) Result: Text
    var
        XmlNod2: XmlNode;
    begin
        if XmlNod.SelectSingleNode(Name, XmlNod2) then
            Result := XmlNod2.AsXmlElement().InnerText;
    end;

    /// <summary>
    /// Return inner text of selected child node as date (format YYYY-MM-DD)
    /// </summary>
    procedure GetXmlChildAsDate(Name: Text; var XmlNod: XmlNode) Result: Date
    var
        TypeHelp: Codeunit "Type Helper";
        XmlNod2: XmlNode;
        Fmt: Text;
        ResVar: Variant;
        InvalidErr: Label 'Invalid date %1 format %2';
    begin
        ResVar := Result;
        Fmt := 'yyyy-MM-dd';
        if XmlNod.SelectSingleNode(Name, XmlNod2) then
            if not TypeHelp.Evaluate(ResVar, XmlNod2.AsXmlElement().InnerText, Fmt, '') then
                Error(InvalidErr, XmlNod2.AsXmlElement().InnerText, Fmt);
        Result := ResVar;
    end;

    /// <summary>
    /// Return inner text of selected child node as decimal
    /// </summary>
    procedure GetXmlChildAsDecimal(Name: Text; var XmlNod: XmlNode) Result: Decimal
    var
        XmlNod2: XmlNode;
    begin
        if XmlNod.SelectSingleNode(Name, XmlNod2) then
            exit(ConvertTextToDecimal(XmlNod2.AsXmlElement().InnerText));
    end;

    /// <summary>
    /// Append a new element to parent with specified tag name
    /// </summary>
    procedure AppendXmlElement(Name: Text; Parent: XmlElement) Result: XmlElement
    begin
        Result := XmlElement.Create(Name);
        Parent.Add(Result);
    end;

    /// <summary>
    /// Append a new element to parent with specified text content
    /// </summary>
    procedure AppendXmlText(Name: Text; Parent: XmlElement; Content: Text)
    var
        XmlEl: XmlElement;
    begin
        XmlEl := XmlElement.Create(Name);
        XmlEl.Add(XmlText.Create(Content));
        Parent.Add(XmlEl);
    end;

    /// <summary>
    /// Append a new element to parent with specified date content (format YYYY-MM-DD)
    /// </summary>
    procedure AppendXmlDate(Name: Text; Parent: XmlElement; DateValue: Date)
    var
        XmlEl: XmlElement;
    begin
        XmlEl := XmlElement.Create(Name);
        XmlEl.Add(XmlText.Create(Format(DateValue, 0, '<Year4>-<Month,2>-<Day,2>')));
        Parent.Add(XmlEl);
    end;

    /// <summary>
    /// Append a new element to parent with specified integer content
    /// </summary>
    procedure AppendXmlInteger(Name: Text; Parent: XmlElement; IntValue: Integer)
    var
        XmlEl: XmlElement;
    begin
        XmlEl := XmlElement.Create(Name);
        XmlEl.Add(XmlText.Create(Format(IntValue, 0, 9)));
        Parent.Add(XmlEl);
    end;

    /// <summary>
    /// Append a new element to parent with specified decimal content
    /// </summary>
    procedure AppendXmlDecimal(Name: Text; Parent: XmlElement; DecValue: Decimal)
    begin
        AppendXmlDecimal(Name, Parent, DecValue, -1);
    end;

    /// <summary>
    /// Append a new element to parent with specified decimal content and decimal places
    /// </summary>
    procedure AppendXmlDecimal(Name: Text; Parent: XmlElement; DecValue: Decimal; DecPlaces: Integer)
    var
        XmlEl: XmlElement;
        Fmt: Text;
    begin
        if DecPlaces >= 0 then
            Fmt := '<Sign><Integer><Decimals,' + Format(DecPlaces + 1) + '><Comma,.>'
        else
            Fmt := '<Sign><Integer><Decimals><Comma,.>';
        XmlEl := XmlElement.Create(Name);
        XmlEl.Add(XmlText.Create(Format(DecValue, 0, Fmt)));
        Parent.Add(XmlEl);
    end;
    #endregion

    #region JSON
    /// <summary>
    /// Returns a JSON object property as datetime (round trip format)
    /// </summary>
    /// <returns>Empty datetime if the property does not exists</returns>
    procedure GetJsonPropertyAsDateTime(JObject: JsonObject; KeyName: Text) Result: DateTime
    var
        JToken: JsonToken;
    begin
        if JObject.Get(KeyName, JToken) then
            exit(JToken.AsValue().AsDateTime());
    end;

    /// <summary>
    /// Returns a JSON object property as text
    /// </summary>
    /// <returns>Empty string if the property does not exists</returns>
    procedure GetJsonPropertyAsText(JObject: JsonObject; KeyName: Text): Text
    var
        JToken: JsonToken;
    begin
        if JObject.Get(KeyName, JToken) then
            exit(JToken.AsValue().AsText());
    end;

    /// <summary>
    /// Returns a JSON object property as object
    /// </summary>
    /// <returns>Empty object if the property does not exists</returns>
    procedure GetJsonPropertyAsObject(JObject: JsonObject; KeyName: Text): JsonObject
    var
        JToken: JsonToken;
    begin
        if JObject.Get(KeyName, JToken) then
            exit(JToken.AsObject());
    end;

    /// <summary>
    /// Returns a JSON object property as list of JSON object (array of objects)
    /// </summary>
    /// <returns>Empty list if the property does not exists</returns>
    procedure GetJsonPropertyAsObjectArray(JObject: JsonObject; KeyName: Text) Result: List of [JsonObject]
    var
        JToken: JsonToken;
        JToken2: JsonToken;
    begin
        if JObject.Get(KeyName, JToken) then
            foreach JToken2 in JToken.AsArray() do
                Result.Add(JToken2.AsObject());
    end;
    #endregion

    #region TEXT
    /// <summary>
    /// Pad a text to specifiedn length wid padding char to the left of the string
    /// </summary>
    procedure PadLeft(TextToPad: Text; Length: Integer; PadChar: Char) Result: Text
    begin
        Result := CopyStr(TextToPad, 1, Length);
        if StrLen(Result) < Length then
            Result := PadStr('', Length - StrLen(Result), PadChar) + Result;
    end;
    #endregion

    #region CONVERT
    /// <summary>
    /// Convert text to date format (yyyy-MM-dd)
    /// </summary>
    procedure ConvertTextToDate(InputText: Text) Result: Date
    begin
        Result := ConvertTextToDate(InputText, 'yyyy-MM-dd');
    end;

    /// <summary>
    /// Convert text to date format (.NET format)
    /// </summary>
    procedure ConvertTextToDate(InputText: Text; FormatString: Text) Result: Date
    var
        TypeHelp: Codeunit "Type Helper";
        ResVar: Variant;
        InvalidErr: Label 'Invalid date %1';
    begin
        ResVar := Result;
        if not TypeHelp.Evaluate(ResVar, InputText, FormatString, '') then
            Error(InvalidErr, InputText);
        Result := ResVar;
    end;

    /// <summary>
    /// Convert text to decimal with dot as decimal separator
    /// </summary>
    procedure ConvertTextToDecimal(InputText: Text) Result: Decimal
    var
        TypeHelp: Codeunit "Type Helper";
        ResVar: Variant;
        InvalidErr: Label 'Invalid decimal %1';
    begin
        ResVar := Result;
        if not TypeHelp.Evaluate(ResVar, InputText, '', 'en-US') then
            Error(InvalidErr, InputText);
        Result := ResVar;
    end;

    /// <summary>
    /// Convert string contained in a BLOB to text (UTF8)
    /// </summary>
    procedure ConvertBlobToText(var TempBlob: Codeunit "Temp Blob") Result: Text;
    var
        IStream: InStream;
    begin
        IStream := TempBlob.CreateInStream(TextEncoding::UTF8);
        exit(ConvertStreamToText(IStream));
    end;

    /// <summary>
    /// Convert a text in a BLOB (UTF8)
    /// </summary>
    procedure ConvertTextToBlob(InputText: Text) Result: Codeunit "Temp Blob"
    var
        OStream: OutStream;
    begin
        OStream := Result.CreateOutStream(TextEncoding::UTF8);
        OStream.WriteText(InputText);
    end;

    /// <summary>
    /// Convert a stream into string in UTF8 format
    /// </summary>
    procedure ConvertStreamToText(var InputStream: InStream) Result: Text
    var
        StreamReader: Codeunit DotNet_StreamReader;
        Encoding: Codeunit DotNet_Encoding;
    begin
        Encoding.UTF8();
        StreamReader.StreamReader(InputStream, Encoding);
        Result := StreamReader.ReadToEnd();
        StreamReader.Close();
    end;

    /// <summary>
    /// Convert a base64 string to UTF8 text
    /// </summary>
    procedure ConvertBase64ToText(Base64String: Text): Text
    var
        Base64Convert: Codeunit "Base64 Convert";
    begin
        exit(Base64Convert.FromBase64(Base64String, TextEncoding::UTF8));
    end;

    /// <summary>
    /// Convert a UTF8 text as base64 string
    /// </summary>
    procedure ConvertTextToBase64(TextString: Text): Text
    var
        Base64Convert: Codeunit "Base64 Convert";
    begin
        exit(Base64Convert.ToBase64(TextString, TextEncoding::UTF8));
    end;
    #endregion
}
