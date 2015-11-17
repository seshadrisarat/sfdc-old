/*
    Silverline modified an existing package to fit the business requirements of Hilliard Lyons.
    Code modifications include additions and removal of elements from the following package:
    https://github.com/SalesforceFoundation/Relationships/. See link for details about original code.
*/
/**
* \arg ClassName      		: Relationships
* \arg JIRATicket       	: HIL-9
* \arg CreatedOn        	: 16/DEC/2013
* \arg LastModifiedOn   	: 16/MAR/2015
* \arg CreatededBy      	: -
* \arg LastModifiedBy       : Pankaj Ganwani
* \arg Description      	: This class serves as the Relationship trigger handler to create, update, delete and undelete the inverse relationship records corresponding to the master relationship record as a result of trigger events insert, update, delete and undelete respectively.
*/
public with sharing class Relationships {

    public Relationships(){}
	
	static final Id contactToContactRecordtype;//variable to hold the contact to contact record type id of relationship object.
	static final String FIELDSET_NAME = 'AffiliationFieldSet';//holding the field set name
	static final String SOBJECT_NAME = 'Relationship__c';//holding the api name of Affiliation object.
	static Set<String> setFields = new Set<String>();//holding the fields of field set.
	
	static
	{
		//fetching record type id
		for(RecordType objRecordType : [SELECT Id FROM RecordType WHERE DeveloperName =:'Contact_To_Contact' AND SobjectType =:SOBJECT_NAME LIMIT 1])
		{
			contactToContactRecordtype = objRecordType.Id;
		}
		
		//fetching fields corresponding to field set.
		for(schema.FieldSetMember objFieldSetMember: Relationships_Utils.getFieldSetFlds(FIELDSET_NAME, SOBJECT_NAME))
		{
			setFields.add(objFieldSetMember.getFieldPath());
		}
	}
	
    public Relationships(Relationship__c[] Relationships, Relationship__c[] oldRelationships, Relationships_Utils.triggerAction ta) 
    {   
        List<Relationship__c> origrelationships = new List<Relationship__c>();
        List<Relationship__c> relationshipsToCreate = new List<Relationship__c>();
        List<Relationship__c> relationshipsToUpdate = new List<Relationship__c>();
        List<Relationship__c> relationshipsToDelete = new List<Relationship__c>();
        List<Relationship__c> reciprocalsToUpdate = new List<Relationship__c>();
        List<Relationship__c> lstUndeletedRelationship = new List<Relationship__c>();
        
        if (ta==Relationships_Utils.triggerAction.afterUpdate){
            Relationships_ProcessControl.hasRun = true;
        }
        Integer i = 0;      
        
        for(Relationship__c r : Relationships) 
        {
        	//checking for the contact to contact record type
            if(r.RecordTypeId == contactToContactRecordtype)
            {
            	//if trigger is fired on after insert or after undelete
	            if (ta==Relationships_Utils.triggerAction.afterInsert) 
	            {
	                if (r.ReciprocalRelationship__c == null)
	                {
	                    relationshipsToCreate.add(r);
	                }
	                if (r.ReciprocalRelationship__c != null) 
	                {
	                    reciprocalsToUpdate.add(r);
	                }
	            }
	
	            if (ta==Relationships_Utils.triggerAction.afterUpdate) 
	            {               
	                if (r.ReciprocalRelationship__c == oldRelationships[i].ReciprocalRelationship__c && r.Related_Account__c != null)
	                {
	                    relationshipsToUpdate.add(r);
	                    origRelationships.add(oldRelationships[i]);
	                }
	                if (r.Related_Account__c == null)
	                {
	                    relationshipsToDelete.add(r);
	                }
	            }
	
	            if (ta==Relationships_Utils.triggerAction.afterDelete) 
	            {
	                if (r.ReciprocalRelationship__c != null)
	                {
	                    relationshipsToDelete.add(r);
	                }
	            }
	            
	            //checking for undelete case of trigger.
	            if(ta==Relationships_Utils.triggerAction.afterUndelete)
	            {
	            	if (r.Related_Affiliation_Text__c == null)
	                {
	                    relationshipsToCreate.add(r);
	                }
	                else 
	                {
	                    lstUndeletedRelationship.add(r);
	                }
	            }
            }

            i += 1;
        }
        if (relationshipsToCreate.size() > 0 ) {
            createRelationship(relationshipsToCreate);
        }
        
        if(!lstUndeletedRelationship.isEmpty())
        	undeleteRecords(lstUndeletedRelationship);
        
        if (relationshipsToUpdate.size() > 0 ) {
            updateRelationship(relationshipsToUpdate, origRelationships);
        }
        if (reciprocalsToUpdate.size() > 0 ) {
            reciprocate(reciprocalsToUpdate);
        }
        if (relationshipsToUpdate.size() > 0 ) {
            updateRelationship(relationshipsToUpdate, origRelationships);
        }
        if (relationshipsToDelete.size() > 0 ) {
            deleteRelationship(relationshipsToDelete);
        }

        if (ta==Relationships_Utils.triggerAction.afterUpdate){
            Relationships_ProcessControl.hasRun = false;
        }

    }

    public static void deleteRelationship(Relationship__c[] relationships)
    {
        List<Id> relationshipsToDelete = new List<Id>();
        for(Relationship__c r : Relationships) 
        {
            if (r.ReciprocalRelationship__c != null)
            {
                relationshipsToDelete.add(r.ReciprocalRelationship__c);
            } else
            if (r.Related_Account__c == null)
            {
                relationshipsToDelete.add(r.Id);
            }
        }
        if ( relationshipsToDelete.size() > 0 )
        {
            Database.DeleteResult[] lsr = Database.delete(relationshipsToDelete, false);
        }
        
    }

    @future
    public static void deleteEmptyRelationships()
    {
        List<Relationship__c> relationshipsToDelete = new List<Relationship__c>();
        for (Relationship__c r : [Select Id from Relationship__c where Related_Account__c = null])
        {
            relationshipsToDelete.add(r);
        }
        if ( relationshipsToDelete.size() > 0 )
        {
            Database.DeleteResult[] lsr = Database.delete(relationshipsToDelete, false);
        }
    }
    
    public static void reciprocate(Relationship__c[] Relationships)
    {
        List<Relationship__c> relationshipsToUpdate = new List<Relationship__c>();
        List<Relationship__c> lstTempRel = new List<Relationship__c>();
        for(Relationship__c r : Relationships) 
        {
            Relationship__c copy = new Relationship__c(Id=r.ReciprocalRelationship__c, ReciprocalRelationship__c=r.Id);
            copy.Account__c = r.Related_Account__c;
            copy.Related_Account__c = r.Account__c;
            copy.Related_Affiliation_Text__c = r.Id;
            relationshipsToUpdate.add(assignValues(r,copy,setFields));
            lstTempRel.add(new Relationship__c(Id = r.Id, Related_Affiliation_Text__c = r.ReciprocalRelationship__c));
        }
        addType(Relationships, relationshipsToUpdate);
        relationshipsToUpdate.addAll(lstTempRel);
        update relationshipsToUpdate;
    }
    
    public static void createRelationship(Relationship__c[] Relationships)
    {
        Map<Id, Relationship__c> relationshipsToCreate = new Map<Id, Relationship__c>();
        List<Relationship__c> relationshipsToUpdate = new List<Relationship__c>();
                
        for(Relationship__c r : Relationships) 
        {
            Relationship__c copy = new Relationship__c();              
            copy.Account__c = r.Related_Account__c;
            copy.Related_Account__c = r.Account__c;
            copy.ReciprocalRelationship__c = r.Id;
            copy.Related_Affiliation_Text__c = r.Id;
            copy.SystemCreated__c = true;
            relationshipsToCreate.put(r.Id, assignValues(r,copy,setFields));
        }
        
        addType(Relationships, relationshipsToCreate.values());      
        Database.Saveresult[] sr = Database.insert(relationshipsToCreate.values(), false);
        
        for(Id relId : relationshipsToCreate.keyset())
        {
        	if(relId == relationshipsToCreate.get(relId).Related_Affiliation_Text__c)
        		relationshipsToUpdate.add(new Relationship__c(Id = relId, Related_Affiliation_Text__c = relationshipsToCreate.get(relId).Id));
        }
        
        Database.update(relationshipsToUpdate,false);
    }

    public static void updateRelationship(Relationship__c[] Relationships, Relationship__c[] oldRelationships)
    {       
        List<Relationship__c> originalRelationships = new List<Relationship__c>();
        List<Relationship__c> relationshipsToUpdate = new List<Relationship__c>();
        Integer counter = 0;        

        for(Relationship__c r : Relationships) 
        {
            if ((SL_DiffRecordUtil.recordDiff(r,oldRelationships[counter],setFields) || oldRelationships[counter].Related_Account__c!=r.Related_Account__c || oldRelationships[counter].Account__c!=r.Account__c) && r.ReciprocalRelationship__c != null)
            {
                Relationship__c copy = new Relationship__c(Id=r.ReciprocalRelationship__c);
                
                if(oldRelationships[counter].Related_Account__c!=r.Related_Account__c){
                    copy.Account__c = r.Related_Account__c;
                }
                
                if(oldRelationships[counter].Account__c!=r.Account__c){
                    copy.Related_Account__c = r.Account__c;
                }
                
                relationshipsToUpdate.add(assignValues(r,copy,setFields));
                originalRelationships.add(r);
            }
            counter += 1;
        }

        if (!originalRelationships.isEmpty() && !relationshipsToUpdate.isEmpty()){
            addType(originalRelationships, relationshipstoUpdate);
            Database.Saveresult[] sr = Database.update(relationshipsToUpdate,false);        
        }            
    }
    
    private static void undeleteRecords(List<Relationship__c> lstRelationship)
    {
    	List<Relationship__c> lstInverseRelationshipToUndelete = new List<Relationship__c>();// list to hold undeleted inverse records corresponding to the original undeleted records.
    	for(Relationship__c objRel : lstRelationship)
    	{
    		lstInverseRelationshipToUndelete.add(new Relationship__c(Id = objRel.Related_Affiliation_Text__c));
    	}
    	
    	if(!lstInverseRelationshipToUndelete.isEmpty())
    		Database.undelete(lstInverseRelationshipToUndelete, false);
    }
    
    /**
	* @author Pankaj Ganwani
	* @date 13/MAR/2015
	* @description This function is used to assign field values of fields contained in field set from source object to target object.
	*/
    private static Relationship__c assignValues(Relationship__c objFromRel, Relationship__c objToRel, Set<String> setFieldsFromFieldSet)
    {
    	for(String strFieldAPIName : setFieldsFromFieldSet)
    	{
    		objToRel.put(strFieldAPIName, objFromRel.get(strFieldAPIName));
    	}
    	return objToRel;
    }
    
    private static void addType(list<Relationship__c> rList, list<Relationship__c> rCopy){
        
        integer counter = 0;            
        map<string, Relationship_Type_Mapping__c> rlMap = Relationship_Type_Mapping__c.getAll().clone();
    
        for (string s : rlMap.keySet()){
            if (rlMap.get(s).Active__c != true){
                rlMap.remove(s);
            }
        }
        
        System.debug(rlMap);
    
        list<id> rIDs = new list<id>();
            
        for (Relationship__c r : rList){
            rIDs.add(r.Related_Account__c);
            rIDs.add(r.Account__c);
        }            
        
        String query_string = 'SELECT Id, Name FROM Account WHERE Id IN :rIDs';                   
            
        map<id, Account> cMap = new map<id, Account>((List<Account>)database.query(query_string));
        
        for(Relationship__c r : rList){
            
            Relationship__c copy = rCopy[counter];

            Account relatedAccount = cMap.get(r.Account__c);
      
            if(rlMap.containsKey(r.Type__c)){                       
                copy.Type__c = rlMap.get(r.Type__c).Matching_Type__c;                       
            }          
            
            else{
                copy.Type__c = r.Type__c;
            }                
            counter++;
        }            
    }
}