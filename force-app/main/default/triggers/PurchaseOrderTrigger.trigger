trigger PurchaseOrderTrigger on Purchase_Order__c (after update) {
    new PurchaseOrderHandler(Trigger.new, Trigger.newMap, Trigger.oldMap).handler();
}