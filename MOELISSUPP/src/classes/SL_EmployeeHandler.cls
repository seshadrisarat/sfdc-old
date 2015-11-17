/*
* Class Name    : SL_EmployeeHandler
* JIRA Ticket   : Moelis-116
* Created on    : 19/11/2013
* Created by    : Rahul Majumdar
* Jira ticket   : http://silverline.jira.com/browse/Moelis-116
* Description   : Handler for SL_Employee_Profile trigger (trigger on Employee_Profile__c)
*/
public without sharing class SL_EmployeeHandler   
{

    /* Start - Local and global variables*/
    private Integer intBatchSize = 0;
    private Boolean isExecuting = false;
    /* stop - Local and global variables*/
    
    //Constructor of the handler
    public SL_EmployeeHandler(Boolean isExecuting, Integer intBatchSize)
    {
        //Intializing the variables
        this.isExecuting = isExecuting;
        this.intBatchSize = intBatchSize;
    }
    
    public void onAfterInsert(Map<Id,Employee_Profile__c> mapNewIdToEmployee)
    {
        //Updating fields on related Users 
        updateFieldsOnUsers(mapNewIdToEmployee, null);
    }

    public void onAfterUpdate(Map<Id,Employee_Profile__c> mapNewIdToEmployee , Map<Id,Employee_Profile__c> mapOldIdToEmployee)
    {
        //Updating fields on related Users if corresponding fields on Employee have been changed  
        updateFieldsOnUsers(mapNewIdToEmployee, mapOldIdToEmployee);
    }
    
    /** 
    * \author: Rahul Majumdar 
    * \date: 19/11/2013
    * \ http://silverline.jira.com/browse/Moelis-116
    * \Description: Updating fields on related Users if Employee is created or corresponding fields on related Employee have been changed 
    */
    private void updateFieldsOnUsers(Map<Id,Employee_Profile__c> mapNewIdToEmployee , Map<Id,Employee_Profile__c> mapOldIdToEmployee)
    {
        List<User> listUsersToUpdate = new List<User>(); //Will contain the list of User records to update if parent Employee objects field is updated 
        Map<Id,Employee_Profile__c> mapUserIdToUpsertedEmployee = new Map<Id,Employee_Profile__c>();// Contains the map of User id to updated/inserted Employee 
        Map<Id,String> mapAssistantIdToName = new Map<Id,String>(); // Map of Employee Id to Name 
        Set<Id> setAssistantIds = new Set<Id>(); //set of Assistant ids
        
        //Fetching updated/inserted Employee records
        for(Employee_Profile__c objEmployee :mapNewIdToEmployee.values())
        {
            //Checking if Employee status is active and User_ID__c is not null
            if (objEmployee.Status__c == 'Active' && objEmployee.User_ID__c != null && ( mapOldIdToEmployee == null || ( mapOldIdToEmployee !=null && (
            //Chceking if any of the mentioned field or User_ID__c has been updated (in  update)
                    objEmployee.Title__c != mapOldIdToEmployee.get(objEmployee.Id).Title__c 
                || objEmployee.Internal_Dial__c != mapOldIdToEmployee.get(objEmployee.Id).Internal_Dial__c
                || objEmployee.Mobile_Phone__c != mapOldIdToEmployee.get(objEmployee.Id).Mobile_Phone__c 
                || objEmployee.Assistant__c != mapOldIdToEmployee.get(objEmployee.Id).Assistant__c 
                || objEmployee.Business_Type__c != mapOldIdToEmployee.get(objEmployee.Id).Business_Type__c 
                || objEmployee.Group__c != mapOldIdToEmployee.get(objEmployee.Id).Group__c 
                || objEmployee.Start_Date__c != mapOldIdToEmployee.get(objEmployee.Id).Start_Date__c 
                || objEmployee.Assistant_Internal_Dial__c != mapOldIdToEmployee.get(objEmployee.Id).Assistant_Internal_Dial__c
                || objEmployee.Asst_Phone__c != mapOldIdToEmployee.get(objEmployee.Id).Asst_Phone__c
                || objEmployee.User_ID__c != mapOldIdToEmployee.get(objEmployee.Id).User_ID__c
                || objEmployee.Bio__c != mapOldIdToEmployee.get(objEmployee.Id).Bio__c
                || mapOldIdToEmployee.get(objEmployee.Id).Status__c != 'Active' ))
               ))
            {
                mapUserIdToUpsertedEmployee.put(objEmployee.User_ID__c,objEmployee);
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
}