namespace Vjeko.Demos;

using System.Threading;
using Microsoft.Sales.Document;
using System.Security.User;
using Microsoft.Sales.Setup;
using Microsoft.Inventory.Item;

codeunit 50011 ProcessQuotes implements IProcessQuotes
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        ProcessQuotes();
    end;

    procedure ProcessQuotes()
    begin
        ProcessQuotes(this);
    end;

    internal procedure ProcessQuotes(Controller: Interface IProcessQuotes)
    var
        SalesQuote: Record "Sales Header";
    begin
        if not Controller.FindQuotes(SalesQuote, Controller) then
            exit;

        Controller.MakeAndPostOrders(SalesQuote, Controller);
    end;

    internal procedure FindQuotes(var SalesHeader: Record "Sales Header"; Controller: Interface IProcessQuotes): Boolean
    var
        UserSetup: Record "User Setup";
        SalesSetup: Record "Sales & Receivables Setup";
        SalespersonCode: Code[20];
        CustomerPostingGroup: Code[20];
        AtDate: Date;
    begin
        CustomerPostingGroup := Controller.GetDomesticPostingGroup(SalesSetup);
        SalespersonCode := Controller.GetSalespersonCode(UserSetup, false);
        AtDate := Today();

        Controller.SetFilters(SalesHeader, SalespersonCode, CustomerPostingGroup, AtDate);

        exit(SalesHeader.FindSet(true));
    end;

    internal procedure GetDomesticPostingGroup(var SalesSetup: Record "Sales & Receivables Setup"): Code[20]
    begin
        SalesSetup.Get();
        SalesSetup.TestField("VDE Domestic Cust. Post. Group");
        exit(SalesSetup."VDE Domestic Cust. Post. Group");
    end;

    internal procedure GetSalespersonCode(var UserSetup: Record "User Setup"; WithGui: Boolean): Code[20]
    begin
        if not UserSetup.Get(UserId) then
            exit;

        if UserSetup."Salespers./Purch. Code" = '' then
            if WithGui then
                UserSetup.TestField("Salespers./Purch. Code");

        exit(UserSetup."Salespers./Purch. Code");
    end;

    internal procedure SetFilters(var SalesHeader: Record "Sales Header"; SalespersonCode: Code[20]; CustomerPostingGroup: Code[20]; AtDate: Date)
    begin
        SalesHeader.SetRange("Document Type", "Sales Document Type"::Quote);
        SalesHeader.SetRange(Status, "Sales Document Status"::Open);
        SalesHeader.SetRange("Shipment Date", AtDate);
        SalesHeader.SetRange("Salesperson Code", SalespersonCode);
        SalesHeader.SetRange("Customer Posting Group", CustomerPostingGroup);
    end;

    internal procedure MakeAndPostOrders(var SalesQuote: Record "Sales Header"; Controller: Interface IProcessQuotes)
    var
        Converter: Codeunit QuoteToOrder;
        Releaser: Codeunit ReleaseDocument;
        Poster: Codeunit PostDocument;
    begin
        repeat
            Controller.MakeAndPostOne(SalesQuote, Controller, Converter, Releaser, Poster);
        until SalesQuote.Next() = 0;
    end;

    internal procedure MakeAndPostOne(var SalesQuote: Record "Sales Header"; Controller: Interface IProcessQuotes; Converter: Interface IQuoteToOrder; Releaser: Interface IReleaseDocument; Poster: Interface IPostDocument)
    var
        SalesOrder: Record "Sales Header";
    begin
        if not Controller.ConvertQuoteToOrder(SalesQuote, SalesOrder, Controller, Converter) then
            exit;
        Controller.CommitTransaction();

        if not Controller.ReleaseOrder(SalesOrder, Controller, Releaser) then
            exit;
        Controller.CommitTransaction();

        if not Controller.PostOrder(SalesOrder, Controller, Poster) then
            exit;
        Controller.CommitTransaction();
    end;

    internal procedure ConvertQuoteToOrder(var SalesQuote: Record "Sales Header"; var SalesOrder: Record "Sales Header"; Controller: Interface IProcessQuotes; Converter: Interface IQuoteToOrder) Result: Boolean
    begin
        Result := Converter.Convert(SalesQuote);
        if Result then
            Converter.GetSalesOrderHeader(SalesOrder)
        else
            Controller.LogError('VD-0001', StrSubstNo('Error converting quote %1 to order.', SalesQuote."No."));
    end;

    internal procedure ReleaseOrder(var SalesOrder: Record "Sales Header"; Controller: Interface IProcessQuotes; Releaser: Interface IReleaseDocument) Result: Boolean
    begin
        Result := Releaser.Release(SalesOrder);

        if not Result then
            Controller.LogError('VD-0002', StrSubstNo('Error releasing order %1.', SalesOrder."No."));
    end;

    internal procedure PostOrder(var SalesOrder: Record "Sales Header"; Controller: Interface IProcessQuotes; Poster: Interface IPostDocument) Result: Boolean
    begin
        Result := Poster.Post(SalesOrder, true, false);

        if not Result then
            Controller.LogError('VD-0003', StrSubstNo('Error posting order %1.', SalesOrder."No."));
    end;

    internal procedure CommitTransaction()
    begin
        Commit();
    end;

    internal procedure LogError(EventId: Text; ErrorMessage: Text)
    begin
        LogMessage(EventId, ErrorMessage, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, '', '');
    end;

    internal procedure HasApplicableLines(var SalesQuote: Record "Sales Header"; var SalesLine: Record "Sales Line"; Controller: Interface IProcessQuotes): Boolean
    var
        Item: Record Item;
    begin
        Controller.SetLineFilters(SalesQuote, SalesLine);
        if not SalesLine.FindSet(false) then
            exit(false);

        repeat
            if not Controller.IsLineApplicable(SalesLine, Item, Controller) then
                exit(false);
        until SalesLine.Next() = 0;

        exit(true);
    end;

    internal procedure SetLineFilters(var SalesQuote: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
        SalesLine.SetRange("Document Type", "Sales Document Type"::Quote);
        SalesLine.SetRange("Document No.", SalesQuote."No.");
        SalesLine.SetRange(Type, "Sales Line Type"::Item);
        SalesLine.SetFilter("No.", '<>%1', '');
    end;

    internal procedure IsLineApplicable(var SalesLine: Record "Sales Line"; var Item: Record Item; Controller: Interface IProcessQuotes): Boolean
    begin
        Controller.GetItem(SalesLine, Item);
        exit(Item.Inventory > 0);
    end;

    internal procedure GetItem(var SalesLine: Record "Sales Line"; var Item: Record Item);
    begin
        if SalesLine."Location Code" <> '' then
            Item.SetRange("Location Filter", SalesLine."Location Code");
        Item.SetAutoCalcFields(Inventory);
        Item.SetLoadFields(Inventory);
        Item.Get(SalesLine."No.");
    end;
}
