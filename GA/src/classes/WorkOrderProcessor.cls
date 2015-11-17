global class WorkOrderProcessor implements Messaging.InboundEmailHandler 
{
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) 
    {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        List<User> lU=[SELECT Id,Name FROM User WHERE email=:email.fromAddress];
System.debug(email);
        if(lU.size()>0)
        {
	        Work_Order_Email__c woe=new Work_Order_Email__c(Subject__c=email.subject, Body__c=email.plainTextBody, Sender__c=email.fromAddress);
	        woe.OwnerId=lU.get(0).Id;
	        String strRecip='';
	        
	        if(email.toAddresses!=null)
	        {
		        for(String s : email.toAddresses)
	    	        strRecip=strRecip+','+s;
	        }
	        
	        woe.Recipients__c=strRecip;
	        insert woe;
        }
        
        return result;
    }
}