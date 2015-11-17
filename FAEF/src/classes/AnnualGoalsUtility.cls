public with sharing class AnnualGoalsUtility {
    static Set<String> aacgm1Stages = new Set<String>{'Booked', 'Booked with Follow ups', 'Pending Equipment Delivery', 'Progress Payments', 'Ready to Document', 'Documents Out', 'Documents Received', 'Due to Fund'};
    static Set<String> aacgm2Stages = new Set<String>{'Application Incomplete', 'Leaseline Balance - Not Submitted to Credit', 'Operations Review In Process', 'Credit Review in Process', 
                                                    'More Information Requested By Credit', 'Approved Balance'};
    static Set<String> aacgm3Stages = new Set<String>{'Booked','Booked with Follow ups','Pending Equipment Delivery', 'Progress Payments', 'Ready to Document', 'Documents Out', 'Documents Received', 'Due to Fund'};
        
    static Set<String> newAccountStages1 = new Set<String>{'Booked','Booked with Follow ups','Pending Equipment Delivery', 'Progress Payments', 'Ready to Document',  'Documents Out', 'Documents Received', 'Due to Fund'};
    static Set<String> newAccountStages2 = new Set<String>{'Application Incomplete', 'Leaseline Balance – Not Submitted to Credit', 'Operations Review in Process', 'Credit Review in Process','More Information Requested By Credit','Approved Balance'};
    
    //tamarack add PC Goals list 
    private static final List <Presidents_Club_Goal__c> pcGoals = new List <Presidents_Club_Goal__c> ([SELECT Id, Name FROM Presidents_Club_Goal__c LIMIT 1000]);

    //tamarack overload method to create ability to rerun stats for other years
    public static void updateAnnualGoals (List<ID> userIds) {
        updateAnnualGoals (userIds, Date.today().year());
    }


    public static void updateAnnualGoals(List<ID> userIds, Integer year) {
        Integer currentYear = year;
        List<AnnualGoals__c> goals = null;
        Map<ID, AnnualGoals__c> userGoalMap = new Map<ID, AnnualGoals__c>();
        AggregateResult[] newAccounts = null;
        Map<ID, Integer> userNewAccountsMap = new Map<ID, Integer>();
        AggregateResult[] prospectClosedOppNumerators = null;
        Map<ID, Decimal> userProspectClosedOppNumeratorMap = new Map<ID, Decimal>();
        AggregateResult[] prospectClosedOppDenominators = null;
        Map<ID, Decimal> userProspectClosedOppDenominatorMap = new Map<ID, Decimal>();
        AggregateResult[] currentClosedOppNumerators = null;
        Map<ID, Decimal> userCurrentClosedOppNumeratorMap = new Map<ID, Decimal>();
        AggregateResult[] currentClosedOppDenominators = null;
        Map<ID, Decimal> userCurrentClosedOppDenominatorMap = new Map<ID, Decimal>();
        //List<Schedule__c> allSchedules = null;
        //Map<ID, List<Schedule__c>> userSchedulesMap = new Map<ID, List<Schedule__c>>();
        AggregateResult[] allVirtualMeetings = null;
        Map<ID, Integer> userVirtualMeetingsMap = new  Map<ID, Integer>();
        AggregateResult[] allOfficeMeetings = null;
        Map<ID, Integer> userOfficeMeetingsMap = new  Map<ID, Integer>();
        AggregateResult[] allSevenFigureDeals = null;
        Map<ID, Integer> userSevenFigureDealsMap = new Map<ID, Integer>();
           
        Map<Id, Account> newAccountMap = null;
        createGoals(userIds, currentYear);
        
        goals = [SELECT Year__c, User__c, PC_Year_and_Category__c, User__r.Sales_Team__c, Display_Team__c FROM AnnualGoals__c WHERE Year__c = :String.valueOf(currentYear) AND User__c in :userIds];

        //tamarack 02-22-15
        //get a map of PC_Goals 
        Map <String, Id> pcGoalNameMap = new Map <String, Id> ();
        for (Presidents_Club_Goal__c pcg: pcGoals) {
            pcGoalNameMap.put(pcg.Name, pcg.Id);
        }
        //System.debug(LoggingLevel.INFO,'+++++ pcGoalNameMap +++++' + pcGoalNameMap);
        //end PC Goals
                                        
        if(goals != null)
        {
            for(AnnualGoals__c ag :goals)
            {
                userGoalMap.put(ag.User__c, ag);
            }
            
            //13
            prospectClosedOppNumerators = [SELECT OwnerId, SUM(Amount) FROM Opportunity 
                                            WHERE IsClosed = True AND New_Account__c = 'YES' AND CloseDate != null AND CALENDAR_YEAR(CloseDate) = :currentYear
                                                    AND Proposal_Date__c != null AND StageName in ('Awarded','Approved','Declined')
                                                    AND OwnerId in :userGoalMap.keySet() 
                                            GROUP BY OwnerId];
                                                
            prospectClosedOppDenominators = [SELECT OwnerId, SUM(Amount) FROM Opportunity 
                                            WHERE IsClosed = True AND New_Account__c = 'YES' AND CloseDate != null AND CALENDAR_YEAR(CloseDate) = :currentYear
                                                    AND Proposal_Date__c != null AND StageName in ('Awarded','Approved','Declined','Lost')
                                                    AND OwnerId in :userGoalMap.keySet()
                                            GROUP BY OwnerId];
                                                
            if(prospectClosedOppNumerators != null)
            {
                for(AggregateResult ar :prospectClosedOppNumerators)
                {
                    userProspectClosedOppNumeratorMap.put((ID)ar.get('OwnerId'), (Decimal)ar.get('expr0'));
                }
            }
            
            if(prospectClosedOppDenominators != null)
            {
                for(AggregateResult ar :prospectClosedOppDenominators)
                {
                    userProspectClosedOppDenominatorMap.put((ID)ar.get('OwnerId'), (Decimal)ar.get('expr0'));
                }
            }
            
            //14
            currentClosedOppNumerators = [SELECT OwnerId, SUM(Amount) FROM Opportunity 
                                            WHERE IsClosed = True AND New_Account__c = 'NO' AND CloseDate != null AND CALENDAR_YEAR(CloseDate) = :currentYear
                                                    AND Proposal_Date__c != null AND StageName in ('Awarded','Approved','Declined')
                                                    AND OwnerId in :userGoalMap.keySet() 
                                            GROUP BY OwnerId];
                                                
            currentClosedOppDenominators = [SELECT OwnerId, SUM(Amount) FROM Opportunity 
                                            WHERE IsClosed = True AND New_Account__c = 'NO' AND CloseDate != null AND CALENDAR_YEAR(CloseDate) = :currentYear
                                                    AND Proposal_Date__c != null AND StageName in ('Awarded','Approved','Declined','Lost')
                                                    AND OwnerId in :userGoalMap.keySet()
                                            GROUP BY OwnerId];
                                                
            if(currentClosedOppNumerators != null)
            {
                for(AggregateResult ar :currentClosedOppNumerators)
                {
                    userCurrentClosedOppNumeratorMap.put((ID)ar.get('OwnerId'), (Decimal)ar.get('expr0'));
                }
            }
            
            if(currentClosedOppDenominators != null)
            {
                for(AggregateResult ar :currentClosedOppDenominators)
                {
                    userCurrentClosedOppDenominatorMap.put((ID)ar.get('OwnerId'), (Decimal)ar.get('expr0'));
                }
            }
            
            
            //19
            newAccountMap = new Map<Id, Account>([SELECT Id, Name FROM Account 
                                                    WHERE ID in (SELECT Account_Lookup__c 
                                                    FROM Schedule__c 
                                                    WHERE Schedule_Number__c like '%01' 
                                                        AND (CALENDAR_YEAR(Orignal_LOI_Award_Date__c) = :currentYear OR CALENDAR_YEAR(Award_Date_Override__c) = :currentYear 
                                                        OR CALENDAR_YEAR(Additional_A_A_Award_Date__c) = :currentYear) 
                                                        AND Letter_of_Intent__r.Opportunity__r.OwnerId in :userGoalMap.keySet() 
                                                        AND (Stage__c in :newAccountStages1 OR (Stage__c in :newAccountStages2 AND Count_for_A_A__c in ('Yes','Partial')))) 
                                                ]);
                
            //19        
            newAccounts = [SELECT Letter_of_Intent__r.Opportunity__r.OwnerId UserId, Count(ID) Accounts
                           FROM Schedule__c 
                           WHERE Schedule_Number__c like '%01' 
                                    AND (CALENDAR_YEAR(Orignal_LOI_Award_Date__c) = :currentYear OR CALENDAR_YEAR(Award_Date_Override__c) = :currentYear 
                                    OR CALENDAR_YEAR(Additional_A_A_Award_Date__c) = :currentYear) 
                                    AND Letter_of_Intent__r.Opportunity__r.OwnerId in :userGoalMap.keySet() 
                                    AND (Stage__c in :newAccountStages1 OR (Stage__c in :newAccountStages2 AND Count_for_A_A__c in ('Yes','Partial'))) 
                           Group by Letter_of_Intent__r.Opportunity__r.OwnerId];
          
            
            if(newAccounts != null)
            {
                for(AggregateResult ar :newAccounts)
                {
                    userNewAccountsMap.put((ID)ar.get('UserId'), (Integer)ar.get('Accounts'));
                }
            }
                                    
            //Virtual Meetings
            allVirtualMeetings = [SELECT OwnerId, COUNT(ID) FROM Event 
                                    WHERE OwnerId in :userGoalMap.keySet() AND ActivityDate = THIS_YEAR AND RecordType.Name = 'Virtual Meeting' 
                                        AND Result__c = 'Virtual Meeting - Success' AND ActivityDate < TODAY
                                    GROUP BY OwnerId];
            
            if(allVirtualMeetings != null)
            {
                for(AggregateResult ar : allVirtualMeetings)
                {
                    userVirtualMeetingsMap.put((ID)ar.get('OwnerId'), (Integer)ar.get('expr0'));
                }
            }
            
            //Office Meetings
            allOfficeMeetings = [SELECT OwnerId, COUNT(ID) FROM Event 
                                    WHERE OwnerId in :userGoalMap.keySet() AND ActivityDate = THIS_YEAR AND RecordType.Name = 'Event' 
                                        AND Type = 'In-Person Meeting' AND ActivityDate < TODAY
                                    GROUP BY OwnerId];
            
            if(allOfficeMeetings != null)
            {
                for(AggregateResult ar : allOfficeMeetings)
                {
                    userOfficeMeetingsMap.put((ID)ar.get('OwnerId'), (Integer)ar.get('expr0'));
                }
            }
            //7 Figure Deals
            allSevenFigureDeals = [Select OwnerId, COUNT(ID) FROM Opportunity
                                  	WHERE OwnerId in :userGoalMap.keySet() AND Amount > 999999.99 AND (CloseDate != null AND CALENDAR_YEAR(CloseDate) = :currentYear)
                                  		AND StageName != 'Pre-Opportunity' AND StageName != 'Pre-Opportunity Terminated'
                                  	GROUP BY OwnerId];
            
            if(allSevenFigureDeals != null)
            {
                for(AggregateResult ar : allSevenFigureDeals)
                {
                    userSevenFigureDealsMap.put((ID)ar.get('OwnerId'), (Integer)ar.get('expr0'));
                }
            }
            //Update goals
            for(AnnualGoals__c ag :goals)
            {
                //tamarack 03-10-15 update Display_Team__c 
                ag.Display_Team__c = ag.Display_Team__c == null ? ag.User__r.Sales_Team__c : ag.Display_Team__c;

                List<Opportunity> opps = [SELECT ID, Name, OwnerId, Prospect_as_of_Qualified_Opp_Creation__c, Report_Created_Date__c, Proposal_Date__c, Amount, IsClosed, StageName, CloseDate, AccountId
                                            FROM Opportunity 
                                            WHERE ((CloseDate != null AND CALENDAR_YEAR(CloseDate) = :currentYear) 
                                                    OR (Report_Created_Date__c != null AND CALENDAR_YEAR(Report_Created_Date__c) = :currentYear) 
                                                    OR (Proposal_Date__c != null AND CALENDAR_YEAR(Proposal_Date__c) = :currentYear)) 
                                                    AND OwnerId =: ag.User__c];
                //userOppsMap.containsKey(ag.User__c) ? userOppsMap.get(ag.User__c) : new List<Opportunity>();
                List<Schedule__c> schedules = [SELECT ID, Name, Financial_Product__c, Stage__c, Orignal_LOI_Award_Date__c, Actual_GM_Dollars__c, GM_Percent__c, Count_for_A_A__c, 
                                                Partial_A_A_Revenue__c, Account_Lookup__c, Award_Date_Override__c, Alternative_CGM__c, Total_Equipment_Cost__c, Additional_A_A_Revenue__c, 
                                                Additional_A_A_Award_Date__c, Count_Additional_for_A_A__c, Letter_of_Intent__r.Opportunity__r.OwnerId, Anticipated_Fund_Date__c,
                                                Letter_of_Intent__r.Opportunity__r.Prospect_as_of_Qualified_Opp_Creation__c, Letter_of_Intent__r.Opportunity__r.StageName
                                                FROM Schedule__c 
                                                WHERE (CALENDAR_YEAR(Orignal_LOI_Award_Date__c) = :currentYear OR CALENDAR_YEAR(Award_Date_Override__c) = :currentYear 
                                                        OR CALENDAR_YEAR(Additional_A_A_Award_Date__c) = :currentYear OR CALENDAR_YEAR(Anticipated_Fund_Date__c) = :currentYear) 
                                                        AND Letter_of_Intent__r.Opportunity__r.OwnerId = :ag.User__c];
                //userSchedulesMap.containsKey(ag.User__c) ? userSchedulesMap.get(ag.User__c) : new List<Schedule__c>();
                Double leads = 0;
                Double proposals = 0;
                Double sameYearProposals = 0;
                Decimal proposalSize = 0;
                Double closedWonProposal = 0;
                Double closedLostProposal = 0;
                Double closedWonCurrent = 0;
                Double closedLostCurrent = 0;
                Double closedWonNew = 0;
                Double closedLostNew = 0;
                Double closedWonLead = 0;
                Double closedLostLead = 0;
                Decimal fmv = 0;
                Decimal fma = 0;
                Decimal csc = 0;
                Decimal newAccountAACGM = 0;
                Integer fmvFmaTransactions = 0;
                Integer qualifiedNewAccounts = 0;
                Decimal fundedCGMBacklog = 0;
                Decimal fundedCGM = 0;
                Map<ID,Decimal> qualifiedNewAccountAacgmMap = new Map<ID, Decimal>();
                Set<ID> newAccountFmvFmaSet = new Set<ID>();
                Decimal prospectClosedOppNumerator = 0;
                Decimal prospectClosedOppDenominator = 0;
                Decimal currentClosedOppNumerator = 0;
                Decimal currentClosedOppDenominator = 0;
                
                //13
                if(userProspectClosedOppNumeratorMap.containsKey(ag.User__c))
                {
                    prospectClosedOppNumerator = userProspectClosedOppNumeratorMap.get(ag.User__c);
                }
                
                if(userProspectClosedOppDenominatorMap.containsKey(ag.User__c))
                {
                    prospectClosedOppDenominator = userProspectClosedOppDenominatorMap.get(ag.User__c);
                }
                
                //14
                if(userCurrentClosedOppNumeratorMap.containsKey(ag.User__c))
                {
                    currentClosedOppNumerator = userCurrentClosedOppNumeratorMap.get(ag.User__c);
                }
                
                if(userCurrentClosedOppDenominatorMap.containsKey(ag.User__c))
                {
                    currentClosedOppDenominator = userCurrentClosedOppDenominatorMap.get(ag.User__c);
                }
                                
                for(Opportunity o :opps)
                {
                    if(o.StageName != 'Pre-Opportunity'  && o.StageName != 'Pre-Opportunity Terminated' && o.Report_Created_Date__c != null && o.Report_Created_Date__c.year() == currentYear)
                    {
                        leads += 1;
                        
                        if(o.Proposal_Date__c != null && o.Proposal_Date__c.year() == currentYear)
                        {
                            sameYearProposals += 1;
                        }
                    }
                    
                    if(o.StageName != 'Pre-Opportunity'  && o.StageName != 'Pre-Opportunity Terminated' && o.Proposal_Date__c != null && o.Proposal_Date__c.year() == currentYear)
                    {
                        proposals += 1;
                        
                        if(o.Amount != null)
                        {
                            proposalSize += o.Amount;
                        }
                    }
                    
                    if(o.CloseDate.year() == currentYear && o.Proposal_Date__c != null)
                    {
                        if(o.StageName == 'Lost')
                        {
                            if(newAccountMap.containsKey(o.AccountId))
                            {
                                closedLostNew += 1;
                            }
                            else
                            {
                                closedLostCurrent += 1;
                            }
                            
                            if(o.Proposal_Date__c != null && o.Proposal_Date__c.year() == currentYear)
                            {
                                closedLostProposal += 1;
                            }
                            
                            if(o.Report_Created_Date__c != null && o.Report_Created_Date__c.year() == currentYear)
                            {
                                closedLostLead += 1;
                            }
                        }
                        else if(o.StageName == 'Awarded' || o.StageName == 'Approved' || o.StageName == 'Declined')
                        {
                            if(newAccountMap.containsKey(o.AccountId))
                            {
                                closedWonNew += 1;
                            }
                            else
                            {
                                closedWonCurrent += 1;
                            }
                            
                            if(o.Proposal_Date__c != null && o.Proposal_Date__c.year() == currentYear)
                            {
                                closedWonProposal += 1;
                            }
                            
                            if(o.Report_Created_Date__c != null && o.Report_Created_Date__c.year() == currentYear)
                            {
                                closedWonLead += 1;
                            }
                        }
                    }
                }//for opps
                
                for(Schedule__c s :schedules) {
                    Decimal aacgm = 0;
                 
                    try{
                        if(aacgm1Stages.contains(s.stage__c) || (aacgm2Stages.contains(s.stage__c) && s.Count_for_A_A__c == 'Yes')){
                            //16-1, 16-2, 17-1, 17-2, 18-1, 18-2
                            if((s.Orignal_LOI_Award_Date__c != null && s.Orignal_LOI_Award_Date__c.year() == currentYear) || 
                                (s.Award_Date_Override__c != null && s.Award_Date_Override__c.year() == currentYear))
                            {
                                if(s.Alternative_CGM__c != null)
                                {
                                    aacgm = s.Alternative_CGM__c * s.Total_Equipment_Cost__c / 100;
                                }
                                else
                                {
                                    aacgm = s.Actual_GM_Dollars__c;   
                                }
                            }
                        }
                        
                        if(aacgm3Stages.contains(s.stage__c) || (aacgm2Stages.contains(s.stage__c) && s.Count_for_A_A__c == 'Yes')){
                            if(s.Additional_A_A_Award_Date__c != null && s.Additional_A_A_Award_Date__c.year() == currentYear && 
                                (s.Orignal_LOI_Award_Date__c == null || s.Orignal_LOI_Award_Date__c.year() != currentYear) && 
                                (s.Award_Date_Override__c == null || s.Award_Date_Override__c.year() != currentYear))
                            {   
                                //16-3, 17-3, 18-3
                                
                                if(s.Alternative_CGM__c != null)
                                {
                                    aacgm = s.Alternative_CGM__c * s.Additional_A_A_Revenue__c / 100;
                                }
                                else
                                {
                                    aacgm = s.Additional_A_A_Revenue__c * s.GM_Percent__c / 100;
                                }
                              
                            }
                        }
                        
                        //issue #3 tamarack
                        if (aacgm2Stages.contains(s.stage__c) && s.Count_for_A_A__c == 'Partial' && ((s.Orignal_LOI_Award_Date__c != null && s.Orignal_LOI_Award_Date__c.year() == currentYear) || 
                                (s.Award_Date_Override__c != null && s.Award_Date_Override__c.year() == currentYear)))
                        {   
                            //16-4, 17-4, 18-4 //tamarack 2-5-15 fixing NPE 
                            if(s.Partial_A_A_Revenue__c != null && s.Alternative_CGM__c != null){
                                aacgm = s.Partial_A_A_Revenue__c * s.Alternative_CGM__c / 100;
                            }

                            //tamarack 2-5-15 fixing NPE 
                            else if (s.Partial_A_A_Revenue__c != null && s.GM_Percent__c != null){
                                aacgm = s.Partial_A_A_Revenue__c * s.GM_Percent__c / 100;
                            }
                        }
                                            
                       
                                            
                        if(aacgm == null){
                            aacgm = 0;
                        }
                        
                        //System.debug('Calculated  Dollars: ' + s.Actual_GM_Dollars__c);
                            
                        if(s.Financial_Product__c == 'Fair Market Value'){
                            fmv += aacgm;
                            
                            if(newAccountMap.containsKey(s.Account_Lookup__c))
                            {
                                if(!newAccountFmvFmaSet.contains(s.Account_Lookup__c))
                                {
                                    newAccountFmvFmaSet.add(s.Account_Lookup__c);
                                }
                            }
                        } else if(s.Financial_Product__c == 'First Amendment Deal'){
                            fma += aacgm;
                            
                            if(newAccountMap.containsKey(s.Account_Lookup__c))
                            {                           
                                if(!newAccountFmvFmaSet.contains(s.Account_Lookup__c))
                                {
                                    newAccountFmvFmaSet.add(s.Account_Lookup__c);
                                }
                            }
                        } else {// if(s.Financial_Product__c == '$1.00 Purchase Option')
                            csc += aacgm;
                        }
                        
                        if(newAccountMap.containsKey(s.Account_Lookup__c)){
                            //20
                            newAccountAACGM += aacgm;
                            
                            //3
                            Decimal accountAacgmTotal = 0;
                            
                            if(qualifiedNewAccountAacgmMap.containsKey(s.Account_Lookup__c))
                            {
                                accountAacgmTotal = qualifiedNewAccountAacgmMap.get(s.Account_Lookup__c);
                            }
                            
                            accountAacgmTotal += aacgm;
                            qualifiedNewAccountAacgmMap.put(s.Account_Lookup__c, accountAacgmTotal);
                        }
                        
                        //Funded CGM
                        if(s.Anticipated_Fund_Date__c != null && s.Anticipated_Fund_Date__c.year() == currentyear){
                            decimal funded = s.Actual_GM_Dollars__c;                       
                            
                            if(s.Alternative_CGM__c != null)
                            {
                                funded = s.Alternative_CGM__c * s.Total_Equipment_Cost__c / 100;
                            }
                            
                            if(s.Stage__c == 'Booked' || s.Stage__c == 'Booked with Follow ups')
                            {
                                fundedCGM += funded;
                            }
                            else if(s.Stage__c != 'Booked' && s.Stage__c != 'Booked with Follow ups' && s.Stage__c != 'Declined' && s.Stage__c != 'Cancelled' && s.Stage__c != 'Withdrawn')
                            {
                                fundedCGMBacklog += funded;
                            }
                        }
                    }
                    catch(Exception ex)
                    {
                        throw new AnnualGoalsException('Schedule ID: ' + s.Id + ' *** Error: ' + ex.getMessage() + ' ' + ex.getStackTraceString());
                    }
                }//Schedules loop
                
                //Qualified new accounts and new accounts with FMA/FMV transaction
                for(Id i :qualifiedNewAccountAacgmMap.keySet())
                {
                    if(qualifiedNewAccountAacgmMap.get(i) > 10000)
                    {
                        //3
                        qualifiedNewAccounts++;
                        
                        //4
                        if(newAccountFmvFmaSet.contains(i))
                        {
                            fmvFmaTransactions++;
                        }
                    }
                }
                
                /*system.debug('closedWonProposal:' + closedWonProposal);
                system.debug('closedLostProposal:' + closedLostProposal);
                system.debug('proposalSize:' + proposalSize);
                system.debug('proposals:' + proposals);
                system.debug('closedWonCurrent:' + closedWonCurrent);
                system.debug('closedLostCurrent:' + closedLostCurrent);
                system.debug('closedWonLead:' + closedWonLead);
                system.debug('closedWonNew:' + closedWonNew);
                system.debug('closedLostNew:' + closedLostNew);*/
                //20
                if(newAccountAACGM == 0)
                {
                    ag.AACGMNewCustomers__c = 0;
                }
                else
                {
                    ag.AACGMNewCustomers__c = newAccountAACGM;  
                }
                
                //15
                //tamarack update 2-5-15
                ag.Total_Closed_Current_Customers_Not_Lost__c = currentClosedOppNumerator == null ? 0 : currentClosedOppNumerator;
                ag.Total_Closed_Current_Customers__c = currentClosedOppDenominator == null ? 0 : currentClosedOppDenominator;
                
                //if((prospectClosedOppDenominator + currentClosedOppDenominator) == 0)
                //{
                //    ag.AllProposalsClosingRate__c =  0;
                //}
                //else
                //{
                //     ag.AllProposalsClosingRate__c = ((prospectClosedOppNumerator + currentClosedOppNumerator) / (prospectClosedOppDenominator + currentClosedOppDenominator)) * 100;
                //}
                
                //10
                //tamarack 2-5-2015
                ag.Proposal_Size__c = proposalSize;
                //if(proposals == 0)
                //{
                //    ag.AvgProposalSize__c = 0;
                //}
                //else
                //{
                //    ag.AvgProposalSize__c = proposalSize / proposals;
                //}
                ag.CSCGrossMargin__c = csc;
                
                //14
                //tamarack 2-5-15
                //if(currentClosedOppDenominator == 0)
                //{
                //    ag.CurrentCustomersClosingRate__c = 0;
                //}
                //else
                //{
                //    ag.CurrentCustomersClosingRate__c = (currentClosedOppNumerator / currentClosedOppDenominator) * 100;
                //}
                
                //17
                ag.FMAGrossMargin__c = fma;
                
                //16
                ag.FMVGrossMargin__c = fmv;
                
                //5
                ag.FundedCGM__c = fundedCGM;
                
                //6
                ag.FundedCGMBacklog__c = fundedCGMBacklog;
                
                //11
                //tamarack 2-5-2015
                ag.Same_Year_Proposals__c = sameYearProposals;
                //if( leads == 0)
                //{
                //    ag.LeadConversionRate__c = 0;
                //}
                //else
                //{
                //    ag.LeadConversionRate__c = (sameYearProposals / leads) * 100;
                //}
                
                //9
                ag.Leads__c = leads;   
                
                //19            
                ag.NewAccounts__c = userNewAccountsMap.containsKey(ag.User__c) ? userNewAccountsMap.get(ag.User__c) : 0;
                
                //4
                ag.NewAccountsFMVFMATransactions__c = fmvFmaTransactions;       
                
                //8
                ag.OfficeMeetings__c = userOfficeMeetingsMap.containsKey(ag.User__c) ? userOfficeMeetingsMap.get(ag.User__c) : 0;
                
                ag.X7_Figure_Deals__c = userSevenFigureDealsMap.containsKey(ag.User__c) ? userSevenFigureDealsMap.get(ag.User__c) :0;
                
                //10
                ag.Proposals__c = proposals;
                
                //13

                //tamarack update 2-5-15
                ag.Total_Closed_Prospects_Not_Lost__c = prospectClosedOppNumerator;
                ag.Total_Closed_Prospects__c = prospectClosedOppDenominator;

                //if(prospectClosedOppDenominator == 0)
                //{
                //    ag.ProspectsClosingRate__c =  0;
                //}
                //else
                //{
                //    ag.ProspectsClosingRate__c =  (prospectClosedOppNumerator / prospectClosedOppDenominator) * 100;
                //}



                
                //3
                ag.QualifiedNewAccounts__c = qualifiedNewAccounts;
                
                //7
                ag.VirtualMeetings__c = userVirtualMeetingsMap.containsKey(ag.User__c) ? userVirtualMeetingsMap.get(ag.User__c) : 0;


                //tamarack 02-22-15
                //add logic to update PC_Goal lookups on individual user goals
                ag.Presidents_Club_Goal__c = pcGoalNameMap.get(ag.PC_Year_and_Category__c);

                //end update pc goals
                 
            }//for goal
                        
            update goals;
        }
    }
    
    public static void updateCareerToDateFundedCGM(List<ID> userIds)
    {
        Map<ID, User> userMap = new Map<ID, User>([SELECT Id, FundedCGM12312013__c, FundedCGMCareerToDate__c FROM User where Id in :userIds ]);
        List<User> users = new List<User>();
        AggregateResult[] results = [SELECT User__c, SUM(FundedCGM__c) FROM AnnualGoals__c where User__c in :userIds GROUP BY User__c];
        
        for(AggregateResult ar :results)
        {
            User u = userMap.get((ID)ar.get('User__c'));
            Decimal fundedCGM = u.FundedCGM12312013__c == null ? 0 : u.FundedCGM12312013__c + (Decimal)ar.get('expr0');
            
            if(u.FundedCGMCareerToDate__c != fundedCGM)
            {
                u.FundedCGMCareerToDate__c = fundedCGM;
                users.Add(u);
            }
            
            if(users.size() > 0)
            {
                update users;
            }
        }       
    }
    
    public static void createGoals(List<ID> userIds, Integer currentYear)
    {
        List<AnnualGoals__c> goals = [SELECT User__c FROM AnnualGoals__c WHERE Year__c = :String.valueOf(currentYear) AND User__c in :userIds];
        Set<ID> users = new Set<ID>();
        List<AnnualGoals__c> newGoals = new List<AnnualGoals__c>(); 
        
        for(AnnualGoals__c g :goals)
        {
            users.add(g.User__c);
        }                           
        
        for(ID uId :userIds)
        {
            if(!users.contains(uId))
            {
                newGoals.add(new AnnualGoals__c(User__c = uId, Year__c = String.valueOf(currentYear), Name = 'x', OwnerId = uId));
            }
        }
        
        if(newGoals.size() > 0)
        {
            insert newGoals;
        }
    }
    
    public static Boolean Manager()
    {
        return [SELECT AnnualGoalsManagerView__c FROM User WHERE Id =: UserInfo.getUserId()][0].AnnualGoalsManagerView__c;
    }
    
    public static List<User> getUsers()
    {
        return [SELECT ID, Name FROM User 
                    WHERE isactive = true AND Profile.Name != 'Sales - RVP' AND Profile.Name != 'Sales - RVP - Vendor' AND Profile.Name LIKE 'Sales%'
                    ORDER BY Name];
    }
    
    public static List<SelectOption> getUserOptions()
    {
        List<User> users = null;
        List<SelectOption> options = new List<SelectOption>();
        
        users = getUsers();
            
        for(User u :users)
        {           
            options.add(new SelectOption(u.Id,u.Name));         
        }
        
        return options;
    } 
    
    public static List<ScheduleSummary> getUserScheduleSummaries(ID userId)
    {
        Integer currentYear = Date.today().year();
        List<ScheduleSummary> summaries = new List<ScheduleSummary>();
        List<Schedule__c> schedules = [SELECT ID, Name, Financial_Product__c, Stage__c, Orignal_LOI_Award_Date__c, Actual_GM_Dollars__c, GM_Percent__c, Count_for_A_A__c, 
                                                Partial_A_A_Revenue__c, Account_Lookup__c, Award_Date_Override__c, Alternative_CGM__c, Total_Equipment_Cost__c, Additional_A_A_Revenue__c, 
                                                Additional_A_A_Award_Date__c, Count_Additional_for_A_A__c, Letter_of_Intent__r.Opportunity__r.OwnerId, Anticipated_Fund_Date__c,
                                                Letter_of_Intent__r.Opportunity__r.Prospect_as_of_Qualified_Opp_Creation__c, Letter_of_Intent__r.Opportunity__r.StageName
                                                FROM Schedule__c 
                                                WHERE (CALENDAR_YEAR(Orignal_LOI_Award_Date__c) = :currentYear OR CALENDAR_YEAR(Award_Date_Override__c) = :currentYear 
                                                        OR CALENDAR_YEAR(Additional_A_A_Award_Date__c) = :currentYear OR CALENDAR_YEAR(Anticipated_Fund_Date__c) = :currentYear) 
                                                        AND Letter_of_Intent__r.Opportunity__r.OwnerId = :userId
                                        order by Name desc
                                      ];
        
        
        for(Schedule__c s :schedules)
        {
            Decimal fmv = 0;
            Decimal fma = 0;
            Decimal csc = 0;
            Decimal aacgm = 0;
            
            try
            {
                if(aacgm1Stages.contains(s.stage__c) || (aacgm2Stages.contains(s.stage__c) && s.Count_for_A_A__c == 'Yes'))
                {
                    //16-1, 16-2, 17-1, 17-2, 18-1, 18-2
                    if((s.Orignal_LOI_Award_Date__c != null && s.Orignal_LOI_Award_Date__c.year() == currentYear) || 
                       (s.Award_Date_Override__c != null && s.Award_Date_Override__c.year() == currentYear))
                    {
                        if(s.Alternative_CGM__c != null)
                        {
                            aacgm = s.Alternative_CGM__c * s.Total_Equipment_Cost__c / 100;
                        }
                        else
                        {
                            aacgm = s.Actual_GM_Dollars__c;   
                        }
                    }
                }
                
                if(aacgm3Stages.contains(s.stage__c) || (aacgm2Stages.contains(s.stage__c) && s.Count_for_A_A__c == 'Yes'))
                {
                    if(s.Additional_A_A_Award_Date__c != null && s.Additional_A_A_Award_Date__c.year() == currentYear && 
                       (s.Orignal_LOI_Award_Date__c == null || s.Orignal_LOI_Award_Date__c.year() != currentYear) && 
                       (s.Award_Date_Override__c == null || s.Award_Date_Override__c.year() != currentYear))
                    {   
                        //16-3, 17-3, 18-3
                        
                        if(s.Alternative_CGM__c != null)
                        {
                            aacgm = s.Alternative_CGM__c * s.Additional_A_A_Revenue__c / 100;
                        }
                        else
                        {
                            aacgm = s.Additional_A_A_Revenue__c * s.GM_Percent__c / 100;
                        }
                        
                    }
                }
                //issue #3 tamarack
                if (aacgm2Stages.contains(s.stage__c) && s.Count_for_A_A__c == 'Partial' && ((s.Orignal_LOI_Award_Date__c != null && s.Orignal_LOI_Award_Date__c.year() == currentYear) || 
                                                                                             (s.Award_Date_Override__c != null && s.Award_Date_Override__c.year() == currentYear)))
                {   
                    //16-4, 17-4, 18-4
                    if(s.Alternative_CGM__c != null)
                    {
                        aacgm = s.Partial_A_A_Revenue__c * s.Alternative_CGM__c / 100;
                    }
                    else
                    {
                        aacgm = s.Partial_A_A_Revenue__c * s.GM_Percent__c / 100;
                    }
                }
                
                if(aacgm == null)
                {
                    aacgm = 0;
                }
                
                //System.debug('Calculated  Dollars: ' + s.Actual_GM_Dollars__c);
                
                if(s.Financial_Product__c == 'Fair Market Value')
                {
                    fmv = aacgm;
                }
                else if(s.Financial_Product__c == 'First Amendment Deal')
                {
                    fma = aacgm;
                }
                else// if(s.Financial_Product__c == '$1.00 Purchase Option')
                {
                    csc = aacgm;
                }
            }
            catch(Exception ex)
            {
                throw new AnnualGoalsException('Schedule ID: ' + s.Id + ' *** Error: ' + ex.getMessage() + ' ' + ex.getStackTraceString());
            }
            
            summaries.add(new ScheduleSummary(s.Id, s.Name, fma, fmv, csc));
        }//Schedules loop
                
        return summaries;
    }
    
    public class ScheduleSummary
    {
        public ID id{get;set;}
        public String name {get;set;}
        public Decimal fma{get;set;}
        public Decimal fmv{get;set;}
        public Decimal csc{get;set;}
        
        public ScheduleSummary(ID sId, String sName, Decimal sFma, Decimal sFmv, Decimal sCsc)
        {
            this.id = sId;
            this.name = sName;
            this.fma = sFma;
            this.fmv = sFmv;
            this.csc = sCsc;
        }
    }
}