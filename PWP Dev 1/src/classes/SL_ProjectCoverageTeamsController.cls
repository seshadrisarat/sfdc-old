/**
* \arg ClassName        : SL_ProjectCoverageTeamsController
* \arg JIRATicket     	: PWP-83,113,128,174,180
* \arg CreatedOn      	: 24/JULY/2015
* \arg LastModifiedOn	: 09/SEP/2015
* \arg CreatededBy    	: Prakash 
* \arg ModifiedBy     	: Lodhi
* \arg Description      : Class create/update opportunity records and related Project_Coverage_Team_Member__c records
*/
public with sharing class SL_ProjectCoverageTeamsController{
	public list<wrapBussinesGroupUsers> lstBusinessGrpUsers						{get;set;}
	public map<Id,string> mapCoverageTeam										{get;set;}
	public map<Id,string> mapOtherTeamMember									{get;set;}
	public map<Id,Project_Coverage_Team_Member__c> mapExistingCoverageTeam		{get;set;}
	public list<Id> lstSelGroupUserId											{get;set;}	// For other team member to filter related users
	public Opportunity objProject												{get;set;}
	public Id selUserId															{get;set;}
	public String selUserName													{get;set;}
	public String strSelAll														{get;set;}
	public map<Id, User> mapIdToUser											{get;set;}
	public String strCompanyId                                      			{get;set;}
	public String strCompanyName                                    			{get;set;}
	public String strBusinessUnitId                                 			{get;set;}
	public String strBusinessUnitName                               			{get;set;}
	public Boolean isAccessible                                                 {get;set;}
	private Id recordTypeId;
	private Set<Id> setExistingUsers;
	private Set<Id> setDoNotDeleteUsers;
	
	public SL_ProjectCoverageTeamsController(ApexPages.StandardController cr){
        /* Added by Lodhi as part of PWP-251 09/Sep/2015 */
        isAccessible = false;
        Set<Id> setPSUserId = new Set<Id>();
        List<Profile> lstProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' AND Id =: UserInfo.getProfileId() LIMIT 1];
        for(PermissionSetAssignment objPSA : [SELECT Id, AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = 'Accounting'])
        {
            setPSUserId.add(objPSA.AssigneeId);
        }
        if((!lstProfile.isEmpty() || setPSUserId.contains(UserInfo.getUserId())) && Schema.sObjectType.Opportunity.fields.Generate_Project_Code__c.isAccessible())
            isAccessible = true;
        /* Added by Lodhi as part of PWP-251 09/Sep/2015 */

		List<RecordType> lstRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Coverage_Team' AND SobjectType = 'Project_Coverage_Team_Member__c'];
		if(!lstRecordType.isEmpty())
		    recordTypeId = lstRecordType[0].Id;    
		mapIdToUser = new map<Id, User>([SELECT Id, Name, Coverage_Team_Role__c FROM User WHERE IsActive = true]);
		lstBusinessGrpUsers = new list<wrapBussinesGroupUsers>();
		mapCoverageTeam = new map<Id,string>();
		mapOtherTeamMember = new map<Id,string>();
		mapExistingCoverageTeam = new map<Id,Project_Coverage_Team_Member__c>();
		lstSelGroupUserId = new list<Id>();
		selUserId = null;
		selUserName = strCompanyName = strBusinessUnitId = strBusinessUnitName = '';
		setExistingUsers = new Set<Id>();
		setDoNotDeleteUsers = new Set<Id>();
		
		objProject = new Opportunity();
		objProject = (Opportunity)cr.getRecord() ;
		objProject.name='(optional)'; // its mandatory field and in trigger overriding with custom name 
		objProject.Billing_Code__c='(optional)';
		// If New Document created from Account/PE records
        if(ApexPages.currentPage().getParameters().get('retURL') != null
        	&& cr.getId() == null){
        	strCompanyId = objProject.AccountId = ApexPages.currentPage().getParameters().get('accId');
        	objProject.CloseDate = date.today();
        	objProject.StageName = 'Prospective Mandate';
        	List<Account> lstAccount = [SELECT Name FROM Account WHERE Id =: strCompanyId];
        	if(!lstAccount.isEmpty())
        	    strCompanyName = lstAccount[0].Name;    
        	
        	/* Added by Lodhi as part of PWP-128 05/AUG/2015 */
        	Set<Id> setUserOrBusinessUnitId = new Set<Id>();
        	List<Business_Unit_Members__c> lstBusinessUnitMembers = new List<Business_Unit_Members__c>();
        	for(Business_Unit_Members__c objBUM : [SELECT Business_Unit__r.Name
													 FROM Business_Unit_Members__c 
													WHERE PWP_Employee__c =: UserInfo.getUserId()]){
                setUserOrBusinessUnitId.add(objBUM.Business_Unit__c);
                lstBusinessUnitMembers.add(objBUM);
            }	
            if(!lstBusinessUnitMembers.isEmpty() && lstBusinessUnitMembers.size() == 1){
                Business_Unit_Members__c objBUMTemp = lstBusinessUnitMembers[0];
                objProject.Business_Group__c = strBusinessUnitId = objBUMTemp.Business_Unit__c;
                strBusinessUnitName = objBUMTemp.Business_Unit__r.Name;
                // objProject.Business_Group__c = lstBUId[0];
                for(Business_Unit_Members__c objBUM : [SELECT Id, PWP_Employee__c, PWP_Employee__r.Name 
    													 FROM Business_Unit_Members__c 
    													WHERE PWP_Employee__c != null 
    													  AND PWP_Employee__r.IsActive = true
    													  AND Business_Unit__c IN : setUserOrBusinessUnitId]){
    			    lstSelGroupUserId.add(objBUM.PWP_Employee__c);
    			    if(!setUserOrBusinessUnitId.contains(objBUM.PWP_Employee__c)){
    			        setUserOrBusinessUnitId.add(objBUM.PWP_Employee__c);
    			        lstBusinessGrpUsers.add(new wrapBussinesGroupUsers(objBUM.PWP_Employee__c, objBUM.PWP_Employee__r.Name, false));    										    
    			    }
                }
            }
        	/* Added by Lodhi as part of PWP-128 05/AUG/2015 */
        }
        if(cr.getId() != null){
        	editProjectAndCoverageTeam(cr.getId());
        }
	}
	
	/**
	    * @JIRATicket   : PWP-180
        * @Name         : updateAccountIdOnProject
        * @Description  : on edit update the account 
    */
	public void updateAccountIdOnProject(){
        objProject.AccountId = strCompanyId;
	}
	
	/**
        * @Name         : editProjectAndCoverageTeam
        * @Description  : on edit update the project and related coverage team
    */
	public void editProjectAndCoverageTeam(Id objProjId){
		
		objProject = [Select Id,Name,Account.Name,CloseDate,StageName,Business_Group__r.Name,Billing_Code__c, Generate_Project_Code__c  
						From Opportunity 
						Where Id = : objProjId limit 1];
		
		strCompanyId = objProject.AccountId;
		strCompanyName = objProject.Account.Name;
		strBusinessUnitId = objProject.Business_Group__c;
		strBusinessUnitName = objProject.Business_Group__r.Name;
		editProjCoverageTeam(objProjId);
		bussGroupRelatedCoverageTeamMembers();
		// Adding into Coverage collection
		mapCoverageTeam.putAll(mapOtherTeamMember);
		setExistingUsers.addAll(mapCoverageTeam.KeySet());
					
	}
	/**
        * @Name         : editProjCoverageTeam
        * @Description  : on edit update the project related coverage team
    */
	public void editProjCoverageTeam(Id objProjId){
	    Set<Id> setBusinesUnitMembersId = new Set<Id>();
	    
		for(Project_Coverage_Team_Member__c objOTM : [Select Id,User__c,User__r.Name,Project__c, RecordType.Name, RecordType.DeveloperName From Project_Coverage_Team_Member__c
												Where Project__c = : objProjId ]){
			mapExistingCoverageTeam.put(objOTM.User__c,objOTM);
			if(objOTM.RecordType.DeveloperName == 'Coverage_Team')
			    lstSelGroupUserId.add(objOTM.User__c);
			setDoNotDeleteUsers.add(objOTM.User__c);
		}
		
	}
	/**
        * @Name         : bussGroupRelatedCoverageTeamMembers
        * @Description  : Collect the Bussiness group related users 
    */
	public void bussGroupRelatedCoverageTeamMembers(){
	    /*Added by Lodhi as part of PWP-241 on 10/Sep/2015 */
	    Set<Id> setCoverageTeamMemberId = new Set<Id>();
	    if(objProject.Id != null)
	    {
	        for(Project_Coverage_Team_Member__c objPCTM : [SELECT Id, User__c 
	                                                         FROM Project_Coverage_Team_Member__c 
	                                                        WHERE Project__c =: objProject.Id
	                                                          AND RecordType.DeveloperName = 'Coverage_Team'])
            {
                setCoverageTeamMemberId.add(objPCTM.User__c);
            }
	    }
	    /*Added by Lodhi as part of PWP-241 on 10/Sep/2015 */
	    
		lstBusinessGrpUsers = new list<wrapBussinesGroupUsers>();
		Set<Id> setBusinesUnitMembersId = new Set<Id>();
        if(objProject.Id == null)
            lstSelGroupUserId = new List<Id>();
        objProject.Business_Group__c = strBusinessUnitId;    
		for(Business_Unit_Members__c objBussUnit:[Select Id,Business_Unit__c,PWP_Employee__c,PWP_Employee__r.Name 
													From Business_Unit_Members__c 
													Where PWP_Employee__c != null And PWP_Employee__r.IsActive = true And Business_Unit__c =: objProject.Business_Group__c ]){
			if(!setBusinesUnitMembersId.contains(objBussUnit.PWP_Employee__c))
    			lstBusinessGrpUsers.add(new wrapBussinesGroupUsers(objBussUnit.PWP_Employee__c,
    																objBussUnit.PWP_Employee__r.Name,
    																(((mapExistingCoverageTeam.containsKey(objBussUnit.PWP_Employee__c)
    																 || mapOtherTeamMember.containsKey(objBussUnit.PWP_Employee__c) 
    																 || mapCoverageTeam.containsKey(objBussUnit.PWP_Employee__c)) 
    																 && setCoverageTeamMemberId.contains(objBussUnit.PWP_Employee__c)) ? true : false)));
			setBusinesUnitMembersId.add(objBussUnit.PWP_Employee__c); 
			// On edit if Business Group changed and show the related coverage records
			if(mapExistingCoverageTeam.containsKey(objBussUnit.PWP_Employee__c) && setCoverageTeamMemberId.contains(objBussUnit.PWP_Employee__c))
				mapCoverageTeam.put(objBussUnit.PWP_Employee__c,objBussUnit.PWP_Employee__r.Name);
				
			/* Duplicate records will enter*/
			lstSelGroupUserId.add(objBussUnit.PWP_Employee__c); 
		}
		
		//Added by Lodhi 30/JULY/2015 tp prevent other team member in coverage team member list that were previously added when Remove all button is clicked
		for(Project_Coverage_Team_Member__c objOppTeam : mapExistingCoverageTeam.values()){
            if(!setBusinesUnitMembersId.contains(objOppTeam.User__c) && setCoverageTeamMemberId.contains(objOppTeam.User__c))
                mapOtherTeamMember.put(objOppTeam.User__c,objOppTeam.User__r.Name);
        }
	}
	/**
        * @Name         : otherTeamMembers
        * @Description  : Select the other user which is not related to Business user 
    */
	public void otherTeamMembers(){
		try{
    		mapOtherTeamMember.put(selUserId,selUserName);
    		lstSelGroupUserId.add(selUserId);
    		selectUnselectCoverageTeam();
		}
		catch(Exception ex){
		    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
		}
	}
	/**
        * @Name         : selectUnselectCoverageTeam
        * @Description  : On select the check box add into coverage team list. And on remove link click uncheck in add coverage team list 
    */
	public void selectUnselectCoverageTeam(){ 
		integer i=0; 
		
		// On checkbox select adding Business group users in Coverage Team list and unselect removing from list
		if(mapCoverageTeam.size() == 0){
		    mapOtherTeamMember.put(selUserId,selUserName);
			mapCoverageTeam.put(selUserId,selUserName);
		}else{
			Boolean flag = false;	
			for(Id userId:mapCoverageTeam.keySet()){
				if(selUserId == userId){
					mapCoverageTeam.remove(selUserId);
					flag = true;
					break;
				}
				i++;
			}
			
			if(!flag){
			    mapOtherTeamMember.put(selUserId,selUserName);
				mapCoverageTeam.put(selUserId,selUserName);
			}	
		}
		// Remove link selected from coverage team table
		if(strSelAll == 'RemoveOne'){
			// Unselected the check box in Business group list
			for(wrapBussinesGroupUsers objUsers : lstBusinessGrpUsers){
				if(selUserId == objUsers.bussUserId){
					objUsers.isChecked = false;
					break;
				}	
			}
			i = 0;
			// Remove the element from Other Team members list
			for(id idUser:lstSelGroupUserId){
				if(selUserId == idUser){
					mapOtherTeamMember.remove(selUserId);
					lstSelGroupUserId.remove(i);
					break;
				}
				i++;
			}
		}
	}
	/**
        * @Name         : selectAllOrRemoveUsers
        * @Description  : Select/Unselect all Business Group records on click of Add All/Remove All button.
    */
	public void selectAllOrRemoveUsers(){
		Boolean isSelect = false; 
		mapCoverageTeam.clear();
		if(strSelAll == 'AddAll'){
			isSelect = true;			
		}
        
		for(wrapBussinesGroupUsers objUsers : lstBusinessGrpUsers){
			objUsers.isChecked = isSelect;
			if(isSelect){
				mapCoverageTeam.put(objUsers.bussUserId,objUsers.bussUserName);
				mapOtherTeamMember.put(objUsers.bussUserId,objUsers.bussUserName);
			}	
			else
			    mapOtherTeamMember.remove(objUsers.bussUserId);
		}
		mapCoverageTeam.putAll(mapOtherTeamMember);
	}
	/**
        * @Name         : saveClick
        * @Description  : Save the Opprotunity(Project) and related Project_Coverage_Team_Member__cs(Coverage Team) records
    */
	public pageReference saveClick(){
		try{
			// insert/update the opportunity records  
			upsert objProject;
			
			// insert the selected coverage team members(Project_Coverage_Team_Member__cs)
			list<Project_Coverage_Team_Member__c> lstOTM = new list<Project_Coverage_Team_Member__c>(); 
			for(id idUser:mapCoverageTeam.keySet()){
				/*	Checking on edit of project team member records
					if coverage team records alredy exist/unselecte/selected.
					If its not contains in existing collection create record 
				*/
				if(!setExistingUsers.contains(idUser) || !mapExistingCoverageTeam.containsKey(idUser)){
					lstOTM.add(new Project_Coverage_Team_Member__c(Project__c = objProject.Id, User__c = idUser, RecordTypeId = recordTypeId));
				}else{
					mapExistingCoverageTeam.remove(idUser);
				}
				if(setDoNotDeleteUsers.contains(idUser))
				    mapExistingCoverageTeam.remove(idUser);
			}
			setDoNotDeleteUsers.removeAll(setExistingUsers);
			for(Id userId : mapExistingCoverageTeam.keySet()){
			    if(setDoNotDeleteUsers.contains(userId))
			        mapExistingCoverageTeam.remove(userId);    
			}
			// Deleting the Coverage Team records if they are unselected on edit project
			if(!mapExistingCoverageTeam.isEmpty() )
			{
			    delete([SELECT Id FROM Project_Coverage_Team_Member__c 
			             WHERE User__c IN : mapExistingCoverageTeam.KeySet() 
			               AND RecordType.DeveloperName = 'Coverage_Team'
			               AND Project__c =: objProject.Id]);
			}              
			// delete mapExistingCoverageTeam.values();
			
			// Insert the Coverage Team Records	
			if(!lstOTM.isEmpty())
				insert lstOTM; 
			
			// Send the user to the detail page from where this page was launched.
			return new pageReference(ApexPages.currentPage().getParameters().get('retURL'));
		}
		catch(Exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
		}
		return null;
	}
	/**
        * @Name         : cancelClick
        * @Description  : On Click redirect to previous page
    */
	public pageReference cancelClick(){
		return new pageReference(ApexPages.currentPage().getParameters().get('retURL'));
	}
	
	/**
        * @Name         : wrapBussinesGroupUsers
        * @Description  : Collect the selected Business Group Unit records
    */
	public class wrapBussinesGroupUsers{
		public Id bussUserId			{get;set;}
		public String bussUserName		{get;set;}
		public Boolean isChecked		{get;set;}
		
		public wrapBussinesGroupUsers(Id PMPEmpId,String PMPEmpName,Boolean isChk){
			bussUserId = PMPEmpId;
			bussUserName = PMPEmpName;
			isChecked = isChk;
		}
	}
}