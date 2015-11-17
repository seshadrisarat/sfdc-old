public class SL_Debug {
	private boolean flag = false;
	private LoggingLevel level = LoggingLevel.DEBUG;
	
	//public SL_Debug(String className) {
	public SL_Debug(Object obj) {
		String className = '';
		if (obj instanceof String) className = (String) obj;
		else className = String.valueOf(obj).split(':')[0];
		
		Debug_Log__c cs = Debug_Log__c.getInstance();
		if (cs != null && cs.OnOff__c==true && cs.ClassName__c.contains('|')) {
			Set<String> setClassNames = new Set<String>();
			setClassNames.addAll(cs.ClassName__c.split('\\|'));
			if(setClassNames.contains(className)) flag = true;
		}
		
		if (cs != null && cs.OnOff__c==true && Pattern.matches(cs.ClassName__c, className)==true) {
			flag = true;
		}

		if(flag == true) {
			if (cs.LogLevel__c == 'ERROR')		level = LoggingLevel.ERROR;
			else if (cs.LogLevel__c == 'WARN') 	level = LoggingLevel.WARN;
			else if (cs.LogLevel__c == 'INFO') 	level = LoggingLevel.INFO;
			else if (cs.LogLevel__c == 'DEBUG') level = LoggingLevel.DEBUG;
			else if (cs.LogLevel__c == 'FINE') 	level = LoggingLevel.FINE;
			else if (cs.LogLevel__c == 'FINER') level = LoggingLevel.FINER;
			else if (cs.LogLevel__c == 'FINEST')level = LoggingLevel.FINEST;
		}
		system.debug('flag===' + flag);
		system.debug('level===' + level);
	}
	
	public void log(Object msg) {
		if(flag == true) system.debug(level, msg);
	}
	
	public static void log(Object obj, Object msg) {
		String className = '';
		if (obj instanceof String) className = (String) obj;
		else className = String.valueOf(obj).split(':')[0];
		
		
		boolean flag = false;

		Debug_Log__c cs = Debug_Log__c.getInstance();
		
		if (cs != null && cs.OnOff__c==true && cs.ClassName__c.contains('|')) {
			Set<String> setClassNames = new Set<String>();
			setClassNames.addAll(cs.ClassName__c.split('\\|'));
			if(setClassNames.contains(className)) flag = true;
		}
		
		if (cs != null && cs.OnOff__c==true && Pattern.matches(cs.ClassName__c, className)==true) {
			flag = true;
		}
		
		if(flag == true) {
			LoggingLevel level = LoggingLevel.DEBUG;
			if (cs.LogLevel__c == 'ERROR')		level = LoggingLevel.ERROR;
			else if (cs.LogLevel__c == 'WARN') 	level = LoggingLevel.WARN;
			else if (cs.LogLevel__c == 'INFO') 	level = LoggingLevel.INFO;
			else if (cs.LogLevel__c == 'DEBUG') level = LoggingLevel.DEBUG;
			else if (cs.LogLevel__c == 'ERROR') level = LoggingLevel.ERROR;
			else if (cs.LogLevel__c == 'FINE') 	level = LoggingLevel.FINE;
			else if (cs.LogLevel__c == 'FINER') level = LoggingLevel.FINER;
			else if (cs.LogLevel__c == 'FINEST')level = LoggingLevel.FINEST;
			system.debug(level, msg);
		}
	}
}