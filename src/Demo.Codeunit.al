namespace Vjeko.Demos;

using Microsoft.Sales.Customer;

codeunit 50000 Demo
{
    procedure CreateCustomer(No: Code[20]; Name: Text[100])
    var
        Customer: Record Customer;
    begin
        Customer."No." := No;
        Customer.Name := Name;
        Customer.Insert(false);
    end;
}
