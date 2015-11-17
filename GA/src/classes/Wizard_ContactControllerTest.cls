/*******************************************************************
* Author        :  Harshit Jain (Appirio Offshore)
* Name          :  Wizard_ContactControllerTest
* Date          :  Oct 29,2012
* Description   :  Verify functionality of Wizard_ContactController class.                 
*******************************************************************/
@isTest
private class Wizard_ContactControllerTest {
    
    public static Account vehicle;
    public static List<Contact> contactList;
    public static Contact cnt ;
        
    static testMethod void testContactController() {
        createDummyData();
        PageReference pageRef = Page.Wizard_Contact;
        Test.setCurrentPageReference(pageRef);
        ApexPages.currentPage().getParameters().put('Id', vehicle.Id);
        Wizard_ContactController contactController = new Wizard_ContactController();
        
        //Create new contact
        contactController.contact.LastName = 'con-16';
        contactController.notifyAccountingContact = true;
        contactController.addContact();
        system.assertEquals(getContacts(vehicle.Id).size(), 6);
        
        //delete contact
        contactController.deleteContactIndex = 5;
        contactController.deleteContact();
        system.assertEquals(getContacts(vehicle.Id).size(), 5);
        
        //edit contact
        contactController.editContactIndex = 0;
        contactController.editContact();
        system.assertNotEquals(contactController.contact.LastName , null);
        contactController.clearContactFields();
     
        //Create one more contact
        contactController.contact.LastName = 'con-17';
        //Story # S-105960 Start
        //system.assertEquals(contactController.saveContact().getUrl(),new pageReference('/apex/Wizard_ContactPreference?vehicleId='+vehicle.Id).getURL());
        system.assertEquals(contactController.saveContact().getUrl(),new pageReference('/apex/Wizard_ContactPreference?vehicleId='+vehicle.Id + '&contactId=' + contactController.contact.Id).getURL());
        //Story # S-105960 End
        system.assertEquals(getContacts(vehicle.Id).size(), 6);
        //Story # S-105960 Start
        //system.assertEquals(contactController.redirectToContactPreferencePage().getUrl() , new pageReference('/apex/Wizard_ContactPreference?vehicleId='+vehicle.Id).getUrl());
        system.assertEquals(contactController.redirectToContactPreferencePage().getUrl() , new pageReference('/apex/Wizard_ContactPreference?vehicleId='+vehicle.Id + '&contactId=' + contactController.contact.Id).getUrl());
        //Story # S-105960 End
        //Existing contact scenario
        contactController.contactLookup.Source_Contact__c = cnt.Id;
        contactController.setContactField();
    }
    
    
    private static void createDummyData() {
        cnt = new Contact();
        cnt.lastname = 'test';
        insert cnt;
        //Case 48779 - LSLEVIN - 6.4.2013-START
        //vehicle = Test_Utility.createAccount('V-1',null,'Vehicle-LP');
        vehicle = Test_Utility.createAccount('V-1',null,'Vehicle');
        //Case 48779 - LSLEVIN - 6.4.2013-END
        insert vehicle;
        contactList = new List<Contact>();
        for(Integer index =1; index<=5; index++) {
            contactList.add(Test_Utility.createContact('Con-1'+index, vehicle.Id)); 
        }
        insert contactList;             
    }
    
    private static list<Contact> getContacts(Id vehicleId) {
        return [select Id from contact where AccountId =: vehicleId];
    }
    
}