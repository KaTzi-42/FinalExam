public with sharing class PurchaseOrderLineItemSelector {

    public static List<Purchase_Order_Line_Item__c> getPurOrderLineItemsWithProduct(Set<Id> purOrderIds) {
        return [
                SELECT
                        Id, Quantity__c, Unit_Price__c,
                        Product__r.Quantity__c
                FROM Purchase_Order_Line_Item__c
                WHERE Purchase_Order__c IN :purOrderIds
        ];
    }
}