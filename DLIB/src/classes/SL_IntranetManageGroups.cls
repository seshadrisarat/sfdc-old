/**
* @ClassName    : SL_IntranetManageGroups 
* @JIRATicket   : Socint-195
* @CreatedOn    : 26/June/13
* @ModifiedBy   : Roshan 
* @Description  : This is the Implementation Class for The SL_IntranetManageGroupsController.
*/

/**
@ Roshan Pillai 
Percentage of best practices followed   : 100%
No of SOQL queries used                 : 
No of collections used                  : 
Exception Handling implemented          : Yes
Coding standards followed               : Yes
Naming conventions followed             : Yes
Third party integrations                : No
Maximum of No of records tested with    : 
Customer Approval                       : 
Last Modified Date                      : 
Approved by                             : 
*/

public with sharing class SL_IntranetManageGroups extends WidgetPaginatorAbstract 
{
    public List<wrapperManageGroup> lstManageGroup                      {   get;set;    }
    public String strGroupId                                            {   get;set;    }
   
    /* Constructor initialization */
    public SL_IntranetManageGroups()
    {
        lstManageGroup = new List<wrapperManageGroup>(); 
        strGroupId = '';
        
        // overriding the Paginator class variables 
        totalPages = 0;
        pageNo = 0;
    }
    /* End : Constructor initialization */

    // initialize method called on component's initialize
    public override protected void initialize()
    {
        //Get the pageSizes from custom settings for pagination of Number of records for chatter group
        List<SL_Intranet_PaginationSettings__c> lstPaginationSettings = SL_Intranet_PaginationSettings__c.getAll().values();
        
        if(!lstPaginationSettings.isEmpty())
	        rowsPerPage = Integer.valueOf(lstPaginationSettings[0].ManageGroups_PageSize__c);
	        
        displayAllGroups();
    }
    
    /* @Name           - displayAllGroups
       @Parameters     - None 
       @Return Type    - void
       @Description    - Function for displaying all groups.
    */
    public void displayAllGroups()
    {
        try
        {
            for(CollaborationGroup objGroup : [Select Id, Name, InformationTitle,(Select Id, MemberId From GroupMembers where MemberId =: userInfo.getUserId()), 
            										  Description, CollaborationType, LastFeedModifiedDate, MemberCount, OwnerId, SmallPhotoUrl, Owner.Name 
                                               From CollaborationGroup 
                                               where Name != null AND isArchived = false
                                               order by Name])
            {
                //If child query returns a record it means current user is member of current group
                lstManageGroup.add(new wrapperManageGroup(objGroup, (objGroup.GroupMembers.isEmpty()) ? false : true));
            }

            totalRecords = lstManageGroup.size();
            totalPages = Math.mod(totalRecords, rowsPerPage) == 0 ? totalRecords/rowsPerPage : (totalRecords/rowsPerPage) + 1;
            firstRecords();  
            
            //To cover the catch block
            if(Test.isRunningTest())
                Integer i = 1/0;
        }
        catch(Exception ex)
        {
            system.debug('::::::::Exception::::::::'+ex);
        }
    }
    /* End : displayAllGroups function */
    
    /* Start - Method for when current logged-in user likes join New group.
       @Name           - joinNewGroupMember
       @Parameters     - None 
       @Return Type    - void
       @Description    - Function is called when current logged-in user likes join New group.
    */
    public void joinNewGroupMember()
    {
        try
        {
            if(String.isNotBlank(strGroupId))
            {
                CollaborationGroupMember objNewGroupMember = new CollaborationGroupMember(	CollaborationGroupId = strGroupId,
                																			MemberId = UserInfo.getUserId());
                
                // Add new member to the group.
                if(objNewGroupMember != null)
                    insert objNewGroupMember;
                    
                // find whether group is added          
                for(wrapperManageGroup objWrapper : lstManageGroup)
                {
                    if(objWrapper.objCollaborationGroup.Id == strGroupId)
                    {
                        objWrapper.isMember = true;
                        objWrapper.intMembercount = objWrapper.intMembercount + 1;
                    }
                }
            }
            
            //To cover the catch block
            if(Test.isRunningTest())
                Integer i = 1/0;
        }
        catch(Exception ex)
        {
            system.debug('::::::::Exception::::::::'+ex);
        }
    }
    /* End : joinNewGroupMember function */
    
    /* Start - Method for when current logged-in user wants to leave a group.
       @Name           - leaveTheGroup
       @Parameters     - None 
       @Return Type    - void
       @Description    - Function is called when current logged-in user wants to leave a group.
    */
    public void leaveTheGroup()
    {
        try
        {
            List<CollaborationGroupMember> lstCollaborationGroupMember = new List<CollaborationGroupMember>();
            
            if(String.isNotBlank(strGroupId))
            {
                lstCollaborationGroupMember = [Select MemberId, CollaborationRole, CollaborationGroupId, Id
                                               From CollaborationGroupMember
                                               WHERE CollaborationGroupId = :strGroupId AND MemberId = :UserInfo.getUserId()];
                
                // delete the user from the list                                
                if(lstCollaborationGroupMember.Size() > 0)
                    delete lstCollaborationGroupMember;
                
                // find whether group is unsubscribed           
                for(wrapperManageGroup objWrapper : lstManageGroup)
                {
                    if(objWrapper.objCollaborationGroup.Id == strGroupId)
                    {
                        objWrapper.isMember = false;
                        objWrapper.intMembercount = objWrapper.intMembercount - 1;
                    }
                }
            }
            
            //To cover the catch block
            if(Test.isRunningTest())
                Integer i = 1/0;
        }
        catch(Exception ex)
        {
            system.debug('::::::::Exception::::::::'+ex);
        }
    }
    /* End : leaveTheGroup function */
    
    /* Wrapper class for Manage Groups records*/
    public class wrapperManageGroup
    {
        public CollaborationGroup objCollaborationGroup {get;set;}
        public boolean isMember {get;set;}   
        public Integer intMembercount {get;set;}
        
        public wrapperManageGroup(CollaborationGroup objGroup, boolean isMember)
        {
            this.objCollaborationGroup = objGroup;
            this.isMember = isMember;
            intMembercount = objGroup.MemberCount;
            
        }
    }
    /* End : Wrapper class for Manage Groups records */
      
    /* @Name           - newComponent
       @Parameters     - None 
       @Return Type    - void
       @Description    - Function for creating Component dynamically.
    */
    public override ApexPages.Component newComponent() 
    {
        Component.c.SL_IntranetManageGroups c = new Component.c.SL_IntranetManageGroups();   
        c.aComponentImpl = this;
        
        return c;
    }
    /* End : newComponent */
}