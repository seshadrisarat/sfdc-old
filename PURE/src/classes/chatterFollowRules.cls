public class chatterFollowRules {
    
    private static Map<Id,Set<Id>> userAndFollows = new Map<Id,Set<Id>>();
    
    @future
    public static void processNewUser(Set<Id> userIds, Set<Id> managerChangesIds){
        
        Chatter_Follow_Rules__c chatterFollowSettings = Chatter_Follow_Rules__c.getInstance();
        system.debug('chatterFollowSettings: ' + chatterFollowSettings);
        
            Boolean FOLLOW_TEAM = false;
            Boolean FOLLOW_EVERYONE = false;
            Boolean FOLLOW_ROLE = false;
            Boolean FOLLOW_PROFILE = false;
            Boolean FOLLOW_DEPARTMENT = false;
            Boolean FOLLOW_DIVISION = false;
            Boolean FOLLOW_MANAGER_HIERARCHY = false;
            
        if (chatterFollowSettings!=null){
        	FOLLOW_EVERYONE = chatterFollowSettings.Follow_Everyone__c;
            FOLLOW_TEAM = chatterFollowSettings.Follow_Team__c;
            FOLLOW_ROLE = chatterFollowSettings.Follow_Role__c;
            FOLLOW_PROFILE = chatterFollowSettings.Follow_Profile__c;
            FOLLOW_DEPARTMENT = chatterFollowSettings.Follow_Department__c;
            FOLLOW_DIVISION = chatterFollowSettings.Follow_Division__c;
            FOLLOW_MANAGER_HIERARCHY = chatterFollowSettings.Follow_Manager_Hierarchy__c;           
        }
       

        List<User> users = [select Id,ManagerId,Manager.ManagerId,Manager.Manager.ManagerId,Manager.Manager.Manager.ManagerId,UserRoleId,ProfileId,Department,Division from User where Id IN :userIds and isActive = true and UserType='Standard'];
        if(users.size()>0){
            
            if(FOLLOW_EVERYONE){
            
                List<User> everyone = new List<User>();
                try {
                    everyone = [select Id,ManagerId from User where isActive = true];
                } catch (QueryException e){
                    for(User thisUser : users){
                        thisUser.addError('there was a problem following everyone: ' + e.getMessage());
                    }
                }
                
                if (everyone.size()>0){
                    for(User thisUser : users){
                        for(User thisOtherUser : everyone){ 
                            createFollow(userAndFollows, thisUser.Id, thisOtherUser.Id, true); 
                        }                       
                    }
                }
                
            } else {
            
                if (FOLLOW_TEAM){
                    
                    Set<Id> managers = new Set<Id>();
                
                    Map<id,Set<id>> managerAndTeamMembers = new Map<id,Set<id>>();
                    
                    for(User thisUser : users){
                        if (thisUser.ManagerId!=null){
                            managers.add(thisUser.ManagerId);                   
                        }
                    }
                    if(managers.size()>0){
                        List<User> teamMembers = new List<User>();
                        
                        try {
                            teamMembers = [select Id,ManagerId from User where ManagerId IN :managers and isActive = true];
                        } catch (QueryException e){
                            for(User thisUser : users){
                                thisUser.addError('there was a problem following all team members: ' + e.getMessage());
                            }
                        }

                        if (teamMembers.size()>0){
                            for(User thisUser : teamMembers){                       
                                
                                if(managerAndTeamMembers.get(thisUser.ManagerId)==null){
                                    Set<Id> newTeamMembers = new Set<Id>();
                                    newTeamMembers.add(thisUser.Id);
                                    managerAndTeamMembers.put(thisUser.ManagerId,newTeamMembers);
                                } else {
                                    managerAndTeamMembers.get(thisUser.ManagerId).add(thisUser.Id);
                                }
                            
                            
                                if (managerAndTeamMembers.size()>0){
                                    for(User thisTriggerUser : users){
                                        if (managerAndTeamMembers.get(thisUser.ManagerId)!=null){
                                            for(Id thisTeamMemberId : managerAndTeamMembers.get(thisTriggerUser.ManagerId)){    
                                                createFollow(userAndFollows, thisTriggerUser.Id, thisTeamMemberId, true);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            
                if(FOLLOW_MANAGER_HIERARCHY){
                    
                    List<User> affectedUsers = new List<User>();
                    List<User> bottomReports = new List<User>();
                    
                    List<User> goingUp = new List<User>();
                    
                    IF(managerChangesIds==null){
                        affectedUsers = users;
                    } else {
                        affectedUsers = [select Id,ManagerId from User where (ManagerId IN :managerChangesIds OR Manager.ManagerId IN :managerChangesIds OR Manager.Manager.ManagerId IN :managerChangesIds) and isActive = true];
                        bottomReports = [select Id,ManagerId from User where Manager.Manager.Manager.ManagerId IN :managerChangesIds and isActive = true];
                        
                    }
                    
                    affectedUsers.addAll(bottomReports);
                    
                    Map<Id,Id> userToManager = new Map<Id,Id>();
                    for(User thisAffectedUser : affectedUsers){
                        if(thisAffectedUser.ManagerId!=null){
                            userToManager.put(thisAffectedUser.Id,thisAffectedUser.ManagerId);  
                        }                    
                    }
                    //second pass
                    if(bottomReports.size()>0){
                        affectedUsers = [select Id,ManagerId from User where (ManagerId IN :bottomReports OR Manager.ManagerId IN :bottomReports OR Manager.Manager.ManagerId IN :bottomReports OR Manager.Manager.Manager.ManagerId IN :bottomReports) and isActive = true];
                        
                        for(User thisAffectedUser : affectedUsers){
                            userToManager.put(thisAffectedUser.Id,thisAffectedUser.ManagerId);                      
                        }
                    }
                    //go up from affected users
                    IF(managerChangesIds==null){
                        goingUp = [select Id,ManagerId,Manager.ManagerId,Manager.Manager.ManagerId,Manager.Manager.Manager.ManagerId from User where (Id IN :users) and isActive = true];
                    } else {
                        goingUp = [select Id,ManagerId,Manager.ManagerId,Manager.Manager.ManagerId,Manager.Manager.Manager.ManagerId from User where (Id IN :managerChangesIds) and isActive = true];
                        
                    }
                    Set<Id> toppedOutUserIds = new Set<Id>();
                    for(User upUser : goingUp){
                        if(upUser.ManagerId!=null){
                            userToManager.put(upUser.Id,upUser.ManagerId);
                            if(upUser.Manager.ManagerId!=null){
                                userToManager.put(upUser.ManagerId,upUser.Manager.ManagerId);
                            }
                            
                            if(upUser.Manager.Manager.ManagerId!=null){
                                userToManager.put(upUser.Manager.ManagerId,upUser.Manager.Manager.ManagerId);
                            }
                            
                            if(upUser.Manager.Manager.Manager.ManagerId!=null){
                                userToManager.put(upUser.Manager.Manager.ManagerId,upUser.Manager.Manager.Manager.ManagerId);
                                toppedOutUserIds.add(upUser.Manager.Manager.Manager.ManagerId);
                            }
                        }
                    }
                    
                    if(toppedOutUserIds.size()>0){
                        goingUp = [select Id,ManagerId,Manager.ManagerId,Manager.Manager.ManagerId,Manager.Manager.Manager.ManagerId from User where (Id IN :toppedOutUserIds) and isActive = true];
                        
                    }
                    
                    for(User upUser : goingUp){
                        if(upUser.ManagerId!=null){
                            userToManager.put(upUser.Id,upUser.ManagerId);
                            if(upUser.Manager.ManagerId!=null){
                                userToManager.put(upUser.ManagerId,upUser.Manager.ManagerId);
                            }
                            
                            if(upUser.Manager.Manager.ManagerId!=null){
                                userToManager.put(upUser.Manager.ManagerId,upUser.Manager.Manager.ManagerId);
                            }
                            
                            if(upUser.Manager.Manager.Manager.ManagerId!=null){
                                userToManager.put(upUser.Manager.Manager.ManagerId,upUser.Manager.Manager.Manager.ManagerId);
                                toppedOutUserIds.add(upUser.Manager.Manager.Manager.ManagerId);
                            }
                        }
                    }

                    for(Id userId : userToManager.keySet()){
                        Id currentManagementId = userToManager.get(userId);
                        createFollow(userAndFollows, currentManagementId,userId,  false);
                        While(userToManager.get(currentManagementId)!=null){
                            currentManagementId = userToManager.get(currentManagementId);
                            createFollow(userAndFollows, currentManagementId,userId,  false);                           
                        }
                    }                   
                }
                
                if (FOLLOW_ROLE){
                    
                    Set<Id> roles = new Set<Id>();
                    
                    for(User thisUser : users){
                        if (thisUser.UserRoleId!=null){
                            roles.add(thisUser.UserRoleId);                 
                        }
                    }
                    if(roles.size()>0){
                        
                        List<User> roleMembers = new List<User>();
                        
                        try {
                            roleMembers = [select Id,UserRoleId from User where UserRoleId IN :roles and isActive = true];
                        } catch (QueryException e){
                            for(User thisUser : users){
                                thisUser.addError('there was a problem following all role members: ' + e.getMessage());
                            }
                        }
                        findAndCreateFollows(userAndFollows, users,roleMembers,'Role',true);                        
                    }
                }   
                
                if (FOLLOW_PROFILE){
                    
                    Set<Id> profiles = new Set<Id>();
                
                    Map<id,Set<id>> allProfileMembers = new Map<id,Set<id>>();
                    
                    for(User thisUser : users){
                        if (thisUser.profileId!=null){
                            profiles.add(thisUser.profileId);                   
                        }
                    }
                    if(profiles.size()>0){
                        
                        List<User> ProfileMembers = new List<User>();
                        
                        try {
                            ProfileMembers = [select Id,profileId from User where profileId IN :profiles and isActive = true];
                        } catch (QueryException e){
                            for(User thisUser : users){
                                thisUser.addError('there was a problem following all profile members: ' + e.getMessage());
                            }
                        }
                        findAndCreateFollows(userAndFollows, users,ProfileMembers,'Profile',true);  
                    }
                }   
                
                if (FOLLOW_DEPARTMENT){
                    
                    Set<String> departments = new Set<String>();
                
                    Map<String,Set<id>> allDepartmentMembers = new Map<String,Set<id>>();
                    
                    for(User thisUser : users){
                        if (thisUser.Department!=null){
                            departments.add(thisUser.Department);                   
                        }
                    }
                    if(departments.size()>0){
                        
                        List<User> departmentMembers = new List<User>();
                        
                        try {
                            departmentMembers = [select Id,Department from User where Department IN :departments and isActive = true];
                        } catch (QueryException e){
                            for(User thisUser : users){
                                thisUser.addError('there was a problem following all department members: ' + e.getMessage());
                            }
                        }          
                        findAndCreateFollows(userAndFollows, users,departmentMembers,'Department',true);
                    }
                } 
            
                if (FOLLOW_DIVISION){
                    
                    Set<String> divisions = new Set<String>();
                
                    Map<String,Set<id>> allDivisionMembers = new Map<String,Set<id>>();
                    
                    for(User thisUser : users){
                        if (thisUser.Division!=null){
                            divisions.add(thisUser.Division);                   
                        }
                    }
                    if(divisions.size()>0){
                        List<User> divisionMembers = new List<User>();
                        
                        try {
                            divisionMembers = [select Id,Division from User where Division IN :divisions and isActive = true];
                        } catch (QueryException e){
                            for(User thisUser : users){
                                thisUser.addError('there was a problem following all division members: ' + e.getMessage());
                            }
                        } 
                        findAndCreateFollows(userAndFollows, users,divisionMembers,'Division',true);                      
                    }
                }                       
            }   
        }
        
        system.debug('userAndFollows: ' + userAndFollows);
        if(userAndFollows.size()>0){
            
            List<EntitySubscription> newSubscriptions = new List<EntitySubscription> ();
            
            for(Id thisUserId : userAndFollows.keySet()){
                for(Id followerId : userAndFollows.get(thisUserId)){                    
                    newSubscriptions.addAll(createSubscriptions(thisUserId, followerId));
                }
            }

            Integer listSize = newSubscriptions.size();

            while(listSize > 10000){
                List<EntitySubscription> newSubscriptionsToInsert = new List<EntitySubscription> ();
                for(Integer i = listSize-1; i >= listSize-10000; i--){
                    newSubscriptionsToInsert.add(newSubscriptions[i]);
                }

                for(Integer j = listSize-1; j >= listSize-10000; j--){
                    newSubscriptions.remove(j);
                }

                Database.SaveResult[] lsr = Database.insert(newSubscriptionsToInsert, false);
                listSize = newSubscriptions.size();
            }

            Database.SaveResult[] lsr = Database.insert(newSubscriptions, false);
        }
    }
    
    public static void findAndCreateFollows(Map<Id,Set<Id>> userAndFollows2, List<User> allUsers, List<User> followUsers, String followRule, Boolean bidirectional){
        Map<String,Set<id>> allGroupMembers = new Map<String,Set<id>>();
        if (followUsers.size()>0){
            for(User thisUser : followUsers){    
                String groupId;
                if(followRule=='Role'){
                    groupId = thisUser.UserRoleId;
                } else if(followRule=='Profile'){
                    groupId = thisUser.profileId;
                } else if(followRule=='Division'){
                    groupId = thisUser.Division;
                } else if(followRule=='Department'){
                    groupId = thisUser.Department;
                }     
                
                if(allGroupMembers.get(groupId)==null){
                    Set<Id> newGroupMembers = new Set<Id>();
                    newGroupMembers.add(thisUser.Id);
                    allGroupMembers.put(groupId,newGroupMembers);
                } else {
                    allGroupMembers.get(groupId).add(thisUser.Id);
                }
            
                if (allGroupMembers.size()>0){
                    for(User thisTriggerUser : allUsers){
                        String groupIdSecondUser;
                        if(followRule=='Role'){
                            groupIdSecondUser = thisTriggerUser.UserRoleId;
                        } else if(followRule=='Profile'){
                            groupIdSecondUser = thisTriggerUser.profileId;
                        } else if(followRule=='Division'){
                            groupIdSecondUser = thisTriggerUser.Division;
                        } else if(followRule=='Department'){
                            groupIdSecondUser = thisTriggerUser.Department;
                        }
                        if (allGroupMembers.get(groupId)!=null){
                            if (allGroupMembers.get(groupIdSecondUser)!=null){
                                for(Id thisTeamMemberId : allGroupMembers.get(groupIdSecondUser)){  
                                    createFollow(userAndFollows2, thisTriggerUser.Id, thisTeamMemberId, true);
                                }
                            }
                        }
                    }
                }
            }
        }       
    }
    
    public static List<EntitySubscription> createSubscriptions(Id parentId, Id subscriberId){
        
        List<EntitySubscription> mySubsForCreation = new List<EntitySubscription> ();
        
        if(parentId!=null && subscriberId!=null && parentId!=subscriberId){
            EntitySubscription newSub = new EntitySubscription();
            newSub.parentid = parentId;
            newSub.subscriberid = subscriberId;
            mySubsForCreation.add(newSub);
        }
        
        return mySubsForCreation;
    }
       
    public static void createFollow(Map<Id,Set<Id>> userAndFollowsMap, Id userId, Id followerId, Boolean bothWays){
        if(userId != followerId){
            if(userId!=null && followerId!=null && userAndFollowsMap.get(userId)==null){
                Set<Id> newFollowers = new Set<Id>();
                newFollowers.add(followerId);
                userAndFollowsMap.put(userId,newFollowers);
            } else if (userId!=null && followerId!=null){
                userAndFollowsMap.get(userId).add(followerId);
            }
            if(bothWays){
                if(userId!=null && followerId!=null && userAndFollowsMap.get(followerId)==null){
                    Set<Id> newFollowers = new Set<Id>();
                    newFollowers.add(userId);
                    userAndFollowsMap.put(followerId,newFollowers);
                } else if (userId!=null && followerId!=null){
                    userAndFollowsMap.get(followerId).add(userId);
                }
            }
        }
    }
    
   /* static testMethod void testTeamfollowRule() {
                
        
        User thisUser = [ select Id,ProfileId,LocaleSidKey, TimeZoneSidKey, LanguageLocaleKey, EmailEncodingKey from User where Id = :UserInfo.getUserId() ];
        System.runAs(thisUser){
            List<Chatter_Follow_Rules__c> existingRules = [select id from Chatter_Follow_Rules__c];
            delete existingRules;
        }
        
        System.runAs(thisUser){
            Chatter_Follow_Rules__c customSetting = new Chatter_Follow_Rules__c();
            customSetting.Follow_Team__c = true;
            insert customSetting;
        }
        
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
        
        User user2 = new User();
        user2.FirstName = 'Joe';
        user2.LastName = 'smith';
        user2.ProfileId = thisUser.ProfileId;
        user2.LocaleSidKey = thisUser.LocaleSidKey;
        user2.TimeZoneSidKey = thisUser.TimeZoneSidKey;
        user2.LanguageLocaleKey = thisUser.LanguageLocaleKey;
        user2.EmailEncodingKey = thisUser.EmailEncodingKey;
        user2.ManagerId = user1.Id;
        user2.alias = 'user2';
        user2.username = 'user2@adfjkluiopasfuioasjijklasdfjlajio.com';
        user2.CommunityNickname = 'user2adfjkluiopasfuioasjijklasdfjlajio';
        user2.email = 'user2@email.com';
        usersforCreation.add(user2);
        
        insert usersforCreation;
        
        User user6 = new User();
        user6.FirstName = 'Joe';
        user6.LastName = 'smith';
        user6.ProfileId = thisUser.ProfileId;
        user6.LocaleSidKey = thisUser.LocaleSidKey;
        user6.TimeZoneSidKey = thisUser.TimeZoneSidKey;
        user6.LanguageLocaleKey = thisUser.LanguageLocaleKey;
        user6.EmailEncodingKey = thisUser.EmailEncodingKey;
        user6.ManagerId = user1.Id;
        user6.alias = 'user6';
        user6.username = 'user@adfjkluiopasfuioasjijklasdfjlajio.com';
        user6.CommunityNickname = 'user6adfjkluiopasfuioasjijklasdfjlajio';
        user6.email = 'user6@email.com';
        
        insert user6;
        Test.stopTest();
        List<EntitySubscription> createdSubs = [select id,parentId,subscriberid from EntitySubscription where parentId = :user6.Id];
        system.debug('createdSubs: ' + createdSubs);
        system.assert(createdSubs.size()>0);
        system.debug('createdSubs: ' + createdSubs);
    }
      */ 
   
    /*static testMethod void testFollowManagerHierarchy() {
        
        
        User thisUser = [ select Id,ProfileId,LocaleSidKey, TimeZoneSidKey, LanguageLocaleKey, EmailEncodingKey from User where Id = :UserInfo.getUserId() ];

        System.runAs(thisUser){
            List<Chatter_Follow_Rules__c> existingRules = [select id from Chatter_Follow_Rules__c];
            delete existingRules;
            
            Chatter_Follow_Rules__c customSetting = new Chatter_Follow_Rules__c();
            customSetting.Follow_Team__c = false;
            customSetting.Follow_Manager_Hierarchy__c = true;
            insert customSetting;
       
        }

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
        system.debug('User 1: ' + user1.id);
        
        User user2 = new User();
        user2.FirstName = 'Joe';
        user2.LastName = 'smith';
        user2.ProfileId = thisUser.ProfileId;
        user2.LocaleSidKey = thisUser.LocaleSidKey;
        user2.TimeZoneSidKey = thisUser.TimeZoneSidKey;
        user2.LanguageLocaleKey = thisUser.LanguageLocaleKey;
        user2.EmailEncodingKey = thisUser.EmailEncodingKey;
        user2.ManagerId = user1.Id;
        user2.alias = 'user2';
        user2.username = 'user2@adfjkluiopasfuioasjijklasdfjlajio.com';
        user2.CommunityNickname = 'user2adfjkluiopasfuioasjijklasdfjlajio';
        user2.email = 'user2@email.com';
        insert user2;
        system.debug('User 2: ' + user2.id);
        
        User user3 = new User();
        user3.FirstName = 'Joe';
        user3.LastName = 'smith';
        user3.ProfileId = thisUser.ProfileId;
        user3.LocaleSidKey = thisUser.LocaleSidKey;
        user3.TimeZoneSidKey = thisUser.TimeZoneSidKey;
        user3.LanguageLocaleKey = thisUser.LanguageLocaleKey;
        user3.EmailEncodingKey = thisUser.EmailEncodingKey;
        user3.ManagerId = user2.Id;
        user3.alias = 'user3';
        user3.username = 'user3@adfjkluiopasfuioasjijklasdfjlajio.com';
        user3.CommunityNickname = 'user3adfjkluiopasfuioasjijklasdfjlajio';
        user3.email = 'user3@email.com';
        insert user3;
        system.debug('User 3: ' + user3.id);
        
        User user4 = new User();
        user4.FirstName = 'Joe';
        user4.LastName = 'smith';
        user4.ProfileId = thisUser.ProfileId;
        user4.LocaleSidKey = thisUser.LocaleSidKey;
        user4.TimeZoneSidKey = thisUser.TimeZoneSidKey;
        user4.LanguageLocaleKey = thisUser.LanguageLocaleKey;
        user4.EmailEncodingKey = thisUser.EmailEncodingKey;
        user4.ManagerId = user3.Id;
        user4.alias = 'user4';
        user4.username = 'user4@adfjkluiopasfuioasjijklasdfjlajio.com';
        user4.CommunityNickname = 'user4adfjkluiopasfuioasjijklasdfjlajio';
        user4.email = 'user4@email.com';
        insert user4;
        system.debug('User 4: ' + user4.id);
        
        User user6 = new User();
        user6.FirstName = 'Joe';
        user6.LastName = 'smith';
        user6.ProfileId = thisUser.ProfileId;
        user6.LocaleSidKey = thisUser.LocaleSidKey;
        user6.TimeZoneSidKey = thisUser.TimeZoneSidKey;
        user6.LanguageLocaleKey = thisUser.LanguageLocaleKey;
        user6.EmailEncodingKey = thisUser.EmailEncodingKey;
        user6.ManagerId = user4.Id;
        user6.alias = 'user6';
        user6.username = 'user@adfjkluiopasfuioasjijklasdfjlajio.com';
        user6.CommunityNickname = 'user6adfjkluiopasfuioasjijklasdfjlajio';
        user6.email = 'user6@email.com';
        
        insert user6;
        system.debug('User 6: ' + user6.id);
       
        Test.stopTest();
      
        
        List<EntitySubscription> createdSubs = [select id,parentId,subscriberid from EntitySubscription where parentId = :user4.Id and subscriberId = :user6.Id];
        
        system.assertEquals(1,createdSubs.size());
        
        List<EntitySubscription> createdSubs2ndLevel = [select id,parentId,subscriberid from EntitySubscription where parentId = :user3.Id and subscriberid = :user6.Id];
        
        system.assertEquals(1,createdSubs2ndLevel.size());
        
        List<EntitySubscription> createdSubs3rdLevel = [select id,parentId,subscriberid from EntitySubscription where parentId = :user2.Id and subscriberid = :user6.Id];
        
        system.assertEquals(1,createdSubs3rdLevel.size());
        
        List<EntitySubscription> createdSubs4thLevel = [select id,parentId,subscriberid from EntitySubscription where parentId = :user1.Id and subscriberid = :user6.Id];
        
        system.assertEquals(1,createdSubs4thLevel.size());
        
    }
  
    
   /*
    static testMethod void testFollowRole() {
        
        User thisUser = [ select Id,UserRoleId,ProfileId,LocaleSidKey, TimeZoneSidKey, LanguageLocaleKey, EmailEncodingKey from User where Id = :UserInfo.getUserId() ];
        
        System.runAs(thisUser){
            List<Chatter_Follow_Rules__c> existingRules = [select id from Chatter_Follow_Rules__c];
            delete existingRules;
            
            Chatter_Follow_Rules__c customSetting = new Chatter_Follow_Rules__c();
            customSetting.Follow_Team__c = false;
            customSetting.Follow_Role__c = true;
            insert customSetting;
        }
                
        List<User> usersforCreation = new List<User>();
        List<UserRole> userRoleIds = new List<UserRole>();
        userRoleIds = [Select u.Name, u.Id From UserRole u limit 1];
        if(userRoleIds.size()>0){
            Id UserRoleId = userRoleIds[0].id;
            Test.startTest();
            User user1 = new User();
            user1.FirstName = 'Joe';
            user1.LastName = 'smith';
            user1.ProfileId = thisUser.ProfileId;
            user1.LocaleSidKey = thisUser.LocaleSidKey;
            user1.TimeZoneSidKey = thisUser.TimeZoneSidKey;
            user1.LanguageLocaleKey = thisUser.LanguageLocaleKey;
            user1.EmailEncodingKey = thisUser.EmailEncodingKey;
            user1.UserRoleId = thisUser.UserRoleId;
            user1.alias = 'user1';
            user1.username = 'user1@adfjkluiopasfuioasjijklasdfjlajio.com';
            user1.CommunityNickname = 'user1adfjkluiopasfuioasjijklasdfjlajio';
            user1.email = 'user1@email.com';
            insert user1;
            
            User user6 = new User();
            user6.FirstName = 'Joe';
            user6.LastName = 'smith';
            user6.ProfileId = thisUser.ProfileId;
            user6.LocaleSidKey = thisUser.LocaleSidKey;
            user6.TimeZoneSidKey = thisUser.TimeZoneSidKey;
            user6.LanguageLocaleKey = thisUser.LanguageLocaleKey;
            user6.EmailEncodingKey = thisUser.EmailEncodingKey;
            user6.UserRoleId = thisUser.UserRoleId;
            user6.ManagerId = user1.Id;
            user6.alias = 'user6';
            user6.username = 'user6@adfjkluiopasfuioasjijklasdfjlajio.com';
            user6.CommunityNickname = 'user6adfjkluiopasfuioasjijklasdfjlajio';
            user6.email = 'user6@email.com';
            
            insert user6;
            
            User user7 = new User();
            user7.FirstName = 'Joe';
            user7.LastName = 'smith';
            user7.ProfileId = thisUser.ProfileId;
            user7.LocaleSidKey = thisUser.LocaleSidKey;
            user7.TimeZoneSidKey = thisUser.TimeZoneSidKey;
            user7.LanguageLocaleKey = thisUser.LanguageLocaleKey;
            user7.EmailEncodingKey = thisUser.EmailEncodingKey;
            user7.ManagerId = user1.Id;
            user7.alias = 'user7';
            user7.username = 'user7@adfjkluiopasfuioasjijklasdfjlajio.com';
            user7.CommunityNickname = 'user7adfjkluiopasfuioasjijklasdfjlajio';
            user7.email = 'user7@email.com';
            
            insert user7;
            Test.stopTest();
        }
        //List<EntitySubscription> createdSubs = [select id,parentId,subscriberid from EntitySubscription where parentId = :user6.Id];
        
       // system.assert(createdSubs.size()>0);
        
    }
    
     static testMethod void testFollowProfile() {
        
        User thisUser = [ select Id,UserRoleId,ProfileId,LocaleSidKey, TimeZoneSidKey, LanguageLocaleKey, EmailEncodingKey from User where Id = :UserInfo.getUserId() ];
        
        System.runAs(thisUser){
            List<Chatter_Follow_Rules__c> existingRules = [select id from Chatter_Follow_Rules__c];
            delete existingRules;
        }
        
        List<User> usersforCreation = new List<User>();
        
        Id aProfileId = [select id from Profile where Id != :thisUser.ProfileId limit 1].id;
        
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
                
        System.runAs(thisUser){
            Chatter_Follow_Rules__c customSetting = new Chatter_Follow_Rules__c();
            customSetting.Follow_Team__c = false;
            customSetting.Follow_Profile__c = true;
            insert customSetting;
        }
        
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
        user6.username = 'user6@adfjkluiopasfuioasjijklasdfjlajio.com';
        user6.CommunityNickname = 'user6adfjkluiopasfuioasjijklasdfjlajio';
        user6.email = 'user6@email.com';
        
        insert user6;
        
        
        Test.stopTest();
        List<EntitySubscription> createdSubs = [select id,parentId,subscriberid from EntitySubscription where parentId = :user6.Id];
        
        system.assert(createdSubs.size()>0);
        
        
    }*/
    
  /*  static testMethod void testFollowDepartment() {
        
        User thisUser = [ select Id,UserRoleId,ProfileId,LocaleSidKey, TimeZoneSidKey, LanguageLocaleKey, EmailEncodingKey from User where Id = :UserInfo.getUserId() ];
        
        System.runAs(thisUser){
            List<Chatter_Follow_Rules__c> existingRules = [select id from Chatter_Follow_Rules__c];
            delete existingRules;
        }
        
        List<User> usersforCreation = new List<User>();
        
        Id aProfileId = [select id from Profile where Id != :thisUser.ProfileId limit 1].id;
        
        User user1 = new User();
        user1.FirstName = 'Joe';
        user1.LastName = 'smith';
        user1.ProfileId = thisUser.ProfileId;
        user1.LocaleSidKey = thisUser.LocaleSidKey;
        user1.TimeZoneSidKey = thisUser.TimeZoneSidKey;
        user1.LanguageLocaleKey = thisUser.LanguageLocaleKey;
        user1.EmailEncodingKey = thisUser.EmailEncodingKey;
        user1.Department = 'myDept92383293789';
        user1.alias = 'user1';
        user1.username = 'user1@adfjkluiopasfuioasjijklasdfjlajio.com';
        user1.CommunityNickname = 'user1adfjkluiopasfuioasjijklasdfjlajio';
        user1.email = 'user1@email.com';
        insert user1;
                
        System.runAs(thisUser){
            Chatter_Follow_Rules__c customSetting = new Chatter_Follow_Rules__c();
            customSetting.Follow_Team__c = false;
            customSetting.Follow_Department__c = true;
            insert customSetting;
        }
        
        Test.startTest();
        User user6 = new User();
        user6.FirstName = 'Joe';
        user6.LastName = 'smith';
        user6.ProfileId = thisUser.ProfileId;
        user6.LocaleSidKey = thisUser.LocaleSidKey;
        user6.TimeZoneSidKey = thisUser.TimeZoneSidKey;
        user6.LanguageLocaleKey = thisUser.LanguageLocaleKey;
        user6.EmailEncodingKey = thisUser.EmailEncodingKey;
        user6.Department = 'myDept92383293789';
        user6.alias = 'user6';
        user6.username = 'user6@adfjkluiopasfuioasjijklasdfjlajio.com';
        user6.CommunityNickname = 'user6adfjkluiopasfuioasjijklasdfjlajio';
        user6.email = 'user6@email.com';
        
        insert user6;
        
        Test.stopTest();
        List<EntitySubscription> createdSubs = [select id,parentId,subscriberid from EntitySubscription where parentId = :user6.Id];
        
        system.assert(createdSubs.size()>0);
        
    }*/

}