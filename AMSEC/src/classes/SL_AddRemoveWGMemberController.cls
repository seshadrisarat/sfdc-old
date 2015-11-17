/**
ClassName        : SL_AddRemoveWGMemberController
JIRA Ticket      : AMSEC-559 
CreatedOn        : 
LastModifiedOn   : 
CreatededBy      : Vishnu
ModifiedBy       : 
Description      : To add/remove WG members on Deal__c(Inv. Opp.)
*/
public with sharing class SL_AddRemoveWGMemberController 
{
    private String strDealId;                                           //To store Deal Id
    private String strUserId;                                           //To store logged in user Id
    private List<Contact> lstContact;                                   //To Store logged in user related contact
    private List<External_Working_Group_Member__c> lstWorkingGroup;     //To store Investment Opportunity Working Group records
    
    public boolean isAddMe      {get; set;}                             //To change Add/Remove Me button label 
    /*Constructor*/
    public SL_AddRemoveWGMemberController(ApexPages.StandardController controller)
    {
        strDealId = ApexPages.currentPage().getParameters().get('id');
        strUserId = UserInfo.getUserId();
        isAddMe = true;
        lstWorkingGroup = new List<External_Working_Group_Member__c>();
        
        checkUserIsRelatedToDeal();
    }

    /*To check logged in user associated contact is currently a Working Group Member on the Deal*/
    private void checkUserIsRelatedToDeal()
    {
        // query to get contact related to logged in user
        lstContact = [Select Id, Name, Salesforce_User__c From Contact Where Salesforce_User__c =: strUserId];
        if(!lstContact.isEmpty())
        {
            //fetch the Working Group Member records related to the contact of current user
            for(External_Working_Group_Member__c objWorkingGroup : [Select Id, Name, Deal__c, Contact__c, End_Date__c, CreatedDate 
                                                                            From External_Working_Group_Member__c 
                                                                            Where Deal__c=:strDealId and Contact__c=: lstContact[0].Id 
                                                                            order by CreatedDate DESC limit 1])
            {
                lstWorkingGroup.add(objWorkingGroup);
                //to change the button label to Remove Me if Working Group record End Date is blank
                if(objWorkingGroup.End_Date__c == null)
                {
                    isAddMe = false;
                }
            }
        }
    }
    
    /* To add the logged in user related contact to Investment Opportunity Working Group*/
    public void addMe()
    {
        if(!lstContact.isEmpty())
        {
            if(!lstWorkingGroup.isEmpty())
            {
                // to update Working Group.End Date if user's associated contact is currently a Working Group Member on the Deal
                for(External_Working_Group_Member__c objWorkingGroup : lstWorkingGroup)
                {
                    objWorkingGroup.End_Date__c = null;
                }
                if(!lstWorkingGroup.isEmpty())
                    update lstWorkingGroup;
            }
            else
            {
                //creating new Working Gropu record for loggedin user and current Deal record
                External_Working_Group_Member__c objWorkingGroup = new External_Working_Group_Member__c();
                objWorkingGroup.Contact__c = lstContact[0].Id;
                objWorkingGroup.Deal__c = strDealId;
                objWorkingGroup.Initial_Participation_Date__c = system.Today();
                insert objWorkingGroup;
            }
        }
            
    }
    
    /* To remove the logged in user related contact to Investment Opportunity Working Group*/
    public void removeMe()
    {
        //To update the Working Group.End Date to Today
        for(External_Working_Group_Member__c objWorkingGroup : lstWorkingGroup)
        {
            objWorkingGroup.End_Date__c = system.Today();
        }
        if(!lstWorkingGroup.isEmpty())
            update lstWorkingGroup;
        
    }
}