namespace Vjeko.Demos.Test;

using Vjeko.Demos;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Setup;
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
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        // [GIVEN] Default customer posting group
        SalesSetup.Get();
        SalesSetup."Default Cust. Posting Group" := 'DUMMY-GROUP';
        SalesSetup.Modify(true);

        // [WHEN] Invoking CreateCustomer
        Demo.CreateCustomer('DUMMY', 'Dummy Customer');

        // [THEN] Customer is created
        Customer.Get('DUMMY');
        Assert.AreEqual('Dummy Customer', Customer.Name, 'Customer name is not as expected');
        Assert.AreEqual('DUMMY-GROUP', Customer."Customer Posting Group", 'Customer posting group is not as expected');
    end;

    [Test]
    procedure CreateCustomer_NoDefaultGroup_Fails()
    var
        Customer: Record Customer;
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        // [GIVEN] No default customer posting group
        SalesSetup.Get();
        SalesSetup."Default Cust. Posting Group" := '';
        SalesSetup.Modify(true);

        // [WHEN] Invoking CreateCustomer
        asserterror Demo.CreateCustomer('DUMMY2', 'Dummy Customer');

        // [THEN] Customer is not created
        asserterror Customer.Get('DUMMY2');
    end;
}
