public with sharing class OpportunityTriggerHandler extends AbstractTriggerHandler {
    private List<Opportunity> newOpportunities;
    private Map<Id, Opportunity> newOpportunitiesById;
    private Map<Id, Opportunity> oldOpportunitiesById;

    public OpportunityTriggerHandler(
            List<Opportunity> newValue,
            Map<Id, Opportunity> newValueById,
            Map<Id, Opportunity> oldValueById) {
        this.newOpportunities = newValue;
        this.newOpportunitiesById = newValueById;
        this.oldOpportunitiesById = oldValueById;
    }

    public override void afterUpdate() {
        OpportunityService.decreasedProductQuantity(newOpportunitiesById, oldOpportunitiesById);
    }
}