namespace Vjeko.Demos;

using Microsoft.Sales.Setup;

tableextension 50000 "Sales & Receivables Setup" extends "Sales & Receivables Setup"
{
    fields
    {
        field(50000; "Default Cust. Posting Group"; Code[20])
        {
            Caption = 'Default Customer Posting Group';
            ToolTip = 'Specifies the Customer Posting Group value that will be used by default for new customers.';
            DataClassification = CustomerContent;
        }
    }
}
