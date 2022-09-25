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

    public abstract void handler();
}