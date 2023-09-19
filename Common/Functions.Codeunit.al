#if W1XX002A
/// <summary>
/// Various utility functions
/// </summary>
codeunit 60004 "YNS Functions"
{
    #region JSON
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

    #region CONVERT
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
#endif