/**
* Test methods are in Test_PBI.cls
**/
public class PBI_AddMultiple 
{
	public string deleteContainer { get; set; }
	public String CurDealId {get; set;}
	public List<Potential_Buyer_Investor__c> PBI_List{ get; set; }
	List<Potential_Buyer_Investor__c> delListObj = new List<Potential_Buyer_Investor__c>();
	
	
	public String testName = '';
	public boolean isTest {get;set;}
	public List<selectOption> lProjects = null;
	
	public String testData {get; set;}
	public boolean canDelete { get; set; }
	public string jsonContent { get; set; }
	
	
	public PBI_AddMultiple() 
	{
		if(System.currentPageReference().getParameters().get('pid')!=null && System.currentPageReference().getParameters().get('pid')!='')
		{
			CurDealId = System.currentPageReference().getParameters().get('pid'); 
		}
		this.PBI_List = [
				SELECT Id, t.TargetBuyer__r.Name,
                    t.TargetBuyer__c,
                    t.Project__r.Id, 
                    t.Project__c, 
                    t.Name, t.Declined__c,
					 t.X3rd_Round_Bid_Received__c,				t.X3rd_Round_Bid_Low_mm__c,		t.X3rd_Round_Bid_High_mm__c,	t.X2nd_Round_Bid_Received__c,
                     t.X2nd_Round_Bid_Process_Letter_Sent__c,	t.X2nd_Round_Bid_Low_mm__c, 	t.X2nd_Round_Bid_High_mm__c,	t.X1st_Round_Bid_Received__c,
                     t.X1st_Round_Bid_Low_mm__c,				t.X1st_Round_Bid_High_mm__c,	t.Type__c, t.Teaser_Sent__c,	t.Status__c,
                     t.Mgmt_Presentation__c,					t.Data_Room_Access__c,			t.Initial_Contact_Made__c,		t.CIM_Info_Package_Sent__c,
                     t.CIM_Number__c,							t.CIM_Info_Package_Returned__c,	t.CA_Under_Negotiation__c,		t.CA_Signed__c,
                     t.CA_Sent__c,								t.X1st_Round_Bid_Process_Letter_Sent__c,						t.X3rd_Round_Bid_Process_Letter_Sent__c
                FROM Potential_Buyer_Investor__c t     
                WHERE t.Project__c =: this.CurDealId];
	        
	        this.canDelete = true;
	}

    
    
    
	public PageReference AddNew()
	{
		Potential_Buyer_Investor__c temp = new Potential_Buyer_Investor__c(Project__c=CurDealId);
		PBI_List.add(temp);
		return null;	
	}
	
