@IsTest
public with sharing class TestDataFactory {

    public static List<Opportunity> createOpportunities(Integer amount, Boolean doInsert) {
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < amount; i++) {
            opportunities.add(new Opportunity(
                    Name = 'Test Opportunity #' + i,
                    StageName = 'Perception Analysis',
                    CloseDate = Date.today().addDays(7)
            ));
        }

        if (doInsert) {
            insert opportunities;
        }
        return opportunities;
    }

    public static List<Product2> createProducts(Integer amount, Boolean doInsert) {
        List<Product2> products = new List<Product2>();
        for (Integer i = 0; i < amount; i++) {
            products.add(new Product2(
                    Name = 'Test Product #' + i,
                    ProductCode = 'code #' + i,
                    Quantity__c = 0,
                    IsActive = true
            ));
        }

        if (doInsert) {
            insert products;
        }
        return products;
    }

    public static List<PricebookEntry> createPricebookEntry(Integer amount, Id prodId, Boolean doInsert) {
        List<PricebookEntry> pbEntries = new List<PricebookEntry>();
        for (Integer i = 0; i < amount; i++) {
            pbEntries.add(new PricebookEntry(
                    Pricebook2Id = Test.getStandardPricebookId(),
                    Product2Id = prodId,
                    UnitPrice = 998,
                    IsActive = true
            ));
        }

        if (doInsert) {
            insert pbEntries;
        }
        return pbEntries;
    }

    public static List<OpportunityLineItem> createOppLineItems(
            Integer amount,
            Id prodId,
            Id oppId,
            Id priceBookEntryId,
            Boolean doInsert) {
        List<OpportunityLineItem> lineItems = new List<OpportunityLineItem>();
        for (Integer i = 0; i < amount; i++) {
            lineItems.add(new OpportunityLineItem(
                    Product2Id = prodId,
                    OpportunityId = oppId,
                    PricebookEntryId = priceBookEntryId,
                    UnitPrice = 999,
                    Quantity = 1
            ));
        }

        if (doInsert) {
            insert lineItems;
        }
        return lineItems;
    }

    public static List<OpportunityLineItem> createOppLineItemsByDefault(Integer amount, Boolean doInsert) {
        Id oppId = createOpportunities(1, true)[0]?.Id;
        Id prodId = createProducts(1, true)[0]?.Id;
        Id pbEntryId = createPricebookEntry(1, prodId, true)[0]?.Id;

        return createOppLineItems(amount, prodId, oppId, pbEntryId, doInsert);
    }

    public static List<Account> createAccount(Integer amount, AccountRecordType type, Boolean doInsert) {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < amount; i++) {
            accounts.add(new Account(
                    Name = 'Test Acc #' + i,
                    RecordTypeId = Schema.SObjectType.Account
                            .getRecordTypeInfosByName()
                            .get(type.name().toLowerCase().capitalize())
                            .getRecordTypeId()));
        }

        if (doInsert) {
            insert accounts;
        }
        return accounts;
    }

    public static List<Purchase_Order__c> createPurchaseOrders(Integer amount, Id accountId, Boolean doInsert) {
        List<Purchase_Order__c> orders = new List<Purchase_Order__c>();
        for (Integer i = 0; i < amount; i++) {
            orders.add(new Purchase_Order__c(
                    Name = 'Test Order #' + i,
                    Vendor__c = accountId
            ));
        }

        if (doInsert) {
            insert orders;
        }
        return orders;
    }

    public static List<Purchase_Order_Line_Item__c> createPurchaseOrderLineItems(
            Integer amount,
            Id purchaseOrderId,
            Id productId,
            Boolean doInsert) {
        List<Purchase_Order_Line_Item__c> items = new List<Purchase_Order_Line_Item__c>();
        for (Integer i = 0; i < amount; i++) {
            items.add(new Purchase_Order_Line_Item__c(
                    Purchase_Order__c = purchaseOrderId,
                    Product__c = productId,
                    Quantity__c = 1
            ));
        }

        if (doInsert) {
            insert items;
        }
        return items;
    }

}