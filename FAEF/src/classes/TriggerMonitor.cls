public class TriggerMonitor {
    public static set<string> ExecutedTriggers = new set<string>();
    
    public static testmethod void testTriggerMonitor(){
    	TriggerMonitor.ExecutedTriggers.add('Test');
    }
}