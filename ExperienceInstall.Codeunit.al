codeunit 60001 "YNS Experience Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        OnAfterInstallAppPerCompany();
    end;

    [InternalEvent(false)]
    local procedure OnAfterInstallAppPerCompany()
    begin
    end;
}