public with sharing class PurchaseOrderHandler extends AbstractTriggerHandler{
    private List<Purchase_Order__c> newPurchaseOrders;
    private Map<Id, Purchase_Order__c> newPurchaseOrdersById;
    private Map<Id, Purchase_Order__c> oldPurchaseOrdersById;

    public PurchaseOrderHandler(
            List<Purchase_Order__c> newValue,
            Map<Id, Purchase_Order__c> newValueById,
            Map<Id, Purchase_Order__c> oldValueById) {
        this.newPurchaseOrders = newValue;
        this.newPurchaseOrdersById = newValueById;
        this.oldPurchaseOrdersById = oldValueById;
    }

    public override void afterUpdate() {
        PurchaseOrderService.increaseProductQuantity(newPurchaseOrdersById, oldPurchaseOrdersById);
    }
}