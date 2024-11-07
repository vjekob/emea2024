namespace Vjeko.Demos;

using Microsoft.Sales.Document;
using Microsoft.Sales.Posting;

codeunit 50016 PostDocument implements IPostDocument
{
    Access = Internal;

    var
        SalesPost: Codeunit "Sales-Post";

    procedure Post(var SalesHeader: Record "Sales Header"; Ship: Boolean; Invoice: Boolean): Boolean;
    begin
        SalesHeader.Ship := Ship;
        SalesHeader.Invoice := Invoice;
        exit(SalesPost.Run(SalesHeader));
    end;
}
