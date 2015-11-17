/**
 * @Author      : Edward Rivera
 * @ClassName   : SL_Operations_Request_Handler
 * @CreatedOn   : 20 Oct 2014
 * @Test        : SL_Test_OperationsRequest
 * @Description : This is the controller class for SL_Operations_Request trigger.
 */
public with sharing class SL_Operations_Request_Handler {
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;

    public static boolean isRecursion= false;

    /**
    * Constructor    : Initialise the global variables
    * @param      : isExecuting, size
    */
    public SL_Operations_Request_Handler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    /*
    @MethodName    : onBeforeInsert
    @param      : newList  (Trigger.new)
    @Description  : Not used
    */
    public void onBeforeInsert(List<Operations_Request__c> newList){
        try{
            //assignToHRQueue(newList);
        }
        // currently throwing up unhandled exceptions
        catch(Exception e){
        // do nothing
        }
    }
    /*
    @MethodName    : onAfterInsert
    @param      : newList  (Trigger.new), newMap(Trigger.newMap)
    @Description  : Share the new record with a private requester
    
    public void onAfterInsert(List<Operations_Request__c> newList, Map<ID, Operations_Request__c> newMap){
        try{
        }
        // currently throwing up unhandled exceptions
        catch(Exception e){
        // do nothing
            throw e;
        }
    }
    /*
    @MethodName    : onBeforeUpdate
    @param      : newList  (Trigger.new), newMap(Trigger.newMap)
    @Description  : Share the new record with a private requester
    
    public void onBeforeUpdate(Map<ID,Operations_Request__c> newMap, Map<ID, Operations_Request__c> oldMap){
        try{
            SL_Operations_Request_Sharing.shareWithRequester(newMap.values());
        }
        // currently throwing up unhandled exceptions
        catch(Exception e){
        // do nothing
            throw e;
        }
    }
    /*
    @MethodName    : onAfterUpdate
    @param      : newList  (Trigger.new), newMap(Trigger.newMap)
    @Description  : Share the new record with a private requester
    */
    public void onAfterUpdate(Map<ID,Operations_Request__c> newMap, Map<ID, Operations_Request__c> oldMap){
        try{
            SL_Operations_Request_Sharing.shareWithRequester(newMap.values());
        }
        // currently throwing up unhandled exceptions
        catch(Exception e){
        // do nothing
        }
    }
    /*
    @MethodName    : onBeforeDelete
    @param      : oldList  (Trigger.old), oldMap(Trigger.oldMap)
    @Description  : Not used
    
    public void onBeforeDelete(Map<Id, Operations_Request__c> oldMap){
        try{

        }
        // currently throwing up unhandled exceptions
        catch(Exception e){
        // do nothing
            throw e;
        }
    
    }
    /*
    @MethodName    : onAfterDelete
    @param      : oldList  (Trigger.old), oldMap(Trigger.oldMap)
    @Description  : Not used
    
    public void onAfterDelete(List<Operations_Request__c> oldList, Map<Id, Operations_Request__c> oldMap){
        try{
        }
        // currently throwing up unhandled exceptions
        catch(Exception e){
        // do nothing
            throw e;
        }
    
    }   
    /*
    @MethodName    : assignToHRQueue
    @param      : requests - a list of new Operations Requests
    @Description  : All requests of type 'People Services (Private)' are assigned to the appropriate queue
    
    public void assignToHRQueue(List<Operations_Request__c> requests){
        Group HRQueue = [SELECT Id FROM Group WHERE name = 'People Services (Private) Queue' AND type = 'Queue' LIMIT 1];
        for(Operations_Request__c request: requests){
            if (request.Private__c){
                request.ownerId=HRQueue.ID;
            }
        }

    }*/
}