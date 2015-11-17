global virtual class GAPSMailHandlerBase
{
	public class GAPSException extends Exception {}
//	public class GAPSParsingException extends GAPSException {}
	protected GAPS_Settings__c settings;


	public GAPSMailHandlerBase()
	{
		settings=GAPS_Settings__c.getInstance();	
	}
	
	virtual public String getHelpText(boolean blnPlainText) { return ''; }
	
    protected User findUser(String strEmail)
    {
    	User uRequestor=null;
		String strSenderUsername=strEmail+(settings.Is_Test_Mode__c?'.cwd':'');
		List<User> lU=[SELECT Id,Name,email,Group_Name__c FROM User WHERE username=:strSenderUsername LIMIT 1];
		
		if(lU.size()>0) uRequestor=lU.get(0);
			
		if(uRequestor==null) throw new GAPSException('Cannot find requesting user in the system: '+strEmail);
			
		return uRequestor;
    }	
    
    protected Contact findContact(String strEmail)
    {
    	Contact cRequestor=null;
		String strSenderUsername=strEmail; //+(settings.Is_Test_Mode__c?'.cinovate':'');
		List<Contact> lC=[SELECT Id,Name,email FROM Contact WHERE email=:strSenderUsername LIMIT 1];
		
		if(lC.size()>0) cRequestor=lC.get(0);
			
		if(cRequestor==null) throw new GAPSException('Cannot find requesting contact in the system: '+strEmail);
			
		return cRequestor;   
	 }  
	 
	 protected void saveAttachments(Messaging.InboundEmail email, Id idParentID)
	 {
	 	saveAttachments(email,idParentID,UserInfo.getUserId());
	 }
	 
	 protected void saveAttachments(Messaging.InboundEmail email, Id idParentID, Id uId)
	 {
	 	//List<Attachment> attachments = new List<Attachment>();
	 	List<FeedItem> chatterAttachments=new List<FeedItem>();
	 	
	 	if (email.binaryAttachments != null) 
	 	{
			for (Messaging.InboundEmail.BinaryAttachment a : email.binaryAttachments) 
			{
			    //attachments.add(new Attachment( ParentId = idParentID, Name = (a.fileName != null ? a.fileName : 'No Name'), Body = a.body ));
			   chatterAttachments.add(new FeedItem(CreatedById=uId, ParentId = idParentID, ContentFileName = (a.fileName != null ? a.fileName : 'No Name'),ContentData = a.body));
			}
		}
		
        if (email.textAttachments != null) 
        {
            for (Messaging.InboundEmail.TextAttachment a : email.textAttachments) 
            {
//                attachments.add(new Attachment(ParentId = idParentID, Name = (a.fileName != null ? a.fileName : 'No Name'), Body = Blob.valueOf(a.body) ));
                chatterAttachments.add(new FeedItem(CreatedById=uId, ParentId = idParentID, ContentFileName = (a.fileName != null ? a.fileName : 'No Name'),ContentData = Blob.valueOf(a.body)));
            }
		}
            
		if (!chatterAttachments.isEmpty()) insert chatterAttachments;
	 }  
}