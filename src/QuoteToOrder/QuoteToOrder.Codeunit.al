namespace Vjeko.Demos;

using Microsoft.Sales.Document;

codeunit 50013 QuoteToOrder implements IQuoteToOrder
{
    Access = Internal;

    var
        QuoteToOrder: Codeunit "Sales-Quote to Order";

    procedure Convert(var SalesQuote: Record "Sales Header"): Boolean
    begin
        exit(QuoteToOrder.Run(SalesQuote));
    end;

    procedure GetSalesOrderHeader(var SalesOrder: Record "Sales Header")
    begin
        QuoteToOrder.GetSalesOrderHeader(SalesOrder);
    end;
}
