
namespace Vjeko.Demos.Test;

using Microsoft.Sales.Document;
using Vjeko.Demos;

codeunit 60015 QuoteToOrderMock implements IQuoteToOrder
{
    Access = Internal;

    var
        ExpectedConvertResult: Boolean;
        ConvertInvoked: Boolean;
        GetSalesOrderHeaderInvoked: Boolean;

    procedure SetExpected_Convert(Expected: Boolean)
    begin
        ExpectedConvertResult := Expected;
    end;

    procedure IsInvoked_Convert(): Boolean
    begin
        exit(ConvertInvoked);
    end;

    procedure IsInvoked_GetSalesOrderHeader(): Boolean
    begin
        exit(GetSalesOrderHeaderInvoked);
    end;

    procedure Convert(var SalesQuote: Record "Sales Header"): Boolean;
    begin
        ConvertInvoked := true;
        exit(ExpectedConvertResult);
    end;

    procedure GetSalesOrderHeader(var SalesOrder: Record "Sales Header");
    begin
        GetSalesOrderHeaderInvoked := true;
    end;
}