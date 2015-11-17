@isTest
private class MoveContactExtensiontest {
    static testMethod void MoveContactExtension_Test() {
    Account a = new Account(name='Test Deal Company');
    insert a;

    Contact c = new Contact(FirstName='Test',LastName='Contact',AccountID=a.id);
    insert c;
    ApexPages.StandardController sc = new ApexPages.standardController(c);
    MoveContactExtension mcont = new MoveContactExtension(sc);
    mcont.moveContact();
    }
    }