/*************************************************************************
Name : BatchAssociateUserAndContact 
Author : Reena Acharya
Date : 3 August , 2013
Usage : This batch is used to Associate User And Contact 
**************************************************************************/
global class BatchAssociateUserAndContact implements Database.Batchable<SObject>{
    public string query{get;set;}
    
    global database.querylocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, LIST<SObject> listData){
        
        //Create a set of email address of contact.
        List<Contact> contacts = (List<Contact>)listData;
        Set<String> emailAddresses = new Set<String>();
        for(Contact cont : contacts){
            emailAddresses.Add(cont.Email);
        }
        
        //Create a map of user with Email address.
        Map<string , User> userEmails = new Map<String , User>();
        List<User> users = new List<User>([Select id,Email from User where email in : emailAddresses]);
        for(User u : users){
            userEmails.put(u.Email, u);
        }
        
        //Check for users who have same email address as Contact
        //Then associated that user to the respective contact.
        List<Contact> contToUpdate = new List<Contact>();
        for(Contact cont : contacts){
            if(userEmails.ContainsKey(cont.Email)){
                cont.User__c = userEmails.get(cont.Email).ID;
                contToUpdate.Add(cont);
            }
        }
        //Update contacts
        if(contToUpdate.size() > 0)
            update contToUpdate;
        
    }
    
    global void finish(Database.BatchableContext BC){
         
    }
   }