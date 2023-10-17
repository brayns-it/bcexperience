codeunit 60016 "YNS Purchases Management"
{
#if W1PU001A
    [EventSubscriber(ObjectType::Table, database::"Purchase Line", 'OnAfterValidateTypePurchaseLine', '', false, false)]
    local procedure OnAfterValidateTypePurchaseLine(var PurchaseLine: Record "Purchase Line"; var xPurchaseLine: Record "Purchase Line"; var TempPurchaseLine: Record "Purchase Line" temporary)
    begin
        if xPurchaseLine."YNS Incoming Line" and (xPurchaseLine."No." = '') then begin
            PurchaseLine.Description := xPurchaseLine.Description;
            PurchaseLine."Unit of Measure Code" := xPurchaseLine."Unit of Measure Code";
            PurchaseLine.Quantity := xPurchaseLine.Quantity;
            PurchaseLine."Direct Unit Cost" := xPurchaseLine."Direct Unit Cost";
            PurchaseLine."Line Amount" := xPurchaseLine."Line Amount";
            PurchaseLine."Line Discount %" := xPurchaseLine."Line Discount %";
        end;

        PurchaseLine."YNS Incoming Line" := xPurchaseLine."YNS Incoming Line";
    end;

    [EventSubscriber(ObjectType::Table, database::"Purchase Line", 'OnAfterValidateNoPurchaseLine', '', false, false)]
    local procedure OnAfterValidateNoPurchaseLine(var PurchaseLine: Record "Purchase Line"; var xPurchaseLine: Record "Purchase Line"; var TempPurchaseLine: Record "Purchase Line" temporary; PurchaseHeader: Record "Purchase Header")
    var
        UoM: Record "Unit of Measure";
        ItemUoM: Record "Item Unit of Measure";
    begin
        if xPurchaseLine."YNS Incoming Line" and (xPurchaseLine."No." = '') then begin
            PurchaseLine.Description := xPurchaseLine.Description;

            case PurchaseLine.type of
                PurchaseLine.type::Item:
                    if ItemUoM.Get(PurchaseLine."No.", xPurchaseLine."Unit of Measure Code") then
                        PurchaseLine.Validate("Unit of Measure Code", xPurchaseLine."Unit of Measure Code");
                else
                    if UoM.Get(xPurchaseLine."Unit of Measure Code") then
                        PurchaseLine.Validate("Unit of Measure Code", xPurchaseLine."Unit of Measure Code");
            end;

            PurchaseLine.validate(Quantity, xPurchaseLine.Quantity);
            PurchaseLine.validate("Direct Unit Cost", xPurchaseLine."Direct Unit Cost");
            PurchaseLine.validate("Line Discount %", xPurchaseLine."Line Discount %");
        end;

        PurchaseLine."YNS Incoming Line" := xPurchaseLine."YNS Incoming Line";
    end;
#endif
}