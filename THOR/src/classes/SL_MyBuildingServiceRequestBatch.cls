/**
*  Class Name     : SL_MyBuildingServiceRequestBatch
*  JIRATicket     : THOR-13
*  CreatedOn      : 4/NOV/2014
*  ModifiedBy     : SANATH
*  Description    : Class for creating Service request cases based on MyBuilding responses.
*/
global class SL_MyBuildingServiceRequestBatch implements database.Batchable<sobject>, Database.AllowsCallouts
{
    /* START : Variables */
    string strQuery = ''; 
    String PAGE_NUMBER = '1';
    List<SL_ServiceRequestResponseClass.Requests> lstOfServiceRequests = new List<SL_ServiceRequestResponseClass.Requests>();
    List<Case> lstCaseToUpsert = new List<Case>(); 
    List<Account> lstAccountToInsert = new List<Account>();
    SL_MyBuilding_Integration__c objCustomSetting = SL_MyBuilding_Integration__c.getall().values();//Fetching values from Custom Setting.
    Map<String,String> mapCaseEmailPhoneDescription_AccountDetails = new Map<String,String>();
    Map<String,Id> mapAccountDetails_AccountId = new Map<String,Id>();
    Map<String, Account> mapExistingPersonAccount = new Map<String, Account>();
    Id PERSON_ACCOUNT_RECORDTYPEID = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND  IsPersonType = true].Id;
    Set<String> setContactLastNames = new Set<String>();
    Set<String> setContactFirstNames = new Set<String>();
    Set<String> setContactEmail = new Set<String>();
    Set<String> setContactPhone = new Set<String>();
    Map<String,Id> mapExistingCase = new Map<String,Id>();
	Set<Id> setExistingCaseDetails = new Set<Id>();
	Set<String> setExistingAccountDetails = new Set<String>(); 
	Map<String,Id> mapApartmentName_ApartmentId = new Map<String,Id>();
	
	/* Added by Lodhi to defaut account id THOR-65 */
	private static Default_Account_For_Maintainence_Cases__c objDAFMC;
	private static final Id defaultAccountId;
	private static final Id defaultCustomSettingId;
	private static Account objDefaultAccount;
	
    /*Added for THOR-68*/
    set<Id> setApartmentId = new set<Id>();
    /*Added for THOR-68*/

	static 
	{
    	objDAFMC = Default_Account_For_Maintainence_Cases__c.getInstance('Default Account') != null 
                   ? Default_Account_For_Maintainence_Cases__c.getInstance('Default Account') : null;
        defaultAccountId = (objDAFMC != null) ? objDAFMC.Default_Account_Id__c : null;
        defaultCustomSettingId = (objDAFMC != null) ? objDAFMC.Id : null;
        
        List<Account> lstDefaultAccount = [SELECT Id, Name, FirstName, LastName, PersonEmail, Phone, Description 
	                                         FROM Account WHERE IsPersonAccount = true AND Id =: defaultAccountId
	                                          AND FirstName != null AND PersonEmail != null AND Phone != null];
        if(!lstDefaultAccount.isEmpty())
        {
            objDefaultAccount = lstDefaultAccount[0];
        }    
        else
        {
            Id recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'PersonAccount'].Id;
            objDefaultAccount = new Account(FirstName = 'Default', LastName = 'Account', RecordTypeId = recordTypeId, Phone = 'Default', 
                                            PersonEmail = 'defaultaccount@silverlinecrm.com', Description = 'Default Account Description'); 
            insert objDefaultAccount;
            objDefaultAccount = [SELECT Name, FirstName, LastName, PersonEmail, Phone, Description FROM Account WHERE Id =: objDefaultAccount.Id];
            
            if(defaultAccountId != null)             
                update new Default_Account_For_Maintainence_Cases__c(Id = defaultCustomSettingId, Default_Account_Id__c = objDefaultAccount.Id);    
            
            if(defaultCustomSettingId == null)
                insert new Default_Account_For_Maintainence_Cases__c(Name = 'Default Account', Default_Account_Id__c = objDefaultAccount.Id);
        }    
	}    
    /* Added by Lodhi to defaut account id THOR-65  */
    /* END : Variables */
    
    /* Start : Constructor */
    public SL_MyBuildingServiceRequestBatch()
    {   
        strQuery = 'Select Community_ID__c From Building__c Where Community_ID__c != null';   
    }
    /* End : Constructor */
    
    /*
        @MethodName : start   
        @param      : Database.BatchableContext BC
        @Description: This method is used to collect records of Building__c objects when Community_ID__c is not null, return all that records to execute method.
    */
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(strQuery);
    }
    
    /*
        * MethodName   : execute
        * Param        : Database.BatchableContext BC, List<Building__c> lstBuilding
        * Description  : Processes Building__c records returned by start method
    */
    global void execute(Database.BatchableContext BC, List<Building__c> lstBuilding)
    {
        // Scope size would always be '1'.      
        for(Building__c objBuilding: lstBuilding)
        {
            //Call makeCalloutForServiceRequests method with CommunityId as parameter. 
            makeCalloutForServiceRequests(objBuilding.Community_ID__c);
        }
    }
    
    /*
        * MethodName   : makeCalloutForServiceRequests
        * Param        : String communityId
        * Description  : Performing callouts to MyBuilding based on different communityId.
    */
    public void makeCalloutForServiceRequests(String communityId)
    {
        List<Case> lstCasesToUpdate = new List<Case>();
        
        // Make call-out to MyBuilding
        Http h = new Http();
        HttpResponse res;
        HttpRequest request = new HttpRequest();
        String endPointValue = objCustomSetting.EndPoint__c ;
        String strRequestBody = '?format=json';  
        strRequestBody += '&app_id=' + objCustomSetting.app_Id__c;// Fetching appId from custom setting
        strRequestBody += '&app_key=' + objCustomSetting.app_key__c;// Fetching appKey from custom setting
        strRequestBody += '&communityId=' + communityId;//; //This will change for next execution of execute method.
        strRequestBody += '&pageSize=' + '50';
        strRequestBody += '&pageNumber=' + PAGE_NUMBER; // This will increment in case of recursive calls per building
        request.setEndpoint('http://api.mybuilding.org/servicerequests'+strRequestBody);
        
        
        request.setMethod('GET');
        
        res = h.send(request);
        
        //Retrieving the response in wrapper
        SL_ServiceRequestResponseClass objResponse = (SL_ServiceRequestResponseClass)JSON.deserialize(res.getBody(), SL_ServiceRequestResponseClass.class);
        //Adding all the requests in lstOfServiceRequests.
        if(objResponse.response.requests != null)
            lstOfServiceRequests.addAll(objResponse.response.requests); 
        
        if(!lstOfServiceRequests.isEmpty())
            prepareServiceRequestCases(communityId, lstOfServiceRequests);// Call prepareServiceRequestCases method by passing Community and lstOfServiceRequests as parameter.
        
        //Making callout again for next PageNumber  
        if(objResponse.response.pageCount != null)
        {
            if(Integer.valueOf(PAGE_NUMBER) < objResponse.response.pageCount)
            {
                PAGE_NUMBER = String.valueof(Integer.valueOf(PAGE_NUMBER) + 1);
                makeCalloutForServiceRequests(communityId);//Recursively call this method till callout happens for lastpage.
            }
            else
            {
                if(!lstCaseToUpsert.isEmpty())
                {
                    upsert lstCaseToUpsert;
                    searchLease(); //Added for THOR-68
                }
                    
                if(!lstAccountToInsert.isEmpty())
                {
                    insert lstAccountToInsert;
                    
                    for(Account objAccount:[SELECT FirstName,LastName,Id,PersonEmail,Phone
                                            FROM Account 
                                            WHERE Id IN:lstAccountToInsert])
                    {
                        mapAccountDetails_AccountId.put(objAccount.FirstName + '###' + objAccount.LastName + '###' + objAccount.PersonEmail +
                                                         '###' + objAccount.Phone,objAccount.Id);
                    }
                    
                    for(Case objCase:[SELECT AccountId,Service_Request_Id__c
                                      FROM Case
                                      WHERE Id IN:lstCaseToUpsert])
                    {
                        objCase.AccountId = mapAccountDetails_AccountId.get(mapCaseEmailPhoneDescription_AccountDetails.get(objCase.Service_Request_Id__c));
                        lstCasesToUpdate.add(objCase);
                    }
                    
                    if(!lstCasesToUpdate.isEmpty())
                        update lstCasesToUpdate;// Updating Cases if it is not empty.
                }
            }
        }
    }
    
    /*Added by Sanath for THOR-68*/

    /*
        * MethodName   : populate Leases
        * Param        : List<Case>(List of Cases to be inserted)
        * Description  : Added for THOR-68.Populates the Case with it respective lease
    */

    void searchLease()
    {
        List<Lease__c> lstLeaseToUpdateCase = new List<Lease__c>();
        List<Case> lstCasesToUpdateLease = new List<Case>();
        map<Id , Case> mapIdToCase = new map<Id , Case>(); 
        for(Lease__c objLease : [SELECT Id,Start_Date__c,End_Date__c,Apartment__c From Lease__c where Apartment__c IN:setApartmentId])
        {
            lstLeaseToUpdateCase.add(objLease);
        }
        for(Case objCase : [Select Id,CreatedDate from Case where Id IN:lstCaseToUpsert AND Lease__c = null])
        {
            mapIdToCase.put(objCase.Id , objCase);
        }
        if(!lstLeaseToUpdateCase.isEmpty())
            for(Case objCase : lstCaseToUpsert)
            {
                if(mapIdToCase.containsKey(objCase.Id))
                {
                    for(Lease__c objLease : lstLeaseToUpdateCase)
                    {
                        if(objLease.Start_Date__c <= mapIdToCase.get(objCase.Id).CreatedDate && objLease.End_Date__c >= mapIdToCase.get(objCase.Id).CreatedDate && objCase.Apartment__c == objLease.Apartment__c)
                        {
                            objCase.Lease__c = objLease.Id;
                            objCase.Lease_Start_Date__c = objLease.Start_Date__c;
                            lstCasesToUpdateLease.add(objCase);
                            break;
                        }
                    }
                }
            }
        if(!lstCasesToUpdateLease.isEmpty())
            upsert lstCasesToUpdateLease;
    }

    /*Added by Sanath for THOR-68*/

    /*
        * MethodName   : prepareServiceRequestCases
        * Param        : String communityId and List<SL_ServiceRequestResponseClass.Requests> lstOfServiceRequests
        * Description  : Used for creating cases and Account based on My Building responses. 
    */
    public void prepareServiceRequestCases(String communityId, List<SL_ServiceRequestResponseClass.Requests> lstOfServiceRequests)
    {
    	Id CASE_RECORDTYPE_ID = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND  DeveloperName = 'Maintenance_Request'].Id;
        // Iterating on lstOfServiceRequests for getting contactName, contactEmail, contactPhone.
        for(SL_ServiceRequestResponseClass.Requests objResp : lstOfServiceRequests)
        {
        	try
        	{
            	objResp.contactName = objResp.contactName.trim();
        		setContactFirstNames.add(objResp.contactName.split(' ')[0]);
        		setContactLastNames.add(objResp.contactName.split(' ')[1]);
        		setContactEmail.add(objResp.ContactEmail.trim());
        		setContactPhone.add(objResp.contactPhone.trim());
        	}
        	catch(Exception ex)
        	{
    	        objResp.contactName = objDefaultAccount.Name;
        		setContactFirstNames.add(objDefaultAccount.FirstName);
        		setContactLastNames.add(objDefaultAccount.LastName);
        		setContactEmail.add(objDefaultAccount.PersonEmail);
        		setContactPhone.add(objDefaultAccount.Phone);
        	}
        }
        
        // Creating map of existing person account based on My Building responses.
        for(Account objPersonAccount : [SELECT Id, FirstName ,LastName,PersonEmail,Phone 
                                        FROM Account  
                                        WHERE  IsPersonAccount = true AND LastName IN:setContactLastNames AND FirstName IN:setContactFirstNames
                                        AND PersonEmail IN:setContactEmail AND Phone IN:setContactPhone])
        {
            mapExistingPersonAccount.put(objPersonAccount.FirstName + '###' + objPersonAccount.LastName + '###' + 
                                         objPersonAccount.PersonEmail + '###' + objPersonAccount.Phone
                                         , objPersonAccount);
        }
        
        for(Case objCase:[SELECT Id,Service_Request_Id__c
                          FROM Case
                          WHERE Service_Request_Id__c != null])
        {
            mapExistingCase.put(objCase.Service_Request_Id__c,objCase.Id);
        }
        
        ///Query the building record
        Building__c objBuilding = [SELECT Id FROM Building__c WHERE Community_ID__c =:communityId LIMIT 1];
        
        for(Apartment__c objApartment:[SELECT Id,Apartment_Number__c From Apartment__c WHERE Building__c =:objBuilding.Id])
        {
        	if(objApartment.Apartment_Number__c != null)
        	{
        		mapApartmentName_ApartmentId.put(objApartment.Apartment_Number__c,objApartment.Id);
                setApartmentId.add(objApartment.Id);
        	}
        }
        
        // Iterate over the responses to create cases
        for(SL_ServiceRequestResponseClass.Requests objRes : lstOfServiceRequests)
        {
        	if(!mapExistingCase.containskey(objRes.requestId.trim()) &&
        	   !mapCaseEmailPhoneDescription_AccountDetails.containskey(objRes.requestId.trim()))
        	{
        		try
        		{
            		objRes.contactName = objRes.contactName.trim();
            		objRes.contactEmail = objRes.contactEmail.trim();
    	            objRes.contactPhone = objRes.contactPhone.trim();
            		objRes.description = objRes.description.trim();
        		}
        		catch(Exception ex)
        		{
        		    objRes.contactName = objDefaultAccount.Name;
            		objRes.contactEmail = objDefaultAccount.PersonEmail;
    	            objRes.contactPhone = objDefaultAccount.Phone;
            		objRes.description = objDefaultAccount.description;
        		}
        		
	            Case objCase = new Case();
	            objCase.Service_Request_Id__c       =       objRes.requestId;
	            objCase.Service_Request_Category__c =       objRes.category;
	            objCase.Service_Request_Status__c   =       objRes.status;
	            objCase.Description                 =       objRes.description;
	            objCase.Phone__c                    =       objRes.contactPhone;
	            objCase.Email__c                    =       objRes.ContactEmail;
	            objCase.RecordtypeId                =        CASE_RECORDTYPE_ID;
	            
	            if(objBuilding.Id != null) 
	            	objCase.Building__c             =       objBuilding.Id;
	            
	            if(objRes.unit != null)
	            objRes.unit = objRes.unit.replace('-','');
	            
	            if(mapApartmentName_ApartmentId.containskey(objRes.unit) && mapApartmentName_ApartmentId.get(objRes.unit) != null)
	           	    objCase.Apartment__c            =       mapApartmentName_ApartmentId.get(objRes.unit);
	            
	            //Creating new Accounts if it is not already present.
	            if(!mapExistingPersonAccount.containskey(objRes.contactName.split(' ')[0] + '###' + objRes.contactName.split(' ')[1] + '###' + 
                                         						objRes.contactEmail + '###' + objRes.contactPhone) &&
                    !setExistingAccountDetails.contains(objRes.contactName.split(' ')[0] + '###' + objRes.contactName.split(' ')[1] + '###' + 
                                         						objRes.contactEmail + '###' + objRes.contactPhone))
	            {
	                Account objAccount = new Account(FirstName = objRes.contactName.split(' ')[0],
	                                                 LastName = objRes.contactName.split(' ')[1],
	                                                 PersonEmail =  objRes.contactEmail.trim(),
	                                                 Phone = objRes.contactPhone.trim(),
	                                                 RecordTypeId = PERSON_ACCOUNT_RECORDTYPEID);     
	                lstAccountToInsert.add(objAccount);
	                
	                setExistingAccountDetails.add(objRes.contactName.split(' ')[0] + '###' + objRes.contactName.split(' ')[1] + '###' + 
                                         						objRes.contactEmail + '###' + objRes.contactPhone);
	            }
	            else if(mapExistingPersonAccount.containskey(objRes.contactName.split(' ')[0] + '###' + objRes.contactName.split(' ')[1] + '###' + objRes.contactEmail + '###' + objRes.contactPhone) &&
                                         mapExistingPersonAccount.get(objRes.contactName.split(' ')[0] + '###' + objRes.contactName.split(' ')[1] + '###' + objRes.contactEmail + '###' + objRes.contactPhone) != null)
                {     
	                objCase.AccountId = mapExistingPersonAccount.get(objRes.contactName.split(' ')[0] + '###' + objRes.contactName.split(' ')[1] + '###' + 
                                         						objRes.contactEmail + '###' + objRes.contactPhone).Id;
                }
	            mapCaseEmailPhoneDescription_AccountDetails.put(objRes.requestId.trim(),
	                    objRes.contactName.split(' ')[0] + '###' + objRes.contactName.split(' ')[1] + '###' + objRes.contactEmail + '###' + objRes.contactPhone);
                                         						
	        	lstCaseToUpsert.add(objCase);
        	}
        	else if(mapExistingCase.containskey(objRes.requestId.trim()) && mapExistingCase.get(objRes.requestId.trim()) != null &&
        	        !setExistingCaseDetails.contains(mapExistingCase.get(objRes.requestId.trim())))
        	{
        		Case objCase = new Case();
        		objCase.Id = mapExistingCase.get(objRes.requestId.trim());
        		objCase.Service_Request_Status__c   = objRes.status;
        		setExistingCaseDetails.add(objCase.Id);
        		lstCaseToUpsert.add(objCase);
        	}
        }
    }
    
     /*
        * MethodName   : finish
        * Param        : Database.BatchableContext BC
        * Description  : Performs necessary post-execution steps
    */
    global void finish(Database.BatchableContext BC)
    {
        //Do Nothing
    }
}