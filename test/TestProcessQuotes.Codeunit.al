namespace Vjeko.Demos.Test;

using Vjeko.Demos;
using System.TestLibraries.Utilities;
using Microsoft.Sales.Setup;
using System.Security.User;
using Microsoft.Sales.Document;
using Microsoft.Inventory.Item;

codeunit 60003 "Test - ProcessQuotes"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        LibrarySales: Codeunit "Library - Sales";
        LibraryInventory: Codeunit "Library - Inventory";
        SUT: Codeunit ProcessQuotes;

    [Test]
    procedure ProcessQuotes_FindsNothing_DoesNothing()
    var
        MockProcessQuotes: Codeunit ProcessQuotesMock;
    begin
        // Assemble
        MockProcessQuotes.SetExpected_FindQuotes(false);

        // Act
        SUT.ProcessQuotes(MockProcessQuotes);

        // Assert
        Assert.IsFalse(MockProcessQuotes.IsInvoked_MakeAndPostOrders(), 'MakeAndPostOrders should not be invoked');
    end;

    [Test]
    procedure ProcessQuotes_FindsQuotes_MakesAndPostsOrders()
    var
        MockProcessQuotes: Codeunit ProcessQuotesMock;
    begin
        // Assemble
        MockProcessQuotes.SetExpected_FindQuotes(true);

        // Act
        SUT.ProcessQuotes(MockProcessQuotes);

        // Assert
        Assert.IsTrue(MockProcessQuotes.IsInvoked_MakeAndPostOrders(), 'MakeAndPostOrders should be invoked');
    end;

    [Test]
    procedure GetDomesticPostingGroup_NoGroup_Error()
    var
        TempSalesSetup: Record "Sales & Receivables Setup" temporary;
    begin
        // Assemble
        TempSalesSetup."VDE Domestic Cust. Post. Group" := '';
        TempSalesSetup.Insert();

        // Act
        asserterror SUT.GetDomesticPostingGroup(TempSalesSetup);

        // Assert
        Assert.ExpectedErrorCode('TestField');
    end;

    [Test]
    procedure GetDomesticPostingGroup_GroupExists_ReturnsGroup()
    var
        TempSalesSetup: Record "Sales & Receivables Setup" temporary;
        PostingGroup: Code[20];
    begin
        // Assemble
        TempSalesSetup."VDE Domestic Cust. Post. Group" := 'DUMMY';
        TempSalesSetup.Insert();

        // Act
        PostingGroup := SUT.GetDomesticPostingGroup(TempSalesSetup);

        // Assert
        Assert.AreEqual('DUMMY', PostingGroup, 'Posting group should be DOMESTIC');
    end;

    [Test]
    procedure GetSalespersonCode_NoUser_Blank()
    var
        TempUserSetup: Record "User Setup" temporary;
        SalespersonCode: Code[20];
    begin
        // Act
        SalespersonCode := SUT.GetSalespersonCode(TempUserSetup, true);

        // Assert
        Assert.AreEqual('', SalespersonCode, 'Salesperson code should be blank');
    end;

    [Test]
    procedure GetSalespersonCode_NoSalesperson_NoGui_Blank()
    var
        TempUserSetup: Record "User Setup" temporary;
        SalespersonCode: Code[20];
    begin
        // Assemble
        TempUserSetup."User ID" := UserId();
        TempUserSetup."Salespers./Purch. Code" := '';
        TempUserSetup.Insert();

        // Act
        SalespersonCode := SUT.GetSalespersonCode(TempUserSetup, false);

        // Assert
        Assert.AreEqual('', SalespersonCode, 'Salesperson code should be blank');
    end;

    [Test]
    procedure GetSalespersonCode_NoSalesperson_WithGui_Error()
    var
        TempUserSetup: Record "User Setup" temporary;
    begin
        // Assemble
        TempUserSetup."User ID" := UserId();
        TempUserSetup."Salespers./Purch. Code" := '';
        TempUserSetup.Insert();

        // Act
        asserterror SUT.GetSalespersonCode(TempUserSetup, true);

        // Assert
        Assert.ExpectedErrorCode('TestField');
    end;

    [Test]
    procedure GetSalespersonCode_SalespersonExists_ReturnsSalesperson()
    var
        TempUserSetup: Record "User Setup" temporary;
        SalespersonCode: Code[20];
    begin
        // Assemble
        TempUserSetup."User ID" := UserId();
        TempUserSetup."Salespers./Purch. Code" := 'DUMMY';
        TempUserSetup.Insert();

        // Act
        SalespersonCode := SUT.GetSalespersonCode(TempUserSetup, false);

        // Assert
        Assert.AreEqual('DUMMY', SalespersonCode, 'Salesperson code should be DUMMY');
    end;

    [Test]
    procedure SetFilters()
    var
        SalesHeader: Record "Sales Header";
        SalespersonCode: Code[20];
        AtDate: Date;
    begin
        // Act
        SUT.SetFilters(SalesHeader, 'DUMMYSP', 'DUMMYPG', 20001020D);

        // Assert
        Assert.AreEqual("Sales Document Type"::Quote, SalesHeader.GetRangeMax("Document Type"), 'Document type should be Quote');
        Assert.AreEqual("Sales Document Type"::Quote, SalesHeader.GetRangeMin("Document Type"), 'Document type should be Quote');
        Assert.AreEqual("Sales Document Status"::Open, SalesHeader.GetRangeMax(Status), 'Status should be Open');
        Assert.AreEqual("Sales Document Status"::Open, SalesHeader.GetRangeMin(Status), 'Status should be Open');
        Assert.AreEqual(20001020D, SalesHeader.GetRangeMax("Shipment Date"), 'Shipment date should be 2020-10-20');
        Assert.AreEqual(20001020D, SalesHeader.GetRangeMin("Shipment Date"), 'Shipment date should be 2020-10-20');
        Assert.AreEqual('DUMMYSP', SalesHeader.GetRangeMax("Salesperson Code"), 'Salesperson code should be DUMMY');
        Assert.AreEqual('DUMMYSP', SalesHeader.GetRangeMin("Salesperson Code"), 'Salesperson code should be DUMMY');
        Assert.AreEqual('DUMMYPG', SalesHeader.GetRangeMax("Customer Posting Group"), 'Customer posting group should be DUMMYSP');
        Assert.AreEqual('DUMMYPG', SalesHeader.GetRangeMin("Customer Posting Group"), 'Customer posting group should be DUMMYSP');
    end;

    [Test]
    procedure FindQuotes_NoQuotes_False()
    var
        TempSalesHeader: Record "Sales Header" temporary;
        MockProcessQuotes: Codeunit ProcessQuotesMock;
        Result: Boolean;
    begin
        // Assemble
        MockProcessQuotes.SetExpected_GetDomesticPostingGroup('DUMMYPG');
        MockProcessQuotes.SetExpected_GetSalespersonCode('DUMMYSP');

        // Act
        Result := SUT.FindQuotes(TempSalesHeader, MockProcessQuotes);

        // Assert
        Assert.IsFalse(Result, 'No quotes should be found');
    end;

    [Test]
    procedure FindQuotes_QuotesFound_True()
    var
        TempSalesHeader: Record "Sales Header" temporary;
        MockProcessQuotes: Codeunit ProcessQuotesMock;
        Result: Boolean;
    begin
        // Assemble
        MockProcessQuotes.SetExpected_GetDomesticPostingGroup('DUMMYPG');
        MockProcessQuotes.SetExpected_GetSalespersonCode('DUMMYSP');
        TempSalesHeader.Insert();

        // Act
        Result := SUT.FindQuotes(TempSalesHeader, MockProcessQuotes);

        // Assert
        Assert.IsTrue(Result, 'Quotes should be found');
    end;

    [Test]
    procedure FindQuotes_Collaboration()
    var
        TempSalesHeader: Record "Sales Header" temporary;
        MockProcessQuotes: Codeunit ProcessQuotesMock;
    begin
        // Assemble
        MockProcessQuotes.SetExpected_GetDomesticPostingGroup('DUMMYPG');
        MockProcessQuotes.SetExpected_GetSalespersonCode('DUMMYSP');

        // Act
        SUT.FindQuotes(TempSalesHeader, MockProcessQuotes);

        // Assert
        Assert.IsTrue(MockProcessQuotes.IsInvoked_SetFilters('DUMMYSP', 'DUMMYPG', Today()), 'SetFilters should be invoked');
    end;

    [Test]
    procedure MakeAndPostOrders_InvokesEachQuote()
    var
        TempSalesQuote: Record "Sales Header" temporary;
        MockProcessQuotes: Codeunit ProcessQuotesMock;
    begin
        // Assemble
        TempSalesQuote."No." := '1';
        TempSalesQuote.Insert();
        TempSalesQuote."No." := '2';
        TempSalesQuote.Insert();
        TempSalesQuote."No." := '3';
        TempSalesQuote.Insert();
        TempSalesQuote.FindSet();

        // Act
        SUT.MakeAndPostOrders(TempSalesQuote, MockProcessQuotes);

        // Assert
        Assert.AreEqual(3, MockProcessQuotes.CountInvoked_MakeAndPostOne(), 'MakeAndPostOne should be invoked for each quote');
    end;

    [Test]
    procedure GetItem()
    var
        ItemFixture, Item : Record Item;
        SalesLine: Record "Sales Line";
    begin
        // Assemble
        if not ItemFixture.FindFirst() then begin
            ItemFixture."No." := 'DUMMY';
            ItemFixture.Insert();
        end;
        SalesLine."No." := ItemFixture."No.";

        // Act
        SUT.GetItem(SalesLine, Item);

        // Assert
        Assert.AreEqual(ItemFixture."No.", Item."No.", 'Item should be found');
    end;

    [Test]
    procedure IsLineApplicable_HasInventory_ReturnsTrue()
    var
        Item: Record Item;
        SalesLine: Record "Sales Line";
        MockProcessQuotes: Codeunit ProcessQuotesMock;
        Result: Boolean;
    begin
        // Assemble
        Item.Inventory := 1;

        // Act
        Result := SUT.IsLineApplicable(SalesLine, Item, MockProcessQuotes);

        // Assert
        Assert.IsTrue(MockProcessQuotes.IsInvoked_GetItem(), 'GetItem should be invoked');
        Assert.IsTrue(Result, 'Line should be applicable');
    end;

    [Test]
    procedure IsLineApplicable_NoInventory_ReturnsFalse()
    var
        Item: Record Item;
        SalesLine: Record "Sales Line";
        MockProcessQuotes: Codeunit ProcessQuotesMock;
        Result: Boolean;
    begin
        // Assemble
        Item.Inventory := 0;

        // Act
        Result := SUT.IsLineApplicable(SalesLine, Item, MockProcessQuotes);

        // Assert
        Assert.IsTrue(MockProcessQuotes.IsInvoked_GetItem(), 'GetItem should be invoked');
        Assert.IsFalse(Result, 'Line should not be applicable');
    end;

    [Test]
    procedure SetLineFilters()
    var
        SalesQuote: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // Assemble
        SalesQuote."No." := '1';

        // Act
        SUT.SetLineFilters(SalesQuote, SalesLine);

        // Assert
        Assert.AreEqual("Sales Document Type"::Quote, SalesLine.GetRangeMax("Document Type"), 'Document type should be Quote');
        Assert.AreEqual("Sales Document Type"::Quote, SalesLine.GetRangeMin("Document Type"), 'Document type should be Quote');
        Assert.AreEqual(SalesQuote."No.", SalesLine.GetRangeMax("Document No."), 'Document no. should be the same as in the quote');
        Assert.AreEqual(SalesQuote."No.", SalesLine.GetRangeMin("Document No."), 'Document no. should be the same as in the quote');
        Assert.AreEqual("Sales Line Type"::Item, SalesLine.GetRangeMax(Type), 'Line type should be Item');
        Assert.AreEqual("Sales Line Type"::Item, SalesLine.GetRangeMin(Type), 'Line type should be Item');
        Assert.AreEqual('<>''''', SalesLine.GetFilter("No."), 'Item no. should be specified');
    end;

    [Test]
    procedure HasApplicableLines_NoLines_False()
    var
        TempSalesQuote: Record "Sales Header" temporary;
        TempSalesLine: Record "Sales Line" temporary;
        MockProcessQuotes: Codeunit ProcessQuotesMock;
        Result: Boolean;
    begin
        // Assemble
        TempSalesQuote."No." := '1';

        // Act
        Result := SUT.HasApplicableLines(TempSalesQuote, TempSalesLine, MockProcessQuotes);

        // Assert
        Assert.IsFalse(Result, 'No lines should be applicable');
        Assert.AreEqual(0, MockProcessQuotes.CountInvoked_IsLineApplicable(), 'IsLineApplicable should not be invoked');
    end;

    [Test]
    procedure HasApplicableLines_LinesFoundAndApplicable_True()
    var
        TempSalesQuote: Record "Sales Header" temporary;
        TempSalesLine: Record "Sales Line" temporary;
        MockProcessQuotes: Codeunit ProcessQuotesMock;
        Result: Boolean;
    begin
        // Assemble
        TempSalesLine."Line No." := 10000;
        TempSalesLine.Insert();
        TempSalesLine."Line No." := 20000;
        TempSalesLine.Insert();
        MockProcessQuotes.SetExpected_IsLineApplicable(true);
        MockProcessQuotes.SetExpected_IsLineApplicable(true);

        // Act
        Result := SUT.HasApplicableLines(TempSalesQuote, TempSalesLine, MockProcessQuotes);

        // Assert
        Assert.IsTrue(Result, 'Lines should be applicable');
        Assert.AreEqual(2, MockProcessQuotes.CountInvoked_IsLineApplicable(), 'IsLineApplicable should be invoked for each line');
    end;

    [Test]
    procedure HasApplicableLines_LinesFoundNotApplicable_False()
    var
        TempSalesQuote: Record "Sales Header" temporary;
        TempSalesLine: Record "Sales Line" temporary;
        MockProcessQuotes: Codeunit ProcessQuotesMock;
        Result: Boolean;
    begin
        // Assemble
        TempSalesLine."Line No." := 10000;
        TempSalesLine.Insert();
        TempSalesLine."Line No." := 20000;
        TempSalesLine.Insert();
        MockProcessQuotes.SetExpected_IsLineApplicable(true);
        MockProcessQuotes.SetExpected_IsLineApplicable(false);

        // Act
        Result := SUT.HasApplicableLines(TempSalesQuote, TempSalesLine, MockProcessQuotes);

        // Assert
        Assert.IsFalse(Result, 'Not all lines should be applicable');
        Assert.AreEqual(2, MockProcessQuotes.CountInvoked_IsLineApplicable(), 'IsLineApplicable should be invoked for each line');
    end;

    [Test]
    procedure ConvertQuoteToOrder_ConversionFails_LogsError()
    var
        TempSalesQuote: Record "Sales Header" temporary;
        TempSalesOrder: Record "Sales Header" temporary;
        MockProcessQuotes: Codeunit ProcessQuotesMock;
        MockQuoteToOrder: Codeunit QuoteToOrderMock;
    begin
        // Assemble
        MockQuoteToOrder.SetExpected_Convert(false);

        // Act
        SUT.ConvertQuoteToOrder(TempSalesQuote, TempSalesOrder, MockProcessQuotes, MockQuoteToOrder);

        // Assert
        Assert.IsTrue(MockProcessQuotes.IsInvoked_LogError('VD-0001', 'Error converting quote  to order.'), 'Error should be logged');
    end;

    [Test]
    procedure ConvertQuoteToOrder_ConversionSucceeds_ReturnsTrue()
    var
        TempSalesQuote: Record "Sales Header" temporary;
        TempSalesOrder: Record "Sales Header" temporary;
        MockProcessQuotes: Codeunit ProcessQuotesMock;
        MockQuoteToOrder: Codeunit QuoteToOrderMock;
        Result: Boolean;
    begin
        // Assemble
        MockQuoteToOrder.SetExpected_Convert(true);

        // Act
        Result := SUT.ConvertQuoteToOrder(TempSalesQuote, TempSalesOrder, MockProcessQuotes, MockQuoteToOrder);

        // Assert
        Assert.IsTrue(Result, 'Conversion should succeed');
    end;

    [Test]
    procedure ReleaseOrder_ReleaseFails_LogsError()
    var
        TempSalesOrder: Record "Sales Header" temporary;
        MockProcessQuotes: Codeunit ProcessQuotesMock;
        MockReleaser: Codeunit ReleaseDocumentMock;
    begin
        // Assemble
        MockReleaser.SetExpected_Release(false);

        // Act
        SUT.ReleaseOrder(TempSalesOrder, MockProcessQuotes, MockReleaser);

        // Assert
        Assert.IsTrue(MockProcessQuotes.IsInvoked_LogError('VD-0002', 'Error releasing order .'), 'Error should be logged');
    end;

    [Test]
    procedure ReleaseOrder_ReleaseSucceeds_ReturnsTrue()
    var
        TempSalesOrder: Record "Sales Header" temporary;
        MockProcessQuotes: Codeunit ProcessQuotesMock;
        MockReleaser: Codeunit ReleaseDocumentMock;
        Result: Boolean;
    begin
        // Assemble
        MockReleaser.SetExpected_Release(true);

        // Act
        Result := SUT.ReleaseOrder(TempSalesOrder, MockProcessQuotes, MockReleaser);

        // Assert
        Assert.IsTrue(Result, 'Release should succeed');
    end;

    [Test]
    procedure PostOrder_PostFails_LogsError()
    var
        TempSalesOrder: Record "Sales Header" temporary;
        MockProcessQuotes: Codeunit ProcessQuotesMock;
        MockPoster: Codeunit PostDocumentMock;
    begin
        // Assemble
        MockPoster.SetExpected_Post(false);

        // Act
        SUT.PostOrder(TempSalesOrder, MockProcessQuotes, MockPoster);

        // Assert
        Assert.IsTrue(MockProcessQuotes.IsInvoked_LogError('VD-0003', 'Error posting order .'), 'Error should be logged');
    end;

    [Test]
    procedure PostOrder_PostSucceeds_ReturnsTrue()
    var
        TempSalesOrder: Record "Sales Header" temporary;
        MockProcessQuotes: Codeunit ProcessQuotesMock;
        MockPoster: Codeunit PostDocumentMock;
        Result: Boolean;
    begin
        // Assemble
        MockPoster.SetExpected_Post(true);

        // Act
        Result := SUT.PostOrder(TempSalesOrder, MockProcessQuotes, MockPoster);

        // Assert
        Assert.IsTrue(Result, 'Post should succeed');
        Assert.IsTrue(MockPoster.IsInvoked_Post(true, false), 'Post should be invoked with Ship = true and Invoice = false');
    end;

    [Test]
    procedure MakeAndPostOne_ConversionFails_DoesNotRelease()
    var
        TempSalesQuote: Record "Sales Header" temporary;
        MockProcessQuotes: Codeunit ProcessQuotesMock;
        MockQuoteToOrder: Codeunit QuoteToOrderMock;
        MockReleaser: Codeunit ReleaseDocumentMock;
        MockPoster: Codeunit PostDocumentMock;
    begin
        // Assemble
        MockProcessQuotes.SetExpected_ConvertQuoteToOrder(false);

        // Act
        SUT.MakeAndPostOne(TempSalesQuote, MockProcessQuotes, MockQuoteToOrder, MockReleaser, MockPoster);

        // Assert
        Assert.IsFalse(MockProcessQuotes.IsInvoked_ReleaseOrder(), 'ReleaseOrder should not be invoked');
        Assert.IsFalse(MockProcessQuotes.IsInvoked_PostOrder(), 'PostOrder should not be invoked');
        Assert.AreEqual(0, MockProcessQuotes.CountInvoked_CommitTransaction(), 'CommitTransaction should not be invoked');
    end;

    [Test]
    procedure MakeAndPostOne_ConversionSucceeds_ReleaseFails_DoesNotPost()
    var
        TempSalesQuote: Record "Sales Header" temporary;
        MockProcessQuotes: Codeunit ProcessQuotesMock;
        MockQuoteToOrder: Codeunit QuoteToOrderMock;
        MockReleaser: Codeunit ReleaseDocumentMock;
        MockPoster: Codeunit PostDocumentMock;
    begin
        // Assemble
        MockProcessQuotes.SetExpected_ConvertQuoteToOrder(true);
        MockProcessQuotes.SetExpected_ReleaseOrder(false);

        // Act
        SUT.MakeAndPostOne(TempSalesQuote, MockProcessQuotes, MockQuoteToOrder, MockReleaser, MockPoster);

        // Assert
        Assert.IsFalse(MockProcessQuotes.IsInvoked_PostOrder(), 'PostOrder should not be invoked');
        Assert.AreEqual(1, MockProcessQuotes.CountInvoked_CommitTransaction(), 'CommitTransaction should not be invoked');
    end;

    [Test]
    procedure MakeAndPostOne_ConversionAndReleaseSucceed_PostFails()
    var
        TempSalesQuote: Record "Sales Header" temporary;
        MockProcessQuotes: Codeunit ProcessQuotesMock;
        MockQuoteToOrder: Codeunit QuoteToOrderMock;
        MockReleaser: Codeunit ReleaseDocumentMock;
        MockPoster: Codeunit PostDocumentMock;
    begin
        // Assemble
        MockProcessQuotes.SetExpected_ConvertQuoteToOrder(true);
        MockProcessQuotes.SetExpected_ReleaseOrder(true);
        MockProcessQuotes.SetExpected_PostOrder(false);

        // Act
        SUT.MakeAndPostOne(TempSalesQuote, MockProcessQuotes, MockQuoteToOrder, MockReleaser, MockPoster);

        // Assert
        Assert.AreEqual(2, MockProcessQuotes.CountInvoked_CommitTransaction(), 'CommitTransaction should be invoked');
    end;

    [Test]
    procedure MakeAndPostOne_AllSucceed()
    var
        TempSalesQuote: Record "Sales Header" temporary;
        MockProcessQuotes: Codeunit ProcessQuotesMock;
        MockQuoteToOrder: Codeunit QuoteToOrderMock;
        MockReleaser: Codeunit ReleaseDocumentMock;
        MockPoster: Codeunit PostDocumentMock;
    begin
        // Assemble
        MockProcessQuotes.SetExpected_ConvertQuoteToOrder(true);
        MockProcessQuotes.SetExpected_ReleaseOrder(true);
        MockProcessQuotes.SetExpected_PostOrder(true);

        // Act
        SUT.MakeAndPostOne(TempSalesQuote, MockProcessQuotes, MockQuoteToOrder, MockReleaser, MockPoster);

        // Assert
        Assert.AreEqual(3, MockProcessQuotes.CountInvoked_CommitTransaction(), 'CommitTransaction should be invoked');
    end;
}
