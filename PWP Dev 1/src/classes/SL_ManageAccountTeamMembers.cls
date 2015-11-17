/**
* \arg ClassName        : SL_ManageAccountTeamMembers
* \arg JIRATicket     	: PWP-77, PWP-88
* \arg CreatedOn      	: 24/JULY/2015
* \arg LastModifiedOn	: 20/AUG/2015
* \arg CreatededBy    	: Lodhi 
* \arg ModifiedBy     	: Lodhi
* \arg Description      : Serves as a utility class to manage AccountTeamMembers from 
*                         class SL_OpportunityHandler and SL_Project_Coverage_Team_Member__cHandler
*/
public without sharing class SL_ManageAccountTeamMembers 
{
    /**
	    @MethodName : createAccountTeamMembers
	    @Param 		: Set of account id on which we need to insert the team member records
	    @Description: This method will create Account team member records.
    **/
    public static void createAccountTeamMembers(Set<Id> setAccIdOrOppIdTeamToManageAccTeams)
    {
        Map<String, AccountTeamMember> mapUserIdRoleToAccountTeams = new Map<String, AccountTeamMember>();
        Map<String, AccountTeamMember> mapExistingAccountTeams = new Map<String, AccountTeamMember>();
        List<AccountTeamMember> lstAccountTeamsToDelete = new List<AccountTeamMember>();
        Set<String> setStringCombined = new Set<String>();
        
        //Collecting all the existing AccountTeamMember on the corresponding accounts.
        for(AccountTeamMember objAccountTeam : [SELECT Id, UserId, TeamMemberRole, AccountId
                                                  FROM AccountTeamMember
                                                 WHERE AccountId IN : setAccIdOrOppIdTeamToManageAccTeams])
        {
            mapExistingAccountTeams.put(objAccountTeam.UserId +'_'+ objAccountTeam.AccountId, objAccountTeam);
        }
        
        //Adding AccountTeamMember from Opportunities where StageName is 'Active Mandate','Prospective Mandate' 
        for(Project_Coverage_Team_Member__c objOppTeam : [SELECT Id, Name, Project__c, User__c, Project__r.AccountId
                                                  			FROM Project_Coverage_Team_Member__c
                                                 		   WHERE Project__r.AccountId IN : setAccIdOrOppIdTeamToManageAccTeams
                                               				 AND Project__r.StageName IN('Active Mandate','Prospective Mandate')
                                               				 AND User__c != null])
        {
            setStringCombined.add(objOppTeam.User__c +'_'+ objOppTeam.Project__r.AccountId);
            if(!mapExistingAccountTeams.containsKey(objOppTeam.User__c +'_'+ objOppTeam.Project__r.AccountId))
                mapUserIdRoleToAccountTeams.put(objOppTeam.User__c +'_'+ objOppTeam.Project__r.AccountId, 
                                                new AccountTeamMember(UserId = objOppTeam.User__c, TeamMemberRole = 'Coverage Team Member',
                                                                      AccountId = objOppTeam.Project__r.AccountId));  
        }
        
        //If there is no opportunity present with StageName 'Active Mandate','Prospective Mandate' 
        //then adding all the Project_Coverage_Team_Member__cs as AccountTeamMember
        if(setStringCombined.isEmpty())
        {
            for(Project_Coverage_Team_Member__c objOppTeam : [SELECT Id, Name,Project__c, User__c, Project__r.AccountId
                                                  				FROM Project_Coverage_Team_Member__c
                                                 			   WHERE Project__r.AccountId IN : setAccIdOrOppIdTeamToManageAccTeams
                                                   				 AND Project__r.StageName NOT IN('Active Mandate','Prospective Mandate')
                                                   				 AND User__c != null])
            {
                setStringCombined.add(objOppTeam.User__c +'_'+ objOppTeam.Project__r.AccountId);
                if(!mapExistingAccountTeams.containsKey(objOppTeam.User__c +'_'+ objOppTeam.Project__r.AccountId))    
                    mapUserIdRoleToAccountTeams.put(objOppTeam.User__c +'_'+ objOppTeam.Project__r.AccountId, 
                                                    new AccountTeamMember(UserId = objOppTeam.User__c, TeamMemberRole = 'Coverage Team Member',
                                                                          AccountId = objOppTeam.Project__r.AccountId));        
            }
        }
        
        //Removing unusual teammembers from corresponding Accounts
        for(String strCombined : mapExistingAccountTeams.keySet())
        {
            if(!setStringCombined.contains(strCombined))
            {
                lstAccountTeamsToDelete.add(mapExistingAccountTeams.get(strCombined));
            }
        }
        //Deleting AccountTeamMember records
        delete lstAccountTeamsToDelete;
        //Deleting call report share and EntitySubscription records corresponding to the company
        if(!lstAccountTeamsToDelete.isEmpty())
            deleteEntitySubscriptionAndCallReportShare(lstAccountTeamsToDelete);
        
        /* Added by Lodhi as part of PWP-133 on 20/Aug/2015 */
        Map<Id, AccountTeamMember> mapDoNotSendEmailToAccTeams = new Map<Id, AccountTeamMember>();
        List<Messaging.SingleEmailMessage> lstMails = new List<Messaging.SingleEmailMessage>();
        
        //Iterating over AccountTeamMember to avoid the sending of email alert to those users that are newly added 
        for(AccountTeamMember objAccTeam : [SELECT UserId, User.Name, User.Email, Account.Name
                                              FROM AccountTeamMember
                                             WHERE AccountId IN : setAccIdOrOppIdTeamToManageAccTeams])
        {
            mapDoNotSendEmailToAccTeams.put(objAccTeam.userId, objAccTeam);
        }                                             
        
        //Sending email alert to the existing users regards the newly added team members
        for(AccountTeamMember objAccTeam : mapDoNotSendEmailToAccTeams.values())
        {
            String strCoverageTeams = '';
            String strMemberUrl = '';
            String strProjecName = '';
            Messaging.SingleEmailMessage objEmail = new Messaging.SingleEmailMessage();
            objEmail.setToAddresses(new List<String>{objAccTeam.User.Email});
            for(Project_Coverage_Team_Member__c objOppTeam : [SELECT Id, Name, User__r.Name, Project__r.Name 
                                                                FROM Project_Coverage_Team_Member__c 
                                                               WHERE Id IN : setAccIdOrOppIdTeamToManageAccTeams
                                                                 AND RecordType.DeveloperName = 'Coverage_Team'])
            {
                if(String.isEmpty(strProjecName))
                    strProjecName = objOppTeam.Project__r.Name ;
                
                if(!mapDoNotSendEmailToAccTeams.containsKey(objOppTeam.User__c))
                {
                    strCoverageTeams += (!String.isEmpty(strCoverageTeams) ? ', ' + objOppTeam.User__r.Name : objOppTeam.User__r.Name);      
                    strMemberUrl += (String.isEmpty(strMemberUrl) ? '<br><br>' : '<br>') + System.URL.getSalesforceBaseURL().toExternalForm() +'/'+ objOppTeam.Id;
                }    
            }
            objEmail.setHtmlBody('<Strong>Company :</Strong> ' + objAccTeam.Account.Name + '<br><Strong>Project :</Strong> ' + strProjecName + '<br><Strong>'+(strCoverageTeams.split(',').size() > 1 ? 'Coverage Member\'s :</Strong> ' : 'Coverage Member :</Strong> ') + strCoverageTeams + '<br> <Strong>Created By :</Strong> ' + UserInfo.getName() + strMemberUrl);
            objEmail.setSubject(strCoverageTeams + ' has been added to Coverage Team');
            if(strCoverageTeams != '')
                lstMails.add(objEmail);
        }
        try
        {
            if(!lstMails.isEmpty())
                Messaging.sendEmail(lstMails);
        }
        catch(Exception ex)
        {
            system.debug('===ex==='+ex.getMessage()+'===msg==='+ex.getLineNumber());
        }
        /* Added by Lodhi as part of PWP-133 on 20/Aug/2015 */
        
        //Creating call report share and EntitySubscription records corresponding to the company
        if(!mapUserIdRoleToAccountTeams.isEmpty())
            createEntitySubscriptionAndCallReportShare(mapUserIdRoleToAccountTeams.values());
        
        //Inserting AccountTeamMember records
        insert mapUserIdRoleToAccountTeams.values();
    }
    /* End */
    
    /**
	    @MethodName : createEntitySubscriptionAndCallReportShare
	    @Param 		: Set of account id on which we need to insert the team member records
	    @Description: This method will create call report share records and EntitySubscription records to follow the corresponding account.
    **/
    public static void createEntitySubscriptionAndCallReportShare(List<AccountTeamMember> lstAccountTeamMembers)
    {
        Map<String, EntitySubscription> mapEntitySubscription = new Map<String, EntitySubscription>();//Map of string combination of account id to user id to EntitySubscription for inserting the unique records
        Map<Id, List<AccountTeamMember>> mapAccIdTolstOfAccTeams = new Map<Id, List<AccountTeamMember>>();// map to hold account id and its corresponding AccountTeamMember records.
        List<Call_Report__Share> lstCRShare = new List<Call_Report__Share>();// list of call report share records to insert
        Set<Id> setAccountId = new Set<Id>();//Set of account id
        Set<Id> setUserId = new Set<Id>();//Set of user id   
        Set<String> setAcountIdToUserId = new Set<String>();//Set of string with combination of accountid and user id
        Set<String> setCRIdToUserId = new Set<String>();
        
        //Iterating on Relationship__c to get set of accountid, set of user id and filtered list of 
        for(AccountTeamMember objAccTeam : lstAccountTeamMembers)
        {
            setAccountId.add(objAccTeam.AccountId);
            setUserId.add(objAccTeam.UserId);
            
            if(!mapAccIdTolstOfAccTeams.containskey(objAccTeam.AccountId))
                mapAccIdTolstOfAccTeams.put(objAccTeam.AccountId, new List<AccountTeamMember>{objAccTeam});
            else
                mapAccIdTolstOfAccTeams.get(objAccTeam.AccountId).add(objAccTeam);
            
        }
        
        //Iterating on Relationship__c to create unique EntitySubscription records.
        for(AccountTeamMember objAccTeam : lstAccountTeamMembers)
        {
            mapEntitySubscription.put(objAccTeam.AccountId +'_'+ objAccTeam.UserId, 
                                      new EntitySubscription(ParentId = objAccTeam.AccountId, SubscriberId = objAccTeam.UserId));
        }
        
        //Fetching all call reports correspnding to call report company records.
        for(Call_Report_Company__c objCRC : [SELECT Call_Report__c, Relevant_Company__c 
                                               FROM Call_Report_Company__c 
                                              WHERE Relevant_Company__c IN : mapAccIdTolstOfAccTeams.keyset()])
        {
            if(mapAccIdTolstOfAccTeams.containskey(objCRC.Relevant_Company__c))
            {
                for(AccountTeamMember objAccTeam : mapAccIdTolstOfAccTeams.get(objCRC.Relevant_Company__c))
                {
                    lstCRShare.add(new Call_Report__Share(ParentId = objCRC.Call_Report__c, UserOrGroupId = objAccTeam.UserId, AccessLevel = 'Read'));
                }
            }
        }
        //Inserting call report share records using Database.insert for avoiding creating Call_Report__Share for the Call_Report__c owners
        Database.insert(lstCRShare, false);
        
        //Inserting EntitySubscription records
        Database.insert(mapEntitySubscription.values(), false);        
    }
    /* End */
    
    /**
	    @MethodName : deleteEntitySubscriptionAndCallReportShare
	    @Param 		: Set of account id on which we need to insert the team member records
	    @Description: This method will delete call report share records and EntitySubscription records.
    **/
    public static void deleteEntitySubscriptionAndCallReportShare(List<AccountTeamMember> lstAccountTeamMembers)
    {
        List<EntitySubscription> lstEntitySubscription = new List<EntitySubscription>();//List of EntitySubscription to delete
        List<Call_Report__Share> lstCallReportShare = new List<Call_Report__Share>();// list to delete the call report sharing records
        Set<Id> setAccountId = new Set<Id>();//Set of account id
        Set<Id> setUserId = new Set<Id>();//Set of user id   
        Set<Id> setCallReportId = new Set<Id>();//set to hold the call report ids corresponding to companies of inserted coverage team members
        
        //Iterating on Coverage_Team_Members__c to get account id and user id into set
        for(AccountTeamMember objAccTeam : lstAccountTeamMembers)
        {
            setAccountId.add(objAccTeam.AccountId);
            setUserId.add(objAccTeam.UserId);
        }
        
        //fetching all call reports corresponding to the inserted call team member's account
        for(Call_Report_Company__c objCRC : [SELECT Call_Report__c 
                                               FROM Call_Report_Company__c 
                                              WHERE Relevant_Company__c IN : setAccountId])
        {
            setCallReportId.add(objCRC.Call_Report__c);
        }
        
        //Iterating  on EntitySubscription to delete 
        for(EntitySubscription objEntitySubscription:[SELECT ParentId, SubscriberId 
                                                        FROM EntitySubscription
                                                       WHERE ParentId IN: setAccountId
                                                         AND SubscriberId IN : setUserId])
        {
            lstEntitySubscription.add(objEntitySubscription);
        }
        
        //Fetching call report share records correponding to call report ids and pwp employees
        for(Call_Report__Share objCRShare : [SELECT ParentId, UserOrGroupId 
                                               FROM Call_Report__Share 
                                              WHERE ParentId IN : setCallReportId 
                                                AND UserOrGroupId IN : setUserId 
                                                AND RowCause = 'Manual'])
        {
            lstCallReportShare.add(objCRShare);               
        }
        //Delete the EntitySubscription records
        delete lstEntitySubscription;
        
        //Delete the call report share records
        delete lstCallReportShare;
    }
    /* End */
}