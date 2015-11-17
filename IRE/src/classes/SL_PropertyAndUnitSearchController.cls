/**
* \arg ClassName      : SL_PropertyAndUnitSearchController
* \arg JIRATicket     : IRE-120
* \arg CreatedOn      : 4/AUG/2015
* \arg LastModifiedOn : 20/AUG/2015
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This class serves as controller for searching Property and Unit custom search based on some search filters.
*/
public with sharing class SL_PropertyAndUnitSearchController 
{
	/* Start - Page Variables */
	public String strSearchTerm	{get;set;} //Variable to hold value of entered search text from ui
	public String strSelectedValue {get;set;}// Variable to hold value of selected option from drop down on ui followed by search text box
	public List<queryFilterElements> lstFilterElements {get;set;}// list to hold the filter elements that are displayed on ui and displayed dynamically from field set.
	public transient Integer totalProperties {get;set;} //Variable to hold calculated total number of properties that fall under search results, each time when search button is clicked.
	public transient Integer totalUnits {get;set;} //Variable to hold calculated total number of units that fall under search results, each time when search button is clicked.
	public transient List<RecordWrapper> lstRecordWrapper {get;set;} // wrapper class list to hold the search results based on the picklist value selected.
	/* End - Page Variables */
	
	/* Start - Class Variables */
	private static Map<String, Schema.Sobjecttype> mapAllObjects = Schema.getGlobalDescribe();
	private static String strUnitQuery = 'SELECT Id, Unit_Image__c, DW_Local_Tenant__c, DW_Unit_Number__c,Budgeted_Net_Effective_Rent_NER__c, Budgeted_TI__c, Property__c, Property__r.Name, DW_Unit_Square_Feet__c, Budgeted_Rent__c,Comments__c, Vacancy_Date__c, Unit_Status__c, Property__r.Property_Image__c, Property__r.DW_Address__c, Property__r.DW_Business_Unit_Desc__c, Property__r.DW_Total_Physical_Occupancy__c, Property__r.DW_Total_Financial_Occupancy__c, Property__r.DW_Num_of_Units__c, Property__r.DW_Property_Status__c, Property__r.DW_Property_Type__c, Property__r.DW_City__c, Property__r.DW_State__c, Property__r.DW_Asset_Manager__c, Property__r.DW_Property_Manager__c,Property__r.DW_Asset_Manager__r.Name, Property__r.DW_Property_Manager__r.Name FROM Unit__c';
	private static String strPropertyQuery = 'SELECT Id, Name, Property_Image__c, DW_Address__c, DW_Business_Unit_Desc__c, DW_Total_Physical_Occupancy__c, DW_Total_Financial_Occupancy__c, DW_Num_of_Units__c, DW_Property_Status__c, DW_Property_Type__c, DW_City__c, DW_State__c, Comments__c, DW_Asset_Manager__c, DW_Property_Manager__c, DW_Asset_Manager__r.Name, DW_Property_Manager__r.Name FROM Property__c';
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
	
	public class RecordWrapper
	{
		public Property__c objProperty {get;set;}
		public Unit__c objUnit	{get;set;}
		public List<Unit__c> lstUnit {get;set;}
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
	public SL_PropertyAndUnitSearchController()
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
		* MethodName        : fetchRecords
		* param             : -
		* Description       : This method is called when Search button is clicked to show the results based on the populated filters on the page.
	*/
	public void fetchRecords()
	{
		lstRecordWrapper = new List<RecordWrapper>();
		String strWhereForProperty = ApexPages.currentPage().getParameters().get('propertyWhereClause');
		String strWhereForUnit = ApexPages.currentPage().getParameters().get('unitWhereClause');
		totalProperties = totalUnits = 0;

		if(String.isNotEmpty(strSearchTerm))
		{
			strSearchTerm = String.escapeSingleQuotes(strSearchTerm);
			if(strSelectedValue == 'PropertyAndUnits')
			{					
				Map<Id, Property__c> mapIdToProperty = new Map<Id,Property__c>((List<Property__c>)Database.query(String.isNotEmpty(strWhereForProperty) ? strPropertyQuery+strWhereForProperty : strPropertyQuery));
				Set<Id> setFilteredPropertyIds = new Set<Id>();
				for(Property__c objProperty : mapIdToProperty.values())
				{
					if((objProperty.Comments__c!=NULL && objProperty.Comments__c.containsIgnoreCase(strSearchTerm)) 
					  || (objProperty.DW_City__c!=NULL && objProperty.DW_City__c.containsIgnoreCase(strSearchTerm)) 
					  || (objProperty.DW_State__c!=NULL && objProperty.DW_State__c.containsIgnoreCase(strSearchTerm))
					  || (objProperty.DW_Asset_Manager__c!=NULL && objProperty.DW_Asset_Manager__r.Name.containsIgnoreCase(strSearchTerm))
					  || (objProperty.DW_Property_Manager__c!=NULL && objProperty.DW_Property_Manager__r.Name.containsIgnoreCase(strSearchTerm)))
					{
						if(objProperty.Property_Image__c!=NULL)
							objProperty.Property_Image__c = formatRichText(objProperty.Property_Image__c);
						
						setFilteredPropertyIds.add(objProperty.Id);
					}
				}
				
				Map<Id,List<Unit__c>> mapPropertyIdTolstOfUnit = new Map<Id, List<Unit__c>>();
				for(Unit__c objUnit : Database.query(String.isNotEmpty(strWhereForUnit) ? strUnitQuery+strWhereForUnit+' AND Property__c IN : setFilteredPropertyIds' : strUnitQuery + ' WHERE Property__c IN : setFilteredPropertyIds'))
				{
					if(objUnit.Comments__c!=NULL && objUnit.Comments__c.containsIgnoreCase(strSearchTerm)
					  || (objUnit.Property__r.DW_City__c!=NULL && objUnit.Property__r.DW_City__c.containsIgnoreCase(strSearchTerm)) 
					  || (objUnit.Property__r.DW_State__c!=NULL && objUnit.Property__r.DW_State__c.containsIgnoreCase(strSearchTerm))
					  || (objUnit.Property__r.DW_Asset_Manager__c!=NULL && objUnit.Property__r.DW_Asset_Manager__r.Name.containsIgnoreCase(strSearchTerm))
					  || (objUnit.Property__r.DW_Property_Manager__c!=NULL && objUnit.Property__r.DW_Property_Manager__r.Name.containsIgnoreCase(strSearchTerm)))
					{
						if(objUnit.Unit_Image__c!=NULL)
							objUnit.Unit_Image__c = formatRichText(objUnit.Unit_Image__c);
							
						if(!mapPropertyIdTolstOfUnit.containskey(objUnit.Property__c))
							mapPropertyIdTolstOfUnit.put(objUnit.Property__c, new List<Unit__c>{objUnit});
						else
							mapPropertyIdTolstOfUnit.get(objUnit.Property__c).add(objUnit);
					}						
				}
				
				for(Id propertyId : mapPropertyIdTolstOfUnit.keyset())
				{
					totalProperties++;
					RecordWrapper objRecordWrapper = new RecordWrapper();
					objRecordWrapper.objProperty = mapIdToProperty.get(propertyId);
					objRecordWrapper.lstUnit = mapPropertyIdTolstOfUnit.get(propertyId);
					totalUnits+=objRecordWrapper.lstUnit.size();
					lstRecordWrapper.add(objRecordWrapper);
				}
			}
			else if(strSelectedValue == 'Properties')
			{
				for(Property__c objProperty : Database.query(String.isNotEmpty(strWhereForProperty) ? strPropertyQuery+strWhereForProperty : strPropertyQuery))
				{
					if((objProperty.Comments__c!=NULL && objProperty.Comments__c.containsIgnoreCase(strSearchTerm)) 
						|| (objProperty.DW_City__c!=NULL && objProperty.DW_City__c.containsIgnoreCase(strSearchTerm)) 
						|| (objProperty.DW_State__c!=NULL && objProperty.DW_State__c.containsIgnoreCase(strSearchTerm))
						|| (objProperty.DW_Asset_Manager__c!=NULL && objProperty.DW_Asset_Manager__r.Name.containsIgnoreCase(strSearchTerm))
					    || (objProperty.DW_Property_Manager__c!=NULL && objProperty.DW_Property_Manager__r.Name.containsIgnoreCase(strSearchTerm)))
					{
						if(objProperty.Property_Image__c!=NULL)
							objProperty.Property_Image__c = formatRichText(objProperty.Property_Image__c);
						
						RecordWrapper objRecordWrapper = new RecordWrapper();
						objRecordWrapper.objProperty = objProperty;
						totalProperties++;
						lstRecordWrapper.add(objRecordWrapper);
					}
				}
			}
			else if(strSelectedValue == 'Units')
			{
				for(Unit__c objUnit : Database.query(String.isNotEmpty(strWhereForUnit) ? strUnitQuery+strWhereForUnit : strUnitQuery))
				{
					if(objUnit.Comments__c!=NULL && objUnit.Comments__c.containsIgnoreCase(strSearchTerm)
					  || (objUnit.Property__r.DW_City__c!=NULL && objUnit.Property__r.DW_City__c.containsIgnoreCase(strSearchTerm)) 
					  || (objUnit.Property__r.DW_State__c!=NULL && objUnit.Property__r.DW_State__c.containsIgnoreCase(strSearchTerm))
					  || (objUnit.Property__r.DW_Asset_Manager__c!=NULL && objUnit.Property__r.DW_Asset_Manager__r.Name.containsIgnoreCase(strSearchTerm))
					  || (objUnit.Property__r.DW_Property_Manager__c!=NULL && objUnit.Property__r.DW_Property_Manager__r.Name.containsIgnoreCase(strSearchTerm)))
					  
					  {
						if(objUnit.Unit_Image__c!=NULL)
							objUnit.Unit_Image__c = formatRichText(objUnit.Unit_Image__c);
						
						RecordWrapper objRecordWrapper = new RecordWrapper();
						objRecordWrapper.objUnit = objUnit;
						totalUnits++;
						lstRecordWrapper.add(objRecordWrapper);
					  }
				}
			}
		}
		else
		{
			if(strSelectedValue == 'PropertyAndUnits')
			{					
				if(String.isNotEmpty(strWhereForProperty))
				{
					Map<Id, Property__c> mapIdToProperty = new Map<Id,Property__c>((List<Property__c>)Database.query(strPropertyQuery+strWhereForProperty));
					Set<Id> setFilteredPropertyIds = new Set<Id>();
					for(Property__c objProperty : mapIdToProperty.values())
					{					
						if(objProperty.Property_Image__c!=NULL)
							objProperty.Property_Image__c = formatRichText(objProperty.Property_Image__c);
						
						setFilteredPropertyIds.add(objProperty.Id);
					}
					
					Map<Id,List<Unit__c>> mapPropertyIdTolstOfUnit = new Map<Id, List<Unit__c>>();
					for(Unit__c objUnit : Database.query(String.isNotEmpty(strWhereForUnit) ? strUnitQuery+strWhereForUnit+' AND Property__c IN : setFilteredPropertyIds' : strUnitQuery + ' WHERE Property__c IN : setFilteredPropertyIds'))
					{
						if(objUnit.Unit_Image__c!=NULL)
							objUnit.Unit_Image__c = formatRichText(objUnit.Unit_Image__c);
							
						if(!mapPropertyIdTolstOfUnit.containskey(objUnit.Property__c))
							mapPropertyIdTolstOfUnit.put(objUnit.Property__c, new List<Unit__c>{objUnit});
						else
							mapPropertyIdTolstOfUnit.get(objUnit.Property__c).add(objUnit);
							
					}
					
					for(Id propertyId : mapPropertyIdTolstOfUnit.keyset())
					{
						totalProperties++;
						RecordWrapper objRecordWrapper = new RecordWrapper();
						objRecordWrapper.objProperty = mapIdToProperty.get(propertyId);
						objRecordWrapper.lstUnit = mapPropertyIdTolstOfUnit.get(propertyId);
						totalUnits+=objRecordWrapper.lstUnit.size();
						lstRecordWrapper.add(objRecordWrapper);
					}
				}
				else if(String.isNotEmpty(strWhereForUnit))
				{
					Map<Id,List<Unit__c>> mapPropertyIdTolstOfUnit = new Map<Id, List<Unit__c>>();
					for(Unit__c objUnit : Database.query(strUnitQuery+strWhereForUnit))
					{
						if(objUnit.Unit_Image__c!=NULL)
							objUnit.Unit_Image__c = formatRichText(objUnit.Unit_Image__c);
							
						if(!mapPropertyIdTolstOfUnit.containskey(objUnit.Property__c))
							mapPropertyIdTolstOfUnit.put(objUnit.Property__c, new List<Unit__c>{objUnit});
						else
							mapPropertyIdTolstOfUnit.get(objUnit.Property__c).add(objUnit);
					}
					
					Set<Id> setPropertyIds = new Set<Id>(mapPropertyIdTolstOfUnit.keyset());
					Map<Id, Property__c> mapIdToProperty = new Map<Id, Property__c>();
					
					for(Property__c objProperty : Database.query(strPropertyQuery + ' WHERE Id IN : setPropertyIds'))
					{
						if(objProperty.Property_Image__c!=NULL)
							objProperty.Property_Image__c = formatRichText(objProperty.Property_Image__c);
						mapIdToProperty.put(objProperty.Id, objProperty);
					}					
					
					for(Id propertyId : mapPropertyIdTolstOfUnit.keyset())
					{
						totalProperties++;
						RecordWrapper objRecordWrapper = new RecordWrapper();
						objRecordWrapper.objProperty = mapIdToProperty.get(propertyId);
						objRecordWrapper.lstUnit = mapPropertyIdTolstOfUnit.get(propertyId);
						totalUnits+=objRecordWrapper.lstUnit.size();
						lstRecordWrapper.add(objRecordWrapper);
					}
				}
			}
			else if(strSelectedValue == 'Properties' && String.isNotEmpty(strWhereForProperty))
			{
				for(Property__c objProperty : Database.query(strPropertyQuery+strWhereForProperty))
				{					
					if(objProperty.Property_Image__c!=NULL)
						objProperty.Property_Image__c = formatRichText(objProperty.Property_Image__c);
					
					RecordWrapper objRecordWrapper = new RecordWrapper();
					objRecordWrapper.objProperty = objProperty;
					totalProperties++;
					lstRecordWrapper.add(objRecordWrapper);					
				}
			}
			else if(strSelectedValue == 'Units' && String.isNotEmpty(strWhereForUnit))
			{
				for(Unit__c objUnit : Database.query(strUnitQuery+strWhereForUnit))
				{					
					if(objUnit.Unit_Image__c!=NULL)
						objUnit.Unit_Image__c = formatRichText(objUnit.Unit_Image__c);
					
					RecordWrapper objRecordWrapper = new RecordWrapper();
					objRecordWrapper.objUnit = objUnit;
					totalUnits++;
					lstRecordWrapper.add(objRecordWrapper);					
				}
			}
		}
	}
	
	/*
		* MethodName        : initialize
		* param             : -
		* Description       : This method is called to initialize both class and page variables and to call the methods related to field set for displaying fields on the visualforce page.
	*/
	private void initialize()
	{
		lstFilterElements = new List<queryFilterElements>();
		lstRecordWrapper = new List<RecordWrapper>();
		readFieldSet('Unit__c','searchFilters');
		readFieldSet('Property__c','searchFilters');
		totalProperties = totalUnits = 0;
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
	
	/*
		* MethodName        : formatRichText
		* param             : Value of the rich text area field
		* Description       : This function is used to set the formatting of the field value in order to show image on contract review page.
	*/
	private String formatRichText(String strRichText)
	{
		return strRichText.subStringBetween(strRichText.contains('src') ? 'src="' : 'href="','"').replaceAll('&amp;','&');
	}	
}