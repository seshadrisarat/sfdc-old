/**
* Test methods are in Test_Deal.cls
**/
public class DealRelParties_AddMultiple 
{
	public string deleteContainer { get; set; }
	public String ErrorMsg {get; set;}
	public String CurDealId {get; set;}
	public boolean isTest = false;
	
	public List<Deal_Related_Parties__c> DealPartiesList {get; set;}
	List<Deal_Related_Parties__c> delListObj= new List<Deal_Related_Parties__c>();

	public DealRelParties_AddMultiple() 
	{
		DealPartiesList = new list<Deal_Related_Parties__c>();
		if(System.currentPageReference().getParameters().get('did')!=null && System.currentPageReference().getParameters().get('did')!='')
        {
            CurDealId = System.currentPageReference().getParameters().get('did'); 
        }
		for (Deal_Related_Parties__c temp :  [
				Select Id, Role__c, Party__c, Notes__c, Deal__c, Company__c,Company__r.Name,Deal__r.Name
            	From Deal_Related_Parties__c 
            	WHERE Deal__c=:CurDealId 
            	ORDER BY Party__c
            	])
        {
            DealPartiesList.add(temp);
        }
	}
	
	public PageReference AddNew()
	{
		Schema.DescribeFieldResult roleObj = Deal_Related_Parties__c.Role__c.getDescribe();
		List<Schema.PicklistEntry> roleVals = roleObj.getPicklistValues();
		Schema.DescribeFieldResult partyObj = Deal_Related_Parties__c.Party__c.getDescribe();
		List<Schema.PicklistEntry> partyVals = partyObj.getPicklistValues();
		
		Deal_Related_Parties__c temp = new Deal_Related_Parties__c(Deal__c=CurDealId);
		temp.Role__c = roleVals[0].getValue();
		temp.Party__c = partyVals[0].getValue();
		DealPartiesList.add(temp);
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
	        	
	        Deal_Related_Parties__c tmpTrack;
	        
	        for (integer i = DealPartiesList.size(); i >= 0; i--)
	        {
				if(deleleSet.contains(i))
				{
		                if(DealPartiesList[i].Id != null)
		                {
		                	tmpTrack = new Deal_Related_Parties__c(Id = DealPartiesList[i].Id);
		                	delListObj.add(tmpTrack);
		                }
		             	DealPartiesList.remove(i);
				}
			}
		}	
		return null;
	}
	public boolean ToSave()
	{
		if(delListObj.size() > 0) 
		{
			try {delete delListObj;}
			catch (Exception ex){}
		}
		Boolean isError = false;
		if (DealPartiesList.size() > 0)
		{
			for(Deal_Related_Parties__c item :DealPartiesList)
			{
				system.debug(item);
				if(item.Company__c == null)
				{
					item.Company__c.addError('Please enter Company Name');
					isError = true;
				}
				if(item.Role__c == null || item.Role__c == '')
				{
					item.Role__c.addError('Please assign Role');
					isError = true;
				}
				if(item.Party__c == null || item.Party__c == '')
				{
					item.Party__c.addError('Please assign Party');
					isError = true;
				}
			}
		} 

		if(isError)return false; 
		if (DealPartiesList.size() > 0) upsert DealPartiesList;
		return true; 
	}

     public PageReference save()
     {
     	this.ToSave();
     	return null;
     }
     
     public PageReference save_close()
     {
     	if (this.ToSave())
     	{
	     	PageReference pageRef = new PageReference('/'+CurDealId);
			pageRef.setRedirect(true);
	        return pageRef;
     	}
     	else return null;
     }
}