/**
 * Trigger Name :   UserUpdateWithContact   
 * Created By   :   Mohit
 * Date         :   04/03/2013
 * Description  :   Insert or Update the contact fields on the basis of User.
 */
 
trigger UserUpdateWithContact on User (after insert, after update) {
    Map<Id,Contact> userContactInfo = new Map<Id,Contact>();
    List<Contact> contactList = new List<Contact>();
    Set<String> userSet = new Set<String>();
    if(trigger.isUpdate) {
        for(User user : Trigger.new){
            if(user.FirstName != Trigger.oldMap.get(user.Id).FirstName || user.LastName != Trigger.oldMap.get(user.Id).LastName
            || user.Email != Trigger.oldMap.get(user.Id).Email || user.Title != Trigger.oldMap.get(user.Id).Title
            || user.Phone != Trigger.oldMap.get(user.Id).Phone || user.MobilePhone != Trigger.oldMap.get(user.Id).MobilePhone 
            || user.City != Trigger.oldMap.get(user.Id).City || user.Country != Trigger.oldMap.get(user.Id).Country
            || user.PostalCode != Trigger.oldMap.get(user.Id).PostalCode || user.State != Trigger.oldMap.get(user.Id).State
            || user.Street != Trigger.oldMap.get(user.Id).Street || user.CompanyName != Trigger.oldMap.get(user.Id).CompanyName){
                userSet.add(user.Email);
            }
        }
    }
    
    if(trigger.isInsert){
        for(User user : Trigger.new){
            userSet.add(user.Email);
        }
    }
    if(userSet.size()>0){
        ContactRecordHandler.createContactRecords(userSet);
    }
}