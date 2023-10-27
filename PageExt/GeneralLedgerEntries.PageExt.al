pageextension 60011 YNSGeneralLedgerEntries extends "General Ledger Entries"
{
    layout
    {
        addlast(Control1)
        {
#if W1FN009A
            field(YNSBalance; GetEntryBalanceYNS(Rec."Entry No."))
            {
                Caption = 'Balance';
                Editable = false;
                ApplicationArea = All;
                BlankZero = true;
            }
#endif            
#if W1FN012A
            field("YNS Accrual Starting Date"; Rec."YNS Accrual Starting Date")
            {
                ApplicationArea = All;
            }
            field("YNS Accrual Ending Date"; Rec."YNS Accrual Ending Date")
            {
                ApplicationArea = All;
            }
#endif
        }
    }

    actions
    {
        addlast("F&unctions")
        {
#if W1XX008A            
            action(YNSDeleteDoc)
            {
                Image = Delete;
                Caption = 'Delete Document';
                ApplicationArea = All;

                trigger OnAction()
                var
                    LedgDeletion: Codeunit "YNS Ledger Deletion";
                begin
                    LedgDeletion.DeleteGLEntryYN(Rec);
                end;
            }
#endif            
#if W1FN009A
            action(YNSCalculateBalance)
            {
                Image = Balance;
                Caption = 'Calculate Balance';
                ApplicationArea = All;

                trigger OnAction()
                begin
                    CalculateBalanceYNS();
                    CurrPage.Update(false);
                end;
            }
#endif  
        }
    }

#if W1FN009A
    local procedure GetEntryBalanceYNS(EntryNo: Integer) Result: Decimal
    begin
        if not TempBalance.Get(EntryNo, Result) then
            Result := 0;
    end;

    local procedure CalculateBalanceYNS()
    var
        GLEntry: Record "G/L Entry";
        Amt: Decimal;
    begin
        Amt := 0;
        Clear(TempBalance);

        GLEntry.Copy(Rec);
        if GLEntry.FindSet() then
            repeat
                Amt += GLEntry.Amount;
                TempBalance.Add(GLEntry."Entry No.", Amt);
            until GLEntry.Next() = 0;
    end;
#endif

    var
#if W1FN009A    
        TempBalance: Dictionary of [Integer, Decimal];
#endif    
}