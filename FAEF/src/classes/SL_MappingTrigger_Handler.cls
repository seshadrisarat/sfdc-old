/**
* \arg ClassName      : SL_MappingTrigger_Handler
* \arg JIRATicket     : FAEF-4
* \arg CreatedOn      : 10/09/2013
* \arg LastModifiedOn : 24/09/2014
* \arg CreatededBy    : Lodhi
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This is genric class which can be called by the Trigger Handler class to create the Sobject records and also the related list records on the basis 
*                       of the Custom Mapping and thier child records.
*/
public with sharing class SL_MappingTrigger_Handler 
{
    /* Start Variables */
    private Map<String, Map<String, Schema.SObjectField>> mapSobjectNameToFieldsDescription;
    /* End Variables*/
    
    /* Start Constructor*/
    public SL_MappingTrigger_Handler()  
    {
       	mapSobjectNameToFieldsDescription =  new Map<String, Map<String, Schema.SObjectField>>();
    }
    /* End Contructor */
    
    /*!
        * MethodName : createSobjectRecords
        * param      : List of Sobject corresponding to which records need to be create and the Sobject name correspond which Custom Mapping records need to query.
        * Description: This method will create the Sobject records on the basis of the Custom Mapping records and his child records and also copy the related list records.
    */
    public void createSobjectRecords(Map<Id,Sobject> mapIdToSobject, String strSobjectAPIName)
    {
        if(!mapIdToSobject.isEmpty() && strSobjectAPIName != null && strSobjectAPIName != '')
        {
        	mapSobjectNameToFieldsDescription =  new Map<String, Map<String, Schema.SObjectField>>();
            Map<Integer,Object_Relationship__c> mapOrderNoToOR = new Map<Integer,Object_Relationship__c>();//!< This map is use to keep the Object Relation records corresponding to Order field.
            Map<String,List<Field_Mapping__c>> mapORIdToLstOfFM = new Map<String,List<Field_Mapping__c>>();//!< This map is use to keep the list of Field Mapping records corresponding to the  Object Reelation record Id.
            Set<String> setORId = new Set<String>(); //!< This set is used to keep the Id of the Object Relation records.
            List<Integer> lstOrder = new List<Integer>();//!< This list to use to order the value of the Order field.
            Map<String, List<Sobject>> mapSobjectNameToLstSobject = new Map<String, List<Sobject>>();//!< This map is use to put the List of Sobject corresponding to it's name.
            List<Sobject> lstSobject = new List<Sobject>();//!< This list is used to get the lst of Sobject inserted to keep in map..
            Set<Id> setSobjectId = new Set<Id>();//!< To put the Id of the Parent reecord to Query.
            mapSobjectNameToLstSobject.put(strSobjectAPIName, mapIdToSobject.values());//!< Putting the List of the Sobject to map corresponding to its API Name.
            
            ///< Query the Object_Relationship__c records to get create the Sobject records.
            for(Object_Relationship__c objOR : [SELECT Id, Target_Relationship_Id__c, Target_Parent_Id__c, Target_Object_API__c, RecordType.DeveloperName, 
                                                RecordTypeId, Parent_Object_Relationship__c, Order__c, Name, Custom_Mapping__c, Context_Relationship_Id__c, 
                                                Context_Object_API__c, Related_Record_Parent_Id__c, Parent_Object_Relationship__r.Target_Object_API__c,
                                                Copy_Notes__c,Copy_Attachments__c, Copy_Sharing_Rules__c
                                                FROM Object_Relationship__c
                                                WHERE Custom_Mapping__c IN: [SELECT Id FROM Custom_Mapping__c WHERE Sobject_API_Name__c =: strSobjectAPIName LIMIT 1]])
            {
            	if(objOR.Order__c != null)
            	{
	                setORId.add(objOR.Id);//!< Adding the Id to get the Field Mapping records.  
	                mapOrderNoToOR.put(Integer.valueOf(objOR.Order__c), objOR);//!< Adding items to the mapOrderNoToOR
	                lstOrder.add(Integer.valueOf(objOR.Order__c)); //!<Add Order fields values to the list to sort the Order 
	                
	                /////////
	                if(Schema.getGlobalDescribe().containsKey(objOR.Target_Object_API__c))
	                	mapSobjectNameToFieldsDescription.put(objOR.Target_Object_API__c, Schema.getGlobalDescribe().get(objOR.Target_Object_API__c).getDescribe().fields.getMap());
	                ////////
            	}  
            }
            ///< Query the Field_Mapping__c records to get fields mapping value corresponding to each Object_Relationship__c records.
            for(Field_Mapping__c objFM : [SELECT Target_Full_API__c, Target_Field_Name__c, Object_Relationship__c, Name, Id, Context_Full_API__c, 
                                          Context_Field_Name__c, Active__c, RecordTypeId, RecordType.DeveloperName, Target_Value__c 
                                          FROM Field_Mapping__c 
                                          WHERE Active__c = true AND Object_Relationship__c IN: setORId])
            {
                //!< Checking if the map already contains the Key value.
                if(mapORIdToLstOfFM.containsKey(objFM.Object_Relationship__c))
                    mapORIdToLstOfFM.get(objFM.Object_Relationship__c).add(objFM);//!< Adding the values to the list by getting the list using key
                else
                    mapORIdToLstOfFM.put(objFM.Object_Relationship__c, new List<Field_Mapping__c>{objFM});//!< Adding values.
            }
            
            
            lstOrder.sort();//!< Sorting the list values.
            ///< Iterating the lstOrder to get the correct order to create the records.
            for(Integer intOrder : lstOrder)
            {
            	if(mapOrderNoToOR.containsKey(intOrder))
            	{
            		if(mapOrderNoToOR.get(intOrder).RecordType.DeveloperName == 'Direct_Association' && mapOrderNoToOR.get(intOrder).Parent_Object_Relationship__c == null && mapSobjectNameToLstSobject.containsKey(mapOrderNoToOR.get(intOrder).Context_Object_API__c))
            		{
            			//!< Call mappingFieldsOfSourceObjectToTargetObject methods to mapping the field with the context object values.
                       lstSobject = fieldMappingForDirectAssociation(mapSobjectNameToLstSobject.get(mapOrderNoToOR.get(intOrder).Context_Object_API__c), 
   																	 mapORIdToLstOfFM.containsKey(mapOrderNoToOR.get(intOrder).Id) ? mapORIdToLstOfFM.get(mapOrderNoToOR.get(intOrder).Id) : new List<Field_Mapping__c>(),
                                                                  	 mapIdToSobject,
                                                                   	 mapOrderNoToOR.get(intOrder).Target_Object_API__c,
                                                                   	 mapOrderNoToOR.get(intOrder).Target_Relationship_Id__c,
                                                                   	 mapOrderNoToOR.get(intOrder).Context_Relationship_Id__c,
                                                                     mapOrderNoToOR.get(intOrder).Copy_Notes__c,  
                                                                     mapOrderNoToOR.get(intOrder).Copy_Attachments__c,
                                                                     mapOrderNoToOR.get(intOrder).Copy_Sharing_Rules__c,
                                                                     mapOrderNoToOR.get(intOrder).Context_Object_API__c!=null ? mapOrderNoToOR.get(intOrder).Context_Object_API__c : strSobjectAPIName);
            		}
            		else if(mapOrderNoToOR.get(intOrder).RecordType.DeveloperName == 'Direct_Association' && mapOrderNoToOR.get(intOrder).Parent_Object_Relationship__c != null)
            		{
            			setSobjectId = new Set<Id>();
            			String strTargetParentAPI = mapOrderNoToOR.get(intOrder).Target_Parent_Id__c;
            			String strTargetParentRelationAPI = strTargetParentAPI.subString(0,strTargetParentAPI.indexOf('.'));
            			String strParentRelationContextAPI =strTargetParentAPI.subString(strTargetParentAPI.indexOf('.') + 1,strTargetParentAPI.length());
            			for(Sobject sObj : mapSobjectNameToLstSobject.get(mapOrderNoToOR.get(intOrder).Parent_Object_Relationship__r.Target_Object_API__c))
        				{
        					setSobjectId.add((Id)sObj.get('Id'));
        				}
        				
        				String strQuery = 'SELECT Id, ' + strParentRelationContextAPI + ' FROM ' + mapOrderNoToOR.get(intOrder).Parent_Object_Relationship__r.Target_Object_API__c + ' WHERE Id IN: setSobjectId';
        				mapSobjectNameToLstSobject.put(mapOrderNoToOR.get(intOrder).Parent_Object_Relationship__r.Target_Object_API__c,Database.query(strQuery));
        				
            			if(mapOrderNoToOR.get(intOrder).Context_Object_API__c == strSobjectAPIName && mapSobjectNameToLstSobject.containsKey(mapOrderNoToOR.get(intOrder).Parent_Object_Relationship__r.Target_Object_API__c))
            			{
            				//!< Call mappingFieldsOfSourceObjectToTargetObject methods to mapping the field with the context object values.
                       		lstSobject = fieldMappingForDirectAssociation(mapSobjectNameToLstSobject.get(mapOrderNoToOR.get(intOrder).Parent_Object_Relationship__r.Target_Object_API__c), 
       																	  mapORIdToLstOfFM.containsKey(mapOrderNoToOR.get(intOrder).Id) ? mapORIdToLstOfFM.get(mapOrderNoToOR.get(intOrder).Id) : new List<Field_Mapping__c>(),
                                                                      	  mapIdToSobject,
                                                                       	  mapOrderNoToOR.get(intOrder).Target_Object_API__c,
                                                                       	  strTargetParentRelationAPI,
                                                                       	  strParentRelationContextAPI,
                                                                		  mapOrderNoToOR.get(intOrder).Copy_Notes__c,  
                                                                          mapOrderNoToOR.get(intOrder).Copy_Attachments__c,
                                                                          mapOrderNoToOR.get(intOrder).Copy_Sharing_Rules__c,
                                                                		  mapOrderNoToOR.get(intOrder).Context_Object_API__c!=null ? mapOrderNoToOR.get(intOrder).Context_Object_API__c : strSobjectAPIName);
                                                                                  
            			}
            			else if(mapSobjectNameToLstSobject.containsKey(mapOrderNoToOR.get(intOrder).Parent_Object_Relationship__r.Target_Object_API__c))
            			{
            				Set<Id> setContextObjectId = new Set<Id>();
            				for(Sobject sObj : mapSobjectNameToLstSobject.get(mapOrderNoToOR.get(intOrder).Parent_Object_Relationship__r.Target_Object_API__c))
            				{
            					setContextObjectId.add((Id)sObj.get(strParentRelationContextAPI));
            				}
            				
            				strQuery = 'SELECT Id';
            				
            				for(Field_Mapping__c objFieldMapping :mapORIdToLstOfFM.containsKey(mapOrderNoToOR.get(intOrder).Id) ? mapORIdToLstOfFM.get(mapOrderNoToOR.get(intOrder).Id) : new List<Field_Mapping__c>())//!< Adding fields need to query  
	                        {
	                        	if(objFieldMapping.Target_Field_Name__c != null &&  objFieldMapping.Target_Field_Name__c!= '' && objFieldMapping.Context_Field_Name__c != null && objFieldMapping.Context_Field_Name__c !='')
	                         	   strQuery += ', '+ objFieldMapping.Context_Field_Name__c;
	                        }
	                        
	                        strQuery += ', '+ strParentRelationContextAPI ;  
	                        strQuery += ' FROM ' + mapOrderNoToOR.get(intOrder).Context_Object_API__c;
	                        strQuery += ' WHERE ' + strParentRelationContextAPI + ' IN: setContextObjectId';
	                        Map<Id,Sobject> mapIdToSobjectContext = new Map<Id,Sobject>();
	                        for(Sobject sObj : Database.query(strQuery))
	                        {
	                        	mapIdToSobjectContext.put((Id)sObj.get('Id'), sObj);
	                        }
	                        //!< Call mappingFieldsOfSourceObjectToTargetObject methods to mapping the field with the context object values.
                       		lstSobject = fieldMappingForDirectAssociation(mapSobjectNameToLstSobject.get(mapOrderNoToOR.get(intOrder).Context_Object_API__c), 
	           															  mapORIdToLstOfFM.containsKey(mapOrderNoToOR.get(intOrder).Id) ? mapORIdToLstOfFM.get(mapOrderNoToOR.get(intOrder).Id) : new List<Field_Mapping__c>(),
	                                                                      mapIdToSobjectContext,
	                                                                      mapOrderNoToOR.get(intOrder).Target_Object_API__c,
	                                                                      strTargetParentRelationAPI,
	                                                                      strParentRelationContextAPI,
                                                                		  mapOrderNoToOR.get(intOrder).Copy_Notes__c,  
                                                                		  mapOrderNoToOR.get(intOrder).Copy_Attachments__c,
                                                                		  mapOrderNoToOR.get(intOrder).Copy_Sharing_Rules__c,
                                                                		  mapOrderNoToOR.get(intOrder).Context_Object_API__c!=null ? mapOrderNoToOR.get(intOrder).Context_Object_API__c : strSobjectAPIName);
            			}
            		}
            		else
            		{
            			Map<Id, List<Sobject>> mapContextToLstOfRelatedListRecord = new	Map<Id, List<Sobject>>();
            			List<Sobject> lstParentSobject = new List<Sobject>();
            			String strTargetParentAPI = mapOrderNoToOR.get(intOrder).Target_Parent_Id__c;
            			String strTargetParentRelationAPI = strTargetParentAPI.subString(0,strTargetParentAPI.indexOf('.'));
            			String strParentRelationContextAPI =strTargetParentAPI.subString(strTargetParentAPI.indexOf('.') + 1,strTargetParentAPI.length());
            			setSobjectId = new Set<Id>();
            			for(Sobject sObj : mapSobjectNameToLstSobject.get(mapOrderNoToOR.get(intOrder).Parent_Object_Relationship__r.Target_Object_API__c))
        				{
        					setSobjectId.add((Id)sObj.get('Id'));
        				}
        				
        				String strQuery = 'SELECT Id, ' + strParentRelationContextAPI + ' FROM ' + mapOrderNoToOR.get(intOrder).Parent_Object_Relationship__r.Target_Object_API__c + ' WHERE Id IN: setSobjectId';
        				if(mapOrderNoToOR.get(intOrder).Context_Object_API__c == strSobjectAPIName)
        				{
        					lstParentSobject = Database.query(strQuery);
        					setSobjectId = new Set<Id>();
        					setSobjectId.addAll(mapIdToSobject.keySet());
        				}
        				else
        				{
        					setSobjectId = new Set<Id>();
        					for(Sobject sObj : Database.query(strQuery))
        					{
        						lstParentSobject.add(sObj);
        						setSobjectId.add((Id)sObj.get(strParentRelationContextAPI));
        					}
        				}
        				
        				strQuery = 'SELECT Id';
            				
        				for(Field_Mapping__c objFieldMapping : mapORIdToLstOfFM.containsKey(mapOrderNoToOR.get(intOrder).Id) ? mapORIdToLstOfFM.get(mapOrderNoToOR.get(intOrder).Id) : new List<Field_Mapping__c>())//!< Adding fields need to query  
                        {
                        	if(objFieldMapping.Target_Field_Name__c != null &&  objFieldMapping.Target_Field_Name__c!= '' && objFieldMapping.Context_Field_Name__c != null && objFieldMapping.Context_Field_Name__c !='')
                         	   strQuery += ', '+ objFieldMapping.Context_Field_Name__c;
                        }
                        
                        strQuery += ', '+ mapOrderNoToOR.get(intOrder).Related_Record_Parent_Id__c;  
                        strQuery += ' FROM ' + mapOrderNoToOR.get(intOrder).Context_Relationship_Id__c;
                        strQuery += ' WHERE ' +  mapOrderNoToOR.get(intOrder).Related_Record_Parent_Id__c + ' IN: setSobjectId';
                        if (mapOrderNoToOR.get(intOrder).Context_Relationship_Id__c=='IST__SuperTRUMP_Pricing_Quote__c'){
                            strQuery+= ' AND Will_Be_Promoted__c=True'; 
                        }
                        System.debug(LoggingLevel.ERROR, 'querying for super trumps       ' + strQuery);
                        System.debug(LoggingLevel.ERROR, 'query for super trumps sobjectids   ' + setSobjectId);
                        for(Sobject sObj : Database.query(strQuery))
                        {
                        	if(mapContextToLstOfRelatedListRecord.containsKey((Id)sObj.get(mapOrderNoToOR.get(intOrder).Related_Record_Parent_Id__c)))
                        		mapContextToLstOfRelatedListRecord.get((Id)sObj.get(mapOrderNoToOR.get(intOrder).Related_Record_Parent_Id__c)).add(sObj);
                        	else
                        		mapContextToLstOfRelatedListRecord.put((Id)sObj.get(mapOrderNoToOR.get(intOrder).Related_Record_Parent_Id__c), new List<Sobject>{sObj});
                    	}
                    	
                    	//!< Call mappingFieldsOfSourceObjectToTargetObject methods to mapping the field with the context object values.
                   		lstSobject = fieldMappingForRelatedList(lstParentSobject, 
   																mapORIdToLstOfFM.containsKey(mapOrderNoToOR.get(intOrder).Id) ? mapORIdToLstOfFM.get(mapOrderNoToOR.get(intOrder).Id) : new List<Field_Mapping__c>(),
                                                                mapContextToLstOfRelatedListRecord,
                                                                mapOrderNoToOR.get(intOrder).Target_Object_API__c,
                                                                strTargetParentRelationAPI,
                                                                strParentRelationContextAPI,
                                                                mapOrderNoToOR.get(intOrder).Copy_Notes__c,  
                                                                mapOrderNoToOR.get(intOrder).Copy_Attachments__c,
                                                                mapOrderNoToOR.get(intOrder).Copy_Sharing_Rules__c,
                                                                mapOrderNoToOR.get(intOrder).Context_Object_API__c!=null ? mapOrderNoToOR.get(intOrder).Context_Object_API__c : strSobjectAPIName);
            		}
            		
            		//Database.insert(lstSobject, false);//!< Peforming the DML operation
            		//insert lstSobject;
                    mapSobjectNameToLstSobject.put(mapOrderNoToOR.get(intOrder).Target_Object_API__c, lstSobject);//!< Adding the List of Sobject to the map corresponding to Sobject Name.
            	}
        	}
        }
    }
    /* End */
    
    /*!
        * MethodName : mappingFieldsOfSourceObjectToTargetObject
        * param      :     
        * Description: This method is called to do the field mapping from Context Object to Target Object.
    */
    private List<Sobject> fieldMappingForDirectAssociation(List<Sobject> lstParentSobject, List<Field_Mapping__c> lstFieldMapping, 
																	Map<Id,Sobject> mapIdToSobjectContext, String strTargetObjectAPIName, 
																	String strTargetParentRelationshipAPI, String strParentRelationToContextAPI,
																	Boolean isNote, Boolean isAttachment, Boolean isSharingRules, String strContextObjectAPIName)
    {
        List<Sobject> lstSobject = new List<Sobject>(); //!< This list is use to keep the Sobject Need to insert.
        Map<String, Sobject> mapParentIdToSobject = new Map<String, Sobject>();//!< This map is use to keep the Sobject corresponding to its parent records to insert 
        																		//!< as well to create the Note and Attachement record.
         
        //!< Iterating the Context object from the list to create corresponding target sobject records.
       	for(Sobject sobjSource : lstParentSobject)
        {
        	if(Schema.getGlobalDescribe().containsKey(strTargetObjectAPIName))
        	{
	            sObject sObj = Schema.getGlobalDescribe().get(strTargetObjectAPIName).newSObject();
	            sObj.put(strTargetParentRelationshipAPI,sobjSource.get('Id'));
	            String strParentId = ''; 
	            if(strParentRelationToContextAPI.contains('.'))
	            	strParentId = String.valueOf(sobjSource.getSObject(strParentRelationToContextAPI.subString(0,strParentRelationToContextAPI.indexOf('.'))).get(strParentRelationToContextAPI.subString(strParentRelationToContextAPI.indexOf('.') + 1,strParentRelationToContextAPI.length())));
	            else
	            	strParentId = String.valueOf(sobjSource.get(strParentRelationToContextAPI));
	           
	            if(mapIdToSobjectContext.containsKey((Id)strParentId))
	            {
		            Sobject sObjContext = mapIdToSobjectContext.get((Id)strParentId);
		            //!< Iterating the Field mapping records to map the field from context object to target object.	
		            for(Field_Mapping__c objFieldMapping : lstFieldMapping)
		            {
		            	if(objFieldMapping.Target_Field_Name__c != null &&  objFieldMapping.Target_Field_Name__c!= '' 
		            		&& objFieldMapping.Context_Field_Name__c != null && objFieldMapping.Context_Field_Name__c !='' && objFieldMapping.RecordType.DeveloperName == 'Reference')
		            	{
		            		sObj = fieldTypeCasting(sObj, mapSobjectNameToFieldsDescription.get(strTargetObjectAPIName),String.valueOf(sObjContext.get(objFieldMapping.Context_Field_Name__c)),objFieldMapping.Target_Field_Name__c);
		               		//sObj.put(objFieldMapping.Target_Field_Name__c, sObjContext.get(objFieldMapping.Context_Field_Name__c));//!< Setting the fields.
		            	}
		            	else if(objFieldMapping.Target_Field_Name__c != null &&  objFieldMapping.Target_Field_Name__c!= '' && objFieldMapping.Target_Value__c != null 
		            			&& objFieldMapping.Target_Value__c != '' && objFieldMapping.RecordType.DeveloperName == 'Value')
		            	{
		            		sObj = fieldTypeCasting(sObj, mapSobjectNameToFieldsDescription.get(strTargetObjectAPIName),objFieldMapping.Target_Value__c,objFieldMapping.Target_Field_Name__c);
		            		//sObj.put(objFieldMapping.Target_Field_Name__c, objFieldMapping.Target_Value__c);//!< Setting the fields.
		            	}
		            }
	            }
	            mapParentIdToSobject.put(strParentId,sObj);//!< Adding Sobject corresponding to parentId.
		        //lstSobject.add(sObj);//!< Adding Sobject 
        	}
        }
        if(!mapParentIdToSobject.isEmpty()) 
        	Database.insert(mapParentIdToSobject.values(), false);//!< Peforming the DML operation
        	
        if(isNote || isAttachment)
        	copyNoteAttachmentRecord(mapParentIdToSobject,isNote,isAttachment);//!< If we need to copy the Note and Attachemnt records then we will call this method.
        	
        /***This check has been performed as per the requirement of FAEF-39*****/
        if(isSharingRules)
        	copySharingRules(mapParentIdToSObject, strTargetObjectAPIName, strContextObjectAPIName);//calling method to copy sharing rules from parent object to child
        	
        return mapParentIdToSobject.values();//!< returnning the map.
    }
  	/* End */
   	/*!
        * MethodName : fieldMappingForRelatedList
        * param      :     
        * Description: This method is called to do the field mapping from Context Object to Target Object.
    */
    private List<Sobject> fieldMappingForRelatedList(List<Sobject> lstParentSobject, List<Field_Mapping__c> lstFieldMapping, 
													 Map<Id,List<Sobject>> mapContextIdToRelatedSobject, String strTargetObjectAPIName, 
													 String strTargetParentRelationshipAPI, String strParentRelationToContextAPI,
													 Boolean isNote, Boolean isAttachment, Boolean isSharingRules, String strContextObjectAPIName)
    {
        List<Sobject> lstSobject = new List<Sobject>(); //!< This list is use to keep the Sobject Need to insert.
        Map<String, Sobject> mapParentIdToSobject = new Map<String, Sobject>();//!< This map is use to keep the Sobject corresponding to its parent records to insert 
        																		//!< as well to create the Note and Attachement record.
       //!< Iterating the Context object from the list to create corresponding target sobject records.
       	for(Sobject sobjSource : lstParentSobject)
        {
        	String strParentId = ''; 
            if(strParentRelationToContextAPI.contains('.'))
            	strParentId = String.valueOf(sobjSource.getSObject(strParentRelationToContextAPI.subString(0,strParentRelationToContextAPI.indexOf('.'))).get(strParentRelationToContextAPI.subString(strParentRelationToContextAPI.indexOf('.') + 1,strParentRelationToContextAPI.length())));
            else
            	strParentId = String.valueOf(sobjSource.get(strParentRelationToContextAPI));
            	
        	if(mapContextIdToRelatedSobject.containsKey((Id)strParentId))
            {
	            for(Sobject sObjContext : mapContextIdToRelatedSobject.get((Id)strParentId))
	            {
	            	sObject sObj = Schema.getGlobalDescribe().get(strTargetObjectAPIName).newSObject();
	           		sObj.put(strTargetParentRelationshipAPI,sobjSource.get('Id'));
		            //!< Iterating the Field mapping records to map the field from context object to target object.	
		            for(Field_Mapping__c objFieldMapping : lstFieldMapping)
		            {
		            	if(objFieldMapping.Target_Field_Name__c != null &&  objFieldMapping.Target_Field_Name__c!= '' 
		            		&& objFieldMapping.Context_Field_Name__c != null && objFieldMapping.Context_Field_Name__c !='' && objFieldMapping.RecordType.DeveloperName == 'Reference')
		            	{
		            		sObj = fieldTypeCasting(sObj, mapSobjectNameToFieldsDescription.get(strTargetObjectAPIName),String.valueOf(sObjContext.get(objFieldMapping.Context_Field_Name__c)),objFieldMapping.Target_Field_Name__c);
		               		//sObj.put(objFieldMapping.Target_Field_Name__c, sObjContext.get(objFieldMapping.Context_Field_Name__c));//!< Setting the fields.
		            	}
		            	else if(objFieldMapping.Target_Field_Name__c != null &&  objFieldMapping.Target_Field_Name__c!= '' && objFieldMapping.Target_Value__c != null 
		            			&& objFieldMapping.Target_Value__c != '' && objFieldMapping.RecordType.DeveloperName == 'Value')
		            	{
		            		sObj = fieldTypeCasting(sObj, mapSobjectNameToFieldsDescription.get(strTargetObjectAPIName),objFieldMapping.Target_Value__c,objFieldMapping.Target_Field_Name__c);
		            		//sObj.put(objFieldMapping.Target_Field_Name__c, objFieldMapping.Target_Value__c);//!< Setting the fields.
		            	}
		            }
		            mapParentIdToSobject.put(String.valueOf(sObjContext.get('Id')),sObj);//!< Adding Sobject corresponding to parentId.
		            //lstSobject.add(sObj);//!< Adding Sobject corresponding  
	            }
            }
        } 
        
        if(!mapParentIdToSobject.isEmpty()) 
        	Database.insert(mapParentIdToSobject.values(), false);//!< Peforming the DML operation
        	
        if(isNote || isAttachment)
        	copyNoteAttachmentRecord(mapParentIdToSobject,isNote,isAttachment);//!< If we need to copy the Note and Attachemnt records then we will call this method.
        
        /***This check has been performed as per the requirement of FAEF-39*****/
        if(isSharingRules)
        	copySharingRules(mapParentIdToSobject, strTargetObjectAPIName, strContextObjectAPIName);//calling method to copy sharing rules from parent object to child
        
        return mapParentIdToSobject.values();//!< returnning the map.
    }
   /* End */
   
   	/*!
        * MethodName : copyNoteAttachmentRecord
        * param      : map of the Parent record Id to the Sobject corresponding to which the Note and Attachment records get created.  
        * Description: This method is used to create Note and Attachment Records on the basis of the Object_Relationship__c records.
    */
    private void copyNoteAttachmentRecord(Map<String, Sobject> mapParentIdToSobject, Boolean isNote, Boolean isAttachment)
    {
    	List<Note> lstNoteToInsert = new List<Note>();//!< This list is use to insert the Note records. 
    	List<Attachment> lstAttachmentToInsert = new List<Attachment>();//!< This list is use to insert the Attachment records.
    	
    	if(isNote)//!< Checking if we need to copy Note record or not.
    	{
    		///Query all the Note records to create/copy note to the newely created Sobject records.
    		for(Note objNote : [SELECT Id, Title, ParentId, IsPrivate, Body FROM Note WHERE ParentId IN : mapParentIdToSobject.keySet()])
    		{
    			//!< Mapping the fields with the exitance Attachment and the ParentId as the new created records.
    			lstNoteToInsert.add( new Note(Title=objNote.Title, Body = objNote.Body,IsPrivate = objNote.IsPrivate, 
    										  ParentId = (Id)mapParentIdToSobject.get(objNote.ParentId).get('Id')));
    		}
    	}
    	
    	if(isAttachment)//!< Checking if we need to copy Attachment record or not.
    	{
    		///Query all the Attachemnt records to create/copy note to the newely created Sobject records.
    		for(Attachment objAttachment : [SELECT ParentId, Name, Id, Description, ContentType, BodyLength, Body 
											FROM Attachment 
											WHERE ParentId IN : mapParentIdToSobject.keyset()])
			{
				//!< Mapping the fields with the exitance Attachment and the ParentId as the new created records.
				lstAttachmentToInsert.add(new Attachment(Body = objAttachment.Body, Name = objAttachment.Name,
														 ContentType = objAttachment.ContentType, 
														 ParentId = (Id)mapParentIdToSobject.get(objAttachment.ParentId).get('Id')));
			}
    	}
    	
    	if(!lstNoteToInsert.isEmpty())
    		Database.insert(lstNoteToInsert, false);//!< Peforming the DML operation
    	if(!lstAttachmentToInsert.isEmpty())
    		Database.insert(lstAttachmentToInsert, false);//!< Peforming the DML operation
    }
    /* End */
    
    
    /***This method has been created as per the requirement of FAEF-39*****/
    /*!
        * MethodName : copySharingRules
        * param      : map of the Parent record Id to the Sobject corresponding to which sharing rule records to be created, target object API name, parent object API name
        * Description: This method is used to copy all sharing rules from parent object to its child object
    */
    private void copySharingRules(Map<String, SObject> mapParentIdToSObject, String TargetObjectAPIName, String ContextObjectAPIName)
    {
    	Map<String, Schema.Sobjecttype> mapSobjectnameToSobject = Schema.getGlobalDescribe();//this map is used to keep schema of all objects in the org
    	//if target and context objects does not exist then return
    	if(!(mapSobjectnameToSobject.containskey(TargetObjectAPIName) && mapSobjectnameToSobject.containskey(ContextObjectAPIName)))
    			return;
    	Set<String> setParentId = new Set<String>();//this set is used to contain parent ids to use as filter while fetching sharing records from parent object.
    	Map<Id, List<Sobject>> mapParentIdToLstOfSharingRules = new Map<Id, List<Sobject>>();//map to collect sharing rules corresponding to parent Id
    	List<Sobject> lstSharingRulesToInsert = new List<Sobject>();// list of sharing rules that are to be inserted
    	
    	setParentId.addAll(mapParentIdToSObject.keyset());//adding elements of map keyset in a set.    	
    	List<String> lstParentObjectAttributes = getAttributeAPINames(ContextObjectAPIName, mapSobjectnameToSobject);//getting parent object attributes
    	List<String> lstChildObjectAttributes = getAttributeAPINames(TargetObjectAPIName, mapSobjectnameToSobject);//getting child object attributes    	
    	try
    	{
	    	//framing dynamic soql
	    	String strQuery = 'SELECT UserOrGroupId, '+ lstParentObjectAttributes[1]+', '+lstParentObjectAttributes[2]
	      					  +' FROM '+lstParentObjectAttributes[0]
	      					  +' WHERE '+(lstParentObjectAttributes[1]+' IN : setParentId');
	        //Iterating over dynamic soql to fill the map with parent id and its corresponding list of sharing records
	        for(Sobject objSObject : Database.query(strQuery))
	        {
	        	String strParentId = String.valueOf(objSObject.get(lstParentObjectAttributes[1]));
	        	if(!mapParentIdToLstOfSharingRules.containskey(strParentId))
	        		mapParentIdToLstOfSharingRules.put(strParentId,new List<Sobject>{objSObject});
	        	else
	        		mapParentIdToLstOfSharingRules.get(strParentId).add(objSObject);        		
	        }
	        
	        //Iterating over map key set to clone sharing rules
	        for(String strParentId : mapParentIdToSObject.keyset())
	        {
	        	//checking if contains parent id or not
	        	if(mapParentIdToLstOfSharingRules.containskey(strParentId))
	        	{
	        		//getting all the sharing rules related to parent and associating them with child records
	        		for(Sobject objParentShare : mapParentIdToLstOfSharingRules.get(strParentId))
	        		{
	        			Sobject objSobject = mapSobjectnameToSobject.get(lstChildObjectAttributes[0]).newSobject();
	        			//Setting the value of userid
	        			objSobject.put('UserOrGroupId',String.valueOf(objParentShare.get('UserOrGroupId')));
	        			//Setting the value of access level
	        			objSobject.put(lstChildObjectAttributes[2],String.valueOf(objParentShare.get(lstParentObjectAttributes[2])));
	        			//Setting the value of parent id
	        			objSobject.put(lstChildObjectAttributes[1],String.valueOf(mapParentIdToSObject.get(strParentId).get('Id')));
	        			lstSharingRulesToInsert.add(objSobject);
	        		}
	        		
	        	}
	        }
	        
	        if(!lstSharingRulesToInsert.isEmpty())
	        	Database.insert(lstSharingRulesToInsert,false);//inserting the sharing rules
    	}
    	catch(DMLException ex)
    	{
    		System.debug('=================='+ex.getLineNumber()+'==================='+ex.getMessage());
    	}
    	catch(Exception ex)
    	{
    		System.debug('=================='+ex.getLineNumber()+'==================='+ex.getMessage());
    	}
    }
    
    /* End */
    
    /***This method has been created as per the requirement of FAEF-39*****/
    /*!
        * MethodName : getAttributeAPINames
        * param      : name of the sobject and global describe map
        * Description: This method is used to get sobject attributes API names
    */
    private List<String> getAttributeAPINames(String strObjectName, Map<String, Schema.Sobjecttype> mapSobjectnameToSobject)
    {
    	 return mapSobjectnameToSobject.get(strObjectName).getDescribe().isCustom() ? new List<String>{strObjectName.replace('__c','__Share'),'ParentId','AccessLevel'} : new List<String>{strObjectName+'Share',strObjectName+'Id',strObjectName+'AccessLevel'};
    }
    /* End */
   
   /*!
        * MethodName : fieldTypeCasting
        * param      :     
        * Description: This method is called to do the type casting.
    */
   private Sobject fieldTypeCasting(Sobject sObjTarget, Map<String, Schema.SObjectField> mapFieldDef, String fieldValue, String TargetFieldAPIName)
   {
   		try
   		{
   			if(TargetFieldAPIName != null && TargetFieldAPIName != '' && mapFieldDef.containsKey(TargetFieldAPIName) && mapFieldDef.get(TargetFieldAPIName) != null)
   			{
	   			Schema.SObjectField field = mapFieldDef.get(TargetFieldAPIName);
		        Schema.DisplayType fieldType = field.getDescribe().getType();
		        
		        if(field.getDescribe().isUpdateable() && fieldValue != null && fieldValue != '')
		        {
		        	if ((fieldType == Schema.DisplayType.DOUBLE) || (fieldType == Schema.DisplayType.CURRENCY))
	             	{
	                 	// Validating field is double or not else giving custom exception
	                 	if(fieldValue.remove('.').isNumeric())	
	                 		sObjTarget.put(TargetFieldAPIName,double.valueOf(fieldValue));
	                 	else
	                 		sObjTarget.addError('Incorrect value for decimal field');
	             	}
	                else if (fieldType == Schema.DisplayType.BOOLEAN)
	                	sObjTarget.put(TargetFieldAPIName,Boolean.valueOf(fieldValue));
	                else if (fieldType == Schema.DisplayType.INTEGER)
	                	sObjTarget.put(TargetFieldAPIName,Integer.valueOf(fieldValue));
	                else if (fieldType == Schema.DisplayType.Date)
	            	{
                		//Replacing '-' to '/'. Date.Parse() method take string in a specific format which takes '/' 
                		List<String> lstDate = new List<String>();
                		fieldValue = fieldValue.replace('00:00:00', '').replaceAll('-', '/').trim();
                		lstDate.addAll(fieldValue.split('/'));
                		Integer intYear = (lstDate[0].length() == 4) ? Integer.valueOf(lstDate[0]) :  Integer.valueOf(lstDate[2]);	
	            		Integer intMonth = (lstDate[0].length() == 4) ? Integer.valueOf(lstDate[1]): Integer.valueOf(lstDate[0]);
	            		Integer intDate = (lstDate[0].length() == 4) ? Integer.valueOf(lstDate[2]): Integer.valueOf(lstDate[1]);
	            		
                		sObjTarget.put(TargetFieldAPIName, Date.newinstance(intYear,intMonth,intDate));
	            	}
	        	 	else if (fieldType == Schema.DisplayType.Id)
	        	 		sObjTarget.put(TargetFieldAPIName,Id.valueOf(fieldValue));
	        	 	else if(fieldType == Schema.DisplayType.DateTime)
	        	 	{
	        	 		fieldValue = fieldValue.replaceAll('/','-');
	        	 		if(fieldValue.split('/')[0].length() == 4)
	        	 		{
		        	 		List<String> lstDate = new List<String>();
							String strDate = fieldValue.split(' ')[0];
							String strTime = (fieldValue.split(' ').size() > 1) ? fieldValue.split(' ')[1] : '00:00:00';
							lstDate.addAll(strDate.split('-'));
							fieldValue = lstDate[2] + '-' + lstDate[0] + '-' + lstDate[1] + ' ' + strTime;
	        	 		}
	        	 		
                		sObjTarget.put(TargetFieldAPIName,DateTime.valueOf(fieldValue));
	        	 	}
	                else  // Checking with field length and populating string with accommodate size
	                	sObjTarget.put(TargetFieldAPIName,String.valueOf(fieldValue).length() > field.getDescribe().getLength() ? String.valueOf(fieldValue).substring(0,field.getDescribe().getLength()) :String.valueOf(fieldValue));
		        }
   			}
	        
   		}
   		catch(Exception ex)
   		{
   			sObjTarget.addError(''+ ex.getMessage());
   		}
   		return sObjTarget;
   }
    /* End */
}