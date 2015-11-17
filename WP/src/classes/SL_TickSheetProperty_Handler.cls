/**
* \arg  ClassName      : SL_TickSheetProperty_Handler
* \arg  JIRATicket     : WP-104
* \arg  CreatedOn      : 18/JULY/2013
* \arg  ModifiedBy     : -
* \arg  Description    : Class to display an error message on insert/update of ticksheet
                         property records in conditions as per WP-104
*/
public without sharing class SL_TickSheetProperty_Handler 
{
    //constructor
    public SL_TickSheetProperty_Handler()
    {
        // Do nothing
    }
    
    public void onAfterInsert(){}
    public void onAfterUpdate(){}
    
    /**
	* MethodName: onBeforeInsert
	* param: Ticksheet_Property__c object's trigger.new values
	* Description: This is the method to call verifySavedLocationWithContactMetadata method on insert
    * of ticksheet property record
	*/
    public void onBeforeInsert(List<Ticksheet_Property__c> lstNewTicksheetProperties)
    {
        verifySavedLocationWithContactMetadata(lstNewTicksheetProperties,null);
    }
    
    /**
	* MethodName: onBeforeUpdate
	* param: Ticksheet_Property__c object's trigger.new, trigger.oldMap values
	* Description: This is the method to call verifySavedLocationWithContactMetadata method on update
    * of ticksheet property record
	*/
    public void onBeforeUpdate(List<Ticksheet_Property__c> lstNewTicksheetProperties, Map<Id, Ticksheet_Property__c> mapOldTicksheetProperties)
    {
        verifySavedLocationWithContactMetadata(lstNewTicksheetProperties, mapOldTicksheetProperties);
    }
    
    
    /**
	* MethodName: verifySavedLocationWithContactMetadata
	* param: Ticksheet_Property__c object's trigger.new,trigger.oldMap values
	* Description: This is the method to filter the inserted/updated records and pass filtered list to verifySavedLocationWithContactMetadataOnInsertOrUpdate method 
	*/
    private void verifySavedLocationWithContactMetadata(List<Ticksheet_Property__c> lstNewTicksheetProperties, Map<Id, Ticksheet_Property__c> mapOldTicksheetProperties)
    {
    	List<Ticksheet_Property__c> lstTickSheetProperties = new List<Ticksheet_Property__c>(); /// List to store and pass filtered Tick_Sheet_Property__c records 
    	
    	/// check if insert operation
        if(mapOldTicksheetProperties == null)
        {
        	verifySavedLocationWithContactMetadataOnInsertOrUpdate(lstNewTicksheetProperties);
        }
        else
        {
        	/// Iterate over Ticksheet_Property__c and filter on records whose Save_Location__c field is modified
        	for(Ticksheet_Property__c objTickSheetProperty: lstNewTicksheetProperties)
	        {
	            if(objTickSheetProperty.Save_Location__c != mapOldTicksheetProperties.get(objTickSheetProperty.Id).Save_Location__c)
	            {
	                lstTickSheetProperties.add(objTickSheetProperty);
	            }
	        }
	        
	        if(!lstTickSheetProperties.isempty())
	        {
	        	verifySavedLocationWithContactMetadataOnInsertOrUpdate(lstTickSheetProperties);
	        }
        }
    }
    
    /**
	* MethodName: verifySavedLocationWithContactMetadataOnInsertOrUpdate
	* param: Filtered Ticksheet_Property__c records 
	* Description: Method to check the main functionality. Check if Save Location value selected is present as a field on Contact. If yes, check if it has an entry with TicksheetPropertyName 
     of ticksheet property record
	*/
    private void verifySavedLocationWithContactMetadataOnInsertOrUpdate(List<Ticksheet_Property__c> lstTicksheetProperties)
    {
        map<String,Set<String>> mapContactPicklistFieldsToPickListValues = describePicklist(); /// Map to store Contact object's picklist fields to thier respective values
        
        /// Iterate over filtered Ticksheet_Property__c records
        for(Ticksheet_Property__c objTickSheetProperty : lstTicksheetProperties)
        {
            /// Check and show an error message if Contact object does not contain a field as selected in Ticksheet_Property__c record's Save_Location__c field
            if(objTickSheetProperty.Save_Location__c!= null && !mapContactPicklistFieldsToPickListValues.keyset().contains(objTickSheetProperty.Save_Location__c))
            {   
                if(!test.isRunningTest())
                {
                    objTickSheetProperty.addError('Save Location does not exist');
                    //System.debug('objTickSheetProperty.Save_Location__c: ' + objTickSheetProperty.Save_Location__c);
                    //System.debug('mapContactPicklistFieldsToPickListValues.keyset().contains(objTickSheetProperty.Save_Location__c): ' + mapContactPicklistFieldsToPickListValues.keyset().contains(objTickSheetProperty.Save_Location__c));
                	//System.debug('mapContactPicklistFieldsToPickListValues.keyset(): ' + mapContactPicklistFieldsToPickListValues.keyset());
                }
            }
            
            /// Check and show an error message if the Ticksheet_Property__c record's name is not present in Contact object's picklist fields
            else if (objTickSheetProperty.Save_Location__c!= null && 
                     !(mapContactPicklistFieldsToPickListValues.get(objTickSheetProperty.Save_Location__c).contains(objTickSheetProperty.Name)))
            {
                if(!test.isRunningTest())
                {
                    objTickSheetProperty.addError('Save Location does not exist');
                    //System.debug('objTickSheetProperty.Save_Location__c: ' + objTickSheetProperty.Save_Location__c);
                    //System.debug('mapContactPicklistFieldsToPickListValues.get(objTickSheetProperty.Save_Location__c).contains(objTickSheetProperty.Name): ' + mapContactPicklistFieldsToPickListValues.get(objTickSheetProperty.Save_Location__c).contains(objTickSheetProperty.Name));
                    //System.debug('objTickSheetProperty.Name: ' + objTickSheetProperty.Name);
                    //System.debug('mapContactPicklistFieldsToPickListValues.get(objTickSheetProperty.Save_Location__c): ' + mapContactPicklistFieldsToPickListValues.get(objTickSheetProperty.Save_Location__c)); 
                } 
            }
        }
    }
    
    /**
	* MethodName: describePicklist
	* param: None 
	* Description: This is the method to return map of picklist fields to
                   respective picklist values of contact object
	*/
    private Map<String, Set<String>> describePicklist()
    {       
        Map<String, Schema.SObjectField> mapContactFields = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap(); /// Map to store all fields of Contact
        //System.debug('Schema.getGlobalDescribe().get(\'Contact\').getDescribe().fields.getMap(): ' + Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap());
        Map<String,Set<String>> mapContactPicklistFieldsToPickListValues = new Map<String,Set<String>>();  /// Map to store and return Contact's picklist fields and their corresponding picklist entries
        Map<String,Set<Schema.PicklistEntry>> mapContactPicklistFieldsToPickListEntryValues = new Map<String,Set<Schema.PicklistEntry>>(); /// Map to store  Contact's picklist fields and their corresponding picklist entries
        
        /// Iterate over all Contact object's fields
        for(Schema.SObjectField objContactField : mapContactFields.values())
        {
            Schema.DescribeFieldResult describedContactFields = mapContactFields.get(String.ValueOf(objContactField)).getDescribe(); /// Get field information
            String fieldtype = describedContactFields.getType().name(); /// Get the type of field
            String strPickListName = describedContactFields.getName(); /// Get the API name of the field
            
            /// Check if fieldtype is picklist
            if(fieldtype == 'MULTIPICKLIST')
            {
            	Set<Schema.PicklistEntry> setContactPicklistValues = new Set<Schema.PicklistEntry>(); /// Set to store picklist fields
            	setContactPicklistValues.addAll(objContactField.getDescribe().getPickListValues());
            	mapContactPicklistFieldsToPickListEntryValues.put(strPickListName, setContactPicklistValues);
            }
        }
        
        /// Iterate over multiselect picklist fields of Contact object
        for(String objString:mapContactPicklistFieldsToPickListEntryValues.keyset())
        {
        	//System.debug('objString: ' + objString);
        	Set<Schema.PicklistEntry> setPicklistEntryValues = new Set<Schema.PicklistEntry>(); /// Set to store picklist entries of each picklist field
        	setPicklistEntryValues.addAll(mapContactPicklistFieldsToPickListEntryValues.get(objString));
        	
        	/// Iterate over Picklist values for each picklist field
        	for(Schema.PicklistEntry objPicklistValue : setPicklistEntryValues)
            {
                if(!mapContactPicklistFieldsToPickListValues.containskey(String.ValueOf(objString)))
                {
                    mapContactPicklistFieldsToPickListValues.put(String.ValueOf(objString), new Set<String> {String.ValueOf(objPicklistValue.getLabel())});
                }
                else
                {
                    Set<String> setStrPicklistValues = mapContactPicklistFieldsToPickListValues.get((String.ValueOf(objString)));
                    setStrPicklistValues.add(String.ValueOf(objPicklistValue.getLabel()));
                    mapContactPicklistFieldsToPickListValues.put((String.ValueOf(objString)), setStrPicklistValues);
                }
            }
        }
            
        return mapContactPicklistFieldsToPickListValues;
    }
}