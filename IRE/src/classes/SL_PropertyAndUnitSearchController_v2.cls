/**
* \arg ClassName      : SL_PropertyAndUnitSearchController
* \arg JIRATicket     : IRE-120
* \arg CreatedOn      : 4/AUG/2015
* \arg LastModifiedOn : 26/AUG/2015
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This class serves as controller for searching Property and Unit custom search based on some search filters.
*/
public with sharing class SL_PropertyAndUnitSearchController_v2 
{
	/* Start - Page Variables */
	public List<queryFilterElements> lstFilterElements {get;set;}// list to hold the filter elements that are displayed on ui and displayed dynamically from field set.
	/* End - Page Variables */
	
	/* Start - Class Variables */
	private static Map<String, Schema.Sobjecttype> mapAllObjects = Schema.getGlobalDescribe();
	/* End - Class Variables */
	
	/* Start - Wrapper classes*/
	public class choicePicklistWrapper
	{
		public String strLabel	{get;set;}
		public String strValue	{get;set;}
		
		public choicePicklistWrapper(String strValue, String strLabel)
		{
			this.strLabel = strLabel;
			this.strValue = strValue;
		}
	}
	
	public class queryFilterElements
	{
		public String labelName {get;set;}
		public String apiName {get;set;}
		public String fldType {get;set;}
		public List<String> plValues {get;set;}
		public String objectName {get;set;}
	}
	
	/* End - Wrapper classes*/
	
	/* Start - Constructor */
	public SL_PropertyAndUnitSearchController_v2()
	{
		initialize();
	}
	/* End - Constructor */
	
	/*
		* MethodName        : getPicklistOptions
		* param             : -
		* Description       : This getter method is used to show the picklist values on the page which a user selects an option from, in order to perform searching.
	*/
	public List<choicePicklistWrapper> getPicklistOptions()
	{
		return new List<choicePicklistWrapper>{new choicePicklistWrapper('PropertyAndUnits', 'Properties & Units'), new choicePicklistWrapper('Properties', 'Properties'), new choicePicklistWrapper('Units', 'Units')};
	}
	
	/*
		* MethodName        : initialize
		* param             : -
		* Description       : This method is called to initialize both class and page variables and to call the methods related to field set for displaying fields on the visualforce page.
	*/
	private void initialize()
	{
		lstFilterElements = new List<queryFilterElements>();
		readFieldSet('Unit__c','searchFilters');
		readFieldSet('Property__c','searchFilters');
	}
	
	/*
		* MethodName        : readFieldSet
		* param             : object name and field set name
		* Description       : This method is used to fetch the fields from the field set name which has been supplied as parameter and created on the named object.
	*/
	private void readFieldSet(String objectName, String fieldSetName)
	{
		for(Schema.FieldSetMember fieldSetMember : mapAllObjects.get(objectName).getDescribe().FieldSets.getMap().get(fieldSetName).getFields())
		{
			queryFilterElements objqueryFilterElements = new queryFilterElements();
			
			objqueryFilterElements.labelName = fieldSetMember.getLabel();
			objqueryFilterElements.objectName = objectName;
			
			if(fieldSetMember.getType() == Schema.DisplayType.Currency || fieldSetMember.getType() == Schema.DisplayType.Integer || fieldSetMember.getType() == Schema.DisplayType.Double)
			{				
				objqueryFilterElements.fldType = 'number';
				objqueryFilterElements.apiName = fieldSetMember.getFieldPath();
			}
			else if(fieldSetMember.getType() == Schema.DisplayType.Boolean)
			{
				objqueryFilterElements.fldType = 'boolean';
				objqueryFilterElements.apiName = fieldSetMember.getFieldPath();
			}
			else if(fieldSetMember.getType() == Schema.DisplayType.Date)
			{
				objqueryFilterElements.fldType = 'date';
				objqueryFilterElements.apiName = fieldSetMember.getFieldPath();
			}
			else if(fieldSetMember.getType() == Schema.DisplayType.DateTime)
			{
				objqueryFilterElements.fldType = 'datetime';
				objqueryFilterElements.apiName = fieldSetMember.getFieldPath();
			}
			else if(fieldSetMember.getType() == Schema.DisplayType.String || fieldSetMember.getType() == Schema.DisplayType.URL || fieldSetMember.getType() == Schema.DisplayType.Phone || fieldSetMember.getType() == Schema.DisplayType.Email || fieldSetMember.getType() == Schema.DisplayType.Reference)
			{
				if(fieldSetMember.getType() != Schema.DisplayType.Reference)
				{
					objqueryFilterElements.fldType = 'string';
					objqueryFilterElements.apiName = fieldSetMember.getFieldPath();
				}
				else
				{
					objqueryFilterElements.fldType = 'reference';
					objqueryFilterElements.apiName = getLkupObjStatic(fieldSetMember.getFieldPath(), objectName)+'_Name';
				}
			}
			else if(fieldSetMember.getType() == Schema.DisplayType.Picklist)
			{
				objqueryFilterElements.fldType = 'picklist';
				objqueryFilterElements.plValues = getPicklistValues(fieldSetMember.getFieldPath(), objectName);
				objqueryFilterElements.apiName = fieldSetMember.getFieldPath();
			}
			else if(fieldSetMember.getType() == Schema.DisplayType.MultiPicklist)
			{
				objqueryFilterElements.fldType = 'multipicklist';
				objqueryFilterElements.plValues = getPicklistValues(fieldSetMember.getFieldPath(), objectName);
				objqueryFilterElements.apiName = fieldSetMember.getFieldPath();
			}
			
			lstFilterElements.add(objqueryFilterElements);
		}	
	}
	
	/*
		* MethodName        : getPicklistValues
		* param             : field api name and object name
		* Description       : This method is used to fetch the picklist values from the field that has been supplied as parameter.
	*/
	private List<String> getPicklistValues(String fldApiName, String objectName)
	{
		List<String> picklistValues = new List<String>();
		List<Schema.PicklistEntry> picklistEntry = mapAllObjects.get(objectName).getDescribe().fields.getMap().get(fldApiName).getDescribe().getPicklistValues();
		for(Schema.PicklistEntry pl : picklistEntry)
		{
			picklistValues.add(pl.getValue());
		}
		return picklistValues;
	}
	
	/*
		* MethodName        : getLkupObjStatic
		* param             : field api name and object name
		* Description       : This method is used to return the relationship name of the reference field which has been supplied as parameter.
	*/
	private String getLkupObjStatic(String fldApiName, String objectName)
	{
		return mapAllObjects.get(objectName).getDescribe().fields.getMap().get(fldApiName).getDescribe().getRelationshipName();
	}
}