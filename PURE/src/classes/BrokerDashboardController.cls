/**
*  BrokerDashboardController contains controller method and actions to the BrokerDashboardPage VF page.
*   
*  Author  :   Wilson Ng
*  Date    :   Feb 21, 2013
*  
*  Revision History:
*  Date     Author          Comments
*  04/14/13 Redkite         Added total inforce to metric2flds, changed the scale for non broker group to not K
*  06/02/13 Redkite         Modified the displayed values on the Broker group page for Written_Premium_CYTD_EDW__c, Retention_Rate_EDW__c,
*                           Loss_Ratio_CYTD_EDW__c
*
*/
public with sharing class BrokerDashboardController {

    
    public final Account acct;
    
    public boolean isBrokerGroup { get; private set; }
    public boolean targetRollUpValueIsNotNullOrZero { get;  set;}
    private list<Id> brokerGroupIds;
    private Account brokerGroupAcct;    // consolidated record with all child values rolled up
    
    // note: displayed currency values: brokerGroup is in ($MM), whereas broker is normal
    //  This is used for CONTOLLER LEVEL VIEW FORMATTING.  (VF Can't really handle this well)
    public string currencyScaleLabel { get { return DashboardUtility.getCurrencyScaleLabel(isBrokerGroup); } }
    public string currencyScaleLabel2 { get { return currencyScaleLabel.replace('M', 'K'); } }            // work-around - barseries does not render decimal places, so it will be in $thous.
    public string currencyScaleLabel3 { get { return currencyScaleLabel.replace('\'', '\'\''); } }        // work-around - metrics table does not render the quote properly, so needs to double quotes
    private integer scale { get { return (this.isBrokerGroup?1000000:1000); } }
    private integer precision { get { return (this.isBrokerGroup?2:0); } }
    

    public BrokerDashboardController(ApexPages.StandardController ctlr) {
        Id aid = ctlr.getId();
        this.acct = (aid == null) ? (Account)ctlr.getRecord() : database.query(constructQuery('where id=:aid'));
    }
    
    public PageReference init() {
        // initialize broker group, which is used for both broker and group
        this.brokerGroupIds = new list<Id> { this.acct.Id };        // must include the parent ids in the ids list

        // the following sObject is the main data container for this controller.  For Brokers, it will contain the 
        //  brokers direct data.  For a Broker Group, the values of the child records will be rolled up into this
        //  records fields
        this.brokerGroupAcct = this.acct.clone(false, true);        // deep clone
        
        // determine if broker group
        isBrokerGroup = (this.acct.RecordType!=null && this.acct.RecordType.DeveloperName==DashboardUtility.BROKER_GROUP_REC_TYPE);
        system.debug('is broker group: ' + isBrokerGroup);
        
        // if broker group, get all associated child ids
        if(isBrokerGroup) {
            retrieveBrokerGroups();
            decimal displayValForTargetRollup = getDisplayValue(this.brokerGroupAcct, 'WP_Year_End_Target__c', 'CURRENCY');
            if(displayValForTargetRollup != null){
                if(displayValForTargetRollup > 0) {
                    this.targetRollUpValueIsNotNullOrZero = true;
                }
            } else {
                this.targetRollUpValueIsNotNullOrZero = false;
            }
        }
        system.debug('broker group ids: ' + brokerGroupIds);
        system.debug('broker group acct: ' + brokerGroupAcct);
        return null;
    }

    // retrieves all related ids for broker group and rolls up the sum and avg fields
    private void retrieveBrokerGroups() {

        // supports 1-level broker group only
        Id acctId = this.acct.Id;
        string tmpBrokerRec = DashboardUtility.BROKER_REC_TYPE;
        for(Account broker : database.query(constructQuery('where parentId=:acctId and RecordType.DeveloperName=:tmpBrokerRec'))) {
            
            // sum up fields
            for(string sumfld : sumfields) {
                Double grpTotal = DashboardUtility.getValue(this.brokerGroupAcct, sumfld);
                Double bkrTotal = DashboardUtility.getValue(broker, sumfld);
                
                this.brokerGroupAcct.put(sumfld, grpTotal + bkrTotal);
            }

            // avg fields
            for(string avgfld : avgfields) {
                // do not rollup these fields: CYTD_WP_Growth_Rate__c
                if(avgfld != 'CYTD_WP_Growth_Rate__c') {
                    Double grpTotal = DashboardUtility.getValue(this.brokerGroupAcct, avgfld) * (this.brokerGroupIds.size()-1);
                    Double bkrTotal = DashboardUtility.getValue(broker, avgfld);
                    this.brokerGroupAcct.put(avgfld, ( grpTotal + bkrTotal ) / (this.brokerGroupIds.size()));       //note: the broker group record is not included in the avg
                }
            }
                        
            // add to broker group id list
            this.brokerGroupIds.add(broker.Id);
        }
    }

    static list<string> sumfields = new list<string> {
                'of_Binds_Last_90_Days__c', 'of_Binds_90_180_Days__c', 'Binds_Amount_Last_90_Days__c', 'Binds_Amount_90_180_Days__c', 
                'of_Quotes_Last_90_Days__c', 'of_Quotes_90_180_Days__c', 'Quotes_Amount_Last_90_Days__c', 'Quotes_Amount_90_180_Days__c',
                'Written_Premium_CYTD_EDW__c', 'New_Business_WP_YTD_EDW__c', 'Total_Inforce_Premium_EDW__c', 'of_20k_accounts_EDW__c',
                'Total_Quote_Pipeline_EDW__c', 'Total_Members_EDW__c', 'WP_Year_End_Target__c'
                ,'Loss_Ratio_CYTD_EDW__c', 'Retention_Rate_EDW__c'
                // new fields added for new calculations for percentage fields
                ,'Written_Premium_YTD_Amt__c','Written_Premium_PYTD_Amt__c','Retention_CYTD_Member_Count__c','Retention_PYTD_Member_Count__c'
                ,'YTD_Reported_Loss_Amt__c','YTD_EP_Amt__c'
                
    };
    static list<string> avgfields = new list<string> {
                'CYTD_WP_Growth_Rate_EDW__c'
    };

    // constructs account query using dynamic soql
    private string constructQuery(string filterClause) {
        return string.format('select Id, Name, RecordType.DeveloperName, {0}, {1} from Account {2}', 
                        new list<string> { string.join(sumfields, ','), string.join(avgfields, ','), filterClause } );
    }
    
    private decimal getDisplayValue(sObject sobj, string fld, string typ) {
        return DashboardUtility.getDisplayValue(sobj, fld, typ, this.scale, 2); //this.precision);
    }

    
    // page getter methods ----------------------------------------------------------------------------------------------
    // Properties for the First Metric's Section
    static list<string> metric1flds = new list<string> {
            'of_Binds_90_180_Days__c', 
            'of_Binds_Last_90_Days__c', 
            'of_Quotes_90_180_Days__c', 
            'of_Quotes_Last_90_Days__c'
    };
    public list<DashboardUtility.Data> getMetrics1Data() {
        list<DashboardUtility.Data> metricsData = new list<DashboardUtility.Data>();
        for(string met : metric1flds) {
            Schema.Describefieldresult f = Schema.SObjectType.Account.fields.getMap().get(met).getDescribe();
            metricsData.add(new DashboardUtility.Data(f.getLabel(), getDisplayValue(this.brokerGroupAcct, met, string.valueof(f.getType())), string.valueof(f.getType())));
        }
        return metricsData;
    }

    // Properties for the Second Metric's Section
    static list<string> metric2flds = new list<string> {
            'Total_Inforce_Premium_EDW__c',
            'of_20k_accounts_EDW__c', 
            'Total_Quote_Pipeline_EDW__c',
            'Loss_Ratio_CYTD_EDW__c', // this is special in the Broker Group
            'Retention_Rate_EDW__c', // this is special in the Broker Group
            'Total_Members_EDW__c'
    };
    public list<DashboardUtility.Data> getMetrics2Data() {
        list<DashboardUtility.Data> metricsData = new list<DashboardUtility.Data>();
        for(string met : metric2flds) {
            Schema.Describefieldresult f = Schema.SObjectType.Account.fields.getMap().get(met).getDescribe();
            // dont use the page's default scale if MM and K.  instead go to the Dashboard Utility directly and set scale and precision for this metirc chart
            if (isBrokerGroup && met.equals('Loss_Ratio_CYTD_EDW__c')){
                Double brokerGroupVal = (this.brokerGroupAcct.YTD_EP_Amt__c==0) ? 0 :
                    (this.brokerGroupAcct.YTD_Reported_Loss_Amt__c / this.brokerGroupAcct.YTD_EP_Amt__c)*100;

                metricsData.add(new DashboardUtility.Data(f.getLabel(), DashboardUtility.getDisplayValue(brokerGroupVal, 1, this.precision),
                    string.valueof(f.getType())));
            }
            else if (isBrokerGroup && met.equals('Retention_Rate_EDW__c')){
                Double brokerGroupVal = (this.brokerGroupAcct.Retention_PYTD_Member_Count__c==0) ? 0 :
                    (this.brokerGroupAcct.Retention_CYTD_Member_Count__c / this.brokerGroupAcct.Retention_PYTD_Member_Count__c)*100;

                metricsData.add(new DashboardUtility.Data(f.getLabel(), DashboardUtility.getDisplayValue(brokerGroupVal, 1, this.precision),
                    string.valueof(f.getType())));
            }
            else{
                metricsData.add(new DashboardUtility.Data(f.getLabel(), 
                    DashboardUtility.getDisplayValue(this.brokerGroupAcct, met, string.valueof(f.getType()), 1, 0),
                    string.valueof(f.getType())));
            }
        }
        return metricsData;
    }

    // # of trip YTD
    private list<DashboardUtility.Data> tripData = null;
    public integer tripMax { 
        get {
            integer max = 0;
            for(DashboardUtility.Data d : getTripData())
                if(d.data1 > max)
                    max = Integer.valueOf(d.data1); 
            return Math.max(5, 5 * Math.floor((max+4) / 5)).intValue();     // calculate the left axis top value
        }
    }
    public list<DashboardUtility.Data> getTripData() {
        if(tripData == null) {
            map<integer, decimal> ytdMap = DashboardUtility.constructEmptyYTDMap();
            
            //query all related this year trip report completed tasks
            for(Task[] tasks : [select ActivityDate from Task where AccountId in :brokerGroupIds and IsClosed=true and ActivityDate=THIS_YEAR and RecordType.DeveloperName=:DashboardUtility.TRIP_REPORT_REC_TYPE])
                for(task t : tasks) {
                    decimal cnt = ytdMap.get(t.ActivityDate.month());
                    ytdMap.put(t.ActivityDate.month(), ++cnt);
                }
                
            tripData = DashboardUtility.convertToDataList(ytdMap);
        }
        system.debug('Trip Data: ' + tripData);
        return tripData;
    }

    
    //
    // # and $ binds and quotes together
    public list<DashboardUtility.Data> getBindsQuotesData() {
        list<DashboardUtility.Data> bqData = new list<DashboardUtility.Data>();
        // work-around - show in thous.
        boolean tmp = this.isBrokerGroup;
        this.isBrokerGroup = false;
        bqData.add(new DashboardUtility.Data('180 - 90', getDisplayValue(this.brokerGroupAcct, 'of_Binds_90_180_Days__c', 'NUMBER'), getDisplayValue(this.brokerGroupAcct, 'Binds_Amount_90_180_Days__c', 'CURRENCY'),
                                    getDisplayValue(this.brokerGroupAcct, 'of_Quotes_90_180_Days__c', 'NUMBER'), getDisplayValue(this.brokerGroupAcct, 'Quotes_Amount_90_180_Days__c', 'CURRENCY')));
        bqData.add(new DashboardUtility.Data('Last 90', getDisplayValue(this.brokerGroupAcct, 'of_Binds_Last_90_Days__c', 'NUMBER'), getDisplayValue(this.brokerGroupAcct, 'Binds_Amount_Last_90_Days__c', 'CURRENCY'),
                                    getDisplayValue(this.brokerGroupAcct, 'of_Quotes_Last_90_Days__c', 'NUMBER'), getDisplayValue(this.brokerGroupAcct, 'Quotes_Amount_Last_90_Days__c', 'CURRENCY')));
        this.isBrokerGroup = tmp;
        return bqData;
    }
    
    
    // written premiums
    public list<DashboardUtility.Data> getWPData() {
        list<DashboardUtility.Data> wpData = new list<DashboardUtility.Data>();
        // work-around - show in thous.
        boolean tmp = this.isBrokerGroup;
        this.isBrokerGroup = false;
        wpData.add(new DashboardUtility.Data('YTD', getDisplayValue(this.brokerGroupAcct, 'New_Business_WP_YTD_EDW__c', 'CURRENCY'),  
                                    getDisplayValue(this.brokerGroupAcct, 'Written_Premium_CYTD_EDW__c', 'CURRENCY') - getDisplayValue(this.brokerGroupAcct, 'New_Business_WP_YTD_EDW__c', 'CURRENCY'),
                                    getDisplayValue(this.brokerGroupAcct, 'WP_Year_End_Target__c', 'CURRENCY')));
        this.isBrokerGroup = tmp;
       
        return wpData;
    }
    
    
    // cytd wp growth rate
    public list<DashboardUtility.Data> getCytdwpData() {
        list<DashboardUtility.Data> cytdwpData = new list<DashboardUtility.Data>();
        if (isBrokerGroup){
            Double brokerGroupVal = (this.brokerGroupAcct.Written_Premium_PYTD_Amt__c==0) ? 0 :
                (this.brokerGroupAcct.Written_Premium_YTD_Amt__c / this.brokerGroupAcct.Written_Premium_PYTD_Amt__c)*100;

            cytdwpData.add(new DashboardUtility.Data('Growth Rate', DashboardUtility.getDisplayValue(brokerGroupVal, 1, this.precision),
                                        getDisplayValue(this.brokerGroupAcct, 'CYTD_WP_Growth_Rate__c', 'PERCENT')));
        }
        else{
            cytdwpData.add(new DashboardUtility.Data('Growth Rate', getDisplayValue(this.brokerGroupAcct, 'CYTD_WP_Growth_Rate_EDW__c', 'PERCENT'),
                                        getDisplayValue(this.brokerGroupAcct, 'CYTD_WP_Growth_Rate__c', 'PERCENT')));
        }
        return cytdwpData;
    }
    
    
    // Properties for inforce premium guage
    private decimal inforceTotal { get { return getDisplayValue(this.brokerGroupAcct, 'Total_Inforce_Premium_EDW__c', 'CURRENCY'); } }      // in Ms for brokerGroup and Ks for broker
    public integer inforceMax { get { return this.isBrokerGroup ? 20 : 1000; } }
    public list<DashboardUtility.Data> getInforceData() {
        list<DashboardUtility.Data> wpData = new list<DashboardUtility.Data>();
        wpData.add(new DashboardUtility.Data('Total', inforceTotal));
        return wpData;
    }
    
    
    //---------------------------------------------------------------------------------------------------------------------
    // test methods
    @isTest
    static void testThisController_Broker() {
        // create dummy account
        Account acct = new Account(Name='test Account', RecordType=new Recordtype(Name=DashboardUtility.BROKER_REC_TYPE.replaceAll('_', ' ')));
        insert acct;
        
        // create dummy tasks
        RecordType taskRT = new RecordType(Name=DashboardUtility.TRIP_REPORT_REC_TYPE.replaceAll('_', ' ')); 
        list<Task> taskList = new list<Task>();
        for(integer i=0; i<50; i++)
            taskList.add(new Task(WhatId=acct.Id, ActivityDate=system.today()-i, Subject='testtask'+i, RecordType=taskRT, Status='Completed'));
        insert taskList;
        
        Test.startTest();
        
        PageReference pageRef = Page.BrokerDashboardPage;
        Test.setCurrentPageReference(pageRef);      
        BrokerDashboardController controller = new BrokerDashboardController(new ApexPages.StandardController(acct));
        PageReference nextPage = controller.init();
        string lab = controller.currencyScaleLabel;
        
        controller.getTripData();
        integer mx = controller.tripMax;
        
        controller.getBindsQuotesData();
        
        controller.getWPData();
        
        controller.getCytdwpData();
        
        controller.getInforceData();
        
        controller.getMetrics1Data();
        controller.getMetrics2Data();
        
        Test.stopTest();
    }
    
    @isTest
    static void testThisController_BrokerGroup() {
        // create dummy accounts
        list<Account> accts = new list<Account>();
        accts.add(new Account(Name='test broker group', RecordType=new Recordtype(Name=DashboardUtility.BROKER_GROUP_REC_TYPE.replaceAll('_', ' '))));
        insert accts[0];
        accts.add(new Account(ParentId=accts[0].Id, Name='test broker 1', RecordType=new Recordtype(Name=DashboardUtility.BROKER_REC_TYPE.replaceAll('_', ' '))));
        accts.add(new Account(ParentId=accts[0].Id, Name='test broker 2', RecordType=new Recordtype(Name=DashboardUtility.BROKER_REC_TYPE.replaceAll('_', ' '))));
        accts.add(new Account(ParentId=accts[0].Id, Name='test broker 3', RecordType=new Recordtype(Name=DashboardUtility.BROKER_REC_TYPE.replaceAll('_', ' '))));
        insert new list<Account> { accts[1], accts[2], accts[3] };
        
        // create dummy tasks
        RecordType taskRT = new RecordType(Name=DashboardUtility.TRIP_REPORT_REC_TYPE.replaceAll('_', ' ')); 
        list<Task> taskList = new list<Task>();
        for(integer i=0; i<100; i++)
            taskList.add(new Task(WhatId=accts[(Math.mod(i,4))].Id, ActivityDate=system.today()-i, Subject='testtask'+i, RecordType=taskRT, Status='Completed'));
        insert taskList;
        
        Test.startTest();
        
        PageReference pageRef = Page.BrokerDashboardPage;
        Test.setCurrentPageReference(pageRef);      
        BrokerDashboardController controller = new BrokerDashboardController(new ApexPages.StandardController(accts[0]));       // parent broker group
        PageReference nextPage = controller.init();
        string lab = controller.currencyScaleLabel2;
        
        controller.getTripData();
        integer mx = controller.tripMax;
        
        controller.getBindsQuotesData();
        
        controller.getWPData();
        
        controller.getCytdwpData();
        
        controller.getInforceData();
        
        controller.getMetrics1Data();
        controller.getMetrics2Data();
        
        Test.stopTest();
    }
}