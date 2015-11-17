/**
* \arg ClassName      : SL_ActivityHandler
* \arg JIRATicket     : PWP-20
* \arg CreatedOn      : 2015-03-09
* \arg LastModifiedOn : 2015-03-13
* \arg CreatededBy    : Edward Rivera
* \arg ModifiedBy     : 
* \arg Description    : This class serves as a handler for the Activity triggers.
*/
public with sharing class SL_ActivityHandler {
	
	public SL_ActivityHandler() {	
	}
	// all of these need to filter only tasks and events that are part of this trigger logic
	public void onAfterInsert(Map<Id, Task> newTasks){
		generateNewShadowActivities(newTasks);
	}
	public void onAfterInsert(Map<Id, Event> newEvents){
		generateNewShadowActivities(newEvents);
	}
	public void onAfterUpdate(Map<Id, Task> oldTasks, Map<Id, Task> newTasks){
		updateRelatedShadowActivities(oldTasks, newTasks);
	}
	public void onAfterUpdate(Map<Id, Event> oldEvents, Map<Id, Event> newEvents){
		updateRelatedShadowActivities(oldEvents, newEvents);
	}
	public void onAfterDelete(Map<Id, Task> oldTasks){
		deleteRelatedShadowActivities(oldTasks);
	}
	public void onAfterDelete(Map<Id, Event> oldEvents){
		deleteRelatedShadowActivities(oldEvents);
	}

	private void generateNewShadowActivities(Map<Id, Task> newTasks){
		List<Shadow_Activity__c> newShadowClones = new List<Shadow_Activity__c>();
		for (Task thisTask: newTasks.values()){
			newShadowClones.add(new Shadow_Activity__c
								(
								 OwnerId=thisTask.OwnerId,
								 Contact__c=thisTask.WhoId,
								 Date__c=thisTask.ActivityDate,
								 Description__c=thisTask.Description,
								 Related_To__c=thisTask.AccountId,
								 Status__c=thisTask.Status,
								 Hidden_Subject__c=thisTask.Subject,
								 Original_Activity_Id__c=thisTask.Id));
		}
		insert newShadowClones;
	}

	private void generateNewShadowActivities(Map<Id, Event> newEvents){
		List<Shadow_Activity__c> newShadowClones = new List<Shadow_Activity__c>();
		for (Event thisEvent: newEvents.values()){
			newShadowClones.add(new Shadow_Activity__c
								(
								 OwnerId=thisEvent.OwnerId,
								 Contact__c=thisEvent.WhoId,
								 Date__c=thisEvent.ActivityDate,
								 Description__c=thisEvent.Description,
								 Related_To__c=thisEvent.AccountId,
								 Hidden_Subject__c=thisEvent.Subject,
								 Original_Activity_Id__c=thisEvent.Id));
		}
		insert newShadowClones;
	}

	private void updateRelatedShadowActivities(Map<Id, Task> oldTasks, Map<Id, Task> newTasks){
		Map<Id, Shadow_Activity__c> mapActivityIdToShadowActivity = new Map<Id, Shadow_Activity__c>();
		for (Shadow_Activity__c shadowActivity: [SELECT Id,
														OwnerId,
														Contact__c,
														Date__c,
														Description__c,
														Related_To__c,
														Status__c,
														Hidden_Subject__c,
														Original_Activity_Id__c
												FROM Shadow_Activity__c
												WHERE Original_Activity_Id__c IN: newTasks.keySet()]){
			mapActivityIdToShadowActivity.put(shadowActivity.Original_Activity_Id__c, shadowActivity);
		}
		List<Shadow_Activity__c> updateShadowClones = new List<Shadow_Activity__c>();
		// update existing shadow records
		for (Task thisTask: newTasks.values()){
			Shadow_Activity__c shadowActivityToUpdate = new Shadow_Activity__c
								(OwnerId=thisTask.OwnerId,
								 Contact__c=thisTask.WhoId,
								 Date__c=thisTask.ActivityDate,
								 Description__c=thisTask.Description,
								 Related_To__c=thisTask.AccountId,
								 Status__c=thisTask.Status,
								 Hidden_Subject__c=thisTask.Subject,
								 Original_Activity_Id__c=thisTask.Id);

			if (mapActivityIdToShadowActivity.get(thisTask.Id)!=null){
				shadowActivityToUpdate.Id = mapActivityIdToShadowActivity.get(thisTask.Id).Id;	
			}
			updateShadowClones.add(shadowActivityToUpdate);
		}
		upsert updateShadowClones;
	}

	private void updateRelatedShadowActivities(Map<Id, Event> oldEvents, Map<Id, Event> newEvents){
		Map<Id, Shadow_Activity__c> mapActivityIdToShadowActivity = new Map<Id, Shadow_Activity__c>();
		for (Shadow_Activity__c shadowActivity: [SELECT Id,
														OwnerId,
														Contact__c,
														Date__c,
														Description__c,
														Related_To__c,
														Hidden_Subject__c,
														Original_Activity_Id__c
												FROM Shadow_Activity__c
												WHERE Original_Activity_Id__c IN: newEvents.keySet()]){
			mapActivityIdToShadowActivity.put(shadowActivity.Original_Activity_Id__c, shadowActivity);
		}
		List<Shadow_Activity__c> updateShadowClones = new List<Shadow_Activity__c>();
		for (Event thisEvent: newEvents.values()){
			Shadow_Activity__c shadowActivityToUpdate = new Shadow_Activity__c
								(
								 OwnerId=thisEvent.OwnerId,
								 Contact__c=thisEvent.WhoId,
								 Date__c=thisEvent.ActivityDate,
								 Description__c=thisEvent.Description,
								 Related_To__c=thisEvent.AccountId,
								 Hidden_Subject__c=thisEvent.Subject,
								 Original_Activity_Id__c=thisEvent.Id);

			if (mapActivityIdToShadowActivity.get(thisEvent.Id)!=null){
				shadowActivityToUpdate.Id = mapActivityIdToShadowActivity.get(thisEvent.Id).Id;	
			}
			updateShadowClones.add(shadowActivityToUpdate);
		}
		upsert updateShadowClones;
	}

	private void deleteRelatedShadowActivities(Map<Id, Task> oldTasks){
		delete [SELECT Id FROM Shadow_Activity__c WHERE Original_Activity_Id__c IN :oldTasks.keySet()];
	}

	private void deleteRelatedShadowActivities(Map<Id, Event> oldEvents){
		delete [SELECT Id FROM Shadow_Activity__c WHERE Original_Activity_Id__c IN :oldEvents.keySet()];
	}
	
}