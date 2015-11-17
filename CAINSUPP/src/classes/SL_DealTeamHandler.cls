/**
* \arg ClassName      : SL_DealTeam
* \arg JIRATicket     : CAINSUPP-14
* \arg CreatedOn      : 09/17/2015
* \arg CreatedBy      : Manu
* \arg ModifiedBy     : Manu
* \arg Description    : Handler Class for the SL_DealTeam trigger
*/
public with sharing class SL_DealTeamHandler {
	
	/*!
        * MethodName : onAfterInsert
        * param      : map of newly inserted Deals
        * Description: This method is called after insert of Deal team/s
    */
	public void onAfterInsert(Map<Id, Cain_Deal_Team__c> mapNewDealTeam){
		
		updateDealResponsibleBanker(mapNewDealTeam.values());

	}
	
	/*!
        * MethodName : onAfterUpdate
        * param      : map of newly updated Deals
        * param		 : map of old Deal values
        * Description: This method is called after update of the Deal team/s
    */
    public void onAfterUpdate(Map<Id, Cain_Deal_Team__c> mapNewDealTeam, Map<Id, Cain_Deal_Team__c> mapOldDealTeam){
    	
    	updateDealResponsibleBanker(mapNewDealTeam.values());
    }

    /*!
        * MethodName : updateDealResponsibleBanker
        * param      : list of Deal members
        * Description: Method to update the Responsible banker on the Deal and
        			   remove the checkbox for any other team member that was previously selected
    */
    public void updateDealResponsibleBanker(List<Cain_Deal_Team__c> listNewDealTeam){
		
		Map<Id, Deal__c> mapDeals = new Map<Id, Deal__c>();
		List<Id> listResponsibleTeam = new List<Id>();
		//1. Create map of all the deals that need the responsible banker field updated based on the new 
		//   value on the Team Member where the Resonible Banker checkbox is checked
		for(Cain_Deal_Team__c team : listNewDealTeam){
			if(team.Responsible_Banker_Deal__c){
				Deal__c deal = new Deal__c(id = team.Deal__c, Responsible_Banker__c = team.Team_Member__c);
				mapDeals.put(team.Deal__c, deal);
				listResponsibleTeam.add(team.Id);
			}
		}
		//2. Create a list of all the other team members that may have the checkbox selected
		List<Cain_Deal_Team__c> otherTeamMembersToUpdate = new List<Cain_Deal_Team__c>();
		for(Cain_Deal_Team__c otherTeamMember : [select id, Responsible_Banker_Deal__c from Cain_Deal_Team__c where Deal__c IN :mapDeals.keySet() AND Id NOT IN: listResponsibleTeam]){
			if(otherTeamMember.Responsible_Banker_Deal__c){
				Cain_Deal_Team__c memberToUpdate = new Cain_Deal_Team__c(id=otherTeamMember.id, Responsible_Banker_Deal__c = false);
				otherTeamMembersToUpdate.add(memberToUpdate);
			}
		}

		if(!mapDeals.isEmpty()) update mapDeals.values();
		if(!otherTeamMembersToUpdate.isEmpty()) update otherTeamMembersToUpdate;
    }

}