/*
* Handles the lead trigger
*
* @author Mike Regan
*/
public class LeadTriggerHandler extends TriggerHandler {
	private map<Id, Lead> newLeadMap;
	private map<Id, Lead> oldLeadMap;

	public LeadTriggerHandler() {
		newLeadMap = (map<Id, Lead>)Trigger.newMap;
		oldLeadMap = (map<Id, Lead>)Trigger.oldMap;
  	}
  	
  	public override void beforeInsert() {
  		// If we have too many leads to geocode now then the job will run after insert and process these
  		LeadServices.markNewLeadsForGeocodingRetryIfTooManyLeads(Trigger.new);
  	}
  	
  	public override void afterInsert() {
  		// Run the geocode job to process the leads if there are too many to do now
  		LeadServices.scheduleGeocodingJobIfTooManyLeads(Trigger.new);
  		
  		// If we can geocode now then do it
  		LeadServices.geocodeLeadsIfNotTooMany(newLeadMap);
        
        TriggerHandler.bypass('LeadTriggerHandler');
        //LeadServices.createActivity(newLeadMap); //BS-229
        LeadServices.createConsumerActionsForLeads(Trigger.new);	
        TriggerHandler.clearBypass('LeadTriggerHandler');	
  	}
  	
  	public override void beforeUpdate() {
  		// If we have too many leads to geocode now then the job will run after update and process these. However no
  		// need to mark them if nothing has changed
  		LeadServices.markLeadsForGeodingRetryIfTooManyLeadsAndAddressHasChanged(oldLeadMap, newLeadMap);	
  	}

  	public override void afterUpdate() {
  		TriggerHandler.bypass('LeadTriggerHandler');
  		// If the address has not changed then we don't need to geocode. However, if data has changed that affects
  		// the rules then we need to rerun dealer assignment (dealer routing)
  		LeadServices.assignDealersToLeadsIfNotGeocodingButScoreOrAssignmentDataHasChanged(oldLeadMap, newLeadMap);
  		TriggerHandler.clearBypass('LeadTriggerHandler');	
  		
  		// Run the geocode job to process the leads if there are too many to do now
  		LeadServices.scheduleGeocodingJobIfTooManyLeads(Trigger.new);
  		
  		// If we have leads that need to be geocoded and the amount it not too great, go ahead an do it now
  		LeadServices.geocodeLeadsIfNotTooManyAndAddressHasChanged(oldLeadMap, newLeadMap);
  		
  		TriggerHandler.bypass('LeadTriggerHandler');
  		LeadServices.updateConsumerActionBoatOwnersForConvertedLeads(oldLeadMap, newLeadMap);	
  		TriggerHandler.clearBypass('LeadTriggerHandler');	
  		
  		//Testing - LeadServices.createActivity(newLeadMap);
 	}
}