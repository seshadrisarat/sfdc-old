global class SL_Fix_Sharing implements Database.Batchable<sObject> {
	
	String query;
	
	global SL_Fix_Sharing(String i)
	{
		//This is our starting Point, Find all Note__c that have RG Related To it
		query = 'SeLect Id,OwnerId,Account_Del__c,Relationship_Group__c,Relationship_Group__r.Rep_Code__c,Create_Joiner_Records__c '+
				'FROM Note__c '+
				'WHERE Relationship_Group__c != NULL AND Account_Del__c = NULL';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC)
	{
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope)
   	{
   		Set<Id> rcIds = new Set<Id>();
   		map<Id,Set<Id>> rcuMap = new map<Id,Set<Id>>();
   		Note__c[] tempNList = (Note__c[]) scope;
   		map<Id,Note__c> tempNMap = new map<Id,Note__c>(tempNList);
   		Set<Id> nIdsToClean = new Set<Id>();
   		Note_Joiner__c[] delNJRG = new Note_Joiner__c[]{};

   		System.debug(tempNList);


   		//Build Rep Code User Maps
   		for(Note__c n : tempNList)
   		{
   			if(n.Relationship_Group__r.Rep_Code__c != null)
   			{
   				rcIds.add(n.Relationship_Group__r.Rep_Code__c);
   			}
   		}

   		Rep_Code_User__c[] rcuList = [Select Id,Rep_Code__c,User__c
   									From Rep_Code_User__c
   									WHERE Rep_Code__c IN: rcIds];

   		for(Rep_Code_User__c rcu : rcuList)
   		{
   			if(rcuMap.containsKey(rcu.Rep_Code__c))
   			{
   				rcuMap.get(rcu.Rep_Code__c).add(rcu.User__c);
   			}else
   			{
   				rcuMap.put(rcu.Rep_Code__c,new Set<Id>{rcu.User__c});
   			}
   		}


   		//Identifiy Which Note Joiners and Sharing Rules we need to clean up
   		for(Note__c n : tempNList)
   		{
   			if(n.Relationship_Group__r.Rep_Code__c != null)
   			{
   				if(!rcuMap.get(n.Relationship_Group__r.Rep_Code__c).contains(n.OwnerId))
   				{
   					nIdsToClean.add(n.Id);
   				}
   			}
   		}

   		for(Id i : tempNMap.keyset())
   		{
   			if(!nIdsToClean.contains(i))
   			{
   				tempNMap.remove(i);
   			}
   		}


   		//Delete the Note Shares in questions
   		Note__Share[] delShares = [Select Id
   								   From Note__Share
							   	   WHERE ParentId IN: nIdsToClean AND RowCause != 'Owner'];

   		delete delShares;


   		Note_Joiner__c[] njList = [Select Id,Client_Prospect__c,Relationship_Group__c,Note__c
   								   From Note_Joiner__c
   								   WHERE Note__c IN: nIdsToClean];


   		//Just delete all Note Joiners and We will re-create them
   		for(Note_Joiner__c nj : njList)
   		{
   			delNJRG.add(nj);

   			if(nj.Client_Prospect__c != null)
   			{
   				if(tempNMap != null && !tempNMap.isEmpty() && tempNMap.get(nj.Note__c) != null)
   				{
	   				tempNMap.get(nj.Note__c).Relationship_Group__c = null;
	   				tempNMap.get(nj.Note__c).Account_Del__c = nj.Client_Prospect__c;
	   				tempNMap.get(nj.Note__c).Create_Joiner_Records__c = true;
	   			}
   			}
   		}

   		delete delNJRG;

   		update tempNMap.values();

   		//Create the Note Joiners and Sharing Records
   		SL_Note_Joiner_Handler njHand = new SL_Note_Joiner_Handler(false,200);
   		njHand.createJoinerRecs(tempNMap);
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}