permissionset 60000 YNSExperience
{
    Caption = 'Brayns Experience', Locked = true;
    Assignable = true;
    Permissions =
#if W1XX007A
        tabledata "YNS Remote Functions" = RIMD,
        table "YNS Remote Functions" = X,
#endif       
#if W1FN001A      
        codeunit "YNS Finance Management" = X,
        page "YNS Arrange CV Entries" = X,
#endif   
#if W1XX009A
        tabledata "YNS Partner Group" = RIMD,
        table "YNS Partner Group" = X,
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
        tabledata "YNS Doc. Exchange Log" = RIMD,
        tabledata "YNS FileSystem Transport Setup" = RIMD,
        table "YNS Doc. Exchange Reference" = X,
        table "YNS Doc. Exchange Ref. Line" = X,
        table "YNS Doc. Exchange Profile" = X,
        table "YNS Doc. Exchange Log" = X,
        table "YNS FileSystem Transport Setup" = X,
#endif        
#if W1SA003A
        tabledata "YNS Store Document" = RIMD,
        tabledata "YNS Store Document Line" = RIMD,
        tabledata "YNS Store Document Payment" = RIMD,
        tabledata "YNS Store Setup" = RIMD,
        table "YNS Store Document" = X,
        table "YNS Store Document Line" = X,
        table "YNS Store Document Payment" = X,
        table "YNS Store Setup" = X,
#endif     
#if W1PU002A
        tabledata "YNS Purchases Source" = RIMD,
        tabledata "YNS Purchases Source Line" = RIMD,
        tabledata "YNS Purchases Repository" = RIMD,
        table "YNS Purchases Source" = X,
        table "YNS Purchases Source Line" = X,
        table "YNS Purchases Repository" = X,
#endif
#if ITXX002A
        tabledata "YNS Italy E-Invoice Setup" = RIMD,
        tabledata "YNS Italy E-Invoice" = RIMD,
        table "YNS Italy E-Invoice Setup" = X,
        table "YNS Italy E-Invoice" = X,
#endif        
        tabledata "YNS File Storage" = RIMD,
        table "YNS File Storage" = X,
        codeunit "YNS Experience Install" = X,
        codeunit "YNS Experience Upgrade" = X;
}