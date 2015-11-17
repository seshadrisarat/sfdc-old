public with sharing class chatterFollowLists {

    public static Map<Id,Set<Id>> userAndFollows = new Map<Id,Set<Id>>();
    
    @future
    public static void processNewUser(Set<Id> userIds){    
        
        List<EntitySubscription> newSubscriptions = new List<EntitySubscription> ();
              
        List<User> users = [select Id from User where Id IN :userIds and isActive = true];
        if(users.size()>0){
            //follow a list of key staff
            List<Chatter_List_User__c> followThese = [Select c.User__c From Chatter_List_User__c c Where c.Chatter_Follow_List__r.RecordType.Name='Everyone Follows List' and c.User__r.isActive = true];
            
            for(User thisUser : users){
                for(Chatter_List_User__c thisFollowUser : followThese){
                    createFollow(thisFollowUser.User__c, thisUser.Id, false);
                }
            }
        
            //be followed by a list
            List<Chatter_List_User__c> followedByThese = [Select c.User__c, c.Chatter_Follow_List__c From Chatter_List_User__c c Where c.Chatter_Follow_List__r.RecordType.Name='Follows Everyone List' and c.User__r.isActive = true];
            
            for(User thisUser : users){
                for(Chatter_List_User__c thisFollowUser : followedByThese){
                    createFollow(thisUser.Id, thisFollowUser.User__c, false);
                }           
            }
        }
        
        if(userAndFollows.size()>0){
            for(Id thisUserId : userAndFollows.keySet()){
                for(Id followerId : userAndFollows.get(thisUserId)){
                    if(thisUserId!=null&&followerId!=null&&thisUserId!=followerId){
                        EntitySubscription newSub = new EntitySubscription();
                        newSub.parentid = thisUserId;
                        newSub.subscriberid = followerId;
                        newSubscriptions.add(newSub);
                    }
                }
            }               
            Database.SaveResult[] lsr = Database.insert(newSubscriptions, false);
        }
    }
    
    public static void createFollow(Id userId, Id followerId, Boolean bothWays){
        if(userId!=null && followerId!=null && userAndFollows.get(userId)==null){
            Set<Id> newFollowers = new Set<Id>();
            newFollowers.add(followerId);
            userAndFollows.put(userId,newFollowers);
        } else if (userId!=null && followerId!=null){
            userAndFollows.get(userId).add(followerId);
        }
        if(bothWays){
            if(userId!=null && followerId!=null && userAndFollows.get(followerId)==null){
                Set<Id> newFollowers = new Set<Id>();
                newFollowers.add(userId);
                userAndFollows.put(followerId,newFollowers);
            } else if (userId!=null && followerId!=null){
                userAndFollows.get(followerId).add(userId);
            }
        }
    }
    
     static testMethod void testToBeFollowedRule() {/*
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Chatter_Follow_List__c; 
        Map<String,Schema.RecordTypeInfo> chatterRulesRTMap = cfrSchema.getRecordTypeInfosByName();
        
        List<Chatter_Follow_List__c> existingRules = [select id from Chatter_Follow_List__c];
        delete existingRules;
        
        User thisUser = [ select Id,ProfileId,LocaleSidKey, TimeZoneSidKey, LanguageLocaleKey, EmailEncodingKey from User where Id = :UserInfo.getUserId() ];
        List<User> usersforCreation = new List<User>();
        
        
        
        Test.startTest();
        
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
        Test.stopTest();
        List<EntitySubscription> createdSubs = [select id,parentId,subscriberid from EntitySubscription where parentId = :user1.Id and subscriberid = :user6.Id];
        system.debug('createdSubs: ' + createdSubs);
        system.assertEquals(1,createdSubs.size());
        system.debug('createdSubs: ' + createdSubs);
        
        List<EntitySubscription> createdSubsReverse = [select id,parentId,subscriberid from EntitySubscription where subscriberid = :user1.Id and subscriberid = :user6.Id];
        system.debug('createdSubsReverse: ' + createdSubsReverse);
        system.assertEquals(0,createdSubsReverse.size());
        system.debug('createdSubsReverse: ' + createdSubsReverse);
    }
    
      static testMethod void testFollowAllRule() {
       /* Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Chatter_Follow_List__c; 
        Map<String,Schema.RecordTypeInfo> chatterRulesRTMap = cfrSchema.getRecordTypeInfosByName();
        
        List<Chatter_Follow_List__c> existingRules = [select id from Chatter_Follow_List__c];
        delete existingRules;
        
        User thisUser = [ select Id,ProfileId,LocaleSidKey, TimeZoneSidKey, LanguageLocaleKey, EmailEncodingKey from User where Id = :UserInfo.getUserId() ];
        List<User> usersforCreation = new List<User>();
        Test.startTest();
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
        bigwigs.RecordTypeId = chatterRulesRTMap.get('Follows Everyone List').getRecordTypeId();
        insert bigwigs;
        
        Chatter_List_User__c bigWig = new Chatter_List_User__c();
        bigWig.Chatter_Follow_List__c = bigwigs.id;
        bigWig.User__c = user1.id;
        insert bigWig;
        
        
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
        Test.stopTest();
        List<EntitySubscription> createdSubs = [select id,parentId,subscriberid from EntitySubscription where parentId = :user1.Id and subscriberid = :user6.Id];
        system.debug('createdSubs: ' + createdSubs);
        //system.assertEquals(0,createdSubs.size());
        system.debug('createdSubs: ' + createdSubs);
        
        List<EntitySubscription> createdSubsReverse = [select id,parentId,subscriberid from EntitySubscription where subscriberid = :user1.Id and parentId = :user6.Id];
        system.debug('createdSubsReverse: ' + createdSubsReverse);
        system.assertEquals(1,createdSubsReverse.size());
        system.debug('createdSubsReverse: ' + createdSubsReverse);*/
    }
    
}