namespace Vjeko.Demos;

using Microsoft.Sales.Customer;

codeunit 50000 Demo
{
    procedure CreateCustomer()
    var
        Customer: Record Customer;
    begin
        Customer."No." := 'DUMMY';
        Customer.Name := 'Dummy Customer';
        Customer.Insert(false);
    end;
}
