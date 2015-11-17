/**
* \arg \b ClassName      : SL_Note_Handler
* \arg \b JIRATicket     : FAEF-1
* \arg \b CreatedOn      : 02/07/2013
* \arg \b ModifiedBy     : Rahul
* \arg \b Description    : This is the handler class for Note trigger. when we Insert any Note then it will make a string by merging the Note title and body upto target field length then update that string in 
*							parent object Latest_Note__c field .On delete of latest note it will again find the last modified note and update the parent object latest note field.	
*/

public with sharing class SL_Note_Handler 
{
	//Constructor of a Handler Class
	public SL_Note_Handler()
	{
		/* Do nothing. */
	}
	
	/*
	    * MethodName 	: onAfterInsert.
	    * param 		: List of Note.
	    * Description	: This function will call After insert of the note.
    */
    public void onAfterInsert(Map<Id, Note> mapNewNote)
    {
    	updateParentObject(mapNewNote);
    }
	
	/*
    	* MethodName 	: onAfterUpdate.
        * param 		: List of Note.
        * Description	: This function will call After Update of the note.
    */
    public void onAfterUpdate(Map<Id, Note> mapNewNote)
    {
        updateParentObject(mapNewNote);
    }
    
    /*
        * MethodName 	: onAfterDelete.
        * param 	    : List of Note.
        * Description	: This function will call After Delete of the note.
    */
    public void onAfterDelete(Map<Id, Note> mapNewNote)
    {
        updateParentObject(mapNewNote);
    }
    
    /*
        * MethodName	: updateParentObject
        * param None	: List of Notes.
        * Description	: updates all the parent objects Latest_Note__c field.
    */
    private void updateParentObject(Map<Id, Note> mapNewNote)
    {
		Set<String> setObjectAPIName = new Set<String>(); //!< Used to store all parent object API Name to compare whether deleted Note ParentObject is in that list or not.
	    Map<String, String> mapParentObjNameToLatestNoteField = new Map<String, String>(); //!< Used to store all parent object and their Latest_Note__c field from custom setting.
	    list<Note> lstNotes = new List<Note>(); // used to store notes inserted for objects present in custom setting.
	    map<Id,list<Note>> mapParenIdToLstnote = new map<Id,list<Note>>();  // used to store ParentId of Note and List of Notes of parentId.
		map<Id,Note> mapParentIdToLatestNote = new map<Id,Note>(); // used to store ParentId and LatestNote of ParentId to update ParentId LatestNote field. 
		set<Id> setparentIds = new set<Id>(); //set to store parent ids of notes
		set<Id> setParentIdsToUpdateLatestNoteBlank = new set<Id>(); // Used to store the parentIds which having Notes which are unchecked as private or having no Notes to update ParentId LatestNote field as blank.
		map<Id, Sobject> mapSObjectIdToSObject = new Map<Id, Sobject>(); // Used to update parentIds Latest Note field
		map<String,sObjectType> mapSobjectNameToSobjectType = new map<String,sObjectType>();
		map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
		map<String,Schema.DescribeFieldResult> mapObjectAPINameToTargetFieldDecribeResult = new map<String,Schema.DescribeFieldResult>();
    	
	    /* This Loop is use to get mapping of all parent objects and their latest note detail field api name. */
    	for(SObjectAPIName__c objCS : SObjectAPIName__c.getAll().values())
    	{
    		setObjectAPIName.add(objCS.Name);
    		mapParentObjNameToLatestNoteField.put(objCS.Name, objCS.LatestNoteFieldAPIName__c);
    	    Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(objCS.Name);
	     	Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
	     	Schema.DescribeFieldResult objfieldresult = DescribeSObjectResultObj.fields.getMap().get(mapParentObjNameToLatestNoteField.get(objCS.Name)).getDescribe(); 
	     	mapObjectAPINameToTargetFieldDecribeResult.put(objCS.Name,objfieldresult);
	     	mapSobjectNameToSobjectType.put(objCS.Name,SObjectTypeObj);
    	}
    	
    	if(setObjectAPIName.isEmpty())
    		return;
    		
	    /* This Loop is used to collect parentids and Notes belongs to objects present in custom setting */
	    for(Note sObjNote : mapNewNote.values())
	    {	
    		if(mapParentObjNameToLatestNoteField.keyset().contains(String.valueOf(sObjNote.ParentId.getSObjectType())))
    		{
		       lstNotes.add(sObjNote);
               setparentIds.add(sObjNote.ParentId);
		    }
	     }
	     
	     /* This loop is used to create a map of ParentId and List of Notes whose IsPrivate is marked as unchecked  */
		 for(Note objNote : [select Title,IsPrivate,ParentId ,Body,LastModifiedDate from Note
				                where IsPrivate = false and ParentId IN :setparentIds])
         {
			if(mapParenIdToLstnote.containsKey(objNote.ParentId))
				mapParenIdToLstnote.get(objNote.ParentId).add(objNote);

			else
				mapParenIdToLstnote.put(objNote.ParentId,new list<Note>{objNote});
		  }
		  
		  /* Used to prepare the parentIds which having only Notes checked as private or having no Notes related to ParentId and to update ParentId LatestNote field as blank.*/
		  for(Id objParentId : setparentIds)
		  
		  {
		  		if(!mapParenIdToLstnote.containsKey(objParentId))
		  			setParentIdsToUpdateLatestNoteBlank.add(objParentId);
		  }
		  
		  /* Used to find the latest dated Note of ParentId */
		  for(Note objNote : lstNotes )
		  {
		     DateTime objdate;
			 if( mapParenIdToLstnote.get(objNote.ParentId)!= null)
			 {
				  for( Note objNote1 :mapParenIdToLstnote.get(objNote.ParentId))
				  {	
						if(objdate == null)
						{	
							objdate = objNote1.LastModifiedDate;
							mapParentIdToLatestNote.put(objNote.ParentId,objNote1);
						}
						else if(objdate < objNote1.LastModifiedDate)
						{
							objdate = objNote1.LastModifiedDate;
							mapParentIdToLatestNote.put(objNote.ParentId,objNote1);
						}
	              }
			 }
		 }
		 
		 /* Used to update parentIds LatestNote Field to blank which having only Notes checked as Private or having no Notes */
		 for(Id ObjParentId : setParentIdsToUpdateLatestNoteBlank)
		 {
		 	String SObjectApiName = string.valueOf(ObjParentId.getSObjectType());
		 	Schema.SObjectType sObjectType = mapSobjectNameToSobjectType.get(SObjectApiName);
	        SObject sObjectNoteParent = sObjectType.newSObject(ObjParentId);
	        sObjectNoteParent.put(mapParentObjNameToLatestNoteField.get(SObjectApiName),'');
	        mapSObjectIdToSObject.put(ObjParentId, sObjectNoteParent);
		 }
		 
	    /* Used to update ParentId LatestNote field with latest Note Title + '' + Body*/
	     for(Note objNote : mapParentIdToLatestNote.values())
	     {
	     	String strLatestNoteTitleAndBody = objNote.Title;
	     	String SObjectApiName = string.valueOf(objNote.ParentId.getSObjectType());
	     	Schema.SObjectType sObjectType = mapSobjectNameToSobjectType.get(SObjectApiName);
	     	Integer intTargetFieldLength = mapObjectAPINameToTargetFieldDecribeResult.get(SObjectApiName).getLength();
	     	// objfieldresult.getLength(); // Getting target field length to Grab those much characters from Latest Note.
	     	
	     	if(objNote.Body !=null && objNote.Body != '')
	    	{ 
	    		strLatestNoteTitleAndBody += ' ' + objNote.Body ;                  // Appending Title and body of Latest Dated Note
	    	}
	    	
	    	if(strLatestNoteTitleAndBody.length()>intTargetFieldLength)
	    		strLatestNoteTitleAndBody = strLatestNoteTitleAndBody.substring(0,intTargetFieldLength);
	    		
	    	SObject sObjectNoteParent = sObjectType.newSObject(objNote.ParentId);
	    	sObjectNoteParent.put(mapParentObjNameToLatestNoteField.get(SObjectApiName),strLatestNoteTitleAndBody);
	    	mapSObjectIdToSObject.put(objNote.ParentId, sObjectNoteParent);
	      }
	      
		  try
		  {
		     if(!mapSObjectIdToSObject.isEmpty())
		     {
			  	 Database.update(mapSObjectIdToSObject.values(), false);  // Updating ParentIds
		     }
		  }
		  catch(Exception e)
		  {
		     system.debug('##Exception:'+ e);
		  }
    }
}