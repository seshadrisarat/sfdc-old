/**
* \arg ClassName      : SL_ManageMassGroupMembers
* \arg JIRATicket     : AMSEC-12
* \arg CreatedOn      : 31/MARCH/2015
* \arg LastModifiedOn : 25/MAY/2015
* \arg CreatededBy    : Lodhi
* \arg ModifiedBy     : Lodhi
* \arg Description    : Controller class for SL_ManageMassGroupMembers page.
*/
public without sharing class SL_ManageMassGroupMembers 
{
	/* Start variables */
	public List<GroupMemberWrapper> lstGroupMemberWrapper	        {	get;set;	}
	public List<ColumnWrapper> lstContactColumnWrapper              {	get;set;	}
	public List<ColumnWrapper> lstWGMColumnWrapper                  {	get;set;	}
	public List<External_Working_Group_Member__c>  lstEWGMember     {   get;set;    } 
	public Id parentId										        {	get;set;	}
	public Boolean isEditAll								        {	get;set;	}
	public Boolean isHaveAccess								        {	get;set;	}
	public Boolean isShowTypeAhead                                  {	get;set;	}
	public Boolean isAllowMassEdit                                  {	get;set;	}
	public Boolean isAllowToDeactivate                              {	get;set;	}
	public String strContactId                                      {	get;set;	}
	public String strContactName                                    {	get;set;	}     
	public Set<Id> setExistingContactId;
	public Set<Id> setContactId;
	public Set<String> setUserOrRoleId;
	public Set<String> setMemberIds;
	public Set<String> setFullAccessUserIds;
	public String parentObjectAPIName;
	public String strContactFields;
	private static Map<String, Schema.SObjectType> mapGlobalDescribe = Schema.getGlobalDescribe();
	/* End variables */
	
	private Boolean isPortfolioProject; 
	
	/*Start constructor*/   
	public SL_ManageMassGroupMembers()
	{   
		try
		{
		    initialization();
		    String parentIDString = '';
		    if(Apexpages.currentPage().getParameters().containsKey('parentId'))
		    {
		    	parentIDString=Apexpages.currentPage().getParameters().get('parentId');
		    }
		    if(parentIdString!='')
		    {
		    	System.debug(parentIdString);
		    	List<String> splitString = new List<String>();
		    	if(parentIDString.contains('?'))
		    	{
		    		splitString = parentIDString.split('\\?');
		    	}
		    	if(splitString.size()>0)
		    		parentID = splitString[0];
		    	else
		    		parentID = parentIdString;
			/*parentId = (Apexpages.currentPage().getParameters().containsKey('parentId') && Apexpages.currentPage().getParameters().get('parentId') != '') 
			           ? Apexpages.currentPage().getParameters().get('parentId')
			           : null ;*/
			}
			if(parentId == null)
			{
			    isHaveAccess = true;
			    return;
			}
			
			if(Apexpages.currentPage().getParameters().containsKey('isDeactivate'))
			{
			    isAllowToDeactivate = true ;
			    return;
			}
			
			isEditAll = (Apexpages.currentPage().getParameters().containsKey('isEditAll')) ? true : false;
			parentObjectAPIName = (parentId.getSobjectType() == Deal__c.getSobjectType()) 
			                       ? 'Deal__c' 
			                       : (parentId.getSobjectType() == Account.getSobjectType()) 
			                       ? 'Company__c' 
			                       : 'AS_Project__c';
			
			/* Added for AMSEC-302 */
			if(parentObjectAPIName == 'AS_Project__c' && parentId != null && !isEditAll) 
			{
			    List<AS_Project__c> lstASProject = [SELECT Portfolio_Company__r.Recordtype.DeveloperName 
        			                                  FROM AS_Project__c
        			                                 WHERE Id =: parentId];
                
                if(!lstASProject.isEmpty())
                    isPortfolioProject = (lstASProject[0].Portfolio_Company__r.Recordtype.DeveloperName == 'Portfolio_Company')
                                         ? true : false;
			}
			/* Added for AMSEC-302 */
			
		    setFullAccessUserIds = checkPublicGroupMemberAccessiblity('fullaccess');
            lstGroupMemberWrapper = prepareGroupMemberWrapper();			                       
			
			if(parentObjectAPIName == 'Company__c')
			{
			    setMemberIds = checkPublicGroupMemberAccessiblity('AS_Project__c');
			    ShowTypeAheadCompany__c objDTACompany = ShowTypeAheadCompany__c.getInstance('Show Type Ahead');
			    if(objDTACompany != null && objDTACompany.DisplayTypeAhead__c)
			        isShowTypeAhead = true;       
			}
			else if(parentObjectAPIName == 'Deal__c')
			{
			    setMemberIds = checkPublicGroupMemberAccessiblity('AS_Project__c');
			    ShowTypeAheadInvOpp__c objDTAInvOpp = ShowTypeAheadInvOpp__c.getInstance('Show Type Ahead');
			    if(objDTAInvOpp != null && objDTAInvOpp.DisplayTypeAhead__c)
			        isShowTypeAhead = true;    
			}
			else 
			{
			    setMemberIds = checkPublicGroupMemberAccessiblity('Deal__c');
			    ShowTypeAheadASProject__c objDTAProject = ShowTypeAheadASProject__c.getInstance('Show Type Ahead');
			    if(objDTAProject != null && objDTAProject.DisplayTypeAhead__c)
			        isShowTypeAhead = true;    
			}
			
			Id profileId = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
			if(setMemberIds.contains(UserInfo.getUserId()) || profileId == UserInfo.getProfileId() || setFullAccessUserIds.contains(UserInfo.getUserId()))
			    isHaveAccess = true;
            else
                isHaveAccess = false;
		}
		catch(Exception ex)
		{
			System.debug('=====ex===='+ex.getLineNumber()+'======='+ex);   
		}
	}
	/*End constructor*/
	
	/*
        * MethodName	: initialization()
        * param			: NA
        * Description	: This method is used for initialize the variables. 
 	*/
	private void initialization()
	{
        lstGroupMemberWrapper = new List<GroupMemberWrapper>(); 
		lstEWGMember = new List<External_Working_Group_Member__c>();
		lstContactColumnWrapper = new List<columnWrapper>();
		lstWGMColumnWrapper = new List<columnWrapper>();
		setExistingContactId = new Set<Id>();
		setContactId = new Set<Id>(); 
		setUserOrRoleId = new Set<String>();
		setMemberIds = new Set<String>();
		setFullAccessUserIds = new Set<String>();
		isAllowMassEdit = false;
		isShowTypeAhead = false;
		isHaveAccess = false;
		isAllowToDeactivate = false;
		isPortfolioProject = false;//AMSEC-302
		strContactId = '';
		strContactName = '';
		strContactFields = '';
	}
	/* End */
	
	/* Start - Group Member Wrapper Class */ 
	public class GroupMemberWrapper
	{
		public Contact contact								{	get;set;	}
		public External_Working_Group_Member__c	EWGMember	{	get;set;	}
		public Boolean isSelected							{	get;set;	}
		
		public GroupMemberWrapper(External_Working_Group_Member__c	EWGMember, Contact contact, Id parentRecordId, String strParentApiName)
		{
			this.contact = contact;
			this.EWGMember = EWGMember;
			this.EWGMember.put(strParentApiName, parentRecordId);
			this.isSelected = false;
		}
	}
	/* End - Group Member Wrapper Class */
	
	/* Start - Column Wrapper Class */ 
	public class ColumnWrapper
	{
	    public String strFieldLabel    {   get;set;    }
	    public String strFieldAPI      {   get;set;    }
	    public String strFieldType     {   get;set;    }
	    
	    public ColumnWrapper(String strFieldLabel, String strFieldAPI, String strFieldType)
	    {
	        this.strFieldLabel = strFieldLabel;
	        this.strFieldAPI = strFieldAPI;
	        this.strFieldType = strFieldType;
	    }
	}
	/* End - Column Wrapper Class */ 
	
	/*
        * MethodName	: checkAccessiblity()
        * param			: Parent object api name
        * Description	: This method is used for checking the accessiblity of the user. 
 	*/
	public static Set<String> checkPublicGroupMemberAccessiblity(String parentObjectAPIName)
	{
	    String strGroupName = '';
	    String strUserRole = '';
        Set<String> setGroupMemberId = new Set<String>();
	    
	    if(parentObjectAPIName == 'AS_Project__c')
	    {
	        strGroupName = 'Resource_Group';
	        strUserRole = 'Resource_Group_Member';
	    }
	    else if(parentObjectAPIName == 'fullaccess')
	    {
	        strGroupName = 'Data_Managers';
	        strUserRole = '';
	    }
	    else
	    {
	        strGroupName = 'Investment_Team_Members';
	        strUserRole = 'Investment_Team_Member';
	    }   
        
        //Fetching all the group member records from Default_Diligence_Project_Members public group
        for(GroupMember objGroupMember : [SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName =: strGroupName])
        {
            setGroupMemberId.add(objGroupMember.UserOrGroupId);
        }
        
        //Fetching all the group member records from groups containing another group
        for(GroupMember objGroupMember : [SELECT UserOrGroupId FROM GroupMember WHERE GroupId IN : setGroupMemberId])
        {
            setGroupMemberId.add(objGroupMember.UserOrGroupId);
        }
        
        //Iterating over Group object to get all the user associated with it
        for(Group objGroup : [SELECT RelatedId FROM Group WHERE RelatedId != null AND Id IN : setGroupMemberId])
        {
            setGroupMemberId.add(objGroup.RelatedId);
        }
        // for(Group objGroup : Database.query('SELECT Id, RelatedId FROM Group WHERE RelatedId != null AND DeveloperName = \'' + strGroupName + '\''))
        // {
        //     setGroupMemberId.add(objGroup.RelatedId);
        // }
        
        //Iterating on user to get all the user based on the role exist in the public group
        for(User objUser : [SELECT Id FROM User WHERE UserRoleId IN : setGroupMemberId])
        {
            setGroupMemberId.add(objUser.Id);
        }
        // for(UserRole objUserRole : Database.query('SELECT Id, (SELECT Id FROM Users) FROM UserRole WHERE DeveloperName = \'' + strUserRole + '\''))
        // {
        //     for(User objUser : objUserRole.Users)
        //     {
        //         setGroupMemberId.add(objUser.Id);
        //     }
        // }
	    return setGroupMemberId;
	}
	/* End */
	
	/*
        * MethodName	: prepareGroupMemberWrapper()
        * param			: NA
        * Description	: This method is used for preparing list of GroupMemberWrapper. 
 	*/
	private List<GroupMemberWrapper> prepareGroupMemberWrapper()
	{
		List<GroupMemberWrapper> lstGroupMemberWrapper = new List<GroupMemberWrapper>();
		//Execute only if click on the Edit All Button from External_Working_Group_Member__c related list 
		if(isEditAll)
		{
		    isAllowMassEdit = true;
		    Set<Id> setUserIdToAllowMassEdit = new Set<Id>();
		    Id profileId = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
		    
		    //Iterating over GroupMembers to check if the contact.
            for(GroupMember objGroupMember : [SELECT Id, 
                                                     UserOrGroupId  
                                                FROM GroupMember 
                                               WHERE Group.DeveloperName = 'Mass_Edit_WG_Users'])
            {
                setUserIdToAllowMassEdit.add(objGroupMember.UserOrGroupId);
            }
		    
		    if(setUserIdToAllowMassEdit.contains(UserInfo.getUserId()) || profileId == UserInfo.getProfileId() || setFullAccessUserIds.contains(UserInfo.getUserId()))
		    {
    		    String strFieldSetName = (parentObjectAPIName == 'Deal__c') 
    		                              ? 'WGMDealEdit' 
    		                              : (parentObjectAPIName == 'Company__c') 
    		                              ? 'WGMPortfolioEdit'
    		                              : 'WGMProjectEdit';	
    		  //  String strContactFields = '';
    		    for(SelectOption objOption : getFieldOptions(strFieldSetName))
                {
                    strContactFields += ',' + objOption.getValue();
                    
                    if(objOption.getValue().contains('.'))
                        lstWGMColumnWrapper.add(new ColumnWrapper(objOption.getLabel(), objOption.getValue(), 'reference'));
                    else
                        lstWGMColumnWrapper.add(new ColumnWrapper(objOption.getLabel(), objOption.getValue(), 'other'));
                        
                }
                strContactFields = strContactFields.replaceFirst(',','');
    		    
    		    lstEWGMember = Database.query('SELECT '+ strContactFields + ' FROM External_Working_Group_Member__c WHERE '
    										           + parentObjectAPIName + '=\'' +parentId+ '\'');
		        
		    }
		    else
		    {
		        isAllowMassEdit = false;
		    }
	    }
		else
		{
		    String strFieldSetName = (parentObjectAPIName == 'Deal__c') 
		                              ? 'WGMDealAdd' 
		                              : (parentObjectAPIName == 'Company__c')
		                              ? 'WGMPortfolioAdd'
		                              : 'WGMProjectAdd'; 
            String strGroupName = (parentObjectAPIName == 'AS_Project__c') ? 'Resource_Group' : 'Investment_Team_Members';
            String strUserRole = (parentObjectAPIName == 'AS_Project__c') ? 'Resource_Group_Member' : 'Investment_Team_Member';
		    
		    //Iterating over fieldset options to prepare list of columnWrapper for contact and working group members
		    for(SelectOption objOption : getFieldOptions(strFieldSetName))
            {
                if(objOption.getValue().contains('Contact__r'))
                {
                    strContactFields += ',' + objOption.getValue().split('\\.')[1];
                    lstContactColumnWrapper.add(new ColumnWrapper(objOption.getLabel(), objOption.getValue().split('\\.')[1], 'reference'));
                }    
                else
                {
                    if(objOption.getValue().contains('.'))
                        lstWGMColumnWrapper.add(new ColumnWrapper(objOption.getLabel(), objOption.getValue(), 'reference'));
                    else
                        lstWGMColumnWrapper.add(new ColumnWrapper(objOption.getLabel(), objOption.getValue(), 'other'));
                }
                    
            }
            strContactFields = strContactFields.replaceFirst(',','');
		    
		    //Iterating on External_Working_Group_Member__c to get the set of contact ids
			for(External_Working_Group_Member__c objEWGMember : Database.query('SELECT Id, Contact__c FROM ' 
																				 + 'External_Working_Group_Member__c WHERE '
																				 + parentObjectAPIName + '=\'' +parentId+ '\''
																				 + ' AND Contact__c != NULL'))
			{
				setContactId.add(objEWGMember.Contact__c);
			}
			
            //Iterating over GroupMembers to check if the contact.
            for(GroupMember objGroupMember : Database.query('SELECT Id, UserOrGroupId  FROM GroupMember '+ 
                                                            'WHERE Group.DeveloperName = \''+ strGroupName + '\''))
            {
                setUserOrRoleId.add(objGroupMember.UserOrGroupId);
            }
            
            //Fetching all the group member records from groups containing another group
            for(GroupMember objGroupMember : [SELECT UserOrGroupId FROM GroupMember WHERE GroupId IN : setUserOrRoleId])
            {
                setUserOrRoleId.add(objGroupMember.UserOrGroupId);
            }
            
            // for(GroupMember objGroupMember : Database.query('SELECT Id, UserOrGroupId  FROM GroupMember '+ 
            //                                                 'WHERE Group.DeveloperName = \''+ strGroupName + '\''))
            // {
            //     setUserOrRoleId.add(objGroupMember.UserOrGroupId);
            // }
            
            //Iterating over Group object to get all the user associated with it
            for(Group objGroup : [SELECT RelatedId FROM Group WHERE RelatedId != null AND Id IN : setUserOrRoleId])
            {
                setUserOrRoleId.add(objGroup.RelatedId);
            }
            
            //Iterating on user to get all the user based on the role exist in the public group
            for(User objUser : [SELECT Id FROM User WHERE UserRoleId IN : setUserOrRoleId])
            {
                setUserOrRoleId.add(objUser.Id);
            }
            
            // for(UserRole objUserRole : Database.query('SELECT Id, (SELECT Id FROM Users) FROM UserRole WHERE DeveloperName = \'' + strUserRole + '\''))
            // {
            //     for(User objUser : objUserRole.Users)
            //     {
            //         setUserOrRoleId.add(objUser.Id);
            //     }
            // }
            
			//Iterating on contact which are not on the External_Working_Group_Member__c related list
			for(Contact objContact : Database.query('SELECT '+ strContactFields + ', Salesforce_User__c FROM Contact WHERE RecordType.Name = \'AS Employee\' '+
	                                                'AND Salesforce_User__r.IsActive = true ANd Active_Employee__c =true AND Id NOT IN : setContactId '))
	        {
	        	
	            if(setUserOrRoleId.contains(objContact.Salesforce_User__c)&& !setExistingContactId.contains(objContact.ID))
	            {
	            	System.debug(objContact);
	                setExistingContactId.add(objContact.Id);
                    if(parentObjectAPIName == 'Deal__c' || parentObjectAPIName == 'Company__c')
	        	        lstGroupMemberWrapper.add(new GroupMemberWrapper(new External_Working_Group_Member__c(Contact__c = objContact.Id, Role__c = 'AS Investment Team'), 
	        	                                                         objContact, parentId, parentObjectAPIName));
	        	    else
                        lstGroupMemberWrapper.add(new GroupMemberWrapper(new External_Working_Group_Member__c(Contact__c = objContact.Id, Role__c = 'AS Resource'), 
                                                                         objContact, parentId, parentObjectAPIName));	        	    
	            }	  
	        }
		}
		return lstGroupMemberWrapper;
	}
	/* End */
	
	
	/*
        * MethodName	: getFieldOptions()
        * param			: NA
        * Description	: This method is used for preparing list of selectoptions from fieldset. 
 	*/
 	public void addGroupMember()
 	{
 	    if(setContactId.contains(strContactId.trim()))
 	    {
 	        String strMessage = strContactName + ' is already a member. Please select other contact to add in the Working group member list';
 	        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, strMessage));
 	        return;
 	    }
 	    if(setExistingContactId.contains(strContactId.trim()))
 	    {
 	        String strMessage = strContactName + ' is already present in the working group member list. Please select other contact to add in the Working group member list';
 	        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, strMessage));
 	        return;
 	    }
 	    
 	    for(Contact objContact : Database.query('SELECT '+ strContactFields + ', Salesforce_User__c FROM Contact ' +
 	                                            'WHERE Id = \'' + strContactId.trim() +'\' AND Id NOT IN : setExistingContactId'))
        { 	                                            
 	        if(!setExistingContactId.contains(objContact.Id))
 	        {
 	            setExistingContactId.add(objContact.Id);
 	            if(parentObjectAPIName == 'Deal__c' || parentObjectAPIName == 'Company__c') 
 	            {   
 	                if(setUserOrRoleId.contains(objContact.Salesforce_User__c))
         	            lstGroupMemberWrapper.add(new GroupMemberWrapper(new External_Working_Group_Member__c(Contact__c = objContact.Id, Role__c = 'AS Investment Team'), 
         	                                                             objContact, parentId, parentObjectAPIName));	        	    
 	            
 	                else
     	            {
     	                lstGroupMemberWrapper.add(new GroupMemberWrapper(new External_Working_Group_Member__c(Contact__c = objContact.Id), 
         	                                                                                                objContact, parentId, parentObjectAPIName));
     	            }
 	            }
 	            else
 	            {
 	                if(setUserOrRoleId.contains(objContact.Salesforce_User__c))
         	            lstGroupMemberWrapper.add(new GroupMemberWrapper(new External_Working_Group_Member__c(Contact__c = objContact.Id, Role__c = 'AS Resource'), 
         	                                                             objContact, parentId, parentObjectAPIName));	        	    
 	            
 	                else
     	            {
     	                lstGroupMemberWrapper.add(new GroupMemberWrapper(new External_Working_Group_Member__c(Contact__c = objContact.Id), 
         	                                                                                                objContact, parentId, parentObjectAPIName));
     	            }
 	            }
 	        }
         }
    }
	/* End */
	
	/*
        * MethodName	: getFieldOptions()
        * param			: NA
        * Description	: This method is used for preparing list of selectoptions from fieldset. 
 	*/
    public List<SelectOption> getFieldOptions(String fieldsetName) 
    {   
        List<SelectOption> lstOptions = new List<SelectOption>();
    	Schema.FieldSet fieldset = mapGlobalDescribe.get('External_Working_Group_Member__c').getDescribe().FieldSets.getMap().get(fieldsetName);
    	
    	//Preparing list of select option from fieldset
    	for(Schema.FieldSetMember objFSM : fieldset.getFields()) 
    	{
    	    lstOptions.add(new SelectOption(objFSM.getFieldPath(), objFSM.getLabel()));
        }
        return lstOptions;
    }
    /* End */
	
	/*
        * MethodName	: updateRecords()
        * param			: NA
        * Description	: This method is used to update the External_Working_Group_Member__c records. 
 	*/
	public Pagereference updateRecords()
	{
	    if(isEditAll)
		    update lstEWGMember;
		else
		    save();
		return new Pagereference('/'+parentId);
	}
	/* End */
	
	/*
        * MethodName	: cancel()
        * param			: NA
        * Description	: This method is used to redirect on the parent object detail page. 
 	*/
	public Pagereference cancel()
	{
		return new Pagereference('/'+parentId);
	}
	/* End */
	
	/*
        * MethodName	: save()
        * param			: NA
        * Description	: This method is used for creating External_Working_Group_Member__c records. 
 	*/
	public Pagereference save()
	{
		List<External_Working_Group_Member__c> lstEWGMemberToInsert = new List<External_Working_Group_Member__c>();
		Set<String> setAmsecRoles = new Set<String>{'AS Investment Team', 'AS Investment Development'};
		Set<Id> setAmericanSecCompanyIds = new Set<Id>();
		String strErrorMessage = 'You can not assign <b>AS Investment Team or AS Investment Development</b> roles to ';
		String strContactsName = '';
		
		for(Contact objContact : [SELECT Id
                                    FROM Contact 
                                   WHERE Id IN : setExistingContactId 
                                     AND Contact.AccountId != null
                                     AND Account.Name LIKE '%American Securities%'])
		{
		    setAmericanSecCompanyIds.add(objContact.Id);
		}
		//Iterating on GroupMemberWrapper to insert External_Working_Group_Member__c corresponding to the contact 
		for(GroupMemberWrapper objGMW : lstGroupMemberWrapper)
		{
			if(objGMW.isSelected)
			{
				objGMW.EWGMember.Initial_Participation_Date__c = Date.today();
				if(isPortfolioProject)
				{
    				if(objGMW.EWGMember.Role__c == null 
    				   || ((setAmericanSecCompanyIds.contains(objGMW.contact.Id))
    				   || (!setAmericanSecCompanyIds.contains(objGMW.contact.Id) && !setAmsecRoles.contains(objGMW.EWGMember.Role__c))))
    				{
    				    lstEWGMemberToInsert.add(objGMW.EWGMember);
    				}    
    				else
    				{
    				    if(!setAmericanSecCompanyIds.contains(objGMW.contact.Id))
    				    {
    				        strContactsName += ', ' + objGMW.contact.Name;
    				    }
    				  
    				}
				}	
				else if(parentObjectAPIName=='Company__c')
				{
					List<Account> companies = [SELECT Recordtype.DeveloperName 
        			                                  FROM Account
        			                                 WHERE Id =: parentId LIMIT 1];
        			if(companies.size()>0)
        			{
        				if(companies[0].Recordtype.DeveloperName=='Portfolio_Company')
        				{
		        			if(objGMW.EWGMember.Role__c == null 
		    				   || ((setAmericanSecCompanyIds.contains(objGMW.contact.Id)&& setAmsecRoles.contains(objGMW.EWGMember.Role__c))
		    				   || (!setAmericanSecCompanyIds.contains(objGMW.contact.Id) && !setAmsecRoles.contains(objGMW.EWGMember.Role__c))))
		    				{
		    				    lstEWGMemberToInsert.add(objGMW.EWGMember);
		    				}    
		    				else
		    				{
		    				    if(!setAmericanSecCompanyIds.contains(objGMW.contact.Id))
		    				    {
		    				        strContactsName += ', ' + objGMW.contact.Name;
		    				    }
		    				  
		    				}
        				}
        			}
				}
				else
				{
					 lstEWGMemberToInsert.add(objGMW.EWGMember);
				}
			}	
		}
		

		if(strContactsName != '')
		{
		    strContactsName = strContactsName.replaceFirst(',', '');
		    strErrorMessage += '<b>'+strContactsName+'</b>.';
		    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, strErrorMessage));
	        return null;
		}
		else
		{
    	    upsert lstEWGMemberToInsert;
    	    return new Pagereference('/'+parentId);
		}    	    
	}
	/* End */
}