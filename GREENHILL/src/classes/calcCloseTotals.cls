public class calcCloseTotals {
	
	public static void updateCloseTotal(String currCloseId) {
		decimal commitMinSum = 0;
		decimal commitMaxSum = 0; 
		Close__c  currClose; 		
				
		currClose = [select Id from Close__c where Id = :currCloseId];
		system.debug (currCloseId);
		
		//set the Max amount in the Close
		for (Opportunity o: [select o.Id, o.Maximum_Commitment_Size__c, o.Minimum_Commitment_Size__c, o.Probability
							from Opportunity o where Close__c = :currCloseId]){
			if (o.Minimum_Commitment_Size__c != null) {
				commitMinSum += o.Minimum_Commitment_Size__c * (o.Probability/100);
			}
			
			if (o.Maximum_Commitment_Size__c != null) {
				commitMaxSum += o.Maximum_Commitment_Size__c * (o.Probability/100);
			} 
		} 
	
		currClose.Min_Amount__c = commitMinSum;
		currClose.Max_Amount__c = commitMaxSum; 
		
		//update the Close 
		update currClose;
		
	}
	
	static testMethod void testUpdateCloseTotal(){
		vced2__Fund__c testFund = new vced2__Fund__c(name='testFund');
		insert testFund;
		
		Close__c testClose = new Close__c(name='testClose', Fund__c = testFund.Id, Max_Amount__c = 0, Min_Amount__c = 0);
		insert testClose;
		
		Opportunity testOpp = new Opportunity(name='testOpp', Close__c = testClose.Id, 
							Maximum_Commitment_Size__c = 50,Minimum_Commitment_Size__c = 10, 
							StageName='Circled',CloseDate=System.today(), 
							RecordTypeId = '0124000000059rP');
		insert testOpp; 
			
		Close__c testClose2 = [select ID, Max_Amount__c, Min_Amount__c  from Close__c where Id = :testClose.Id];
		
		System.assertEquals(37.5,testClose2.Max_Amount__c);
		System.assertEquals(7.5,testClose2.Min_Amount__c);
		
		
		delete testOpp;
		testClose2 = null;
		testClose2 = [select ID, Min_Amount__c, Max_Amount__c  from Close__c where Id = :testClose.Id];
		
		System.assertEquals(0,testClose2.Max_Amount__c);
		System.assertEquals(0,testClose2.Min_Amount__c); 
				
	}

}