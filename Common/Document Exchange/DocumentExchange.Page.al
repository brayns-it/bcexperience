#if W1XX004A
page 60040 "YNS Document Exchange"
{
    PageType = StandardDialog;
    SourceTable = "Name/Value Buffer";
    SourceTableTemporary = true;
    Caption = 'Document Exchange';
    DataCaptionExpression = GetCaption();
    Editable = false;
    ApplicationArea = All;
    UsageCategory = Tasks;

    layout
    {
        area(Content)
        {
            repeater(control1)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    var
        ExMgmt: Codeunit "YNS Doc. Exchange Management";

    trigger OnOpenPage()
    begin
        ExMgmt.GetAllProcessOptions(Rec);
        Rec.Reset();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        Log: Record "YNS Doc. Exchange Log";
        DocRefs: RecordRef;
        ActivityID: Guid;
    begin
        if CloseAction = Action::OK then begin
            ActivityID := ExMgmt.ProcessDocuments(Rec."Value Long", DocRefs);

            log.Reset();
            log.FilterGroup(2);
            log.SetRange("Activity ID", ActivityID);
            if not log.IsEmpty() then
                page.Run(Page::"YNS Doc. Exchange Log", Log);
        end;
    end;

    local procedure GetCaption(): Text
    begin
        exit('')
    end;
}
#endif