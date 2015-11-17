/**
 * Exercise the NU_AccountProspectDate class 
 * to confirm that the prospect date is set for the 
 * expected prospect statuses.
 * @author thusted@nimbluser.com
 */
@isTest
private class NU_AccountProspectDateTest {
   	static final Date TODAY = Date.today();

    static testMethod void AccountProspectDateTest() {

        // On insert QP, set QPD to Today
        // System.debug(LoggingLevel.ERROR,'**** On insert QP, set QPD to Today ****');        
        Account a = new Account(Name = NU.LOREM, Prospect_Status__c = NU.QUALIFIED_PROSPECT);        
        System.assertEquals(null,a.QualifiedProspectDate__c);
        System.assertEquals(false,a.NU_Contacted_Within_90_Days__c);
        insert a; // fire the trigger
        a = [SELECT QualifiedProspectDate__c FROM Account WHERE Id= :a.Id];
        System.assertEquals(TODAY,a.QualifiedProspectDate__c, a.Id);
                       
        // On update QP, when status changes to QP, set QPD to Today
        // System.debug(LoggingLevel.ERROR,'**** On update QP, when status changes to QP, set QPD to Today ****');        
        Account b = new Account(name = NU.LOREM, Prospect_Status__c = NU.LOREM);
        insert b;
        System.assertEquals(NU.LOREM,b.Prospect_Status__c);        
        System.assertEquals(null,b.QualifiedProspectDate__c);
        b.Prospect_Status__c = NU.QUALIFIED_PROSPECT;
        update b;
        b = [SELECT QualifiedProspectDate__c FROM Account WHERE Id= :b.Id];        
        System.assertEquals(TODAY,b.qualifiedProspectDate__c);

		// On insert CP, set LCD to Today
        // System.debug(LoggingLevel.ERROR,'**** On insert CP, set LCD to Today ****');        
        Account c = new Account(Name = NU.LOREM, Prospect_Status__c = NU.CONTACT);
        System.assertEquals(null,c.ContactLastContactDate__c);
        System.assertEquals(false,c.NU_Contacted_Within_90_Days__c);
        insert c;
        c = [SELECT ContactLastContactDate__c FROM Account WHERE Id= :c.Id];        
        System.assertEquals(TODAY,c.ContactLastContactDate__c);
        
        // On update CP, when status changes to CP, set LCD to Today
        // System.debug(LoggingLevel.ERROR,'**** On update CP, when status changes to CP, set LCD to Today ****');        
        Account d = new Account(Name = NU.LOREM, Prospect_Status__c = NU.LOREM);
        insert d;
        System.assertEquals(NU.LOREM,d.Prospect_Status__c);        
        System.assertEquals(null,d.ContactLastContactDate__c);
        d.Prospect_Status__c = NU.CONTACT;
        update d;
        d = [SELECT ContactLastContactDate__c FROM Account WHERE Id= :d.Id];        
        System.assertEquals(TODAY,d.ContactLastContactDate__c);
    }
}