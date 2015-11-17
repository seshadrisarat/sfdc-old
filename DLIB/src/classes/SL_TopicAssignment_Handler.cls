/**
 * @Author      : Edward Rivera
 * @ClassName   : SL_TopicAssignment_Handler
 * @CreatedOn   : 3 Sep 2014
 * @Test        : SL_Test_TopicAssignment
 * @Description : This is the controller class for SL_TopicAssignment trigger.
 */
public with sharing class SL_TopicAssignment_Handler {
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    // a list of errors that arose while attempting to perform the trigger
	private List<SL_Opportunity_Error> errors;
    public static boolean isRecursion= false;
	public static List<Set<String>> masterSet = new List<Set<String>>();
    /**
    * Constructor    : Initialise the global variables
    * @param      : isExecuting, size
    */
    public SL_TopicAssignment_Handler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
        errors = new List<SL_Opportunity_error>();
    }
    /*
    @MethodName    : onBeforeInsert
    @param      : newList  (Trigger.new)
    @Description  : Not used
    */
    public void onBeforeInsert(List<TopicAssignment> newList){
        try{
            
        }
        catch(Exception e){
        // do nothing
        }
    }
    /*
    @MethodName    : onAfterInsert
    @param      : newList  (Trigger.new), newMap(Trigger.newMap)
    @Description  : To add to the Related Topic field
    */
    public void onAfterInsert(List<TopicAssignment> newList, Map<ID, TopicAssignment> newMap){
        try{
            List<SL_Opportunity_Error> newErrors;
            newErrors = SL_Opportunity_Topic_Updater.updateTopicsOnOpportunities(newList);
            if (newErrors!=null){
                errors.addAll(newErrors);
            }
        }
        catch(Exception e){
        // do nothing
        }
    }
    /*
    @MethodName    : onBeforeDelete
    @param      : oldList  (Trigger.old), oldMap(Trigger.oldMap)
    @Description  : Not used
    */
    public void onBeforeDelete(Map<Id, TopicAssignment> oldMap){
        try{

        }
        catch(Exception e){
        // do nothing
        }
    
    }
    /*
    @MethodName    : onAfterDelete
    @param      : oldList  (Trigger.old), oldMap(Trigger.oldMap)
    @Description  : To remove from the Related Topic field
    */
    public void onAfterDelete(List<TopicAssignment> oldList, Map<Id, TopicAssignment> oldMap){
        try{
            List<SL_Opportunity_Error> newErrors;
            // catch all errors from the field update
            newErrors = SL_Opportunity_Topic_Updater.updateTopicsOnOpportunities(oldList);
            // add them to the master list
            if (newErrors!=null){
                errors.addAll(newErrors);
            }
        }
        catch(Exception e){
        // do nothing
        }
    
    }
}