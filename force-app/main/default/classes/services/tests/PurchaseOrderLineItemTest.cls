@IsTest
private class PurchaseOrderLineItemTest {

    @IsTest
    static void createPurchaseOrderLineItem_FromController() {
        Account acc = TestDataFactory.createAccount(1, AccountRecordType.VENDOR, true)[0];
        Product2 product = TestDataFactory.createProducts(1, true)[0];
        Purchase_Order__c order = TestDataFactory.createPurchaseOrders(1, acc.Id, true)[0];

        Test.startTest();
        PurchaseOrderLineItemController.createPurchaseOrderLineItem(product.Id, order.Id, 2, 10);
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM Purchase_Order_Line_Item__c]);
    }

    @IsTest
    static void createPurchaseOrderLineItem_FromController_Fail() {
        Account acc = TestDataFactory.createAccount(1, AccountRecordType.VENDOR, true)[0];
        Product2 product = TestDataFactory.createProducts(1, true)[0];
        Purchase_Order__c order = TestDataFactory.createPurchaseOrders(1, acc.Id, true)[0];

        Exception error = null;

        Test.startTest();
        try {
            PurchaseOrderLineItemController.createPurchaseOrderLineItem(product.Id, order.Id, -1, 10);
        } catch (Exception e) {
            error = e;
        }
        Test.stopTest();

        System.assert(error != null);
    }
}