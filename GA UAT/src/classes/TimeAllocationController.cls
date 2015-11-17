public with sharing class TimeAllocationController {
    public static final String LIVE_DEALS = 'Live Deals';
    public static final String THEMES = 'Market Research';
    public static final String PROSPECTING = 'Prospecting';
    public static final String PORTFOLIO_COMPANIES = 'Portfolio Companies';
    public static final String DELETED = 'DELETED';
    public static final String FIRM_PROJECT = 'Firm Project';

    public transient String dmessage { get; set; }
    public Time_Allocation__c weekOf { get; private set; }
    public Date startDate { get; private set; }
    public Date endDate { get; private set; }
    public String tableTitle { get; private set; }
    public String employeeName { get; private set;}
    public String filterSelected { get; set; }
    public List<SelectOption> filterOptions { get; private set; }

    private Id employeeId;
    private PageReference redirectRef;

    private Map<String, List<Time_Allocation__c>> allocationMap { get; private set; }
    public List<Time_Allocation__c> liveDealList { get; private set; }
    public List<Time_Allocation__c> themeList { get; private set; }
    public List<Time_Allocation__c> prospectingList { get; private set; }
    public List<Time_Allocation__c> portfolioCompanyList { get; private set; }
    public List<Time_Allocation__c> firmProjectList { get; private set; }

    public TimeAllocationController() {
        employeeId = ApexPages.currentPage().getParameters().get('Id');
        try {
            if (employeeId == null) {
                Employee__c e = [SELECT Id, Name FROM Employee__c WHERE SalesforceUser__c=:UserInfo.getUserId() LIMIT 1];
                employeeId = e.Id;
                employeeName = e.Name;
                redirectRef = new PageReference('/home/home.jsp');
            } else {
                employeeName = [SELECT Id, Name FROM Employee__c WHERE Id=:employeeId LIMIT 1].Name;
                redirectRef = new PageReference('/' + employeeId);
            }
    
            filterSelected = 'THIS_WEEK';
            filterOptions = new List<SelectOption> {
                new SelectOption('LAST_WEEK', 'Last Week'),
                new SelectOption('THIS_WEEK', 'This Week'),
                new SelectOption('NEXT_WEEK', 'Next Week')
            };
    
            weekOf = new Time_Allocation__c(
                Date__c = Date.today().addDays(-7)
            );
            refresh();
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid or missing employee ID'));
        }
    }
    private void refresh() {
        setFilterRange(0);
        refreshAllocations();
        applyFilter();
    }

    private void refreshAllocations() {
        allocationMap = new Map<String, List<Time_Allocation__c>>();
        allocationMap.put(DELETED, new List<Time_Allocation__c>());
        List<String> categories = new List<String> { LIVE_DEALS, THEMES, PROSPECTING, PORTFOLIO_COMPANIES, FIRM_PROJECT };
        for (String c : categories) {
            for (Integer i=0; i<3; i++) {
                allocationMap.put(c + i, new List<Time_Allocation__c>());
            }
        }

        // Existing allocations
        for (Time_Allocation__c a : [SELECT Id, Deal_Team_Member__c, Category__c, Allocation__c, Estimated_Allocation__c, Date__c, Expected_Calls__c, Actual_Calls__c, Actual_Events__c, Related_Company__c, Related_Deal__c, Related_Theme__c, Description__c FROM Time_Allocation__c WHERE Deal_Team_Member__c=:employeeId AND Date__c>=:startDate AND Date__c<:endDate AND IsDeleted=FALSE AND Category__c<>NULL]) {
            Integer index = startDate.daysBetween(a.Date__c) / 7;
            try {
                if (a.Category__c == 'Themes') {
                    allocationMap.get('Market Research' + index).add(a); 
                } else {
                    allocationMap.get(a.Category__c + index).add(a);
                }
            } catch (Exception e) {
            }
        }

        // Prospecting calls
        for (Integer i=0; i<3; i++) {
            if (allocationMap.get(PROSPECTING + i).isEmpty()) {
                addAnother(PROSPECTING, i);
            } else {
                allocationMap.get(PROSPECTING + i).get(0).Actual_Calls__c = 0;
                allocationMap.get(PROSPECTING + i).get(0).Actual_Events__c = 0;
            }
        }
        
        // Count Actual Calls
        for (Task t : [SELECT Id, ActivityDate FROM Task WHERE IsClosed=TRUE AND Type='Prospect Call' AND ActivityDate>=:startDate AND ActivityDate<:endDate AND OwnerId=:UserInfo.getUserId() AND IsDeleted=FALSE]) {
            Integer index = startDate.daysBetween(t.ActivityDate) / 7;
            try {
                allocationMap.get(PROSPECTING + index).get(0).Actual_Calls__c++;
            } catch (Exception e) {
            }
        }
        
        // Count Actual Events
         for (Event t : [SELECT Id, ActivityDate FROM Event WHERE Type='Prospect Meeting' AND ActivityDate>=:startDate AND ActivityDate<:endDate AND OwnerId=:UserInfo.getUserId() AND IsDeleted=FALSE]) {
            Integer index = startDate.daysBetween(t.ActivityDate) / 7;
            try {
                allocationMap.get(PROSPECTING + index).get(0).Actual_Events__c++;
            } catch (Exception e) {
            }
        }
        
        // Initialize 5 empty rows
        for (Integer i=0; i<3; i++) {
            for (Integer j=0; j<5; j++) {
                addAnother(LIVE_DEALS, i);
                addAnother(THEMES , i);
                addAnother(PORTFOLIO_COMPANIES, i);
                addAnother(FIRM_PROJECT, i);
            }
        }
    }

    private Integer weekIndex() {
        Integer index = 0;
        if (filterSelected == 'THIS_WEEK') {
            index = 1;
        } else if (filterSelected == 'NEXT_WEEK') {
            index = 2;
        }
        return index;
    }

    public void applyFilter() {
        Integer index = weekIndex();
        liveDealList = buildList(LIVE_DEALS, index);
        themeList = buildList(THEMES, index);
        prospectingList = buildList(PROSPECTING, index);
        portfolioCompanyList = buildList(PORTFOLIO_COMPANIES, index);
        firmProjectList = buildList(FIRM_PROJECT, index);
        
        Datetime dtStart = Datetime.newInstanceGmt(weekOf.Date__c.year(), weekOf.Date__c.month(), weekOf.Date__c.day()).addDays(7 * index + 1);
        Datetime dtEnd = dtStart.addDays(6);
        tableTitle = dtStart.format('EE MMMMM d, yyyy') + ' - ' + dtEnd.format('EE MMMMM d, yyyy');
    }

    private List<Time_Allocation__c> buildList(String category, Integer index) {
        return allocationMap.get(category + index);
    }


    public PageReference saveAllocations() {
        List<Time_Allocation__c> records = new List<Time_Allocation__c>();
        Map<Integer,Decimal> weeklyTotal = new Map<Integer,Decimal>();
        for (Integer i=0; i<3; i++) {
            weeklyTotal.put(i,0);
            
            // Live deals
            Map<Id, Time_Allocation__c> dealAllocationMap = new Map<Id, Time_Allocation__c>();
            for (Time_Allocation__c a : allocationMap.get(LIVE_DEALS + i)) {
                if (a.Related_Deal__c == null) {
                    continue;
                }
                Time_Allocation__c aClone = cloneAllocation(a);
                if (dealAllocationMap.containsKey(a.Related_Deal__c)) {
                    Time_Allocation__c relatedAllocation = dealAllocationMap.get(a.Related_Deal__c);
                    relatedAllocation.Allocation__c += a.Allocation__c;
                    relatedAllocation.Estimated_Allocation__c += a.Estimated_Allocation__c;
                } else if (aClone.Id != null || aClone.Allocation__c > 0 || aClone.Estimated_Allocation__c > 0) {
                    dealAllocationMap.put(aClone.Related_Deal__c, aClone);
                }
                if (a.Allocation__c == null) {
                    a.Allocation__c = 0;
                }
                weeklyTotal.put(i,weeklyTotal.get(i) + a.Allocation__c);
            }

            // Themes
            Map<Id, Time_Allocation__c> themeAllocationMap = new Map<Id, Time_Allocation__c>();
            for (Time_Allocation__c a : allocationMap.get(THEMES + i)) {
                if (a.Related_Theme__c == null) {
                    continue;
                }
                Time_Allocation__c aClone = cloneAllocation(a);
                if (themeAllocationMap.containsKey(a.Related_Theme__c)) {
                    Time_Allocation__c relatedAllocation = themeAllocationMap.get(a.Related_Theme__c);
                    relatedAllocation.Allocation__c += a.Allocation__c;
                    relatedAllocation.Estimated_Allocation__c += a.Estimated_Allocation__c;
                } else if (aClone.Id != null || aClone.Allocation__c > 0 || aClone.Estimated_Allocation__c > 0) {
                    themeAllocationMap.put(aClone.Related_Theme__c, aClone);
                }
                if (a.Allocation__c == null) {
                    a.Allocation__c = 0;
                }
                weeklyTotal.put(i,weeklyTotal.get(i) + a.Allocation__c);
            }

            // Portfolio companies
            Map<Id, Time_Allocation__c> companyAllocationMap = new Map<Id, Time_Allocation__c>();
            for (Time_Allocation__c a : allocationMap.get(PORTFOLIO_COMPANIES + i)) {
                if (a.Related_Company__c == null) {
                    continue;
                }
                Time_Allocation__c aClone = cloneAllocation(a);
                if (companyAllocationMap.containsKey(a.Related_Company__c)) {
                    Time_Allocation__c relatedAllocation = companyAllocationMap.get(a.Related_Company__c);
                    relatedAllocation.Allocation__c += a.Allocation__c;
                    relatedAllocation.Estimated_Allocation__c += a.Estimated_Allocation__c;
                } else if (aClone.Id != null || aClone.Allocation__c > 0 || aClone.Estimated_Allocation__c > 0) {
                    companyAllocationMap.put(aClone.Related_Company__c, aClone);
                }
                if (a.Allocation__c == null) {
                    a.Allocation__c = 0;
                }
                weeklyTotal.put(i,weeklyTotal.get(i) + a.Allocation__c);
            }
            
            // Firm Projects
            Map<String, Time_Allocation__c> firmProjectAllocationMap = new Map<String, Time_Allocation__c>();
            for (Time_Allocation__c a : allocationMap.get(FIRM_PROJECT + i)) {
                Time_Allocation__c aClone = cloneAllocation(a);
                if (firmProjectAllocationMap.containsKey(a.Description__c)) {
                    Time_Allocation__c relatedAllocation = companyAllocationMap.get(a.Description__c);
                    relatedAllocation.Allocation__c += a.Allocation__c;
                    relatedAllocation.Estimated_Allocation__c += a.Estimated_Allocation__c;
                } else if (aClone.Id != null || aClone.Allocation__c > 0 || aClone.Estimated_Allocation__c > 0) {
                    firmProjectAllocationMap.put(aClone.Description__c, aClone);
                }
                if (a.Allocation__c == null) {
                    a.Allocation__c = 0;
                }
                weeklyTotal.put(i,weeklyTotal.get(i) + a.Allocation__c);
            }
            
            for (Time_Allocation__c prospect : allocationMap.get(PROSPECTING + i)) {
                if (prospect.Allocation__c == null) {
                    prospect.Allocation__c = 0;
                }
                weeklyTotal.put(i,weeklyTotal.get(i) + prospect.Allocation__c);
            }
            
            if (weeklyTotal.get(i) == 0 || weeklyTotal.get(i) == 100) {
                // Add records for processing
                records.addAll(dealAllocationMap.values());
                records.addAll(themeAllocationMap.values());
                records.addAll(companyAllocationMap.values());
                records.addAll(firmProjectAllocationMap.values());
                records.addAll(allocationMap.get(PROSPECTING + i));
            } else {
                System.debug('i=' + i + ' | total = ' + weeklyTotal.get(i));
                
                if (i == 0) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Weekly allocation for last week does not equal 100%'));
                } if (i == 1) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Weekly allocation for this week does not equal 100%'));
                } else if (i == 2) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Weekly allocation for next week does not equal 100%'));
                }
            }
        }
        if (ApexPages.hasMessages()) {
            return null;
        }

        try {
            if (!records.isEmpty()) {
                System.debug(records);
                upsert records;
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Insufficient access rights to affected records.'));
            return null;    
        }
        
        try {
            List<Time_Allocation__c> deleteRecords = allocationMap.get(DELETED);
            if (!deleteRecords.isEmpty()) {
                delete deleteRecords;
            }
        } catch (Exception e) {
            return null;
        }
        return redirectBack();
    }

    public PageReference redirectBack() {
        return redirectRef;
    }

    private void setFilterRange(Integer days) {
        weekOf.Date__c = weekOf.Date__c.addDays(days).toStartOfWeek();
        startDate = weekOf.Date__c.toStartOfWeek();
        endDate = startDate.addDays(21);
    }

    public void previous() {
        setFilterRange(-7);
        refresh();
    }

    public void next() {
        setFilterRange(7);
        refresh();
    }


    public void addLiveDeal() {
        addAnother(LIVE_DEALS, weekIndex());
    }

    public void addTheme() {
        addAnother(THEMES, weekIndex());
    }

    public void addPortfolioCompany() {
        addAnother(PORTFOLIO_COMPANIES, weekIndex());
    }

    public void addFirmProject() {
        addAnother(FIRM_PROJECT, weekIndex());
    }
    
    private void addAnother(String category, Integer index) {
        Time_Allocation__c allocation = new Time_Allocation__c(
            Deal_Team_Member__c = employeeId,
            Category__c = category,
            Date__c = startDate.addDays(index * 7),
            Allocation__c = 0,
            Estimated_Allocation__c = 0,
            Actual_Calls__c = 0,
            Expected_Calls__c = 0,
            Actual_Events__c = 0
        );
        allocationMap.get(category + index).add(allocation);
    }

    private Time_Allocation__c cloneAllocation(Time_Allocation__c a) {
        Time_Allocation__c aClone = a.clone(true, true);
        if (aClone.Allocation__c == null) {
            aClone.Allocation__c = 0;
        }
        if (aClone.Estimated_Allocation__c == null) {
            aClone.Estimated_Allocation__c = 0;
        }
        if (aClone.Expected_Calls__c == null) {
            aClone.Expected_Calls__c = 0;
        }
        if (aClone.Actual_Calls__c == null) {
            aClone.Actual_Calls__c = 0;
        }
        
        if (aClone.Actual_Events__c == null) {
            aClone.Actual_Events__c = 0;
        }
        return aClone;
    }
    
    
    public void deleteAllocation() {
        try {
            String category = ApexPages.currentPage().getParameters().get('category');
            Integer index = Decimal.valueOf(ApexPages.currentPage().getParameters().get('index')).intValue();
            Integer weekIndex = weekIndex();
            allocationMap.get(DELETED).add(allocationMap.get(category + weekIndex).remove(index));
            if (allocationMap.get(category + weekIndex).isEmpty()) {
                addAnother(category, weekIndex);
            }
        } catch (Exception e) {
        }        
    }    
}