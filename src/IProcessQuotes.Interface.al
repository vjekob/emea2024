namespace Vjeko.Demos;

using Microsoft.Sales.Document;

interface IProcessQuotes
{
    Access = Internal;

    procedure FindQuotes(var SalesHeader: Record "Sales Header"): Boolean;
    procedure MakeAndPostOrders(var SalesHeader: Record "Sales Header");
}
