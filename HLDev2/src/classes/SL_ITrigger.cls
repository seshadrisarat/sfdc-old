/**
 * @description Interface containing methods Trigger Handlers must implement to
 *  enforce best practice and bulkification of triggers.
 *  (from Tony Scott's article
 *  http://developer.force.com/cookbook/recipe/trigger-pattern-for-tidy-streamlined-bulkified-triggers)
 */
public interface SL_ITrigger {
    /**
     * @description This method is called prior to execution of a BEFORE trigger. 
     * Use this to cache any data required into maps prior execution of the trigger.
     */
    void bulkBefore();
    
    /**
     * @description This method is called prior to execution of an AFTER trigger. 
     * Use this to cache any data required into maps prior execution of the trigger.
     */
    void bulkAfter();
    
    /**
     * @description This method is called iteratively for each record to be inserted 
     * during a BEFORE trigger. Never execute any SOQL/SOSL etc in this and other 
     * iterative methods.
     */
    void beforeInsert(SObject so);
    
    /**
     * @description This method is called iteratively for each record to be updated 
     * during a BEFORE trigger.
     */
    void beforeUpdate(SObject oldSo, SObject so);

    /**
     * @description This method is called iteratively for each record to be deleted 
     * during a BEFORE trigger.
     */
    void beforeDelete(SObject so);

    /**
     * @description This method is called iteratively for each record inserted during 
     * an AFTER trigger. Always put field validation in the 'After' methods in case 
     * another trigger has modified any values. The record is 'read only' by this 
     * point.
     */
    void afterInsert(SObject so);

    /**
     * @description This method is called iteratively for each record updated during 
     * an AFTER trigger.
     */
    void afterUpdate(SObject oldSo, SObject so);

    /**
     * @description This method is called iteratively for each record deleted during 
     * an AFTER trigger.
     */
    void afterDelete(SObject so);

    /**
     * @description This method is called iteratively for each record being undeleted
     */
    void afterUndelete(SObject so);

    /**
     * @description This method is called once all records have been processed by 
     * the trigger. Use this method to accomplish any final operations such as creation 
     * or updates of other records.
     */
    void andFinally();
}