@isTest
private class ContactContollerTest {
    static testMethod void myTest() {
        List<Contact> contacts = ContactController.findNearby(37, -122, 4000);
        System.assert(contacts != null);
     }
}