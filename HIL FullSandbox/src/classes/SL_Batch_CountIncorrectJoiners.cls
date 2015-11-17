global class SL_Batch_CountIncorrectJoiners implements Database.Batchable<sObject>,Database.Stateful {
	
	String query;
	global integer Summary;
	global String njIds;
	
	global SL_Batch_CountIncorrectJoiners()
	{
		Summary = 0;
		njIds = '';
		query = 'Select Id,Note__c,Note__r.OwnerId,Relationship_Group__c,Relationship_Group__r.Rep_Code__c '+
				'From Note_Joiner__c '+
				'WHERE Relationship_Group__r.Rep_Code__c != null AND Note__r.OwnerId != \'005i0000001HLurAAG\' '+
				'AND Note__r.OwnerId != \'005i00000024WC1AAM\'';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC)
	{
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope)
   	{
   		Note_Joiner__c[] tempList = (Note_Joiner__c[]) scope;
   		Set<Id> repIds = new Set<Id>();
   		map<Id,Set<Id>> rcuMap = new map<Id,Set<Id>>();
   		Set<Id> nIds = new Set<Id>();
   		Set<Id> grpIds = new Set<Id>();

   		for(Note_Joiner__c nj : tempList)
   		{
   			repIds.add(nj.Relationship_Group__r.Rep_Code__c);
   		}

   		Rep_Code_User__c[] rcuList = [Select Id,User__c,Rep_Code__c
   									  From Rep_Code_User__c
   									  WHERE Rep_Code__c IN: repIds];

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

   		System.debug(rcuMap);

   		for(Note_Joiner__c nj : tempList)
   		{
   			if(rcuMap.get(nj.Relationship_Group__r.Rep_Code__c) != null && !rcuMap.get(nj.Relationship_Group__r.Rep_Code__c).contains(nj.Note__r.OwnerId))
   			{
   				grpIds.add(nj.Relationship_Group__c);
   				nIds.add(nj.Note__c);
   				System.debug('Im in');
   				Summary = Summary + 1;
   				njIds = njIds + nj.Id + ',';
   			}
   		}

   		delete [Select Id From Note__c WHERE Id IN: nIds];
	}
	
	global void finish(Database.BatchableContext BC)
	{
		// First, reserve email capacity for the current Apex transaction to ensure
                        
		// that we won't exceed our daily email limits when sending email after
		                        
		// the current transaction is committed.
		Messaging.reserveSingleEmailCapacity(1);

		// Processes and actions involved in the Apex transaction occur next,
		// which conclude with sending a single email.

		// Now create a new single email message object
		// that will send out a single email to the addresses in the To, CC & BCC list.
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

		// Strings to hold the email addresses to which you are sending the email.
		String[] toAddresses = new String[] {'hilliard@silverlinecrm.com'};
		  

		// Assign the addresses for the To and CC lists to the mail object.
		mail.setToAddresses(toAddresses);

		// Specify the address used when the recipients reply to the email. 
		mail.setReplyTo('hilliard@silverlinecrm.com');

		// Specify the name used as the display name.
		mail.setSenderDisplayName('BatchClassCount');

		// Specify the subject line for your email address.
		mail.setSubject('Number of Incorrect Rep Code Owner Note Joiners : ' + Summary);

		// Set to True if you want to BCC yourself on the email.
		mail.setBccSender(false);

		// Optionally append the salesforce.com email signature to the email.
		// The email address of the user executing the Apex Code will be used.
		mail.setUseSignature(false);

		// Specify the text content of the email.
		mail.setPlainTextBody('Number of Incorrect Rep Code Owner Note Joiners : ' + Summary + '\n\nAnd here are the Ids: \n\n' + njIds);

		// Send the email you have created.
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
	
}