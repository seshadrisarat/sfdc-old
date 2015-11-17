global without sharing class SL_DealSharingCompliance_Scheduler implements Schedulable 
{
	/*
	System.schedule('SL Deal Sharing Compliance', '0 0 * * * ?', new SL_DealSharingCompliance_Scheduler());
	*/
	global void execute(SchedulableContext sc)
    {
    	SL_DealSharingCompliance_Batch b = new SL_DealSharingCompliance_Batch();
		//b.query = ''; 
		database.executebatch(b,400);
    }

}