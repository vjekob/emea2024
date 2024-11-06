namespace Vjeko.Demos.Test;

using Vjeko.Demos;
using Microsoft.Sales.Customer;
using System.TestLibraries.Utilities;

codeunit 60001 "Test - Demo"
{
    Subtype = Test;

    var
        Assert: Codeunit "Library Assert";
        Demo: Codeunit Demo;

    [Test]
    procedure CreateCustomer()
    var
        Customer: Record Customer;
    begin
        // [GIVEN]

        // [WHEN] Invoking CreateCustomer
        Demo.CreateCustomer();

        // [THEN] Customer is created
        Customer.Get('DUMMY');
        Assert.AreEqual('Dummy Customer', Customer.Name, 'Customer name is not as expected');
    end;

}
