/**
 * @description Used to instantiate and execute Trigger Handlers associated 
 *  with SObjects.
 *
 * (from Tony Scott's article
 * http://developer.force.com/cookbook/recipe/trigger-pattern-for-tidy-streamlined-bulkified-triggers)
 */
public class SL_TriggerFactory {
    /**
     * @description create the handler for the specified SObject 
     * @param obType the SObject type to handle; may not be null
     */
    public static void createHandler(SObjectType obType) {
        SL_ITrigger handler = SL_TriggerFactory.getHandler(obType);
        if (null == handler) {
            throw new SL.TriggerException('No trigger handler registered for object type: ' + obType);
        }
        
        SL_TriggerFactory.execute(handler);
    }
    
    /**
     * @description call various methods on the supplied handler based on the
     *   current trigger type.  
     * @param handler the handler; may not be null
     */
    private static void execute(SL_ITrigger handler) {
        if (Trigger.isBefore) {
            handler.BulkBefore();
            if (Trigger.isDelete) {
                for (SObject so : Trigger.old) {
                    handler.beforeDelete(so);
                }
            } else if (Trigger.isInsert) {
                for (SObject so : Trigger.new) {
                    handler.beforeInsert(so);
                }
            } else if (Trigger.isUpdate) {
                for (SObject so : Trigger.old) {
                    handler.beforeUpdate(so, Trigger.newMap.get(so.Id));
                }
            }
        } else {
            handler.bulkAfter();
            if (Trigger.isDelete) {
                for (SObject so : Trigger.old) {
                    handler.afterDelete(so);
                }
            } else if (Trigger.isInsert) {
                for (SObject so : Trigger.new) {
                    handler.afterInsert(so);
                }
            } else if (Trigger.isUpdate) {
                for (SObject so : Trigger.old) {
                    handler.afterUpdate(so, Trigger.newMap.get(so.Id));
                }
            } else if (Trigger.isUndelete) {
                for (SObject so : Trigger.new) {
                    handler.afterUndelete(so);
                }
            }
        }
        
        handler.andFinally();
    } 
    
    /**
     * @description get the handler for the specified SObject 
     * @param obType the SObject type; may not be null
     */
    private static SL_ITrigger getHandler(SObjectType obType) {
        // Add handlers here...
        if (Account.SObjectType == obType) {
            return new SL_AccountHandler();
        } else {
            return null;
        }
    }
}