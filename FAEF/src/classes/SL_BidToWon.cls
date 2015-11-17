/**  
* \arg ClassName        : SL_BidToWon 
* \arg JIRATicket       : FAEF-45
* \arg CreatedOn        : 12/NOV/2014
* \arg LastModifiedOn   : 13/NOV/2014
* \arg CreatededBy      : Lodhi
* \arg ModifiedBy       : Harsh
* \arg ModifiedOn       : 20/Nov/2014
* \arg Description      : Controller class for the SL_BidToWon_WS webservice.
*/
public with sharing class SL_BidToWon 
{
    /* Start - Variables */
    /* End - Variables */
    
    /* Start - Constructor */
    public SL_BidToWon()
    {
        //do nothing.  
    }
    /* End - Constructor */
    
    /*
        * MethodName    : updateBidRecords.
        * param         : Bid id 
        * Description   : This method will update the bid and all bid items to won and approves the latest approval process and 
                          reject all the approval process corresponding to bids those are not won related to lot.
    */
    public static String updateBidRecords(Id idBid)
    {
        List<Bid_Item__c> lstBidItem = new List<Bid_Item__c>();//List of bid item for updating the status
        List<Bid__c> lstBidToUpdate = new List<Bid__c>();//List of bid to update the status
        Map<Id, ProcessInstance> mapIdToProcessInstance = new Map<Id, ProcessInstance>();//Map of id to ProcessInstance for updating the status
        Set<Id> setBidId = new Set<Id>();//Set of bid id to fetch all of its bid items 
        Savepoint savePoint = Database.setSavepoint();//creating the save point
        List<Approval.ProcessWorkitemRequest> lstRequest = new List<Approval.ProcessWorkitemRequest>();//List of Approval.ProcessWorkitemRequest
        String strMessage = '';
        
        //Updating the operating bid status to won
        List<Bid__c> lstBid = [SELECT Id, 
                                      Status__c, 
                                      Lot__c
                                 FROM Bid__c 
                                WHERE Id =: idBid];
        if(!lstBid.isEmpty())
        {
            if(lstBid[0].Status__c != 'Won')
                lstBidToUpdate.add(new Bid__c(Id = lstBid[0].Id, Status__c = 'Won', Won_Lost_Date__c = Datetime.now()));
            
            //Iterating on bids related to the lot and updating the status as failed whose status is not winning
            for(Bid__c objBids : [SELECT Id,
                                        Status__c,
                                        Lot__c
                                   FROM Bid__c
                                  WHERE Lot__c =: lstBid[0].Lot__c
                                    AND Id !=: lstBid[0].Id
                                    AND Lot__c != NULL
                                    AND Status__c != 'Won'])
            {
                setBidId.add(objBids.Id);
                lstBidToUpdate.add(new Bid__c(Id = objBids.Id, Status__c = 'Failed'));
            }
        }
                    
        //Iterating on bid item for updating the status as won.
        for(Bid_Item__c objBidItem : [SELECT Id,
                                             Status__c,
                                             Bid__c
                                        FROM Bid_Item__c
                                       WHERE Bid__c IN : setBidId 
                                         AND Status__c != 'Failed'])
        {
        	lstBidItem.add(new Bid_Item__c(Id = objBidItem.Id, Status__c = 'Failed'));
        }
        
        //Iterate on the ProcessInstance to update the approval process status 
        for(ProcessInstance objProcessInstance : [SELECT Id, 
                                                         TargetObjectId,
                                                         Status,
                                                         (SELECT Id, 
                                                                 ActorId, 
                                                                 ProcessInstanceId 
                                                            FROM Workitems LIMIT 1)
                                                    FROM ProcessInstance 
                                                   WHERE (TargetObjectId IN : setBidId 
                                                      OR TargetObjectId =: idBid)
                                                     AND Status = 'Pending'
                                                ORDER BY LastModifiedDate DESC])
        {
            if(!mapIdToProcessInstance.containsKey(objProcessInstance.TargetObjectId))
            {
                mapIdToProcessInstance.put(objProcessInstance.TargetObjectId, objProcessInstance);
                for(ProcessInstanceWorkItem objPIWI : objProcessInstance.WorkItems)
                {
                    Approval.ProcessWorkitemRequest request = new Approval.ProcessWorkitemRequest();
                    
                    if(objProcessInstance.TargetObjectId == idBid)
                    {
                        request.setAction('Approve');
                        request.setWorkitemId(objPIWI.Id);
                    }   
                    else
                    {
                        request.setAction('Reject');
                        request.setWorkitemId(objPIWI.Id);
                    }
                    lstRequest.add(request);    
                }
            }       
        }
                                                        
        try
        { 
            if(!lstRequest.isEmpty())
                Approval.ProcessResult[] appResult = Approval.process(lstRequest); 

            // 1st updating BidItems to populate the Bid.Won_Amount formula field inorder to get proper Amount value for the created proceed records..Changed by Harsh as per FAEF-31 review comments by Steve
            if(!lstBidItem.isEmpty())
                update lstBidItem;
            if(!lstBid.isEmpty())
                update lstBidToUpdate;
            
            for(Bid_Item__c objBidItem : [SELECT Id FROM Bid_Item__c WHERE Bid__c =: idBid AND Status__c = 'Won'])
            {
            	lstBidItem.add(objBidItem);
            }    
            return (lstBidItem.isEmpty()) ? 'There are no bid items to mark as Won.' :'All bid items were marked as Won.';  
        }
        Catch(Exception exp)
        {
            Database.rollback(savePoint);
            return exp.getMessage();
        }
    }
    /* End */
}