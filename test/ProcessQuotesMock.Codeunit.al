namespace Vjeko.Demos.Test;

using Microsoft.Sales.Document;
using Vjeko.Demos;
using System.Security.User;
using Microsoft.Sales.Setup;

codeunit 50100 ProcessQuotesMock implements IProcessQuotes
{
    Access = Internal;

    var
        ExpectedFindQuotesResult: Boolean;
        FindQuotesInvoked: Boolean;
        MakeAndPostOrdersInvoked: Boolean;
        ExpectedGetDomesticPostingGroupResult: Code[20];
        ExpectedGetSalespersonCodeResult: Code[20];
        SetFiltersInvoked: Boolean;
        SetFilters_InvokedWith_SalespersonCode: Code[20];
        SetFilters_InvokedWith_CustomerPostingGroup: Code[20];
        SetFilters_InvokedWith_AtDate: Date;


    procedure SetExpected_FindQuotes(Expected: Boolean)
    begin
        ExpectedFindQuotesResult := Expected;
    end;

    procedure SetExpected_GetDomesticPostingGroup(Expected: Code[20])
    begin
        ExpectedGetDomesticPostingGroupResult := Expected;
    end;

    procedure SetExpected_GetSalespersonCode(Expected: Code[20])
    begin
        ExpectedGetSalespersonCodeResult := Expected;
    end;

    procedure IsInvoked_FindQuotes(): Boolean
    begin
        exit(FindQuotesInvoked);
    end;

    procedure IsInvoked_MakeAndPostOrders(): Boolean
    begin
        exit(MakeAndPostOrdersInvoked);
    end;

    procedure IsInvoked_SetFilters(WithSalespersonCode: Code[20]; WithCustomerPostingGroup: Code[20]; WithAtDate: Date): Boolean
    begin
        exit(SetFiltersInvoked and
            (SetFilters_InvokedWith_SalespersonCode = WithSalespersonCode) and
            (SetFilters_InvokedWith_CustomerPostingGroup = WithCustomerPostingGroup) and
            (SetFilters_InvokedWith_AtDate = WithAtDate));
    end;

    procedure FindQuotes(var SalesHeader: Record "Sales Header"; Controller: Interface IProcessQuotes): Boolean;
    begin
        FindQuotesInvoked := true;
        exit(ExpectedFindQuotesResult);
    end;

    procedure MakeAndPostOrders(var SalesHeader: Record "Sales Header");
    begin
        MakeAndPostOrdersInvoked := true;
    end;

    procedure GetDomesticPostingGroup(var SalesSetup: Record "Sales & Receivables Setup"): Code[20]
    begin
        exit(ExpectedGetDomesticPostingGroupResult);
    end;

    procedure GetSalespersonCode(var UserSetup: Record "User Setup"; WithGui: Boolean): Code[20]
    begin
        exit(ExpectedGetSalespersonCodeResult);
    end;

    procedure SetFilters(var SalesHeader: Record "Sales Header"; SalespersonCode: Code[20]; CustomerPostingGroup: Code[20]; AtDate: Date)
    begin
        SetFiltersInvoked := true;
        SetFilters_InvokedWith_SalespersonCode := SalespersonCode;
        SetFilters_InvokedWith_CustomerPostingGroup := CustomerPostingGroup;
        SetFilters_InvokedWith_AtDate := AtDate;
    end;
}
