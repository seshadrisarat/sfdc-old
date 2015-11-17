public with sharing class ChatterTopicSpecification implements IVisibilitySpecification {
	
	private Set<Id> entitiesIds = new Set<Id>();
	
	public ChatterTopicSpecification(String chatterTopicId, String prefix) {				
		for(TopicAssignment obj : [
			SELECT id, TopicId, EntityId FROM TopicAssignment WHERE TopicId =: chatterTopicId AND EntityKeyPrefix =: prefix
		])
	 		entitiesIds.add(obj.EntityId);
	}
	
	public Boolean satisfiedBy(SObject candidate) {				
	 	return entitiesIds.contains(candidate.Id);
	} 
}