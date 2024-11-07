namespace Vjeko.Demos;

using Microsoft.Sales.Document;

codeunit 50014 ReleaseDocument implements IReleaseDocument
{
    Access = Internal;

    var
        ReleaseDocument: Codeunit "Release Sales Document";

    procedure Release(var SalesHeader: Record "Sales Header"): Boolean;
    begin
        exit(ReleaseDocument.Run(SalesHeader));
    end;
}
