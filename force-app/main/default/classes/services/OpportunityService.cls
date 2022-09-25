public with sharing class OpportunityService {

    public static void decreasedProductQuantity(Map<Id, Opportunity> opportunityMap, Map<Id, Opportunity> oldOpportunityMap) {
        Set<Id> completeOpportunitiesIds = new Set<Id>();
        for (Id key : opportunityMap.keySet()) {
            if (opportunityMap.get(key).StageName == 'Closed Won' &&
                    oldOpportunityMap.get(key).StageName != 'Closed Won') {
                completeOpportunitiesIds.add(key);
            }
        }

        if (completeOpportunitiesIds.isEmpty()) {
            return;
        }

        List<OpportunityLineItem> oppItemWithProduct =
                OpportunitySelector.getOppItemWithProduct(completeOpportunitiesIds);

        List<Product2> productToDecrease = new List<Product2>();
        for (OpportunityLineItem opp : oppItemWithProduct) {
            if (opp.Product2.Quantity__c - opp.Quantity < 0) {
                opportunityMap.get(opp.OpportunityId).addError(
                        opp.Product2.Quantity__c + ' products (' + opp.Product2.Name + ') left in stock');
                return;
            }

            opp.Product2.Quantity__c -= opp.Quantity;
            productToDecrease.add(opp.Product2);
        }

        update productToDecrease;
    }
}