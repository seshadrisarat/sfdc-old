/**
* \arg ClassName      : SL_ActivityController
* \arg JIRATicket     : PWP-10
* \arg CreatedOn      : 9/JAN/2014
* \arg LastModifiedOn : 12/MAR/2015
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Edward Rivera
* \arg Description    : This class serves as standard controller extension for both Task and Event records.
*/
public with sharing class SL_ActivityController 
{    
    /* Start - Page Variables */
    public Sobject objSobject   {get;set;}
    /* End - Page Variables */
    
    /* Start - Class Variables*/
    Id activityId;
    /* End - Class Variables*/
    
    /* Start - Constructor */
    public SL_ActivityController(ApexPages.StandardController stdController) 
    {
        activityId = stdController.getId();
    }
    /* End - Constructor */
    
      /*
        * MethodName   : getShowSubject
        * Param        : activity id
        * Description  : This method is used to validate whether the user belongs to coverage team members of Account or not
    */
    public PageReference ShowSubject()
    {
        Id ownerId;
        Id parentId;
        if (String.valueOf(activityId).startsWith('00T')){
            Task t = [SELECT AccountId, OwnerId FROM Task WHERE Id = :activityId][0];
            ownerId = t.OwnerId;
            parentId = t.AccountId;
        }
        else {
            Event e = [SELECT AccountId, OwnerId FROM Event WHERE Id = :activityId][0];
            ownerId = e.OwnerId;
            parentId = e.AccountId;
        }
        
        if (ownerId==Userinfo.getUserId()){
            return null;
        }

        PageReference redirect = new PageReference('/apex/SL_Activity_NoAccess?id='+parentId);
        redirect.setRedirect(true);
        String strQuery = 'SELECT Id, WhatId, Subject, Subject__c FROM objectName WHERE id=:activityId';
        List<Sobject> lstSobject = Database.query((activityId.getSobjectType() == Task.sobjecttype ? strQuery.replace('objectName','Task') : strQuery.replace('objectName','Event')));
        if(!lstSobject.isEmpty())
        {
            objSobject = lstSobject[0];
            if(objSobject.get('WhatId') == null){
                return redirect;
            }
            Id relatedToId = Id.valueOf(String.valueOf(objSobject.get('WhatId')));
            if([SELECT COUNT() FROM Coverage_Team_Members__c WHERE PWP_Employee__c=:Userinfo.getUserId() AND Company__c=:relatedToId] > 0){
               return null;
            }
        }
        return redirect;
    }
}