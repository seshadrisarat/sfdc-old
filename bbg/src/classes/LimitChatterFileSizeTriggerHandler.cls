public without sharing class LimitChatterFileSizeTriggerHandler {



	public static void onBefore(List<FeedComment> feedCommentList) {
		
		Integer maxSize = 2000000;
		
		try{
			SROC_System_Settings__c setting = SROC_System_Settings__c.getInstance('SROC');
			maxSize = Integer.valueOf(setting.Max_Chatter_File_Size__c);
		}catch(Exception e){
		}
		
		Set<Id> cvIdList = new Set<Id>();
		
		for(FeedComment fc : feedCommentList)
		{
			cvIdList.add(fc.RelatedRecordId);
		}
		
		Map<Id,ContentVersion> cvMap = new Map<Id, ContentVersion>([SELECT Id, VersionData,ContentDocumentId, ContentSize FROM ContentVersion WHERE Id IN :cvIdList]);
		
		Set<ContentDocument> deleteCV = new Set<ContentDocument>();
		
		for(FeedComment fc : feedCommentList)
		{
			system.debug(fc);
			ContentVersion currCV = cvMap.get(fc.RelatedRecordId);
			if(currCV != null && (currCV.VersionData != null && currCV.VersionData.size() > maxSize) || (currCV.ContentSize != null && currCV.ContentSize > maxSize))
			{	
				fc.RelatedRecordId = null;
				fc.addError('File size limit exceeded! File must be less than 2 MB.');
				ContentDocument cd = new ContentDocument();
				cd.Id = currCV.ContentDocumentId;
				deleteCV.add(cd);
			}
		}
		
		
		system.debug(deleteCV);
		if(deleteCV.size() > 0)
		{
			SROCUtilities.deleteContentDocuments(new List<ContentDocument>(deleteCV));
		}
		
	}
	
	public static void onBefore(List<ContentVersion> cvList) {
		
		Integer maxSize = 2000000;
		
		try{
			SROC_System_Settings__c setting = SROC_System_Settings__c.getInstance('SROC');
			maxSize = Integer.valueOf(setting.Max_Chatter_File_Size__c);
		}catch(Exception e){
		}
		
		for(ContentVersion cv : cvList)
		{
			system.debug(cv);
			if(cv.VersionData != null && (cv.VersionData != null && cv.VersionData.size() > maxSize) || (cv.ContentSize != null && cv.ContentSize > maxSize) )
			{
				cv.addError('File size limit exceeded! File must be less than 2 MB.');
			}
		}
		
	}
	
	public static void onBefore (List<FeedItem> fiList) {
		
		Integer maxSize = 2000000;
		
		try{
			SROC_System_Settings__c setting = SROC_System_Settings__c.getInstance('SROC');
			maxSize = Integer.valueOf(setting.Max_Chatter_File_Size__c);
		}catch(Exception e){
		}
		
		for(FeedItem fi : fiList)
		{
			system.debug(fi);
			if((fi.ContentData != null && fi.ContentData.size() > maxSize) || (fi.ContentSize != null && fi.ContentSize > maxSize))
			{ 
				fi.addError('File size limit exceeded! File must be less than 2 MB.');
			}
		}
			
	}


}