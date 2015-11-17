public class F8_Schedule15MinImplementation 
  implements F8_Schedule15.IF8Schedule
{
/*
    Created by: Alex Romanchuk
    Created Date: 06/18/2014
    Description: Schedule Implementation - "hides" details of the scheduled class from scheduled job (to avoid problems with deployment). 
        Expects to be executed every 15 minutes
*/  
    public void Execute(SchedulableContext sc)
    {
        F8_Schedule15MinImplementation.RestartCrashedIntegrations();
//      F8_Schedule15MinImplementation.ReportNotRunning();
    }

    public static map<string,integer> m_Integration_MaxSuccessAgeMin=new map<string,integer> {'MM Clients'=>60,'Customers'=>60, 'Invoices'=>60};
    public static map<string,integer> m_Integration_RestartAfterMin=new map<string,integer> {'Customers'=>15, 'Invoices'=>15};
    
    
@future
    static public void RestartCrashedIntegrations() {
        List<Integration_Log__c> lLog=new List<Integration_Log__c> ([select Id,Integration_Object__c, Integration_Start__c FROM Integration_Log__c WHERE Integration_Status__c != 'Completed']);
        integer iRestartAfterMin;
        DateTime dtCutOffTime;
        List<Integration_Log__c> lIntegrationLog_Delete=new List<Integration_Log__c>();
        List<Log_Record__c> lLogAdd=new List<Log_Record__c>();
        for(Integration_Log__c log: lLog) {
            iRestartAfterMin=(m_Integration_RestartAfterMin.containsKey(log.Integration_Object__c))?(m_Integration_RestartAfterMin.get(log.Integration_Object__c)):(30); //default restart time=30 minutes
            dtCutOffTime=System.now();
            dtCutOffTime=dtCutOffTime.addMinutes(-iRestartAfterMin);
            if(log.Integration_Start__c < dtCutOffTime) { 
                lIntegrationLog_Delete.add(log);
                lLogAdd.add(new Log_Record__c(Source__c='Restart Crashed Integrations', Severity_Level__c='WARNING', Message__c='Crashed integration of "'+log.Integration_Object__c+'" started at '+log.Integration_Start__c 
                    + ' was restarted because it was not completed in '+iRestartAfterMin+' minutes'));
            }
        }
        try {
            if(!lIntegrationLog_Delete.isEmpty()) delete lIntegrationLog_Delete;
            if(!lLogAdd.isEmpty()) insert lLogAdd;
        } catch(Exception e) {
            insert new  Log_Record__c(Source__c='F8_Schedule15MinImplementation.RestartCrashedIntegrations', Severity_Level__c='ERROR', Message__c='System Error restarting crashed integrations:\n'+e.getMessage());
        }           
    }
/*  
@future
    static public void ReportNotRunning() {
        List<AggregateResult> lMostRecentSuccess= new List<AggregateResult>([select Integration_Object__c, max(Integration_Start__c) FROM Integration_Log__c WHERE Integration_Status__c = 'Completed' Group By Integration_Object__c]);
        integer iReportAfterMin;
        DateTime dtCutOffTime;
        DateTime dtMostRecentSuccess;   
        string sIntegration_Object;
        List<Log_Record__c> lLogAdd=new List<Log_Record__c>();
        for (AggregateResult ar : lMostRecentSuccess)  {
            sIntegration_Object=string.valueof(ar.get('Integration_Object__c'));
            iReportAfterMin=(m_Integration_MaxSuccessAgeMin.containsKey(sIntegration_Object))?(m_Integration_MaxSuccessAgeMin.get(sIntegration_Object)):(60); //default report not running integration time=60 minutes
            dtCutOffTime=dtCutOffTime.addMinutes(-iReportAfterMin);
            dtMostRecentSuccess=datetime.valueof(ar.get('max_integration_start')); //max(Integration_Start__c)
            if( dtMostRecentSuccess < dtCutOffTime ) {  lLogAdd.add(new Log_Record__c(Source__c=ar.get('Integration_Object__c') + ' integration is NOT RUNNING', Severity_Level__c='INFO', Message__c='Intgraton "'+ar.get('Integration_Object__c')+'" is not running. Most recent success: '
                    +ar.get('max_integration_start') + ' \nCheck Boomi execution log (Manage->Process reporting)'));
            }
        }
        if(!lLogAdd.isEmpty()) insert lLogAdd;
    }
*/  
}