/*******************************************************************
* Author        :  Akanksha Bhatia (Appirio Offshore)
* Name          :  StrengthControllerTest
* Date          :  Oct 29,2012
* Description   :  Verify functionality of StrengthController class.                 
*******************************************************************/
@isTest
private class StrengthControllerTest {

    private static Contact contactData;
    private static Relationship_Strength__c strength;

    static testMethod void testStrengthController() 
    {
        List<Relationship_Strength__c> myStrengths;

        createDummyData();
        PageReference pageRef = Page.RelationshipStrengthInline;
        Test.setCurrentPageReference(pageRef);

       	// Test adding relationship strength
        ApexPages.StandardController ctr = new ApexPages.StandardController(contactData);
        StrengthController controller = new  StrengthController(ctr);
        
        // jfavors - 12/12/13 - add assertions
        System.assertEquals(contactData.Id, controller.contactId);
        System.assertNotEquals(null, controller.strengthList);
        System.assertEquals(0, controller.strengthList.size());
        System.assertNotEquals(null, controller.strength);
        System.assertEquals(4, controller.strength.size()); // picklist
		System.assert(String.isBlank(controller.selectedOption));
        
        controller.selectedOption = 'Medium';
        controller.save();
        myStrengths = getMyStrengths(contactData.Id);
        
        System.assertNotEquals(null, myStrengths);
        System.assertEquals(1, myStrengths.size());
        System.assertEquals('Medium', myStrengths[0].Relationship_Strength__c);
        
        // Test update existing
		ctr = new ApexPages.StandardController(contactData);
        controller = new  StrengthController(ctr);
        
        System.assertEquals(contactData.Id, controller.contactId);
        System.assertNotEquals(null, controller.strengthList);
        System.assertEquals(1, controller.strengthList.size());
		System.assertEquals('Medium', controller.selectedOption);
        
        controller.selectedOption = 'Low';
        controller.save();
        myStrengths = getMyStrengths(contactData.Id);
        
        System.assertNotEquals(null, myStrengths);
        System.assertEquals(1, myStrengths.size());
        System.assertEquals('Low', myStrengths[0].Relationship_Strength__c);
        // end jfavors
    }

    private static void createDummyData()
    {
        contactData = new Contact(LastName = 'testLastName');
        insert contactData;

        // jfavors - 12/12/13 - removing to test add via controller, not DML
        //strength = new Relationship_Strength__c(Relationship_Strength__c ='Low', contact__c = contactData.id, user__c = UserInfo.getUserId());
        //insert strength;
    }

    /* jfavors - 12/12/13 - removing to test update via controller, not DML
    private static void updateDummyData()
    {
        strength.Relationship_Strength__c ='Low';
        update strength;
    }
    */

    private static List<Relationship_Strength__c> getMyStrengths(Id contactId) {
        return [select Relationship_Strength__c, Contact__c, User__c
                from Relationship_Strength__c
                where User__c = :UserInfo.getUserId()
                  and Contact__c = :contactId];
    }
}