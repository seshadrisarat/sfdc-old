public class Utilities {
    private Utilities() {}

    public static void dealReferralRollup(String query) {
        try {
            List<AsyncApexJob> jobQueue = [SELECT Id FROM AsyncApexJob WHERE CompletedDate=NULL];
            if (jobQueue.size() < 5) {
                Database.executeBatch(new DealReferralRollupBatchable(query));
            }
        } catch (Exception e) {
        }
    }


    public static void dealsWorkedRollup(String query) {
        try {
            List<AsyncApexJob> jobQueue = [SELECT Id FROM AsyncApexJob WHERE CompletedDate=NULL];
            if (jobQueue.size() < 5) {
                Database.executeBatch(new DealsWorkedRollupBatchable(query));
            }
        } catch (Exception e) {
        }
    }


    public static void employeeRollup(String query) {
        try {
            List<AsyncApexJob> jobQueue = [SELECT Id FROM AsyncApexJob WHERE CompletedDate=NULL];
            if (jobQueue.size() < 5) {
                Database.executeBatch(new EmployeeRollupBatchable(query));
            }
        } catch (Exception e) {
        }
    }


    public static void themeRollup(String query) {
        try {
            List<AsyncApexJob> jobQueue = [SELECT Id FROM AsyncApexJob WHERE CompletedDate=NULL];
            if (jobQueue.size() < 5) {
                Database.executeBatch(new ThemeRollupBatchable(query));
            }
        } catch (Exception e) {
        }
    }


    public static void companyThemeRollup(String query) {
        try {
            List<AsyncApexJob> jobQueue = [SELECT Id FROM AsyncApexJob WHERE CompletedDate=NULL];
            if (jobQueue.size() < 5) {
                Database.executeBatch(new CompanyThemeRollupBatchable(query));
            }
        } catch (Exception e) {
        }
    }
    

    public static void initializeAccount(String query) {
        try {
            List<AsyncApexJob> jobQueue = [SELECT Id FROM AsyncApexJob WHERE CompletedDate=NULL];
            if (jobQueue.size() < 5) {
                Database.executeBatch(new InitializeAccountBatchable(query));
            }
        } catch (Exception e) {
        }
    }


    public static void initializeDeal(String query) {
        try {
            List<AsyncApexJob> jobQueue = [SELECT Id FROM AsyncApexJob WHERE CompletedDate=NULL];
            if (jobQueue.size() < 5) {
                Database.executeBatch(new InitializeDealBatchable(query));
            }
        } catch (Exception e) {
        }
    }


    public static void initializeEmployee(String query) {
        try {
            List<AsyncApexJob> jobQueue = [SELECT Id FROM AsyncApexJob WHERE CompletedDate=NULL];
            if (jobQueue.size() < 5) {
                Database.executeBatch(new InitializeEmployeeBatchable(query));
            }
        } catch (Exception e) {
        }
    }


    public static void initializeTheme(String query) {
        try {
            List<AsyncApexJob> jobQueue = [SELECT Id FROM AsyncApexJob WHERE CompletedDate=NULL];
            if (jobQueue.size() < 5) {
                Database.executeBatch(new InitializeThemeBatchable(query));
            }
        } catch (Exception e) {
        }
    }


    public static void employeeMetric(Date d) {
        try {
            List<AsyncApexJob> jobQueue = [SELECT Id FROM AsyncApexJob WHERE CompletedDate=NULL];
            if (jobQueue.size() < 5) {
                Database.executeBatch(new EmployeeMetricBatchable(d));
            }
        } catch (Exception e) {
        }
    }


    public static String quoteSet(Set<Id> ids) {
        String s = '';
        for (Id i : ids) {
            s += ',\'' + i + '\'';
        }
        return s.substring(1);
    }


    public static Account rollupAccountStatistics(Deal__c d) {
        Account a;
        if (d.Source_Company__c != null) {
            a = new Account(
                Id = d.Source_Company__c,
                Total_Intros_Referred__c = 1,
                Total_Intros_Referred_Value_MM__c = d.Deal_Size_MM__c
            );
            if (d.Competitive_Dynamic__c == 'Exclusive') {
                a.Total_Exclusives_Referred__c = 1;
                a.Total_Exclusives_Referred_Value_MM__c = d.Deal_Size_MM__c;
            }
        }
        return a;
    }

    public static Set<Id> getPublicTeamMembers() {
        Set<Id> teamUserIds = new Set<Id>();
        
        //identify all public groups where the current user is a member
        List<Id> groups = new List<Id>();
        for (GroupMember gm : [SELECT GroupId FROM GroupMember WHERE UserOrGroupId = :userInfo.getUserID()]) {
            groups.add(gm.GroupId);
        }
        
        //search for all team members of the groups
        if (!groups.isEmpty()) {
            for (GroupMember gm : [SELECT UserOrGroupId, Group.Name, Group.RelatedID From GroupMember WHERE Group.Name LIKE 'Team: %' AND GroupId IN :groups]) {
                teamUserIds.add(gm.UserOrGroupId);
                teamUserIds.add(gm.Group.RelatedID);
            }
        }
        return teamUserIds;
    }

    public static Account combineAccountStatistics(Account a, Account b, Integer multiplier) {
        Account c = new Account(
            Id = a.Id,
            Total_Intros_Referred__c = 0,
            Total_Intros_Referred_Value_MM__c = 0,
            Total_Exclusives_Referred__c = 0,
            Total_Exclusives_Referred_Value_MM__c = 0,
            Total_Intros_Referred_LTM__c = 0,
            Total_Intros_Referred_Value_LTM__c = 0,
            Total_Exclusives_Referred_LTM__c = 0,
            Total_Exclusives_Referred_Value_LTM__c = 0
        );

        if (a.Total_Intros_Referred__c != null) {
            c.Total_Intros_Referred__c += a.Total_Intros_Referred__c;
        }
        if (a.Total_Intros_Referred_Value_MM__c != null) {
            c.Total_Intros_Referred_Value_MM__c += a.Total_Intros_Referred_Value_MM__c;
        }
        if (a.Total_Exclusives_Referred__c != null) {
            c.Total_Exclusives_Referred__c += a.Total_Exclusives_Referred__c;
        }
        if (a.Total_Exclusives_Referred_Value_MM__c != null) {
            c.Total_Exclusives_Referred_Value_MM__c += a.Total_Exclusives_Referred_Value_MM__c;
        }
        if (a.Total_Intros_Referred_LTM__c != null) {
            c.Total_Intros_Referred_LTM__c += a.Total_Intros_Referred_LTM__c;
        }
        if (a.Total_Intros_Referred_Value_LTM__c != null) {
            c.Total_Intros_Referred_Value_LTM__c += a.Total_Intros_Referred_Value_LTM__c;
        }
        if (a.Total_Exclusives_Referred_LTM__c != null) {
            c.Total_Exclusives_Referred_LTM__c += a.Total_Exclusives_Referred_LTM__c;
        }
        if (a.Total_Exclusives_Referred_Value_LTM__c != null) {
            c.Total_Exclusives_Referred_Value_LTM__c += a.Total_Exclusives_Referred_Value_LTM__c;
        }

        if (b.Total_Intros_Referred__c != null) {
            c.Total_Intros_Referred__c += (multiplier * b.Total_Intros_Referred__c);
        }
        if (b.Total_Intros_Referred_Value_MM__c != null) {
            c.Total_Intros_Referred_Value_MM__c += (multiplier * b.Total_Intros_Referred_Value_MM__c);
        }
        if (b.Total_Exclusives_Referred__c != null) {
            c.Total_Exclusives_Referred__c += (multiplier * b.Total_Exclusives_Referred__c);
        }
        if (b.Total_Exclusives_Referred_Value_MM__c != null) {
            c.Total_Exclusives_Referred_Value_MM__c += (multiplier * b.Total_Exclusives_Referred_Value_MM__c);
        }
        if (b.Total_Intros_Referred_LTM__c != null) {
            c.Total_Intros_Referred_LTM__c += (multiplier * b.Total_Intros_Referred_LTM__c);
        }
        if (b.Total_Intros_Referred_Value_LTM__c != null) {
            c.Total_Intros_Referred_Value_LTM__c += (multiplier * b.Total_Intros_Referred_Value_LTM__c);
        }
        if (b.Total_Exclusives_Referred_LTM__c != null) {
            c.Total_Exclusives_Referred_LTM__c += (multiplier * b.Total_Exclusives_Referred_LTM__c);
        }
        if (b.Total_Exclusives_Referred_Value_LTM__c != null) {
            c.Total_Exclusives_Referred_Value_LTM__c += (multiplier * b.Total_Exclusives_Referred_Value_LTM__c);
        }

        return c;
    }
}