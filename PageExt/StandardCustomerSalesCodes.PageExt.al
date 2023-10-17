pageextension 60026 YNSStandardCustomerSalesCodes extends "Standard Customer Sales Codes"
{
    actions
    {
        addlast(processing)
        {
#if W1SA001A
            action(YNSToggleForAll)
            {
                Caption = 'Enable for All Customers';
                Image = CustomerList;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                ApplicationArea = All;

                trigger OnAction()
                var
                    StdCodes: Record "Standard Customer Sales Code";
                    EnableQst: Label 'Enable %1 for all customers?';
                begin
                    if rec."Customer No." > '' then
                        if Confirm(EnableQst) then begin
                            StdCodes := Rec;
                            StdCodes."Customer No." := '';
                            StdCodes.Insert();
                            Rec.Delete();
                            CurrPage.Update(false);
                        end;
                end;
            }
#endif
        }
    }
}