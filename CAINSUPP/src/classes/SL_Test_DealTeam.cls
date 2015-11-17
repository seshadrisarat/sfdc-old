/**
* \arg ClassName      : SL_Test_DealTeam
* \arg JIRATicket     : CAINSUPP-14
* \arg CreatedOn      : 09/17/2015
* \arg CreatedBy      : Manu
* \arg ModifiedBy     : Manu
* \arg Description    : This class works as testClass for SL_DealTeam trigger and related classes.
*/
@isTest
private class SL_Test_DealTeam{
	
	@isTest
	static void testDealTeam(){
		SL_Test_DealHandler.createTestData();
		Deal__c testDeal = [select id from Deal__c where name = 'Test Deal SL'];
		List<Cain_Deal_Team__c> testTeam = [SELECT Id, Team_Member__c, Responsible_Banker_Deal__c FROM Cain_Deal_Team__c WHERE Deal__c =: testDeal.Id];
		System.debug(testTeam.size());
		Cain_Deal_Team__c dealMember = testTeam[0];
		dealMember.Responsible_Banker_Deal__c = true;
		update dealMember;
		//Test if the Responsible_Banker__c has been updated to the one that was marked as checked
		Cain_Deal_Team__c updatedMember = [select Team_Member__c from Cain_Deal_Team__c where id = :dealMember.Id];
		testDeal = [select Responsible_Banker__c from Deal__c where name = 'Test Deal SL'];
		System.assertEquals(testDeal.Responsible_Banker__c, updatedMember.Team_Member__c);
		
		//Test if the other team members' Responsible_Banker_Deal__c is deselected if its selected for one on the team
		List<Cain_Deal_Team__c> otherMembers = [select Id, Responsible_Banker_Deal__c from Cain_Deal_Team__c where Deal__c = :testDeal.Id and id != : dealMember.Id];
		Cain_Deal_Team__c otherMember = otherMembers[0];
		otherMember.Responsible_Banker_Deal__c = true;
		update otherMember;
		updatedMember = [select Id, Responsible_Banker_Deal__c from Cain_Deal_Team__c where Id = :dealMember.Id];
		System.assertNotEquals(updatedMember.Responsible_Banker_Deal__c, true);
	}
}