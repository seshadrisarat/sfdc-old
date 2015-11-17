/**
* \arg ClassName      : SL_PropertyAndUnitResultsController
* \arg JIRATicket     : IRE-165
* \arg CreatedOn      : 26/AUG/2015
* \arg LastModifiedOn : 28/AUG/2015
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This class serves the purpose of displaying the sorted results based on the populated filters of main page.
*/
public with sharing class SL_PropertyAndUnitResultsController 
{
	public transient List<RecordWrapper> lstRecordWrapper {get;set;} // wrapper class list to hold the search results based on the picklist value selected.
	public transient Integer totalProperties {get;set;} //Variable to hold calculated total number of properties that fall under search results, each time when search button is clicked.
	public transient Integer totalUnits {get;set;} //Variable to hold calculated total number of units that fall under search results, each time when search button is clicked.
	
	private static String strUnitQuery = 'SELECT Id, Unit_Image__c, Name, DW_Local_Tenant__c, DW_Unit_Number__c,Budgeted_Net_Effective_Rent_NER__c, Budgeted_TI__c, Property__c, Property__r.Name, DW_Unit_Square_Feet__c, Budgeted_Rent__c,Comments__c, Vacancy_Date__c, Unit_Status__c, Property__r.Property_Image__c, Property__r.DW_Address__c, Property__r.DW_Business_Unit_Desc__c, Property__r.DW_Total_Physical_Occupancy__c, Property__r.DW_Total_Financial_Occupancy__c, Property__r.DW_Num_of_Units__c, Property__r.DW_Property_Status__c, Property__r.DW_Property_Type__c, Property__r.DW_City__c, Property__r.DW_State__c, Property__r.DW_Asset_Manager__c, Property__r.DW_Property_Manager__c,Property__r.DW_Asset_Manager__r.Name, Property__r.DW_Property_Manager__r.Name FROM Unit__c';
	private static String strPropertyQuery = 'SELECT Id, Name, Property_Image__c, DW_Address__c, DW_Business_Unit_Desc__c, DW_Total_Physical_Occupancy__c, DW_Total_Financial_Occupancy__c, DW_Num_of_Units__c, DW_Property_Status__c, DW_Property_Type__c, DW_City__c, DW_State__c, Comments__c, DW_Asset_Manager__c, DW_Property_Manager__c, DW_Asset_Manager__r.Name, DW_Property_Manager__r.Name FROM Property__c';
	
	public class RecordWrapper
	{
		public Property__c objProperty {get;set;}
		public Unit__c objUnit	{get;set;}
		public List<Unit__c> lstUnit {get;set;}
	}
	
	/*
		* MethodName        : fetchRecords
		* param             : -
		* Description       : This method is called when Search button is clicked to show the results based on the populated filters on the page.
	*/
	public void fetchRecords()
	{
		lstRecordWrapper = new List<RecordWrapper>();
		Map<String,String> mapPageParameters = ApexPages.currentPage().getParameters();
		String strSelectedValue = mapPageParameters.get('selectedVal');
		String strSearchTerm = mapPageParameters.get('searchparam');
		String strWhereForProperty = mapPageParameters.get('propertyWhereClause');
		String strWhereForUnit = mapPageParameters.get('unitWhereClause');
		String strSortOption = mapPageParameters.get('sortOption');
		List<String> lstSortOptionArray = strSortOption!='--' ? strSortOption.split('-') : null;
		totalProperties = totalUnits = 0;
		
		if(String.isNotEmpty(strSearchTerm))
		{
			strSearchTerm = String.escapeSingleQuotes(strSearchTerm);
			if(strSelectedValue == 'PropertyAndUnits')
			{					
				List<Property__c> lstFilteredProperty = new List<Property__c>();
				Set<Id> setFilteredPropertyIds = new Set<Id>();
				for(Property__c objProperty : Database.query(String.isNotEmpty(strWhereForProperty) ? strPropertyQuery+strWhereForProperty+ (lstSortOptionArray!=NULL ? ' ORDER BY ' + lstSortOptionArray[0] + ' ' + lstSortOptionArray[1] : '') : strPropertyQuery+(lstSortOptionArray!=NULL ? ' ORDER BY ' + lstSortOptionArray[0] + ' ' + lstSortOptionArray[1] : '')))
				{
					if((objProperty.Comments__c!=NULL && objProperty.Comments__c.containsIgnoreCase(strSearchTerm)) 
					  || (objProperty.Name.containsIgnoreCase(strSearchTerm)) 
					  || (objProperty.DW_City__c!=NULL && objProperty.DW_City__c.containsIgnoreCase(strSearchTerm)) 
					  || (objProperty.DW_State__c!=NULL && objProperty.DW_State__c.containsIgnoreCase(strSearchTerm))
					  || (objProperty.DW_Asset_Manager__c!=NULL && objProperty.DW_Asset_Manager__r.Name.containsIgnoreCase(strSearchTerm))
					  || (objProperty.DW_Property_Manager__c!=NULL && objProperty.DW_Property_Manager__r.Name.containsIgnoreCase(strSearchTerm)))
					{
						if(objProperty.Property_Image__c!=NULL)
							objProperty.Property_Image__c = formatRichText(objProperty.Property_Image__c);
						
						setFilteredPropertyIds.add(objProperty.Id);
						lstFilteredProperty.add(objProperty);
					}
				}
				
				Map<Id,List<Unit__c>> mapPropertyIdTolstOfUnit = new Map<Id, List<Unit__c>>();
				for(Unit__c objUnit : Database.query(String.isNotEmpty(strWhereForUnit) ? strUnitQuery+strWhereForUnit+' AND Property__c IN : setFilteredPropertyIds' : strUnitQuery + ' WHERE Property__c IN : setFilteredPropertyIds'))
				{
					if(objUnit.Comments__c!=NULL && objUnit.Comments__c.containsIgnoreCase(strSearchTerm)
					  || (objUnit.Name.containsIgnoreCase(strSearchTerm)) 
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
				
				for(Property__c objProperty : lstFilteredProperty)
				{					
					totalProperties++;
					RecordWrapper objRecordWrapper = new RecordWrapper();
					objRecordWrapper.objProperty = objProperty;
					objRecordWrapper.lstUnit = mapPropertyIdTolstOfUnit.containskey(objProperty.Id) ? mapPropertyIdTolstOfUnit.get(objProperty.Id) : new List<Unit__c>();
					totalUnits+=objRecordWrapper.lstUnit.size();
					lstRecordWrapper.add(objRecordWrapper);					
				}
			}
			else if(strSelectedValue == 'Properties')
			{
				for(Property__c objProperty : Database.query(String.isNotEmpty(strWhereForProperty) ? strPropertyQuery+strWhereForProperty+ (lstSortOptionArray!=NULL ? ' ORDER BY ' + lstSortOptionArray[0] + ' ' + lstSortOptionArray[1] : '') : strPropertyQuery+(lstSortOptionArray!=NULL ? ' ORDER BY ' + lstSortOptionArray[0] + ' ' + lstSortOptionArray[1] : '')))
				{
					if((objProperty.Comments__c!=NULL && objProperty.Comments__c.containsIgnoreCase(strSearchTerm)) 
						|| (objProperty.Name.containsIgnoreCase(strSearchTerm)) 
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
				for(Unit__c objUnit : Database.query(String.isNotEmpty(strWhereForUnit) ? strUnitQuery+strWhereForUnit+ (lstSortOptionArray!=NULL ? ' ORDER BY ' + lstSortOptionArray[0] + ' ' + lstSortOptionArray[1] : '') : strUnitQuery+(lstSortOptionArray!=NULL ? ' ORDER BY ' + lstSortOptionArray[0] + ' ' + lstSortOptionArray[1] : '')))
				{
					if(objUnit.Comments__c!=NULL && objUnit.Comments__c.containsIgnoreCase(strSearchTerm)
					  || (objUnit.Name.containsIgnoreCase(strSearchTerm)) 
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
					List<Property__c> lstFilteredProperty = new List<Property__c>();
					Set<Id> setFilteredPropertyIds = new Set<Id>();
					for(Property__c objProperty : Database.query(strPropertyQuery+strWhereForProperty+ (lstSortOptionArray!=NULL ? ' ORDER BY ' + lstSortOptionArray[0] + ' ' + lstSortOptionArray[1] : '')))
					{					
						if(objProperty.Property_Image__c!=NULL)
							objProperty.Property_Image__c = formatRichText(objProperty.Property_Image__c);
						
						setFilteredPropertyIds.add(objProperty.Id);
						lstFilteredProperty.add(objProperty);
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
					
					for(Property__c objProperty : lstFilteredProperty)
					{						
						totalProperties++;
						RecordWrapper objRecordWrapper = new RecordWrapper();
						objRecordWrapper.objProperty = objProperty;
						objRecordWrapper.lstUnit = mapPropertyIdTolstOfUnit.containskey(objProperty.Id) ? mapPropertyIdTolstOfUnit.get(objProperty.Id) : new List<Unit__c>();
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
					
					for(Property__c objProperty : Database.query(strPropertyQuery + ' WHERE Id IN : setPropertyIds'+ (lstSortOptionArray!=NULL ? ' ORDER BY ' + lstSortOptionArray[0] + ' ' + lstSortOptionArray[1] : '')))
					{
						if(objProperty.Property_Image__c!=NULL)
							objProperty.Property_Image__c = formatRichText(objProperty.Property_Image__c);
						
						totalProperties++;
						RecordWrapper objRecordWrapper = new RecordWrapper();
						objRecordWrapper.objProperty = objProperty;
						objRecordWrapper.lstUnit = mapPropertyIdTolstOfUnit.containskey(objProperty.Id) ? mapPropertyIdTolstOfUnit.get(objProperty.Id) : new List<Unit__c>();
						totalUnits+=objRecordWrapper.lstUnit.size();
						lstRecordWrapper.add(objRecordWrapper);
					}					
				}
			}
			else if(strSelectedValue == 'Properties' && String.isNotEmpty(strWhereForProperty))
			{
				for(Property__c objProperty : Database.query(strPropertyQuery+strWhereForProperty+ (lstSortOptionArray!=NULL ? ' ORDER BY ' + lstSortOptionArray[0] + ' ' + lstSortOptionArray[1] : '')))
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
				for(Unit__c objUnit : Database.query(strUnitQuery+strWhereForUnit+ (lstSortOptionArray!=NULL ? ' ORDER BY ' + lstSortOptionArray[0] + ' ' + lstSortOptionArray[1] : '')))
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
		* MethodName        : formatRichText
		* param             : Value of the rich text area field
		* Description       : This function is used to set the formatting of the field value in order to show image on contract review page.
	*/
	private String formatRichText(String strRichText)
	{
		return strRichText.subStringBetween(strRichText.contains('src') ? 'src="' : 'href="','"').replaceAll('&amp;','&');
	}	
}