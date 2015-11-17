public class PrintAddressExtensionTestSuite {
// http://salesforcesource.blogspot.com/2008/09/testing-your-controller-extentions.html

    public static testMethod void testMyController() {
       
        // Acquire Page Reference
        PageReference pageRef = Page.PrintAddress;
        Test.setCurrentPageReference(pageRef);
        // Setup stub account and contact for testing
        Account myAccount = new Account (name='Account Name');
        insert myAccount;
        Contact myContact = new Contact (
            FirstName='First',
            LastName='Last',
            MailingStreet = 'Street',
            MailingState = 'ST',
            MailingCity = 'City',
            MailingPostalCode = '12345',
            AccountId=myAccount.id);
        insert myContact;
        // Instantiate standard Contact controller         
        ApexPages.StandardController sc = new ApexPages.standardController(myContact);
        // Create the custom extension that we need to test and acquire singleton
        PrintAddressExtension pae = new PrintAddressExtension(sc);
        PrintAddressExtension.PaObject po = pae.getPaObject(myContact);
        // Exercise each public method and property of the extension
        System.Assert( null != po);
        System.AssertEquals('First Last',po.getContactFullName()); 
        System.Assert( null != po.getFormattedAddress());
        System.Assert( null != po.getAddressLabelXml());
        System.Assert( null != po.getImageSrc());
        po.printbarcode = 'printbarcode';
        System.Assert( 'printbarcode' == po.printbarcode); 
        po.setFormattedAddress('formattedaddress');
        System.Assert( 'formattedaddress' == po.getFormattedAddress());
        System.Assert( null != po.getAddressLabelXml());
        po.setImageSrc('imageSrc');        System.Assert( 'imageSrc' == po.getImageSrc()); 

        PrintAddressExtension.PaObject po2 = pae.getPaObject();
        System.assert(null != po2);         
 }
}