public with sharing class PurchaseOrderLineItemController {

    @AuraEnabled
    public static Id createPurchaseOrderLineItem(Id productId, Id purchaseOrderId, Integer quantity, Integer price) {
        try {
            Purchase_Order_Line_Item__c lineItem = new Purchase_Order_Line_Item__c(
                    Product__c = productId,
                    Purchase_Order__c = purchaseOrderId,
                    Quantity__c = quantity,
                    Unit_Price__c = price
            );

            insert lineItem;
            return lineItem.Id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}