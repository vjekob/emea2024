namespace Vjeko.Demos;

using Microsoft.Sales.Document;

pageextension 50000 SalesQuotesExt extends "Sales Quotes"
{
    actions
    {
        addlast(processing)
        {
            action(VDEProcessQuotes)
            {
                ApplicationArea = All;
                Caption = 'Process Quotes';
                ToolTip = 'Processes all quotes ready for shipment today';
                Image = Process;

                trigger OnAction()
                var
                    ProcessQuotes: Codeunit ProcessQuotes;
                begin
                    ProcessQuotes.ProcessQuotes();
                end;
            }
        }
    }
}
