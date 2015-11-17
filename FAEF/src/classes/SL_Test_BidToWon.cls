/**  
* \arg ClassName        : SL_Test_BidToWon 
* \arg JIRATicket       : FAEF-45
* \arg CreatedOn        : 13/NOV/2014
* \arg LastModifiedOn   : 13/NOV/2014
* \arg CreatededBy      : Lodhi
* \arg ModifiedBy       : -
* \arg Description      : Test class for the SL_BidToWon_WS webservice class and SL_BidToWon class.
*/
@isTest
private class SL_Test_BidToWon 
{
    static testMethod void Test_BidToWon() 
    {
    	Id bidRecordtypeId = [SELECT Id FROM RecordType WHERE RecordType.DeveloperName = 'Saved_Bid'].Id;
    	
    	Auction__c objAuction = new Auction__c(Name = 'Auction-01');
    	insert objAuction;
    	
    	Lot__c objLot = new Lot__c(Auction__c = objAuction.Id);
    	insert objLot;
    	
        List<Bid__c> lstBid = new List<Bid__c>{
        									new Bid__c(Status__c = 'Submitted', Lot__c = objLot.Id, RecordTypeId = bidRecordtypeId),
        									new Bid__c(Status__c = 'Submitted', Lot__c = objLot.Id, RecordTypeId = bidRecordtypeId),
        									new Bid__c(Status__c = 'Submitted', Lot__c = objLot.Id, RecordTypeId = bidRecordtypeId),
        									new Bid__c(Status__c = 'Submitted', Lot__c = objLot.Id, RecordTypeId = bidRecordtypeId)};
		insert lstBid; 
		System.assertEquals(lstBid.size(), 4);
		
		List<Bid_Item__c> lstBidItem = new List<Bid_Item__c>{
															new Bid_Item__c(Status__c = 'Submitted', Bid__c = lstBid[0].Id),
															new Bid_Item__c(Status__c = 'Won', Bid__c = lstBid[0].Id),
															new Bid_Item__c(Status__c = 'Failed', Bid__c = lstBid[0].Id),
															new Bid_Item__c(Status__c = 'Saved', Bid__c = lstBid[0].Id),
															new Bid_Item__c(Status__c = 'Saved', Bid__c = lstBid[1].Id),
															new Bid_Item__c(Status__c = 'Won', Bid__c = lstBid[1].Id),
															new Bid_Item__c(Status__c = 'Submitted', Bid__c = lstBid[2].Id),
															new Bid_Item__c(Status__c = 'Won', Bid__c = lstBid[2].Id),
															new Bid_Item__c(Status__c = 'Failed', Bid__c = lstBid[3].Id),
															new Bid_Item__c(Status__c = 'Won', Bid__c = lstBid[3].Id)};
		insert lstBidItem;	
		System.assertEquals(lstBidItem.size(), 10);
		
		List<Approval.ProcessSubmitRequest> lstRequest = new List<Approval.ProcessSubmitRequest>();
		Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
		req1.setObjectId(lstBid[0].Id);
		lstRequest.add(req1);
		
		Approval.ProcessSubmitRequest req2 = new Approval.ProcessSubmitRequest();
		req2.setObjectId(lstBid[1].Id);
		lstRequest.add(req2);
		
		Approval.ProcessSubmitRequest req3 = new Approval.ProcessSubmitRequest();
		req3.setObjectId(lstBid[2].Id);
		lstRequest.add(req3);
		
		Approval.ProcessSubmitRequest req4 = new Approval.ProcessSubmitRequest();
		req4.setObjectId(lstBid[3].Id);
		lstRequest.add(req4);
		
		Approval.ProcessResult[] appResult = Approval.process(lstRequest);
																
		SL_BidToWon objBidToWon = new SL_BidToWon();													
		SL_BidToWon_WS objBidToWonWS = new SL_BidToWon_WS();											
		SL_BidToWon_WS.updateBid(lstBid[0].Id);	       									
    	
    	List<Bid__c> lstBid1 = [SELECT Id, 
		 							   Status__c
		 						  FROM Bid__c 
		 					     WHERE Lot__c =: objLot.Id];
    	
    	System.assertEquals(lstBid1[0].Status__c, 'Won');
		System.assertEquals(lstBid1[1].Status__c, 'Failed');
		System.assertEquals(lstBid1[2].Status__c, 'Failed');
		System.assertEquals(lstBid1[3].Status__c, 'Failed');
    	
		List<Bid_Item__c> lstBidItem2 = [SELECT Id,
	    										Status__c,
	    										Bid__c
	    								   FROM Bid_Item__c
	    								  WHERE Bid__c =: lstBid[1].Id];
		System.assertEquals(lstBidItem2[0].Status__c, 'Failed');
		System.assertEquals(lstBidItem2[1].Status__c, 'Failed');
    }
}