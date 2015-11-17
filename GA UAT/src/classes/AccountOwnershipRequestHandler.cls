global class AccountOwnershipRequestHandler implements Messaging.InboundEmailHandler 
{
	global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) 
	{  	
		Id idCompany=null;
		List<RecordType> lTypes=[Select SobjectType, Name, IsActive, Id, DeveloperName From RecordType WHERE SObjectType='Account' AND Name IN ('Company','G2K Historical Company')];
		List<Id> lRTIds=new List<Id>();
		AccountRequestSettings__c settings=AccountRequestSettings__c.getInstance();
		Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
		result.success=true;
		
		for(RecordType r : lTypes)
		{
			lRTIds.add(r.Id);
			
			if(r.Name=='Company')
				idCompany=r.Id;
		}
		
		try
		{
			User uRequestor=null;
			String strSenderUsername=email.fromAddress+(settings.Is_Test_Mode__c?'.cinovate':'');
			String strApproverEmail=settings.Approver_Email__c;
			
			List<User> lU=[SELECT Id,Name,email FROM User WHERE username=:strSenderUsername LIMIT 1];
			System.debug(strSenderUsername);
			
			if(lU.size()>0)
				uRequestor=lU.get(0);
			
			if(uRequestor==null)
			{
				result.success=false;
				result.message='I\'m sorry but I cannot find your user in the system.';	
			}
			else
			{
				String strCompany=email.subject+'%';
				List<Account> lAccounts=[SELECT Id, Name, Company_Name__c, Description, Status__c, RecordType.Name, OwnerID, Owner.email, Owner.Name, Owner.username FROM Account WHERE (RecordTypeId IN :lRTIds) AND (Name like :strCompany OR Id=:email.subject)];
				
				if(lAccounts.size()==0) //CWD-- no match
				{
					result.success=false;
					result.message='Cannot find the company with the name or ID:  \''+email.subject+'\' ';	
				}
				else if(lAccounts.size()==1) //CWD-- exact match
				{
					Account a=lAccounts.get(0);
					
					a.OwnerID=uRequestor.Id;
					a.RecordTypeId=idCompany;
					update a;
					
					System.debug(a);
					/* AA 06-13-14 Commented out notification code as business no longer requires it
					Messaging.SingleEmailMessage alertEmail = new Messaging.SingleEmailMessage();
					String[] toAddresses=new String[] { email.fromAddress };
					String[] ccAddresses=new String[] { strApproverEmail, a.Owner.email };
					alertEmail.setToAddresses(toAddresses);
					alertEmail.setCCAddresses(ccAddresses);
					alertEmail.setSubject('Ownership of '+a.Name+' assigned');
					alertEmail.setPlainTextBody('Ownership of '+a.Name+' assigned to '+uRequestor.Name);
					Messaging.sendEmail(new Messaging.Email[] { alertEmail });
				}
				else //CWD-- multiple matches. which one should we use?
				{
					Messaging.SingleEmailMessage alertEmail = new Messaging.SingleEmailMessage();
					String[] toAddresses=new String[] { email.fromAddress };
					String[] ccAddresses=new String[] { strApproverEmail };
					alertEmail.setToAddresses(toAddresses);
					alertEmail.setCCAddresses(ccAddresses);
					alertEmail.setSubject('Multiple Companies found for \''+email.subject+'\'');
					String strHTMLBody='Multiple companies were found for \''+email.subject+'\'<br/>';
					String strTextBody='Multiple companies were found for \''+email.subject+'\'\n';
					
					for(Account a : lAccounts)
					{
						strHTMLBody+='<a href="mailto: '+envelope.toAddress+'?subject='+a.Id+'">'+a.Company_Name__c+'</a>: '+a.RecordType.Name+'<br/>Status: '+a.Status__c+'<br/>'+a.description+'<br/><br/>';
						strTextBody+=envelope.toAddress+'?subject='+a.Id+' '+a.Company_Name__c+': '+a.RecordType.Name+'\nStatus: '+a.Status__c+'\n'+a.description+'>\n\n';
					}
					
					alertEmail.setHtmlBody(strHTMLBody);
					alertEMail.setPlainTextBody(strTextBody);
					Messaging.sendEmail(new Messaging.Email[] { alertEmail });*/
				}
			}				
		}
		catch(Exception e)
		{
			result.success=false;
			result.message=e.getMessage();
		}
		
		return result;
	}
 }