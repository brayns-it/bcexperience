#if W1XX003A
/// <summary>
/// Bulk data import from JSON structured objects.
/// Create one codeunit instance for each import.
/// </summary>
codeunit 60005 "YNS Bulk Importer" implements "YNS Generic API"
{
    #region PERMISSIONS
    Permissions = tabledata "G/L Entry" = RIMD,
        tabledata "Cust. Ledger Entry" = RIMD,
        tabledata "Detailed Cust. Ledg. Entry" = RIMD,
        tabledata "Vendor Ledger Entry" = RIMD,
        tabledata "Detailed Vendor Ledg. Entry" = RIMD,
        tabledata "Item Ledger Entry" = RIMD,
        tabledata "Bank Account Ledger Entry" = RIMD,
        tabledata "VAT Entry" = RIMD,
        tabledata "G/L Entry - VAT Entry Link" = RIMD,
        tabledata "G/L Register" = RIMD,
        tabledata "FA Ledger Entry" = RIMD,
        tabledata "FA Register" = RIMD,
        tabledata "Sales Invoice Header" = RIMD,
        tabledata "Sales Invoice Line" = RIMD,
        tabledata "Sales Cr.Memo Header" = RIMD,
        tabledata "Sales Cr.Memo Line" = RIMD,
        tabledata "Purch. Inv. Header" = RIMD,
        tabledata "Purch. Inv. Line" = RIMD,
        tabledata "Purch. Cr. Memo Hdr." = RIMD,
        tabledata "Purch. Cr. Memo Line" = RIMD,
        tabledata "Dimension Set Entry" = RIMD,
        tabledata "Dimension Set Tree Node" = RIMD,
        tabledata "Issued Fin. Charge Memo Header" = RIMD,
        tabledata "Issued Fin. Charge Memo Line" = RIMD,
        tabledata "Reminder/Fin. Charge Entry" = RIMD;
    #endregion

    var
        Functions: Codeunit "YNS Functions";
        PropertyMap: Dictionary of [Text, Integer];
        Tags: Dictionary of [Text, Text];

    /// <summary>
    /// Set a custom tag to identify this instance (for events)
    /// </summary>
    procedure SetTag(TagKey: Text; TagValue: Text)
    begin
        if Tags.ContainsKey(TagKey) then
            Tags.Set(TagKey, TagValue)
        else
            Tags.Add(TagKey, TagValue);
    end;

    /// <summary>
    /// Get the custom tag to identify this instance (for events)
    /// </summary>
    procedure GetTag(TagKey: Text) Result: Text
    begin
        if not Tags.Get(TagKey, Result) then
            Result := '';
    end;

    /// <summary>
    /// Add mapping from JSON object property type to table ID
    /// </summary>
    procedure AddTable(PropertyName: Text; TableID: Integer);
    begin
        PropertyMap.Add(PropertyName, TableID);
    end;

    /// <summary>
    /// Remove all mapped tables
    /// </summary>
    procedure ClearTables()
    begin
        Clear(PropertyMap);
    end;

    /// <summary>
    /// Bulk import the table, doing modify if the record exists or insert.
    /// Each mapped property is searched recursively in the object and processed as array of objects.
    /// </summary>
    procedure ImportTable(var JObject: JsonObject)
    var
        RecRef: RecordRef;
        JItem: JsonObject;
        PropertyName: Text;
        TableID: Integer;
        IsHandled: Boolean;
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

                        IsHandled := false;
                        OnBeforeModifyRecord(JItem, RecRef, IsHandled);
                        if not IsHandled then
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
        ToUpper: Boolean;
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

        ToUpper := false;

        for I := 1 to StrLen(TempName) do begin
            Ch := TempName.Substring(I, 1);
            if Ch = ' ' then
                ToUpper := true
            else begin
                if ToUpper then
                    Result += Ch.ToUpper()
                else
                    Result += Ch.ToLower();
                ToUpper := false;
            end;
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
        SkipField: Boolean;
        UnsupportedErr: Label 'Unsupported field type %1';
    begin
        for I := 1 to RecRef.FieldCount() do begin
            FldRef := RecRef.FieldIndex(I);
            JName := FormatJsonName(FldRef.Name());

            if FldRef.Class() = FieldClass::Normal then begin
                SkipField := false;

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
                            if TmpDate = 0D then
                                JValue.SetValue('')
                            else
                                if TmpDate <> NormalDate(TmpDate) then
                                    JValue.SetValue('C' + Format(TmpDate, 0, '<Year4>-<Month,2>-<Day,2>'))
                                else
                                    JValue.SetValue(TmpDate);
                        end;
                    FieldType::Time:
                        begin
                            TmpTime := FldRef.Value;
                            if TmpTime = 0T then
                                JValue.SetValue('')
                            else
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
                            if TmpDateTime = 0DT then
                                JValue.SetValue('')
                            else
                                JValue.SetValue(TmpDateTime);
                        end;
                    FieldType::RecordId,
                    FieldType::Blob,
                    FieldType::Media,
                    FieldType::MediaSet:
                        SkipField := true;
                    else
                        Error(UnsupportedErr, FldRef.Type());
                end;

                if not SkipField then
                    Result.Add(JName, JValue);
            end;
        end;
    end;

    /// <summary>
    /// Copy a JSON object to a record ref, each property equals to field
    /// </summary>
    procedure CopyJsonObjectToRecordRef(var JObject: JsonObject; var RecRef: RecordRef)
    var
        TmpDateFmla: DateFormula;
        FldRef: FieldRef;
        I: Integer;
        JToken: JsonToken;
        JName: Text;
        TmpGuid: Guid;
        UnsupportedErr: Label 'Unsupported field type %1';
    begin
        OnBeforeCopyObject(JObject, RecRef.Number);

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
                        if JToken.AsValue().AsText() = '' then
                            FldRef.Value := 0D
                        else
                            if JToken.AsValue().AsText().StartsWith('C') then          // Cyyyy-MM-dd
                                FldRef.Value := ClosingDate(Functions.ConvertTextToDate(JToken.AsValue().AsText().Substring(2)))
                            else
                                FldRef.Value := JToken.AsValue().AsDate();             // yyyy-MM-dd
                    FieldType::Time:
                        if JToken.AsValue().AsText() = '' then
                            FldRef.Value := 0T
                        else
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
                        if JToken.AsValue().AsText() = '' then
                            FldRef.Value := 0DT
                        else
                            FldRef.Value := JToken.AsValue().AsDateTime();   // 2009-06-15T13:45:30.0000000-07:00
                    else
                        Error(UnsupportedErr, FldRef.Type());
                end;
        end;

        OnAfterCopyObject(JObject, RecRef);
    end;

    /// <summary>
    /// Api implementation
    /// </summary>
    procedure Invoke(ProcedureName: Text; Request: JsonObject): JsonObject
    var
        Objs: Record AllObj;
        RecRef: RecordRef;
        JItem: JsonObject;
        InvalidProcedureErr: Label 'Invalid procedure %1';
    begin
        Objs.Reset();
        Objs.SetRange("Object Type", Objs."Object Type"::Table);
        Objs.SetRange("Object Name", Functions.GetJsonPropertyAsText(Request, 'tableName'));
        Objs.FindFirst();

        RecRef.Open(Objs."Object ID");

        case ProcedureName of
            'TRUNCATE':
                RecRef.DeleteAll();
            'APPEND':
                foreach JItem in Functions.GetJsonPropertyAsObjectArray(Request, 'items') do begin
                    RecRef.Init();
                    CopyJsonObjectToRecordRef(JItem, RecRef);
                    RecRef.Insert();
                end;
            else
                Error(InvalidProcedureErr, ProcedureName);
        end;

        RecRef.Close();
    end;

    [InternalEvent(true)]
    local procedure OnBeforeCopyObject(var JObject: JsonObject; TableID: Integer)
    begin
    end;

    [InternalEvent(true)]
    local procedure OnAfterCopyObject(var JObject: JsonObject; var RecRef: RecordRef)
    begin
    end;

    [InternalEvent(true)]
    local procedure OnBeforeModifyRecord(var JObject: JsonObject; var RecRef: RecordRef; var IsHandled: Boolean)
    begin
    end;
}
#endif