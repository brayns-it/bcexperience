#if LOCALEIT
pageextension 60031 YNSPeriodicVATSettlementCard extends "Periodic VAT Settlement Card"
{
    layout
    {
#if ITXX008A
        addlast(General)
        {
            field("YNS Periodic Communication No."; Rec."YNS Periodic Communication No.")
            {
                Editable = CommNoEditable;
                ApplicationArea = All;

                trigger OnAssistEdit()
                begin
                    CommNoEditable := not CommNoEditable;
                end;
            }
        }
        addfirst(Settlement)
        {
            field("YNS Sales Base"; Rec."YNS Sales Base")
            {
                ApplicationArea = All;
            }
            field("YNS Sales Amount"; Rec."YNS Sales Amount")
            {
                ApplicationArea = All;
            }
            field("YNS Purchase Base"; Rec."YNS Purchase Base")
            {
                ApplicationArea = All;
            }
            field("YNS Purchase Amount"; Rec."YNS Purchase Amount")
            {
                ApplicationArea = All;
            }
        }
#endif
    }

    var
#if ITXX008A
        CommNoEditable: Boolean;
#endif
}
#endif