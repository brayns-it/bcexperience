codeunit 60020 "YNS Job Management"
{
#if W1JB001A    
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Post-Line", 'OnPostInvoiceContractLineOnBeforeCheckBillToCustomer', '', false, false)]
    local procedure OnPostInvoiceContractLineOnBeforeCheckBillToCustomer(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var JobPlanningLine: Record "Job Planning Line"; var IsHandled: Boolean)
    begin
        if SalesLine."YNS Sys.-Created Job Contract" then
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeUpdateSalesLineBeforePost', '', false, false)]
    local procedure OnBeforeUpdateSalesLineBeforePost(var SalesLine: Record "Sales Line"; var SalesHeader: Record "Sales Header"; WhseShip: Boolean; WhseReceive: Boolean; RoundingLineInserted: Boolean; CommitIsSuppressed: Boolean)
    var
        JobPlanning: Record "Job Planning Line";
        JobInvoice: Record "Job Planning Line Invoice";
        Line: Integer;
    begin
        if (SalesHeader."Document Type" in [SalesHeader."Document Type"::Invoice, SalesHeader."Document Type"::"Credit Memo"]) and
            (SalesLine."Job No." > '') and (SalesLine."Job Contract Entry No." = 0)
        then begin
            SalesLine.TestField("Job Task No.");

            Line := 10000;
            JobPlanning.Reset();
            JobPlanning.setrange("Job No.", SalesLine."Job No.");
            JobPlanning.setrange("Job Task No.", SalesLine."Job Task No.");
            if JobPlanning.FindLast() then
                Line += JobPlanning."Line No.";

            JobPlanning.Init();
            JobPlanning."Job No." := SalesLine."Job No.";
            JobPlanning."Job Task No." := SalesLine."Job Task No.";
            JobPlanning."Line No." := Line;
            JobPlanning.Validate("Line Type", JobPlanning."Line Type"::Billable);
            JobPlanning.Validate("Planning Date", SalesHeader."Posting Date");

            case SalesLine.type of
                SalesLine.Type::"G/L Account":
                    JobPlanning.Type := JobPlanning.Type::"G/L Account";
                SalesLine.Type::Resource:
                    JobPlanning.Type := JobPlanning.Type::Resource;
                SalesLine.Type::Item:
                    JobPlanning.Type := JobPlanning.Type::Item;
                else
                    SalesLine.FieldError(Type);
            end;

            JobPlanning.Validate("No.", SalesLine."No.");
            JobPlanning.Description := SalesLine.Description;
            JobPlanning.Validate("Location Code", SalesLine."Location Code");
            JobPlanning.Validate(Quantity, SalesLine.Quantity);
            JobPlanning.Validate("Unit of Measure Code", SalesLine."Unit of Measure Code");
            JobPlanning.Validate("Unit Price", SalesLine."Unit Price");
            JobPlanning.Validate("Line Discount %", SalesLine."Line Discount %");
            JobPlanning."Gen. Prod. Posting Group" := SalesLine."Gen. Prod. Posting Group";
            JobPlanning.Insert(true);

            JobInvoice.Init();
            JobInvoice."Job No." := JobPlanning."Job No.";
            JobInvoice."Job Task No." := JobPlanning."Job task No.";
            JobInvoice."Job Planning Line No." := JobPlanning."Line No.";
            JobInvoice."Document Type" := JobInvoice."Document Type"::Invoice;
            JobInvoice."Document No." := SalesHeader."No.";
            JobInvoice."Line No." := SalesLine."line No.";
            JobInvoice."Quantity Transferred" := SalesLine.Quantity;
            JobInvoice."Transferred Date" := SalesHeader."Posting Date";
            JobInvoice.Insert();

            SalesLine."Job Contract Entry No." := JobPlanning."Job Contract Entry No.";
            SalesLine."YNS Sys.-Created Job Contract" := true;
            SalesLine.Modify();
        end;
    end;
#endif    
}