trigger ChatterItemProcessor on FeedItem (after update, after insert) 
{
    String strID='';
    String strAccountPrefix=Account.sObjectType.getDescribe().getKeyPrefix();
    String strDealPrefix=Deal__c.sObjectType.getDescribe().getKeyPrefix();
    String strProjectPrefix=Project__c.sObjectType.getDescribe().getKeyPrefix();
    String strTeamTaskPrefix=Task__c.sObjectType.getDescribe().getKeyPrefix();
    
    ChatterItemProcessor cip=new ChatterItemProcessor();
    List<FeedItem> lGAPSOwnership=new List<FeedItem>();
    List<FeedItem> lGAPSStatusNote=new List<FeedItem>();
    List<FeedItem> lProjectsToApprove=new List<FeedItem>();
    List<FeedItem> lProjectsToReject=new List<FeedItem>();
    List<FeedItem> lTeamTasksToComplete=new List<FeedItem>();
    
    for(FeedItem f : Trigger.new)
    {
        strID=f.parentId;
        String strBody=f.body;
        
        if(strBody==null) strBody='';
        
        strBody=strBody.toLowerCase();
        
        if((strID.startsWith(strAccountPrefix) || strID.startsWith(strDealPrefix)) ) //CWD-- deal & account records
        {
        	if(strBody.contains('#ownership'))
        	{
	            lGAPSOwnership.add(f);
        	}
	        
	        if(strID.startsWith(strAccountPrefix) && strBody.contains('#statusnote')) //CWD-- need to handle deal status note entry but short cutting for now
	        {
	        	lGAPSStatusNote.add(f);
	        }
	        
        }
        
        if(strID.startsWith(strProjectPrefix))
        {	
        	if(strBody.contains('#approve') || strBody.contains('#approved') || strBody.contains('#yes'))
        	{
        		lProjectsToApprove.add(f);
        	}
        	else if(strBody.contains('#reject') || strBody.contains('#rejected') || strBody.contains('#no'))
        	{
        		lProjectsToReject.add(f);
        	}
        }
        
        if(strID.startsWith(strTeamTaskPrefix))
        {
        	if(strBody.contains('#complete') || strBody.contains('#done') || strBody.contains('#close'))
        	{
        		lTeamTasksToComplete.add(f);
        	}	        
        }
    }
    
    if(lGAPSOwnership.size()>0)
    {
        cip.processGAPSOwnership(lGAPSOwnership);
    }
    
    if(lGAPSStatusNote.size()>0)
    {
    	cip.processStatusNotes(lGAPSStatusNote);
    }

	if(lProjectsToApprove.size()>0)
	{
		cip.processResearchTrackerApprovals(lProjectsToApprove,'Approved');
	}

	if(lProjectsToReject.size()>0)
	{
		cip.processResearchTrackerApprovals(lProjectsToReject,'90% Complete');
	}
	
	if(lTeamTasksToComplete.size()>0)
	{
		cip.processTeamTaskStatuses(lTeamTasksToComplete, 'Completed');
	}
}