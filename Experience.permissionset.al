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
#if W1XX004A
        tabledata "YNS Data Exchange Reference" = RIMD,
        table "YNS Data Exchange Reference" = X,
        tabledata "YNS Data Exchange Ref. Line" = RIMD,
        table "YNS Data Exchange Ref. Line" = X,
#endif        
        codeunit "YNS Experience Install" = X,
        codeunit "YNS Experience Upgrade" = X;
}