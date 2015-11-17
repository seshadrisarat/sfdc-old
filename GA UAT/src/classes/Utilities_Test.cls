@isTest (SeeAllData = false)
public class Utilities_Test {
    static testMethod void Test_Utilities() {
        Utilities.dealReferralRollup(NULL);
        Utilities.dealsWorkedRollup(NULL);
        Utilities.employeeRollup(NULL);
        Utilities.themeRollup(NULL);
        Utilities.companyThemeRollup(NULL);
        Utilities.initializeAccount(NULL);
        Utilities.initializeDeal(NULL);
        Utilities.initializeEmployee(NULL);
        Utilities.initializeTheme(NULL);
        Utilities.employeeMetric(NULL);
        Utilities.getPublicTeamMembers();
        
        Set<Id> idSet = new Set<Id>{UserInfo.getUserId()};
        Utilities.quoteSet(idSet);
        
        Account acc = new Account(name='Test Deal Company');
        insert acc;
        
        Contact c = new Contact(FirstName='Test',LastName='Contact',AccountID=acc.id);
        insert c;
        Deal__c d = new Deal__c(Related_Company__c=acc.Id,Source_Name__c=c.id,Source_Company__c=acc.id,Deal_Size_MM__c=5,Status__c='Early Investigation');
        d.Competitive_Dynamic__c = 'Exclusive';
        insert d;
        Utilities.rollupAccountStatistics(d);
        
        Account a = new Account(Name = 'test acc1');
        a.Total_Intros_Referred__c = 1;
        a.Total_Intros_Referred_Value_MM__c = 1;
        a.Total_Exclusives_Referred__c = 1;
        a.Total_Intros_Referred_LTM__c = 1;
        a.Total_Exclusives_Referred_LTM__c = 1;
        a.Total_Intros_Referred_Value_LTM__c = 1;
        insert a;
        
        Account b = new Account(Name = 'test acc2');
        b.Total_Intros_Referred__c = 1;
        b.Total_Intros_Referred_Value_MM__c = 1;
        b.Total_Exclusives_Referred__c = 1;
        b.Total_Intros_Referred_LTM__c = 1;
        b.Total_Exclusives_Referred_LTM__c = 1;
        b.Total_Intros_Referred_Value_LTM__c = 1;
        insert b;
        Utilities.combineAccountStatistics(a, b, 2);
    }
}