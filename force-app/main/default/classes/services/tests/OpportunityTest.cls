@IsTest
private class OpportunityTest {

    @IsTest
    static void decreasedProductQuantityTriggerTest() {
        Opportunity opp = TestDataFactory.createOpportunities(1, true)[0];
        opp.StageName = 'Closed Won';
        Product2 prod = TestDataFactory.createProducts(1, false)[0];
        prod.Quantity__c = 1;
        insert prod;

        PricebookEntry pbEntry = TestDataFactory.createPricebookEntry(1, prod.Id, true)[0];
        OpportunityLineItem item = TestDataFactory.createOppLineItems(1, prod.Id, opp.Id, pbEntry.Id, true)[0];

        Test.startTest();
        update opp;
        Test.stopTest();

        System.assertEquals(0, [SELECT Quantity__c FROM Product2 WHERE Id = :prod.Id]?.Quantity__c);
    }

    @IsTest
    static void decreasedProductQuantityTriggerTest_validationError() {
        Opportunity opp = TestDataFactory.createOpportunities(1, true)[0];
        opp.StageName = 'Closed Won';
        Product2 prod = TestDataFactory.createProducts(1, true)[0];

        PricebookEntry pbEntry = TestDataFactory.createPricebookEntry(1, prod.Id, true)[0];
        OpportunityLineItem item = TestDataFactory.createOppLineItems(1, prod.Id, opp.Id, pbEntry.Id, true)[0];
        Exception error = null;

        Test.startTest();
        try {
            update opp;
        } catch (Exception e) {
            error = e;
        }
        Test.stopTest();

        System.assert(error != null);
    }

    @IsTest
    static void decreasedProductQuantityTriggerTest_Bulk() {
        List<Opportunity> opportunities = TestDataFactory.createOpportunities(160, true);
        List<Product2> products = TestDataFactory.createProducts(2, false);
        products[0].Quantity__c = 80;
        products[1].Quantity__c = 80;
        insert products;

        List<PricebookEntry> pricebookEntries = TestDataFactory.createPricebookEntry(
                2, products[0].Id, false);
        pricebookEntries[1].Product2Id = products[1].Id;
        insert pricebookEntries;

        List<OpportunityLineItem> items = TestDataFactory.createOppLineItems(
                160, products[0].Id, opportunities[0].Id, pricebookEntries[0].Id, false);
        for (Integer i = 0; i < items.size(); i++) {
            Integer index = Math.mod(i, 2) == 0 ? 0 : 1;

            items[i].Product2Id = products[index].Id;
            items[i].PricebookEntryId = pricebookEntries[index].Id;
            items[i].OpportunityId = opportunities[i].Id;
            opportunities[i].StageName = 'Closed Won';
        }
        insert items;

        Test.startTest();
        update opportunities;
        Test.stopTest();

        System.assertEquals(0, [SELECT Quantity__c FROM Product2 WHERE Id = :products[0].Id]?.Quantity__c);
        System.assertEquals(0, [SELECT Quantity__c FROM Product2 WHERE Id = :products[1].Id]?.Quantity__c);
    }
}