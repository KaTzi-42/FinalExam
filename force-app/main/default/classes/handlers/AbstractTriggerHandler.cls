public abstract class AbstractTriggerHandler {

    public virtual void beforeInsert() {
    }
    public virtual void afterInsert() {
    }
    public virtual void beforeUpdate() {
    }
    public virtual void afterUpdate() {
    }
    public virtual void beforeDelete() {
    }
    public virtual void afterDelete() {
    }
    public virtual void afterUndelete() {
    }
    public virtual void handler() {
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
}