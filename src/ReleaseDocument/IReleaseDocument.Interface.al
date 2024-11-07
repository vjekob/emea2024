namespace Vjeko.Demos;

using Microsoft.Sales.Document;

interface IReleaseDocument
{
    Access = Internal;

    procedure Release(var SalesHeader: Record "Sales Header"): Boolean;
}
