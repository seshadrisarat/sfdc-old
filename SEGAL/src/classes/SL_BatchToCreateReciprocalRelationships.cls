/**
*  ClassName      : SL_BatchToCreateReciprocalRelationships
*  JIRATicket     : SEGAL-5
*  CreatedOn      : 9/JAN/2015
*  ModifiedBy     : Sanath Kumar
*  Description    : This is the batch to create reciprocal records
*/
global class SL_BatchToCreateReciprocalRelationships implements Database.Batchable<Sobject> 
{
	///Get Id of different recordtypes
	static final Id CONTACT_TO_CONTACT_RECORDTYPEID = [SELECT ID FROM RecordType WHERE sObjectType = 'Relationships__c' AND DeveloperName ='Contact_to_Contact'].ID;
	static final Id ENTITY_TO_ENTITY_RECORDTYPEID = [SELECT ID FROM RecordType WHERE sObjectType = 'Relationships__c' AND DeveloperName ='Entity_to_Entity'].ID;
	
	/*
        * MethodName : start
        * param      : Database.BatchableContext
        * Description: This is the start method to pass the query records to execute method
    */
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
    	List<Schema.FieldSetMember> lstFieldSetMember  =  sObjectType.Relationships__c.FieldSets.Relationship_Field_Set.getFields();
    	
    	Set<String> setDirectlyQueriedFields = new Set<String>{'Contact1__c','Contact2__c','Entity1__c','Entity2__c','RecordtypeId',
		                                                       'Primary_Relationship_Type__c','Reciprocal_Relationship_Type__c',
		                                                       'IsPrimary__c','Primary_Reciprocal_Relationship_Id__c'};
    	String Query ='';
    	Query += 'SELECT Id,RecordTypeId,Contact1__c,Contact2__c,Entity1__c,Entity2__c,Reciprocal_Relationship_Type__c,Primary_Relationship_Type__c';
    	
    	///Create dynamic query from field set
    	for(Schema.FieldSetMember objFieldsetMember:lstFieldSetMember)
    	{
    		if(!setDirectlyQueriedFields.contains(objFieldsetMember.getFieldPath()))
    		{
    			Query += ',' + objFieldsetMember.getFieldPath();
    		}
    	}
    	
    	Query += ' FROM Relationships__c WHERE IsPrimary__c = true';
    	
    	return Database.getQueryLocator(Query);
    }
    
    /*
        * MethodName : execute
        * param      : Database.BatchableContext and list of Relationships__c records
        * Description: This method is used to create reciprocal relationship records
    */
    global void execute(Database.BatchableContext BC, List<Relationships__c> lstRelationships)
    {
    	SL_GenericClassCreateReciprocalRelations objGenericClassCreateReciprocalRelations = new SL_GenericClassCreateReciprocalRelations(lstRelationships);
    }
    
     /*
        * MethodName : finish
        * param      : Database.BatchableContext
        * Description: This is the finish method of this batch process
    */
    global void finish(Database.BatchableContext BC)
    {
 		///Do nothing
    }
}