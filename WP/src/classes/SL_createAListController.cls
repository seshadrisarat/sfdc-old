/**
* @ClassName    : SL_createAListController 
* @JIRATicket   : WP-97
* @CreatedOn    : 
* @ModifiedBy   : SL
* @Description  : 
*/

/**
@Developer Name							: Sandeep
Percentage of best practices followed	: 100%
No of SOQL queries used					: 
No of collections used					: 0
Exception Handling implemented			: Yes
Coding standards followed				: Yes
Naming conventions followed				: Yes
Third party integrations				: No
Maximum of No of records tested with	: 
Customer Approval						: 
Last Modified Date						: 
Approved by								: 

*/

public with sharing class SL_createAListController 
{
	/*Start - Global variables*/
	public Company_List__c objList	{get;set;} 					
	public SelectOption[] lstUserOrGroup_Input {get;set;}
   	public SelectOption[] lstUserOrGroup_Output {get;set;}
   	public String strUserOrGroups {get; set;}
	public String strSecurityAccessLevel	{get;set;}
	public String strUserOrGroup	{get;set;}
	public Boolean isFirmWide{get;set;}
	public Boolean isReadWriteAccess{get;set;}
	public Boolean isRecordOwner {get;set;}
	
	/*End - Global variables*/
	
	/*Start-  local variables*/
	private Set<String> setSelectGroupId;
	private Set<String> setSelectUserId;
	private Set<String> setSelectFirmId;	
	private Set<String> setSelectUserOrGroupId;
	private Set<String> setUserOrGroupId;
	private String strContactListId;
	private String strReturnURL;
	private String adminProfileId;
	private String oldOwnerId;
	private boolean isEdit;
	private Boolean isPageLoad;
	private Boolean isFirstClick;
	private Map<String, set<Id>> mapUserIds;		//Used for preparing a set of User Ids having duplicate name. 
	private Map<String, set<Id>> mapGroupIds;		//Used for preparing a set of Group Ids having duplicate name.
	private Map<String, set<Id>> mapFirmIds;		//Used for preparing a set of Group Ids having duplicate name.
	
	private Set<String> setValidGroupTypes = new Set<String>{'Regular', 'Role', 'RoleAndSubordinates'};
	private Set<String> setRemovedGroups = new Set<String>{'Admin', 'Deal_Professionals'};
	/*End -  local variables*/
	
    
    /*Start - Constructor*/  
	public SL_createAListController(ApexPages.StandardController stdCtrl)
	{
		initialize();	// initialize local and global variables.
		
		strReturnURL = Apexpages.currentPage().getParameters().get('retURL');	// fetch the return url from the URL for Cancel button functionality.
		
		if(stdCtrl.getId() != Null){		// check whether the page is launched in Edit/New mode
			isEdit = true;
			strContactListId = stdCtrl.getId(); // get the current Id of the contact list record.
		}
		else{
			isEdit = false;
			objList.OwnerId = Userinfo.getUserId();
		}
		
		// query the details of the List record
		if(isEdit)
		{
			objList = [Select Id, Name, Show_in_Quick_Add__c, Outlook_Sync__c, Status__c, OwnerId 
							from Company_List__c 
							where Id = :strContactListId limit 1];
			Set<Id> setGroupIdsTemp = new Set<Id>();
			for(Company_List__Share objShareList :[Select Id, UserOrGroupId, AccessLevel from Company_List__Share where ParentId = :objList.Id])
			{
				//PG : Admin<>PG : Advisor<>PG : Compliance_Group<>PG : RoleAndSubordinates:Admin<>
				if(String.valueOF(objShareList.UserOrGroupId).substring(0,3) == '00G')
					setGroupIdsTemp.add(objShareList.UserOrGroupId);
			}
			
			Set<String> setDuplicateNames = new Set<String>();
			for(Group objGroup : [Select Id, Email, DeveloperName, Type from Group where Id IN : setGroupIdsTemp ORDER BY DeveloperName])
			{
				if(!setRemovedGroups.contains(objGroup.DeveloperName))
				{
					if(setDuplicateNames.contains(objGroup.DeveloperName))
					{
						
						strUserOrGroups += 'PG : ' + objGroup.type +':'+objGroup.DeveloperName + '<>';
					}
					else
					{
						setDuplicateNames.add(objGroup.DeveloperName);
						strUserOrGroups += 'PG : ' + objGroup.DeveloperName + '<>';
					}
				}
				
				
			}
		}
		
		
		fetchUserOrTGroupPicklistValues();	// This method will load all the necessary values on-page load	
	}
	/*End - Constructor*/  
	
	/*This function is user to check whether user is having read/write access or not */
	public pageReference checkUserPermissions()
	{
		String listId = Apexpages.currentPage().getParameters().get('id');
		Set<Id> setGroupIds = new Set<Id>();
       	String accessLevel = '';
       	
       	for(Group objGroup : [Select Id, Type from Group where Type =:'Organization'])
       	{
       		setGroupIds.add(objGroup.Id);
       	}
       	
		/*This is to query group id if user exist in any group.*/       
        for(GroupMember objGroupMember : [Select UserOrGroupId, Id, GroupId From GroupMember where UserOrGroupId =: UserInfo.getUserId()])
        {
        	setGroupIds.add(objGroupMember.GroupId);
        }
        
		
		
		//This is to query Access permission for current user on selected list
	    for(Company_List__Share objShareObject :[Select Id, ParentId, AccessLevel, UserOrGroupId  
	    										From Company_List__Share
	    										Where ParentId =:listId
	    										AND (UserOrGroupId =: UserInfo.getUserId()
	    										OR UserOrGroupId =:setGroupIds)
	    										
        										])
        {
	    	accessLevel =  objShareObject.AccessLevel;
	    	
        }
        String ListOwnerId;
        for(Company_List__c objList : [Select Id, OwnerId From Company_List__c where Id =:listId])
        {
        	ListOwnerId = objList.OwnerId;
        }
        
        if(UserInfo.getProfileId() == adminProfileId || ListOwnerId == UserInfo.getUserId())
        {
        	isReadWriteAccess = false;
        }
        else if(accessLevel == 'Read' )
        {
        	isReadWriteAccess = true;
        	//PageReference pageRef = new PageReference('/' + listId);   
          // pageRef.setRedirect(true);   
           //return pageRef; 
        }
		return null;
	}
	
	/*Start - initialize local and global variables.*/
	private void initialize()
	{
      	lstUserOrGroup_Input = new List<SelectOption>();
        lstUserOrGroup_Output = new List<SelectOption>();
        strUserOrGroups = '';
		//adminProfileId = '';
      	setSelectGroupId = new Set<String>();
      	setSelectUserId = new Set<String>();
      	setSelectFirmId = new Set<String>();
      	setSelectUserOrGroupId = new Set<String>();
      	setUserOrGroupId = new Set<String>();
        strUserOrGroup = 'Group';
        objList = new Company_List__c(); 
        isEdit = true;
        isReadWriteAccess = false;
        isRecordOwner = false;
        strContactListId = strReturnURL = '';
        isPageLoad = true;
        isFirstClick = true;
        isFirmWide = false;
        mapUserIds = new Map<String, set<Id>>();
        mapGroupIds = new Map<String, set<Id>>();
        mapFirmIds = new Map<String, set<Id>>();
        
        /*Added by sandeep */
        for(User objUser:[Select Related_Contact_Id__c, Id From User Where Id =:Userinfo.getUserId() limit 1])
        {
	        for(Contact objContact :[Select Id,Firm_Wide_List__c from Contact where Id =:objUser.Related_Contact_Id__c limit 1])
	        {
	        	isFirmWide = objContact.Firm_Wide_List__c;
	        }
        }
        
        /*This is to get admin profile id*/
        for(Profile objProfile : [Select Id, Name from Profile where Name=:'System Administrator'])
        {
        	adminProfileId = objProfile.Id;
        }
	}
	/*End - initialize local and global variables.*/
	
	private String strPreviousPckListValue = '';
	
	/*Start - fetchUserOrTGroupPicklistValues method will called on page  load and on each time when user changes the share with User/Group picklist*/
	public void fetchUserOrTGroupPicklistValues()
	{
		//Set<Id> setUserOrGroupId = new Set<Id>();
		lstUserOrGroup_Input = new List<SelectOption>();
		lstUserOrGroup_Output = new List<SelectOption>();
		Set<String> setDuplicateIdentifier = new Set<String>();
		Boolean isGroupOrUser = true;
		try
		{
			String strMultiPicklistValue = '';
		    system.debug('------------------strUserOrGroups : '+strUserOrGroups);
		    if(strUserOrGroups != null && strUserOrGroups != '' && strUserOrGroups != 'Empty' && strUserOrGroups.length() > 1) 
		    {
		    	for(String strValue : strUserOrGroups.substring(0,strUserOrGroups.length()-2).split('<>'))
		    		strMultiPicklistValue += strValue+';';
		    }
		    else if(strUserOrGroups != 'Empty') 
		    	strMultiPicklistValue = '';
			
			//Creating list of selected User Or Groups ids.
		    List<String> lstStrUserOrGroups = new List<String>();
		    if(strMultiPicklistValue != '' && strMultiPicklistValue != null)
		    	lstStrUserOrGroups = strMultiPicklistValue.split(';');
			
			// This will execute only for New button(Creating new List record)
			if(isEdit == false)
			{
				if((strUserOrGroup == 'User' && strPreviousPckListValue == 'Group') || (strUserOrGroup == 'Firm' && strPreviousPckListValue == 'Group'))
					setSelectGroupId = new Set<String>();
				else if((strUserOrGroup == 'User' && strPreviousPckListValue == 'Firm') || (strUserOrGroup == 'Group' && strPreviousPckListValue == 'Firm'))
					setSelectFirmId = new Set<String>();	
				else if((strUserOrGroup == 'Group' && strPreviousPckListValue == 'User') || (strUserOrGroup == 'Firm' && strPreviousPckListValue == 'User'))
					setSelectUserId = new Set<String>();

				List<Id> lstTempId1 = new List<Id>();
				List<Id> lstTempId2 = new List<Id>();
				Id strTempId;
				strUserOrGroups = '';

				for(String strObj : lstStrUserOrGroups)
				{
					lstTempId1 = new List<Id>();
					lstTempId2 = new List<Id>();
					if(strUserOrGroup == 'Group' && mapUserIds.containskey(strObj)){
						lstTempId1.addAll(mapUserIds.get(strObj));
						strTempId = (lstTempId1.size() > 0) ? lstTempId1[0] : null;
						if(strTempId != null){
							mapUserIds.get(strObj).remove(strTempId);
							setSelectUserId.add(strTempId);
						}
					}
					else if(strUserOrGroup == 'User' && mapGroupIds.containskey(strObj)){
						lstTempId1.addAll(mapGroupIds.get(strObj));
						strTempId = (lstTempId1.size() > 0) ? lstTempId1[0] : null;
						if(strTempId != null){
							mapGroupIds.get(strObj).remove(strTempId);
							setSelectGroupId.add(strTempId);
						}
					}
					else if(strUserOrGroup == 'Firm' && mapUserIds.containskey(strObj)){
						lstTempId1.addAll(mapUserIds.get(strObj));
						strTempId = (lstTempId1.size() > 0) ? lstTempId1[0] : null;
						if(strTempId != null){
							mapUserIds.get(strObj).remove(strTempId);
							setSelectUserId.add(strTempId);
						}
					}

					if(strUserOrGroup == 'Group' && mapFirmIds.containskey(strObj)){
						lstTempId2.addAll(mapFirmIds.get(strObj));
						strTempId = (lstTempId2.size() > 0) ? lstTempId2[0] : null;
						if(strTempId != null){
							mapFirmIds.get(strObj).remove(strTempId);
							setSelectFirmId.add(strTempId);
						}
					}
					else if(strUserOrGroup == 'User' && mapFirmIds.containskey(strObj)){
						lstTempId2.addAll(mapFirmIds.get(strObj));
						strTempId = (lstTempId2.size() > 0) ? lstTempId2[0] : null;
						if(strTempId != null){
							mapFirmIds.get(strObj).remove(strTempId);
							setSelectFirmId.add(strTempId);
						}
					}
					else if(strUserOrGroup == 'Firm' && mapGroupIds.containskey(strObj)){
						lstTempId2.addAll(mapGroupIds.get(strObj));
						strTempId = (lstTempId2.size() > 0) ? lstTempId2[0] : null;
						if(strTempId != null){
							mapGroupIds.get(strObj).remove(strTempId);
							setSelectGroupId.add(strTempId);
						}
					}
				}

				if(strUserOrGroup == 'Group' )
				{
        			mapGroupIds = new Map<String, set<Id>>();
					
					for(Group objGroup : [Select Id, Email, DeveloperName, Type from Group where Type IN : setValidGroupTypes ORDER BY DeveloperName])
			        {
			        	if(!setRemovedGroups.contains(objGroup.DeveloperName))
						{
			        	
				        	if(setDuplicateIdentifier.Contains(objGroup.DeveloperName))
				        	{
				        		
				        		String strDeveloperName = '';
				        		strDeveloperName = objGroup.type +':'+objGroup.DeveloperName;
				        		
				        		if(!setSelectGroupId.Contains(objGroup.Id))
				            		lstUserOrGroup_Input.add(new SelectOption('PG : ' + strDeveloperName,  strDeveloperName));
					            else
					            	lstUserOrGroup_Output.add(new SelectOption('PG : ' + strDeveloperName,  strDeveloperName));
					            
				            	if(!mapGroupIds.containskey('PG : ' + strDeveloperName))
				            		mapGroupIds.put('PG : ' + strDeveloperName, new set<Id>{objGroup.Id});	
				            	else
			            		mapGroupIds.get('PG : ' + strDeveloperName).add(objGroup.Id);
				        	}
				        	else
				        	{
				        		setDuplicateIdentifier.add(objGroup.DeveloperName);
				        		String strDeveloperName = '';
				        		strDeveloperName = objGroup.DeveloperName;
				        		
				        		if(!setSelectGroupId.Contains(objGroup.Id))
				            		lstUserOrGroup_Input.add(new SelectOption('PG : ' + strDeveloperName,  strDeveloperName));
					            else
					            	lstUserOrGroup_Output.add(new SelectOption('PG : ' + strDeveloperName,  strDeveloperName));
					            
				            	if(!mapGroupIds.containskey('PG : ' + strDeveloperName))
				            		mapGroupIds.put('PG : ' + strDeveloperName, new set<Id>{objGroup.Id});	
				            	else
			            		mapGroupIds.get('PG : ' + strDeveloperName).add(objGroup.Id);
				        	}
				        	
						}
			        	
			        }
			        
				}
				else if(strUserOrGroup =='User')
				{
					mapUserIds = new Map<String, set<Id>>();

					for(User objUser : [Select Id, Name, FirstName, LastName, UserType from User where UserType = 'Standard' and IsActive = true ORDER BY Name])
					{
						if(!setSelectUserId.Contains(objUser.Id))
							lstUserOrGroup_Input.add(new SelectOption(objUser.LastName+', '+objUser.FirstName,  objUser.LastName+', '+objUser.FirstName));
						else
							lstUserOrGroup_Output.add(new SelectOption(objUser.LastName+', '+objUser.FirstName,  objUser.LastName+', '+objUser.FirstName));
						
		            	if(!mapUserIds.containskey(objUser.LastName+', '+objUser.FirstName))
		            		mapUserIds.put(objUser.LastName+', '+objUser.FirstName, new set<Id>{objUser.Id});	
		            	else
		            		mapUserIds.get(objUser.LastName+', '+objUser.FirstName).add(objUser.Id);	
					}
				}
				else if(strUserOrGroup =='Firm')
				{
					mapFirmIds = new Map<String, set<Id>>();
					for(Group objGroup : [Select Id, Email, DeveloperName, Type from Group where Type = 'Organization' ORDER BY DeveloperName])
			        {
			        	String strDeveloperName = '';
			        	strDeveloperName = objGroup.DeveloperName;
	        			strDeveloperName = strDeveloperName.substring(0,3)+' '+strDeveloperName.substring(3,11)+' '+strDeveloperName.substring(11,16);
	        			
	        			if(!setSelectFirmId.Contains(objGroup.Id))
		            		lstUserOrGroup_Output.add(new SelectOption('PG : ' + strDeveloperName,  strDeveloperName));
			            else
			            	lstUserOrGroup_Output.add(new SelectOption('PG : ' + strDeveloperName,  strDeveloperName));
			            
		            	if(!mapFirmIds.containskey('PG : ' + strDeveloperName))
		            		mapFirmIds.put('PG : ' + strDeveloperName, new set<Id>{objGroup.Id});	
		            	else
		            		mapFirmIds.get('PG : ' + strDeveloperName).add(objGroup.Id);	
		        	
			        }
				}
			}
			
			// This will execute only for Edit button(editing existing List record)
			else if(isEdit == true)
			{
				// add all selected Ids
				if(isPageLoad == false)
				{
					if(UserInfo.getProfileId() == adminProfileId || objList.OwnerId == UserInfo.getUserId())
					{
						isRecordOwner = true;
					}
					else
					{
						for(Company_List__Share objShare : [Select UserOrGroupId, ParentId, AccessLevel From Company_List__Share c Where ParentId=:objList.Id AND UserOrGroupId=:Userinfo.getUserId() ])
						{
							if(objShare.AccessLevel == 'All' )
							{
								isRecordOwner = true;
							}
							else
							{
								isRecordOwner = false;
							}
						}
					}
					oldOwnerId = objList.OwnerId;
					setSelectUserOrGroupId = new Set<String>();
					setSelectUserOrGroupId.addAll(setSelectGroupId);
					setSelectUserOrGroupId.addAll(setSelectUserId);
					setSelectUserOrGroupId.addAll(setSelectFirmId);
					
					if((strUserOrGroup == 'User' && strPreviousPckListValue == 'Group') || (strUserOrGroup == 'Firm' && strPreviousPckListValue == 'Group'))
						setSelectGroupId = new Set<String>();
					else if((strUserOrGroup == 'User' && strPreviousPckListValue == 'Firm') || (strUserOrGroup == 'Group' && strPreviousPckListValue == 'Firm'))
						setSelectFirmId = new Set<String>();	
					else if((strUserOrGroup == 'Group' && strPreviousPckListValue == 'User') || (strUserOrGroup == 'Firm' && strPreviousPckListValue == 'User'))
						setSelectUserId = new Set<String>();
	
					List<Id> lstTempId1 = new List<Id>();
					List<Id> lstTempId2 = new List<Id>();
					Id strTempId;
					strUserOrGroups = '';
	
					for(String strObj : lstStrUserOrGroups)
					{
						lstTempId1 = new List<Id>();
						lstTempId2 = new List<Id>();
						if(strUserOrGroup == 'Group' && mapUserIds.containskey(strObj)){
							lstTempId1.addAll(mapUserIds.get(strObj));
							strTempId = (lstTempId1.size() > 0) ? lstTempId1[0] : null;
							if(strTempId != null){
								mapUserIds.get(strObj).remove(strTempId);
								setSelectUserId.add(strTempId);
							}
						}
						else if(strUserOrGroup == 'User'  && mapGroupIds.containskey(strObj)){
							lstTempId1.addAll(mapGroupIds.get(strObj));
							strTempId = (lstTempId1.size() > 0) ? lstTempId1[0] : null;
							if(strTempId != null){
								mapGroupIds.get(strObj).remove(strTempId);
								setSelectGroupId.add(strTempId);
							}
						}
						else if(strUserOrGroup == 'Firm' && mapUserIds.containskey(strObj)){
							lstTempId1.addAll(mapUserIds.get(strObj));
							strTempId = (lstTempId1.size() > 0) ? lstTempId1[0] : null;
							if(strTempId != null){
								mapUserIds.get(strObj).remove(strTempId);
								setSelectUserId.add(strTempId);
							}
						}
	
						if(strUserOrGroup == 'Group' && mapFirmIds.containskey(strObj)){
							lstTempId2.addAll(mapFirmIds.get(strObj));
							strTempId = (lstTempId2.size() > 0) ? lstTempId2[0] : null;
							if(strTempId != null){
								mapFirmIds.get(strObj).remove(strTempId);
								setSelectFirmId.add(strTempId);
							}
						}
						else if(strUserOrGroup == 'User' && mapFirmIds.containskey(strObj)){
							lstTempId2.addAll(mapFirmIds.get(strObj));
							strTempId = (lstTempId2.size() > 0) ? lstTempId2[0] : null;
							if(strTempId != null){
								mapFirmIds.get(strObj).remove(strTempId);
								setSelectFirmId.add(strTempId);
							}
						}
						else if(strUserOrGroup == 'Firm' && mapGroupIds.containskey(strObj)){
							lstTempId2.addAll(mapGroupIds.get(strObj));
							strTempId = (lstTempId2.size() > 0) ? lstTempId2[0] : null;
							if(strTempId != null){
								mapGroupIds.get(strObj).remove(strTempId);
								setSelectGroupId.add(strTempId);
							}
						}
					}
				}	

				// on page load only
				if(isPageLoad == true)
				{
					if(UserInfo.getProfileId() == adminProfileId || objList.OwnerId == UserInfo.getUserId())
					{
						isRecordOwner = true;
					}
					else
					{
						for(Company_List__Share objShare : [Select UserOrGroupId, ParentId, AccessLevel From Company_List__Share c Where ParentId=:objList.Id AND UserOrGroupId=:Userinfo.getUserId() ])
						{
							if(objShare.AccessLevel == 'All' )
							{
								isRecordOwner = true;
							}
							else
							{
								isRecordOwner = false;
							}
						}
					}
					oldOwnerId = objList.OwnerId;
					// find all the existing share for the Conatct List record
					for(Company_List__Share objShareList :[Select Id, UserOrGroupId, AccessLevel from Company_List__Share where ParentId = :objList.Id])
					{
						setUserOrGroupId.add(objShareList.UserOrGroupId);
						strSecurityAccessLevel = objShareList.AccessLevel;

						if(String.valueOF(objShareList.UserOrGroupId).substring(0,3) == '00G')
							setSelectGroupId.add(objShareList.UserOrGroupId);
						else if(String.valueOF(objShareList.UserOrGroupId).substring(0,3) == '005')
							setSelectUserId.add(objShareList.UserOrGroupId);
					}
					for(Group objGroup : [Select Id, Email, DeveloperName, Type from Group where Type = 'Organization' and Id IN : setSelectGroupId ORDER BY DeveloperName])
			        {
			        	setSelectFirmId.add(objGroup.Id);
			        	setSelectGroupId.remove(objGroup.Id);
			        }
					if(!setUserOrGroupId.IsEmpty())
						setSelectUserOrGroupId.addAll(setUserOrGroupId);
					isPageLoad = false;
				}
				
				if(strUserOrGroup == 'Group' )
				{
					mapGroupIds = new Map<String, set<Id>>();
					setDuplicateIdentifier = new Set<String>();
					for(Group objGroup : [Select Id, Email, DeveloperName, Type from Group where Type IN : setValidGroupTypes ORDER BY DeveloperName])
			        {
			        	if(!setRemovedGroups.contains(objGroup.DeveloperName))
						{
							if(setDuplicateIdentifier.Contains(objGroup.DeveloperName))
				        	{
				        		String strDeveloperName = '';
				        	
				        		strDeveloperName = objGroup.type+':'+objGroup.DeveloperName;
				        					        		
				        		if(!setSelectGroupId.Contains(objGroup.Id))
				            	lstUserOrGroup_Input.add(new SelectOption('PG : ' + strDeveloperName,  strDeveloperName));
					            else if(setSelectGroupId.Contains(objGroup.Id))
					            	lstUserOrGroup_Output.add(new SelectOption('PG : ' + strDeveloperName,  strDeveloperName));
					            	
					            if(!mapGroupIds.containskey('PG : ' + strDeveloperName))
				            		mapGroupIds.put('PG : ' + strDeveloperName, new set<Id>{objGroup.Id});	
				            	else
				            		mapGroupIds.get('PG : ' + strDeveloperName).add(objGroup.Id);
				        		
				        	}
				        	else
				        	{
				        		setDuplicateIdentifier.add(objGroup.DeveloperName);
				        		String strDeveloperName = '';
				        	
				        		strDeveloperName = objGroup.DeveloperName;
				        					        		
				        		if(!setSelectGroupId.Contains(objGroup.Id))
				            	lstUserOrGroup_Input.add(new SelectOption('PG : ' + strDeveloperName,  strDeveloperName));
					            else if(setSelectGroupId.Contains(objGroup.Id))
					            	lstUserOrGroup_Output.add(new SelectOption('PG : ' + strDeveloperName,  strDeveloperName));
					            	
					            if(!mapGroupIds.containskey('PG : ' + strDeveloperName))
				            		mapGroupIds.put('PG : ' + strDeveloperName, new set<Id>{objGroup.Id});	
				            	else
				            		mapGroupIds.get('PG : ' + strDeveloperName).add(objGroup.Id);
				        		
				        	}
							
						}	
							
			        	
			        }
				}
				else if(strUserOrGroup =='User')
				{
					mapUserIds = new Map<String, set<Id>>();
					
					for(User objUser : [Select Id, Name, FirstName, LastName, UserType from User where Id != :objList.OwnerId and IsActive = true and UserType = 'Standard' ORDER BY Name])
					{
						if(!setSelectUserId.Contains(objUser.Id))
							lstUserOrGroup_Input.add(new SelectOption(objUser.LastName+', '+objUser.FirstName,  objUser.LastName+', '+objUser.FirstName));
						else if(setSelectUserId.Contains(objUser.Id))
							lstUserOrGroup_Output.add(new SelectOption(objUser.LastName+', '+objUser.FirstName,  objUser.LastName+', '+objUser.FirstName));
							
						if(!mapUserIds.containskey(objUser.LastName+', '+objUser.FirstName))
		            		mapUserIds.put(objUser.LastName+', '+objUser.FirstName, new set<Id>{objUser.Id});	
		            	else
		            		mapUserIds.get(objUser.LastName+', '+objUser.FirstName).add(objUser.Id);		
					}
				}
				else if(strUserOrGroup =='Firm')
				{
					mapFirmIds = new Map<String, set<Id>>();
					for(Group objGroup : [Select Id, Email, DeveloperName, Type from Group where Type = 'Organization' ORDER BY DeveloperName])
			        {
			        	String strDeveloperName = '';
			        	strDeveloperName = objGroup.DeveloperName;
	        			strDeveloperName = strDeveloperName.substring(0,3)+' '+strDeveloperName.substring(3,11)+' '+strDeveloperName.substring(11,16);
	        			
	        			if(!setSelectFirmId.Contains(objGroup.Id))
		            		lstUserOrGroup_Input.add(new SelectOption('PG : ' + strDeveloperName,  strDeveloperName));
			            else
			            	lstUserOrGroup_Output.add(new SelectOption('PG : ' + strDeveloperName,  strDeveloperName));
			            
		            	if(!mapFirmIds.containskey('PG : ' + strDeveloperName))
		            		mapFirmIds.put('PG : ' + strDeveloperName, new set<Id>{objGroup.Id});	
		            	else
		            		mapFirmIds.get('PG : ' + strDeveloperName).add(objGroup.Id);	
		        	
			        }
				}  
			}
			
			strPreviousPckListValue = strUserOrGroup;
		}
		catch(Exception ex){
			// do nothing.
		}
	}
	/*End - fetchUserOrTGroupPicklistValues method */
	
	
	/*Start - fetchCurrentUserOrGroupPicklistValues method will called on page  load and on each time when user changes the share with User/Group picklist*/
	public void fetchCurrentUserOrGroupPicklistValues()
	{
		system.debug('---------strUserOrGroups------'+strUserOrGroups);
		try{
			String strMultiPicklistValue = '';
			
		    if(strUserOrGroups != null && strUserOrGroups != '' && strUserOrGroups != 'Empty' && strUserOrGroups.length() > 1) 
		    {
		    	for(String strValue : strUserOrGroups.substring(0,strUserOrGroups.length()-2).split('<>'))
		    		strMultiPicklistValue += strValue+';';
		    }
		    else if(strUserOrGroups != 'Empty') 
		    	strMultiPicklistValue = '';
			
			//Creating list of selected User Or Groups ids.
		    List<String> lstStrUserOrGroups = new List<String>();
		    if(strMultiPicklistValue != '' && strMultiPicklistValue != null)
		    	lstStrUserOrGroups = strMultiPicklistValue.split(';');
			
			if(strUserOrGroup == 'User')
				setSelectUserId = new Set<String>();	
			else if(strUserOrGroup == 'Group')
				setSelectGroupId = new Set<String>();
			else if(strUserOrGroup == 'Firm')
				setSelectFirmId = new Set<String>();		
			
			
			List<Id> lstTempId1 = new List<Id>();
			Id strTempId;
			for(String strObj : lstStrUserOrGroups)
			{
				lstTempId1 = new List<Id>();
				if(strUserOrGroup == 'Group' && mapGroupIds.containskey(strObj)){
					lstTempId1.addAll(mapGroupIds.get(strObj));
					strTempId = (lstTempId1.size() > 0) ? lstTempId1[0] : null;
					if(strTempId != null){
						mapGroupIds.get(strObj).remove(strTempId);
						setSelectGroupId.add(strTempId);
					}
				}
				else if(strUserOrGroup == 'User' && mapUserIds.containskey(strObj)){
					lstTempId1.addAll(mapUserIds.get(strObj));
					strTempId = (lstTempId1.size() > 0) ? lstTempId1[0] : null;
					if(strTempId != null){
						mapUserIds.get(strObj).remove(strTempId);
						setSelectUserId.add(strTempId);
					}
				}
				else if(strUserOrGroup == 'Firm' && mapFirmIds.containskey(strObj)){
					lstTempId1.addAll(mapFirmIds.get(strObj));
					strTempId = (lstTempId1.size() > 0) ? lstTempId1[0] : null;
					if(strTempId != null){
						mapFirmIds.get(strObj).remove(strTempId);
						setSelectFirmId.add(strTempId);
					}
				}
			}	
			
			setSelectUserOrGroupId = new Set<String>();
			setSelectUserOrGroupId.addAll(setSelectGroupId);
			setSelectUserOrGroupId.addAll(setSelectUserId);
			setSelectUserOrGroupId.addAll(setSelectFirmId);
		}
		catch(Exception ex){
			//Do nothing
		}
	}
	
	
	/*Start - btnSave method */
	public pageReference btnSave()
	{
		List<Company_List__Share> lstContactListShare_Insert = new List<Company_List__Share>();  
		List<Company_List__Share> lstContactListShare_Delete = new List<Company_List__Share>();
		try
		{
			
			if(objList.Name == null || objList.Name == '')
			{
				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Name is Required field.');
            	ApexPages.addMessage(myMsg);
            	return null;
			}
			// Save the Contact list 
			if(objList != null)
				upsert objList;
			
			// This snippet to delete existing share, so we dont need this to execute on creating new share record
			if(isEdit == true)
			{
				/* start - delete all existing share*/   
				for(Company_List__Share objShareList : [Select Id from Company_List__Share where ParentId = :objList.Id])
				{
					lstContactListShare_Delete.add(objShareList);
				}
				
				// delete all existing shares
				if(!lstContactListShare_Delete.IsEmpty())
					database.delete(lstContactListShare_Delete, false);
				/* stop - delete all existing share*/
			}
			system.debug('--------11-strUserOrGroups------'+strUserOrGroups);
			// get current select Group/User list 
			fetchCurrentUserOrGroupPicklistValues();
			
			Boolean isGroupPresent = false;
			Set<String> setLocalGroups = new Set<String>();
			Set<String> setLocalUsers = new Set<String>();
			
			for(String strSelectedUserOrGroupId : setSelectUserOrGroupId)
			{
				if(strSelectedUserOrGroupId != objList.OwnerId)
				{
					if(strSelectedUserOrGroupId.startsWith('00G'))
					{
						isGroupPresent = true;
						setLocalGroups.add(strSelectedUserOrGroupId);
					}
					else if(strSelectedUserOrGroupId.startsWith('005'))
						setLocalUsers.add(strSelectedUserOrGroupId);
				}
			}
			
			if(isGroupPresent)
			{
				for(String strSelectedUserOrGroupId : setLocalGroups)
				{
					Company_List__Share objContactListShare = new Company_List__Share(parentId = objList.Id, AccessLevel = strSecurityAccessLevel, UserOrGroupId = strSelectedUserOrGroupId);
					lstContactListShare_Insert.add(objContactListShare);
				}	
			}
			
			system.debug('======1=====lstContactListShare_Insert============'+lstContactListShare_Insert);
			if(!lstContactListShare_Insert.isEmpty())  Database.insert( lstContactListShare_Insert, false);
			system.debug('======2=====lstContactListShare_Insert============'+lstContactListShare_Insert);
			
			lstContactListShare_Insert = new List<Company_List__Share>();  
			
			if(!setLocalUsers.isEmpty())
			{
				for(String strSelectedUserOrGroupId : setLocalUsers)
				{
					Company_List__Share objContactListShare = new Company_List__Share(parentId = objList.Id, AccessLevel = strSecurityAccessLevel, UserOrGroupId = strSelectedUserOrGroupId);
					lstContactListShare_Insert.add(objContactListShare);
				}
			}
			system.debug('======3=====lstContactListShare_Insert============'+lstContactListShare_Insert);
			if(!lstContactListShare_Insert.isEmpty())   Database.insert (lstContactListShare_Insert, false);
			system.debug('======4=====lstContactListShare_Insert============'+lstContactListShare_Insert);
			
			/*=============================================*/
			for(Company_List__Share obj : [Select Id, ParentId, AccessLevel, LastModifiedDate  
	    										From Company_List__Share
	    										Where ParentId = :objList.Id])
			{
				system.debug('======================11=========================='+obj.ParentId);
				system.debug('======================12=========================='+obj.AccessLevel);
				system.debug('======================13==========================='+obj.LastModifiedDate);
			}
			
			/*==============================================*/
			
			if(objList.OwnerId !=oldOwnerId)
			{
				Schema.DescribeSObjectResult R = Company_List__c.SObjectType.getDescribe();
				PageReference page_ref = new PageReference('/'+R.getKeyPrefix());
	            page_ref.setRedirect(true);
				return page_ref;
			}
			
			PageReference page_ref = new PageReference('/'+objList.Id);
            page_ref.setRedirect(true);
			return page_ref;
		}
		catch(Exception ex){
			return null;
		}
	}
	/*End - btnSave method */
	
	
	/*Start - btnCamcel method will return the user to list detail page]*/
	public pagereference btnCancel()
	{
		PageReference page_ref = new PageReference('/'+strReturnURL);
		page_ref.setRedirect(true);
		return page_ref;
		
	}
	/*End - btnCamcel method */
	
	
	/* Start - Method for getting left side multiselect picklist values.
	   @Name           - getunselectedItems
	   @Parameters     - None 
	   @Return Type    - List
	   @Description    - Function for getting left side multiselect picklist values.
	*/
  	public List<SelectOption> getunselectedItems() 
  	{
	    try{
		    List<SelectOption> options = new List<SelectOption>();
		    for(SelectOption strObj : lstUserOrGroup_Input)
		    {
		    	options.add(new SelectOption(strObj.getValue(),strObj.getLabel()));
		    }
		    
		    return options;
	    }
	    catch(Exception e){
	    	return null;
	    }
  	}
  	/* End : getunselectedItems */
  	
	
	/* Start - Method for getting Right side multiselect picklist values.
	   @Name           - getSelectedItems
	   @Parameters     - None 
	   @Return Type    - List
	   @Description    - Function for getting Right side multiselect picklist values.
	*/
  	public List<SelectOption> getSelectedItems() 
  	{
	    try{
		    List<SelectOption> options = new List<SelectOption>();
		    for(SelectOption strObj : lstUserOrGroup_Output)
		    {
		    	options.add(new SelectOption(strObj.getValue(),strObj.getLabel()));
		    }
		    
		    return options;
	    }
	    catch(Exception e){
	    	return null;
	    }
  	}
  	/* End : getSelectedItems */
}