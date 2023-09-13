#if W1FN002A
codeunit 60002 "YNS Repayment Management"
{
    local procedure InstallAndUpgrade()
    var
        RepaSetup: Record "YNS Repayment Setup";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        if not UpgradeTagMgt.HasUpgradeTag('YNS-W1FN002A-Install-20230913') then begin
            if not RepaSetup.Get() then begin
                Clear(RepaSetup);
                RepaSetup.Insert();
            end;
            UpgradeTagMgt.SetUpgradeTag('YNS-W1FN002A-Install-20230913');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"YNS Experience Install", 'OnAfterInstallAppPerCompany', '', false, false)]
    local procedure OnAfterInstallAppPerCompany()
    begin
        InstallAndUpgrade();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"YNS Experience Upgrade", 'OnAfterUpgradePerCompany', '', false, false)]
    local procedure OnAfterUpgradePerCompany()
    begin
        InstallAndUpgrade();
    end;
}
#endif