#if W1XX003A
/// <summary>
/// Bulk data import from JSON structured objects.
/// Create one codeunit instance for each import.
/// </summary>
codeunit 60005 "YNS Bulk Importer"
{
    EventSubscriberInstance = Manual;

    var
        Functions: Codeunit "YNS Functions";
        PropertyMap: Dictionary of [Text, Integer];

    /// <summary>
    /// Add mapping from JSON object property type to table ID
    /// </summary>
    procedure AddTable(PropertyName: Text; TableID: Integer);
    begin
        PropertyMap.Add(PropertyName, TableID);
    end;

    /// <summary>
    /// Bulk import the table, doing modify if the record exists or insert.
    /// Each mapped property is searched recursively in the object and processed as array of objects.
    /// </summary>
    procedure ImportTable(JObject: JsonObject)
    var
        RecRef: RecordRef;
        JItem: JsonObject;
        PropertyName: Text;
        TableID: Integer;
    begin
        foreach PropertyName in PropertyMap.Keys do
            if JObject.Contains(PropertyName) then begin
                PropertyMap.Get(PropertyName, TableID);
                RecRef.Open(TableID);

                foreach JItem in Functions.GetJsonPropertyAsObjectArray(JObject, PropertyName) do begin
                    CopyJsonObjectToRecordRef(JItem, RecRef);

                    RecRef.SetRecFilter();
                    if RecRef.FindFirst() then begin
                        CopyJsonObjectToRecordRef(JItem, RecRef);
                        RecRef.Modify();
                    end else
                        RecRef.Insert();

                    ImportTable(JItem);
                end;

                RecRef.Close();
            end;
    end;

    /// <summary>
    /// Get a valid JSON property name from field name.
    /// Only letters and numbers are retained. Dots and space are stripped. Other characters are replaced by undercore.
    /// Final name is formatted in camel case.
    /// </summary>
    procedure FormatJsonName(Name: Text) Result: Text
    var
        I: Integer;
        TempName: Text;
        Parts: List of [Text];
        Ch: Text;
    begin
        if Name = '' then
            exit;

        TempName := '';
        for I := 1 to StrLen(Name) do begin
            Ch := Name.Substring(I, 1);

            case Ch of
                'A' .. 'Z',
                'a' .. 'z',
                '0' .. '9',
                ' ':
                    TempName += Ch;
                '.':
                    TempName += '';     // strip dot
                else
                    TempName += '_';
            end;
        end;

        I := 0;
        Parts := TempName.Split(' ');
        foreach TempName in Parts do begin
            TempName := TempName.ToLower();
            if I > 0 then
                if StrLen(TempName) > 1 then
                    TempName := TempName.Substring(1, 1).ToUpper() + TempName.Substring(2)
                else
                    TempName := TempName.Substring(1, 1).ToUpper();

            I += 1;
            Result += TempName;
        end;
    end;

    /// <summary>
    /// Copy a record ref to a JSON object, each property equals to field
    /// </summary>
    procedure CopyRecordRefToJsonObject(var RecRef: RecordRef) Result: JsonObject
    var
        TmpDateFmla: DateFormula;
        FldRef: FieldRef;
        I: Integer;
        JName: Text;
        TmpInt: Integer;
        TmpBigInt: BigInteger;
        TmpDate: Date;
        TmpTime: Time;
        TmpDateTime: DateTime;
        TmpDecimal: Decimal;
        TmpText: Text;
        TmpGuid: Guid;
        TmpBool: Boolean;
        JValue: JsonValue;
        UnsupportedErr: Label 'Unsupported field type %1';
    begin
        for I := 1 to RecRef.FieldCount() do begin
            FldRef := RecRef.FieldIndex(I);
            JName := FormatJsonName(FldRef.Name());

            if FldRef.Class() = FieldClass::Normal then begin
                case FldRef.Type() of
                    FieldType::Integer,
                    FieldType::Option:
                        begin
                            TmpInt := FldRef.Value;
                            JValue.SetValue(TmpInt);
                        end;
                    FieldType::BigInteger:
                        begin
                            TmpBigInt := FldRef.Value;
                            JValue.SetValue(TmpBigInt);
                        end;
                    FieldType::Boolean:
                        begin
                            TmpBool := FldRef.Value;
                            JValue.SetValue(TmpBool);
                        end;
                    FieldType::Code,
                    FieldType::Text:
                        begin
                            TmpText := FldRef.Value;
                            JValue.SetValue(TmpText);
                        end;
                    FieldType::Date:
                        begin
                            TmpDate := FldRef.Value;
                            JValue.SetValue(TmpDate);
                        end;
                    FieldType::Time:
                        begin
                            TmpTime := FldRef.Value;
                            JValue.SetValue(TmpTime);
                        end;
                    FieldType::DateFormula:
                        begin
                            TmpDateFmla := FldRef.Value;
                            JValue.SetValue(Format(TmpDateFmla, 0, 9));
                        end;
                    FieldType::Decimal:
                        begin
                            TmpDecimal := FldRef.Value;
                            JValue.SetValue(Format(TmpDecimal, 0, 9));
                        end;
                    FieldType::Guid:
                        begin
                            TmpGuid := FldRef.Value;
                            JValue.SetValue(Format(TmpGuid, 0, 9));
                        end;
                    FieldType::DateTime:
                        begin
                            TmpDateTime := FldRef.Value;
                            JValue.SetValue(TmpDateTime);
                        end;
                    FieldType::Media,
                    FieldType::MediaSet:
                        TmpInt := 0;    // do nothing
                    else
                        Error(UnsupportedErr, FldRef.Type());
                end;

                Result.Add(JName, JValue);
            end;
        end;
    end;

    /// <summary>
    /// Copy a JSON object to a record ref, each property equals to field
    /// </summary>
    procedure CopyJsonObjectToRecordRef(JObject: JsonObject; var RecRef: RecordRef)
    var
        TmpDateFmla: DateFormula;
        FldRef: FieldRef;
        I: Integer;
        JToken: JsonToken;
        JName: Text;
        TmpGuid: Guid;
        UnsupportedErr: Label 'Unsupported field type %1';
    begin
        for I := 1 to RecRef.FieldCount() do begin
            FldRef := RecRef.FieldIndex(I);
            JName := FormatJsonName(FldRef.Name());
            if JObject.Get(JName, JToken) then
                case FldRef.Type() of
                    FieldType::Integer:
                        FldRef.Value := JToken.AsValue().AsInteger();
                    FieldType::BigInteger:
                        FldRef.Value := JToken.AsValue().AsBigInteger();
                    FieldType::Code:
                        FldRef.Value := JToken.AsValue().AsCode();
                    FieldType::Text:
                        FldRef.Value := JToken.AsValue().AsText();
                    FieldType::Date:
                        FldRef.Value := JToken.AsValue().AsDate();      // yyyy-MM-dd
                    FieldType::Time:
                        FldRef.Value := JToken.AsValue().AsTime();      // HH:mm:ss.FFFFFFF
                    FieldType::Decimal:
                        FldRef.Value := JToken.AsValue().AsDecimal();
                    FieldType::Option:
                        FldRef.Value := JToken.AsValue().AsOption();
                    FieldType::Guid:
                        begin
                            Evaluate(TmpGuid, JToken.AsValue().AsText());
                            FldRef.Value := TmpGuid;
                        end;
                    FieldType::DateFormula:
                        begin
                            Evaluate(TmpDateFmla, JToken.AsValue().AsText());
                            FldRef.Value := TmpDateFmla;
                        end;
                    FieldType::Boolean:
                        FldRef.Value := JToken.AsValue().AsBoolean();
                    FieldType::DateTime:
                        FldRef.Value := JToken.AsValue().AsDecimal();   // 2009-06-15T13:45:30.0000000-07:00
                    else
                        Error(UnsupportedErr, FldRef.Type());
                end;
        end;
    end;
}
#endif