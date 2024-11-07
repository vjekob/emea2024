namespace Vjeko.Demos.Test;

using Vjeko.Demos;
using System.TestLibraries.Utilities;
using Microsoft.Sales.Setup;
using System.Security.User;
using Microsoft.Sales.Document;

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
        SUT.SetFilters(SalesHeader, 'DUMMY', 20001020D);

        // Assert
        Assert.AreEqual("Sales Document Type"::Quote, SalesHeader.GetRangeMax("Document Type"), 'Document type should be Quote');
        Assert.AreEqual("Sales Document Type"::Quote, SalesHeader.GetRangeMin("Document Type"), 'Document type should be Quote');
        Assert.AreEqual("Sales Document Status"::Open, SalesHeader.GetRangeMax(Status), 'Status should be Open');
        Assert.AreEqual("Sales Document Status"::Open, SalesHeader.GetRangeMin(Status), 'Status should be Open');
        Assert.AreEqual(20001020D, SalesHeader.GetRangeMax("Shipment Date"), 'Shipment date should be 2020-10-20');
        Assert.AreEqual(20001020D, SalesHeader.GetRangeMin("Shipment Date"), 'Shipment date should be 2020-10-20');
        Assert.AreEqual('DUMMY', SalesHeader.GetRangeMax("Salesperson Code"), 'Salesperson code should be DUMMY');
        Assert.AreEqual('DUMMY', SalesHeader.GetRangeMin("Salesperson Code"), 'Salesperson code should be DUMMY');
    end;
}
