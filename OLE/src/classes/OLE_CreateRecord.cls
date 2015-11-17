public class OLE_CreateRecord
{
    public static Account createAccount(String strName)
    {
         return new Account(Name = strName);  
    }
    
    public static Contact createContact(Id AccountId,String strLastName )
    {
        return new Contact(AccountId = AccountId,
                           LastName = strLastName,
                           MobilePhone = '1283746',
                           Email = strLastName + '@test.com');
    }
    
    public static User createUser(String strUserName, String strContactId)
    {
        Profile aProfile = [select Id from Profile where Name = 'Ole Digital Portal User'];
        
        return new User(Username = strUserName  + System.now().millisecond() +  '@test.com' ,
                        LastName = strUserName  + System.now().millisecond() ,
                        ProfileId = aProfile.Id,
                        Email = strUserName  + '@test.com',
                        Alias = strUserName,
                        ContactId = strContactId, 
                        CommunityNickname = strUserName,
                        IsActive = true,
                        TimeZoneSidKey = 'Asia/Tokyo',
                        LocaleSidKey = 'ja_JP',
                        ReceivesInfoEmails = false,
                        ReceivesAdminInfoEmails = false,
                        EmailEncodingKey = 'Shift_JIS',
                        LanguageLocaleKey = 'ja');
    }
    
    public static Case createCase(String strStatus,String strType,String strOrigin,String strSubject,String strDescription)
    {
        return new Case(Status = strStatus,
                        Type = strType,
                        Origin = strOrigin,
                        Subject = strSubject,
                        Description = strDescription);
    }
}