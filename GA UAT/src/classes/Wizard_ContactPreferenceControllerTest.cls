/*******************************************************************
* Author        :  Harshit Jain (Appirio Offshore)
* Name          :  Wizard_ContactPreferenceControllerTest
* Date          :  Oct 26,2012
* Description   :  Verify functionality of Wizard_ContactPreferenceController class.                 
*******************************************************************/
@isTest
private class Wizard_ContactPreferenceControllerTest {

    static testMethod void testContactPreferenceFunctionality() {
        //Case 48779 - LSLEVIN - 6.4.2013-START
        //Account vehicle = Test_Utility.createAccount('V-1',null,'Vehicle-LP');
        Account vehicle = Test_Utility.createAccount('V-1',null,'Vehicle');
        //Case 48779 - LSLEVIN - 6.4.2013-END
        insert vehicle;
        Account investor = Test_Utility.createAccount('Inv-1',vehicle.Id,'Investor-LP');
        insert investor;
        Investor_Commitment_Agreement__c commitment = Test_Utility.createCommitment('Commit-1', investor.id);
        insert commitment;
        Contact contact = Test_Utility.createContact('Con-1', vehicle.Id);
        insert contact;
        PageReference pageRef = Page.Wizard_ContactPreference;
        Test.setCurrentPageReference(pageRef);
        ApexPages.currentPage().getParameters().put('vehicleId', vehicle.Id);
        ApexPages.currentPage().getParameters().put('contactId', contact.Id);
        Wizard_ContactPreferenceController contactPreferenceController = new Wizard_ContactPreferenceController();
        system.assertEquals(contactPreferenceController.selectContactType.size(), 1);
        system.assertEquals(contactPreferenceController.selectCommitmentType.size(), 2);
        system.assertEquals(contactPreferenceController.selectRecipientType.size(), 3);
        
        contactPreferenceController.selectedCommitment = commitment.id;
        contactPreferenceController.fetchCorrespondenceRecord();
         list<RecordType> ICPrecordTypeList = new list<RecordType>();
        ICPrecordTypeList = [Select r.SobjectType, r.Name
                             From RecordType r 
                             where SobjectType = 'Investor_Correspondence_Preference__c']; 
        system.assertEquals(contactPreferenceController.PreferenceWrapperList.size(),ICPrecordTypeList.size());
                
                for(Integer index=0; index<contactPreferenceController.PreferenceWrapperList.size(); index++) {
                    contactPreferenceController.PreferenceWrapperList.get(index).IsFax = true;  
                }   
        contactPreferenceController.saveCorrespondencePreference();
       
        system.assertEquals(getInvestorPreference(commitment.Id).size(),ICPrecordTypeList.size() );
    }
    
    private static List<Investor_Correspondence_Preference__c> getInvestorPreference(Id CommitmentId) {
            return [Select i.Investor_Commitment_Agreement__c, i.Id From Investor_Correspondence_Preference__c i where Investor_Commitment_Agreement__c =: CommitmentId];       
    }
}