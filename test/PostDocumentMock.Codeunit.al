namespace Vjeko.Demos.Test;

using Microsoft.Sales.Document;
using Vjeko.Demos;

codeunit 60012 PostDocumentMock implements IPostDocument
{
    Access = Internal;

    var
        ExpectedPostResult: Boolean;
        PostInvoked: Boolean;
        Post_InvokedWith_Ship: Boolean;
        Post_InvokedWith_Invoice: Boolean;

    procedure SetExpected_Post(Expected: Boolean)
    begin
        ExpectedPostResult := Expected;
    end;

    procedure IsInvoked_Post(): Boolean
    begin
        exit(PostInvoked);
    end;

    procedure IsInvoked_Post(WithShip: Boolean; WithInvoice: Boolean): Boolean
    begin
        exit(PostInvoked and
            (Post_InvokedWith_Ship = WithShip) and
            (Post_InvokedWith_Invoice = WithInvoice));
    end;

    procedure Post(var SalesHeader: Record "Sales Header"; Ship: Boolean; Invoice: Boolean): Boolean;
    begin
        PostInvoked := true;
        Post_InvokedWith_Ship := Ship;
        Post_InvokedWith_Invoice := Invoice;
        exit(ExpectedPostResult);
    end;
}
