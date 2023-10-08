codeunit 60015 "YNS Italy Management"
{
#if ITXX003A
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Reporting Triggers", 'SubstituteReport', '', false, false)]
    local procedure SubstituteReport(ReportId: Integer; RunMode: Option Normal,ParametersOnly,Execute,Print,SaveAs,RunModal; RequestPageXml: Text; RecordRef: RecordRef; var NewReportId: Integer)
    begin
        case ReportId of
            Report::"G/L Book - Print":
                NewReportId := report::"YNS G/L Book - Print";
            Report::"VAT Register - Print":
                NewReportId := Report::"YNS VAT Register - Print";
        end;
    end;
#endif
}