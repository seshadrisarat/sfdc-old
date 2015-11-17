/**
* \arg ClassName      : SL_InvestorContactAndFundVFController
* \arg JIRATicket     : OAKHILL-9, OAKHILL-34
* \arg CreatedOn      : 06/OCT/2014
* \arg LastModifiedOn : 9/OCT/2015
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This class serves as controller for SL_InvestorContactAndFundInlineVF component to show the list of investor contacts and fund of interest records related to contact id
*/
public without sharing class SL_InvestorContactAndFundVFController 
{
    /* Start - Variables */
    public List<String> lstHeaders                      {set;get;}//list to hold names of the headers
    public List<String> lstFieldAPINames                {set;get;}//list to hold the api names of the fields that needs to be displayed on page
    public List<RecordWrapper> lstRecordWrapper         {set;get;}//list to hold wrapper class objects to show on the page.
    public String strObjectId                           {get;set;}//Id of the element that needs to be deleted
    public Boolean isRender                             {get;set;}//flag variable to hold the status of rendering
    public Boolean isEditable                           {get;set;}//flag variable to hold the status of checkboxes
    public String ContactId                             {get;set;}//variable to hold contact id
    public String FundFamilyIdString                    {get;set;}//variable to hold fund families for MN inline modal
    public String LaunchContext                         {get;set;}//variable to signal launching context to set special behavior
    /* End - Variables */
    
    /*Start - Class Variables */
    private static final String ACTIVE_STATUS   = 'Active';//this variable is used to show the active status for fund of interest object record
    private String strContactName;
    private List<Fund_of_Interest__c> joinersFromUrlParam;
    /*End - Class Variables */
    
    /* Start - Constructor */
    public SL_InvestorContactAndFundVFController()
    {
        //Do  Nothing

    }
    /* End - Constructor */
    
    /** 
        * @Name         : doMeetingNotesInitialization
        * @parameter    : 
        * @Description  : This method is used to do special initialization when called from meetingNotesContext
    */ 

    private void doMeetingNotesInitialization() {
        //if we have fund ids, parse them
        //
        if (FundFamilyIdString.length() > 0) {
            joinersFromUrlParam = fundsOfInterestFromIdList(FundFamilyIdString);
            System.debug('Joiners: ' + joinersFromUrlParam);
        }
    }

    private List<Fund_of_Interest__c> fundsOfInterestFromIdList(String idString){
        List<Fund_of_Interest__c> fundJoinersFromMn = new List<Fund_of_Interest__c>();
        List<Fund_Family__c> fundFamilies = new List<Fund_Family__c>();
        List<String> parsedIds = new List<String>();
        parsedIds = idString.split(',', 0);
        System.debug('@@@ Parsed Ids: ' + parsedIds);
        //get funds
        if(parsedIds.size() > 0) {
            fundFamilies = [SELECT id, name FROM Fund_Family__c WHERE id IN :parsedIds];
        }
        //create joiners
        if (fundFamilies.size() > 0 ) {
            for(Fund_Family__c  f : fundFamilies){
                Fund_of_Interest__c fundOfInterest = new Fund_of_Interest__c();
                fundOfInterest.Fund_Family__c = f.id;
                fundOfInterest.Contact__c = ContactId;
                fundJoinersFromMn.add(fundOfInterest);
            }
        }

        return fundJoinersFromMn;
    }

     /** 
        * @ClassName      : RecordWrapper
        * @parameter      : NA
        * @Description    : This class is used to contain the sobject records and their type to show on the inline vf page
    */ 
    public class RecordWrapper
    {
        public Sobject objSobject               {set;get;}// variable to hold sobject record
        public String strType                   {set;get;}// variable to hold the type of sobject
        public String strObjectName             {set;get;}// variable to hold the name of the sobject
        public RecordWrapper(Sobject objSobject, String strType, String strObjectName)
        {
            this.objSobject = objSobject;
            this.strType = strType;
            this.strObjectName = strObjectName;
        }
    }
     
     /** 
        * @Name         : getRecords
        * @parameter    : Field set name, sobject name
        * @Description  : This method is used to frame soql and retrieve the records from corresponding sobject and fill the wrapper class objects accordingly.
    */ 
    private List<RecordWrapper> getRecords(String strFieldSetName, String strSobjectName, String strType)
    {
        List<RecordWrapper> lstRecords = new List<RecordWrapper>();
        Schema.FieldSet objFieldSet = Schema.getGlobalDescribe().get(strSobjectName).getDescribe().FieldSets.getMap().get(strFieldSetName);
        String strQuery = 'SELECT Id,';
        try
        {
            //Iterating over field set member object to fill the header list and field api list
            for(Schema.FieldSetMember objFieldSetMember : objFieldSet.getFields())
            {
                if(strType == 'Investor Contact' && objFieldSetMember.getFieldPath()!='Investment__c')
                {
                    lstHeaders.add(objFieldSetMember.getLabel());
                    lstFieldAPINames.add(objFieldSetMember.getFieldPath());
                }
                strQuery+=objFieldSetMember.getFieldPath() +',';
            }
            strQuery = strQuery.substring(0,strQuery.length()-1);
            strQuery+=' FROM '+strSobjectName;
            strQuery+= strSobjectName == 'Investor_Contact__c' ? ' WHERE Contact__c =: ContactId' : ' WHERE Contact__c =: ContactId AND Status__c=:ACTIVE_STATUS';
            
            //Iterating over records to fill the wrapper class list to bind with the page
            for(Sobject objSobject : Database.query(strQuery))
            {
                lstRecords.add(new RecordWrapper(objSobject, strType, strSobjectName));
            }
        }
        catch(Exception ex)
        {
            System.debug('================'+ex.getMessage()+'======================'+ex.getLineNumber());
        }

        //if we're dealing with funds of interest, add in the ones from the list
        IF(FundFamilyIdString != null && LaunchContext != null) {
            if(strSobjectName.equals('Fund_of_Interest__c') && LaunchContext.equals('mn') && FundFamilyIdString.length() > 0){
                List<Fund_of_Interest__c>fundsToAdd = new List<Fund_of_Interest__c>();

                //find the ones that are not already existing
                for(Fund_of_Interest__c foiFromurl : joinersFromUrlParam) {
                    Boolean alreadyInList = false;
                    for(RecordWrapper rw : lstRecords){
                        if(rw.objSobject.get('Fund_Family__c') == foiFromurl.get('Fund_Family__c')) {
                            alreadyInList = true;
                        }
                    }
                    if(!alreadyInList) {
                        fundsToAdd.add(foiFromurl);
                    }
                }
                if(fundsToAdd.size()>0){
                    for(Fund_of_Interest__c f : fundsToAdd){
                        RecordWrapper newFromUrlParam = new RecordWrapper(f, 'Fund Of Interest', 'Fund_of_Interest__c');
                        lstRecords.add(newFromUrlParam);
                    }
                }
            }
        }


        return lstRecords;
    }
    
    /** 
        * @Name         : saveRecords
        * @parameter    : -
        * @Description  : This method is used to save the records updated on the page side
    */ 
    public void saveRecords()
    {
        List<Sobject> lstSobject = new List<Sobject>();//list to hold the objects that needs to be updated
        List<Sobject> lstInserts = new List<Sobject>();

        try
        {
            //Iterating over record wrapper list to collect the objects into a list to update them.
            for(RecordWrapper objRecordWrapper : lstRecordWrapper)
            {
                if(objRecordWrapper.objSobject.id != null){
                    lstSobject.add(objRecordWrapper.objSobject);
                } else {
                    lstInserts.add(objRecordWrapper.objSobject);
                }
            }
            update lstSobject;
            insert lstInserts;
            isEditable = false;
        }
        catch(Exception ex)
        {
            System.debug('================='+ex.getMessage());
        }
    }
    
    /** 
        * @Name         : editRecords
        * @parameter    : -
        * @Description  : This method is used to enable the checkboxes on click of edit button
    */ 
    public void editRecords()
    {
        isEditable = true;
    }
    
     /** 
        * @Name         : redirectFundOfInterest
        * @parameter    : -
        * @Description  : This method is used to redirect the standard New Fund of Interest page.
    */ 
    public Pagereference redirectFundOfInterest()
    {
        final String customFieldId = Custom_Field_Ids__c.getInstance('Fund_of_Interest__c').FieldId__c;
        return new Pagereference('/'+Fund_of_Interest__c.sObjectType.getDescribe().getKeyPrefix()+'/e?CF'+customFieldId+'='+strContactName+'&CF'+customFieldId+'_lkid='+ContactId+'&saveURL='+ContactId+'&retURL='+ContactId);
    }
    
    /** 
        * @Name         : redirectInvestorContact
        * @parameter    : -
        * @Description  : This method is used to redirect the standard New Investor Contact page.
    */ 
    public Pagereference redirectInvestorContact()
    {
        final String customFieldId = Custom_Field_Ids__c.getInstance('Investor_Contact__c').FieldId__c;
        return new Pagereference('/'+Investor_Contact__c.sObjectType.getDescribe().getKeyPrefix()+'/e?CF'+customFieldId+'='+strContactName+'&CF'+customFieldId+'_lkid='+ContactId+'&saveURL='+ContactId+'&retURL='+ContactId);
    }
    
     /** 
        * @Name         : deleteRecords
        * @parameter    : -
        * @Description  : This method is used to delete a particular record based on its Id.
    */ 
    public void deleteRecords()
    {
        //creating new object record
        sobject objSobject = Schema.getGlobalDescribe().get(String.valueOf(Id.valueOf(strObjectId).getSobjectType())).newSObject();
        objSobject.put('Id', strObjectId);
        delete objSobject;//deleting the sobject
        initializeElements();//initializing the elements
    }
    
     /** 
        * @Name         : initializeElements
        * @parameter    : -
        * @Description  : This method is used to initialize the elements.
    */ 
    public void initializeElements()
    { 

        //do meeting notes stuff if needful
        if (LaunchContext != null){
            if(LaunchContext.equals('mn')) {
                System.debug('Called From MN');
                doMeetingNotesInitialization();
            }
        }

        isRender = true;
        lstHeaders = new List<String>{'Name'};
        lstFieldAPINames = new List<String>();
        lstRecordWrapper = new List<RecordWrapper>();
        lstRecordWrapper = getRecords('SL_InvestorContactFieldSet', 'Investor_Contact__c', 'Investor Contact');//calling function for investor contact object
        lstRecordWrapper.addAll(getRecords('SL_FundOfInterestFieldSet', 'Fund_of_Interest__c', 'Marketing Contact'));//calling function for fund of interest object
        strContactName = [SELECT Name FROM Contact WHERE Id=:ContactId].Name;
        if(lstRecordWrapper.isEmpty())
            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO,'No Records to display.'));
    }
}