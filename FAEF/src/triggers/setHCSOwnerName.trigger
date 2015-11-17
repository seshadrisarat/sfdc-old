trigger setHCSOwnerName on Account (before insert, before update){
 
    Map<Id,String> userMap = new Map<Id, String>();
 
    for (User u : [Select Id, Name From User]) {
        userMap.put(u.Id, u.Name);
    }
    for (Account a : Trigger.New) {
        a.HCS_Owner_Name__c = userMap.get(a.OwnerId);
    }
}