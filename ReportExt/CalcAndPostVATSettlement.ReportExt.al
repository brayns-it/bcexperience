reportextension 60000 YNSCalcAndPostVATSettlement extends "Calc. and Post VAT Settlement"
{
    dataset
    {
#if ITXX008A        
        modify("VAT Posting Setup")
        {
            trigger OnAfterPostDataItem()
            var
                PriorPeriodVATEntry: Record "Periodic Settlement VAT Entry";
                GLSetup: Record "General Ledger Setup";
                VatEntry: Record "VAT Entry";
            begin
                if CurrReport.PostSettlement then begin
                    GLSetup.Get();

                    PriorPeriodVATEntry.Get(Format(Date2DMY(GLSetup."Last Settlement Date", 3)) + '/' +
                      ConvertStr(Format(Date2DMY(GLSetup."Last Settlement Date", 2), 2), ' ', '0'));

                    VatEntry.Reset();
                    VatEntry.SetRange("VAT Period", PriorPeriodVATEntry."VAT Period");

                    VatEntry.SetRange(Type, VatEntry.Type::Purchase);
                    VatEntry.CalcSums(Base, "Nondeductible Base", Amount, "Nondeductible Amount");
                    PriorPeriodVATEntry."YNS Purchase Amount" := VatEntry.Amount + VatEntry."Nondeductible Amount";
                    PriorPeriodVATEntry."YNS Purchase Base" := VatEntry.Base + VatEntry."Nondeductible Base";

                    VatEntry.SetRange(Type, VatEntry.Type::Sale);
                    VatEntry.CalcSums(Base, "Nondeductible Base", Amount, "Nondeductible Amount");
                    PriorPeriodVATEntry."YNS Sales Amount" := -(VatEntry.Amount + VatEntry."Nondeductible Amount");
                    PriorPeriodVATEntry."YNS Sales Base" := -(VatEntry.Base + VatEntry."Nondeductible Base");

                    PriorPeriodVATEntry.Modify();
                end;
            end;
        }
#endif
    }
}