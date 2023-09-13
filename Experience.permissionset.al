permissionset 60000 YNSExperience
{
    Caption = 'Brayns Experience', Locked = true;
    Assignable = true;
    Permissions =
#if W1FN001A      
        codeunit "YNS Finance Management" = X,
        page "YNS Arrange CV Entries" = X,
#endif            
#if W1FN002A
        tabledata "YNS Issued Repayment Header" = RIMD,
        tabledata "YNS Issued Repayment Line" = RIMD,
        tabledata "YNS Repayment Header" = RIMD,
        tabledata "YNS Repayment Line" = RIMD,
        tabledata "YNS Repayment Setup" = RIMD,
        table "YNS Issued Repayment Header" = X,
        table "YNS Issued Repayment Line" = X,
        table "YNS Repayment Header" = X,
        table "YNS Repayment Line" = X,
        table "YNS Repayment Setup" = X,
        codeunit "YNS Repayment Management" = X,
#endif
        codeunit "YNS Experience Install" = X,
        codeunit "YNS Experience Upgrade" = X;
}