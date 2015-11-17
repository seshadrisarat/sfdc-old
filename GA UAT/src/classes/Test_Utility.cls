/********************************************************************************
**@author : Harshit Jain (Appirio Offshore)
**@date     : 26/10/2012
**@description : This class has many static helper methods used elsewhere.
********************************************************************************/
public with sharing class Test_Utility {

      /*
    **@Method Name : createAccount
    **@description : method to return new account record.  
    **@parameters  : name, parentId
    **@returns     : inserted new account record
    */
    public static Account createAccount(String name,Id parentId, String recordTypeName) {
        Account account = new Account(Name = name, ParentId = parentId, RecordTypeId = fetchRecordTypeIdFromName(recordTypeName));
        return account;
    }
    
    /*
    **@Method Name : createCommitment
    **@description : method to return new commitment record.  
    **@parameters  : Name,investorId
    **@returns     : inserted new commitment record
    */
    public static Investor_Commitment_Agreement__c  createCommitment(String name, Id investorId) {
        Investor_Commitment_Agreement__c  commitment = new Investor_Commitment_Agreement__c (Full_Name__c  = name, Investor__c = investorId);
        return commitment;
    }
    
    /*
    **@Method Name : createContact
    **@description : method to return new contact record.  
    **@parameters  : lastName,AccountId
    **@returns     : inserted new contact record
    */
    public static Contact createContact(String lastName, Id accountId) {
        Contact contact = new Contact(FirstName = 'Test', LastName = lastName, Email = 'test'+lastName+'contact@test.com', AccountId = accountId);
        return contact;
    }
    
  /*
    **@Method Name : extract recordTypeId from name
    **@description : method to return recordTypeId.  
    **@parameters  : recordTypeName
    **@returns     : record type Id
    */
   private static String fetchRecordTypeIdFromName(String recordTypeName) {
     String recordTypeId ;
     Schema.DescribeSObjectResult tskResult = Schema.SObjectType.Account;
     Map<String,Schema.RecordTypeInfo> rtMapByName = tskResult.getRecordTypeInfosByName();
     if(rtMapByName.containsKey(recordTypeName))
     recordTypeId = rtMapByName.get(recordTypeName).getRecordTypeId(); 
     return recordTypeId;
     
   }
   
   //Start - S-117095 (Modified by Anuradha Suthar on May 20, 2013)
   //Create GA Network Request
   public static GA_Network_Request__c createGANetworkRequest(String RequestTopic, String status, boolean isInsert){
       GA_Network_Request__c GANR = new GA_Network_Request__c(name=RequestTopic,
                                                              status__c = status);
       if(isInsert)
           insert GANR;
       return GANR;                                                       
   }
   
   //Create GA Network Finding
   public static GA_Network_Finding__c createGAFinding(ID contact, ID GARequest, String status, boolean isInsert){
       GA_Network_Finding__c GAF = new GA_Network_Finding__c(Contact__c=contact,
                                                              GA_Network_Request__c =GARequest,
                                                              status__c = status);
       if(isInsert)
           insert GAF;
       return GAF;                                                       
   }
   //End - S-117095
}