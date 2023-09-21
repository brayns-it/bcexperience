codeunit 60006 "YNS Warehouse Management"
{
#if W1WH001A
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse. Jnl.-Register Line", 'OnDeleteFromBinContentOnBeforeFieldError', '', false, false)]
    local procedure OnDeleteFromBinContentOnBeforeFieldError(BinContent: Record "Bin Content"; WarehouseEntry: Record "Warehouse Entry"; var IsHandled: Boolean)
    var
        Bin: Record Bin;
    begin
        Bin.Get(BinContent."Location Code", BinContent."Bin Code");
        if Bin."YNS Allow Negative Quantity" then
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse. Jnl.-Register Line", 'OnBeforeDeleteFromBinContent', '', false, false)]
    local procedure OnBeforeDeleteFromBinContent(var WarehouseEntry: Record "Warehouse Entry"; var IsHandled: Boolean)
    var
        FromBinContent: Record "Bin Content";
        Bin: Record Bin;
    begin
        Clear(FromBinContent);
        FromBinContent."Location Code" := WarehouseEntry."Location Code";
        FromBinContent."Bin Code" := WarehouseEntry."Bin Code";
        FromBinContent."Item No." := WarehouseEntry."Item No.";
        FromBinContent."Variant Code" := WarehouseEntry."Variant Code";
        FromBinContent."Unit of Measure Code" := WarehouseEntry."Unit of Measure Code";
        FromBinContent.SetRecFilter();

        if FromBinContent.IsEmpty() then begin
            Bin.Get(FromBinContent."Location Code", FromBinContent."Bin Code");
            if Bin."YNS Allow Negative Quantity" then
                FromBinContent.Insert();
        end;
    end;
#endif
}
