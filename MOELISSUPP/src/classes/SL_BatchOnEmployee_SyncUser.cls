/*
* Class Name    : SL_BatchOnEmployee_SyncUser
* JIRA Ticket   : Moelis-117
* Created on    : 20/11/2013
* Created by    : Sandeep
* Jira ticket   : http://silverline.jira.com/browse/Moelis-117
* Description   : It updates existing User records in sync with Employee records
*/

global without sharing class SL_BatchOnEmployee_SyncUser implements Database.Batchable<Sobject>
{
    /*  Start : Constructor */
    public SL_BatchOnEmployee_SyncUser( )   
    { 
    }

    /*
        @MethodName : start 
        @param      : Database.BatchableContext BC
        @Description: Queries the Employee records 
    */
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        string strQuery = 'select Id, Name, Title__c, Status__c, Internal_Dial__c, Assistant_Internal_Dial__c, Asst_Phone__c, Mobile_Phone__c, Assistant__c,'+ 
        ' Business_Type__c, Group__c ,Start_Date__c, Bio__c, User_ID__c'+
        ' From Employee_Profile__c where Status__c = \'Active\' AND User_ID__c != null ' ;
        return Database.getQueryLocator(strQuery);
    }
    /*
        @MethodName : execute 
        @param      : Database.BatchableContext BC, List<Employee_Profile__c> listEmployees
        @Description: Processes the Employee records recieved from the Start method in batches
    */
    global void execute(Database.BatchableContext BC, List<Employee_Profile__c> listEmployees)
    {
        updateFieldsOnUsers(ListEmployees); 
    }
    
    /** 
    * \author: Sandeep
    * \date: 20/11/2013
    * \ http://silverline.jira.com/browse/Moelis-117
    * \Description: Updating fields on related Users in sync with Employee 
    */
    private void updateFieldsOnUsers(List<Employee_Profile__c> listEmployees)
    {
        List<User> listUsersToUpdate = new List<User>(); //Will contain the list of User records to update if parent Employee objects field is updated 
        Map<Id,Employee_Profile__c> mapUserIdToUpsertedEmployee = new Map<Id,Employee_Profile__c>();// Contains the map of User id to updated/inserted Employee 
        Map<Id,String> mapAssistantIdToName = new Map<Id,String>(); // Map of Employee Id to Name to be used in field mapping 
        Set<Id> setAssistantIds = new Set<Id>(); //set of Assistant ids
        
        for(Employee_Profile__c objEmployee : listEmployees)
        {
            //Checking if Employee status is active and User_ID__c is not null
            if (objEmployee.Status__c == 'Active' && objEmployee.User_ID__c != null)
            {
                mapUserIdToUpsertedEmployee.put(objEmployee.User_ID__c,objEmployee);
                //Storing Assistant Id to set
                setAssistantIds.add(objEmployee.Assistant__c);
            }
        }
        
        //Storing Employee name in map mapAssistantIdToName
        for(Employee_Profile__c objEmployee : [Select Id, Name from Employee_Profile__c where Id In:setAssistantIds])
        {
            mapAssistantIdToName.put(objEmployee.Id,objEmployee.Name);
        }
        
        //Checking if Employee have been created/updated
        if(!mapUserIdToUpsertedEmployee.keyset().isEmpty())
        {
            //Updating fields on User if corresponding fields have been changed on related Employee
            for(User objUser : [ Select Id From User where Id IN: mapUserIdToUpsertedEmployee.keyset()])
            {
                if(mapUserIdToUpsertedEmployee != null && mapUserIdToUpsertedEmployee.containsKey(objUser.Id))
                {
                    listUsersToUpdate.add(new User(Id= objUser.Id,
                    Title = mapUserIdToUpsertedEmployee.get(objUser.Id).Title__c ,
                    Internal_Dial_In__c = mapUserIdToUpsertedEmployee.get(objUser.Id).Internal_Dial__c, 
                    MobilePhone = mapUserIdToUpsertedEmployee.get(objUser.Id).Mobile_Phone__c , 
                    Assistant_1__c = mapUserIdToUpsertedEmployee.get(objUser.Id).Assistant__c != null ? 
                                    mapAssistantIdToName.get(mapUserIdToUpsertedEmployee.get(objUser.Id).Assistant__c): '' ,
                    Business_Type__c = mapUserIdToUpsertedEmployee.get(objUser.Id).Business_Type__c , 
                    Group__c = mapUserIdToUpsertedEmployee.get(objUser.Id).Group__c , 
                    SLSI__Hire_Date__c  = mapUserIdToUpsertedEmployee.get(objUser.Id).Start_Date__c , 
                    Bio_Employee__c = mapUserIdToUpsertedEmployee.get(objUser.Id).Bio__c ,
                    Assistant_Internal_Dial__c = mapUserIdToUpsertedEmployee.get(objUser.Id).Assistant_Internal_Dial__c,
                    Assistant_Phone__c = mapUserIdToUpsertedEmployee.get(objUser.Id).Asst_Phone__c
                    ));
                }
            }
        }
        
        //Updating user records where corresponding fields have been updated on related Employee
        if(!listUsersToUpdate.isEmpty())
            database.update(listUsersToUpdate,false);
    }
    
    
    /*
        @MethodName : finish 
        @param      : Database.BatchableContext BC
        @Description: Performs the post-execution steps
    */
    global void finish(Database.BatchableContext BC)
    {
        //Do nothing
    }
}