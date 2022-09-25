public with sharing class OpportunitySelector {

    public static List<OpportunityLineItem> getOppItemWithProduct(Set<Id> ids) {
        return [
                SELECT
                        Id,
                        OpportunityId,
                        Quantity,
                        Product2.Id,
                        Product2.Quantity__c,
                        Product2.Name
                FROM OpportunityLineItem
                WHERE OpportunityId IN :ids
        ];
    }
}