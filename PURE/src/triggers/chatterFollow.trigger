trigger chatterFollow on User (after insert, after update) {
	
    if( Trigger.isAfter && Trigger.isInsert ){
        Set<id> userIds = new Set<Id>();
        for(User thisUser : trigger.new){
            userIds.add(thisUser.Id); 
        }           
        chatterFollowRules.processNewUser(userIds,null);
        chatterFollowLists.processNewUser(userIds);
    }
    
    if( Trigger.isAfter && Trigger.isUpdate ){
        Set<id> userIds = new Set<Id>();
        Set<id> managementChangeUserIds = new Set<Id>();
        for(User thisUser : trigger.new){
            User thisUserBeforeChange = trigger.oldmap.get(thisUser.id);
            if(thisUser.ManagerId != thisUserBeforeChange.ManagerId ||
                (thisUser.IsActive != thisUserBeforeChange.IsActive && thisUser.IsActive) ||
                thisUser.ProfileId != thisUserBeforeChange.ProfileId ||
                thisUser.UserRoleId != thisUserBeforeChange.UserRoleId){
                    
                userIds.add(thisUser.Id); 
                if(thisUser.ManagerId != thisUserBeforeChange.ManagerId){
                    managementChangeUserIds.add(thisUser.ManagerId); 
                }
            }
        }
        if(userIds.size()>0){
            chatterFollowRules.processNewUser(userIds,managementChangeUserIds);
        }
    }
}