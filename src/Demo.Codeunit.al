namespace Vjeko.Demos;

using Microsoft.Sales.Customer;
using Microsoft.Sales.Setup;

codeunit 50000 Demo
{
    procedure CreateCustomer(No: Code[20]; Name: Text[100])
    var
        Customer: Record Customer;
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        SalesSetup.Get();

        Customer."No." := No;
        Customer.Name := Name;
        Customer."Customer Posting Group" := SalesSetup."Default Cust. Posting Group";
        Customer.Insert(false);
    end;
}
