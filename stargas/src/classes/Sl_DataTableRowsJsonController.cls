/**  
* \arg ClassName      : SL_PriceTables
* \arg JIRATicket     : STARGAS-10, STARGAS-34
* \arg CreatedOn      : 16/JUL/2014
* \arg LastModifiedOn : 29/JAN/2015
* \arg CreatededBy    : SRUTI
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This is controller is used for fetching and send data in form of a JSON string to page
*/

public with sharing class Sl_DataTableRowsJsonController 
{
	public string strJosonDatas {get;set;}//JSON string to be passed to page to diplay records
	
  
	/**
	* @Name     : Constructor
	* @Description  : Fetching all the Price Table records
	*/
	public Sl_DataTableRowsJsonController()
	{
		try
		{
			strJosonDatas = '';
			// Fetching the Passed Values from the Page via URL
			String strDivisionDB = ApexPages.currentPage().getParameters().get('divisionSB');
			String strDivisionName = ApexPages.currentPage().getParameters().get('division');
			String strDivisionGroup = ApexPages.currentPage().getParameters().get('divisiongroup');
			String strSObjectName = ApexPages.currentPage().getParameters().get('sObjectName');
			String strFieldSetName = ApexPages.currentPage().getParameters().get('fieldSetName');
			String strfilter = ApexPages.currentPage().getParameters().get('filter');
			String strfilterLevel = ApexPages.currentPage().getParameters().get('sublevel');
			String strpriceType = ApexPages.currentPage().getParameters().get('priceType');
			String strTankTypeParam = ApexPages.currentPage().getParameters().get('tanktype');
			String strCustomerOwned = ApexPages.currentPage().getParameters().get('customerowned');
			
			
			Set<String> setFields = new Set<String>();            // Set used to store the API Names of the Fields present in the Fieldset.
			Map<String, String> mapNames = new Map<String, String>();    // Map used to store the values after splitting the lookUpNamefields 
			list<sObject> lstSObjectRecords = new list<sObject>();	//Storing list of sobject records retrieved from query 
	        
	        Boolean displayPricetable = true;
	        
	        //Displaying Price Table records based on the Conditions and parameter Passes to the components 
	        if(strfieldSetName == 'Propane_Rec_Fieldset' && (isNullOrBlank(strDivisionDB) || isNullOrBlank(strDivisionName)))
	        {
	        	//When any of the required field is Blank for Propane 
	        	displayPricetable = false;
	        }
	        else if(strfieldSetName == 'Oil_Rec_Fieldset' && (isNullOrBlank(strDivisionDB) || isNullOrBlank(strDivisionName) || isNullOrBlank(strDivisionGroup)))
	        {
	        	//When any of the required field is Blank for Oil
	        	displayPricetable = false;
	        }
	        //Peparing Filter Query string for Propane 
			else if(strfieldSetName != null && strfieldSetName == 'Propane_Rec_Fieldset')
			{
				if(strDivisionDB != null && strDivisionDB != '')
	        		strfilter += strfilter == ''? (' WHERE Division_DB__c = \''+ strDivisionDB +'\'') : ( ' AND Division_DB__c =\'' +strDivisionDB+'\'');
	
	        	if(strDivisionName != null && strDivisionName != '')
	        		strfilter += strfilter == ''? (' WHERE Division_ID__c = \''+ strDivisionName +'\'') : ( ' AND Division_ID__c = \'' +strDivisionName+'\'');
				
				/* Start - This code snippet has been added as per the requirement of STARGAS-34 */
        		if(String.isEmpty(strCustomerOwned) || strCustomerOwned == 'No')
					strfilter += strfilter == ''? (' WHERE (Tank_Type__c = \'0\' OR Tank_Type__c = \'1\')') : ( ' AND (Tank_Type__c = \'0\' OR Tank_Type__c = \'1\')');
				else if(strCustomerOwned == 'Yes')
					strfilter += strfilter == ''? (' WHERE (Tank_Type__c = \'2\' OR Tank_Type__c = \'0\')') : ( ' AND (Tank_Type__c = \'2\' OR Tank_Type__c = \'0\')');
				/* End - This code snippet has been added as per the requirement of STARGAS-34 */	
			}
			//Peparing Filter Query string for Oil
			else if(strfieldSetName != null && strfieldSetName == 'Oil_Rec_Fieldset')
			{
				if(strDivisionGroup != null && strDivisionGroup != '')
	        		strfilter += strfilter == ''? (' WHERE Division_Group__c = \''+ strDivisionGroup +'\'') : ( ' AND Division_Group__c =\'' +strDivisionGroup+'\'');
			}
			
			// If all Required field are present, we are Querying Price Table records
			if(displayPricetable)
			{
				String strQuery = 'select ID, ';
					    
				for(Schema.FieldSetMember fieldSetMemberObj : readFieldSet(strFieldSetName,strSObjectName))
				{
					setFields.add(fieldSetMemberObj.getFieldPath());
				}
				    
				for(String strFieldAPIs : setFields)
				{
					setFields.add(strFieldAPIs);
					if(mapNames.get(strFieldAPIs) != null )
					    setFields.add(mapNames.get(strFieldAPIs));
				}
				        
				// getting all the fields from the updated set
				for(String strfieldstobeQueried : setFields)
					strQuery += strfieldstobeQueried + ', ';
					
				strQuery = strQuery.substring(0, strQuery.length() - 2) + ' From ' +strSObjectName+ ' ' +strfilter + ' '+' ORDER BY Tank_Type__c, Price_Type__c' ; 
											
				lstSObjectRecords.addAll(Database.query(strQuery));
				    
				// Serializing the Data to JSON format
				strJosonDatas = json.serialize(lstSObjectRecords);
				strJosonDatas = strJosonDatas.substring(1, strJosonDatas.length() - 1);
				system.debug('==========strJosonDatas========'+strJosonDatas);
			}
		}
		catch(exception e)
		{
		}
	}
	
	//Validation for String
    private Boolean isNullOrBlank(String str)
    {
    	if(str == null || string.isEmpty(str))
    		return true;
    	else return false;
    }
  
	/**
		* @Name      : readFieldSet()
		* @Description  : A private static method used to get the fields from the field set, fetched from the URL
	*/  
	private static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName)
	{
		Schema.FieldSet fieldSetObj = Schema.getGlobalDescribe().get(ObjectName).getDescribe().FieldSets.getMap().get(fieldSetName);
		return fieldSetObj.getFields(); 
	}
}