global class chatterFollowListBatch implements Database.Batchable<sObject>{ 
global String query; 
	global String email; 
	global Id followList;
	global database.querylocator start(Database.BatchableContext BC){ 
		return Database.getQueryLocator(query);} 
		
	global void execute(Database.BatchableContext BC,List<sObject> scope){ 
		Map<Id,Set<Id>> userAndFollows = new Map<Id,Set<Id>>();
		
		List<Chatter_Follow_List__c> chatterLists = new List<Chatter_Follow_List__c>();
		chatterLists = [Select c.RecordType.Name, c.Name, c.Id,(select User__c from Chatter_Users__r) From Chatter_Follow_List__c c where Id = :followList];
		if(chatterLists.size()==1){
			for(sObject s : scope){User thisUser = (User)s; 
				
				for(Chatter_List_User__c thisUsertoBeFollowed : chatterLists[0].Chatter_Users__r){
					if(chatterLists[0].RecordType.Name == 'Everyone Follows List'){
						chatterFollowRules.createFollow(userAndFollows, thisUsertoBeFollowed.User__c, thisUser.Id, false);
					} else if (chatterLists[0].RecordType.Name == 'Follows Everyone List'){
						chatterFollowRules.createFollow(userAndFollows, thisUser.Id, thisUsertoBeFollowed.User__c, false);
					}
				}				
			}
		}
	
		if(userAndFollows.size()>0){
		    	
			List<EntitySubscription> newSubscriptions = new List<EntitySubscription> ();
			
		    for(Id thisUserId : userAndFollows.keySet()){
		        for(Id followerId : userAndFollows.get(thisUserId)){                	
		        	newSubscriptions.addAll(chatterFollowRules.createSubscriptions(thisUserId, followerId));
		        }
		    }        
		    Database.SaveResult[] lsr = Database.insert(newSubscriptions, false);
		}
	}
	
	global void finish(Database.BatchableContext BC){ 
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
		mail.setToAddresses(new String[]{email}); 
		mail.setReplyTo('batch@acme.com'); 
		mail.setSenderDisplayName('Batch Processing'); 
		mail.setSubject('Batch Process Completed: ' + followList); 
		
		mail.setPlainTextBody('Batch Process has completed'); 
		Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail}); 
	} 
	
	static testMethod void testchatterFollowListBatch() {/*
		Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Chatter_Follow_List__c; 
    	Map<String,Schema.RecordTypeInfo> chatterRulesRTMap = cfrSchema.getRecordTypeInfosByName();
    	
		List<Chatter_Follow_List__c> existingRules = [select id from Chatter_Follow_List__c];
    	delete existingRules;
    	
    	User thisUser = [ select Id,ProfileId,LocaleSidKey, TimeZoneSidKey, LanguageLocaleKey, EmailEncodingKey from User where Id = :UserInfo.getUserId() ];
		
		User user1 = new User();
    	user1.FirstName = 'Joe';
    	user1.LastName = 'smith';
    	user1.ProfileId = thisUser.ProfileId;
    	user1.LocaleSidKey = thisUser.LocaleSidKey;
    	user1.TimeZoneSidKey = thisUser.TimeZoneSidKey;
    	user1.LanguageLocaleKey = thisUser.LanguageLocaleKey;
    	user1.EmailEncodingKey = thisUser.EmailEncodingKey;
    	user1.alias = 'user1';
    	user1.username = 'user1@adfjkluiopasfuioasjijklasdfjlajio.com';
    	user1.CommunityNickname = 'user1adfjkluiopasfuioasjijklasdfjlajio';
    	user1.email = 'user1@email.com';
    	insert user1;
		    	
    	Chatter_Follow_List__c bigwigs = new Chatter_Follow_List__c();
    	bigwigs.Name = 'bigwigs';
    	bigwigs.RecordTypeId = chatterRulesRTMap.get('Everyone Follows List').getRecordTypeId();
    	insert bigwigs;
    	
    	Chatter_List_User__c bigWig = new Chatter_List_User__c();
    	bigWig.Chatter_Follow_List__c = bigwigs.id;
    	bigWig.User__c = user1.id;
    	insert bigWig;
		
		chatterFollowListBatch chatterBatch = new chatterFollowListBatch(); 
		chatterBatch.query = 'select Id,ManagerId,Manager.ManagerId,Manager.Manager.ManagerId,Manager.Manager.Manager.ManagerId,UserRoleId,ProfileId,Department,Division from User where isActive = true'; 
				
		chatterBatch.email =[select email from User where Id = :UserInfo.getUserId()].email; 
		chatterBatch.followList = bigwigs.Id; 
		
		Test.startTest();
		
		User user6 = new User();
    	user6.FirstName = 'Joe';
    	user6.LastName = 'smith';
    	user6.ProfileId = thisUser.ProfileId;
    	user6.LocaleSidKey = thisUser.LocaleSidKey;
    	user6.TimeZoneSidKey = thisUser.TimeZoneSidKey;
    	user6.LanguageLocaleKey = thisUser.LanguageLocaleKey;
    	user6.EmailEncodingKey = thisUser.EmailEncodingKey;
    	user6.alias = 'user6';
    	user6.username = 'user@adfjkluiopasfuioasjijklasdfjlajio.com';
    	user6.CommunityNickname = 'user6adfjkluiopasfuioasjijklasdfjlajio';
    	user6.email = 'user6@email.com';
    	
    	insert user6;
    	
		ID batchprocessid = Database.executeBatch(chatterBatch);  
		Test.stopTest();*/
	}
}