/**
* \arg ClassName   : SL_UploadEquipment
* \arg JIRATicket  : FAEF-13
* \arg CreatedOn   : 7/25/2013
* \arg CreatedBy   : Wes
* \arg ModifiedBy  : Vivek, 12/08/2013 (Commit URL)
* \arg Description : Class is mainly getting the CSV file from system, getting converted to specific sObject rows (Equipment) and insrting them.
*                    Also, adding dynamically column in table from CSV file and validating them.
*/
public class SL_UploadEquipment{
    //update the following
    private String objectAPIName = 'Equipment__c';
    public List<Equipment__c> equipList {get;set;}

    //Should not need to update these vars.
    public Blob csv{get;set;}
    public Boolean isUploaded {get;set;}
    public list<String> lstColumnNames  {get;set;}
    private String parentId {get;set;}
    private String acctId {get;set;}
 	private List<List<String>> csvParsedData;
	private set<String> setFieldsName;
    public String objectNameUI {get;set;}
    public String parentObjectNameUI{get;set;}

    public SL_UploadEquipment()
    {
        init();
    }

     /**
	* Name			: Upload
	* Parameters	: None
	* Description 	: Cleaning CSV records, forming sObject rows, upload them.
	*/
    public Pagereference upload()
    {
        List<String> lstColumn = new List<String>();
        lstColumnNames  = new List<String>();

        if(csv != null)
        {
	        isUploaded  = true;
	        csvParsedData = SL_CSVUtils.parseCSV(csv.toString(),false);

	        if(csvParsedData.size() > 0)
	        {
		        lstColumn = csvParsedData[0];
                // Update these lines
		        equipList = (List<Equipment__c>) SL_CSVUtils.csvTosObject(csvParsedData,objectAPIName);
		        for(Equipment__c equip : equipList)
		        {
		            equip.Schedule__c = parentId;
                                    equip.Account__c = acctId;
		        }
	        }
        }
        else
        	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please choose a CSV file.'));

        // Preparing list of column which has to be shown in table.
        for( String str :lstColumn)
        {
        	if(str.trim().length() > 0 && setFieldsName != null && setFieldsName.contains(str.trim()))
        		lstColumnNames.add(str.trim());
        	else if(str.trim().length() > 0 && !setFieldsName.contains(str.trim()))
    		 	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Incorrect field Name : '+str.trim() + ' in CSV file'));
        }

        return null;

    }

     /**
	* Name			: back
	* Parameters	: None
	* Description 	: Displaying input file component.
	*/
    public Pagereference back(){
        isUploaded  = false;
        csv = null;
        csvParsedData.clear();
        equipList.clear();
        return null;
    }

     /**
	* Name			: save
	* Parameters	: Pagereference
	* Description 	: Inserting Equipment__c records.
	*/
    public Pagereference save()
     {
        if(equipList !=null && equipList.size() >0 )
        {
            try{
                insert equipList;
            }
            catch (Exception e){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error inserting records.'));
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
                return null;
            }
        }
        PageReference parentPage = new PageReference('/' + parentId);
        parentPage.setRedirect(true);
        return parentPage;
    }
    /**
	* Name			: backToParent
	* Parameters	: None
	* Description 	: Return to parent record..
	*/
    public Pagereference backToParent()
     {
        PageReference parentPage = new PageReference('/' + parentId);
        parentPage.setRedirect(true);
        return parentPage;
    }

    private void init()
    {
    	//update this strongly typed list.
        equipList = new List<Equipment__c>();
        objectNameUI = 'Equipment';
        parentObjectNameUI = 'Schedule';

        //Should nto need to udpate this logic
        csvParsedData = new List<List<String>>();
        parentId = ApexPages.CurrentPage().getParameters().get('parentId');
        acctId= ApexPages.CurrentPage().getParameters().get('acctId');
        lstColumnNames = new List<String>();
       	setFieldsName = new set<String>();
        Map<String, Schema.SObjectField> mapField_Target = Schema.getGlobalDescribe().get(objectAPIName).getDescribe().fields.getMap();
        for(Schema.SObjectField objTargetFields : mapField_Target.values())
		{
			setFieldsName.add(String.valueOf(objTargetFields.getDescribe().getName()));
		}
    }
}