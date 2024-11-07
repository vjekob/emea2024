namespace Vjeko.Demos.Test;

using Microsoft.Sales.Document;
using Vjeko.Demos;

codeunit 60014 ReleaseDocumentMock implements IReleaseDocument
{
    Access = Internal;

    var
        ExpectedReleaseResult: Boolean;
        ReleaseInvoked: Boolean;

    procedure SetExpected_Release(Expected: Boolean)
    begin
        ExpectedReleaseResult := Expected;
    end;

    procedure IsInvoked_Release(): Boolean
    begin
        exit(ReleaseInvoked);
    end;

    procedure Release(var SalesHeader: Record "Sales Header"): Boolean;
    begin
        ReleaseInvoked := true;
        exit(ExpectedReleaseResult);
    end;
}