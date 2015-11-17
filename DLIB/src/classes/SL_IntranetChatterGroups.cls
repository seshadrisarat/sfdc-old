/**
* @ClassName    : SL_IntranetChatterGroups 
* @JIRATicket   : Socint-180
* @CreatedOn    : 18/June/13
* @ModifiedBy   : Roshan 
* @Description  : This is the Base class for The SL_IntranetChatterGroupsController.
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
public with sharing class SL_IntranetChatterGroups extends WidgetAbstract 
{
    public List<MyGroup> lstMyGroups {get;set;}
    public List<FeaturedGroup> lstFeaturedGroups {get;set;} 
    
    /* Constructor initialization */
    public SL_IntranetChatterGroups()
    {
        // Do Nothing
    }
    /* End : Constructor initialization */
    
    // Initialize method
    public override protected void initialize()
    {
        lstMyGroups = new List<MyGroup>();
        lstFeaturedGroups = new List<FeaturedGroup>();
        this.getChatterGroups();
    }
    
    

    /* @Name           - getChatterGroups
       @Parameters     - None 
       @Return Type    - void
       @Description    - Function for getting chatter groups and Featured groups.
    */
    private void getChatterGroups()
    { 

        Set<Id> setGroupId = new Set<Id>();     //To avoid the addtion of group multiple times
        Set<Id> setFeaturedGroupIDs = new Set<Id>();
        
        //This is to indentify and conside only thsoe groups which are not archieved. This is specially for that case when Admin adds the archieved group
        //id into Feature group custom setting. 
        Map<Id, CollaborationGroup> mapCollaborationGroups = new Map<Id, CollaborationGroup>([Select Id, Name 
                                                                                              From CollaborationGroup 
                                                                                              where IsArchived = false]);
        //To maintain the order
        List<Id> lstFeaturedGroupIds = new List<Id>();      
        
        //Build Feature Groups list
        Map<Id, FeaturedGroup> mapFGIdToFG = new Map<Id, FeaturedGroup>();
        for(SL_FeaturedGroups__c objFGroup : [ SELECT GroupId__c, Name 
                                               FROM SL_FeaturedGroups__c 
                                               Where GroupId__c != null 
                                               Order By Name])
        {
            if(mapCollaborationGroups.containsKey((Id)objFGroup.GroupId__c))
            {
                mapFGIdToFG.put((Id)objFGroup.GroupId__c, new FeaturedGroup(objFGroup, false));
                lstFeaturedGroupIds.add((Id)objFGroup.GroupId__c);
            }
        }
        
        //Query for getting Id of Groups where logged in user is associated
        for(CollaborationGroupMember objCGMembers : [Select CollaborationGroup.Name, CollaborationGroupId 
                                                     From CollaborationGroupMember 
                                                     Where MemberId =: UserInfo.getUserId() AND
                                                     CollaborationGroup.IsArchived = false
                                                     Order By CollaborationGroup.Name])
        {
            //If present in Feature group then update the membership boolean
            if(mapFGIdToFG.containsKey(objCGMembers.CollaborationGroupId))
                mapFGIdToFG.get(objCGMembers.CollaborationGroupId).isMember = true;
            //Group will be added in MyGroup list only when they are not present in Feature group list to avoid the duplicates  
            else
                lstMyGroups.add(new MyGroup(objCGMembers.CollaborationGroup));
        }
        
        //To maintain the order for Feature group list
        for(Id featureGroupId : lstFeaturedGroupIds)
            lstFeaturedGroups.add(mapFGIdToFG.get(featureGroupId));    
    }
    /* End : getChatterGroups method */  
    
    /* Wrapper class for FeaturedGroup */
    public class FeaturedGroup
    {
        public SL_FeaturedGroups__c objMyGroup {get; set;}
        public Boolean isMember {get;set;}
        
        public FeaturedGroup(SL_FeaturedGroups__c prmCGroup, Boolean prmMember)
        {
            objMyGroup = prmCGroup;
            isMember = prmMember;
        }
    }
    /* End : FeaturedGroup Wrapper class */
    
    /* Wrapper class for MyGroup */
    public class MyGroup
    {
        public CollaborationGroup objMyGroup {get; set;}

        public MyGroup(CollaborationGroup objCGroup)
        {
            objMyGroup = objCGroup;
        }
    }
    /* End : MyGroup Wrapper class */
    
    
    /* @Name           - newComponent
       @Parameters     - None 
       @Return Type    - void
       @Description    - Function for creating Component dynamically.
    */
    public override ApexPages.Component newComponent() 
    {
        Component.c.SL_IntranetChatterGroups c = new Component.c.SL_IntranetChatterGroups();   
        c.aComponentImpl = this;
        
        return c;
    }
    /* End : newComponent */
}