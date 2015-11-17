/** 
* \author Gregory Grinberg
* \date 12/23/11 
* \brief This is used for the license and lead triggers. It is necessary because there is no other way to see exceptions when licenses come in from appexchange.
* \test 
*/
global without sharing class SL_ExceptionHandler {
	
	
	global static void BuildExceptionMessage(Exception ex, list<Sobject> oldRecords, list<SObject> newRecords)
	{
		string messages = 'Whoops! Something went wrong. Exception messages below\n';
		string subject = '';
		while(ex != null)
		{
			messages += '\nException Thrown: ';
			if(ex.getmessage() != null) messages += ex.getTypeName() + ': ' + ex.getmessage() + '\n';
			if(ex.getStackTraceString() != null) messages += ex.getStackTraceString() + '\n';
			if(ex.getLineNumber() != null) messages += 'line number: ' + ex.getLineNumber();
			ex = ex.getcause();	
		}
		
		if(oldRecords != null) messages += '\n\n old records\n' + String.valueof(oldRecords);
		if(newRecords != null) messages += '\n\n new records\n' + String.valueof(newRecords);
		
		if(trigger.isexecuting)
		{
			if(trigger.IsInsert){
		        if(trigger.IsBefore) subject = 'before insert trigger';
		        else subject = 'after insert trigger';
		    }
		     
		    else if(trigger.IsUpdate){
				if(trigger.IsBefore) subject = 'before update trigger';
		        else subject = 'after update trigger';		    
		    }  
		     
		    else if(trigger.isDelete){
		        if(trigger.IsBefore) subject = 'before delete trigger';
		        else subject = 'after delete trigger';
		    }
		     
		    else subject = 'before undelete trigger';
		}

		SL_ExceptionHandler.LicenseExceptionHandler(messages, subject);
	}
	
	@future
	private static void LicenseExceptionHandler(string body, string subject)
	{
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		
		mail.setPlainTextBody(body);
		mail.setSaveAsActivity(false);
		mail.setSubject(subject);
//		mail.setToAddresses(new list<string> {'greg@silverlinecrm.com'});
//		mail.setToAddresses(new list<string> {'elutsenko@dynamo-ny.com'});
		
		mail.setToAddresses( SL_Settings.ErrorMessageRecipients );
		
		Messaging.sendEmail(new Messaging.Email[] { mail });
	}
	
	public class MyException extends Exception {} 
	
	static testmethod void TestThis()
	{
		Test.StartTest();
		try { 
    		throw new MyException(); 
		} 
		catch (MyException e) { 
    		SL_ExceptionHandler.BuildExceptionMessage(e,null,null);
		}
		try { 
    		throw new MyException('exception message');
		} 
		catch (MyException e) { 
    		SL_ExceptionHandler.BuildExceptionMessage(e,null,null);
		}
		try { 
    		throw new MyException(); 
		} 
		catch (MyException cause) {
			try{
				throw new MyException('this is the exception cause',cause);
			} 
			catch(MyException e){
				SL_ExceptionHandler.BuildExceptionMessage(e,null,null);
			}
		} 
		Test.StopTest();
	}
}