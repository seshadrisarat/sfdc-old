/*
*	DealApprovalCtrl – This is the controller class referenced by DealApproval.page
* 	Authors :  Sahir Ali, Don Koppel 3/15/2014	
*/

public without sharing class DealApprovalCtrl {

    public String dealId						{get;set;}		//Id of the selected Deal_c record
	public deal__c dealForApproval 				{get;set;}		//The currently selected Deal__c record
	public List<deal__c> dealsApprovalPending	{get;set;}		//List of deals that will be displayed within the sidebar panel

    public DealApprovalCtrl(){
		init();        
    }
    
	public void init(){
        
		//Initialize the page by retrieving the list of deals that the user has in his/her queue that are pending approval
		Id userId = UserInfo.getUserId();
		List<Id> workItemIdList = new List<Id>();
		for (ProcessInstanceWorkitem workItem : [SELECT p.Id, p.ProcessInstance.TargetObjectId  FROM ProcessInstanceWorkitem p WHERE ActorId = :userId]){
			workItemIdList.add(workItem.ProcessInstance.TargetObjectId);
		}
		System.debug('work item list: ' + workItemIdList);
		
		dealsApprovalPending = [SELECT o.Name, o.Id, o.Commencement_Date__c FROM deal__c o WHERE o.id IN :workItemIdList];
    }
    
    @RemoteAction
    public static String ApproveItems(String dealId, String comments, String action){

		//Approve or reject the deal based on the users action within the Approval popup
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        
        system.Debug('deal id = ' + dealId + ' comments ' + comments);
     
        ProcessInstanceWorkitem workItem  = [Select p.Id from ProcessInstanceWorkitem p  where p.ProcessInstance.TargetObjectId =:dealId LIMIT 1];

        req.setWorkitemId(workItem.Id);
        req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        req.setComments(comments);
        req.setAction(action);
        
        system.debug('Work Item Id = ' + workItem.Id);
        Approval.ProcessResult result =  Approval.process(req);

        return '';
    }
    
 	private string generateListOfDealFields() {
		return string.join(new list<string>(Schema.SObjectType.Deal__c.fields.getMap().keySet()), ',');
	}                                      
    
    @RemoteAction
    public static List<approvalObject> getApprovalPending(String filter)
    {
    	List<String> statuses = new List<String>{'Approved', 'Rejected'};
		List<String> filterList;

		//Determine which deal types should be included within the result
		if(filter == 'Retail'){
    		filterList = new List<String> {'Mall', 'Strip Center', 'Downtown', 'License Agreement'};
		}
		else if(filter == 'Office'){
    		filterList = new List<String> {'Office', 'Loft', 'Retail', 'Office License Agreement'};
		}
		else{
    		filterList = new List<String> {'Office', 'Loft', 'Retail', 'Mall', 'Strip Center', 'Downtown', 'License Agreement', 'Office License Agreement'};
		}
    	
		//Retrieve the list of pending deals that are in the users approval queue
    	deal__c curDeal;
    	Id userId = UserInfo.getUserId();
    	List<Id> workItemIdList = new List<Id>();

        for (ProcessInstanceWorkitem workItem : [SELECT p.Id, p.ProcessInstance.TargetObjectId  FROM ProcessInstanceWorkitem p WHERE ActorId = :userId]){
            workItemIdList.add(workItem.ProcessInstance.TargetObjectId);
        }

    	Map<Id, deal__c> dealMap = new Map<Id, deal__c>([SELECT o.Name, o.Id, o.Lease_Form_Type__c, o.Commencement_Date__c 
    														FROM deal__c o 
    														WHERE o.id IN :workItemIdList 
    															AND o.Lease_Form_Type__c In: filterList
    														ORDER BY o.Commencement_Date__c]);
		Map<Id, approvalObject> workItemMap = new Map<Id, approvalObject>(); 

        for (Deal__c deal : dealMap.values()){
			workItemMap.put(deal.Id, new approvalObject(Deal.Name, Deal.Id, 'Pending', datetime.newInstance(deal.Commencement_Date__c.year(), deal.Commencement_Date__c.month(),deal.Commencement_Date__c.day()).format('MM/dd/yyyy')));
        }
    	
    	//workItemMap.values().sort();
    	
	    return workItemMap.values();
    }

 	@RemoteAction
    public static List<approvalObject> getApprovedRejected(String filter)
    {
		//Get the historical list of deals that have been approved or rejected by the user
    	List<String> statuses = new List<String>{'Approved', 'Rejected'};
		List<String> filterList;

    	deal__c curDeal;
    	Id userId = UserInfo.getUserId();

		//Determine which deal types should be included within the result
		if(filter == 'Retail'){
    		filterList = new List<String> {'Mall', 'Strip Center', 'Downtown', 'License Agreement'};
		}
		else if(filter == 'Office'){
    		filterList = new List<String> {'Office', 'Loft', 'Retail', 'Office License Agreement'};
		}
		else{
    		filterList = new List<String> {'Office', 'Loft', 'Retail', 'Mall', 'Strip Center', 'Downtown', 'License Agreement', 'Office License Agreement'};
		}
   	
   		//Retrieve the list of leasing deals within the users approval history
    	Map<Id, deal__c> dealMap = new Map<Id, deal__c>([select id, name from deal__c where Deal__c.Lease_Form_Type__c In: filterList]);
    	List<Id> workItemIdList = new List<Id>();

        for (ProcessInstanceWorkitem workItem : [SELECT p.Id, p.ProcessInstance.TargetObjectId  FROM ProcessInstanceWorkitem p WHERE ActorId = :userId]){
            workItemIdList.add(workItem.ProcessInstance.TargetObjectId);
        }
        
        List<ProcessInstanceStep> workHistory = [SELECT p.Id, p.ProcessInstanceId, p.ActorId, p.StepStatus, p.CreatedDate, 
        												p.Comments, p.ProcessInstance.TargetObjectId 
        											FROM ProcessInstanceStep p
        											WHERE ActorId = :userId
        											AND   p.StepStatus IN :statuses
        											ORDER BY p.CreatedDate];
    	
		Map<Id, approvalObject> approvalMap = new Map<Id, approvalObject>(); 

        for (ProcessInstanceStep workItem : workHistory){
			if(dealMap.containsKey(workItem.ProcessInstance.TargetObjectId)){
				curDeal = dealMap.get(workItem.ProcessInstance.TargetObjectId);
				approvalMap.put(workItem.ProcessInstance.TargetObjectId, new approvalObject(curDeal.Name, curDeal.Id, workItem.StepStatus, workItem.CreatedDate.format('MM/dd/yyyy')));
			}
        }
    	
		return approvalMap.values();
    }

    @RemoteAction
    public static deal__c getDeal(String Id)
    {
    	return [SELECT o.Id, o.Name, o.Tenant__r.Name, o.Guarantor_Name__c, o.Deal_Stage__c, Deal__c.Owner.Name,
				o.Property__r.Name,o.Space__c,	o.Legal_Work__c, o.Lease_Form_Type__c,	
				o.NewDeal_Renewal__c, o.Commencement_Date__c FROM deal__c o WHERE o.id = :Id];
    	
    }
	
	public Boolean getisDealMemoSheet()
	{
		//Returns true if the selected deal is Deal Memo, else false
		if(dealId !=null)
		{
			Deal__c deal = [select Id, NewDeal_Renewal__c, Lease_Form_Type__c from Deal__c where Id=:dealId];
			
			if(deal.NewDeal_Renewal__c == 'Deal Memo') 
			if(deal.Lease_Form_Type__c == 'License Agreement' || deal.Lease_Form_Type__c == 'Office License Agreement')
			{
				return true;
			}
			return false;
		}
		return false;
	}
	
	public Boolean getisLeasingAmendmentDealSheet()
	{
		//Returns true if the selected deal is Amendment, else false
		if(dealId !=null)
		{
			Deal__c deal = [select Id, NewDeal_Renewal__c, Lease_Form_Type__c from Deal__c where Id=:dealId];
			
			if(deal.NewDeal_Renewal__c == 'Renewal' || deal.NewDeal_Renewal__c == 'Amendment') 
				if(deal.Lease_Form_Type__c == 'Mall' || deal.Lease_Form_Type__c =='Strip Center' || deal.Lease_Form_Type__c =='Downtown' || deal.Lease_Form_Type__c =='Free Standing')
				{
					return true;
				}
			
			return false;
		}
		return false;
	}
    
	public Boolean getisLeasingDealSheet()
	{
		//Returns true if the selected deal is Retail, else false
		if(dealId !=null)
		{
			Deal__c deal = [select Id, NewDeal_Renewal__c, Lease_Form_Type__c from Deal__c where Id=:dealId];
			
			if(deal.NewDeal_Renewal__c == 'New Deal') 
				if(deal.Lease_Form_Type__c == 'Mall' || deal.Lease_Form_Type__c =='Strip Center' || deal.Lease_Form_Type__c =='Downtown' || deal.Lease_Form_Type__c =='Free Standing')
				{
					System.Debug('in leasingDealSheet; deal id = ' + dealId);
					return true;
				}
			return false;
		}
		return false;
	}
	
	public Boolean getisOfficeDealSheet()
	{
		//Returns true if the selected deal is Office, else false
		if(dealId !=null)
		{
			Deal__c deal = [select Id, NewDeal_Renewal__c, Lease_Form_Type__c from Deal__c where Id=:dealId];
			
			
			if(deal.Lease_Form_Type__c == 'Office' || deal.Lease_Form_Type__c =='Loft' || deal.Lease_Form_Type__c =='Retail')
			{
				return true;
			}
			
			return false;
		}
		return false;
	}
  	
  	@remoteAction
	public static List<String> getPreviouslyViewedId(){

		//Retrieve the deal that the user most recently viewed.  This deal will be displayed by default  		
		Id userId = UserInfo.getUserId();
  		Deal_Approval_Last_Viewed__c dealLast = Deal_Approval_Last_Viewed__c.GetInstance(userId);
  		
  		if(dealLast.Deal_Id__c == null ){
			return null;
  		}
  		else{
  			system.debug(dealLast);
  			return new List<String>{dealLast.Deal_Id__c};
  		}
	}
        
	public void getSelectedDeal(){
		//Retrieve the selected deal
		System.debug('Dealid: '+ dealId);

		string query = 'select ' + generateListOfDealFields() + ' From Deal__c where Id=:dealId';
		this.dealForApproval = database.query(query); 

		System.debug(dealForApproval);   
    } 
	
	//remote function to set previously viewed deal
	@remoteAction
	public static String setPreviouslyViewedId(String Id){
		//Update the custom setting that tracks which deal was most recently viewed by the user
		Id userId = UserInfo.getUserId();
  		Deal_Approval_Last_Viewed__c dealLast = Deal_Approval_Last_Viewed__c.GetInstance(userId);
  		
  		if(dealLast.Deal_Id__c == null){
  			dealLast = new Deal_Approval_Last_Viewed__c(SetupOwnerId = userId, Deal_Id__c = Id);
			insert dealLast;
  		}
  		else{
  			system.debug(dealLast);
  			dealLast.Deal_Id__c = Id;
			update dealLast;
  		}
        return '';
  	}

    public class approvalObject{
    	
    	public String name;
    	public String dealId;
    	public String status;
    	public String actionDate;
    	
    	public approvalObject(){}
    	public approvalObject(String n, String d, String s, String ad)
    	{
    		name = n; dealId = d; status = s; actionDate = ad;
    	}
    }

}