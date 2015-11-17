/**
 * Email services are automated processes that use Apex classes
 * to process the contents, headers, and attachments of inbound
 * email.
 */
global class GAPSMailHandler extends GAPSMailHandlerBase implements Messaging.InboundEmailHandler
{
	List<RecordType> lTypes=null;
	Map<String,Id> mRecordTypes=new Map<String,Id>();
		
	public GAPSMailHandler()
	{	
		lTypes=[Select SobjectType, Name, IsActive, Id, DeveloperName From RecordType WHERE SObjectType='Account' AND Name IN ('Company','G2K Historical Company')];

		for(RecordType r : lTypes)
		{
			mRecordTypes.put(r.name,r.Id);
		}			

	}

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) 
    {
    	String strSubjectLine=(email.subject.trim().equals('')?email.plainTextBody:email.subject);
    	String strAction='';
    	String strCompany='';
		String strEmailBody=parseBodyText((email.plainTextBody==null)?'':email.plainTextBody); 
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        try
        {
        	User uRequestor=findUser(email.fromAddress);
        	strAction=parseSubjectLineAction(strSubjectLine);
        	
        	if(strAction=='help')
        	{
        		sendEmail(uRequestor.email,null, 'GAPS Mail Bot Help',getHelpText(false),getHelpText(true),false);
        	}
        	else
        	{
	        	strCompany=parseSubjectLineItem(strSubjectLine);
	        	System.debug('Company to find: \''+strCompany+'\'');
	        	List<Account> lAccounts=findCompany(strCompany);
	        		
	        	if(lAccounts.size()>1)
	        		sendSelectionEmail(uRequestor.email,envelope.toAddress,strAction,strEmailBody,strCompany,lAccounts);
	        	else
	        	{
	        		Account a=lAccounts.get(0);
	        		
		        	if(strAction=='statusnote')
	    	    	{
	        			setStatusNote(uRequestor,a,strEmailBody);
	        		}
	        		else if(strAction=='getstatus')
	        		{        		
		        		getCompanyStatus(uRequestor,a);
	        		}
	        		else if(strAction=='ownership')
	        		{
	        			changeOwner(uRequestor, a);
	        		}
	        		else if(strAction=='fieldupdate')
	        		{
	        			
	        		}
	        		else if(strAction=='attach') 
	        		{ 
	        			//CWD-- fall through 
	        		}
	        		
	        		saveAttachments(email, a.Id, uRequestor.Id);        		
	        	}
        	}
        }
/*
        catch(GAPSParsingException eGP)
        {
        	
        }
*/        
        catch(GAPSException eG)
        {
        	result.success=false;
        	result.message='An error occured: '+eG.getMessage()+'\n\n\n'+getHelpText(true);
        }
        catch(Exception e)
        {
        	result.success=false;	
        	result.message='An error occured: '+e.getMessage()+'\n\n\n'+getHelpText(true);
        }

        return result;
    }
    
    public override String getHelpText(boolean blnPlainText)
    {
       String strHelpBody='';
		
		if(blnPlainText)
		{
			strHelpBody='Commands for the GAPS Mail Bot\nAll commands are entered into the subject line of the email, followed by a colon and then the company name or company record ID.\n\n';
	        strHelpBody+='help\nReturns this help email\n\n';
			strHelpBody+='statusnote: [company name | company record ID]\nEnter a company name or company record ID after the command. Enter the status note in the body of the email.\n';
			strHelpBody+='If you want to enter next steps as well then add "nextsteps:" followed by your next steps note after your status note. To end the message add "';
			strHelpBody+=settings.End_of_Note_Token__c+'" and the note will be truncated there. This is helpful when automated signature blocks are used\n\n';
			strHelpBody+='getstatus: [company name | company record ID]\nEnter a company name or company record ID after the command and receive status of the company\n\n';
			strHelpBody+='ownership: [company name | company record ID]\nEnter a company name or company record ID after the command and ownership of the company will be changed to yourself\n\n';
			strHelpBody+='attach: [company name | company record ID]\nEnter a company name or company record ID after the command and any file attachments will be added to the company. \n\n';
		}
		else
		{
    		strHelpBody='Commands for the GAPS Mail Bot<br/>All commands are entered into the subject line of the email, followed by a colon and then the company name or company record ID.<br/><br/>';
	        strHelpBody+='<b><a href="mailto:gaps@generalatlantic.com?subject=help ">help</a></b><br/> returns this help email<br/><br/>';
	        strHelpBody+='<b><a href="mailto:gaps@generalatlantic.com?subject=statusnote: ">statusnote</a>:</b> [company name | company record ID]<br/>Enter a company name or company record ID after the command. Enter the status note in the body of the email.<br/>';
			strHelpBody+='If you want to enter next steps as well then add "nextsteps:" followed by your next steps note after your status note. To end the message add "';
			strHelpBody+=settings.End_of_Note_Token__c+'" and the note will be truncated there. This is helpful when automated signature blocks are used<br/><br/>';
			strHelpBody+='<b><a href="mailto:gaps@generalatlantic.com?subject=getstatus: ">getstatus</a>:</b> [company name | company record ID]<br/>Enter a company name or company record ID after the command and receive status of the company<br/><br/>';
			strHelpBody+='<b><a href="mailto:gaps@generalatlantic.com?subject=ownership: ">ownership</a>:</b> [company name | company record ID]<br/>Enter a company name or company record ID after the command and ownership of the company will be changed to yourself<br/><br/>';
			strHelpBody+='<b><a href="mailto:gaps@generalatlantic.com?subject=attach: ">attach</a>:</b> [company name | company record ID]<br/>Enter a company name or company record ID after the command and any file attachments will be added to the company.<br/><br/>';
		}
		
		return strHelpBody;		
    }
    
    
    public List<Account> findCompany(String strCompany)
    {
		List<Account> lAccounts=[SELECT Id, Name, Company_Name__c, Description, Status__c, Latest_Status_Note__c, Next_Steps__c, RecordType.Name, OwnerID, Owner.email, Owner.Name, Owner.username FROM Account WHERE (RecordTypeId IN :mRecordTypes.values()) AND (Name like :(strCompany+'%') OR Id=:strCompany) LIMIT 5];
				
		if(lAccounts.size()==0) //CWD-- no match
		{
			throw new GAPSException('Cannot find the company with the name or ID:  \''+strCompany+'\' ');	
		}
		
		return lAccounts;
    }
    
    private String parseBodyText(String strBody)
    {
    	if(strBody==null)
    		strBody='';
    		
    	//(strBody != null ? (strBody.length() > 32000 ? strBody.substring(0, 31997) + '...' : strBody) : '')
    	Integer i=strBody.indexOf(settings.End_of_Note_Token__c);
    	
    	if(i>0)
    		strBody=strBody.substring(0, i);
    		
    	i=strBody.indexOf('_____________________________________________________________');
    	
    	if(i>0)
    		strBody=strBody.substring(0, i);
    		    	
    	return strBody;
    }
    
    private String parseSubjectLineItem(String strSubject)
    {
    	Integer i=strSubject.indexOf(':');
    	
    	if(i<0)
    	{
    		throw new GAPSException('unable to parse subject line items'); //GAPSParsingException
    	}
    	
    	return strSubject.substring(i+1).trim();
    }
    
    private String parseSubjectLineAction(String strSubject) 
    {    	
    	String strAction='';
    	
    	if(strSubject.trim().equalsIgnoreCase('help'))
    		strSubject+=':';
    
    	Integer i=strSubject.indexOf(':');
    	
    	if(i<0)
    		throw new GAPSException('unable to parse subject line command'); //GAPSParsingException
    	
    	strAction=strSubject.substring(0,i).replaceAll(' ','');
    	
    	if(strAction.equalsIgnoreCase('statusnote'))
    	{
    		strAction='statusnote';
    	}
    	else if(strAction.equalsIgnoreCase('getstatus')||strAction.equalsIgnoreCase('getstatusnote'))
    	{
    		strAction='getstatus';
    	}
    	else if(strAction.equalsIgnoreCase('ownership'))
    	{
    		strAction='ownership';
    	}
    	else if(strAction.equalsIgnoreCase('fieldupdate'))
    	{
    		strAction='fieldupdate';
    	}
    	
    	return strAction;
    }
    
    public void setStatusNote(User u,Account a,String strEmailBody) //CWD-- default behavior
    {
    	setStatusNote(u,a,strEmailBody,true);
    }
    
    public void setStatusNote(User u,Account a,String strEmailBody, boolean bSendEmail)
    {    	
    	String strDesc=strEmailBody;
    	String strNextSteps='';
    	Integer i=strEmailBody.toLowerCase().indexOf(settings.Next_Steps_Token__c);
    	
    	if(i>0)
    	{
    		strDesc=strEmailBody.substring(0,i);
    		strNextSteps=strEmailBody.substring(i+settings.Next_Steps_Token__c.length());
    	}
    	
    	if(strNextSteps.length()>255)
    		strNextSteps=strNextSteps.substring(0, 255);
    		
    	Task t=new Task(
    	  WhatId=a.Id,
    	  OwnerId=u.Id,
    	  ActivityDate=date.today(),
    	  Completed_Date__c=date.today(),
    	  Type='Status Note',
    	  Subject='Status Note',
    	  Description=strDesc,
    	  Status = 'Completed',
    	  Next_Steps__c=strNextSteps
    	  );
    	  
    	insert t;
    	a=[SELECT Id, Name, Company_Name__c, Description, Status__c, Latest_Status_Note__c, Next_Steps__c, RecordType.Name, OwnerID, Owner.email, Owner.Name, Owner.username FROM Account WHERE Id=:a.Id LIMIT 1];
    	
    	getCompanyStatus(u,a,bSendEmail);
    }
    
    public void getCompanyStatus(User u,Account a) //CWD-- default behavior
    {
    	getCompanyStatus(u,a,true);
    }
    
    public void getCompanyStatus(User u,Account a, boolean bSendEmail)
    {
	    String strHTMLBody='<a href="https://na11.salesforce.com/'+a.id+'">'+a.Company_Name__c+'</a>: '+a.RecordType.Name+'<br/><b>Status:</b> '+a.Status__c+'<br/><b>Note:</b> '+a.Latest_Status_Note__c+'<br/><b>Next steps:</b> '+a.Next_Steps__c+'<br/><br/>';
		String strTextBody=a.Company_Name__c+': '+a.RecordType.Name+'\nStatus: '+a.Status__c+'\nNote: '+a.Latest_Status_Note__c+'\nNext steps: '+a.Next_Steps__c+'\n\n';
   		
   		if(bSendEmail) sendEmail(u.email,null, 'Company status',strHTMLBody,strTextBody,false);
    }
    
    public void changeOwner(User u, Account a)
    {    	
    	String strHTMLBody='Ownership of <a href="https://na11.salesforce.com/'+a.id+'">'+a.Name+'</a> assigned to <a email="mailto:'+u.email+'">'+u.Name+'</a>';
    	String strTextBody='Ownership of '+a.Name+' assigned to '+u.Name;
    	a.OwnerID=u.Id;
		a.RecordTypeId=mRecordTypes.get('Company');
		update a;
		//06-16-14 Notification no longer required to be sent
		//sendEmail(u.email, a.Owner.email,'Ownership of '+a.Name+' assigned', strHTMLBody,strTextBody,true);
    }
    
    private void sendSelectionEmail(String strTo,String strSystemAddress, String strMethod, String strBody, String strCompany, List<Account> lAccounts)
    {
    	Messaging.SingleEmailMessage alertEmail = new Messaging.SingleEmailMessage();
		String[] toAddresses=new String[] { strTo };
		String[] ccAddresses=new String[] { settings.Approver_Email__c };
		alertEmail.setToAddresses(toAddresses);
		alertEmail.setCCAddresses(ccAddresses);
		alertEmail.setSenderDisplayName('GAPS');
		alertEmail.setSubject('Multiple Companies found for \''+strCompany+'\'');
		strBody+=settings.End_of_Note_Token__c;

		if(!settings.Is_Test_Mode__c) alertEmail.setReplyTo('gaps@generalatlantic.com');
		
		String strHTMLBody='Multiple companies were found for \''+strCompany+'\'<br/>';
		String strTextBody='Multiple companies were found for \''+strCompany+'\'\n';
		
		for(Account a : lAccounts)
		{
			//EncodingUtil.urlEncode(strBody,'UTF-8')
			strHTMLBody+='<a href="mailto: '+strSystemAddress+'?subject='+strMethod+':'+a.Id+'&body='+strBody+'">'+a.Company_Name__c+'</a>: '+a.RecordType.Name+'<br/>Status: '+a.Status__c+'<br/>'+a.description+'<br/><br/>';
			strTextBody+='<a href="mailto: '+strSystemAddress+'?subject='+a.Id+'&body='+strBody+'">'+a.Company_Name__c+'</a>: '+a.RecordType.Name+'\nStatus: '+a.Status__c+'\n'+a.description+'\n\n';
		}
		
		alertEmail.setHtmlBody(strHTMLBody);
		alertEMail.setPlainTextBody(strTextBody);
		Messaging.sendEmail(new Messaging.Email[] { alertEmail });
    }
    
    private void sendEmail(String strRecipient, String strCC,String strSubject, String strHTMLBody,String strTextBody, boolean blnSendToApprover)
    {
    	try
    	{
			Messaging.SingleEmailMessage alertEmail = new Messaging.SingleEmailMessage();
			String[] toAddresses=new String[] { strRecipient };
			String[] ccAddresses=null;
			
			if(blnSendToApprover && (strCC!=null)) ccAddresses=new String[] { settings.Approver_Email__c, strCC };
			else if(blnSendToApprover) ccAddresses=new String[] { settings.Approver_Email__c };
			else if(strCC!=null) ccAddresses=new String[] { strCC };
				
			if(ccAddresses!=null) alertEmail.setCCAddresses(ccAddresses);			
			
			if(!settings.Is_Test_Mode__c) alertEmail.setReplyTo('gaps@generalatlantic.com');
				
			alertEmail.setToAddresses(toAddresses);
			alertEmail.setSenderDisplayName('GAPS');
			alertEmail.setSubject(strSubject);
			alertEmail.setHtmlBody(strHTMLBody);
			alertEMail.setPlainTextBody(strTextBody);
			Messaging.sendEmail(new Messaging.Email[] { alertEmail });
    	}
    	catch(Exception e)
    	{
    		throw new GAPSException(e.getMessage());
    	}
    }
}