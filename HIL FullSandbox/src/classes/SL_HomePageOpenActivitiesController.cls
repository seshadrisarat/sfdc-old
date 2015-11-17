/**
*  ClassName      : SL_HomePageOpenActivitiesController 
*  JIRATicket     : HIL-33
*  CreatedOn      : 24/SEP/2015
*  ModifiedBy     : Sanath
*  Description    : This class serves as controller for Home page VF page namely SL_HomePageOpenActivities 
*/

public class SL_HomePageOpenActivitiesController 
{
    /* Start - Variables */
    public List<Note__c> lstOpenNotes              {get;set;}
    public Boolean renderPageBlock                 {get;set;}
    /* End - Variables */
    
    /* Start - Constructor */ 
    public SL_HomePageOpenActivitiesController()
    {
        lstOpenNotes = new List<Note__c>();
        fetchOpenActivities();
    }
    /* End - Constructor */
    
     /*
        * MethodName        : fetchOpenActivities
        * param             : -
        * Description       : This function fetches all the open activities related to the current logged in user in descending order with LIMIT 5
    */
      
    private void fetchOpenActivities()
    { 
        for(Note__c objNote : [Select   Id, 
                                        Type__c,
                                        Status__c,
                                        CreatedDate,
                                        OwnerId, 
                                        Subject_Text__c
                               FROM Note__c 
                               WHERE Status__c='Open' 
                               AND Type__c='Task'
                               AND OwnerId =: userinfo.getuserid()
                               ORDER BY CreatedDate DESC LIMIT 5])
        {
            lstOpenNotes.add(objNote);
        }
        
        if(!lstOpenNotes.isEmpty())
            renderPageBlock = true;
        else
           {    
               renderPageBlock = false;
               Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'No Open Activities to Display'));
           }
    }
}