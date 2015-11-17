/**
* \arg ClassName      : SL_BatchAddCoverageTeamsToAccountTeams
* \arg JIRATicket     : PWP-88
* \arg CreatedOn      : 24/JULY/2015
* \arg LastModifiedOn : 24/JULY/2015
* \arg CreatededBy    : Lodhi
* \arg ModifiedBy     : Lodhi
* \arg Description    : This is a one time script to add all the coverage team members to account team members.
*/
global class SL_BatchAddCoverageTeamsToAccountTeams implements Database.Batchable<Sobject>
{
    /**
        @MethodName : start
        @Param      : reference of Database.BatchableContext to track the progress of batch job.
        @Description: This method is used to pass the list of Event records to the execute method of interface.
    **/
    global Database.Querylocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator('SELECT Id, Company__c, PWP_Employee__c FROM Coverage_Team_Members__c WHERE '+ 
                                        'PWP_Employee__c != null AND Company__c != null AND PWP_Employee__r.IsActive = true');
    }
    /* End */
    
    /**
        @MethodName : execute
        @Param      : reference of Database.BatchableContext to track the progress of batch job and 
                      list of Coverage_Team_Members__c records received from start method
        @Description: This method is used to add all the Coverage_Team_Members__c to Account's Team.
    **/
    global void execute(Database.BatchableContext BC, List<Coverage_Team_Members__c> lstCoverageTeams)
    {
        List<AccountTeamMember> lstAccountTeam = new List<AccountTeamMember>();
        Set<String> setExistingAccountTeams = new Set<String>();
        Set<Id> setAccountId = new Set<Id>();
        Set<Id> setUserId = new Set<Id>();
        
        //Collecting account id and user id in set
        for(Coverage_Team_Members__c objCoverageTeam : lstCoverageTeams)
        {
            setAccountId.add(objCoverageTeam.Company__c);
            setUserId.add(objCoverageTeam.PWP_Employee__c);
        }
        
        //preparing a set of string combination to avoid adding dulicate user in account teams
        for(AccountTeamMember objAccountTeam : [SELECT Id, UserId, TeamMemberRole, AccountId
                                                  FROM AccountTeamMember
                                                 WHERE AccountId IN : setAccountId
                                                   AND UserId IN : setUserId])
        {
            setExistingAccountTeams.add(objAccountTeam.UserId +'_'+ objAccountTeam.AccountId);
        }
        
        //adding all the Coverage_Team_Members__c as account teams
        for(Coverage_Team_Members__c objCoverageTeam : lstCoverageTeams)
        {
            if(!setExistingAccountTeams.contains(objCoverageTeam.PWP_Employee__c +'_'+ objCoverageTeam.Company__c))
                lstAccountTeam.add(new AccountTeamMember(UserId = objCoverageTeam.PWP_Employee__c, TeamMemberRole = 'Coverage Team Member', 
                                                         AccountId = objCoverageTeam.Company__c));
        }
        if(!lstAccountTeam.isEmpty())
            SL_ManageAccountTeamMembers.createEntitySubscriptionAndCallReportShare(lstAccountTeam);
        
        //Adding all the coverage team member as account team member on the corresponding account record
        insert lstAccountTeam;
    }
    /* End */
    
    /**
        @MethodName : finish
        @Param      : reference of Database.BatchableContext to track the progress of batch job
        @Description: finish method of the interface
    **/
    global void finish(Database.BatchableContext BC)
    {
        //Do nothing
    }
}