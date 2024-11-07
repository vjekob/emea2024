namespace Vjeko.Demos;

using Microsoft.Sales.Document;
using Microsoft.Sales.Setup;
using System.Security.User;
using Microsoft.Inventory.Item;

interface IProcessQuotes
{
    Access = Internal;

    procedure FindQuotes(var SalesHeader: Record "Sales Header"; Controller: Interface IProcessQuotes): Boolean;
    procedure MakeAndPostOrders(var SalesHeader: Record "Sales Header"; Controller: Interface IProcessQuotes);
    procedure GetDomesticPostingGroup(var SalesSetup: Record "Sales & Receivables Setup"): Code[20];
    procedure GetSalespersonCode(var UserSetup: Record "User Setup"; WithGui: Boolean): Code[20];
    procedure SetFilters(var SalesHeader: Record "Sales Header"; SalespersonCode: Code[20]; CustomerPostingGroup: Code[20]; AtDate: Date);
    procedure MakeAndPostOne(var SalesQuote: Record "Sales Header"; Controller: Interface IProcessQuotes; Converter: Interface IQuoteToOrder; Releaser: Interface IReleaseDocument; Poster: Interface IPostDocument);
    procedure GetItem(var SalesLine: Record "Sales Line"; var Item: Record Item);
    procedure SetLineFilters(var SalesQuote: Record "Sales Header"; var SalesLine: Record "Sales Line");
    procedure IsLineApplicable(var SalesLine: Record "Sales Line"; var Item: Record Item; Controller: Interface IProcessQuotes): Boolean;
    procedure LogError(EventId: Text; ErrorMessage: Text);
    procedure ConvertQuoteToOrder(var SalesQuote: Record "Sales Header"; var SalesOrder: Record "Sales Header"; Controller: Interface IProcessQuotes; Converter: Interface IQuoteToOrder) Result: Boolean;
    procedure ReleaseOrder(var SalesOrder: Record "Sales Header"; Controller: Interface IProcessQuotes; Releaser: Interface IReleaseDocument) Result: Boolean;
    procedure PostOrder(var SalesOrder: Record "Sales Header"; Controller: Interface IProcessQuotes; Poster: Interface IPostDocument) Result: Boolean;
    procedure CommitTransaction();
}
