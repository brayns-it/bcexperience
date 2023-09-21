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
        tabledata "YNS Doc. Exchange Reference" = RIMD,
        tabledata "YNS Doc. Exchange Ref. Line" = RIMD,
        tabledata "YNS Doc. Exchange Profile" = RIMD,
        tabledata "YNS Doc. Exchange Entry" = RIMD,
        tabledata "YNS Doc. Exchange Metadata" = RIMD,
        table "YNS Doc. Exchange Reference" = X,
        table "YNS Doc. Exchange Ref. Line" = X,
        table "YNS Doc. Exchange Profile" = X,
        table "YNS Doc. Exchange Entry" = X,
        table "YNS Doc. Exchange Metadata" = X,
#endif        
#if ITXX002A
        tabledata "YNS Italy E-Invoice Setup" = RIMD,
        table "YNS Italy E-Invoice Setup" = X,
#endif        
        tabledata "YNS File Storage" = RIMD,
        table "YNS File Storage" = X,
        codeunit "YNS Experience Install" = X,
        codeunit "YNS Experience Upgrade" = X;
}