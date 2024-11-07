namespace Vjeko.Demos;

using Microsoft.Sales.Document;

interface IQuoteToOrder
{
    Access = Internal;

    procedure Convert(var SalesQuote: Record "Sales Header"): Boolean;
    procedure GetSalesOrderHeader(var SalesOrder: Record "Sales Header");
}
