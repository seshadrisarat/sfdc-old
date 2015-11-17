public class ListView {
    
    private List<Account> AccountList = new List<Account>();
    private List<Contact> ContactList = new List<Contact>();
    
    public integer getAccountListSize() {
        return AccountList.size();
    }
    
    public List<Account> getAccountList() {
        return AccountList;
    }
    
    public integer getContactListSize() {
        return ContactList.size();
    }
    
    public List<Contact> getContactList() {
        return ContactList;
    }
    
    public ListView() {
        AccountList = [Select Name, ID from Account limit 0];
        ContactList = [Select Name, ID from Contact limit 5];
    }
    
    static testMethod void ListView_Test() {
    	Account testAccount = new Account(Name='Test1');
    	insert testAccount;
    	Contact testContact = new Contact(FirstName='testFirstName', LastName='testLastName');
    	insert testContact;
    	
    	ListView lv = new ListView();
    	Integer i1 = lv.getAccountListSize();
    	List<Account> accountList = lv.getAccountList();
    	Integer i2 = lv.getContactListSize();
    	List<Contact> contactList = lv.getContactList();
    }
    
}