
namespace Vjeko.Demos;

using Microsoft.Sales.Document;

interface IPostDocument
{
    Access = Internal;

    procedure Post(var SalesHeader: Record "Sales Header"; Ship: Boolean; Invoice: Boolean): Boolean;
}