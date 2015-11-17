/**  
* \arg ClassName      : SL_DataTables_Remote
* \arg JIRATicket     : STARGAS-10
* \arg CreatedOn      : 16/JUL/2014
* \arg LastModifiedOn : 17/JUNE/2014
* \arg CreatededBy    : SRUTI
* \arg ModifiedBy     : SRUTI
* \arg Description    : This is controller is used for fetching and displaying all the Price Table records into page
*/
global with sharing class SL_DataTables_Remote 
{
	public ID curRecordID {get; set;}
	public SL_DataTables_Remote() {}
	private static Boolean hasEditAccess; 
	
	public SL_DataTables_Remote(ApexPages.StandardController controller)
	{
		try
		{
			sObject inRecord = (sObject)controller.getRecord();
			curRecordID = inRecord.ID;
		}
		catch (Exception e) {}  
	}
 
	//@RemoteAction TO Read the field set
	private static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName)
	{
		Schema.FieldSet fieldSetObj = Schema.getGlobalDescribe().get(ObjectName).getDescribe().FieldSets.getMap().get(fieldSetName);
		return fieldSetObj.getFields(); 
	}  
    
	///Binding Field's property into wrapper class
	@RemoteAction
	global static List<DTFields> getFieldSetFields(String fieldSetName, String objectName) 
	{
		List<DTFields> fields = new List<DTFields>();
		hasEditAccess =Schema.sObjectType.Price_Table__c.isUpdateable();
		for(Schema.FieldSetMember fieldSetMemberObj : readFieldSet(fieldSetName,objectName))
		{
			DTFields dt = new DTFields();
			dt.APIName = fieldSetMemberObj.getFieldPath();
			dt.Label = fieldSetMemberObj.getFieldPath() == 'Propane_Gallons__c' ? 'Gallons' : fieldSetMemberObj.getFieldPath() == 'Tank_Type_Text__c' ? 'Type' : fieldSetMemberObj.getLabel();
			dt.Required = fieldSetMemberObj.getRequired();
			dt.DBRequired = fieldSetMemberObj.getDbRequired();
			dt.Type = fieldSetMemberObj.getType().name();
			dt.hasAccess = hasEditAccess;
		                                
			fields.add(dt);
		}
		return fields;
	}
	//Wrapper class to bind Data table field properties
    global class DTFields
    {
        String APIName;
        String Label;
        Boolean Required;
        Boolean DBRequired;
        String Type;
        Boolean hasAccess;
    }
}