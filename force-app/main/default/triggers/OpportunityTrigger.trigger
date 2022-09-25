trigger OpportunityTrigger on Opportunity (after update) {
    new OpportunityTriggerHandler(Trigger.new, Trigger.newMap, Trigger.oldMap).handler();
}