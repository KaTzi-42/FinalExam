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

    public override void handler() {
        switch on Trigger.operationType {
            when BEFORE_INSERT {
                this.beforeInsert();
            }
            when AFTER_INSERT {
                this.afterInsert();
            }
            when BEFORE_UPDATE {
                this.beforeUpdate();
            }
            when AFTER_UPDATE {
                this.afterUpdate();
            }
            when BEFORE_DELETE {
                this.beforeDelete();
            }
            when AFTER_DELETE {
                this.afterDelete();
            }
            when AFTER_UNDELETE {
                this.afterUndelete();
            }
        }
    }

    public override void afterUpdate() {
        OpportunityService.decreasedProductQuantity(newOpportunitiesById, oldOpportunitiesById);
    }
}