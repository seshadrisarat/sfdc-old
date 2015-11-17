/*
* @author : not known
* @date : 01/28/2015
* @description: Dashboard controller
*
*
* 
*/

public with sharing class AnnualGoalsDashboardComponentController {

    public Id userId {get;set;}
    public Boolean isManager{get;set;}
    public AnnualGoals__c annualGoals{get;set;}
    public Decimal goalToDate{get;set;}
    
    //tamarack 2-9-15
    public AnnualGoals__c teamAnnualGoal {get; set;} 
    
     
    //President's Club Variables
    public Integer pcQualifiedNewAccountsGoal{get;set;}
    public Integer pcQualifiedNewAccountsWithFMVFMATransGoal{get;set;}
    public Decimal pcFMAVGoal{get;set;}
    public Decimal pcGrossMarginFMVACGMGoal{get;set;}
    public String pcCategory{get;set;}
    public Decimal pcGrossMarginAACGMGoal{get;set;} 
    public Integer pcGrossMarginAACGMGoalK {get {return (Integer)(pcGrossMarginAACGMGoal == null ? 0 : pcGrossMarginAACGMGoal/1000);}}
    public Integer pcFMAVGoalK{get{return (Integer)(pcFMAVGoal == null ? 0 : pcFMAVGoal/1000);}}
    public String pcFMAVType{get;set;}
    public Decimal pcGrossMarginFMVACGM{get;set;}
    public String pcGrossMarginAACGMType{get;set;}
    public String pcGrossMarginFMVAType{get;set;}    
    public Integer pcGrossMarginFMVACGMGoalK{get{return (Integer)(pcGrossMarginFMVACGMGoal == null ? 0 : pcGrossMarginFMVACGMGoal/1000);}}
    public Decimal pcPercentGrossMarginAACGM {get;set;}
    public Decimal pcPercentGrossMarginFMVACGM{get;set;}
    public Decimal pcPercentFMAV{get;set;}
    public Integer pcAwardedApprovedCGMK{get{return (Integer) (annualGoals == null ? 0 : annualGoals.AwardedApprovedCGM__c/1000);}}
    public Integer pcGrossMarginFMVACGMK{get{return (Integer) (pcGrossMarginFMVACGM == null ? 0 : pcGrossMarginFMVACGM/1000);}}
    
    public String pcNewAccountType{get;set;}
    public Decimal pcPercentNewAccount{get;set;}
    
    public String pcNewAccountTransType{get;set;}
    public Decimal pcPercentNewAccountTrans{get;set;}
    
    //Bonus Variables    
    public Decimal bonusLevel {get;set;}
    public String bonusAmount {get;set;}
    public Decimal bonusLevelK{get{return (Integer)(bonusLevel == null ? 0 : bonusLevel/1000);}}
    public Decimal percentBonus{get;set;}
    public String bonusBarType{get;set;}
    public Boolean hideBonus {get;set;}
    
    //Promotion Variables
    public String nextStatus{get;set;}
    public Decimal fundedCGMGoal{get;set;}
    public Integer fundedCGMGoalK{get{return (Integer)(fundedCGMGoal == null ? 0 : fundedCGMGoal/1000);}}
    public Decimal fundedCGM{get;set;}
    public Decimal fundedCGMK{get{return (Integer)(fundedCGM == null ? 0 : fundedCGM/1000);}}
    public Integer fundedCGMBacklogK{get{return (Integer)(annualGoals == null ? 0 : annualGoals.FundedCGMBacklog__c/1000);}}
    public Decimal percentFundedCGM{get;set;}
    public Decimal percentFundedCGMBacklog{get;set;}
    public String promotionToDateLabel{get;set;}
    public Boolean hidePromotions {get;set;}
    
    //Component attribute
    public Boolean isOnPrintPage {get;set;}

    //01-26-2015 tamarack https://trello.com/c/EcOxN9Wv/9-add-a-year-selector-to-the-individual-and-team-dashboard
    public String selectedYear {get {
            if (String.isEmpty(selectedYear))
                selectedYear = String.valueOf(Date.today().year());
                
            return selectedYear;
        } 
        set;
    }

    //tamarack add dashboard visibility permissions
    public TC_AnnualGoalsDashboardPermUtil permUtil {
        get {
            return TC_AnnualGoalsDashboardPermUtil.getInstance();
        } 
        private set;}

    public List <SelectOption> goalYears {
        get {
            List <SelectOption> goalYearList = new List <SelectOption> ();
            
            Set <String> yearSet = new Set <String> ();

            AggregateResult [] agGoalYears = [SELECT year__c FROM AnnualGoals__c WHERE User__c != null GROUP BY Year__c ORDER BY Year__c DESC];

            for (AggregateResult ar: agGoalYears) {
                yearSet.add(String.valueOf(ar.get('Year__c')));
            }
            //requirement to always have current year in picklist
            yearSet.add(String.valueOf(Date.today().year()));

            List <String> yearList = new List <String> ();
            yearList.addAll(yearSet);
            yearList.sort();

            for(Integer i = yearList.size()-1; i>=0; i--) {//DESC sort
                goalYearList.add(new SelectOption (yearList.get(i), yearList.get(i)));
            }

            return goalYearList;
        }
        private set;
    }

    public static final String NO_ANNUAL_GOALS_FOUND = 'No annual goals found.';

    
    //end tamarack

    public AnnualGoalsDashboardComponentController(string goalId) {                        
        isManager = getIsManager();
        
        if(!String.isEmpty(goalId)){
            loadGoals(goalId);
        }
    }
    
    public AnnualGoalsDashboardComponentController(){
       
        
        String goalId = ApexPages.currentpage().getparameters().get('id');
        userId = ApexPages.currentPage().getParameters().get('userId');
        selectedYear = ApexPages.currentPage().getParameters().get('year');
        
        List <User> users = getUsers();
                
        isManager = getIsManager();
        
        if(!String.isEmpty(goalId)){
            loadGoals(goalId);
        } else {
                
       
            userId = isManager && users.size() > 0 && String.isEmpty(userId) ? users[0].Id : userId;
            userId = String.isEmpty(userId) ? UserInfo.getUserId() : userId;
        
            if(userId != null) {
                loadGoals();  
            }
        }

        if (annualGoals == null) {
            ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.WARNING, NO_ANNUAL_GOALS_FOUND));
        }         
    }
    
    private Boolean getIsManager () {
        return [SELECT AnnualGoalsManagerView__c FROM User WHERE Id =: UserInfo.getUserId()][0].AnnualGoalsManagerView__c;
    }
    
    private void loadGoals(string goalId){
        List<AnnualGoals__c> goals = [SELECT Sales_Team__c
                                            ,Year__c
                                            ,VirtualMeetings__c
                                            ,VirtualMeetingsGoal__c
                                            ,User__c
                                            ,User__r.FundedCGMCareerToDate__c
                                            ,User__r.Date_of_Hire__c
                                            ,User__r.Date_of_Hire_into_Sales__c
                                            ,User__r.CurrentTitle__c
                                            ,User__r.Name
                                            ,QualifiedNewAccounts__c
                                            ,Prospects_Closing_Rate__c
                                            ,ProspectsClosingRateGoal__c
                                            ,Proposals__c
                                            ,ProposalsGoal__c
                                            ,OfficeMeetings__c
                                            ,OfficeMeetingsGoal__c
                                            ,X7_Figure_Deals__c
                                            ,X7_Figure_Deals_Goal__c
                                            ,NewAccounts__c
                                            ,NewAccountsGoal__c
                                            ,NewAccountsFMVFMATransactions__c
                                            ,NewAccountsFMVFMATransactionsGoal__c
                                            ,Name
                                            ,Leads__c
                                            ,LeadsGoal__c
                                            ,Lead_Conversion_Rate__c
                                            ,LeadConversionRateGoal__c
                                            ,LastModifiedDate
                                            ,Id
                                            ,FundedCGM__c
                                            ,FundedCGMBacklog__c
                                            ,FMVGrossMargin__c
                                            ,FMVGrossMarginGoal__c
                                            ,FMAGrossMargin__c
                                            ,FMAGrossMarginGoal__c
                                            ,Current_Customers_Closing_Rate__c
                                            ,CurrentCustomersClosingRateGoal__c
                                            ,CSCGrossMargin__c
                                            ,CSCGrossMarginGoal__c
                                            ,AwardedApprovedCGM__c
                                            ,AwardedApprovedCGMGoal__c
                                            ,Avg_Proposal_Size__c
                                            ,AvgProposalSizeGoal__c
                                            ,All_Proposals_Closing_Rate__c
                                            ,AllProposalsClosingRateGoal__c
                                            ,AACGMNewCustomers__c
                                            ,AACGMNewCustomersGoal__c 
                                            ,CompositeCallScoreGoals__c
                                            ,CompositeCallScoreYTD__c
                                            ,PC_Category__c 
                                            ,PC_GrossMarginCGMGoal__c
                                            ,PC_GrossMarginFMAFMVCGMGoal__c
                                            ,PC_FMVFMACGMGoal__c
                                            ,PC_NewAccountsGoal__c
                                            ,PC_NewAccountsFMVFMATransactionsGoal__c
                            FROM AnnualGoals__c  WHERE Id =: goalId]; 
                            
        if(goals != null && goals.size() > 0) {
            annualGoals = goals[0]; 
        }
        
        if(!isManager && annualGoals.User__c != UserInfo.getUserId()) {
            annualGoals = null;
        }   
            
        if(annualGoals != null){
            setDashboardData();
        }
    }
    
    //tamarack 01-26-15 update to pull selected year goals.
    private void loadGoals() {

        //reset previous goals 
        annualGoals = null;

        //get new goals
        List<AnnualGoals__c> goals = [SELECT Sales_Team__c
                                            ,Year__c, VirtualMeetings__c
                                            ,VirtualMeetingsGoal__c
                                            ,User__c
                                            ,User__r.FundedCGMCareerToDate__c
                                            ,User__r.Date_of_Hire__c
                                            ,User__r.Date_of_Hire_into_Sales__c
                                            ,User__r.CurrentTitle__c
                                            ,User__r.Name
                                            ,QualifiedNewAccounts__c
                                            ,Prospects_Closing_Rate__c
                                            ,ProspectsClosingRateGoal__c
                                            ,Proposals__c
                                            ,ProposalsGoal__c
                                            ,OfficeMeetings__c
                                            ,OfficeMeetingsGoal__c
                                            ,X7_Figure_Deals__c
                                            ,X7_Figure_Deals_Goal__c
                                            ,NewAccounts__c
                                            ,NewAccountsGoal__c
                                            ,NewAccountsFMVFMATransactions__c
                                            ,NewAccountsFMVFMATransactionsGoal__c
                                            ,Name
                                            ,Leads__c
                                            ,LeadsGoal__c
                                            ,Lead_Conversion_Rate__c
                                            ,LeadConversionRateGoal__c
                                            ,LastModifiedDate
                                            ,Id
                                            ,FundedCGM__c
                                            ,FundedCGMBacklog__c
                                            ,FMVGrossMargin__c
                                            ,FMVGrossMarginGoal__c
                                            ,FMAGrossMargin__c
                                            ,FMAGrossMarginGoal__c
                                            ,Current_Customers_Closing_Rate__c
                                            ,CurrentCustomersClosingRateGoal__c
                                            ,CSCGrossMargin__c
                                            ,CSCGrossMarginGoal__c
                                            ,AwardedApprovedCGM__c
                                            ,AwardedApprovedCGMGoal__c
                                            ,Avg_Proposal_Size__c
                                            ,AvgProposalSizeGoal__c
                                            ,All_Proposals_Closing_Rate__c
                                            ,AllProposalsClosingRateGoal__c
                                            ,AACGMNewCustomers__c
                                            ,AACGMNewCustomersGoal__c 
                                            ,CompositeCallScoreGoals__c
                                            ,CompositeCallScoreYTD__c
                                            ,PC_Category__c
                                            ,PC_GrossMarginCGMGoal__c
                                            ,PC_GrossMarginFMAFMVCGMGoal__c
                                            ,PC_FMVFMACGMGoal__c
                                            ,PC_NewAccountsGoal__c
                                            ,PC_NewAccountsFMVFMATransactionsGoal__c

                                    FROM AnnualGoals__c  
                                    WHERE User__c =: userId 
                                    AND Year__c =: selectedYear ];
        
        system.debug('========userId=============' + userId);
        system.debug('========selectedYear=============' + selectedYear);
        system.debug('========goals=============' + goals);
        
    
        if(goals != null && goals.size() > 0){
            annualGoals = goals[0]; 
        }
                        
        if(annualGoals != null){
            setDashboardData();
        }
    }
    
    private void setDashboardData() {
        
        bonusLevel = 0;
        
        hideBonus = false;
        if(annualGoals.AwardedApprovedCGMGoal__c >= 500000 && annualGoals.AwardedApprovedCGMGoal__c < 750000) {
            bonusLevel = 500000;
            bonusAmount = '$25,000';
        } else if(annualGoals.AwardedApprovedCGMGoal__c >= 750000 && annualGoals.AwardedApprovedCGMGoal__c < 1000000) {
            bonusLevel = 750000;
            bonusAmount = '$50,000';
        } else if(annualGoals.AwardedApprovedCGMGoal__c >= 1000000 && annualGoals.AwardedApprovedCGMGoal__c < 1250000) {
            bonusLevel = 1000000;
            bonusAmount = '$100,000';
        } else if(annualGoals.AwardedApprovedCGMGoal__c >= 1250000){
            bonusLevel = 1250000;
            bonusAmount = '$150,000';
        } else {
            hideBonus = true;
        }
        
        percentBonus = 0;
        
        if(bonusLevel != null && bonusLevel > 0) {
            percentBonus = Math.ceil(annualGoals.AwardedApprovedCGM__c * 100 / bonusLevel);
        }
        
        if(percentBonus >= 100)
        {
            percentBonus = 100;
            bonusBarType = 'success';
        }
        else if(percentBonus >= 50)
        {            
            bonusBarType = 'warning';
        }
        else
        {
            bonusBarType = 'danger';
        }
        
        promotionToDateLabel = 'YTD';
        
        if(annualGoals.FundedCGM__c == null)
        {
            annualGoals.FundedCGM__c = 0;
        }
        
        //debug += 'User Title: ' + annualGoals.User__r.CurrentTitle__c + '<br/>';
        //debug += 'User Career to date: ' + annualGoals.User__r.FundedCGMCareerToDate__c + '<br/>';
        
        hidePromotions = false;
        
        if(annualGoals.User__r.CurrentTitle__c == 'AVP1')
        {
            //debug += 'Next Title: AVP2<br/>';
            nextStatus = 'AVP2';
            fundedCGMGoal = 100000;
            fundedCGM = annualGoals.User__r.FundedCGMCareerToDate__c == null ? 0 : annualGoals.User__r.FundedCGMCareerToDate__c;
            promotionToDateLabel = 'CTD';
        }
        else if(annualGoals.User__r.CurrentTitle__c == 'AVP2')
        {
            //debug += 'Next Title: AVP3<br/>';
            nextStatus = 'AVP3';
            fundedCGMGoal = 250000;
            fundedCGM = annualGoals.FundedCGM__c;
        }
        else if(annualGoals.User__r.CurrentTitle__c == 'AVP3')
        {
            //debug += 'Next Title: AVP4<br/>';
            nextStatus = 'VP1';
            fundedCGMGoal = 500000;
            fundedCGM = annualGoals.FundedCGM__c;
        }
        else if(annualGoals.User__r.CurrentTitle__c == 'VP1')
        {
            //debug += 'Hide Promotions<br/>';
            fundedCGMGoal = 0;
            fundedCGM = 0;
            hidePromotions = true;
        }
        else
        {
            //debug += 'Hide Promotions<br/>';
            fundedCGMGoal = 0;
            fundedCGM = 0;
            hidePromotions = true;
        }
        
        if(annualGoals.FundedCGMBacklog__c == null)
        {
            annualGoals.FundedCGMBacklog__c = 0;
        }
        
        if(fundedCGMGoal != 0)
        {
            //Need to account for 25% over goal
            percentFundedCGM = Math.ceil(fundedCGM * 75 / fundedCGMGoal);
            
            if(percentFundedCGM < 100)
            {
                if(annualGoals.FundedCGMBacklog__c != null)
                {
                    percentFundedCGMBacklog = Math.ceil(annualGoals.FundedCGMBacklog__c * 75 / fundedCGMGoal);
                    
                    if((percentFundedCGMBacklog + percentFundedCGM) > 100)
                    {
                        percentFundedCGMBacklog = 100 - percentFundedCGM;
                    }
                }
                
            }
            else if(percentFundedCGM > 100)
            {
                percentFundedCGM = 100;
            }
        }
        
        setGrossMarginData();
        
        Integer currentWeek = (Integer) Math.floor(Date.newInstance(2012,1,1).daysBetween(Date.Today())/7);
        goalToDate = annualGoals.AwardedApprovedCGMGoal__c == null ? 0 : annualGoals.AwardedApprovedCGMGoal__c * (Math.mod(currentWeek, 52) + 1) /52;


        //tamarack 2-9-15
        loadTeamAnnualGoal();
    }

     //tamarack 2-9-15
    private void loadTeamAnnualGoal () {
        if (annualGoals != null) {
            //get team annual goal for individual
            String goalName = annualGoals.Year__c + ' - ' + annualGoals.Sales_Team__c;
            String teamAnnualGoalQueryString = TC_DataUtility.createSelectAllString('AnnualGoals__c', 'Name = \'' + String.escapeSingleQuotes(goalName) + '\'', '1', null, null);

            try {
                teamAnnualGoal = TC_DataUtility.getTeamAnnualGoal(teamAnnualGoalQueryString);
            } catch (Exception e) {
                System.debug(e);
                ApexPages.addMessages(e);
            }

        } else {
            teamAnnualGoal = new AnnualGoals__c ();
        }
    }
    

    //added the "Exclude_Dashboard__c" field for filtering out non-sales reps
    private List<User> getUsers() {
        return [SELECT Id
                       ,Sales_Team__c
                       ,Name 
                FROM User 
                WHERE IsActive = true 
                    AND Exclude_Dashboard__c != 'TRUE' 
                    AND Profile.Name != 'Sales - RVP' 
                    AND Profile.Name != 'Sales - RVP - Vendor' 
                    AND Profile.Name LIKE 'Sales%'
                ORDER BY Name];
    }
    
    public List<SelectOption> getUserOptions() {
        List<User> users = null;
        List<SelectOption> options = new List<SelectOption>();
        
        users = getUsers();
            
        for(User u :users) {           
            options.add(new SelectOption(u.Id,u.Name));         
        }
        
        return options;
    } 
    
    public PageReference rerenderDashboard()
    {
        //debug = '';
        loadGoals();
        if (annualGoals == null) 
            ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.WARNING, NO_ANNUAL_GOALS_FOUND));

        return null;
    }
    

    //tamarack 02-24-15
    //https://trello.com/c/0Ol27zir/7-add-a-president-s-club-dashboard
    //updated PC goals to be taken from the new object
    private void setGrossMarginData() {
        //debug += 'Setting Gross Margin<br/>';

        pcCategory = annualGoals.PC_Category__c;         
        pcGrossMarginAACGMGoal = annualGoals.PC_GrossMarginCGMGoal__c;
        pcGrossMarginFMVACGMGoal = annualGoals.PC_GrossMarginFMAFMVCGMGoal__c;   
        pcFMAVGoal = annualGoals.PC_FMVFMACGMGoal__c;
        pcQualifiedNewAccountsGoal = Integer.valueOf(annualGoals.PC_NewAccountsGoal__c);
        pcQualifiedNewAccountsWithFMVFMATransGoal = Integer.valueOf(annualGoals.PC_NewAccountsFMVFMATransactionsGoal__c);
        
        ////Leader
        //if(annualGoals.User__r.Date_of_Hire_into_Sales__c <=  date.newInstance(Date.today().year() - 6, 12, 31))
        //{
        //    this.pcCategory = 'Leader';         
        //    this.pcGrossMarginAACGMGoal = 400000;
        //    this.pcGrossMarginFMVACGMGoal = 160000;   
        //    this.pcFMAVGoal = 275000;
        //    this.pcQualifiedNewAccountsGoal = 6;
        //    this.pcQualifiedNewAccountsWithFMVFMATransGoal = 4;
        //}
        //else if(annualGoals.User__r.Date_of_Hire_into_Sales__c <=  date.newInstance(Date.today().year() - 4, 12, 31) && annualGoals.User__r.Date_of_Hire_into_Sales__c >=  date.newInstance(Date.today().year() - 5, 1, 1))
        //{
        //    this.pcCategory = 'Veteran';            
        //    this.pcGrossMarginAACGMGoal = 325000;
        //    this.pcGrossMarginFMVACGMGoal = 130000;   
        //    this.pcFMAVGoal = 225000;
        //    this.pcQualifiedNewAccountsGoal = 6;
        //    this.pcQualifiedNewAccountsWithFMVFMATransGoal = 4;
        //}
        //else
        //{
        //    if(annualGoals.User__r.Date_of_Hire_into_Sales__c <=  date.newInstance(Date.today().year() - 1, 6, 30) && annualGoals.User__r.Date_of_Hire_into_Sales__c >=  date.newInstance(Date.today().year() - 3, 1, 1))
        //    {
        //        this.pcCategory = 'Tenured';
        //    }
        //    else
        //    {
        //        this.pcCategory = 'Rookie';
        //    }
                        
        //    this.pcGrossMarginAACGMGoal = 180000;
        //    this.pcGrossMarginFMVACGMGoal = 72000;   
        //    this.pcFMAVGoal = 130000;
        //    this.pcQualifiedNewAccountsGoal = 5;
        //    this.pcQualifiedNewAccountsWithFMVFMATransGoal = 3;
        //}
        
        pcGrossMarginFMVACGM = annualGoals.FMAGrossMargin__c + annualGoals.FMVGrossMargin__c;
        pcPercentGrossMarginAACGM = pcGrossMarginAACGMGoal > 0 ? Math.ceil(annualGoals.AwardedApprovedCGM__c * 100 / pcGrossMarginAACGMGoal) : 0;
        pcPercentGrossMarginFMVACGM = pcGrossMarginFMVACGMGoal > 0 ? Math.ceil(pcGrossMarginFMVACGM * 100 / pcGrossMarginFMVACGMGoal) : 0;
        pcPercentFMAV = pcFMAVGoal > 0 ? Math.ceil(pcGrossMarginFMVACGM * 100 / pcFMAVGoal) : 0;
        
        if(pcPercentGrossMarginAACGM >= 100){
            pcPercentGrossMarginAACGM = 100;
            pcGrossMarginAACGMType = 'success';
        } else if(pcPercentGrossMarginAACGM >= 50) {            
            pcGrossMarginAACGMType = 'warning';
        } else {
            pcGrossMarginAACGMType = 'danger';
        }
        
        if(pcPercentGrossMarginFMVACGM > 100) {
            pcPercentGrossMarginFMVACGM = 100;
            pcGrossMarginFMVAType = 'success';
        } else if(pcPercentGrossMarginFMVACGM >= 50) {            
            pcGrossMarginFMVAType = 'warning';
        } else {
            pcGrossMarginFMVAType = 'danger';
        }
        
        if(pcPercentFMAV >= 100) {
            pcPercentFMAV = 100;
            pcFMAVType = 'success';
        } else if(pcPercentFMAV >= 50) {            
           pcFMAVType = 'warning';
        } else {
            pcFMAVType = 'danger';
        }
        
    
        pcPercentNewAccount = 0;
        if(annualGoals.QualifiedNewAccounts__c == null) {
            annualGoals.QualifiedNewAccounts__c = 0;
        }
       
        if(pcQualifiedNewAccountsGoal != 0) {
            pcPercentNewAccount = Math.ceil(annualGoals.QualifiedNewAccounts__c * 100 / pcQualifiedNewAccountsGoal);
        }
        
        if(pcPercentNewAccount >= 100) {
            pcPercentNewAccount = 100;
            pcNewAccountType = 'success';
        } else if(pcPercentNewAccount >= 50) {            
           pcNewAccountType = 'warning';
        } else {
            pcNewAccountType = 'danger';
        }
        
        pcPercentNewAccountTrans = 0;
        
        if(annualGoals.NewAccountsFMVFMATransactions__c == null) {
            annualGoals.NewAccountsFMVFMATransactions__c = 0;
        }
        
        if(pcQualifiedNewAccountsWithFMVFMATransGoal != 0) {
            pcPercentNewAccountTrans = Math.ceil(annualGoals.NewAccountsFMVFMATransactions__c * 100 / pcQualifiedNewAccountsWithFMVFMATransGoal);
        }
        
        if(pcPercentNewAccountTrans >= 100) {
            pcPercentNewAccountTrans = 100;
            pcNewAccountTransType = 'success';
        }
        else if(pcPercentNewAccountTrans >= 50) {            
           pcNewAccountTransType = 'warning';
        } else {
            pcNewAccountTransType = 'danger';
        }  
    }
        
    public List<ChartData> getData()
    {
        List<ChartData> dt = new List<ChartData>();
        Decimal diff = null;
        
        if(annualGoals != null)
        {
            diff = annualGoals.AwardedApprovedCGMGoal__c - goalTodate;
            dt.add(new ChartData('YTD', 0, 0, annualGoals.FMVGrossMargin__c, annualGoals.FMAGrossMargin__c, annualGoals.CSCGrossMargin__c));
            dt.add(new ChartData('Goal', diff > 0 ? goalToDate : 0,diff > 0 ? diff : annualGoals.AwardedApprovedCGMGoal__c, 0.00, 0.00, 0.00));
        }
        
        return dt;
    }
    
    public class ChartData
    {
        public String name {get;set;}
        public Decimal quarterGoal {get;set;}
        public Decimal goal {get;set;}
        public Decimal cscAmount {get;set;}
        public Decimal fmvAmount {get;set;}
        public Decimal fmaAmount {get;set;}
        
        public ChartData(string name, decimal quarterGoal, decimal goal, decimal fmv, decimal fma, decimal csc)
        {
            this.name = name;
            this.quarterGoal = quarterGoal;
            this.goal = goal;  
            this.cscAmount = csc;
            this.fmvAmount = fmv;
            this.fmaAmount = fma; 
        }
    }
}