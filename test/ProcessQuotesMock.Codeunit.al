namespace Vjeko.Demos.Test;

using Microsoft.Sales.Document;
using Vjeko.Demos;
using System.Security.User;
using Microsoft.Sales.Setup;
using Microsoft.Inventory.Item;

codeunit 60013 ProcessQuotesMock implements IProcessQuotes
{
    Access = Internal;

    var
        ExpectedFindQuotesResult: Boolean;
        FindQuotesInvoked: Boolean;
        MakeAndPostOrdersInvoked: Boolean;
        ExpectedGetDomesticPostingGroupResult: Code[20];
        ExpectedGetSalespersonCodeResult: Code[20];
        ExpectedIsLineApplicable: List of [Boolean];
        ExpectedConvertQuoteToOrderResult: Boolean;
        ExpectedReleaseOrderResult: Boolean;
        ExpectedPostOrderResult: Boolean;
        SetFiltersInvoked: Boolean;
        SetFilters_InvokedWith_SalespersonCode: Code[20];
        SetFilters_InvokedWith_CustomerPostingGroup: Code[20];
        SetFilters_InvokedWith_AtDate: Date;
        MakeAndPostOneInvokedCount: Integer;
        GetItemInvoked: Boolean;
        SetLineFiltersInvoked: Boolean;
        IsLineApplicableInvokedCount: Integer;
        LogErrorInvoked: Boolean;
        LogError_InvokedWith_EventId: Text;
        LogError_InvokedWith_ErrorMessage: Text;
        ConvertQuoteToOrderInvoked: Boolean;
        ReleaseOrderInvoked: Boolean;
        PostOrderInvoked: Boolean;
        CommitTransactionInvokedCount: Integer;

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

    procedure SetExpected_IsLineApplicable(Expected: Boolean)
    begin
        ExpectedIsLineApplicable.Add(Expected);
    end;

    procedure SetExpected_ConvertQuoteToOrder(Expected: Boolean)
    begin
        ExpectedConvertQuoteToOrderResult := Expected;
    end;

    procedure SetExpected_ReleaseOrder(Expected: Boolean)
    begin
        ExpectedReleaseOrderResult := Expected;
    end;

    procedure SetExpected_PostOrder(Expected: Boolean)
    begin
        ExpectedPostOrderResult := Expected;
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

    procedure CountInvoked_MakeAndPostOne(): Integer
    begin
        exit(MakeAndPostOneInvokedCount);
    end;

    procedure IsInvoked_GetItem(): Boolean
    begin
        exit(GetItemInvoked);
    end;

    procedure IsInvoked_SetLineFilters(): Boolean
    begin
        exit(SetLineFiltersInvoked);
    end;

    procedure CountInvoked_IsLineApplicable(): Integer
    begin
        exit(IsLineApplicableInvokedCount);
    end;

    procedure IsInvoked_LogError(WithEventId: Text; WithErrorMessage: Text): Boolean
    begin
        exit(LogErrorInvoked and
            (LogError_InvokedWith_EventId = WithEventId) and
            (LogError_InvokedWith_ErrorMessage = WithErrorMessage));
    end;

    procedure IsInvoked_ConvertQuoteToOrder(): Boolean
    begin
        exit(ConvertQuoteToOrderInvoked);
    end;

    procedure IsInvoked_ReleaseOrder(): Boolean
    begin
        exit(ReleaseOrderInvoked);
    end;

    procedure IsInvoked_PostOrder(): Boolean
    begin
        exit(PostOrderInvoked);
    end;

    procedure CountInvoked_CommitTransaction(): Integer
    begin
        exit(CommitTransactionInvokedCount);
    end;

    procedure FindQuotes(var SalesHeader: Record "Sales Header"; Controller: Interface IProcessQuotes): Boolean;
    begin
        FindQuotesInvoked := true;
        exit(ExpectedFindQuotesResult);
    end;

    procedure MakeAndPostOrders(var SalesHeader: Record "Sales Header"; Controller: Interface IProcessQuotes);
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

    procedure MakeAndPostOne(var SalesQuote: Record "Sales Header"; Controller: Interface IProcessQuotes; Converter: Interface IQuoteToOrder; Releaser: Interface IReleaseDocument; Poster: Interface IPostDocument)
    begin
        MakeAndPostOneInvokedCount += 1;
    end;

    procedure GetItem(var SalesLine: Record "Sales Line"; var Item: Record Item)
    begin
        GetItemInvoked := true;
    end;

    procedure SetLineFilters(var SalesQuote: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
        SetLineFiltersInvoked := true;
    end;

    procedure IsLineApplicable(var SalesLine: Record "Sales Line"; var Item: Record Item; Controller: Interface IProcessQuotes): Boolean
    begin
        IsLineApplicableInvokedCount += 1;
        exit(ExpectedIsLineApplicable.Get(IsLineApplicableInvokedCount));
    end;

    procedure LogError(EventId: Text; ErrorMessage: Text)
    begin
        LogErrorInvoked := true;
        LogError_InvokedWith_EventId := EventId;
        LogError_InvokedWith_ErrorMessage := ErrorMessage;
    end;

    procedure ConvertQuoteToOrder(var SalesQuote: Record "Sales Header"; var SalesOrder: Record "Sales Header"; Controller: Interface IProcessQuotes; Converter: Interface IQuoteToOrder) Result: Boolean
    begin
        ConvertQuoteToOrderInvoked := true;
        exit(ExpectedConvertQuoteToOrderResult);
    end;

    procedure ReleaseOrder(var SalesOrder: Record "Sales Header"; Controller: Interface IProcessQuotes; Releaser: Interface IReleaseDocument) Result: Boolean
    begin
        ReleaseOrderInvoked := true;
        exit(ExpectedReleaseOrderResult);
    end;

    procedure PostOrder(var SalesOrder: Record "Sales Header"; Controller: Interface IProcessQuotes; Poster: Interface IPostDocument) Result: Boolean
    begin
        PostOrderInvoked := true;
        exit(ExpectedPostOrderResult);
    end;

    procedure CommitTransaction()
    begin
        CommitTransactionInvokedCount += 1;
    end;
}
