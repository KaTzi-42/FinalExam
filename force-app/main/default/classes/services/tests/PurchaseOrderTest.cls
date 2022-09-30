@IsTest
private class PurchaseOrderTest {

    @IsTest
    static void increaseProductQuantityTriggerTest() {
        Account acc = TestDataFactory.createAccount(1, AccountRecordType.VENDOR, true)[0];
        Purchase_Order__c po = TestDataFactory.createPurchaseOrders(1, acc.Id, true)[0];
        Product2 product = TestDataFactory.createProducts(1, true)[0];

        PricebookEntry pe = TestDataFactory.createPricebookEntry(1, product.Id, true)[0];
        Purchase_Order_Line_Item__c item = TestDataFactory.createPurchaseOrderLineItems(1, po.Id, product.Id, true)[0];

        Test.startTest();
        po.Status__c = 'Completed';
        update po;
        Test.stopTest();

        System.assertEquals(1, [SELECT Quantity__c FROM Product2 WHERE Id = :product.Id]?.Quantity__c);
    }

    @IsTest
    static void increaseProductQuantityTriggerTest_Bulk() {
        Account acc = TestDataFactory.createAccount(1, AccountRecordType.VENDOR, true)[0];
        List<Purchase_Order__c> orders = TestDataFactory.createPurchaseOrders(200, acc.Id, true);
        List<Product2> products = TestDataFactory.createProducts(2, true);

        List<PricebookEntry> entries = TestDataFactory.createPricebookEntry(2, products[0].Id, false);
        entries[1].Product2Id = products[1].Id;
        insert entries;

        List<Purchase_Order_Line_Item__c> items = TestDataFactory.createPurchaseOrderLineItems(
                200, orders[0].Id, products[0].Id, false);

        for (Integer i = 0; i < 200; i++) {
            orders[i].Status__c = 'Completed';
            items[i].Product__c = products[Math.mod(i, 2)].Id;
            items[i].Purchase_Order__c = orders[i].Id;
        }
        insert items;

        Test.startTest();
        update orders;
        Test.stopTest();

        List<Product2> result = [SELECT Quantity__c FROM Product2];
        System.assertEquals(100, result[0].Quantity__c);
        System.assertEquals(100, result[1].Quantity__c);
    }

    @IsTest
    static void createPurchaseOrderTest() {
        Account acc = TestDataFactory.createAccount(1, AccountRecordType.VENDOR, true)[0];

        Test.startTest();
        Id resultId = PurchaseOrderController.createPurchaseOrder('po test', acc.Id);
        Test.stopTest();

        System.assertEquals(resultId, [SELECT Id FROM Purchase_Order__c]?.Id);
    }

    @IsTest
    static void createPurchaseOrderTest_Fail() {
        Account acc = TestDataFactory.createAccount(1, AccountRecordType.CUSTOMER, true)[0];
        Exception error = null;

        Test.startTest();
        try {
            Id resultId = PurchaseOrderController.createPurchaseOrder('po test', acc.Id);
        } catch (Exception e) {
            error = e;
        }
        Test.stopTest();

        System.assert(error != null);
    }
}