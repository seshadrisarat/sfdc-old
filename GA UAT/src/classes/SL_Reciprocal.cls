/*
 
* \author Pradeep Maddi
 
* \date 02/08/2015
 
* \GA-6
* \see http://silverline.jira.com/browse/LIB-227
 
* \brief Handles reciprocal triggers logic.  
 
* \test SL_Test_Reciprocal
 
*/
public without sharing class SL_Reciprocal 
{
    // Object relations fields
    //private String objAType;
    //private String objBType;
    private String objAFieldA;               // Reference to the Object A Relationship field A from affiliation
    private String objAFieldB;               // Reference to the Object A Relationship field B from affiliation
    private String objBFieldA;               // Reference to the Object B Relationship field A from affiliation
    private String objBFieldB;               // Reference to the Object B Relationship field B from affiliation
    
    // Joiner relations fields
    private String joinerObjectName;        // Joiner object name
    private String joinerRefField;          // Joiner objects reference field
    
    private String joinerSameFieldsSet;     // Set of fields values of which should be equal for the two joiner objects of a single affiliation.
    
    private String joinerInverseNameField;  // A field on inverse object which acts as a inverse pair to Name field.
    private String joinerInvObjName;        // An object which holds inverse values, Name-inverse__c pairs.
    private Map<String, String> inverse;    // Map which holds inverse values.
    
    private String joinerRefFieldText;      // Makes the proper undelete possible. Textual information of joinerRefField.
    
    /**
    * CONSTRUCTOR - full constructor.
     */
    public SL_Reciprocal (String objAFieldA,             // 'From_Account__c'
                          String objAFieldB,             // 'To_Account__c'
                          String objBFieldA,             // 'From_Contact__c'
                          String objBFieldB,             // 'To_Contact__c'
                          String jRefField,                // 'Related_Connection__c'
                          String jObjName,                 // 'Connection__c'
                          String jFieldsSet,               // 'CnxnSameFlds'
                          String jInv,                     // 'Type__c'
                          String jInvObjName,              // 'Inverse_Affiliation__c'
                          String jRefFieldText             // 'ConnectionRefFieldText__c'
                          ) {
        this.objAFieldA             = objAFieldA;
        this.objAFieldB             = objAFieldB;
        this.objBFieldA             = objBFieldA;
        this.objBFieldB             = objBFieldB;
        this.joinerRefField              = jRefField;
        this.joinerObjectName            = jObjName;
        this.joinerSameFieldsSet         = jFieldsSet;
        this.joinerInverseNameField      = jInv;
        this.joinerInvObjName            = jInvObjName;
        this.joinerRefFieldText          = jRefFieldText;
    }
    
    public SL_Reciprocal (String objAFieldA, String objAFieldB, String objBFieldA, String objBFieldB, String jRefField) {
        this(objAFieldA, objAFieldB, objBFieldA, objBFieldB, jRefField, '', '', '', '', null);
    }
    
    public SL_Reciprocal (String objAFieldA, String objAFieldB, String objBFieldA, String objBFieldB, String jRefField, String jObjName, String jFieldsSet) {
        this(objAFieldA, objAFieldB, objBFieldA, objBFieldB, jRefField, jObjName, jFieldsSet, '', '', null);
    }
    
    public SL_Reciprocal (String objAFieldA, String objAFieldB, String objBFieldA, String objBFieldB, String jRefField, String jObjName, String jFieldsSet, String jInv, String jInvObjName) {
        this(objAFieldA, objAFieldB, objBFieldA, objBFieldB, jRefField, jObjName, jFieldsSet, jInv, jInvObjName, null);
    }
    
    // Method called on After Insert of Relationship record to create inverse Relationship record for created Relationship 
    public void OnAfterInsert(map<ID,SObject> newMap)
    {
        if(isInverse())
        	fillInverseMap(newMap);
        	
        List<SObject> lstRelationRecsToUpdate = new List<SObject>();  // Used for updating Relation records joinerRefField with it's created inverse relation.
        List<sObject> lstInverseRelToInsert = new List<sObject>(); // Used for Creating Inverse Relation records.
		
        
        // Iterating through inserted Relationship records
        for(SObject newSo: newMap.values())
        {
        	// Creating new inverse relation for inserted relation record 
        	lstInverseRelToInsert.add(createNewObject(newSo));
        }
        
        if(!lstInverseRelToInsert.isEmpty())
        {
        	// Inserting inverse relationships for inserted Relation records
            Database.insert(lstInverseRelToInsert, false);
	    	    
	        // Iterating through Created Inverse relations
	        for(SObject sObjInverse : lstInverseRelToInsert)
	        {
	        	SObject objInsertedSObject = sObjInverse.getSObjectType().newSObject();
	        	objInsertedSObject.put('Id',(Id)sObjInverse.get(joinerRefField));
	        	
				// Updating joinerRefField on Relationship record with it's created Inverse relation	        	
	        	objInsertedSObject.put(joinerRefField,(Id)sObjInverse.get('Id'));

				// Updating joinerRefFieldText on Relationship record with it's created Inverse relation which is used in undelete operation of Relationship record.
				if(!String.isEmpty(joinerRefFieldText))
	        		objInsertedSObject.put(joinerRefFieldText,(Id)sObjInverse.get('Id'));

	        	lstRelationRecsToUpdate.add(objInsertedSObject);
	        }
	        
	        // Updating Relationship records joinerRefField with it's created inverse Relations
	        if(!lstRelationRecsToUpdate.isEmpty())
	            Database.update(lstRelationRecsToUpdate, false);
        }    
    }
    
     /**
    * Creates a reverse affiliation object to the one given.
     */
    private SObject createNewObject(SObject newSo)
    {
        SObject sObjInverseRelation = newSo.getSObjectType().newSObject();
        
        if(inverse!=null)
            sObjInverseRelation.put(joinerInverseNameField, inverse.get((String)newSo.get(joinerInverseNameField)));
        
        // Checking if fieldset exists or not
        if(!String.isEmpty(joinerSameFieldsSet))
        {
        	// Querying fields present in provided fieldset by using utility class
            List<Schema.FieldSetMember> sameFields =  SL_GenUtils.getFieldSetFlds(joinerSameFieldsSet, joinerObjectName);
            
            // Looping through fields present in fieldset to create or update Inverse Relationship for created or updated Relationship record.
            for(Schema.FieldSetMember f : sameFields)
            {
            	// Checking if Field is objAFieldA then mapping objAFieldA of inverse Relationship with objAFieldB of created Relationship record.
            	if(f.getFieldPath() == objAFieldA)
                	sObjInverseRelation.put(f.getFieldPath(), newSo.get(objAFieldB));
                	
                // Checking if Field is objAFieldB then mapping objAFieldB of inverse Relationship with objAFieldA of created Relationship record.
                else if(f.getFieldPath() == objAFieldB)	
                	sObjInverseRelation.put(f.getFieldPath(), newSo.get(objAFieldA));
                
                // Checking if Field is objBFieldA then mapping objBFieldA of inverse Relationship with objBFieldB of created Relationship record.	
                else if(f.getFieldPath() == objBFieldA)	
                	sObjInverseRelation.put(f.getFieldPath(), newSo.get(objBFieldB));
                
                // Checking if Field is objBFieldB then mapping objBFieldB of inverse Relationship with objBFieldA of created Relationship record.	
                else if(f.getFieldPath() == objBFieldB)	
                	sObjInverseRelation.put(f.getFieldPath(), newSo.get(objBFieldA));
                	
                // Mapping other fields	for inverse Relationships with created Relationship record..
                else
                	sObjInverseRelation.put(f.getFieldPath(), newSo.get(f.getFieldPath()));			
            }
        }
        
        // Updating joinerRefField on Inverse relation record.
        sObjInverseRelation.put(joinerRefField, newSo.get('id'));
        
        // Updating joinerRefFieldText on Inverse relation record with it's Relationship Id which is used in undelete operation of Relationship record..
        if(joinerRefFieldText!=null)
            sObjInverseRelation.put(joinerRefFieldText, newSo.get('id'));
                
        return sObjInverseRelation;
    }
    
    // Method called on after update of RelationShip record to update or delete it's inverse relationship record
    public void OnAfterUpdate(map<ID,SObject> oldMap, map<ID,SObject> newMap)
    {
        List<SObject> lstInverseRelToUpdate = new List<SObject>();   // List used to update Inverse Relationship records when any of the field present in fieldset is updated.
        Map<Id,Sobject> mapInverserRelationsToInsert = new Map<Id,Sobject>(); // map used to insert Inverse Relationships if Inverse Relationship does not exists for updated Relationship record.
		List<Sobject> lstInverseRelationsToDel = new List<Sobject>(); // List Used to delete Inverse relationships when any of the Relationship field in Relationship record is made blank.
		        
        if(isInverse())
        	fillInverseMap(newMap);
        	
        for (SObject newSo: newMap.values())
        {
            // Check if inverse field has changed
            if(isInverse())
            {
                if(newSo.get(joinerInverseNameField) != oldMap.get(newSo.Id).get(joinerInverseNameField))
                {
                    lstInverseRelToUpdate.add(createNewObject(newSo));
                    continue;
                }
            }
            
            // Check If fieldset exists or not
            if(joinerSameFieldsSet!=null && joinerSameFieldsSet!='')
            {
            	// Getting fields from fieldset
                List<Schema.FieldSetMember> sameFields =  SL_GenUtils.getFieldSetFlds(joinerSameFieldsSet, joinerObjectName);
                boolean isContinue = false;
                
                // Iterating through fields present in fieldset
                for(Schema.FieldSetMember f : sameFields)
                {
                	// Checking whether non relationship field present in fieldset is updated
                    if( !checkForRelationshipFieldsUpdate(f.getFieldPath()) && oldMap.get(newSo.Id).get(f.getFieldPath())!=newSo.get(f.getFieldPath()) || (checkForRelationshipFieldsUpdate(f.getFieldPath()) && (oldMap.get(newSo.Id).get(f.getFieldPath())!=newSo.get(f.getFieldPath()) && newSo.get(f.getFieldPath()) != null)))
                    {
						// Checking if Inverse Relation is present for updated Relationship record.
                    	if(newSo.get(joinerRefField) != null)
                    	{
                    		SObject sObjInverseRelation = createNewObject(newSo);
                    		sObjInverseRelation.put('id', newSo.get(joinerRefField));
                    		lstInverseRelToUpdate.add(sObjInverseRelation);
                    		isContinue = true;
                       		break;
                    	}
                    	
                    	// If no Inverse Relationship exists for updated Relationship record then creating Inverse Relationship..
                    	else if((newSo.get(objAFieldA) != null && newSo.get(objAFieldB) != null) || (newSo.get(objBFieldA) != null && newSo.get(objBFieldB) != null))
                    	{
                    		mapInverserRelationsToInsert.put((Id)newSo.get('Id'),newSo);
                    		isContinue = true;
                        	break;
                    	}
                    }
                    
                    // Checking if relationship field is updated in RelationShip record
                    else if(checkForRelationshipFieldsUpdate(f.getFieldPath()) && (oldMap.get(newSo.Id).get(f.getFieldPath())!=newSo.get(f.getFieldPath()) && newSo.get(f.getFieldPath()) == null))
                    {
                    	// Checking if either of the Relationship exists else deleting inverse relationship record
                    	if((newSo.get(objAFieldA) == null || newSo.get(objAFieldB) == null) && (newSo.get(objBFieldA) == null || newSo.get(objBFieldB) == null))
                    	{
                    		if(newSo.get(joinerRefField) != null)
                    		{
	                    		SObject objInverseSObjToDel = newSo.getSObjectType().newSObject();
	                    		objInverseSObjToDel.put('Id',(Id)newSo.get(joinerRefField));
	                    	
		                    	// Adding Inverse relations to delete when any of the relationship field is made blank
		                    	lstInverseRelationsToDel.add(objInverseSObjToDel);
		                    	
		                    	// Removing joinerRefFieldText if related inverse Relationship is deleted
		        				if(joinerRefFieldText!=null)
		        				{
		        					SObject objUpdatedSObject = newSo.getSObjectType().newSObject();
		                    		objUpdatedSObject.put('id',(Id)newSo.get('Id'));
		            				objUpdatedSObject.put(joinerRefFieldText, null);
		            				lstInverseRelToUpdate.add(objUpdatedSObject);
		        				}	
		                    	isContinue = true;
		                        break;
                    		}
                    	} 
                    	
                    	// Updating inverse Relationship record with updated Relationship if either of the relationship exists.
                    	else if(newSo.get(joinerRefField) != null)
                    	{
                    		SObject sObjInverseRelation = createNewObject(newSo);
                    		sObjInverseRelation.put('id', newSo.get(joinerRefField));
                    		lstInverseRelToUpdate.add(sObjInverseRelation);
                    		isContinue = true;
                       		break;
                    	}
                    }
                }
                if(isContinue) continue;
            }
        }
        
        // Inserting Inverse Relationships for updated Relations if Inverse Relationships does not exists before.
        if(!mapInverserRelationsToInsert.isEmpty())
        	OnAfterInsert(mapInverserRelationsToInsert);	
        
        // Updating Inverse Relationships when any of the field provided in fieldset is updated.
        if(!lstInverseRelToUpdate.isEmpty())
            Database.update(lstInverseRelToUpdate, false);
        
        // Deleting Inverse relations when any of the relationship field is made blank in RelationShip record and no relationship exists between eihter of the relationship objects.
        if(!lstInverseRelationsToDel.isEmpty())
           Database.delete(lstInverseRelationsToDel,false);    
    }
    
    // Method used to check whether the field present in fieldset is relationship field or not..
    private boolean checkForRelationshipFieldsUpdate(String strFieldName)
    {
    	return strFieldName == objAFieldA || strFieldName == objAFieldB || strFieldName == objBFieldA || strFieldName == objBFieldB ;
    }
    
    // Method called on Delete Of Relationship records to delete all of its inverse Relationships
    public void OnAfterDelete(map<ID,SObject> oldMap)
    {
        List<sObject> lstInverseRelationsToDel = new List<sObject>(); // List used to delete Inverse relationShips for deleted Relationship records..
        
        // Iterating through deleted relationship records
        for(SObject relationShip : oldMap.values())
        {
        	// Checking if Inverse relationship exists for deleted Relationship record
        	if((ID)relationShip.get(joinerRefField) != null)
        	{
	        	SObject objInverseRelation = relationShip.getSObjectType().newSObject();
		        objInverseRelation.put('Id',(Id)relationShip.get(joinerRefField));
		        lstInverseRelationsToDel.add(objInverseRelation);
        	}
        }
        // Deleting inverse relationships.
        if(!lstInverseRelationsToDel.isEmpty())
        {
            Database.delete(lstInverseRelationsToDel, false);
        }
    } 
    
    // Method called after undelete of Relationship record
    public void OnAfterUnDelete(map<ID,SObject> newMap)
    {
        if(joinerRefFieldText!=null)
        {
            List<ID> lstInverseRelationIds = new List<ID>(); // Collecting Inverse relationship record Ids for undeleting inverse Relationships
            
            for(SObject item : newMap.values())
            {
            	// Collecting inverse relations if exists to undelete inverse relations
            	if(item.get(joinerRefFieldText) != null)
                	lstInverseRelationIds.add((ID)item.get(joinerRefFieldText));
            }
            // Undeleting inverse relations.
            Database.undelete(lstInverseRelationIds, false);
        }
    }
    
    /**
    * Fills the inverse map, returns true if success, false if failed to fill the map.
     */
    private boolean fillInverseMap(map<ID,SObject> objMap){
        inverse = new Map<String, String>();
        if(joinerInverseNameField!=null && joinerInverseNameField!=''){
            List<String> iVals = new List<String>();
            for(SObject item: objMap.values()){
                iVals.add((String)item.get(joinerInverseNameField));
            }
            try{
                List<SObject> inv = Database.query('SELECT name, inverse__c from ' + joinerInvObjName + ' where name=:iVals OR inverse__c=:iVals');
                for(SObject i: inv){
                    inverse.put((String)i.get('name'), (String)i.get('inverse__c'));
                    inverse.put((String)i.get('inverse__c'), (String)i.get('name'));
                }
            } catch (Exception ex){
                System.debug('ERROR while filling the inverse map: ' + ex.getMessage());
                inverse = null;
                return false;
            }
        }
        return true;
    }
    
    /**
    * Return 'true' if the inverse information is given correctly.
     */
    private boolean isInverse(){
        return joinerInverseNameField!=null && joinerInverseNameField!='' && joinerInvObjName!=null && joinerInvObjName!='';
    }
    
}