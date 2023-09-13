codeunit 60003 "YNS Experience Upgrade"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        OnAfterUpgradePerCompany();
    end;

    [InternalEvent(false)]
    local procedure OnAfterUpgradePerCompany()
    begin
    end;
}