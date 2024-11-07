namespace Vjeko.Demos.Test;

using Microsoft.Sales.Document;
using Vjeko.Demos;

codeunit 50100 ProcessQuotesMock implements IProcessQuotes
{
    Access = Internal;

    var
        ExpectedFindQuotesResult: Boolean;
        FindQuotesInvoked: Boolean;
        MakeAndPostOrdersInvoked: Boolean;

    procedure SetExpected_FindQuotes(Expected: Boolean)
    begin
        ExpectedFindQuotesResult := Expected;
    end;

    procedure IsInvoked_FindQuotes(): Boolean
    begin
        exit(FindQuotesInvoked);
    end;

    procedure IsInvoked_MakeAndPostOrders(): Boolean
    begin
        exit(MakeAndPostOrdersInvoked);
    end;

    procedure FindQuotes(var SalesHeader: Record "Sales Header"): Boolean;
    begin
        FindQuotesInvoked := true;
        exit(ExpectedFindQuotesResult);
    end;

    procedure MakeAndPostOrders(var SalesHeader: Record "Sales Header");
    begin
        MakeAndPostOrdersInvoked := true;
    end;
}
