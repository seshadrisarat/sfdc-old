public with sharing class ProjectExtension {
    private ApexPages.StandardController controller;

    public ProjectExtension(ApexPages.StandardController controller) {
        this.controller = controller;
    }
    
    public PageReference next() {
        String retUrl = ApexPages.currentPage().getParameters().get('retURL');
        if (retUrl == null) {
            retUrl = EncodingUtil.urlEncode('/' + Schema.SOBjectType.Project__c.getKeyPrefix(), 'UTF-8');
        }
        PageReference ref = new PageReference('/' + Schema.SOBjectType.Project__c.getKeyPrefix() + '/e?retURL=' + retUrl);
        Project__c project = (Project__c) controller.getRecord();
        ref.getParameters().put('nooverride', '1');
        ref.getParameters().put('RecordType', project.RecordTypeId);
        ref.getParameters().put('Name', project.Name);
        return ref;
    }

    private static testMethod void test() {
        Project__c p = new Project__c(
            Name = 'Project'
        );
        insert p;
        
        User u = new User(
            LastName = 'Genpact',
            ProfileId = [SELECT Id FROM Profile WHERE Name LIKE '%Genpact%' LIMIT 1].Id,
            Email = 'genpact@generalatlantic.com.test',
            UserName = 'genpact@generalatlantic.com.test',
            alias = 'gtest',
            CommunityNickName='gtest',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey='en_US',
            EmailEncodingKey='ISO-8859-1',
            LanguageLocaleKey='en_US'
        );
        insert u;
        
        Project_Team_Member__c ptm = new Project_Team_Member__c(
            Project__c = p.Id,
            Team_Member__c = u.Id
        );
        insert ptm;
        
        ApexPages.currentPage().getParameters().put('retURL', 'retURL');
        ProjectExtension controller = new ProjectExtension(new ApexPages.standardController(p));
        controller.next();
    }
}