global class chatterFollowBatch implements Database.Batchable<sObject>{ 
    global String query; 
    global String email; 
    global String followRule;
    global database.querylocator start(Database.BatchableContext BC){ 
        return Database.getQueryLocator(query);} 
        
    global void execute(Database.BatchableContext BC,List<sObject> scope){ 
        
        Map<Id,Set<Id>> userAndFollows = new Map<Id,Set<Id>>();
        
        Map<String,Set<id>> allGroupMembers = new Map<String,Set<id>>();
        
        Map<Id,Id> userToManager = new Map<Id,Id>();
        
        for(sObject s : scope){User thisUser = (User)s; 
            
           // if(followRule=='Everyone'){
          //      for(sObject sEveryone : scope){User thisEveryoneUser = (User)sEveryone; 
           //         if(thisUser.Id!=thisEveryoneUser.Id){
           //             chatterFollowRules.createFollow(userAndFollows, thisUser.Id, thisEveryoneUser.Id, true);
           //         }
           //     }
           // } else
             if(followRule=='Hierarchy'){
                
                if(thisUser.ManagerId!=null){
                    userToManager.put(thisUser.Id,thisUser.ManagerId);   
                }      
                
            } else {            
                String groupId;         
                if(followRule=='Role'){
                    groupId = thisUser.UserRoleId;
                } else if(followRule=='Profile'){
                    groupId = thisUser.profileId;
                } else if(followRule=='Division'){
                    groupId = thisUser.Division;
                } else if(followRule=='Department'){
                    groupId = thisUser.Department;
                } else if(followRule=='Team'){
                    groupId = thisUser.ManagerId;
                } 
                if(groupId!=null){
                    if(allGroupMembers.get(groupId)==null){
                        Set<Id> newGroupMembers = new Set<Id>();
                        newGroupMembers.add(thisUser.Id);
                        allGroupMembers.put(groupId,newGroupMembers);
                    } else {
                        allGroupMembers.get(groupId).add(thisUser.Id);
                    }
                    //add the manager relationship
                    if(followRule=='Team'){
                        chatterFollowRules.createFollow(userAndFollows, thisUser.Id, thisUser.ManagerId, true);
                    }
                 
                    if (allGroupMembers.size()>0){
                        for(sObject s2 : scope){User thisTriggerUser = (User)s2; 
                            String groupIdSecondUser;
                            if(followRule=='Role'){
                                groupIdSecondUser = thisTriggerUser.UserRoleId;
                            } else if(followRule=='Profile'){
                                groupIdSecondUser = thisTriggerUser.profileId;
                            } else if(followRule=='Division'){
                                groupIdSecondUser = thisTriggerUser.Division;
                            } else if(followRule=='Department'){
                                groupIdSecondUser = thisTriggerUser.Department;
                            } else if(followRule=='Team'){
                                groupIdSecondUser = thisTriggerUser.ManagerId;
                            }
                            if (groupId==groupIdSecondUser){
                                if (allGroupMembers.get(groupIdSecondUser)!=null){
                                    for(Id thisTeamMemberId : allGroupMembers.get(groupIdSecondUser)){  
                                        if(thisUser.Id!=thisTeamMemberId){
                                            chatterFollowRules.createFollow(userAndFollows, thisUser.Id, thisTeamMemberId, true);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } 
        
        if(userToManager.size()>0){
            for(Id userId : userToManager.keySet()){
                Id currentManagementId = userToManager.get(userId);
                chatterFollowRules.createFollow(userAndFollows, currentManagementId,userId,  false);
                While(userToManager.get(currentManagementId)!=null){
                    currentManagementId = userToManager.get(currentManagementId);
                    chatterFollowRules.createFollow(userAndFollows, currentManagementId,userId,  false);                           
                }
            }
        } 
        
        if(userAndFollows.size()>0){
            
            List<EntitySubscription> newSubscriptions = new List<EntitySubscription> ();
            
            /* Commented out by Daniel llewellyn 3/17/2013 to test alternate batch insert method
            for(Id thisUserId : userAndFollows.keySet()){
                for(Id followerId : userAndFollows.get(thisUserId)){                    
                    newSubscriptions.addAll(chatterFollowRules.createSubscriptions(thisUserId, followerId));
                }
            }        
            Database.SaveResult[] lsr = Database.insert(newSubscriptions, false);
            */

            /* Dans alternate batch approach */
            for(Id thisUserId : userAndFollows.keySet()){
                for(Id followerId : userAndFollows.get(thisUserId)){                    
                    newSubscriptions.addAll(chatterFollowRules.createSubscriptions(thisUserId, followerId));

                    //dml size limit is 10000 records. so when we have 10000 in the list, insert them.
                    //then clear the list and continue
                    if(newSubscriptions.size() == 10000)
                    {
                        Database.SaveResult[] lsr = Database.insert(newSubscriptions, false);
                        newSubscriptions.clear();
                    }
                }
                
            }
        }        
    } 
    global void finish(Database.BatchableContext BC){ 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        mail.setToAddresses(new String[]{email}); 
        mail.setReplyTo('batch@acme.com'); 
        mail.setSenderDisplayName('Batch Processing'); 
        mail.setSubject('Batch Process Completed: ' + followRule); 
        
        mail.setPlainTextBody('Batch Process has completed'); 
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail}); 
    } 
    
    static testMethod void testChatterRole() {
        chatterFollowBatch chatterBatch = new chatterFollowBatch(); 
        chatterBatch.query = 'select Id,ManagerId,Manager.ManagerId,Manager.Manager.ManagerId,Manager.Manager.Manager.ManagerId,UserRoleId,ProfileId,Department,Division from User where isActive = true'; 
                
        chatterBatch.email =[select email from User where Id = :UserInfo.getUserId()].email; 
        chatterBatch.followRule = 'Role'; 
        Test.StartTest();
        ID batchprocessid = Database.executeBatch(chatterBatch);
        Test.StopTest();
    }
    
    static testMethod void testChatterDepartment() {
        chatterFollowBatch chatterBatch = new chatterFollowBatch(); 
        chatterBatch.query = 'select Id,ManagerId,Manager.ManagerId,Manager.Manager.ManagerId,Manager.Manager.Manager.ManagerId,UserRoleId,ProfileId,Department,Division from User where isActive = true'; 
                
        chatterBatch.email =[select email from User where Id = :UserInfo.getUserId()].email; 
        chatterBatch.followRule = 'Department'; 
        Test.StartTest();
        ID batchprocessid = Database.executeBatch(chatterBatch);
        Test.StopTest();
    }
    
    static testMethod void testChatterDivision() {
        chatterFollowBatch chatterBatch = new chatterFollowBatch(); 
        chatterBatch.query = 'select Id,ManagerId,Manager.ManagerId,Manager.Manager.ManagerId,Manager.Manager.Manager.ManagerId,UserRoleId,ProfileId,Department,Division from User where isActive = true'; 
                
        chatterBatch.email =[select email from User where Id = :UserInfo.getUserId()].email; 
        chatterBatch.followRule = 'Division'; 
        Test.StartTest();
        ID batchprocessid = Database.executeBatch(chatterBatch);
        Test.StopTest();
    }
    
    static testMethod void testChatterHierarchy() {
        chatterFollowBatch chatterBatch = new chatterFollowBatch(); 
        chatterBatch.query = 'select Id,ManagerId,Manager.ManagerId,Manager.Manager.ManagerId,Manager.Manager.Manager.ManagerId,UserRoleId,ProfileId,Department,Division from User where isActive = true'; 
                
        chatterBatch.email =[select email from User where Id = :UserInfo.getUserId()].email; 
        chatterBatch.followRule = 'Hierarchy'; 
        Test.StartTest();
        ID batchprocessid = Database.executeBatch(chatterBatch);
        Test.StopTest();
    }
    /*
    static testMethod void testChatterEveryone() {
        chatterFollowBatch chatterBatch = new chatterFollowBatch(); 
        chatterBatch.query = 'select Id,ManagerId,Manager.ManagerId,Manager.Manager.ManagerId,Manager.Manager.Manager.ManagerId,UserRoleId,ProfileId,Department,Division from User where isActive = true'; 
                
        chatterBatch.email =[select email from User where Id = :UserInfo.getUserId()].email; 
        chatterBatch.followRule = 'Everyone'; 
        Test.StartTest();
        ID batchprocessid = Database.executeBatch(chatterBatch);
        Test.StopTest();
    }
    */
    static testMethod void testChatterTeam() {
        chatterFollowBatch chatterBatch = new chatterFollowBatch(); 
        chatterBatch.query = 'select Id,ManagerId,Manager.ManagerId,Manager.Manager.ManagerId,Manager.Manager.Manager.ManagerId,UserRoleId,ProfileId,Department,Division from User where isActive = true'; 
                
        chatterBatch.email =[select email from User where Id = :UserInfo.getUserId()].email; 
        chatterBatch.followRule = 'Team'; 
        Test.StartTest();
        ID batchprocessid = Database.executeBatch(chatterBatch);
        Test.StopTest();
    }
    
    static testMethod void testChatterProfile() {
        chatterFollowBatch chatterBatch = new chatterFollowBatch(); 
        chatterBatch.query = 'select Id,ManagerId,Manager.ManagerId,Manager.Manager.ManagerId,Manager.Manager.Manager.ManagerId,UserRoleId,ProfileId,Department,Division from User where isActive = true'; 
                
        chatterBatch.email =[select email from User where Id = :UserInfo.getUserId()].email; 
        chatterBatch.followRule = 'Profile'; 
        Test.StartTest();
        ID batchprocessid = Database.executeBatch(chatterBatch);
        Test.StopTest();
    }
    
}