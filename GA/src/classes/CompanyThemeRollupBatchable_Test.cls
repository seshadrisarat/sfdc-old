@isTest
public class CompanyThemeRollupBatchable_Test {
    static testMethod void Test_CompanyThemeRollupBatchable() {
        Account acc = new Account(Name = 'Test Acc', Pursuable__c = true);
        insert acc;
        Theme__c themeObj = new Theme__c(Name = 'Test Theme');
        insert themeObj;
        Company_Theme__c compTheme = new Company_Theme__c(Company__c = acc.Id, Theme__c = themeObj.Id);
        insert compTheme;
    }
}