@isTest
private class Test_twitter_Interface 
{
    static testMethod void Test_twitter_Interface() 
    {
        // Insert Custom Setting
        Twitter_Key__c objTwitterKey = new Twitter_Key__c (Name='Twitter Search API',
        												   Access_Token__c = 'testAccessToken',
														   Access_Token_Secret__c = 'testSecret',
														   Consumer_Key__c = 'testConsumer',
														   Consumer_Secret_Key__c = 'testConsumerSecret',
														   Search_Result__c = 15);
        																					
        insert objTwitterKey;
        
        // Inserting Account
        Account objAccount = new Account (Name =  'testAccount\'()*,', TRKBTweetForce__twitterHandler__c = 'testHandler');
        insert objAccount;
        
        Contact objContact = new Contact (FirstName =  'testContact\'()*,',LastName = 'testCon', TRKBTweetForce__twitterHandler__c = 'testHandlerCon');
        insert objContact;
        
        Lead objLead = new Lead (LastName =  'testLead\'()*,', FirstName = 'testLead', Company = 'testComp', TRKBTweetForce__twitterHandler__c = 'testHandlerLead');
        insert objLead;
        
        // Calling fetchUsersFromTwitter method
 		twitter_Interface.fetchUsersFromTwitter(objAccount.Id);		
 		
 		// Calling fetchObjectFields method
 		twitter_Interface.fetchObjectFields('Account');
 		
 		// Calling fetchTweetsFromTwitter method
 		twitter_Interface.fetchTweetsFromTwitter('testScreen');
 		
 		// Callnig saveTwitterId method
 		twitter_Interface.saveTwitterId('testScreen', objAccount.Id);
 		twitter_Interface.saveTwitterId('testScreen', objContact.Id);
 		twitter_Interface.saveTwitterId('testScreen', objLead.Id);
    }
}