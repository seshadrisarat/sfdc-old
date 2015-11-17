/**
*  ClassName      : SL_GenericClassCreateReciprocalRelations
*  JIRATicket     : SEGAL-5
*  CreatedOn      : 9/JAN/2015
*  ModifiedBy     : Sanath Kumar
*  Description    : This is the Generic class to create reciprocal records
*/
global with sharing class SL_GenericClassCreateReciprocalRelations 
{
	///Get Id of different recordtypes
	static final Id CONTACT_TO_CONTACT_RECORDTYPEID = [SELECT ID FROM RecordType WHERE sObjectType = 'Relationships__c' AND DeveloperName ='Contact_to_Contact'].ID;
	static final Id ENTITY_TO_ENTITY_RECORDTYPEID = [SELECT ID FROM RecordType WHERE sObjectType = 'Relationships__c' AND DeveloperName ='Entity_to_Entity'].ID;
	
	///Constructor of the class
	public SL_GenericClassCreateReciprocalRelations(List<Relationships__c> lstRelationships)
	{
		List<Schema.FieldSetMember> lstFieldSetMember  =  sObjectType.Relationships__c.FieldSets.Relationship_Field_Set.getFields();
    	sObject objInverseRelationship = new Relationships__c();
    	Map<Id,Relationships__c> mapRelationshipsId_InverseRelationShipToInsert = new Map<Id,Relationships__c>();
		List<Relationships__c> lstPrimaryRelationshipsToUpdate = new List<Relationships__c>();
		Set<String> setDirectlyQueriedFields = new Set<String>{'Contact1__c','Contact2__c','Entity1__c','Entity2__c','RecordtypeId',
		                                                       'Primary_Relationship_Type__c','Reciprocal_Relationship_Type__c',
		                                                       'IsPrimary__c','Primary_Reciprocal_Relationship_Id__c'};
		
    	///Create data for InverseRelationship record
		for(Relationships__c objRelationship:lstRelationships)
		{
			sObject objSobjectRelationship = objRelationship;
			objInverseRelationship = new Relationships__c(RecordtypeId = objRelationship.RecordtypeId, Primary_Relationship_Type__c = objRelationship.Reciprocal_Relationship_Type__c,
			                                              Reciprocal_Relationship_Type__c = objRelationship.Primary_Relationship_Type__c, IsPrimary__c = false,
			                                              Primary_Reciprocal_Relationship_Id__c = objRelationship.Id);
			
			if(objRelationship.RecordTypeId == CONTACT_TO_CONTACT_RECORDTYPEID)
			{
				objInverseRelationship.put('Contact1__c', objRelationship.Contact2__c);
				objInverseRelationship.put('Contact2__c', objRelationship.Contact1__c);
			}
			else if(objRelationship.RecordTypeId == ENTITY_TO_ENTITY_RECORDTYPEID)
			{
				objInverseRelationship.put('Entity1__c', objRelationship.Entity2__c);
				objInverseRelationship.put('Entity2__c', objRelationship.Entity1__c);
			}
			
			///Iterate over each field in field set
			for(Schema.FieldSetMember objFieldSetMember:lstFieldSetMember)
			{
				if(objSobjectRelationship.get(objFieldSetMember.getFieldPath()) != null && !setDirectlyQueriedFields.contains(objFieldSetMember.getFieldPath()))
				{
					objInverseRelationship.put(objFieldSetMember.getFieldPath(),objSobjectRelationship.get(objFieldSetMember.getFieldPath()));
				}
			}
			
			mapRelationshipsId_InverseRelationShipToInsert.put(objRelationship.Id, (Relationships__c)objInverseRelationship);
		}
		
		if(!mapRelationshipsId_InverseRelationShipToInsert.isEmpty())
			database.insert(mapRelationshipsId_InverseRelationShipToInsert.values(),false);
		
		///Update Primary_Reciprocal_Relationship_Id__c field on Primary relationship
		for(Relationships__c objRelationship:lstRelationships)
		{
			if(mapRelationshipsId_InverseRelationShipToInsert.containskey(objRelationship.Id) &&
			    mapRelationshipsId_InverseRelationShipToInsert.get(objRelationship.Id) != null)
			{
				Relationships__c objRelationshipsNew = new Relationships__c(Id = objRelationship.Id);
				objRelationshipsNew.Primary_Reciprocal_Relationship_Id__c = mapRelationshipsId_InverseRelationShipToInsert.get(objRelationship.Id).Id;
				lstPrimaryRelationshipsToUpdate.add(objRelationshipsNew);
			}
		}
		
		if(!lstPrimaryRelationshipsToUpdate.isEmpty())
			database.update(lstPrimaryRelationshipsToUpdate,false);
	}
}