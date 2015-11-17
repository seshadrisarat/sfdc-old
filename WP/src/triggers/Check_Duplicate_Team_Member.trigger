trigger Check_Duplicate_Team_Member on Deal_Team__c (after insert) {

  Set<ID> ids = Trigger.newMap.keySet();
  Map<ID, Deal_Team__c> dt_List =  Trigger.newMap;
  List<Deal_Team__c> team_list = [Select Id,Deal__c, Employee__c,Employee__r.Name from Deal_Team__c where Id IN :ids];
  
  for(Deal_Team__c item : team_list) {
    List<Deal_Team__c> local_team_list= [Select Deal__c, Employee__c,Employee__r.Name from Deal_Team__c where 
        ((Deal__c =:item.Deal__c) AND (Employee__c =:item.Employee__c))];
    if(local_team_list.size() >1) {
      Deal_Team__c dt_item = dt_List.get(item.Id);
      dt_item.addError('Team Member '+item.Employee__r.Name+' is already part of deal team.Duplicate '+
      'team members are not allowed');
      
    }
  }
}