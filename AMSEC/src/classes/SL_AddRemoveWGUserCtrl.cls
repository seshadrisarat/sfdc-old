/**
ClassName       : SL_AddRemoveWGUserCtrl
JIRA Ticket     : AMSEC-565
CreatedOn       : 22/Sept/15
LastModifiedOn  : 22/Sept/15
CreatededBy     : Praful Gadge
ModifiedBy      : Praful Gadge
Description     : To create Add/Remove Me button on Account/Project/Deal detail page as an inline vf page
*/
public with sharing class SL_AddRemoveWGUserCtrl {

    // To update button lable to Add/Remove Me
    public String getButtonLabel() {    return isAddMe ? 'Add Me' : 'Remove Me';    }
    
    private Boolean isAddMe; // To check the Add/Remove Me
    public Boolean isStatusClosed  {get;set;}
    private String strSObjectId; // To get the account id
    private List<Contact> lstContacts; // To get the associated contacts
    private List<External_Working_Group_Member__c> lstWGMembers; // To get the list of working group members
    private String strSObjectType; // To get the SObject Type
    private String StrKeyPrefix = Deal__c.sObjectType.getDescribe().getKeyPrefix();
    
    public SL_AddRemoveWGUserCtrl() { 

        isAddMe = true;
        isStatusClosed = false;
        strSObjectId = apexPages.currentPage().getParameters().get('id');
        
        if(strSObjectId != NULL && strSObjectId.startsWith(StrKeyPrefix))
        {
          String strAmsecStatus = [Select Id, Deal_Status__c From Deal__c where Id=:strSObjectId].Deal_Status__c;
           // Checking the Amsec status..
          if(strAmsecStatus == 'Closed' || strAmsecStatus == 'Dead'|| strAmsecStatus == 'Entered as Dead'){
            isStatusClosed = true;
          }
        }  


        lstWGMembers = new List<External_Working_Group_Member__c>();

        lstContacts = [SELECT Id FROM Contact WHERE Salesforce_User__c =: UserInfo.getUserId()];

        strSObjectType = ((Id)strSObjectId).getSObjectType().getDescribe().getName();

        String queryStr = '';

        if(!lstContacts.isEmpty()){

            Id contactId = lstContacts[0].Id;

            if(strSObjectType == 'Account'){
                queryStr = 'SELECT Id, Initial_Participation_Date__c, End_Date__c FROM External_Working_Group_Member__c WHERE Contact__c =: contactId AND Company__c =: strSObjectId ORDER BY CreatedDate DESC LIMIT 1';
            }else if(strSObjectType == 'AS_Project__c'){
                queryStr = 'SELECT Id, Initial_Participation_Date__c, End_Date__c FROM External_Working_Group_Member__c WHERE Contact__c =: contactId AND AS_Project__c =: strSObjectId ORDER BY CreatedDate DESC LIMIT 1';
            }else if(strSObjectType == 'Deal__c'){
                queryStr = 'SELECT Id, Initial_Participation_Date__c, End_Date__c FROM External_Working_Group_Member__c WHERE Contact__c =: contactId AND Deal__c =: strSObjectId ORDER BY CreatedDate DESC LIMIT 1';
            }

            for(External_Working_Group_Member__c objWGM : Database.query(queryStr)){

                lstWGMembers.add(objWGM);

                //If they are a working group member AND the End_Date__c isblank, the Button Text should display Remove Me
                if(objWGM.End_Date__c == null){
                    isAddMe = false;
                }
            }
        }
    }


    public void addRemoveMe(){

        if(isAddMe){
            if(!lstContacts.isEmpty()){
                if(lstWGMembers.isEmpty()){
                    External_Working_Group_Member__c objWGMembersToInsert = new External_Working_Group_Member__c(
                                                            Contact__c = lstContacts[0].Id, 
                                                            Initial_Participation_Date__c = System.today()
                                                        );
                    if(strSObjectType == 'Account'){
                        objWGMembersToInsert.Company__c = strSObjectId;
                    }else if(strSObjectType == 'AS_Project__c'){
                        objWGMembersToInsert.AS_Project__c = strSObjectId;
                    }else if(strSObjectType == 'Deal__c'){
                        objWGMembersToInsert.Deal__c = strSObjectId;
                    }
                    
                    insert objWGMembersToInsert;
                }else{
                    for(External_Working_Group_Member__c objWGMember : lstWGMembers){
                        objWGMember.End_Date__c = null;
                    }
                    if(!lstWGMembers.isEmpty())
                        update lstWGMembers;
                }
            }   
        }else{
            if(!lstContacts.isEmpty()){
                if(!lstWGMembers.isEmpty()){
                    for(External_Working_Group_Member__c objWGMember : lstWGMembers){
                        objWGMember.End_Date__c = System.today();
                    }
                    if(!lstWGMembers.isEmpty())
                        update lstWGMembers;
                }
            }
        }
        
    }
}