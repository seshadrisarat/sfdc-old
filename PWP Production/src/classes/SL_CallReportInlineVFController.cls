/**
* @ClassName          : SL_CallReportInlineVFController
* @JIRATicket         : PWP-1,PWP-2,PWP-18
* @CreatedOn          : 02/Dec/14
* @LastModifiedOn     : 3/JUNE/15
* @CreatedBy          : Nrusingh
* @ModifiedBy         : Pankaj Ganwani
* @Description        : This class is the controller for SL_CallReportInlineVF. 
                        The class displays current Call Report Attendees and Call Report Companies for Call Report.
*/

public without sharing class SL_CallReportInlineVFController  
{
    /* Start - Page Variables */
    public list<WrapperAttendee> lstWrapperAttendee {get;set;} // The list of wrapper class for Call Report Attendees
    public list<WrapperCompany> lstWrapperCompany   {get;set;} // The list of wrapper class for Call Report Companies
    public String strAttendeeId                     {get;set;} // The variable will store the Call Report Attendee Id which will come from the VF page
    public String strCompanyId                      {get;set;} // This variable is used to store company id
    public String strObjectName                     {get;set;} // This variable is used to store the object name that will be used to identify the section from where save button has been clicked
    public Boolean isActivityClicked                {get;set;} // This variable is used to show whether this vf page is launched from detail page of call report or from activity link
    public Call_Report__c objCallReport             {get;set;}// The variable will store the Call Report Id
    /* End - Page Variables */
    
    /* Start - Class Variables */
    private Id objectId;//This variable is used to hold the object id from where the link has been clicked either from Account or Contact
    private Id activityId;//This variable is used to hold the id of current activity record from where the link has been clicked
    private Map<String,String> mapPageParameters;//This map is used to hold the parameters of current page
    private Set<Id> setContactId;//This set is used to hold the contact ids in order to prevent creation of duplicate call report attendee records
    private Set<Id> setAccountId;// This set is used to hold the account ids in order to prevent creation of duplicate call report company records
    /* End - Class Variables */
    
    /*
       @ClassName: WrapperAttendee
       @Description: Wrapper class for the Call Report Attendees
    */
    public class WrapperAttendee
    {
        public Call_Report_Attendees__c objAttendee {get;set;}// The variable is used to bind the Call_Report_Attendees record
        public Call_Report__c objCR                 {get;set;}// The Case instance is temporarily used to bind the Case.ContactId standard Lookup field in VF page
        public Boolean isEditRecord                 {get;set;}// The boolean variable is used for edit purpose 
        public Boolean isCancelRecord               {get;set;}// The boolean variable is used for cancel purpose
        public Boolean isSelected                   {get;set;}// This variable is used to show the status of the record i.e. selected or unselected
        public String strErrormessage               {get;set;}
        /* Start - Constructor */
        public WrapperAttendee(Call_Report_Attendees__c objAttendee,Boolean isEditRecord,Boolean isCancelRecord)
        {
            this.objAttendee = objAttendee;
            this.isEditRecord = isEditRecord;
            this.isCancelRecord = isCancelRecord;
            this.isSelected = false;
            objCR = new Call_Report__c();
        }
        /* End - Constructor */
    }
    
    /*
       @ClassName: WrapperCompany
       @Description: Wrapper class for the Call Report Company
    */
    public class WrapperCompany
    {
        public Call_Report_Company__c objCompany    {get;set;}// The variable is used to bind the Call_Report_Company record
        public Call_Report__c objCR                 {get;set;}// The Opporunity instance is temporarily used to bind the Opportunity.AccountId standard Lookup field in VF page
        public Boolean isEditRecord                 {get;set;}// The boolean variable is used for edit purpose 
        public Boolean isCancelRecord               {get;set;}// The boolean variable is used for cancel purpose
        public Boolean isSelected                   {get;set;}// This variable is used to show the status of the record i.e. selected or unselected
        public String strErrormessage               {get;set;}
        
        /* Start - Constructor */
        public WrapperCompany(Call_Report_Company__c objCompany,Boolean isEditRecord,Boolean isCancelRecord)
        {
            this.objCompany = objCompany;
            this.isEditRecord = isEditRecord;
            this.isCancelRecord = isCancelRecord;
            this.isSelected = false;
            objCR = new Call_Report__c ();
        }
        /* End - Constructor */
    }
   
    /* Start - Main Class Constructor */
    public SL_CallReportInlineVFController(ApexPages.standardController stdController)  
    {
        //getting current call report record
        objCallReport = (Call_Report__c)stdController.getRecord();
        //calling method to initialize the page and class variables
        initialize();
        //checking if page is launched from link present on activity related list
        if(!isActivityClicked)
        {
            fetchAttendeeRecords();
            fetchCompanyRecords();
        }
    }
    /* End - Main Class Constructor */
    
     /*
        @MethodName: initialize
        @param None
        @Description: Initialize the global variables.
    */
    private void initialize()
    {
        strCompanyId = strObjectName = strAttendeeId = '';
        isActivityClicked = false;
        mapPageParameters = ApexPages.currentPage().getParameters();
        //checking if page if launched from activity related list and it contains object id and activity id
        try
        {
            if(mapPageParameters.containskey('objId') && mapPageParameters.containskey('ActId'))
            {
                //setting this variable to true to use on page side for rendering call report page block
                isActivityClicked = true;
                //assigning value of object id to variable
                objectId = mapPageParameters.get('objId');       
                //assigning value of activity id to variable
                activityId = mapPageParameters.get('ActId');
            }
        }
        catch(Exception ex)
        {
            System.debug('=================='+ex.getMessage()+'=============='+ex.getLineNumber());
        }
        lstWrapperAttendee = new list<WrapperAttendee>();
        lstWrapperCompany = new list<WrapperCompany>();
        setContactId = new Set<Id>();
        setAccountId = new Set<Id>();
        
    }   
    
     /*
        This method comes under the functionality of PWP-2
        @MethodName: createCallReport
        @param None
        @Description: This function is used to create call report when this page is launched on click of new call report button on activity related list.
    */
    public Pagereference createCallReport()
    {
        try
        {
            //checking if activity id is not empty in order to check whether the page is launched from activity history related list or as inline vf page
            if(String.isNotEmpty(activityId))
            {           
                Id trueActivityId = [SELECT Original_Activity_ID__c FROM Shadow_Activity__c WHERE Id =: activityId LIMIT 1].Original_Activity_ID__c;
                Boolean isTask = String.valueOf(trueActivityId).startsWith('00T') ? true : false;
                String strQuery = isTask ?
                                  'SELECT Subject, Subject__c, OwnerId, Call_Report_Id__c, ActivityDate,(SELECT TaskId, RelationId FROM TaskRelations) FROM Task WHERE Id=:trueActivityId':
                                  'SELECT Subject, Subject__c, OwnerId, Call_Report_Id__c, ActivityDate,(SELECT EventId, RelationId FROM EventRelations) FROM Event WHERE Id=:trueActivityId';
                
                //querying the subject and activitydate field in order to perform mapping with call report record that supposed to be created
                List<Sobject> lstSobject = Database.query(strQuery);
                List<Call_Report_Attendees__c> lstCallReportAtt = new List<Call_Report_Attendees__c>();
                
                //checking if list is not empty
                if(!lstSobject.isEmpty())
                {
                    Sobject objSobject = lstSobject[0];
                    //if(objSobject.get('Call_Report_Id__c')!=NULL)
                    	//return new Pagereference('/'+String.valueOf(objSobject.get('Call_Report_Id__c')));
                    
                    /*Added by Lodhi PWP-43 - added Do_Not_Fire_Trigger__c flag to Avoiding firing of trigger while creating call report from create call report link and from email service handler.*/
                    objCallReport = new Call_Report__c(Do_Not_Fire_Trigger__c = true, Call_Report_Date__c = Date.valueOf(objSobject.get('ActivityDate')));
                    
                    //checking if object id is not null
                    if(String.isNotEmpty(objectId))
                    {
                        //checking if object id belongs to contact
                        if(objectId.getSobjectType() == Contact.sobjectType)
                        {
                            Contact objContact = [SELECT AccountId FROM Contact WHERE Id =:objectId];
                            //checking if Contact account id is not null
                            if(objContact.AccountId != null)
                            {
                                objCallReport.Reference_Account__c = objContact.AccountId;
                                if(objSobject.get('OwnerId')==UserInfo.getUserId() || [SELECT Id, PWP_Employee__c From Coverage_Team_Members__c WHERE Company__c=:objContact.AccountId AND PWP_Employee__c=:userinfo.getuserid()].size()>0)
                                {
                                    if(objSobject.get('Call_Report_Id__c')==NULL)
                                    	objCallReport.Name = String.valueOf(objSobject.get('Subject')).length()<80 ? String.valueOf(objSobject.get('Subject')) : String.valueOf(objSobject.get('Subject')).substring(0, 80);
                                    else
                                    	return new Pagereference('/'+String.valueOf(objSobject.get('Call_Report_Id__c')));
                                }  
                                else if(objSobject.get('Call_Report_Id__c')!=NULL)
                                {
                                    String callReportId = String.valueOf(objSobject.get('Call_Report_Id__c'));
                                    return [SELECT COUNT() FROM Call_Report__c WHERE Id=:callReportId AND OwnerId =:UserInfo.getUserId()] > 0 ? new Pagereference('/'+callReportId) : new Pagereference('/apex/SL_Activity_NoAccess?id='+objectId);
                                    //objCallReport.Name = String.valueOf(objSobject.get('Subject__c')).length()<80 ? String.valueOf(objSobject.get('Subject__c')) : String.valueOf(objSobject.get('Subject__c')).substring(0, 80); 
                                }
                                /*Start - Written By - Pankaj Ganwani on 5/21/2015 */
                                else
                                {
                                	objCallReport.Name = 'Subject Masked';
                                } 
                                /*End - Written By - Pankaj Ganwani on 5/21/2015 */        
                            }
                            else
                                objCallReport.Name = String.valueOf(objSobject.get('Subject')).length()<80 ? String.valueOf(objSobject.get('Subject')) : String.valueOf(objSobject.get('Subject')).substring(0, 80);
                        }
                        //checking if object id belongs to Account
                        else if(objectId.getSobjectType() == Account.sobjectType)
                        {
                            Account objAccount = [Select Id, (Select PWP_Employee__c From Coverage_Team_Members__r where PWP_Employee__c=:userinfo.getuserid()) From Account WHERE Id =:objectId];
                            objCallReport.Reference_Account__c = objAccount.Id;
                            
                            if(objSobject.get('OwnerId')==UserInfo.getUserId() || objAccount.Coverage_Team_Members__r.size()>0)
                            {
                                if(objSobject.get('Call_Report_Id__c') == NULL)
                                	objCallReport.Name = String.valueOf(objSobject.get('Subject')).length()<80 ? String.valueOf(objSobject.get('Subject')) : String.valueOf(objSobject.get('Subject')).substring(0, 80);
                                else
                                	return new Pagereference('/'+String.valueOf(objSobject.get('Call_Report_Id__c')));
                            }
                            else if(objSobject.get('Call_Report_Id__c')!=NULL)
                            {
                                String callReportId = String.valueOf(objSobject.get('Call_Report_Id__c'));
                                return [SELECT COUNT() FROM Call_Report__c WHERE Id=:callReportId AND OwnerId =:UserInfo.getUserId()] > 0 ? new Pagereference('/'+callReportId) : new Pagereference('/apex/SL_Activity_NoAccess?id='+objectId);
                                //objCallReport.Name = String.valueOf(objSobject.get('Subject__c')).length()<80 ? String.valueOf(objSobject.get('Subject__c')) : String.valueOf(objSobject.get('Subject__c')).substring(0, 80);
                            }
                            /*Start - Written By - Pankaj Ganwani on 5/21/2015 */       
                        	else
                        	{
                        		objCallReport.Name = 'Subject Masked';
                        	}
                        	/*End - Written By - Pankaj Ganwani on 5/21/2015 */
                        }
                        insert objCallReport;
                        for(Sobject objActivityRelation : objSobject.getSObjects(isTask ? 'TaskRelations' : 'EventRelations'))
                        {
                            if(Id.valueOf(String.valueOf(objActivityRelation.get('RelationId'))).getSobjectType() == Contact.sObjectType)
                                lstCallReportAtt.add(new Call_Report_Attendees__c(Call_Report__c = objCallReport.Id, Call_Report_Attendee__c = Id.valueOf(String.valueOf(objActivityRelation.get('RelationId')))));
                        }
                        insert lstCallReportAtt;
                        
                        if(!isTask)
                            update new Event(Id = trueActivityId, Call_Report_Id__c = objCallReport.Id);
                        
                        // Commented as trigger is created on Call report to create Call report company for Primary Company of call report.
                        /*//checking if object id belongs to contact
                        if(objectId.getSobjectType() == Contact.sobjectType)
                        {
                            Contact objContact = [SELECT AccountId FROM Contact WHERE Id =:objectId];
                            if(objContact.AccountId!=null)
                            {
                                //insert new Call_Report_Company__c(Call_Report__c = objCallReport.Id, Relevant_Company__c = objContact.AccountId);
                            }
                        }
                        //checking if object id belongs to Account
                        else if(objectId.getSobjectType() == Account.sobjectType)
                        {
                            //insert new Call_Report_Company__c(Call_Report__c = objCallReport.Id, Relevant_Company__c = objectId);
                        }*/
                    }
                    return new Pagereference('/'+objCallReport.Id);
                }
            }
        }
        catch(Exception ex)
        {
            System.debug('=================='+ex.getMessage()+'=============='+ex.getLineNumber());
        }
        return null;
    }
    
    /*
        @MethodName: fetchAttendeeRecords
        @param None
        @Description: Fetch Call Report Attendee records related to the particular Call report.
                      On load the page these records will be shown in the vf page.
    */
    private void fetchAttendeeRecords()
    {
        String callReportId = objCallReport.Id;
        try
        {
            // Fetching Call Report Attendees records which are related to the current Call Report and adding to the public list
            for(Call_Report_Attendees__c objAtt : Database.query(String.format('{0}{1}{2}',new List<String>{'SELECT Id, Call_Report__c,Call_Report_Attendee__c,Call_Report_Attendee__r.Name',readFieldSet('AttendeeFieldSet','Contact','Call_Report_Attendee__c'),' FROM  Call_Report_Attendees__c WHERE  Call_Report__c =:callReportId ORDER BY Call_Report_Attendee__r.Account.Name, Call_Report_Attendee__r.LastName '})))
            {
                lstWrapperAttendee.add(new WrapperAttendee(objAtt,true,false));
                setContactId.add(objAtt.Call_Report_Attendee__c);
            }
            //adding extra row to avoid repeatitive clicks on Add Attendee button
            addAttendee();
        }
        catch(Exception ex)
        {
            System.debug('=================='+ex.getMessage()+'=============='+ex.getLineNumber());
        }
    }
    
     /*
        @MethodName: fetchCompanyRecords
        @param None
        @Description: Fetch Call Report Company records related to the particular Call report.
                      On load the page these records will be shown in the vf page.
    */
    private void fetchCompanyRecords()
    {
        String callReportId = objCallReport.Id;     
        try
        {
            // Fetching Call Report Company records which are related to the current Call Report record and adding to the public list
            for(Call_Report_Company__c objCom :Database.query(String.format('{0}{1}{2}',new List<String>{'SELECT Id, Call_Report__c,Relevant_Company__c,Relevant_Company__r.Name',readFieldSet('CompanyFieldSet','Account','Relevant_Company__c'),' FROM  Call_Report_Company__c WHERE Call_Report__c =:callReportId order by Relevant_Company__r.Name'})))
            {
                lstWrapperCompany.add(new WrapperCompany(objCom,true,false));
                setAccountId.add(objCom.Relevant_Company__c);
            }
            //adding extra row to avoid repeatitive clicks on Add Company button
            addCompany();
        }
        catch(Exception ex)
        {
            System.debug('=================='+ex.getMessage()+'=============='+ex.getLineNumber());
        }
    }
    
    /*
        @MethodName: readFieldSet
        @param : field set name, object name and relationship name
        @Description: It is used to form comma separated string of all the fields that are contained in field set
    */   
    private String readFieldSet(String fieldSetName, String objectName, String relationshipName)
    {
        //fetching fields from field set corresponding to the object name
        Schema.FieldSet objFieldSet = Schema.getGlobalDescribe().get(objectName).getDescribe().FieldSets.getMap().get(fieldSetName);
        String strQuery = '';//declaring variable to hold the value of comma separated fields of field set
        try
        {
            //Iterating over field set member object to fill the header list and field api list
            for(Schema.FieldSetMember objFieldSetMember : objFieldSet.getFields())
            {
               //checking if field is of reference type then fetch id and its name as well to show on the page as hyperlink
               String strFieldAPIName = String.valueOf(objFieldSetMember.getType()) == 'REFERENCE' ? relationshipName.replace('__c', '__r.'+objFieldSetMember.getFieldPath()) + ',' +relationshipName.replace('__c', '__r.'+ (objFieldSetMember.getFieldPath().contains('Id') ? objFieldSetMember.getFieldPath().replace('Id','.Name') : objFieldSetMember.getFieldPath().replace('__c','__r.Name'))) 
                                        : relationshipName.replace('__c', '__r.'+objFieldSetMember.getFieldPath());
               strQuery+= ','+ strFieldAPIName;
            }
        }
        catch(Exception ex)
        {
            System.debug('================'+ex.getMessage()+'======================'+ex.getLineNumber());
        }
        return strQuery;
    }
    
    /*
        @MethodName: addAttendee
        @param None
        @Description: It will add new attendees
    */    
    public void addAttendee()
    {
        Boolean rowAdd = true;
        try
        {
            for(Integer i = 0;i < lstWrapperAttendee.size(); i++)
            {
                if(lstWrapperAttendee[i].objCR.Reference_Contact__c==null && lstWrapperAttendee[i].objAttendee.Id == null)
                    rowAdd = false;
            }
            if(rowAdd)
                lstWrapperAttendee.add(new WrapperAttendee(new Call_Report_Attendees__c(),false,false));
        }
        catch(Exception ex)
        {
            System.debug('=================='+ex.getMessage()+'=============='+ex.getLineNumber());
        }
    }     
    
    /*
        @MethodName: delAttendee
        @param None
        @Description: It will delete selected attendees
    */ 
    
    public void delAttendee()
    {
        try
        {
            delete new Call_Report_Attendees__c(Id = strAttendeeId);       
            for(Integer i=0;i < lstWrapperAttendee.size();i++)
            {
                if(lstWrapperAttendee[i].objAttendee.Id == Id.valueOf(strAttendeeId))
                {
                    setContactId.remove(lstWrapperAttendee[i].objAttendee.Call_Report_Attendee__c);
                    lstWrapperAttendee.remove(i);
                }   
            }
        }
        catch(Exception ex)
        {
            System.debug('=================='+ex.getMessage()+'=============='+ex.getLineNumber());
        }
    }
    
    /*
        @MethodName: cancelAttendeeRecord
        @param None
        @Description: Cancel the updates
    */
    public void cancelAttendeeRecord()
    { 
        Integer nullCount = 0;//to keep track of null attendees
        try
        {
            //Iterating over wrapper class list to check for null Ids
            for(Integer i = 0; i < lstWrapperAttendee.size(); i++)
            {
                lstWrapperAttendee[i].strErrormessage = '';
                if(lstWrapperAttendee[i].objAttendee.Id == null)
                    nullCount++;
            }
            //Iterating over wrapper attendee 
            for(Integer i = 0; i < lstWrapperAttendee.size(); i++)
            {
                //checking if cancel button is clicked on record
                if(lstWrapperAttendee[i].isCancelRecord)
                {
                    setContactId.remove(lstWrapperAttendee[i].objCR.Reference_Contact__c);
                    lstWrapperAttendee[i].objCR.Reference_Contact__c = null;
                    lstWrapperAttendee[i].strErrormessage = '';
                    //if attendee id is null
                    if(String.isEmpty(strAttendeeId))
                    {                    
                        if(nullCount>1)
                            lstWrapperAttendee.remove(i);
                        else
                            lstWrapperAttendee[i].isEditRecord = false;
                    }
                    //if attendee id is not null
                    else
                    {
                        lstWrapperAttendee[i].isCancelRecord = false;
                        lstWrapperAttendee[i].isEditRecord = true;
                    }
                    break;
                } 
            }
        }
        catch(Exception ex)
        {
            System.debug('=================='+ex.getMessage()+'=============='+ex.getLineNumber());
        }
    }
    
    /*
        @MethodName: editAttendee
        @param None
        @Description: The method is called when any call report attendee record is edited 
    */
    public void editAttendee()
    {
        try
        {
            //Iterating over list of attendee records
            for(WrapperAttendee objWrapperAttendee : lstWrapperAttendee)
            {
                if(objWrapperAttendee.objAttendee.Id == id.valueOf(strAttendeeId))
                {
                    setContactId.remove(objWrapperAttendee.objAttendee.Call_Report_Attendee__c);
                    objWrapperAttendee.objCR.Reference_Contact__c = objWrapperAttendee.objAttendee.Call_Report_Attendee__c; 
                    objWrapperAttendee.isEditRecord = false;
                }
            }
        }
        catch(Exception ex)
        {
            System.debug('=================='+ex.getMessage()+'=============='+ex.getLineNumber());
        }
    }
    
   
    /*
        @MethodName: addCompany
        @param None
        @Description: It will add new attendees.The method will be called onclick of Add Company button  from the page
    */
    public void addCompany()
    {
        Boolean rowAdd = true;
        try
        {
            for(Integer i = 0;i < lstWrapperCompany.size(); i++)
            {
                if(lstWrapperCompany[i].objCR.Reference_Account__c == null && lstWrapperCompany[i].objCompany.Id == null)
                    rowAdd = false;
            }
            if(rowAdd)
            lstWrapperCompany.add(new WrapperCompany(new Call_Report_Company__c(),false,false));
        }
        catch(Exception ex)
        {
            System.debug('=================='+ex.getMessage()+'=============='+ex.getLineNumber());
        }
    }
    
    /*
        @MethodName: delCompany
        @param None
        @Description: It will delete the selected attendees. The method will be called onclick of delete link
    */
    public void delCompany()
    {
        try
        {
            delete new Call_Report_Company__c(Id = strCompanyId);       
            for(Integer i=0;i < lstWrapperCompany.size();i++)
            {
                if(lstWrapperCompany[i].objCompany.Id == Id.valueOf(strCompanyId))
                {
                    setAccountId.remove(lstWrapperCompany[i].objCompany.Relevant_Company__c); 
                    lstWrapperCompany.remove(i);
                } 
            }
        }
        catch(Exception ex)
        {
            System.debug('=================='+ex.getMessage()+'=============='+ex.getLineNumber());
        }
    }
    
    /*
        @MethodName: cancelCompanyRecord
        @param None
        @Description: This method will be called onclick of cancel link from the page
    */
        
    public void cancelCompanyRecord()
    { 
        Integer nullCount = 0;//to keep track of null attendees
        try
        {
            //Iterating over wrapper class list to check for null Ids
            for(Integer i = 0; i < lstWrapperCompany.size(); i++)
            {
                lstWrapperCompany[i].strErrormessage = '';
                if(lstWrapperCompany[i].objCompany.Id == null)
                    nullCount++;
            }
            //Iterating over list of call report company records
            for(Integer i = 0; i < lstWrapperCompany.size(); i++)
            {
                //checking if cancel link has been clicked on the row
                if(lstWrapperCompany[i].isCancelRecord)
                {
                    setAccountId.remove(lstWrapperCompany[i].objCR.Reference_Account__c);
                    lstWrapperCompany[i].objCR.Reference_Account__c = null;
                    lstWrapperCompany[i].strErrormessage = '';
                    if(String.isEmpty(strCompanyId))
                    {
                         if(nullCount>1)
                            lstWrapperCompany.remove(i);
                        else
                            lstWrapperCompany[i].isEditRecord = false;
                    }
                    else
                    {
                        lstWrapperCompany[i].isCancelRecord = false;
                        lstWrapperCompany[i].isEditRecord = true;
                    }
                }   
            }
        }
        catch(Exception ex)
        {
            System.debug('=================='+ex.getMessage()+'=============='+ex.getLineNumber());
        }
    }
    
    /*
        @MethodName: editCompany
        @param None
        @Description: This method will be called onclick of the edit link
    */
    public void editCompany()
    {
        
        try
        {
            //Iterating over list of call report company records
            for(Wrappercompany objWrappercompany : lstWrapperCompany)
            {
                if(objWrappercompany.objCompany.Id == id.valueOf(strCompanyId))
                {
                    setAccountId.remove(objWrappercompany.objCompany.Relevant_Company__c);
                    objWrappercompany.objCR.Reference_Account__c = objWrappercompany.objCompany.Relevant_Company__c; 
                    objWrappercompany.isEditRecord = false;
                }
            }
        }
        catch(Exception ex)
        {
            System.debug('=================='+ex.getMessage()+'=============='+ex.getLineNumber());
        }
    }
    
    /*
        @MethodName: saveAll
        @param : NA
        @Description: This method will save all the records of respective sections
    */
    public void saveAll()
    {
        List<Call_Report_Attendees__c> lstCRA = new List<Call_Report_Attendees__c>();//This list is used to hold the Call_Report_Attendees__c records that are supposed to be saved
        List<Call_Report_Company__c> lstCRC = new List<Call_Report_Company__c>();//This list is used to hold the Call_Report_Company__c records that are supposed to be saved
        setContactId.clear();
        setAccountId.clear();
        try
        {
            //checking if button is clicked from call report attendee section
            if(String.isNotBlank(strObjectName))
            {
                if(strObjectName == 'Call Report Attendee')
                {
                    for(WrapperAttendee objWA : lstWrapperAttendee)
                    {
                        if(!objWA.isCancelRecord && objWA.isEditRecord)
                        {
                            if(objWA.objCR.Reference_Contact__c!=null && objWA.objAttendee.Id!=null)
                                setContactId.add(objWA.objCR.Reference_Contact__c);
                            if(objWA.objAttendee.Id!=null)
                                setContactId.add(objWA.objAttendee.Call_Report_Attendee__c);
                        }
                    }
                    for(WrapperAttendee objWA : lstWrapperAttendee)
                    {
                        if(objWA.objCR.Reference_Contact__c!=null)
                        { 
                            if(setContactId.contains(objWA.objCR.Reference_Contact__c))
                            {
                                objWA.strErrormessage = 'Error : Call Report Attendee record already exist corresponding to selected Contact';                                
                                return;
                            }
                            else
                            {
                                lstCRA.add(objWA.objAttendee.Id!=null ? new Call_Report_Attendees__c(Id = objWA.objAttendee.Id, Call_Report__c = objCallReport.Id, Call_Report_Attendee__c = objWA.objCR.Reference_Contact__c) : new Call_Report_Attendees__c(Call_Report__c = objCallReport.Id, Call_Report_Attendee__c = objWA.objCR.Reference_Contact__c));                          
                                setContactId.add(objWA.objCR.Reference_Contact__c);
                            }                       
                        }
                        else if(objWA.objAttendee.Id!=null)
                        {
                            setContactId.add(objWA.objAttendee.Call_Report_Attendee__c);
                        }
                    }
                }
                //checking if button is clicked from call report company section
                else if(strObjectName == 'Call Report Company')
                {
                    for(WrapperCompany objWC : lstWrapperCompany)
                    {
                        if(!objWC.isCancelRecord && objWC.isEditRecord)
                        {
                            if(objWC.objCR.Reference_Account__c!=null && objWC.objCompany.Id!=null)
                                setAccountId.add(objWC.objCR.Reference_Account__c);
                            if(objWC.objCompany.Id!=null)
                                setAccountId.add(objWC.objCompany.Relevant_Company__c);
                        }
                    }
                    for(WrapperCompany objWC : lstWrapperCompany)
                    {
                        if(objWC.objCR.Reference_Account__c!=null)
                        {
                            if(setAccountId.contains(objWC.objCR.Reference_Account__c))
                            {
                                objWC.strErrormessage = 'Error : Call Report Company record already exist corresponding to selected Account';
                                return;
                            }
                            else
                            {
                                lstCRC.add(objWC.objCompany.Id!=null ? new Call_Report_Company__c(Id = objWC.objCompany.Id, Call_Report__c = objCallReport.Id, Relevant_Company__c = objWC.objCR.Reference_Account__c) : new Call_Report_Company__c(Call_Report__c = objCallReport.Id, Relevant_Company__c = objWC.objCR.Reference_Account__c));
                                setAccountId.add(objWC.objCR.Reference_Account__c);
                            }
                        }
                        else if(objWC.objCompany.Id!=null)
                        {
                            setAccountId.add(objWC.objCompany.Relevant_Company__c);
                        }
                    }
                }
            }
            try
            {               
                if(!lstCRA.isEmpty())
                    upsert lstCRA;
                if(!lstCRC.isEmpty())
                    upsert lstCRC;          
            }
            catch(DMLException ex)
            {
                System.debug('================='+ex.getMessage()+'================='+ex.getLineNumber());
            }
            if(strObjectName == 'Call Report Attendee')
            {
                lstWrapperAttendee.clear();
                //refetching the attendee records
                fetchAttendeeRecords();
            }
            if(strObjectName == 'Call Report Company')
            {
                lstWrapperCompany.clear();
                //refetching the company records
                fetchCompanyRecords();
            }
        }
        catch(Exception ex)
        {
            System.debug('================='+ex.getMessage()+'================='+ex.getLineNumber());
        }
    }
    
    /*
        @MethodName: editRecords
        @param : NA
        @Description: This method will be used to make the fields editable
    */
    public void editRecords()
    {
        try
        {   
            //checking if button is clicked from call report attendee section       
            if(strObjectName == 'Call Report Attendee')
            {
                for(WrapperAttendee objWA : lstWrapperAttendee)
                {
                    if(objWA.isSelected)
                    {
                        setContactId.remove(objWA.objAttendee.Call_Report_Attendee__c);
                        objWA.objCR.Reference_Contact__c = objWA.objAttendee.Call_Report_Attendee__c;
                        objWA.isEditRecord = false;
                    }
                }
            }
            //checking if button is clicked from call report company section
            else if(strObjectName == 'Call Report Company')
            {
                for(WrapperCompany objWC : lstWrapperCompany)
                {
                    if(objWC.isSelected)
                    {
                        setAccountId.remove(objWC.objCompany.Relevant_Company__c);
                        objWC.objCR.Reference_Account__c = objWC.objCompany.Relevant_Company__c;
                        objWC.isEditRecord = false;
                    }
                }
            }
        }
        catch(Exception ex)
        {
            System.debug('================='+ex.getMessage()+'================='+ex.getLineNumber());
        }
    }
    
     /*
        @MethodName: deleteRecords
        @param : NA
        @Description: This method will be used to delete the selected records.
    */
    public void deleteRecords()
    {
        List<Sobject> lstSobject = new List<Sobject>();//This list is used to hold the seleted records that are to be deleted       
        try
        {   
            //checking if button is clicked from call report attendee section       
            if(strObjectName == 'Call Report Attendee')
            {
                 for(Integer i=0;i < lstWrapperAttendee.size();i++)
                 {
                    if(lstWrapperAttendee[i].isSelected && lstWrapperAttendee[i].objAttendee.Id!=null)
                    {
                        setContactId.remove(lstWrapperAttendee[i].objAttendee.Call_Report_Attendee__c);
                        lstSobject.add(lstWrapperAttendee[i].objAttendee);
                    }
                 }
            }
            //checking if button is clicked from call report company section
            else if(strObjectName == 'Call Report Company')
            {
                 for(Integer i=0;i < lstWrapperCompany.size();i++)
                 {
                    if(lstWrapperCompany[i].isSelected && lstWrapperCompany[i].objCompany.Id!=null)
                    {
                        setAccountId.remove(lstWrapperCompany[i].objCompany.Relevant_Company__c);
                        lstSobject.add(lstWrapperCompany[i].objCompany);
                    }
                 }
            }
            try
            {
                if(!lstSobject.isEmpty())
                    delete lstSobject;
            }
            catch(DMLException ex)
            {
                System.debug('================='+ex.getMessage()+'================='+ex.getLineNumber());
            }
            if(strObjectName == 'Call Report Attendee')
            {
                lstWrapperAttendee.clear();
                fetchAttendeeRecords();
            }
            if(strObjectName == 'Call Report Company')
            {
                lstWrapperCompany.clear();
                fetchCompanyRecords();
            }
        }
        catch(Exception ex)
        {
            System.debug('================='+ex.getMessage()+'================='+ex.getLineNumber());
        }
    }
}