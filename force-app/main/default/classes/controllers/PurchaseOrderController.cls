public with sharing class PurchaseOrderController {

    @AuraEnabled
    public static Id createPurchaseOrder(String name, Id vendorId) {
        try {
            Purchase_Order__c newOrder = new Purchase_Order__c(
                    Name = name,
                    Vendor__c = vendorId,
                    Status__c = (String) Purchase_Order__c.Status__c.getDescribe().defaultValue
            );

            insert newOrder;
            return newOrder.Id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}