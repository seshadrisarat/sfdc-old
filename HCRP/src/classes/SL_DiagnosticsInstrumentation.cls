/**
* @date 11/9/2014
* @description This class implements diagnostics for the application
*/
public class SL_DiagnosticsInstrumentation {
	
	public static Boolean DiagnosticsEnabled = SL_AppConfigSupport.DiagnosticsEnabled;
	public static Boolean EmailDebugInfoEnabled = SL_AppConfigSupport.EmailDebugInfoEnabled;
	public static String DebugInfoEmailRecipients = SL_AppConfigSupport.DebugInfoEmailRecipients;
	public static Integer DebugInfoMaxNum = SL_AppConfigSupport.DebugInfoMaxNum;
	public static Integer DebugInfoMaxAge = SL_AppConfigSupport.DebugInfoMaxAge;
	
	private static List<DiagnosticEntry> DiagnosticLog;
	private static Integer CurrentLevel = 0;

	private static List<String> StackTrace = new List<String>();
	public static String ExceptionTrace = '';

	private class DiagnosticEntry {
		Integer level;
		String description;
		
		private DiagnosticEntry(String entrydescription)
		{
			level = CurrentLevel;
			description = '[' + System.now().format('HH:mm:ss.SSS') + '] {' + UserInfo.getName() + '} ' + entrydescription;
		}
	}

	/** 
	* @date 11/9/2014
	* @description Should be called at the start of every function to increment and update the current execution context level.
	*/
	public static void Push(String functionname){
		Debug('Entering: ' + functionname);
		CurrentLevel+=1;
		StackTrace.add(functionname);
	}
	
	/** 
	* @date 11/9/2014
	* @description Adds new diagnostic entry to the diagnostic log (if diagnostics are enabled)
	*/
	public static void Debug(String debugstring){
		if (!DiagnosticsEnabled && !EmailDebugInfoEnabled){
			return;
		}
		if(DiagnosticLog==null) DiagnosticLog = new List<DiagnosticEntry>();
		DiagnosticLog.add(new DiagnosticEntry(debugstring));
		if(DiagnosticsEnabled){
			System.Debug(LoggingLevel.Info, debugstring);
		}
	}
	
	/** 
	* @date 11/9/2014
	* @description Called prior to PopAll to add exception info to diagnostic log and object
	*/
	public static void DebugException(Exception ex){
		String exceptioninfo = 'Exception occurred line ' + ex.getLineNumber() + ' - ' + ex.getMessage() + ' stack: ' + ex.getStackTraceString();
		Debug(exceptioninfo);
		DebugInfo__c dbg = new DebugInfo__c(DebugData__c = CurrentLog());
		ExceptionTrace = ' Exception occurred line ' + ex.getLineNumber() + ' - ' + ex.getMessage();
		for(String st: StackTrace) ExceptionTrace += ' | ' + st;
		ExceptionTrace += ' |\n ';
		if(DiagnosticsEnabled){
			insert dbg;
			if (DebugInfoMaxNum!=null || DebugInfoMaxAge!=null)
				CheckDebugInfoLog();
		}
		if (EmailDebugInfoEnabled && DebugInfoEmailRecipients!=null && DebugInfoEmailRecipients!=''){
			EmailDebugInfoLog(new List<DebugInfo__c>{dbg}, 'The following exception occured, see attached CSV:\n'+ dbg.DebugData__c);
		}
	}

	/** 
	* @date 11/9/2014
	* @description Should be called on the exit of every function to decrement and update the current execution context level.
	*/
	public static void Pop(){
		if(CurrentLevel>0) CurrentLevel-=1;
		if(CurrentLevel==0) System.Debug(LoggingLevel.Info, 'Diagnostic Log\n' + CurrentLog());
		if(StackTrace.size()>0) StackTrace.remove(StackTrace.size()-1);
	}
	
	/** 
	* @date 11/9/2014
	* @description Used for exception handling
	*/
	public static void PopAll(){
		CurrentLevel=0;
		Pop();
	}
	
	/** 
	* @date 11/9/2014
	* @description Returns multi-line string representation of diagnostic log
	*/
	public static String CurrentLog(){
		if(DiagnosticLog == null) return null;
		String spaces = '                                                                        ';
		String result = '';
		for(DiagnosticEntry de: DiagnosticLog)
		{
			Integer endindex = 3 * de.level;
			if(endindex >= spaces.length()) endindex = spaces.length()-1;
			result += spaces.substring(0,endindex) + de.description + '\n';
		}
		return result;
	}

	/** 
	* @date 11/9/2014
	* @description Checks if DebugInfo log needs clearing
	*/
	public static void CheckDebugInfoLog(){
	}
	
	/** 
	* @date 11/9/2014
	* @description Deletes DebugInfo log records
	* @param list<DebugInfo__c> List of debug info records to be deleted
	*/
	public static void ClearDebugInfoLog(list<DebugInfo__c> expiredDebugInfoLog){
	}

	public static void EmailDebugInfoLog(list<DebugInfo__c> debugInfoLog){
		EmailDebugInfoLog(debugInfoLog, 'Attached is the DebugInfo log that was cleared for ' + UserInfo.getOrganizationName() + '(' + UserInfo.getOrganizationId() + ')');
	}

	/** 
	* @date 11/9/2014
	* @description Emails DebugInfo log
	* @param list<DebugInfo__c> List of debug info records to be emailed
	*/
	public static void EmailDebugInfoLog(list<DebugInfo__c> debugInfoLog, String emailMessage){
		//Define email settings
        Messaging.SingleEmailMessage debugInfoEmail = new Messaging.SingleEmailMessage();                   
        debugInfoEmail.setToAddresses(DebugInfoEmailRecipients.split(';'));
        debugInfoEmail.setSubject('DebugInfo Log for ' + UserInfo.getOrganizationName() + '(' + UserInfo.getOrganizationId() + ')');
        debugInfoEmail.setPlainTextBody(emailMessage);
        debugInfoEmail.setHtmlBody(emailMessage);
        //Generate attachment
        String csvString = new DebugInfoLogAttachment().generate(debugInfoLog);
        transient Blob csvAttachment = Blob.valueOf(csvString);
        transient Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setBody(csvAttachment);
        efa.setContentType('text/csv');
        efa.setFileName(System.today().format()+'_'+UserInfo.getOrganizationName()+'_DebugInfoLog.csv');
        efa.setInline(false);
        debugInfoEmail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
        //Send email
        if (!Test.isRunningTest())
        	Messaging.sendEmail(new Messaging.SingleEmailMessage[] {debugInfoEmail});
	}

	private class DebugInfoLogAttachment {
		
		private String generate(list<DebugInfo__c> diLog) {
	        String s = line(new String[] {
	                format('DebugInfo Entry'),
	                format('Created Date'),
	                format('Debug Data')
	                });
	        for (DebugInfo__c di : diLog) {
	            s += line(new String[] {
	                    format(di.Name),
	                    format(di.CreatedDate),
	                    format(di.DebugData__c)
	                    });
	        }
	        return s;
	    }
	    private String line(String[] cells) {
	        return String.join(cells, ',') + '\n';
	    }
	    private String format(DateTime dt)    {
	        return dt != null ? '"' + dt.format().escapeCsv() + '"' : '""';
	    }
	    private String format(String s) {
	        return s != null ? '"' + s.escapeCsv() + '"' : '""';
	    }
	}
	
}