namespace Vjeko.Demos;

using Microsoft.Inventory.Item;
using System.Threading;
using Microsoft.Sales.Document;
using Microsoft.Sales.Posting;
using Microsoft.Sales.Setup;
using System.Security.User;

codeunit 50011 ProcessQuotes
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        ProcessQuotes();
    end;

    procedure ProcessQuotes()
    var
        SalesQuote, SalesOrder : Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesSetup: Record "Sales & Receivables Setup";
        UserSetup: Record "User Setup";
        Item: Record Item;
        QuoteToOrder: Codeunit "Sales-Quote to Order";
        ReleaseDocument: Codeunit "Release Sales Document";
        SalesPost: Codeunit "Sales-Post";
        LinesOK: Boolean;
    begin
        SalesSetup.Get();
        SalesSetup.TestField("VDE Domestic Cust. Post. Group");
        if UserSetup.Get(UserId()) then
            if UserSetup."Salespers./Purch. Code" <> '' then
                SalesQuote.SetRange("Salesperson Code", UserSetup."Salespers./Purch. Code")
            else
                if GuiAllowed() then
                    UserSetup.TestField("Salespers./Purch. Code");

        SalesQuote.SetRange("Document Type", SalesQuote."Document Type"::Quote);
        SalesQuote.SetRange("Status", SalesQuote.Status::Open);
        SalesQuote.SetRange("Shipment Date", Today());
        SalesQuote.SetRange("Customer Posting Group", SalesSetup."VDE Domestic Cust. Post. Group");
        if SalesQuote.FindSet(true) then
            repeat
                LinesOK := false;
                SalesLine.SetRange("Document Type", SalesQuote."Document Type");
                SalesLine.SetRange("Document No.", SalesQuote."No.");
                SalesLine.SetRange(Type, "Sales Line Type"::Item);
                SalesLine.SetFilter("No.", '<>%1', '');
                if SalesLine.FindSet() then begin
                    LinesOK := true;
                    repeat
                        if SalesQuote."Location Code" <> '' then
                            Item.SetRange("Location Filter", SalesQuote."Location Code");
                        Item.SetAutoCalcFields(Inventory);
                        Item.SetLoadFields(Inventory);
                        Item.Get(SalesLine."No.");
                        if Item.Inventory <= 0 then
                            LinesOK := false;
                    until SalesLine.Next() = 0;
                end;

                if LinesOK then begin
                    if QuoteToOrder.Run(SalesQuote) then begin
                        Commit();
                        QuoteToOrder.GetSalesOrderHeader(SalesOrder);
                        if ReleaseDocument.Run(SalesOrder) then begin
                            Commit();

                            SalesOrder.Ship := true;
                            salesOrder.Invoice := false;
                            if SalesPost.Run(SalesOrder) then
                                Commit()
                            else
                                LogMessage('VD-0003', StrSubstNo('Error posting sales order %1.', SalesOrder."No."), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, '', '');
                        end else
                            LogMessage('VD-0002', StrSubstNo('Error releasing sales order %1.', SalesOrder."No."), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, '', '');
                    end else
                        LogMessage('VD-0001', StrSubstNo('Error converting quote %1 to order.', SalesQuote."No."), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, '', '');
                end;
            until SalesQuote.Next() = 0;
    end;
}
