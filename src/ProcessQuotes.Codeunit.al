namespace Vjeko.Demos;

using System.Threading;
using Microsoft.Sales.Document;
using System.Security.User;
using Microsoft.Sales.Setup;

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

        Controller.MakeAndPostOrders(SalesQuote);
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

    internal procedure MakeAndPostOrders(var SalesHeader: Record "Sales Header")
    begin
    end;
}
