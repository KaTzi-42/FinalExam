public with sharing class PurchaseOrderService {

    public static void increaseProductQuantity(
            Map<Id, Purchase_Order__c> purchaseOrderMap,
            Map<Id, Purchase_Order__c> oldPurchaseOrderMap) {

        Set<Id> completedPurOrdersIds = new Set<Id>();
        for (Id key : purchaseOrderMap.keySet()) {
            if (purchaseOrderMap.get(key).Status__c == 'Completed' &&
                    oldPurchaseOrderMap.get(key).Status__c != 'Completed') {
                completedPurOrdersIds.add(key);
            }
        }

        if (completedPurOrdersIds.isEmpty()) {
            return;
        }

        List<Purchase_Order_Line_Item__c> lineItems =
                PurchaseOrderLineItemSelector.getPurOrderLineItemsWithProduct(completedPurOrdersIds);
        Map<Id, Product2> productsToUpdate = new Map<Id, Product2>();

        for (Purchase_Order_Line_Item__c item : lineItems) {
            item.Product__r.Quantity__c += item.Quantity__c;
            productsToUpdate.put(item.Product__c, item.Product__r);
        }

        update productsToUpdate.values();
    }
}