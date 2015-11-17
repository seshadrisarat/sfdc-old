public with sharing class SL_CustomLookUpController
{
    /* Start - Variable Declaration */
    public List<sObject> lstSObject             {get;set;}      //
    public String strCheckInField               {get;set;}      //
    public Boolean isNewRecord                  {get;set;}      //
    public List<String> lstFieldNames           {get;set;}      //
    public List<String> lstColumnLabels         {get;set;}      //
    public String strSearch                     {get;set;}      //
    public sObject dynamicSObject               {get;set;}      //
    public List<String> lstSObjectFieldNames    {get;set;}      //
    public String strObjectLabel                {get;set;}      //
    public String strRecordNameInputId          {get;set;}      //
    public String strRecordIdInputId            {get;set;}      //
    
    private String strObjName;
    private Map<String, String> mapObject_FieldNames;
    private static Map<String, List<String>> mapObject_ColumnLabel;
    /* End - Variable Declaration */
    
    //constructor
    public SL_CustomLookUpController() 
    {
        try
        {
            /**********Initialize variables***********/
            strObjectLabel = strRecordNameInputId= strRecordIdInputId='';
            strObjName = strCheckInField = strSearch = '';
            isNewRecord = false;
            lstSObject = new List<sObject>();
            lstSObjectFieldNames = new list<String>();
            lstFieldNames = new List<String>();
            lstColumnLabels = new List<String>();
            lstSObjectFieldNames = new List<String>();
            mapObject_FieldNames = new Map<String, String>();
            mapObject_ColumnLabel = new Map<String, List<String>>();
            /*******Fetch attribute values from URL**************/
            strObjName = System.currentPageReference().getParameters().get('ObjectName');  
            strRecordNameInputId = System.currentPageReference().getParameters().get('inputBox_name');  //Id of an input box of a lookup name
            strRecordIdInputId = System.currentPageReference().getParameters().get('inputBox_id');      //Id of an input box of a lookup id
            strCheckInField = System.currentPageReference().getParameters().get('FieldName');           //fields to be filtered by object
            strSearch = System.currentPageReference().getParameters().get('MatchingString');            //String that has to be searched in the object
            
            //get the field labels and field names (from FieldSets and Custom Object) by describe calls 
            getFieldSetData();
            //Get the lists of field names and labels to be displayed on the page.
            if(strObjName != null || strObjName != 'null')
            	strObjName = String.escapeSingleQuotes(strObjName);
            //Comma separated fields of a selected object 
            String strFieldsOfObject = mapObject_FieldNames.get(strObjName);
            if(strFieldsOfObject != Null && strFieldsOfObject != '')
                lstFieldNames = strFieldsOfObject.split(', ');
            
            //List of column labels
            lstColumnLabels = mapObject_ColumnLabel.get(strObjName);
            
            //Calling a method to search records to display
            searchRelatedTo();
        }
    	catch(Exception e)
    	{
  			 system.debug('=========Exception===='+e);
     	}
    }

    /**
     * @method      :   getFieldSetData
     * @param       :   None
     * @return      :   void
     * @description :   fetches the field labels and the field names being selected in the 'customLookupFieldSet' FieldSet 
                        for the object being passed dynamically from the url
     */
    public void getFieldSetData()
    {
	        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
	        Schema.SObjectType objSchema = schemaMap.get(strObjName);
	        //Get the object label that has been entered through the url
	        strObjectLabel = objSchema.getDescribe().getLabel();
	        //Creating new sobject to use it in input field for dynamic creation
	        dynamicSObject = objSchema.newSObject();
	        
	        //Creating a map of fieldsets
	        Schema.DescribeSObjectResult sObjectResult = objSchema.getDescribe();
	        Map<String, Schema.FieldSet> sObjectFieldSetMap = sObjectResult.fieldSets.getMap();
	        String strFieldNames = '';
	        
	        /* Get the fields that have been inserted in the fieldSet of the object named as "customLookupFieldSet" */ 
	        if(sObjectFieldSetMap.containsKey('customLookupFieldSet'))
	        {
	            for(Schema.FieldSetMember f : sObjectFieldSetMap.get('customLookupFieldSet').getFields())
	            {
	                if(mapObject_ColumnLabel.containsKey(strObjName))
	                {
	                    mapObject_ColumnLabel.get(strObjName).add(f.getLabel());
	                    strFieldNames += ', ' + f.getFieldPath();
	                }
	                else
	                {
	                    mapObject_ColumnLabel.put(strObjName, new List<String>{f.getLabel()});
	                    strFieldNames = f.getFieldPath();
	                }
	            }
	            mapObject_FieldNames.put(strObjName, strFieldNames);
	        }  
	        
	        /* Get the required fields and the main field where the search string has to be searched */
	        Map<String, Schema.SObjectField> fieldMap = objSchema.getDescribe().fields.getMap();
	        Boolean isAutoNumber = false;
	        
	        Set<String> setSObjectFieldNames = new Set<String>();
	        
	        for(String fieldName : fieldMap.keySet())
	        {
	            Schema.SObjectField field = fieldMap.get(fieldName);
	            Schema.DescribeFieldResult fieldDesc = field.getDescribe();
	            
	            if(isAutoNumber && fieldDesc.isDefaultedOnCreate() && fieldDesc.isAutoNumber())
	                strCheckInField = fieldDesc.getName();
	            
	            if(fieldDesc.isAccessible() && !fieldDesc.isNillable() && fieldDesc.isUpdateable() && fieldDesc.getName() != 'OwnerId')
	            {    
	                setSObjectFieldNames.add(fieldDesc.getName());
	            }
	        }  
	        
	        /* Get the fields that have been inserted in the customLookupNewObject fieldSet of the object */
	        if(sObjectFieldSetMap.containsKey('customLookupNewObject'))
	        {
	            for(Schema.FieldSetMember f : sObjectFieldSetMap.get('customLookupNewObject').getFields())
	            {
	                setSObjectFieldNames.add(f.getFieldPath());
	            }
	        }
	        
	        lstSObjectFieldNames.addAll(setSObjectFieldNames);
    	}
    
     
    /**
     * @method      :   searchRelatedTo
     * @param       :   None
     * @return      :   void
     * @description :   search the records based on the search string
     */
    public void searchRelatedTo()
    {
        isNewRecord = false;
        lstSObject = new List<sObject>();
        
        //Fields to be searched are being formed in a string "strFields"
        string strFields = '';
        
        if(mapObject_FieldNames.get(strObjName) != Null && mapObject_FieldNames.get(strObjName) != '')
            strFields = mapObject_FieldNames.get(strObjName) + ',';
        
        if(!strFields.contains(strCheckInField + ','))
            strFields += strCheckInField;
        
        if( strFields.lastIndexOf(',') == strFields.length()-1 )
            strFields = strFields.substring(0, strFields.length()-1);
        
        //Query the records related to the searched string
        if(strObjName != '' && strObjName != null)
        {
            if(strSearch == null && strSearch == '') //SOQL for all records
            {
                String queryStr = 'SELECT Id, '+ strFields +' FROM ' + strObjName +' LIMIT 1000';
                
                lstSObject = Database.query(queryStr);
            }
            else
            {
                String strQuery = '';
                
                //Removing all special characters
                String strSearchTextWithoutSpecialChar = strSearch.replaceAll('%' , '').replaceAll('"' , '')
                                                                  .replaceAll('/' , '').replaceAll('\\*' , '').replaceAll('\\\\' , '');
                
                String strSearchName = '\''+String.escapeSingleQuotes(strSearchTextWithoutSpecialChar)+'*\'';
                
                if(strSearchName.length() > 5)  //SOSL
                {
                    //  forming a dynamic SOSL
                    strQuery = 'Find ' + strSearchName + ' IN Name Fields Returning ' +
                                strObjName +
                                '( Id,' + strFields + ')';
                    
                    //Querying the records (SOSL query)
                    if(strQuery.length() > 0 && strQuery != Null)
                    {
                        List<List<SObject>> searchList = search.query(strQuery);
                        lstSObject = searchList[0];
                    }
                }
                else    //SOQL
                {
                    //Search term's single quotes is being escaped 
                    strSearchName = '\'%' + String.escapeSingleQuotes(strSearchTextWithoutSpecialChar) + '%\'';
                    
                    //  forming a dynamic SOQL
                    //String queryStr='SELECT Id, '+ strFields +' FROM ' + strObjName + ' WHERE '+ queryField +' LIKE '+ strSearchName +' LIMIT 1000';
                    String queryStr = 'SELECT Id, '+ strFields +' FROM ' + strObjName + ' WHERE '+ 
                    				   strCheckInField +' LIKE '+ strSearchName +' LIMIT 1000';
                    
                    //Querying the records (SOQL)
                    if(queryStr.length() > 0 && queryStr != Null)
                        lstSObject = Database.query(queryStr);
                }
            }
        }
    }
    
    /**
     * @method      :   saveDynamicObj
     * @param       :   None
     * @return      :   void
     * @description :   Inserts an newly created sObject 
     */
    public Void saveDynamicObj()
    {
        insert dynamicSObject;
    }     

}