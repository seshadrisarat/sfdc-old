/*



*/
trigger Project_Resource_Before_Trigger on Project_Resource__c (before insert, before update) {

    List<id> PrIDList = new List<Id>();
  
    for (Project_Resource__c pr : trigger.new) /***/ PrIDList.add(pr.Banker__c);

    map<id, id> teamUsers= new map<id, id>();
	
	List<Employee_Profile__c> List_EP = [SELECT id, User_ID__c FROM Employee_Profile__c WHERE id in :PrIDList];
	
    //for (Employee_Profile__c prInfo : [SELECT id, User_ID__c FROM Employee_Profile__c WHERE id in :PrIDList]) 
    for (Employee_Profile__c prInfo : List_EP)
	{
        teamUsers.put(prInfo.id,prInfo.User_ID__c);
    }

    for (Project_Resource__c prTeam : trigger.new)
    {
        if (teamUsers.get(prTeam.Banker__c) == null)
            prTeam.addError('The User_ID__c field of the Banker is not initialized!');
        //if (prTeam.Status__c == 'Inactive')  prTeam.Inactive_Date__c = Date.today();
    }
}