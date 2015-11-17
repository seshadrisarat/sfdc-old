public class HelpDeskController {
    
    public String userId = UserInfo.getUserId();
    public User activeUser = [SELECT Email FROM User WHERE Id = :userId LIMIT 1];
    public String userEmail = activeUser.Email;
    
    public List<Case> getCases () {
        return [SELECT Subject, Reason, CaseNumber, Type, Status, Owner.Name, Closing_Comments_Sent_to_Contact__c, CreatedDate, ClosedDate FROM Case WHERE Contact.Email = :userEmail ORDER BY Status Asc];    
    }
    
}