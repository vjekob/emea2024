namespace Vjeko.Demos;

using Microsoft.Sales.Setup;
using Microsoft.Sales.Customer;

tableextension 50001 SalesReceivablesSetup extends "Sales & Receivables Setup"
{
    fields
    {
        field(50000; "VDE Domestic Cust. Post. Group"; Code[20])
        {
            Caption = 'Domestic Customer Posting Group';
            TableRelation = "Customer Posting Group";
        }
    }
}