	public PageReference ToDelete()
	{
		if(deleteContainer != null && deleteContainer != '')
		{
			String[] deleleList = new List<String>();
	        if(deleteContainer.contains(':'))  deleleList = deleteContainer.split(':');
	        else deleleList.add(deleteContainer);
	        Set<Integer>deleleSet = new Set<Integer>();
	        for (integer j = 0; j < deleleList.size() ; j++)
	        { 
				Integer tmpInd = Integer.valueOf(deleleList[j]);
				deleleSet.add(tmpInd);
	        }
	        	
	        Potential_Buyer_Investor__c tmpTrack;
	        
	        for (integer i = PBI_List.size(); i >= 0; i--)
	        {
				if(deleleSet.contains(i))
				{
		                if(PBI_List[i].Id != null)
		                {
		                	tmpTrack = new Potential_Buyer_Investor__c(Id = PBI_List[i].Id);
		                	delListObj.add(tmpTrack);
		                }
		             	PBI_List.remove(i);
				}
			}
			if(delListObj.size() > 0) 
			{
				try {delete delListObj;}
				catch (Exception ex){}
			}
		}	
		return null;
	}
	public boolean ToSave()
	{
		Boolean isError = false;
		List<Id> PBI_Id_List = new List<Id>();
		if (PBI_List.size() > 0)
		{
			for(Potential_Buyer_Investor__c item :PBI_List)
			{
				
				system.debug(item);
				if(item.TargetBuyer__c == null)
				{
					item.TargetBuyer__c.addError('Please enter PBI');
					isError = true;
				}
				if(item.Type__c == null || item.Type__c == '')
				{
					item.Type__c.addError('Please select Type');
					isError = true;
				}
				system.debug('item ----------------------->'+item);
				system.debug('item.Id ----------------------->'+item.Id);
				//if(item.Id != null && item.Id != '') PBI_Id_List.add(item.Id);
				if(item.id != null)	PBI_Id_List.add(Item.id);
			}
		} 

		if(isError)return false; 
		else 
		{
			/*
			if(delListObj.size() > 0) 
			{
				try {delete delListObj;}
				catch (Exception ex){}
			}
			*/
			Map<ID,Potential_Buyer_Investor__c> mapPBI = new Map<ID,Potential_Buyer_Investor__c>(
											[	select ID,TargetBuyer__c, 
								                    Project__c, 
								                    Declined__c,
													X3rd_Round_Bid_Received__c,				X3rd_Round_Bid_Low_mm__c,		X3rd_Round_Bid_High_mm__c,		X2nd_Round_Bid_Received__c,
								                    X2nd_Round_Bid_Process_Letter_Sent__c,	X2nd_Round_Bid_Low_mm__c, 		X2nd_Round_Bid_High_mm__c,		X1st_Round_Bid_Received__c,
								                    X1st_Round_Bid_Low_mm__c,				X1st_Round_Bid_High_mm__c,		Type__c, Teaser_Sent__c,		Status__c,
								                    Mgmt_Presentation__c,					Data_Room_Access__c,			Initial_Contact_Made__c,		CIM_Info_Package_Sent__c,
								                    CIM_Number__c,							CIM_Info_Package_Returned__c,	CA_Under_Negotiation__c,		CA_Signed__c,
								                    CA_Sent__c,								X1st_Round_Bid_Process_Letter_Sent__c,							X3rd_Round_Bid_Process_Letter_Sent__c
												from Potential_Buyer_Investor__c 
												where ID IN :PBI_Id_List]);
			Boolean isChanged = false; 	
			List<Potential_Buyer_Investor__c> ListToInsert	= new List<Potential_Buyer_Investor__c>();		
			List<Potential_Buyer_Investor__c> ListToUpdate	= new List<Potential_Buyer_Investor__c>();				
			for(Potential_Buyer_Investor__c item :PBI_List)
			{
				if(item.Id != null)
				{
					if(mapPBI.get(item.Id).TargetBuyer__c != item.TargetBuyer__c || 
						mapPBI.get(item.Id).Type__c != item.Type__c ||
						mapPBI.get(item.Id).Status__c != item.Status__c ||
						mapPBI.get(item.Id).Initial_Contact_Made__c != item.Initial_Contact_Made__c ||
						mapPBI.get(item.Id).Teaser_Sent__c != item.Teaser_Sent__c ||
						mapPBI.get(item.Id).CA_Sent__c != item.CA_Sent__c ||
						mapPBI.get(item.Id).CA_Under_Negotiation__c != item.CA_Under_Negotiation__c ||
						mapPBI.get(item.Id).CA_Signed__c != item.CA_Signed__c ||
						mapPBI.get(item.Id).CIM_Info_Package_Sent__c != item.CIM_Info_Package_Sent__c ||
						mapPBI.get(item.Id).CIM_Number__c != item.CIM_Number__c ||
						mapPBI.get(item.Id).Mgmt_Presentation__c != item.Mgmt_Presentation__c ||
						mapPBI.get(item.Id).Data_Room_Access__c != item.Data_Room_Access__c ||
						mapPBI.get(item.Id).X1st_Round_Bid_Process_Letter_Sent__c != item.X1st_Round_Bid_Process_Letter_Sent__c ||
						mapPBI.get(item.Id).X1st_Round_Bid_Received__c != item.X1st_Round_Bid_Received__c ||
						mapPBI.get(item.Id).X2nd_Round_Bid_High_mm__c != item.X2nd_Round_Bid_High_mm__c ||
						mapPBI.get(item.Id).X1st_Round_Bid_Low_mm__c != item.X1st_Round_Bid_Low_mm__c ||
						mapPBI.get(item.Id).X2nd_Round_Bid_Process_Letter_Sent__c != item.X2nd_Round_Bid_Process_Letter_Sent__c ||
						mapPBI.get(item.Id).X2nd_Round_Bid_Received__c != item.X2nd_Round_Bid_Received__c ||
						mapPBI.get(item.Id).X2nd_Round_Bid_High_mm__c != item.X2nd_Round_Bid_High_mm__c ||
						mapPBI.get(item.Id).X2nd_Round_Bid_Low_mm__c != item.X2nd_Round_Bid_Low_mm__c ||
						mapPBI.get(item.Id).X3rd_Round_Bid_Process_Letter_Sent__c != item.X3rd_Round_Bid_Process_Letter_Sent__c ||
						mapPBI.get(item.Id).X3rd_Round_Bid_Received__c != item.X3rd_Round_Bid_Received__c ||
						mapPBI.get(item.Id).X3rd_Round_Bid_High_mm__c != item.X3rd_Round_Bid_High_mm__c ||
						mapPBI.get(item.Id).X3rd_Round_Bid_Low_mm__c != item.X3rd_Round_Bid_Low_mm__c ||
						mapPBI.get(item.Id).Declined__c != item.Declined__c
					 )
					ListToUpdate.add(item);
				}
				else ListToInsert.add(item);
				
			}
			if (ListToUpdate.size() > 0) update ListToUpdate;
			system.debug('ListToInsert --------------------------------->'+ListToInsert);
			if (ListToInsert.size() > 0) insert ListToInsert;
    	
		}
		
		
		return true; 
	}

     public PageReference save()
     {
     	this.ToSave();
     	return null;
     }
     
     public PageReference save_close()
     {
     	if(this.ToSave())
     	{
	     	PageReference pageRef = new PageReference('/'+CurDealId);
			pageRef.setRedirect(true);
	        return pageRef;
     	} else return null;
     }
}