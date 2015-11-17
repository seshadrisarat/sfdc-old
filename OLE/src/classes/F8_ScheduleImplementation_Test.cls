@isTest 
private class F8_ScheduleImplementation_Test {
    static testMethod void testStatement_Distribution() {
        system.debug('@@@INFO m_HalfYear_MMDD_code='+F8_ScheduleImplementation.m_HalfYear_MMDD_code);
        system.debug('@@@INFO m_Quarterly_MMDD_code='+F8_ScheduleImplementation.m_Quarterly_MMDD_code);
        system.debug('@@@INFO m_Monthly_MMDD_code='+F8_ScheduleImplementation.m_Monthly_MMDD_code);
        system.debug('@@@INFO Case_RecordTypeId_Statement'+F8_ScheduleImplementation.Case_RecordTypeId_Statement);
        string sYear=string.valueof(date.today().year());
        string sMonth=('00' + string.valueof(date.today().month())).right(2);
        string sDay=('00' + string.valueof(date.today().day())).right(2);
        
        string sMMDD=sMonth+sDay;   
        F8_ScheduleImplementation.m_HalfYear_MMDD_code.put(sMMDD,'Test3rdHalfYear');
        F8_ScheduleImplementation.m_Quarterly_MMDD_code.put(sMMDD,'Test5thQuarter');
        F8_ScheduleImplementation.m_Monthly_MMDD_code.put(sMMDD,'Test13thMonth');
        List<Account> lAc_test=new List<Account>{
            new Account(Name='Test Admin Account Half-Yearly', recordtypeid=F8_ScheduleImplementation.Account_RecordTypeId_AdminAcct, Payment_Frequency__c='Half-Yearly',MM_COCD__c='000001')
            ,new Account(Name='Test Admin Account Quarterly', recordtypeid=F8_ScheduleImplementation.Account_RecordTypeId_AdminAcct, Payment_Frequency__c='Quarterly',MM_COCD__c='000002')
            ,new Account(Name='Test Admin Account Monthly', recordtypeid=F8_ScheduleImplementation.Account_RecordTypeId_AdminAcct, Payment_Frequency__c='Monthly',MM_COCD__c='000003')
        };
        insert lAc_test;
        F8_ScheduleImplementation.Statement_Distribution();
    }
}