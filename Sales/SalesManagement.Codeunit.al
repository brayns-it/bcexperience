codeunit 60017 "YNS Sales Management"
{
#if W1SA001A
    [EventSubscriber(ObjectType::Table, database::"Standard Customer Sales Code", 'OnBeforeStdCustSalesCodesSetTableView', '', false, false)]
    local procedure OnBeforeStdCustSalesCodesSetTableView(var StandardCustomerSalesCode: Record "Standard Customer Sales Code"; var SalesHeader: Record "Sales Header")
    begin
        StandardCustomerSalesCode.FilterGroup := 2;
        StandardCustomerSalesCode.SetFilter("Customer No.", '%1|%2', '', SalesHeader."Sell-to Customer No.");
        StandardCustomerSalesCode.FilterGroup := 0;
    end;

    [EventSubscriber(ObjectType::Table, database::"Standard Customer Sales Code", 'OnBeforeApplyStdCodesToSalesLinesProcedure', '', false, false)]
    local procedure OnBeforeApplyStdCodesToSalesLinesProcedure(var SalesHeader: Record "Sales Header"; StandardCustomerSalesCode: Record "Standard Customer Sales Code"; var IsHandled: Boolean)
    begin
        if StandardCustomerSalesCode."Customer No." = '' then begin
            StandardCustomerSalesCode."Customer No." := SalesHeader."Sell-to Customer No.";
            StandardCustomerSalesCode.ApplyStdCodesToSalesLines(SalesHeader, StandardCustomerSalesCode);
            IsHandled := true;
        end;
    end;
#endif
}