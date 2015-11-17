global class DealReferralRollupBatchable implements Database.Batchable<SObject>, Database.Stateful {
    private String query;
    private Map<Id, Account> companyMap;

    global DealReferralRollupBatchable(String query) {
        this.query = 'SELECT Source_Company__c, Competitive_Dynamic__c, Deal_Size_MM__c, CreatedDate FROM Deal__c WHERE Source_Company__c<>NULL AND Source_Company__r.RecordType.DeveloperName=\'Intermediary\' AND IsDeleted=FALSE';
        if (query != null) {
            this.query = query;
        }
        companyMap = new Map<Id, Account>();
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<SObject> batch) {
        Map<Id, Account> accounts = new Map<Id, Account>();
        for (Deal__c d : (List<Deal__c>) batch) {
            Account a = getAccount(d.Source_Company__c);
            // All
            a.Total_Intros_Referred__c++;
            try {
                a.Total_Intros_Referred_Value_MM__c += d.Deal_Size_MM__c;
            } catch (Exception e) {
            }
            if (d.Competitive_Dynamic__c == 'Exclusive') {
                a.Total_Exclusives_Referred__c++;
                try {
                    a.Total_Exclusives_Referred_Value_MM__c += d.Deal_Size_MM__c;
                } catch (Exception e) {
                }
            }
            // LTM
            if (d.CreatedDate.date() > Date.today().addMonths(-12) && d.CreatedDate.date() <= Date.today()) {
                a.Total_Intros_Referred_LTM__c++;
                try {
                    a.Total_Intros_Referred_Value_LTM__c += d.Deal_Size_MM__c;
                } catch (Exception e) {
                }
                if (d.Competitive_Dynamic__c == 'Exclusive') {
                    a.Total_Exclusives_Referred_LTM__c++;
                    try {
                        a.Total_Exclusives_Referred_Value_LTM__c += d.Deal_Size_MM__c;
                    } catch (Exception e) {
                    }
                }
            }

            accounts.put(a.Id, a);
        }

        if (!accounts.isEmpty()) {
            update accounts.values();
        }
    }

    global void finish(Database.BatchableContext bc) {}

    private Account getAccount(Id aId) {
        Account a = companyMap.get(aId);
        if (a == null) {
            a = new Account(
                Id = aId,
                Total_Intros_Referred__c = 0,
                Total_Exclusives_Referred__c = 0,
                Total_Exclusives_Referred_Value_MM__c = 0,
                Total_Intros_Referred_Value_MM__c = 0,
                Total_Intros_Referred_LTM__c = 0,
                Total_Exclusives_Referred_LTM__c = 0,
                Total_Exclusives_Referred_Value_LTM__c = 0,
                Total_Intros_Referred_Value_LTM__c = 0
            );
            companyMap.put(aId, a);
        }
        return a;
    }
    
    static testMethod void testDealReferralRollupBatchable() {
        RecordType intermediary = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Intermediary' LIMIT 1];
        
        //User u = [SELECT Id, LastName FROM User WHERE LastName = 'Fidler' AND isActive = TRUE LIMIT 1];
        User u = [SELECT Id, LastName FROM User WHERE isActive = TRUE LIMIT 1];

        Account a = new Account(name='Test Deal Company', RecordTypeId=intermediary.Id);
        insert a;

        Contact c = new Contact(FirstName='Test',LastName='Contact',AccountID=a.id);
        insert c;

        Deal__c d = new Deal__c(Related_Company__c=a.Id,Source_Name__c=c.id,Source_Company__c=a.id,Competitive_Dynamic__c='Exclusive',Deal_Size_MM__c=5,Status__c='Early Investigation');
        insert d;

        Deal_Contact__c dc = new Deal_Contact__c(Deal__c=d.Id,Contact_Name__c=c.id);
        insert dc;

        Employee__c e = new Employee__c(SalesforceUser__c=u.Id,Initials__c='!TL');
        insert e;

        Employee_Metrics__c em = new Employee_Metrics__c(Employee__c=e.id,Date__c=Date.today());
        insert em;

        Team_Member__c tm = new Team_Member__c(Deal__c=d.Id,Name__c=e.Id);
        insert tm;

        Theme__c thm = new Theme__c(Name='Test Theme',Assigned_To_v2__c=e.Id,Active__c='Active');
        insert thm;

        thm.Name = 'Test Theme 2';
        update tm;

        Deal_Theme__c dt = new Deal_Theme__c(Deal__c=d.Id,Theme__c=thm.Id);
        insert dt;

        Test.startTest();
        Database.executeBatch(new DealReferralRollupBatchable('SELECT Source_Company__c, Competitive_Dynamic__c, Deal_Size_MM__c, CreatedDate FROM Deal__c WHERE Source_Company__c=\''+a.Id+'\' AND IsDeleted=FALSE'));
        Test.stopTest();
    }
}