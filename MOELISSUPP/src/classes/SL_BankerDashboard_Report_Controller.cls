/**
 * \author Vika Osmak 
 * \date 03/12/12
 * \see https://silverline.jira.com/browse/MBS-2
 * \brief Senior Banker Scorecard Report (Summary and Detail Sections) 
 */
global class SL_BankerDashboard_Report_Controller
{
    // Inputs to the report.
    public Id userId {get; private set;}
    public String filter {get; private set;}
    public List<String> subFilters {get; private set;}
    public Date curStartDate {get; private set;}
    public Date curEndDate {get; private set;}

    // things to prevent. 
    private Set<String> listMDSCTitles;
    private Set<String> listExcludeGroups;
 
    // main list for the report.
    public List<curEmployee> listSBS_Reports {get; private set;}
    private Map<Id,Employee_Profile__c> mapEmployeeId_Employee;
    public String currencySymbol {get;set;}

    System.LoggingLevel logErr = LoggingLevel.ERROR;
    
    // Constructor
    public SL_BankerDashboard_Report_Controller()
    {
        // Init the main map and list for this report.
        mapEmployeeId_Employee = new Map<Id,Employee_Profile__c>();
        listSBS_Reports = new List<curEmployee>();

        // determine the report filer.
        if(ApexPages.currentPage().getParameters().get('filter') != null && ApexPages.currentPage().getParameters().get('filter') != '')
            this.filter = ApexPages.currentPage().getParameters().get('filter');
        else
            this.filter='banker';
        this.subFilters = new List<String>();

        // Init some currently logged in user details.        
        Id loggedInUserId = UserInfo.getUserId();
        //Id loggedInUserProfileId = UserInfo.getProfileId();
        currencySymbol = getCurrencySymbol(UserInfo.getDefaultCurrency());
        Boolean isAdmin = false;
        //String profileName = [SELECT Name from Profile WHERE Id=:loggedInUserProfileId].Name;
        isAdmin = [Select Banker_Dashboard_Admin__c FROM User WHERE Id=:loggedInUserId].Banker_Dashboard_Admin__c;
        
        // if it's an admin running the report, allow them to query the data for other people. Otherwise,only get data for the user running the report.
        if(isAdmin)
        {
            if(ApexPages.currentPage().getParameters().get('subfilters') != null && ApexPages.currentPage().getParameters().get('subfilters') != '')
            {
                if(ApexPages.currentPage().getParameters().get('subfilters').contains(';'))
                {
                    this.subFilters = ApexPages.currentPage().getParameters().get('subfilters').split(';');
                }
                else 
                    this.subFilters.add(ApexPages.currentPage().getParameters().get('subfilters'));
            }
            else
            {
                for(Employee_Profile__c item : [ SELECT Id
                                             FROM Employee_Profile__c
                                             WHERE User_ID__c =:loggedInUserId])
                {
                    this.subFilters.add(item.Id);
                }
            }
        }
        else
        {
            for(Employee_Profile__c item : [ SELECT Id
                                             FROM Employee_Profile__c
                                             WHERE User_ID__c =:loggedInUserId])
            {
                this.subFilters.add(item.Id);
            }
        }
        
        // Get the start and end dates for the report.
        if(ApexPages.currentPage().getParameters().get('sdate') != null && ApexPages.currentPage().getParameters().get('sdate') != '')
            this.curStartDate  = Date.valueOf(ApexPages.currentPage().getParameters().get('sdate'));
        if(ApexPages.currentPage().getParameters().get('edate') != null && ApexPages.currentPage().getParameters().get('edate') != '')
            this.curEndDate  = Date.valueOf(ApexPages.currentPage().getParameters().get('edate'));
        

        // This method will get all the employees we want to run this report for.
        this.getEmployeeOrderedList();


        if(listSBS_Reports.size() > 0)
        {
            list<AggregateResult> groupedResults;
            Integer countEvents;
            Integer countCallLogs;
            Integer countEventsMD;
            Integer countCallLogsMD;
            Integer countMDBankers;
            
            String strAttendees = '';
            Schema.DescribeSObjectResult R = Account.SObjectType.getDescribe();
            String AccountPrefix = R.getKeyPrefix();
            R = User.SObjectType.getDescribe();
            String UserPrefix = R.getKeyPrefix();
            
            map<Id,Id> mapEmployeeId_UserId = new map<Id,Id>();
            map<Id,String> mapEmployeeId_Title = new map<Id,String>();
            map<String,set<Id>> mapEmployeeTitle_setUserIds = new map<String,set<Id>>();
            if(mapEmployeeId_Employee.keySet().size() > 0)
            {
                for(Id eId : mapEmployeeId_Employee.keySet())
                {
                    if(mapEmployeeId_Employee.get(eId).User_ID__c != null)
                            mapEmployeeId_UserId.put(eId,mapEmployeeId_Employee.get(eId).User_ID__c);
                    if(mapEmployeeId_Employee.get(eId).Title__c != null)
                            mapEmployeeId_Title.put(eId,mapEmployeeId_Employee.get(eId).Title__c);
                    if(mapEmployeeId_Employee.get(eId).Title__c != null && mapEmployeeId_Employee.get(eId).User_ID__c != null)
                    {
                        if(!mapEmployeeTitle_setUserIds.keySet().contains(mapEmployeeId_Employee.get(eId).Title__c))     
                            mapEmployeeTitle_setUserIds.put(mapEmployeeId_Employee.get(eId).Title__c, new set<Id>());
                        mapEmployeeTitle_setUserIds.get(mapEmployeeId_Employee.get(eId).Title__c).add(mapEmployeeId_Employee.get(eId).User_ID__c);
                    }
                }
            }
           
            map<String,Set<Id>> mapSBankerTitle_setSBankerIds = new map<String,Set<Id>>(); // SeniorBankerTitle -> all Bankers with SeniorBankerTitle
            map<String,Set<Id>> mapSBankerTitle_setSBankerUserIds = new map<String,Set<Id>>(); // SeniorBankerTitle ->UserIds for all Bankers with SeniorBankerTitle
            map<String,Integer> mapSBankerTitle_countSBankers = new map<String,Integer>(); // SeniorBankerTitle -> count (all Bankers with SeniorBankerTitle)
            if(mapEmployeeId_Title.values().size() > 0)
            {
                for(Employee_Profile__c item : [SELECT Id,Title__c,User_ID__c 
                                                FROM Employee_Profile__c 
                                                WHERE   Title__c IN : mapEmployeeId_Title.values() AND
                                                        Status__c = 'Active' AND 
                                                        Business_Type__c = 'Advisory' AND
                                                        Group__c NOT IN :listExcludeGroups  ])
                {
                    if(!mapSBankerTitle_setSBankerIds.keySet().contains(item.Title__c)) 
                        mapSBankerTitle_setSBankerIds.put(item.Title__c, new Set<Id>());
                    mapSBankerTitle_setSBankerIds.get(item.Title__c).add(item.Id);
                    
                    if(!mapSBankerTitle_setSBankerUserIds.keySet().contains(item.Title__c)) 
                        mapSBankerTitle_setSBankerUserIds.put(item.Title__c, new Set<Id>());
                    mapSBankerTitle_setSBankerUserIds.get(item.Title__c).add(item.User_ID__c);

                    
                    if(!mapSBankerTitle_countSBankers.keySet().contains(item.Title__c)) 
                        mapSBankerTitle_countSBankers.put(item.Title__c, 0);
                    mapSBankerTitle_countSBankers.put(item.Title__c, mapSBankerTitle_countSBankers.get(item.Title__c) + 1);
                }
            }
            
            ////////////////////////Pitches///////////////////////////////////////////////////////////
            Decimal countDealsBankers = 0;
            Decimal count_MDBanker = 0;
            map<String,Integer> mapSBankerTitle_countBankerProjects = new map<String,Integer>();
            map<String,set<Id>> mapSBankerTitle_setBankers = new map<String,set<Id>>();
            map<String,Integer> mapSBankerTitle_countBankers = new map<String,Integer>();
            map<Id,Integer> mapEmployeeId_countProjects = new map<Id,Integer>();
            map<String,Decimal> mapSBankerTitle_averagePitches = new map<String,Decimal>();


            if(mapEmployeeId_Employee.keySet().size() > 0)
            {
                groupedResults = new list<AggregateResult>();
                groupedResults = [  SELECT Banker__c banker, count(Project__c) countProjects
                                FROM Project_Resource__c 
                                WHERE   Banker__c IN : mapEmployeeId_Employee.keySet() AND
                                        Status__c = 'Active' AND 
                                        Project__r.Pitch_Date__c >=: curStartDate  AND Project__r.Pitch_Date__c <=: curEndDate
                                GROUP BY Banker__c];
                for (AggregateResult ar : groupedResults)
                {
                    mapEmployeeId_countProjects.put((Id)ar.get('banker'), (Integer)ar.get('countProjects'));
                }
            }
            //system.debug('mapEmployeeId_countProjects = '+mapEmployeeId_countProjects);
            if(mapEmployeeId_Title.values().size() > 0)
            {
                for(Project_Resource__c item :[ SELECT Id,Project__c,Banker__c,Banker__r.Title__c
                                                FROM Project_Resource__c 
                                                WHERE   Banker__r.Title__c IN : mapEmployeeId_Title.values() AND
                                                        Banker__r.Status__c = 'Active' AND 
                                                        Banker__r.Business_Type__c = 'Advisory' AND
                                                        Banker__r.Group__c NOT IN :listExcludeGroups AND
                                                        Status__c = 'Active' AND 
                                                        Project__r.Pitch_Date__c >=: curStartDate  AND Project__r.Pitch_Date__c <=: curEndDate
                                                ])
                {
                    // init mapSBankerTitle_countBankerProjects for this Title.
                    if(!mapSBankerTitle_countBankerProjects.keySet().contains(item.Banker__r.Title__c)) 
                        mapSBankerTitle_countBankerProjects.put(item.Banker__r.Title__c, 0);
                    mapSBankerTitle_countBankerProjects.put(item.Banker__r.Title__c, mapSBankerTitle_countBankerProjects.get(item.Banker__r.Title__c) + 1);

                    // init mapSBankerTitle_setBankers for this Title.
                    if(!mapSBankerTitle_setBankers.keySet().contains(item.Banker__r.Title__c))  
                        mapSBankerTitle_setBankers.put(item.Banker__r.Title__c, new set<Id>());
                    mapSBankerTitle_setBankers.get(item.Banker__r.Title__c).add(item.Banker__c);
                }
                if(mapSBankerTitle_setBankers.keySet().size() > 0)
                {
                    for(String sTitle : mapSBankerTitle_setBankers.keySet()){
                        mapSBankerTitle_countBankers.put(sTitle,mapSBankerTitle_setBankers.get(sTitle).size());
                    }
                }
                
                for(Id eId : mapEmployeeId_Title.keySet())
                {
                    countDealsBankers = 0;
                    count_MDBanker = 0;
                    if(mapSBankerTitle_countBankerProjects.get(mapEmployeeId_Title.get(eId)) != null)
                        countDealsBankers = mapSBankerTitle_countBankerProjects.get(mapEmployeeId_Title.get(eId));
                    count_MDBanker = mapSBankerTitle_countSBankers.get(mapEmployeeId_Title.get(eId));
                    mapSBankerTitle_averagePitches.put(mapEmployeeId_Title.get(eId),(count_MDBanker != 0 ? countDealsBankers / count_MDBanker : 0) );
                }
            }

            //////////////////////////////Pitches YTD//////////////////////////////
            mapSBankerTitle_countBankerProjects = new map<String,Integer>();
            mapSBankerTitle_setBankers = new map<String,set<Id>>();
            mapSBankerTitle_countBankers = new map<String,Integer>();
            map<Id,Integer> mapYTD_EmployeeId_countProjects = new map<Id,Integer>();
            map<String,Decimal> mapYTD_SBankerTitle_averagePitches = new map<String,Decimal>();
            if(mapEmployeeId_Employee.keySet().size() > 0)
            {
                groupedResults = new list<AggregateResult>();
                groupedResults = [  SELECT Banker__c banker, count(Project__c) countProjects
                                FROM Project_Resource__c 
                                WHERE   Banker__c IN : mapEmployeeId_Employee.keySet() AND
                                        Status__c = 'Active' AND 
                                        Project__r.Pitch_Date__c  = THIS_YEAR  AND 
                                        Project__r.Pitch_Date__c <= TODAY
                                GROUP BY Banker__c];
                for (AggregateResult ar : groupedResults)
                {
                    mapYTD_EmployeeId_countProjects.put((Id)ar.get('banker'), (Integer)ar.get('countProjects'));
                }
            }
            //system.debug('mapYTD_EmployeeId_countProjects = '+mapYTD_EmployeeId_countProjects);
            if(mapEmployeeId_Title.values().size() > 0)
            {
                for(Project_Resource__c item :[ SELECT Id,Project__c,Banker__c,Banker__r.Title__c
                                                FROM Project_Resource__c 
                                                WHERE   Banker__r.Title__c IN : mapEmployeeId_Title.values() AND
                                                        Banker__r.Status__c = 'Active' AND 
                                                        Banker__r.Business_Type__c = 'Advisory' AND
                                                        Banker__r.Group__c NOT IN :listExcludeGroups AND
                                                        Status__c = 'Active' AND 
                                                        Project__r.Pitch_Date__c  = THIS_YEAR  AND Project__r.Pitch_Date__c <= TODAY
                                                ])
                {
                    // init mapSBankerTitle_countBankerProjects for this title.
                    if(!mapSBankerTitle_countBankerProjects.keySet().contains(item.Banker__r.Title__c)) 
                        mapSBankerTitle_countBankerProjects.put(item.Banker__r.Title__c, 0);
                    mapSBankerTitle_countBankerProjects.put(item.Banker__r.Title__c, mapSBankerTitle_countBankerProjects.get(item.Banker__r.Title__c) + 1);

                    // init mapSBankerTitle_setBankersfor this title.
                    if(!mapSBankerTitle_setBankers.keySet().contains(item.Banker__r.Title__c))  
                        mapSBankerTitle_setBankers.put(item.Banker__r.Title__c, new set<Id>());
                    mapSBankerTitle_setBankers.get(item.Banker__r.Title__c).add(item.Banker__c);
                }
                if(mapSBankerTitle_setBankers.keySet().size() > 0)
                {
                    for(String sTitle : mapSBankerTitle_setBankers.keySet()){
                        mapSBankerTitle_countBankers.put(sTitle,mapSBankerTitle_setBankers.get(sTitle).size());
                    }
                }
                
                for(Id eId : mapEmployeeId_Title.keySet())
                {
                    countDealsBankers = 0;
                    count_MDBanker = 0;
                    if(mapSBankerTitle_countBankerProjects.get(mapEmployeeId_Title.get(eId)) != null)
                        countDealsBankers = mapSBankerTitle_countBankerProjects.get(mapEmployeeId_Title.get(eId));
                    count_MDBanker = mapSBankerTitle_countSBankers.get(mapEmployeeId_Title.get(eId));
                    mapYTD_SBankerTitle_averagePitches.put(mapEmployeeId_Title.get(eId),(count_MDBanker != 0 ? countDealsBankers / count_MDBanker : 0) );
                }
            }

            map<id,Set<Id>> mapEmployeeId_setProjectIds = new map<id,Set<Id>>();
            set<Id> setEmployeeIdProjectIds = new set<Id>();
            
            map<String,Set<Id>> mapSBankerTitle_setProjectIds = new map<String,Set<Id>>();
            set<Id> setEmployeeTitleProjectIds = new set<Id>();
            
                       
            if(mapEmployeeId_Employee.keySet().size() > 0)
            {
                for(Project_Resource__c item : [SELECT Banker__c,Project__c 
                                                FROM Project_Resource__c 
                                                WHERE   Banker__c IN : mapEmployeeId_Employee.keySet()  AND 
                                                        Status__c = 'Active'])
                {
                    if(!mapEmployeeId_setProjectIds.keySet().contains(item.Banker__c))  mapEmployeeId_setProjectIds.put(item.Banker__c, new set<Id>());
                    mapEmployeeId_setProjectIds.get(item.Banker__c).add(item.Project__c);
                    setEmployeeIdProjectIds.add(item.Project__c);
                }
                  system.debug('mapEmployeeId_setProjectIds = '+mapEmployeeId_setProjectIds);
                  system.debug('setEmployeeIdProjectIds = '+setEmployeeIdProjectIds);
            }
            
            //////////////////////////////////  LiveMandates ///////////////////////////////////////////////////////
            map<Id,Integer> mapLM_EmployeeId_countProjects = new map<Id,Integer>();
            map<String,Integer> mapLM_SBankerTitle_countBankerProjects = new map<String,Integer>();
            map<String,set<Id>> mapLM_SBankerTitle_setBankers = new map<String,set<Id>>();
            map<String,Integer> mapLM_SBankerTitle_countBankers = new map<String,Integer>();
            map<String,Decimal> mapLM_SBankerTitle_averagePitches = new map<String,Decimal>();
            
            //////////////////////////////////// AverageFee///////////////////////////////////////////////////
            Map<Id,Decimal> mapAF_EmployeeId_countEFees = new map<Id,Decimal>();
            Map<String,Decimal> mapAF_SBankerTitle_averageEFees = new map<String,Decimal>();
            Map<String,Decimal> mapAF_SBankerTitle_sumAverageFees  = new map<String,Decimal>();
            Map<String,Decimal> mapBankerTitleToSumOfPAR = new Map<String,Decimal>();
            
            //MBS-94
            Map<String, Decimal> mapBankerTitleToSumOfFeeRevenue = new Map<String, Decimal>();
            
            
            Map<Id, Set<Id>> mapBankerIdToSetOfProjectId = new Map<Id, Set<Id>>();
            Map<Id, Decimal> mapBankerIdToSumAF = new Map<Id, Decimal>();
            Map<Id, Decimal> mapBankerIdToAvgAF = new Map<Id, Decimal>();
            Map<Id, String> mapBankerIdToTitle = new Map<Id, String>();
            
            
            if(mapEmployeeId_Employee.keySet().size() > 0)
            {
                groupedResults = new list<AggregateResult>();
                groupedResults = [  SELECT Banker__c banker, count(Project__c) countProjects
                                FROM Project_Resource__c 
                                WHERE   Banker__c IN : mapEmployeeId_Employee.keySet() AND
                                        Status__c = 'Active' AND 
                                        Project__r.Include_in_Pipeline__c = true
                                GROUP BY Banker__c];
                for (AggregateResult ar : groupedResults)
                {
                    mapLM_EmployeeId_countProjects.put((Id)ar.get('banker'), (Integer)ar.get('countProjects'));
                }
            }
            system.debug('mapLM_EmployeeId_countProjects = '+mapLM_EmployeeId_countProjects);
            if(mapEmployeeId_Title.values().size() > 0)
            {
                for(Project_Resource__c item :[ SELECT Id,Project__c,Banker__c,Banker__r.Title__c,
                                                        convertCurrency(Project__r.Estimated_Fee_Revenue__c), 
                                                        convertCurrency(Project__r.Probability_Adjusted_Revenue__c),
                                                        convertCurrency(Project__r.Net_Est_Fee_Revenue_mm__c)
                                                FROM Project_Resource__c 
                                                WHERE   Banker__r.Title__c IN : mapEmployeeId_Title.values() AND
                                                        /*MBS-52*/
                                                        Banker__r.Status__c = 'Active' AND 
                                                        Banker__r.Business_Type__c = 'Advisory' AND
                                                        Banker__r.Group__c NOT IN :listExcludeGroups AND
                                                        Status__c = 'Active' AND 
                                                        Project__r.Include_in_Pipeline__c = true
                                                ])
                {
                    // init mapLM_SBankerTitle_countBankerProjects for this title.
                    if(!mapLM_SBankerTitle_countBankerProjects.keySet().contains(item.Banker__r.Title__c))  
                        mapLM_SBankerTitle_countBankerProjects.put(item.Banker__r.Title__c, 0);
                    mapLM_SBankerTitle_countBankerProjects.put(item.Banker__r.Title__c, mapLM_SBankerTitle_countBankerProjects.get(item.Banker__r.Title__c) + 1);
                
                    // init mapLM_SBankerTitle_setBankers for this title.
                    if(!mapLM_SBankerTitle_setBankers.keySet().contains(item.Banker__r.Title__c))   
                        mapLM_SBankerTitle_setBankers.put(item.Banker__r.Title__c, new set<Id>());
                    mapLM_SBankerTitle_setBankers.get(item.Banker__r.Title__c).add(item.Banker__c);
                    
                    /////////////// for Average Fee Per Mandate////////////////////
                    mapBankerIdToTitle.put(item.Banker__c, item.Banker__r.Title__c);
        
                    if(!mapBankerIdToSetOfProjectId.containsKey(item.Banker__c))
                    mapBankerIdToSetOfProjectId.put(item.Banker__c, new Set<Id>());
                     mapBankerIdToSetOfProjectId.get(item.Banker__c).add(item.Project__c);
        
                    if(!mapBankerIdToSumAF.containsKey(item.Banker__c))
                    mapBankerIdToSumAF.put(item.Banker__c, 0);
                    mapBankerIdToSumAF.put(item.Banker__c, mapBankerIdToSumAF.get(item.Banker__c) + (item.Project__r.Estimated_Fee_Revenue__c != null ? item.Project__r.Estimated_Fee_Revenue__c : 0));
            
                   /* if(!mapAF_SBankerTitle_sumAverageFees.containsKey(item.Banker__r.Title__c)) 
                          mapAF_SBankerTitle_sumAverageFees.put(item.Banker__r.Title__c,0);
                    mapAF_SBankerTitle_sumAverageFees.put(item.Banker__r.Title__c, mapAF_SBankerTitle_sumAverageFees.get(item.Banker__r.Title__c) + (item.Project__r.Estimated_Fee_Revenue__c != null ? item.Project__r.Estimated_Fee_Revenue__c : 0));*/
                    
                    // Weighted Pipeline
                    if(!mapBankerTitleToSumOfPAR.containsKey(item.Banker__r.Title__c)) 
                    mapBankerTitleToSumOfPAR.put(item.Banker__r.Title__c,0);
                    mapBankerTitleToSumOfPAR.put(item.Banker__r.Title__c, mapBankerTitleToSumOfPAR.get(item.Banker__r.Title__c) + (item.Project__r.Probability_Adjusted_Revenue__c != null ? item.Project__r.Probability_Adjusted_Revenue__c : 0));
                    
                    //Net Pipeline
                    if(!mapBankerTitleToSumOfFeeRevenue.containsKey(item.Banker__r.Title__c)) 
                        mapBankerTitleToSumOfFeeRevenue.put(item.Banker__r.Title__c,0);
                    
                    mapBankerTitleToSumOfFeeRevenue.put(item.Banker__r.Title__c, mapBankerTitleToSumOfFeeRevenue.get(item.Banker__r.Title__c) + (item.Project__r.Net_Est_Fee_Revenue_mm__c != null ? item.Project__r.Net_Est_Fee_Revenue_mm__c : 0));
                
                }
                for(Id bankerId : mapBankerIdToSetOfProjectId.keySet())
                {
                    if(mapBankerIdToSumAF.containsKey(bankerId) && mapBankerIdToSumAF.get(bankerId) != 0 && mapBankerIdToSetOfProjectId.get(bankerId).size() != 0)
                    {
                        mapBankerIdToAvgAF.put(bankerId,mapBankerIdToSumAF.get(bankerId)/mapBankerIdToSetOfProjectId.get(bankerId).size());
                    }
                }

                if(mapLM_SBankerTitle_setBankers.keySet().size() > 0)
                {
                    for(String sTitle : mapLM_SBankerTitle_setBankers.keySet()){
                        mapLM_SBankerTitle_countBankers.put(sTitle,mapLM_SBankerTitle_setBankers.get(sTitle).size());
                    }
                }
                
                for(Id eId : mapEmployeeId_Title.keySet())
                {
                    countDealsBankers = 0;
                    count_MDBanker = 0;
                    if(mapLM_SBankerTitle_countBankerProjects.get(mapEmployeeId_Title.get(eId)) != null)
                        countDealsBankers = mapLM_SBankerTitle_countBankerProjects.get(mapEmployeeId_Title.get(eId));                    
                    count_MDBanker = mapSBankerTitle_countSBankers.get(mapEmployeeId_Title.get(eId));
                    mapLM_SBankerTitle_averagePitches.put(mapEmployeeId_Title.get(eId),(count_MDBanker != 0 ? countDealsBankers / count_MDBanker : 0) );
                }
                
            }
            
            if(mapBankerIdToTitle.values().size() > 0)
            {
                for(Id eId : mapBankerIdToTitle.keySet())
                {
                    if(!mapAF_SBankerTitle_sumAverageFees.containsKey(mapBankerIdToTitle.get(eId)))
                        mapAF_SBankerTitle_sumAverageFees.put(mapBankerIdToTitle.get(eId), 0);
                    if(mapBankerIdToAvgAF.containsKey(eId) && mapBankerIdToAvgAF.get(eId) != null)
                    {
                        mapAF_SBankerTitle_sumAverageFees.put(mapBankerIdToTitle.get(eId), mapAF_SBankerTitle_sumAverageFees.get(mapBankerIdToTitle.get(eId)) + mapBankerIdToAvgAF.get(eId));
                    }
                }
    
                for(Id eId : mapEmployeeId_Title.keySet())
                {
                    countDealsBankers = 0;
                    count_MDBanker = 0;

                    if( mapAF_SBankerTitle_sumAverageFees.get(mapEmployeeId_Title.get(eId)) != null     )   
                        countDealsBankers = mapAF_SBankerTitle_sumAverageFees.get(mapEmployeeId_Title.get(eId));
                    /*MBS-56*/
                    count_MDBanker = mapSBankerTitle_countSBankers.get(mapEmployeeId_Title.get(eId));
                    mapAF_SBankerTitle_averageEFees.put(mapEmployeeId_Title.get(eId), (count_MDBanker != 0 ? countDealsBankers / count_MDBanker : 0));
                }
                system.debug('mapAF_SBankerTitle_averageEFees = '+mapAF_SBankerTitle_averageEFees);
            }
            
            ////Weighted Pipeline and YTD Fee Invoice average
            Map<String,Decimal> mapWP_SBankerTitle_averagePAR = new map<String,Decimal>();
            Map<String,Decimal> mapWP_SBankerTitle_averageYTDFeeInvoice = new map<String,Decimal>();
            Map<String, Decimal> mapNP_SBankerTitle_averageNetPipeline = new Map<String, Decimal>();
            if(mapEmployeeId_Title.values().size() > 0)
            {
                for(String srtTitle : mapSBankerTitle_setSBankerIds.keySet())
                {
                    if(mapBankerTitleToSumOfPAR.containsKey(srtTitle))
                    {
                        mapWP_SBankerTitle_averagePAR.put(srtTitle,mapBankerTitleToSumOfPAR.get(srtTitle)/mapSBankerTitle_setSBankerIds.get(srtTitle).size());
                    }
                    if(mapBankerTitleToSumOfFeeRevenue.containsKey(srtTitle))
                    {
                        mapNP_SBankerTitle_averageNetPipeline.put(srtTitle, mapBankerTitleToSumOfFeeRevenue.get(srtTitle)/mapSBankerTitle_setSBankerIds.get(srtTitle).size());
                    }
                }
                // Potential new way to get this average YTD invoice fees.
                
                //Get a list of all the invoices for all projects that meet our requirements for bankers.
                List<IBanking_Project__c> listProjects = 
                    [SELECT Id, Expense_Code__c,
                     (SELECT Title__c FROM Project_Resources__r
                                      WHERE Title__c IN: mapSBankerTitle_setSBankerIds.KeySet() AND
                                            Banker__r.Status__c = 'Active' AND
                                            Banker__r.Group__c NOT IN :listExcludeGroups AND
                                            Status__c = 'Active'
                       ) titles,
                     (SELECT Id, convertCurrency(Fees_Invoiced_mm__c)
                                              FROM Invoices__r 
                                              WHERE Invoice_Date__c  = THIS_YEAR AND
                                                    //Invoice_Date__c >= :curStartDate AND Invoice_Date__c < :curEndDate AND
                                                    Fees_Invoiced__c != 0.0
                       ) invoiceAmounts
                     FROM IBanking_Project__c 
                     WHERE 
                        Id in (SELECT project__c FROM Project_Resource__c 
                                          WHERE Banker__r.Title__c IN:mapSBankerTitle_setSBankerIds.KeySet() AND
                                                Banker__r.Status__c = 'Active' AND
                                                Banker__r.Group__c NOT IN :listExcludeGroups AND
                                                Status__c = 'Active'
                        ) AND
                        Latest_Invoice_Date__c = THIS_YEAR AND
                        //Latest_Invoice_Date__c >= :curStartDate AND Latest_Invoice_Date__c < :curEndDate AND
                        Total_Invoice_Fees__c != 0.0];
                
                Integer saCounter= 0;
                // Map for holding the total project invoice fees by title.
                Map<string,decimal> map_Title_TotProjInvFees = new Map<String,Decimal>();
                for(Ibanking_project__c proj: listProjects)
                {
                    Decimal totalProjInvoices = 0.0;
                    for(Invoice__c invoice : proj.Invoices__r)
                    {
                        totalProjInvoices += invoice.Fees_Invoiced_mm__c;
                    }
                    
                    for(Project_Resource__c res: proj.Project_Resources__r)
                    {
                        if(!map_Title_TotProjInvFees.containsKey(res.Title__c))
                        {
                            map_Title_TotProjInvFees.put(res.Title__c,0.0);
                        }
                        map_Title_TotProjInvFees.put(res.Title__c,map_Title_TotProjInvFees.get(res.Title__c) + totalProjInvoices);
                    }
                }
                for(String strTitle : mapSBankerTitle_setSBankerIds.KeySet())
                {
                    if(map_Title_TotProjInvFees.containskey(strTitle))
                        mapWP_SBankerTitle_averageYTDFeeInvoice.put(strTitle, map_Title_TotProjInvFees.get(strTitle)/mapSBankerTitle_setSBankerIds.get(strTitle).size());
                }          
            }
            
            //Senior Banker Scorecard Detailed â€“ Current Pipeline Section
            Decimal total_Invoice_Fees_YTD = 0;
            Decimal total_Invoice_Expenses_YTD = 0;
            map<Id,list<FeesInvoiced>> mapEmployeeId_FeesInvoiceds_CPS = new map<Id,list<FeesInvoiced>>();
            map<Id,Decimal> mapEmployeeId_grandTotalFeeYTD_CPS = new map<Id,Decimal>();
            map<Id,Decimal> mapEmployeeId_grandTotalExpansesYTD_CPS = new map<Id,Decimal>();
            map<Id,Decimal> mapEmployeeId_grandTotalFeeRevenue_CPS = new map<Id,Decimal>();
            map<Id,Decimal> mapEmployeeId_grandTotalPARevenue_CPS = new map<Id,Decimal>();
            /*Start :MBS-93*/
            map<Id,Decimal> mapEmployeeId_grandTotalNetEstFeeRevenue = new map<Id,Decimal>();
            /*End : MBS-93*/
            
            /*Start : MBS-95 */
            map<Id,Decimal> mapEmployeeId_subTotalFeeYTD_CYP_CPS      = new map<Id,Decimal>();
            map<Id,Decimal> mapEmployeeId_subTotalExpansesYTD_CYP_CPS = new map<Id,Decimal>();
            map<Id,Decimal> mapEmployeeId_subTotalFeeRevenue_CYP_CPS  = new map<Id,Decimal>(); 
            map<Id,Decimal> mapEmployeeId_subTotalPARevenue_CYP_CPS   = new map<Id,Decimal>(); 
            map<Id,Decimal> mapEmployeeId_subTotalNetEstFeeRev_CYP    = new map<Id,Decimal>(); 
                
          
            map<Id,Decimal> mapEmployeeId_subTotalFeeYTD_FP_CPS       = new map<Id,Decimal>();
            map<Id,Decimal> mapEmployeeId_subTotalExpansesYTD_FP_CPS  = new map<Id,Decimal>();
            map<Id,Decimal> mapEmployeeId_subTotalFeeRevenue_FP_CPS   = new map<Id,Decimal>();
            map<Id,Decimal> mapEmployeeId_subTotalPARevenue_FP_CPS    = new map<Id,Decimal>();
            map<Id,Decimal> mapEmployeeId_subTotalNetEstFeeRev_FP     = new map<Id,Decimal>();
            /*End : MBS-95*/
            
            map<Id,String> mapProjectIdToCSBankers = new map<Id,String>();
            map<String, Decimal> map_Title_TotAvgFee = new map<String,Decimal>();
            String prMoelisRoles = '';
            map<Id,String> mapBanker_MoelisRoles = new map<Id,String>();
            map<Id,Set<Id>> mapEmpIdToSetProjectId = new map<Id, Set<Id>>();
            
            if(setEmployeeIdProjectIds.size() > 0)
            {
                for(Ibanking_Project__c item : [
                            SELECT  Client__c,Client__r.Name, Name, RecordType.Name, Expense_Code__c,convertCurrency(Total_Invoice_Fees_mm__c),
                            		convertCurrency(Est_Transaction_Size__c), /*Moelis_Role__c,Moelis_Roles__c,*/ 
                            		Stage__c, convertCurrency(Estimated_Fee_Revenue__c), Expected_Close_Date__c, Revenue_Probability__c,
                            		convertCurrency(Probability_Adjusted_Revenue__c),
                                    convertCurrency(Net_Est_Fee_Revenue_mm__c),
                                    (Select Invoice_Date__c, convertCurrency(Expenses_Invoiced_mm__c),  convertCurrency(Fees_Invoiced_mm__c) From Invoices__r WHERE Invoice_Date__c = THIS_YEAR  AND Invoice_Date__c <= TODAY),
                                    (Select Id, Status__c, Role__c, Banker__c, Banker__r.Name, Banker__r.Status__c, Banker__r.Title__c, Banker__r.First_Name__c, Banker__r.Last_Name__c From Project_Resources__r ORDER BY Banker__r.Title__c ASC,Banker__r.Last_Name__c ASC)
                            FROM Ibanking_Project__c
                            WHERE   Include_in_Pipeline__c = true AND
                                    ID IN : setEmployeeIdProjectIds
                            ORDER BY Client__r.Name ASC])
                {
                    total_Invoice_Fees_YTD = total_Invoice_Expenses_YTD = 0;
                    for (Invoice__c inv : item.Invoices__r) 
                    {
                        if(inv.Fees_Invoiced_mm__c != null)    total_Invoice_Fees_YTD = total_Invoice_Fees_YTD + inv.Fees_Invoiced_mm__c;
                        if(inv.Expenses_Invoiced_mm__c != null)    total_Invoice_Expenses_YTD = total_Invoice_Expenses_YTD + inv.Expenses_Invoiced_mm__c;
                    }
                    mapBanker_MoelisRoles = new map<Id,String>();
                    String srtBankerName = '';
                    for (Project_Resource__c pr : item.Project_Resources__r) 
                    {
                        /* Added by Lodhi as per MBS-77*/
                        if(pr.Status__c == 'Active' && pr.Banker__r.Status__c == 'Active' && listMDSCTitles.contains(pr.Banker__r.Title__c))
                        {
                            srtBankerName += (pr.Banker__r.First_Name__c != null)? pr.Banker__r.First_Name__c.substring(0,1)+'. '+pr.Banker__r.Last_Name__c +', ' : pr.Banker__r.Last_Name__c +', ';
                        }
                            
                        if(pr.Role__c != null && pr.Banker__c != null)  
                            mapBanker_MoelisRoles.put(pr.Banker__c,pr.Role__c);
                    }
                    
                    if(srtBankerName != null && srtBankerName != '' && srtBankerName.length() > 2)
                        srtBankerName = srtBankerName.substring(0,srtBankerName.length()-2);
                        
                    mapProjectIdToCSBankers.put(item.Id, srtBankerName);
                    if(setEmployeeIdProjectIds.contains(item.Id) && mapEmployeeId_setProjectIds.keySet().size()>0)
                    {
                        for(Id eId : mapEmployeeId_setProjectIds.keySet())
                        {
                            if(mapEmployeeId_setProjectIds.get(eId).contains(item.Id))
                            {
                                if(!mapEmployeeId_FeesInvoiceds_CPS.keySet().contains(eId)) mapEmployeeId_FeesInvoiceds_CPS.put(eId, new list<FeesInvoiced>());
                                mapEmployeeId_FeesInvoiceds_CPS.get(eId).add(new FeesInvoiced(
                                                                                (item.Client__r.Name!=null?item.Client__r.Name:''),
                                                                                item.Name,
                                                                                item.Expense_Code__c,
                                                                                item.RecordType.Name, 
                                                                                (mapBanker_MoelisRoles.get(eId) != null ? mapBanker_MoelisRoles.get(eId) : ''),
                                                                                item.Stage__c,
                                                                                item.Est_Transaction_Size__c,
                                                                                item.Estimated_Fee_Revenue__c,
                                                                                item.Total_Invoice_Fees_mm__c,
                                                                                total_Invoice_Fees_YTD,
                                                                                total_Invoice_Expenses_YTD,
                                                                                item.Expected_Close_Date__c,
                                                                                item.Revenue_Probability__c,
                                                                                item.Probability_Adjusted_Revenue__c,
                                                                                mapProjectIdToCSBankers.get(item.Id),
                                                                                item.Net_Est_Fee_Revenue_mm__c
                                                                                ));
                                        
                                if(!mapEmpIdToSetProjectId.containsKey(eId) && item.Revenue_Probability__c != null) 
                                {
                                    mapEmpIdToSetProjectId.put(eId,new Set<Id>{item.Id});
                                }
                                else if(item.Revenue_Probability__c != null)
                                {
                                    mapEmpIdToSetProjectId.get(eId).add(item.Id);
                                }
                                                                        
                                if(!mapEmployeeId_grandTotalFeeYTD_CPS.keySet().contains(eId))    
                                    mapEmployeeId_grandTotalFeeYTD_CPS.put(eId, 0);
                                mapEmployeeId_grandTotalFeeYTD_CPS.put(eId, mapEmployeeId_grandTotalFeeYTD_CPS.get(eId) + total_Invoice_Fees_YTD);
                                
                                if(!mapEmployeeId_grandTotalExpansesYTD_CPS.keySet().contains(eId))   
                                    mapEmployeeId_grandTotalExpansesYTD_CPS.put(eId, 0);
                                mapEmployeeId_grandTotalExpansesYTD_CPS.put(eId, mapEmployeeId_grandTotalExpansesYTD_CPS.get(eId) + total_Invoice_Expenses_YTD);
                                
                                if(!mapEmployeeId_grandTotalFeeRevenue_CPS.keySet().contains(eId))    
                                    mapEmployeeId_grandTotalFeeRevenue_CPS.put(eId, 0);
                                mapEmployeeId_grandTotalFeeRevenue_CPS.put(eId, mapEmployeeId_grandTotalFeeRevenue_CPS.get(eId) + (item.Estimated_Fee_Revenue__c != null ? item.Estimated_Fee_Revenue__c : 0 ));
                                
                                if(!mapEmployeeId_grandTotalPARevenue_CPS.keySet().contains(eId))    
                                    mapEmployeeId_grandTotalPARevenue_CPS.put(eId, 0);
                                mapEmployeeId_grandTotalPARevenue_CPS.put(eId, mapEmployeeId_grandTotalPARevenue_CPS.get(eId) + (item.Probability_Adjusted_Revenue__c != null ? item.Probability_Adjusted_Revenue__c : 0 ));
                             
                                if(!mapEmployeeId_grandTotalNetEstFeeRevenue.keySet().contains(eId))    
                                    mapEmployeeId_grandTotalNetEstFeeRevenue.put(eId, 0);
                                mapEmployeeId_grandTotalNetEstFeeRevenue.put(eId, mapEmployeeId_grandTotalNetEstFeeRevenue.get(eId) + (item.Net_Est_Fee_Revenue_mm__c != null ? item.Net_Est_Fee_Revenue_mm__c : 0 ));
                                
                                String expectedCloseDate = String.valueOf(item.Expected_Close_Date__c); 
                                if(expectedCloseDate != null && expectedCloseDate.length() > 4)
                                {
                                    Integer year = Integer.valueOf(expectedCloseDate.subString(expectedCloseDate.indexOf('2') , 4));
                                    if(year == Date.today().year())
                                    {
                                        if(!mapEmployeeId_subTotalFeeYTD_CYP_CPS.keySet().contains(eId))    
                                            mapEmployeeId_subTotalFeeYTD_CYP_CPS.put(eId, 0);
                                        mapEmployeeId_subTotalFeeYTD_CYP_CPS.put(eId, mapEmployeeId_subTotalFeeYTD_CYP_CPS.get(eId) + total_Invoice_Fees_YTD);
                                        
                                        if(!mapEmployeeId_subTotalExpansesYTD_CYP_CPS.keySet().contains(eId))   
                                            mapEmployeeId_subTotalExpansesYTD_CYP_CPS.put(eId, 0);
                                        mapEmployeeId_subTotalExpansesYTD_CYP_CPS.put(eId, mapEmployeeId_subTotalExpansesYTD_CYP_CPS.get(eId) + total_Invoice_Expenses_YTD);
                                        
                                        if(!mapEmployeeId_subTotalFeeRevenue_CYP_CPS.keySet().contains(eId))    
                                            mapEmployeeId_subTotalFeeRevenue_CYP_CPS.put(eId, 0);
                                        mapEmployeeId_subTotalFeeRevenue_CYP_CPS.put(eId, mapEmployeeId_subTotalFeeRevenue_CYP_CPS.get(eId) + (item.Estimated_Fee_Revenue__c != null ? item.Estimated_Fee_Revenue__c : 0 ));
                                        
                                        if(!mapEmployeeId_subTotalPARevenue_CYP_CPS.keySet().contains(eId))    
                                            mapEmployeeId_subTotalPARevenue_CYP_CPS.put(eId, 0);
                                        mapEmployeeId_subTotalPARevenue_CYP_CPS.put(eId, mapEmployeeId_subTotalPARevenue_CYP_CPS.get(eId) + (item.Probability_Adjusted_Revenue__c != null ? item.Probability_Adjusted_Revenue__c : 0 ));
                                    
                                        if(!mapEmployeeId_subTotalNetEstFeeRev_CYP.keySet().contains(eId))    
                                            mapEmployeeId_subTotalNetEstFeeRev_CYP.put(eId, 0);
                                        mapEmployeeId_subTotalNetEstFeeRev_CYP.put(eId, mapEmployeeId_subTotalNetEstFeeRev_CYP.get(eId) + (item.Net_Est_Fee_Revenue_mm__c != null ? item.Net_Est_Fee_Revenue_mm__c : 0 ));
                                    
                                    }       
                                    else
                                    {
                                        if(!mapEmployeeId_subTotalFeeYTD_FP_CPS.keySet().contains(eId))    
                                            mapEmployeeId_subTotalFeeYTD_FP_CPS.put(eId, 0);
                                        mapEmployeeId_subTotalFeeYTD_FP_CPS.put(eId, mapEmployeeId_subTotalFeeYTD_FP_CPS.get(eId) + total_Invoice_Fees_YTD);
                                        
                                        if(!mapEmployeeId_subTotalExpansesYTD_FP_CPS.keySet().contains(eId))   
                                            mapEmployeeId_subTotalExpansesYTD_FP_CPS.put(eId, 0);
                                        mapEmployeeId_subTotalExpansesYTD_FP_CPS.put(eId, mapEmployeeId_subTotalExpansesYTD_FP_CPS.get(eId) + total_Invoice_Expenses_YTD);
                                        
                                        if(!mapEmployeeId_subTotalFeeRevenue_FP_CPS.keySet().contains(eId))    
                                            mapEmployeeId_subTotalFeeRevenue_FP_CPS.put(eId, 0);
                                        mapEmployeeId_subTotalFeeRevenue_FP_CPS.put(eId, mapEmployeeId_subTotalFeeRevenue_FP_CPS.get(eId) + (item.Estimated_Fee_Revenue__c != null ? item.Estimated_Fee_Revenue__c : 0 ));
                                        
                                        if(!mapEmployeeId_subTotalPARevenue_FP_CPS.keySet().contains(eId))    
                                            mapEmployeeId_subTotalPARevenue_FP_CPS.put(eId, 0);
                                        mapEmployeeId_subTotalPARevenue_FP_CPS.put(eId, mapEmployeeId_subTotalPARevenue_FP_CPS.get(eId) + (item.Probability_Adjusted_Revenue__c != null ? item.Probability_Adjusted_Revenue__c : 0 ));
                                    
                                        if(!mapEmployeeId_subTotalNetEstFeeRev_FP.keySet().contains(eId))    
                                            mapEmployeeId_subTotalNetEstFeeRev_FP.put(eId, 0);
                                        mapEmployeeId_subTotalNetEstFeeRev_FP.put(eId, mapEmployeeId_subTotalNetEstFeeRev_FP.get(eId) + (item.Net_Est_Fee_Revenue_mm__c != null ? item.Net_Est_Fee_Revenue_mm__c : 0 ));
                                    }
                                }
                            }
                        }
                    }
                }
                //system.debug('mapEmployeeId_FeesInvoiceds_CPS = '+mapEmployeeId_FeesInvoiceds_CPS);
            }   
            
           
            map<Id,Decimal> mapWP_EmployeeId_sumPAR = new map<Id,Decimal>();
            if(mapEmployeeId_Title.values().size() > 0)
            {
                for(Id empId : mapEmpIdToSetProjectId.keySet())
                {
                    //WeightPipeline///////////////////////////////////////////////////
                    if(mapEmployeeId_grandTotalPARevenue_CPS.containsKey(empId))
                    {
                        mapWP_EmployeeId_sumPAR.put(empId, mapEmployeeId_grandTotalPARevenue_CPS.get(empId));
                    }
                     //AverageFee///////////////////////////////////////////////////
                    if(mapEmployeeId_grandTotalFeeRevenue_CPS.containsKey(empId))
                    {
                        mapAF_EmployeeId_countEFees.put(empId,mapEmployeeId_grandTotalFeeRevenue_CPS.get(empId));
                    }
                }
            }
            
            //Senior Banker Scorecard Detailed â€“ Other Fees Invoiced Section
            //Other YTD Fees Invoiced (MBS-24)
            map<Id,list<FeesInvoiced>> mapEmployeeId_FeesInvoiceds_OFI = new map<Id,list<FeesInvoiced>>();
            map<Id,Decimal> mapEmployeeId_subtotalFeeYTD_OFI= new map<Id,Decimal>();
            map<Id,Decimal> mapEmployeeId_subtotalExpansesYTD_OFI = new map<Id,Decimal>();
            map<Id,Decimal> mapEmployeeId_subtotalFeeRevenue_OFI = new map<Id,Decimal>();
            mapProjectIdToCSBankers = new Map<Id,String>();
            if(setEmployeeIdProjectIds.size() > 0)
            {
                for(Ibanking_Project__c item : [
                            SELECT  Name,Client__c,Client__r.Name, RecordType.Name, convertCurrency(Est_Transaction_Size__c), convertCurrency(Total_Invoice_Fees_mm__c), 
                            		Expense_Code__c, Stage__c, convertCurrency(Estimated_Fee_Revenue__c), Expected_Close_Date__c, Revenue_Probability__c, convertCurrency(Net_Est_Fee_Revenue_mm__c),
                                    (Select Invoice_Date__c, convertCurrency(Expenses_Invoiced_mm__c),  convertCurrency(Fees_Invoiced_mm__c) From Invoices__r WHERE Invoice_Date__c = THIS_YEAR  AND Invoice_Date__c <= TODAY),
                                    (Select Id, Status__c, Role__c, Banker__c, Banker__r.Name, Banker__r.Status__c, Banker__r.Title__c, Banker__r.First_Name__c, Banker__r.Last_Name__c From Project_Resources__r ORDER BY Banker__r.Title__c ASC,Banker__r.Last_Name__c ASC)
                            FROM Ibanking_Project__c
                            WHERE   MDSC_isOther__c = 1 AND
                                    Latest_Invoice_Date__c = THIS_YEAR  
                                    AND Latest_Invoice_Date__c <= TODAY AND 
                                    ID IN : setEmployeeIdProjectIds
                            ORDER BY Client__r.Name ASC])
                {
                    total_Invoice_Fees_YTD = total_Invoice_Expenses_YTD = 0;
                    for (Invoice__c inv : item.Invoices__r) 
                    {
                        if(inv.Fees_Invoiced_mm__c != null)    total_Invoice_Fees_YTD = total_Invoice_Fees_YTD + inv.Fees_Invoiced_mm__c;
                        if(inv.Expenses_Invoiced_mm__c != null)    total_Invoice_Expenses_YTD = total_Invoice_Expenses_YTD + inv.Expenses_Invoiced_mm__c;
                    }
                    mapBanker_MoelisRoles = new map<Id,String>();
                    String srtBankerName = '';
                    for (Project_Resource__c pr : item.Project_Resources__r) 
                    {
                        /* Added by Lodhi as per MBS-78*/
                        if(pr.Status__c == 'Active' && pr.Banker__r.Status__c == 'Active' && listMDSCTitles.contains(pr.Banker__r.Title__c))
                            srtBankerName += (pr.Banker__r.First_Name__c != null)? pr.Banker__r.First_Name__c.substring(0,1)+'. '+pr.Banker__r.Last_Name__c +', ' : pr.Banker__r.Last_Name__c +', ';
                        if(pr.Role__c != null && pr.Banker__c != null)  mapBanker_MoelisRoles.put(pr.Banker__c,pr.Role__c);
                    }
                    
                    if(srtBankerName != null && srtBankerName != '' && srtBankerName.length() > 2)
                        srtBankerName = srtBankerName.substring(0,srtBankerName.length()-2);
                        
                    mapProjectIdToCSBankers.put(item.Id, srtBankerName);
                    
                    if(setEmployeeIdProjectIds.contains(item.Id) && mapEmployeeId_setProjectIds.keySet().size()>0)
                    {
                        for(Id eId : mapEmployeeId_setProjectIds.keySet())
                        {
                            if(mapEmployeeId_setProjectIds.get(eId).contains(item.Id))
                            {
                                if(!mapEmployeeId_FeesInvoiceds_OFI.keySet().contains(eId)) mapEmployeeId_FeesInvoiceds_OFI.put(eId, new list<FeesInvoiced>());
                                mapEmployeeId_FeesInvoiceds_OFI.get(eId).add(new FeesInvoiced
                                                                             ((item.Client__r.Name!=null?item.Client__r.Name:''),item.Name,item.Expense_Code__c,
                                                                             item.RecordType.Name,(mapBanker_MoelisRoles.get(eId) != null ? mapBanker_MoelisRoles.get(eId) : ''),
                                                                             item.Stage__c,item.Est_Transaction_Size__c,item.Estimated_Fee_Revenue__c,item.Total_Invoice_Fees_mm__c,
                                                                             total_Invoice_Fees_YTD,total_Invoice_Expenses_YTD,item.Expected_Close_Date__c,
                                                                             item.Revenue_Probability__c, null,mapProjectIdToCSBankers.get(item.Id),item.Net_Est_Fee_Revenue_mm__c));
                                
                                if(!mapEmployeeId_subtotalFeeYTD_OFI.keySet().contains(eId))    mapEmployeeId_subtotalFeeYTD_OFI.put(eId, 0);
                                mapEmployeeId_subtotalFeeYTD_OFI.put(eId, mapEmployeeId_subtotalFeeYTD_OFI.get(eId) + total_Invoice_Fees_YTD);
                                
                                if(!mapEmployeeId_subtotalExpansesYTD_OFI.keySet().contains(eId))   mapEmployeeId_subtotalExpansesYTD_OFI.put(eId, 0);
                                mapEmployeeId_subtotalExpansesYTD_OFI.put(eId, mapEmployeeId_subtotalExpansesYTD_OFI.get(eId) + total_Invoice_Expenses_YTD);
                                
                                if(!mapEmployeeId_subtotalFeeRevenue_OFI.keySet().contains(eId))    mapEmployeeId_subtotalFeeRevenue_OFI.put(eId, 0);
                                mapEmployeeId_subtotalFeeRevenue_OFI.put(eId, mapEmployeeId_subtotalFeeRevenue_OFI.get(eId) + (item.Estimated_Fee_Revenue__c != null ? item.Estimated_Fee_Revenue__c : 0 ));
                            }
                        }
                    }
                }
            }   
            
            //Senior Banker Scorecard Detailed â€“ â€œNear Term Transactionsâ€ Section
            map<Id,list<NearTermTransactions>> mapEmployeeId_NearTermTransactions = new map<Id,list<NearTermTransactions>>();
            List<Id> lstAccountIdToNTT = new List<Id>();
            if(mapEmployeeId_Employee.keySet().size() > 0)
            {
                map<Id,list<Company_List_Member__c>> mapEmployeeId_CompanyListMembers = new map<Id,list<Company_List_Member__c>>();
                
                map<Id, set<Id>> mapEmployeeId_setAccountIds = new map<Id, set<Id>>();
                map<Id, map<Id, set<Id>>> mapEmployeeId_mapAccountId_setEventIds = new map<Id, map<Id, set<Id>>>();
                map<Id, map<Id, set<Id>>> mapEmployeeId_mapAccountId_setEventIds_YTD = new map<Id, map<Id, set<Id>>>();
                
                set<Id> listAccountIds = new set<Id>();
                map<Id,set<Id>> map_accontId_setContactIds = new map<Id,set<Id>>();
        
                for(Company_List_Member__c item : [
                        SELECT Company__r.Name,Company__c, Date__c,Expected_Timing__c, Target_Status__c, Tier__c, Deal_Type__c, Description__c, Company_List__c, Company_List__r.OwnerId, 
                               Company_List__r.Banker_Name__c, Senior_Assistance__c, Project_Name__r.Name, Project_Name__c, Project_Code__c, 
                               Product_Assistance__c, Moelis_Probability__c, Industry_Assistance__c, convertCurrency(Est_Transaction_Size_mm__c),convertCurrency(Est_Fee_Revenue_mm__c), Deal_Probability__c 
                        FROM Company_List_Member__c
                        WHERE   Company_List__r.Banker_Name__c  IN : mapEmployeeId_Employee.keySet() AND
                                Company_List__r.Status__c = 'Active' AND 
                                Company_List__r.Type__c = 'Near-Term Transaction List'
                        ORDER BY Company__r.Name ASC])
                {
                    if(item.Company__c != null && item.Company_List__r.Banker_Name__c != null)
                    {
                        if(!mapEmployeeId_CompanyListMembers.keySet().contains(item.Company__c)) 
                        {
                            mapEmployeeId_CompanyListMembers.put(item.Company__c,new list<Company_List_Member__c>());
                            lstAccountIdToNTT.add(item.Company__c);
                        }
                        mapEmployeeId_CompanyListMembers.get(item.Company__c).add(item);
                        
                        if(!mapEmployeeId_mapAccountId_setEventIds.keySet().contains(item.Company_List__r.Banker_Name__c )) 
                            mapEmployeeId_mapAccountId_setEventIds.put(item.Company_List__r.Banker_Name__c, new map<Id, set<Id>>());
                            
                        if(!mapEmployeeId_mapAccountId_setEventIds.get(item.Company_List__r.Banker_Name__c).keySet().contains(item.Company__c)) 
                            mapEmployeeId_mapAccountId_setEventIds.get(item.Company_List__r.Banker_Name__c).put(item.Company__c, new set<Id>());
                            
                        if(!mapEmployeeId_mapAccountId_setEventIds_YTD.keySet().contains(item.Company_List__r.Banker_Name__c )) 
                            mapEmployeeId_mapAccountId_setEventIds_YTD.put(item.Company_List__r.Banker_Name__c, new map<Id, set<Id>>());
                            
                        if(!mapEmployeeId_mapAccountId_setEventIds_YTD.get(item.Company_List__r.Banker_Name__c).keySet().contains(item.Company__c)) 
                            mapEmployeeId_mapAccountId_setEventIds_YTD.get(item.Company_List__r.Banker_Name__c).put(item.Company__c, new set<Id>());
                            
                        if(!map_accontId_setContactIds.keySet().contains(item.Company__c))  
                            map_accontId_setContactIds.put(item.Company__c, new set<Id>());
                            
                        listAccountIds.add(item.Company__c);
                    }
                }
                
                if(mapEmployeeId_CompanyListMembers.keySet().size() > 0)
                {
                    for(Id EmployeeId: lstAccountIdToNTT)
                    {
                        if(mapEmployeeId_CompanyListMembers.containsKey(EmployeeId) && mapEmployeeId_CompanyListMembers.get(EmployeeId) != null)
                        {
                            for(Company_List_Member__c item : mapEmployeeId_CompanyListMembers.get(EmployeeId))
                            {
                                if(!mapEmployeeId_NearTermTransactions.keySet().contains(item.Company_List__r.Banker_Name__c))    mapEmployeeId_NearTermTransactions.put(item.Company_List__r.Banker_Name__c, new list<NearTermTransactions>());
                                mapEmployeeId_NearTermTransactions.get(item.Company_List__r.Banker_Name__c).add(
                                                                    new NearTermTransactions(
                                                                            item.Company__r.Name,
                                                                            item.Date__c,
                                                                            item.Tier__c,
                                                                            item.Deal_Type__c,
                                                                            (   mapEmployeeId_mapAccountId_setEventIds.get(item.Company_List__r.Banker_Name__c) != null && 
                                                                                mapEmployeeId_mapAccountId_setEventIds.get(item.Company_List__r.Banker_Name__c).get(item.Company__c) != null 
                                                                                ?
                                                                                mapEmployeeId_mapAccountId_setEventIds.get(item.Company_List__r.Banker_Name__c).get(item.Company__c).size() 
                                                                                : 
                                                                                0
                                                                            ),
                                                                            (   mapEmployeeId_mapAccountId_setEventIds_YTD.get(item.Company_List__r.Banker_Name__c) != null && 
                                                                                mapEmployeeId_mapAccountId_setEventIds_YTD.get(item.Company_List__r.Banker_Name__c).get(item.Company__c) != null 
                                                                                ?
                                                                                mapEmployeeId_mapAccountId_setEventIds_YTD.get(item.Company_List__r.Banker_Name__c).get(item.Company__c).size() 
                                                                                : 
                                                                                0
                                                                            ),
                                                                            item.Description__c,
                                                                            item.Project_Name__r.Name, item.Project_Code__c ,item.Est_Transaction_Size_mm__c, 
                                                                            item.Est_Fee_Revenue_mm__c, item.Deal_Probability__c, item.Moelis_Probability__c, item.Expected_Timing__c,item.Target_Status__c, 
                                                                            item.Senior_Assistance__c, item.Product_Assistance__c, item.Industry_Assistance__c));
                            }
                        }
                    }
                }
                system.debug('mapEmployeeId_NearTermTransactions = '+mapEmployeeId_NearTermTransactions);
            }
            
            
            
            //Senior Banker Scorecard Detailed â€“ â€œPitches YTDâ€ Section
            map<Id,list<PitchesYTD>> mapEmployeeId_PitchesYTD = new map<Id,list<PitchesYTD>>();
            if(setEmployeeIdProjectIds.size() > 0)
            {
                for(Ibanking_Project__c item: [
                                SELECT  Id, Client__r.Name, Expense_Code__c, Moelis_Roles__c, RecordType.Name, convertCurrency(Estimated_Fee_Revenue__c), Stage__c, Reason__c, 
                                        Expected_Close_Date__c, convertCurrency(Probability_Adjusted_Revenue__c),Name, Pitch_Date__c, convertCurrency(Est_Transaction_Size__c),
                                        (Select Id, Status__c, Role__c, Banker__c, Banker__r.Name, Banker__r.Status__c, Banker__r.Title__c, Banker__r.First_Name__c, Banker__r.Last_Name__c From Project_Resources__r ORDER BY Banker__r.Title__c ASC,Banker__r.Last_Name__c ASC)
                                FROM Ibanking_Project__c
                                WHERE   /*MBS-39
                                        MDSC_isPipeline__c = 1 AND 
                                        /*MBS-31
                                        Latest_Invoice_Date__c = THIS_YEAR  AND Latest_Invoice_Date__c <= TODAY AND */
                                        
                                        /* Updated by Lodhi as per MBS-80*/
                                        Pitch_Date__c  = THIS_YEAR  AND Pitch_Date__c <= TODAY AND
                                        ID IN : setEmployeeIdProjectIds  ORDER BY Client__r.Name ASC])
                {
                    strAttendees = '';
                    mapBanker_MoelisRoles = new map<Id,String>();
                    if(item.Project_Resources__r != null && item.Project_Resources__r.size() > 0)
                    {
                        for (Project_Resource__c pr : item.Project_Resources__r) 
                        {
                            /* Added by Lodhi as per MBS-77*/
                            if(pr.Status__c == 'Active' && pr.Banker__r.Status__c == 'Active' && listMDSCTitles.contains(pr.Banker__r.Title__c))
                            {
                                if(pr.Banker__r.Name != null)
                                {
                                    if(strAttendees.length() == 0)  strAttendees = (pr.Banker__r.First_Name__c != null)? pr.Banker__r.First_Name__c.substring(0,1)+'. '+pr.Banker__r.Last_Name__c  : pr.Banker__r.Last_Name__c;
                                    else strAttendees += (pr.Banker__r.First_Name__c != null)? ', ' + pr.Banker__r.First_Name__c.substring(0,1)+'. '+pr.Banker__r.Last_Name__c  : ', ' + pr.Banker__r.Last_Name__c;
                                }
                            }
                            if(pr.Role__c != null && pr.Banker__c != null)  mapBanker_MoelisRoles.put(pr.Banker__c,pr.Role__c);
                        }
                    }
                    if(setEmployeeIdProjectIds.contains(item.Id) && mapEmployeeId_setProjectIds.keySet().size()>0)
                    {
                        for(Id eId : mapEmployeeId_setProjectIds.keySet())
                        {
                            if(mapEmployeeId_setProjectIds.get(eId).contains(item.Id))
                            {
                                if(!mapEmployeeId_PitchesYTD.keySet().contains(eId))    mapEmployeeId_PitchesYTD.put(eId, new list<PitchesYTD>());
                                mapEmployeeId_PitchesYTD.get(eId).add(new PitchesYTD(item.Client__r.Name,item.Expense_Code__c,(mapBanker_MoelisRoles.get(eId) != null ? mapBanker_MoelisRoles.get(eId) : ''),
                                                                                     item.RecordType.Name,strAttendees,item.Estimated_Fee_Revenue__c,item.Stage__c,item.Reason__c,
                                                                                     item.Probability_Adjusted_Revenue__c,item.Name, item.Pitch_Date__c, item.Est_Transaction_Size__c, item.Expected_Close_Date__c));
                            }
                        }
                    }
                }
            }
            
            //Resource Utilization//////////////////////////////////////////////////////////////////
            list<MDSC_Exclude_NonDealProjects__c> listMDSCExcludeNonDealProjects = MDSC_Exclude_NonDealProjects__c.getall().values();
            set<String> MDSCExcludeNonDealProjects = new set<String>();
            for(MDSC_Exclude_NonDealProjects__c item : listMDSCExcludeNonDealProjects)  MDSCExcludeNonDealProjects.add(item.Name);
            //Resource Utilization Current Period - Summary///////
            //Resource Utilization YTD - Summary///////
            map<id,Decimal> mapEmployeeId_sumDealHours = new map<id,Decimal>();
            map<id,Decimal> mapYTD_EmployeeId_sumDealHours = new map<id,Decimal>();
            
            map<String,Decimal> mapSBankerTitle_sumDealHours = new map<String,Decimal>();
            map<String,Decimal> mapSBankerTitle_sumDealHoursYTD = new map<String,Decimal>();
            map<String,Integer> mapSBankerTitle_countDeals = new map<String,Integer>();
            
            if(mapEmployeeId_Employee.keySet().size() > 0)
            {     
                groupedResults = new list<AggregateResult>();
                groupedResults = [  
                                    SELECT Senior_Banker__c banker, SUM(Hours__c) sumHours
                                    FROM Time_Tracker__c
                                    WHERE   Time_Sheet_Summary__r.Week_Start_Date__c >=: curStartDate  AND 
                                            Time_Sheet_Summary__r.Week_Start_Date__c <=: curEndDate AND
                                            Senior_Banker__c IN : mapEmployeeId_Employee.keySet() AND
                                            Non_Deal_Project__c NOT IN : MDSCExcludeNonDealProjects
                                    GROUP BY Senior_Banker__c];
                for (AggregateResult ar : groupedResults)
                {
                    if(!mapEmployeeId_sumDealHours.keySet().contains((Id)ar.get('banker'))) mapEmployeeId_sumDealHours.put((Id)ar.get('banker'), 0 );
                       mapEmployeeId_sumDealHours.put((Id)ar.get('banker'), mapEmployeeId_sumDealHours.get((Id)ar.get('banker')) + (Decimal)ar.get('sumHours') );
                }
                system.debug('mapEmployeeId_sumDealHours = '+mapEmployeeId_sumDealHours);
                
                // Resource Utilization YTD ///////
                groupedResults = new list<AggregateResult>();
                groupedResults = [  
                                    SELECT Senior_Banker__c banker, SUM(Hours__c) sumHours
                                    FROM Time_Tracker__c
                                    WHERE   Time_Sheet_Summary__r.Week_Start_Date__c = THIS_YEAR  AND 
                                            Time_Sheet_Summary__r.Week_Start_Date__c <= TODAY AND
                                            Senior_Banker__c IN : mapEmployeeId_Employee.keySet() AND
                                            Non_Deal_Project__c NOT IN : MDSCExcludeNonDealProjects
                                    GROUP BY Senior_Banker__c];
                for (AggregateResult ar : groupedResults)
                {
                    if(!mapYTD_EmployeeId_sumDealHours.keySet().contains((Id)ar.get('banker'))) mapYTD_EmployeeId_sumDealHours.put((Id)ar.get('banker'), 0 );
                       mapYTD_EmployeeId_sumDealHours.put((Id)ar.get('banker'), mapYTD_EmployeeId_sumDealHours.get((Id)ar.get('banker')) + (Decimal)ar.get('sumHours') );
                }  
                  
            }
            if(mapEmployeeId_Title.values().size() > 0)
            {
                //Resource Utilization (hrs) - Current Period - Average
                groupedResults = new list<AggregateResult>();
                groupedResults = [  
                                SELECT Senior_Banker__r.Title__c bankerTitle, SUM(Hours__c) sumHours
                                FROM Time_Tracker__c
                                WHERE  Time_Sheet_Summary__r.Week_Start_Date__c >=: curStartDate  AND Time_Sheet_Summary__r.Week_Start_Date__c <=: curEndDate AND
                                       Senior_Banker__r.Title__c IN : mapEmployeeId_Title.values() AND
                                       Senior_Banker__r.Status__c = 'Active' AND 
                                       Senior_Banker__r.Business_Type__c = 'Advisory' AND
                                       Senior_Banker__r.Group__c NOT IN :listExcludeGroups AND
                                       Non_Deal_Project__c NOT IN : MDSCExcludeNonDealProjects
                                GROUP BY Senior_Banker__r.Title__c];
                for (AggregateResult ar : groupedResults)
                {
                    if(!mapSBankerTitle_sumDealHours.keySet().contains((String)ar.get('bankerTitle'))) mapSBankerTitle_sumDealHours.put((String)ar.get('bankerTitle'), 0 );
                    mapSBankerTitle_sumDealHours.put((String)ar.get('bankerTitle'), mapSBankerTitle_sumDealHours.get((String)ar.get('bankerTitle')) + (Decimal)ar.get('sumHours') );
                } 
                
                //Resource Utilization (hrs) - YTD - Average
                groupedResults = new list<AggregateResult>();
                groupedResults = [  
                                SELECT Senior_Banker__r.Title__c bankerTitle, SUM(Hours__c)     sumHours
                                FROM Time_Tracker__c
                                WHERE  Time_Sheet_Summary__r.Week_Start_Date__c = THIS_YEAR  AND Time_Sheet_Summary__r.Week_Start_Date__c <= TODAY AND
                                       Senior_Banker__r.Title__c IN : mapEmployeeId_Title.values() AND
                                       Senior_Banker__r.Status__c = 'Active' AND 
                                       Senior_Banker__r.Business_Type__c = 'Advisory' AND
                                       Senior_Banker__r.Group__c NOT IN :listExcludeGroups AND
                                       Non_Deal_Project__c NOT IN : MDSCExcludeNonDealProjects
                                GROUP BY Senior_Banker__r.Title__c];
                for (AggregateResult ar : groupedResults)
                {
                    if(!mapSBankerTitle_sumDealHoursYTD.keySet().contains((String)ar.get('bankerTitle'))) mapSBankerTitle_sumDealHoursYTD.put((String)ar.get('bankerTitle'), 0 );
                       mapSBankerTitle_sumDealHoursYTD.put((String)ar.get('bankerTitle'), mapSBankerTitle_sumDealHoursYTD.get((String)ar.get('bankerTitle')) + (Decimal)ar.get('sumHours') );
                } 
            }
            
           //Resources Utilization â€“ Current Period â€“ Detailed section
            map<Id,Set<String>> mapEmployeeId_setTitles = new map<Id,Set<String>>();
            
            Decimal tDealHours = 0;
            Decimal tDevHours = 0;
            Decimal tTotalHours = 0;
            Decimal tAverageUsage = 0;
            Decimal tVariance = 0;
            
            map<Id, map<String,Decimal>> mapEmployeeId_mapEmplTitle_SumDealHours = new map<Id, map<String,Decimal>>();
            map<Id, map<String,Decimal>> mapEmployeeId_mapEmplTitle_SumNonDealHours = new map<Id, map<String,Decimal>>();
            map<Id, list<Time_Tracker__c>> mapDealId_listTimeTracker = new map<Id, list<Time_Tracker__c>>();
           
            map<String, Integer> mapSBankerTitle_SBankerTT =  new map<String, Integer>();
            String sTitle = '';
            if(mapEmployeeId_Employee.keySet().size() > 0)
            {    
                for(Time_Tracker__c item : [  
                                SELECT Deal__r.Name,Time_Sheet_Summary__r.Employee__r.Title__c,Employee__c,Deal__c,Hours__c,Senior_Banker__c,Senior_Banker__r.Title__c
                                FROM Time_Tracker__c
                                WHERE   Time_Sheet_Summary__r.Week_Start_Date__c >=: curStartDate  AND Time_Sheet_Summary__r.Week_Start_Date__c <=: curEndDate AND
                                        Senior_Banker__r.Status__c = 'Active' AND 
                                        Senior_Banker__r.Business_Type__c = 'Advisory' AND
                                        Senior_Banker__r.Group__c NOT IN :listExcludeGroups AND 
                                        Senior_Banker__c IN : mapEmployeeId_Employee.keySet() AND
                                        /*MBS-58*/
                                        Non_Deal_Project__c NOT IN : MDSCExcludeNonDealProjects
                               ORDER BY Deal__c,Senior_Banker__c])
                 {
                    if(item.Time_Sheet_Summary__r.Employee__r.Title__c == 'Senior Vice President' || item.Time_Sheet_Summary__r.Employee__r.Title__c == 'Executive Director')
                            sTitle = 'Senior Vice President/Executive Director';
                    else    sTitle = item.Time_Sheet_Summary__r.Employee__r.Title__c;
                    
                    if(item.Deal__r.Name == 'Non-Deal Project')
                    {
                        if(!mapEmployeeId_mapEmplTitle_SumNonDealHours.keySet().contains(item.Senior_Banker__c)) 
                            mapEmployeeId_mapEmplTitle_SumNonDealHours.put(item.Senior_Banker__c, new map<String,Decimal>());
                        if(!mapEmployeeId_mapEmplTitle_SumNonDealHours.get(item.Senior_Banker__c).keySet().contains(sTitle))
                            mapEmployeeId_mapEmplTitle_SumNonDealHours.get(item.Senior_Banker__c).put(sTitle,0);
                    
                        mapEmployeeId_mapEmplTitle_SumNonDealHours.get(item.Senior_Banker__c).put(  sTitle, 
                                                                                                mapEmployeeId_mapEmplTitle_SumNonDealHours.get(item.Senior_Banker__c).get(sTitle) + (item.Hours__c != null ? item.Hours__c : 0 ));
                    }
                    else
                    {
                        if(!mapEmployeeId_mapEmplTitle_SumDealHours.keySet().contains(item.Senior_Banker__c)) 
                            mapEmployeeId_mapEmplTitle_SumDealHours.put(item.Senior_Banker__c, new map<String,Decimal>());
                        if(!mapEmployeeId_mapEmplTitle_SumDealHours.get(item.Senior_Banker__c).keySet().contains(sTitle))
                            mapEmployeeId_mapEmplTitle_SumDealHours.get(item.Senior_Banker__c).put(sTitle,0);
                    
                        mapEmployeeId_mapEmplTitle_SumDealHours.get(item.Senior_Banker__c).put( sTitle, 
                                                                                                mapEmployeeId_mapEmplTitle_SumDealHours.get(item.Senior_Banker__c).get(sTitle) + (item.Hours__c != null ? item.Hours__c : 0 ));
                    }
                    if(!mapEmployeeId_setTitles.keySet().contains(item.Senior_Banker__c))   mapEmployeeId_setTitles.put(item.Senior_Banker__c, new set<String>());
                    mapEmployeeId_setTitles.get(item.Senior_Banker__c).add(sTitle);
                 }
            }
            
            //Resource Utilization â€“ Current Period â€“ Detailed section ("Average Usage")
            map<String,map<String,Decimal>> mapSBankerTitle_mapEmployeeTitle_countSBankerHours = new map<String,map<String,Decimal>>();
            map<String,map<String,Integer>> mapSBankerTitle_mapEmployeeTitle_countSBanker = new map<String,map<String,Integer>>();
            if(mapEmployeeId_Title.values().size() > 0)
            {
                sTitle = '';
                for(Time_Tracker__c item : [  
                                SELECT Time_Sheet_Summary__r.Employee__r.Title__c,Hours__c,Senior_Banker__r.Title__c
                                FROM Time_Tracker__c
                                WHERE  Time_Sheet_Summary__r.Week_Start_Date__c >=: curStartDate  AND Time_Sheet_Summary__r.Week_Start_Date__c <=: curEndDate AND
                                       Senior_Banker__r.Title__c IN : mapEmployeeId_Title.values() AND
                                       Senior_Banker__r.Status__c = 'Active' AND 
                                       Senior_Banker__r.Business_Type__c = 'Advisory' AND
                                       Senior_Banker__r.Group__c NOT IN :listExcludeGroups AND
                                       /*MBS-58*/
                                       Non_Deal_Project__c NOT IN : MDSCExcludeNonDealProjects
                               ORDER BY Senior_Banker__r.Title__c,Time_Sheet_Summary__r.Employee__r.Title__c])
                 {
                    if(item.Time_Sheet_Summary__r.Employee__r.Title__c == 'Senior Vice President' || item.Time_Sheet_Summary__r.Employee__r.Title__c == 'Executive Director')
                            sTitle = 'Senior Vice President/Executive Director';
                    else    sTitle = item.Time_Sheet_Summary__r.Employee__r.Title__c;
                    
                    if(!mapSBankerTitle_mapEmployeeTitle_countSBankerHours.keySet().contains(item.Senior_Banker__r.Title__c)) 
                        mapSBankerTitle_mapEmployeeTitle_countSBankerHours.put(item.Senior_Banker__r.Title__c, new map<String,Decimal>());

                    if(!mapSBankerTitle_mapEmployeeTitle_countSBankerHours.get(item.Senior_Banker__r.Title__c).keySet().contains(sTitle))
                        mapSBankerTitle_mapEmployeeTitle_countSBankerHours.get(item.Senior_Banker__r.Title__c).put(sTitle,0);
                    mapSBankerTitle_mapEmployeeTitle_countSBankerHours.get(item.Senior_Banker__r.Title__c).put( sTitle, mapSBankerTitle_mapEmployeeTitle_countSBankerHours.get(item.Senior_Banker__r.Title__c).get(sTitle) + (Decimal)(item.Hours__c != null ? item.Hours__c : 0)); 
                    
                    if(!mapSBankerTitle_mapEmployeeTitle_countSBanker.keySet().contains(item.Senior_Banker__r.Title__c)) 
                        mapSBankerTitle_mapEmployeeTitle_countSBanker.put(item.Senior_Banker__r.Title__c, new map<String,Integer>());
                    if(!mapSBankerTitle_mapEmployeeTitle_countSBanker.get(item.Senior_Banker__r.Title__c).keySet().contains(sTitle))
                        mapSBankerTitle_mapEmployeeTitle_countSBanker.get(item.Senior_Banker__r.Title__c).put(sTitle,0);
                    mapSBankerTitle_mapEmployeeTitle_countSBanker.get(item.Senior_Banker__r.Title__c).put(  sTitle, mapSBankerTitle_mapEmployeeTitle_countSBanker.get(item.Senior_Banker__r.Title__c).get(sTitle) + 1);
                 }
            }
             
            
            
            ////////////////////////////////////////////////////////////////////
            //generation of the report for all selected bankers
            for(curEmployee curEmployeeProfile : listSBS_Reports)
            {
                //Pitches/////////////////////////////////////////////
                curEmployeeProfile.Pitches_Banker = (mapEmployeeId_countProjects.get(curEmployeeProfile.ID) != null ? mapEmployeeId_countProjects.get(curEmployeeProfile.ID) : 0);
                curEmployeeProfile.Pitches_Average = (mapSBankerTitle_averagePitches.get(curEmployeeProfile.Title) != null ? mapSBankerTitle_averagePitches.get(curEmployeeProfile.Title) : 0);
                curEmployeeProfile.Pitches_Variance = (curEmployeeProfile.Pitches_Banker != null ?curEmployeeProfile.Pitches_Banker:0) - (curEmployeeProfile.Pitches_Average != null ? curEmployeeProfile.Pitches_Average:0);
                            
                //Resource Utilization////////////////////////////////
                curEmployeeProfile.RU_Banker = (mapEmployeeId_sumDealHours.get(curEmployeeProfile.Id) != null ? mapEmployeeId_sumDealHours.get(curEmployeeProfile.Id) : 0);
                if( mapSBankerTitle_sumDealHours.get(curEmployeeProfile.Title) != null && 
                        mapSBankerTitle_countSBankers.get(curEmployeeProfile.Title) != null && 
                        mapSBankerTitle_countSBankers.get(curEmployeeProfile.Title) != 0 )
                {
                    curEmployeeProfile.RU_Average = mapSBankerTitle_sumDealHours.get(curEmployeeProfile.Title) / mapSBankerTitle_countSBankers.get(curEmployeeProfile.Title);
                }
                curEmployeeProfile.RU_Variance = (curEmployeeProfile.RU_Banker != null ? curEmployeeProfile.RU_Banker:0) - (curEmployeeProfile.RU_Average != null ? curEmployeeProfile.RU_Average:0);
                
                ///LiveMandates //////////////////////////////////////
                curEmployeeProfile.LiveMandates_Banker = (mapLM_EmployeeId_countProjects.get(curEmployeeProfile.ID) != null ? mapLM_EmployeeId_countProjects.get(curEmployeeProfile.ID) : 0 );
                curEmployeeProfile.LiveMandates_Average = (mapLM_SBankerTitle_averagePitches.get(curEmployeeProfile.Title) != null ? mapLM_SBankerTitle_averagePitches.get(curEmployeeProfile.Title) : 0);
                curEmployeeProfile.LiveMandates_Variance = (curEmployeeProfile.LiveMandates_Banker != null ?curEmployeeProfile.LiveMandates_Banker:0) - (curEmployeeProfile.LiveMandates_Average != null ? curEmployeeProfile.LiveMandates_Average:0);
                
                //AverageFee//////////////////////////////////////////
                if(mapAF_EmployeeId_countEFees.get(curEmployeeProfile.ID) != null && curEmployeeProfile.LiveMandates_Banker!= null && curEmployeeProfile.LiveMandates_Banker != 0)
                    curEmployeeProfile.AverageFee_Banker   = mapAF_EmployeeId_countEFees.get(curEmployeeProfile.ID)/ curEmployeeProfile.LiveMandates_Banker;
                    
                curEmployeeProfile.AverageFee_Average  = ((mapAF_SBankerTitle_averageEFees.get(curEmployeeProfile.Title) != null ? mapAF_SBankerTitle_averageEFees.get(curEmployeeProfile.Title) : 0 ));
                    
                curEmployeeProfile.AverageFee_Variance = (curEmployeeProfile.AverageFee_Banker != null ? curEmployeeProfile.AverageFee_Banker : 0) - (curEmployeeProfile.AverageFee_Average != null ?curEmployeeProfile.AverageFee_Average:0);
                
                //WeightPipeline//////////////////////////////////////
                curEmployeeProfile.WeightPipeline_Banker = (mapWP_EmployeeId_sumPAR.get(curEmployeeProfile.ID) != null ? mapWP_EmployeeId_sumPAR.get(curEmployeeProfile.ID) : 0 );
                curEmployeeProfile.WeightPipeline_Average =  (mapWP_SBankerTitle_averagePAR.get(curEmployeeProfile.Title) != null ? mapWP_SBankerTitle_averagePAR.get(curEmployeeProfile.Title) : 0);
                curEmployeeProfile.WeightPipeline_Variance =  (curEmployeeProfile.WeightPipeline_Banker != null ?curEmployeeProfile.WeightPipeline_Banker:0) - (curEmployeeProfile.WeightPipeline_Average != null ? curEmployeeProfile.WeightPipeline_Average:0);
                
                
                //Net Pipeline//////////////////////////////////////
                curEmployeeProfile.NetPipeline_Banker  = (mapEmployeeId_grandTotalNetEstFeeRevenue.get(curEmployeeProfile.ID) != null ? mapEmployeeId_grandTotalNetEstFeeRevenue.get(curEmployeeProfile.ID) : 0 );
                curEmployeeProfile.NetPipeline_Average = (mapNP_SBankerTitle_averageNetPipeline.get(curEmployeeProfile.Title) != null ? mapNP_SBankerTitle_averageNetPipeline.get(curEmployeeProfile.Title) : 0);
                curEmployeeProfile.NetPipeline_Variance = (curEmployeeProfile.NetPipeline_Banker != null ?curEmployeeProfile.NetPipeline_Banker:0) - (curEmployeeProfile.NetPipeline_Average != null ? curEmployeeProfile.NetPipeline_Average:0);
                
                
                //YTD Fees Invoiced/////////////////////////////////////
                /*Updated on 6/july/2013 as per the wes comment */
                Decimal feeInvoiced = (mapEmployeeId_grandTotalFeeYTD_CPS.get(curEmployeeProfile.ID) != null && mapEmployeeId_subtotalFeeYTD_OFI.get(curEmployeeProfile.Id) != null) ?
                                        mapEmployeeId_grandTotalFeeYTD_CPS.get(curEmployeeProfile.ID) + mapEmployeeId_subtotalFeeYTD_OFI.get(curEmployeeProfile.Id) :
                                        (mapEmployeeId_grandTotalFeeYTD_CPS.get(curEmployeeProfile.ID) != null && mapEmployeeId_subtotalFeeYTD_OFI.get(curEmployeeProfile.Id) == null)?
                                        mapEmployeeId_grandTotalFeeYTD_CPS.get(curEmployeeProfile.ID) : (mapEmployeeId_grandTotalFeeYTD_CPS.get(curEmployeeProfile.ID) == null && mapEmployeeId_subtotalFeeYTD_OFI.get(curEmployeeProfile.Id) != null)?
                                        mapEmployeeId_subtotalFeeYTD_OFI.get(curEmployeeProfile.Id) : 0;
                                        
                curEmployeeProfile.YTDFeesInvoiced_Banker = feeInvoiced;
                curEmployeeProfile.YTDFeesInvoiced_Average =  mapWP_SBankerTitle_averageYTDFeeInvoice.get(mapEmployeeId_Title.get(curEmployeeProfile.ID));//feeInvoiced/mapSBankerTitle_countSBankers.get(mapEmployeeId_Title.get(curEmployeeProfile.ID));
                curEmployeeProfile.YTDFeesInvoiced_Variance =  (curEmployeeProfile.YTDFeesInvoiced_Banker != null ?curEmployeeProfile.YTDFeesInvoiced_Banker:0) - (curEmployeeProfile.YTDFeesInvoiced_Average != null ? curEmployeeProfile.YTDFeesInvoiced_Average:0);
                
                
                //YTD_Pitches////////////////////////////////////////
                curEmployeeProfile.YTD_Pitches_Banker = (mapYTD_EmployeeId_countProjects.get(curEmployeeProfile.ID) != null ? mapYTD_EmployeeId_countProjects.get(curEmployeeProfile.ID) : 0 );
                curEmployeeProfile.YTD_Pitches_Average = (mapYTD_SBankerTitle_averagePitches.get(curEmployeeProfile.Title) != null ? mapYTD_SBankerTitle_averagePitches.get(curEmployeeProfile.Title) : 0);
                curEmployeeProfile.YTD_Pitches_Variance = (curEmployeeProfile.YTD_Pitches_Banker != null ?curEmployeeProfile.YTD_Pitches_Banker:0) - (curEmployeeProfile.YTD_Pitches_Average != null ? curEmployeeProfile.YTD_Pitches_Average:0);
                
                //YTD Resource Utilization //////////////////////////
                curEmployeeProfile.YTD_RU_Banker = (mapYTD_EmployeeId_sumDealHours.get(curEmployeeProfile.Id) != null ? mapYTD_EmployeeId_sumDealHours.get(curEmployeeProfile.Id) : 0);
                if( mapSBankerTitle_sumDealHoursYTD.get(curEmployeeProfile.Title) != null && 
                    mapSBankerTitle_countSBankers.get(curEmployeeProfile.Title) != null && 
                    mapSBankerTitle_countSBankers.get(curEmployeeProfile.Title) != 0 )
                {
                    curEmployeeProfile.YTD_RU_Average = mapSBankerTitle_sumDealHoursYTD.get(curEmployeeProfile.Title) / mapSBankerTitle_countSBankers.get(curEmployeeProfile.Title);
                }
                curEmployeeProfile.YTD_RU_Variance = (curEmployeeProfile.YTD_RU_Banker != null ? curEmployeeProfile.YTD_RU_Banker:0) - (curEmployeeProfile.YTD_RU_Average != null ? curEmployeeProfile.YTD_RU_Average:0);
                
                /* 
                Senior Banker Scorecard Detail 
                */ 
                
                //Senior Banker Scorecard Detailed â€“ Current Pipeline Section
                if(mapEmployeeId_FeesInvoiceds_CPS.get(curEmployeeProfile.Id) != null)
                {
                    for(FeesInvoiced item : mapEmployeeId_FeesInvoiceds_CPS.get(curEmployeeProfile.Id))
                    {
                         // detailedFuturePipeline
                        
                        
                        if(item.timing != null && item.timing.length() > 4)
                        {
                            Integer year = Integer.valueOf(item.timing.subString(item.timing.indexOf('2') , 4));
                            if(year == Date.today().year())
                                curEmployeeProfile.detailedCurrentYearPipeline.add(item);
                            else
                                curEmployeeProfile.detailedFuturePipeline.add(item);
                        }
                        if(mapEmployeeId_grandTotalFeeYTD_CPS.get(curEmployeeProfile.Id) != null)
                            curEmployeeProfile.grandTotalFeeYTD_CPS = mapEmployeeId_grandTotalFeeYTD_CPS.get(curEmployeeProfile.Id);
                        if(mapEmployeeId_grandTotalExpansesYTD_CPS.get(curEmployeeProfile.Id) != null)
                            curEmployeeProfile.grandTotalExpansesYTD_CPS = mapEmployeeId_grandTotalExpansesYTD_CPS.get(curEmployeeProfile.Id);
                        if(mapEmployeeId_grandTotalFeeRevenue_CPS.get(curEmployeeProfile.Id) != null)
                            curEmployeeProfile.grandTotalFeeRevenue_CPS = mapEmployeeId_grandTotalFeeRevenue_CPS.get(curEmployeeProfile.Id);
                        if(mapEmployeeId_grandTotalPARevenue_CPS.get(curEmployeeProfile.Id) != null)
                            curEmployeeProfile.grandTotalPARevenue_CPS = mapEmployeeId_grandTotalPARevenue_CPS.get(curEmployeeProfile.Id);    
                        if(mapEmployeeId_grandTotalNetEstFeeRevenue.get(curEmployeeProfile.Id) != null)
                            curEmployeeProfile.grandTotalNetEstFeeRev = mapEmployeeId_grandTotalNetEstFeeRevenue.get(curEmployeeProfile.Id);
                        
                        /*MBS : 95*/
                        // Current year pipeline(CYP) subtotal fields
                        if(mapEmployeeId_subTotalFeeRevenue_CYP_CPS.get(curEmployeeProfile.Id) != null)
                            curEmployeeProfile.subTotalFeeRevenue_CYP_CPS = mapEmployeeId_subTotalFeeRevenue_CYP_CPS.get(curEmployeeProfile.Id);
                        if(mapEmployeeId_subTotalPARevenue_CYP_CPS.get(curEmployeeProfile.Id) != null)
                            curEmployeeProfile.subTotalPARevenue_CYP_CPS = mapEmployeeId_subTotalPARevenue_CYP_CPS.get(curEmployeeProfile.Id);
                        if(mapEmployeeId_subTotalNetEstFeeRev_CYP.get(curEmployeeProfile.Id) != null)
                            curEmployeeProfile.subTotalNetEstFeeRev_CYP = mapEmployeeId_subTotalNetEstFeeRev_CYP.get(curEmployeeProfile.Id);
                        
                         // Future pipeline(FP) subtotal fields
                        if(mapEmployeeId_subTotalFeeRevenue_FP_CPS.get(curEmployeeProfile.Id) != null)
                            curEmployeeProfile.subTotalFeeRevenue_FP_CPS = mapEmployeeId_subTotalFeeRevenue_FP_CPS.get(curEmployeeProfile.Id);
                        if(mapEmployeeId_subTotalPARevenue_FP_CPS.get(curEmployeeProfile.Id) != null)
                            curEmployeeProfile.subTotalPARevenue_FP_CPS = mapEmployeeId_subTotalPARevenue_FP_CPS.get(curEmployeeProfile.Id);
                        if(mapEmployeeId_subTotalNetEstFeeRev_FP.get(curEmployeeProfile.Id) != null)
                            curEmployeeProfile.subTotalNetEstFeeRev_FP = mapEmployeeId_subTotalNetEstFeeRev_FP.get(curEmployeeProfile.Id);
                    
                        /*MBS-95*/
                    } 
                }
                //Senior Banker Scorecard Detailed â€“ Other Fees Invoiced Section
                if(mapEmployeeId_FeesInvoiceds_OFI.get(curEmployeeProfile.Id) != null)
                {
                    for(FeesInvoiced item : mapEmployeeId_FeesInvoiceds_OFI.get(curEmployeeProfile.Id))
                    {
                        curEmployeeProfile.detailedOtherFeesInvoiced.add(item);
                        if(mapEmployeeId_subtotalFeeYTD_OFI.get(curEmployeeProfile.Id) != null)
                            curEmployeeProfile.subtotalFeeYTD_OFI = mapEmployeeId_subtotalFeeYTD_OFI.get(curEmployeeProfile.Id);
                        if(mapEmployeeId_subtotalExpansesYTD_OFI.get(curEmployeeProfile.Id) != null)
                            curEmployeeProfile.subtotalExpansesYTD_OFI = mapEmployeeId_subtotalExpansesYTD_OFI.get(curEmployeeProfile.Id);
                        if(mapEmployeeId_subtotalFeeRevenue_OFI.get(curEmployeeProfile.Id) != null)
                            curEmployeeProfile.subtotalFeeRevenue_OFI = mapEmployeeId_subtotalFeeRevenue_OFI.get(curEmployeeProfile.Id);
                    }
                }
                //â€œNear Term Transactionsâ€ Section
                if(mapEmployeeId_NearTermTransactions.get(curEmployeeProfile.Id) != null)
                {
                    for(NearTermTransactions item : mapEmployeeId_NearTermTransactions.get(curEmployeeProfile.Id))
                    {
                        curEmployeeProfile.listNearTermTransactions.add(item);
                    }
                }
                //â€œPitches YTDâ€ Section
                if(mapEmployeeId_PitchesYTD.get(curEmployeeProfile.Id) != null)
                {
                    for(PitchesYTD item : mapEmployeeId_PitchesYTD.get(curEmployeeProfile.Id))
                    {
                        curEmployeeProfile.listPitchesYTD.add(item);
                    }
                }
                //Resources Utilization â€“ Current Period    
                tDealHours = 0;
                tDevHours = 0;
                tTotalHours = 0;
                tAverageUsage = 0;
                tVariance = 0;
                set<String> employeeJuniorBankerTitles = new    set<String>();
                employeeJuniorBankerTitles.add('Senior Vice President/Executive Director');
                employeeJuniorBankerTitles.add('Vice President');
                employeeJuniorBankerTitles.add('Associate');
                employeeJuniorBankerTitles.add('Analyst');
                employeeJuniorBankerTitles.add('Intern');
                Schema.DescribeFieldResult fieldResult = Employee_Profile__c.Title__c.getDescribe();
                List<Schema.PicklistEntry> employeeTitlePickilstValues = fieldResult.getPicklistValues();
                sTitle = '';
                for (Schema.PicklistEntry pVal : employeeTitlePickilstValues)
                {
                    if(pVal.value == 'Senior Vice President')   sTitle = 'Senior Vice President/Executive Director';
                    else sTitle = pVal.value;
                    
                    tDealHours = tDevHours = tTotalHours = tAverageUsage = 0;
                    if( mapEmployeeId_mapEmplTitle_SumDealHours.get(curEmployeeProfile.Id) != null &&
                            mapEmployeeId_mapEmplTitle_SumDealHours.get(curEmployeeProfile.Id).get(sTitle)!= null
                     )  tDealHours = mapEmployeeId_mapEmplTitle_SumDealHours.get(curEmployeeProfile.Id).get(sTitle);
                        
                    if( mapEmployeeId_mapEmplTitle_SumNonDealHours.get(curEmployeeProfile.Id) != null &&
                            mapEmployeeId_mapEmplTitle_SumNonDealHours.get(curEmployeeProfile.Id).get(sTitle)!= null
                    )   tDevHours = mapEmployeeId_mapEmplTitle_SumNonDealHours.get(curEmployeeProfile.Id).get(sTitle);
                                  
                    tTotalHours =   tDealHours + tDevHours;
                         
                    if( mapSBankerTitle_mapEmployeeTitle_countSBankerHours.get(curEmployeeProfile.Title) != null &&
                        mapSBankerTitle_mapEmployeeTitle_countSBankerHours.get(curEmployeeProfile.Title).get(sTitle) != null &&
                        mapSBankerTitle_countSBankers.get(curEmployeeProfile.Title) != null &&
                        mapSBankerTitle_countSBankers.get(curEmployeeProfile.Title) != 0
                    )   tAverageUsage = mapSBankerTitle_mapEmployeeTitle_countSBankerHours.get(curEmployeeProfile.Title).get(sTitle) / mapSBankerTitle_countSBankers.get(curEmployeeProfile.Title); 
                        
                        tVariance = tTotalHours - tAverageUsage;
                        curEmployeeProfile.totDealHours += tDealHours;
                        curEmployeeProfile.totDevHours += tDevHours;
                        curEmployeeProfile.totTotalHours += tTotalHours;
                        curEmployeeProfile.totAverageUsage += tAverageUsage;
                        curEmployeeProfile.totVariance += tVariance;
                   /*mapEmployeeId_setTitles.get(curEmployeeProfile.Id) !=null && mapEmployeeId_setTitles.get(curEmployeeProfile.Id).contains(Stitle)*/
                    if( employeeJuniorBankerTitles.contains(sTitle) || tAverageUsage >0) 
                    {
                        curEmployeeProfile.listResourcesUtilizationCurrentPeriod.add(new ResourcesUtilizationCurrentPeriod(sTitle,tDealHours,tDevHours,tTotalHours,tAverageUsage,tVariance));
                    }
                }
            }//end for : curEmployeeProfile
        } //end if

        for(curEmployee emp:listSBS_Reports)
        {
        	System.debug(LoggingLevel.Error,'before: ' + emp.detailedFuturePipeline);
        	emp.detailedFuturePipeline.sort();
        	System.debug(LoggingLevel.Error,'after sort: ' + emp.detailedFuturePipeline);
        	emp.detailedCurrentYearPipeline.sort();
        }
    }
    
    
    
    private void getEmployeeOrderedList()
    {
        if(this.filter != null && this.subFilters != null && this.curStartDate != null && this.curEndDate != null)
        {
            listMDSCTitles = SL_SeniorBankerScorecard_Dashboard.getSeniorBankerTitles();
            listExcludeGroups = SL_SeniorBankerScorecard_Dashboard.getExcludeGroups();
            if(this.filter == 'banker')
            {
                for(Employee_Profile__c item : [ 
                        SELECT Id,Title__c,MD_Promotion_Date__c,Start_Date__c,User_ID__c, Office_Location__c,Last_Name__c, Group__c,First_Name__c
                        FROM Employee_Profile__c
                        WHERE   Status__c = 'Active' AND 
                                Title__c IN : listMDSCTitles AND 
                                Business_Type__c = 'Advisory' AND
                                Group__c NOT IN :listExcludeGroups AND 
                                Id IN : this.subFilters
                        ORDER BY Last_Name__c, First_Name__c])
                {
                    mapEmployeeId_Employee.put(item.Id,item);
                    listSBS_Reports.add(new curEmployee(item.Id,item.Title__c,item.Last_Name__c,item.First_Name__c,item.Office_Location__c,item.User_ID__c,item.MD_Promotion_Date__c,item.Start_Date__c,item.Group__c));
                }
            }
            else if(this.filter == 'title')
            {
                for(Employee_Profile__c item : [ 
                        SELECT Id,Title__c,MD_Promotion_Date__c,Start_Date__c,User_ID__c, Office_Location__c,Last_Name__c, Group__c,First_Name__c
                        FROM Employee_Profile__c
                        WHERE   Status__c = 'Active' AND 
                                Title__c IN : listMDSCTitles AND 
                                Business_Type__c = 'Advisory' AND
                                Group__c NOT IN :listExcludeGroups AND 
                                Title__c IN : this.subFilters
                        ORDER BY Title__c, Last_Name__c, First_Name__c])
                {
                    mapEmployeeId_Employee.put(item.Id,item);
                    listSBS_Reports.add(new curEmployee(item.Id,item.Title__c,item.Last_Name__c,item.First_Name__c,item.Office_Location__c,item.User_ID__c,item.MD_Promotion_Date__c,item.Start_Date__c,item.Group__c));
                }
            }
            else if(this.filter == 'group')
            {
                for(Employee_Profile__c item : [ 
                        SELECT Id,Title__c,MD_Promotion_Date__c,Start_Date__c,User_ID__c, Office_Location__c,Last_Name__c, Group__c,First_Name__c
                        FROM Employee_Profile__c
                        WHERE   Status__c = 'Active' AND 
                                Title__c IN : listMDSCTitles AND 
                                Business_Type__c = 'Advisory' AND
                                Group__c NOT IN :listExcludeGroups AND 
                                Group__c IN : this.subFilters
                        ORDER BY Group__c, Last_Name__c, First_Name__c])
                {
                    mapEmployeeId_Employee.put(item.Id,item);
                    listSBS_Reports.add(new curEmployee(item.Id,item.Title__c,item.Last_Name__c,item.First_Name__c,item.Office_Location__c,item.User_ID__c,item.MD_Promotion_Date__c,item.Start_Date__c,item.Group__c));
                }
            }
            else if(this.filter == 'location')
            {
                for(Employee_Profile__c item : [ 
                        SELECT Id,Title__c,MD_Promotion_Date__c,Start_Date__c,User_ID__c, Office_Location__c,Last_Name__c, Group__c,First_Name__c 
                        FROM Employee_Profile__c
                        WHERE   Status__c = 'Active' AND 
                                Title__c IN : listMDSCTitles AND 
                                Business_Type__c = 'Advisory' AND
                                Group__c NOT IN :listExcludeGroups AND 
                                Office_Location__c IN : this.subFilters
                        ORDER BY Office_Location__c, Last_Name__c, First_Name__c])
                {
                    mapEmployeeId_Employee.put(item.Id,item);
                    listSBS_Reports.add(new curEmployee(item.Id,item.Title__c,item.Last_Name__c,item.First_Name__c,item.Office_Location__c,item.User_ID__c,item.MD_Promotion_Date__c,item.Start_Date__c,item.Group__c));
                }
            }
        }
    }
    
    /* This method is used to get the currency symbol */
    private String getCurrencySymbol(String iso)
    {

        Map<String,Currency_Symbol_Map__c> currencySymbolMap = Currency_Symbol_Map__c.getall();

        if(iso != '' && iso != null && currencySymbolMap.containskey(iso))
        {
            return currencySymbolMap.get(iso).Symbol__c;
        }
        
        return null;
    }
    /* End */
    
    
    //main class for one current Senior Banker
    public class curEmployee 
    {
        public Id Id {get; set;}
        public string Title {get; set;}
        public string Last_Name {get; set;}
        public string First_Name {get; set;}
        public string Office_Location {get; set;}
        public Id User_ID {get; set;}
        public Date MD_Promotion_Date {get; set;}
        public Date Start_Date {get; set;}
        public string Groups {get; set;}
        
        //Current Period Section 
        //NewBusinessMeetingsCalls
        public Integer NBMC_Banker {get; private set;}
        public Double NBMC_Average {get; private set;}
        public Double NBMC_Variance {get; private set;}
        //Pitches 
        public Integer Pitches_Banker {get; private set;}
        public Decimal Pitches_Average {get; private set;}
        public Decimal Pitches_Variance {get; private set;}
        //Resource Utilization  
        public Decimal RU_Banker {get; private set;}
        public Decimal RU_Average {get; private set;}
        public Decimal RU_Variance {get; private set;}
        //Year To Date Section 
        public Integer LiveMandates_Banker {get; private set;}
        public Decimal LiveMandates_Average {get; private set;}
        public Decimal LiveMandates_Variance {get; private set;}
        public Decimal AverageFee_Banker {get; private set;}
        public Decimal AverageFee_Average {get; private set;}
        public Decimal AverageFee_Variance {get; private set;}
        
        public Decimal NetPipeline_Banker    {   get; private set;   }
        public Decimal NetPipeline_Average   {   get; private set;   }
        public Decimal NetPipeline_Variance  {   get; private set;   }
        
        
        /* Added by Lodhi as per MBS-76 on 30/July/2013 */
        public Decimal WeightPipeline_Banker    {   get; private set;   }
        public Decimal WeightPipeline_Average   {   get; private set;   }
        public Decimal WeightPipeline_Variance  {   get; private set;   }
        public Decimal YTDFeesInvoiced_Banker   {   get; private set;   }
        public Decimal YTDFeesInvoiced_Average  {   get; private set;   }
        public Decimal YTDFeesInvoiced_Variance {   get; private set;   }
        //NewBusinessMeetingsCalls
        public Integer YTD_NBMC_Banker {get; private set;}
        public Decimal YTD_NBMC_Average {get; private set;}
        public Decimal YTD_NBMC_Variance {get; private set;}
        //Pitches 
        public Integer YTD_Pitches_Banker {get; private set;} 
        public Decimal YTD_Pitches_Average {get; private set;}
        public Decimal YTD_Pitches_Variance {get; private set;}
        //Resource Utilization  
        public Decimal YTD_RU_Banker {get; private set;}
        public Decimal YTD_RU_Average {get; private set;}
        public Decimal YTD_RU_Variance {get; private set;}
        //Senior Banker Scorecard Detailed â€“ Current Pipeline Section
        public list<FeesInvoiced> detailedCurrentYearPipeline {get; private set;}
        public list<FeesInvoiced> detailedFuturePipeline {get; private set;}
            // Grand total - Current pipeline section 
        public Decimal grandTotalFeeYTD_CPS   {get; private set;}
        public Decimal grandTotalExpansesYTD_CPS  {get; private set;}
        public Decimal grandTotalFeeRevenue_CPS   {get; private set;}
        public Decimal grandTotalPARevenue_CPS   {get; private set;}
        public Decimal grandTotalNetEstFeeRev    {get;private set;}
            
        /*Start : Added by Vivek MBS-95*/
            // Sub total - Current year pipeline(CYP)
        public Decimal subTotalFeeYTD_CYP_CPS   {get; private set;}
        public Decimal subTotalExpansesYTD_CYP_CPS  {get; private set;}
        public Decimal subTotalFeeRevenue_CYP_CPS   {get; private set;}
        public Decimal subTotalPARevenue_CYP_CPS   {get; private set;}
        public Decimal subTotalNetEstFeeRev_CYP   {get;private set;}
            
            // Sub total - Future pipeline(FP)
        public Decimal subTotalFeeYTD_FP_CPS   {get; private set;}
        public Decimal subTotalExpansesYTD_FP_CPS  {get; private set;}
        public Decimal subTotalFeeRevenue_FP_CPS   {get; private set;}
        public Decimal subTotalPARevenue_FP_CPS   {get; private set;}
        public Decimal subTotalNetEstFeeRev_FP   {get;private set;}
        
        /*End : Added by Vivek MBS-95*/
        //Senior Banker Scorecard Detailed â€“ Other Fees Invoiced Section
        public list<FeesInvoiced> detailedOtherFeesInvoiced {get; private set;}
        public Decimal subtotalFeeYTD_OFI   {get; private set;}
        public Decimal subtotalExpansesYTD_OFI  {get; private set;}
        public Decimal subtotalFeeRevenue_OFI   {get; private set;}
        //â€œPitches YTDâ€ Section
        public list<PitchesYTD> listPitchesYTD  {get; private set;}
        //Resources Utilization â€“ Current Period
        public list<ResourcesUtilizationCurrentPeriod> listResourcesUtilizationCurrentPeriod {get; private set;}
        //Near Term Transactions
        public list<NearTermTransactions> listNearTermTransactions {get; private set;}
        public Decimal totDealHours     {get; private set;}
        public Decimal totDevHours  {get; private set;}
        public Decimal totTotalHours    {get; private set;}
        public Decimal totAverageUsage  {get; private set;}
        public Decimal totVariance  {get; private set;}
        
        public curEmployee(Id p_Id,string p_Title,string p_Last_Name,string p_First_Name,string p_Office_Location,Id p_User_ID,Date p_MD_Promotion_Date,Date p_Start_Date, String p_Groups)
        {
            Id = p_Id;
            Title = p_Title;
            Last_Name = p_Last_Name;
            First_Name = p_First_Name;
            Office_Location = p_Office_Location;
            User_ID = p_User_ID;
            MD_Promotion_Date = p_MD_Promotion_Date;
            Start_Date  = p_Start_Date;     
            Groups = p_Groups;  
            
            detailedCurrentYearPipeline = new list<FeesInvoiced>();
            detailedFuturePipeline = new list<FeesInvoiced>();
            
            detailedOtherFeesInvoiced = new list<FeesInvoiced>();
            listPitchesYTD = new list<PitchesYTD>();
            listResourcesUtilizationCurrentPeriod = new list<ResourcesUtilizationCurrentPeriod>();
            listNearTermTransactions = new list<NearTermTransactions>();
            
            NBMC_Banker = 0;
            NBMC_Average = 0;
            NBMC_Variance = 0;
            Pitches_Banker = 0;
            Pitches_Average = 0;
            Pitches_Variance = 0;
            RU_Banker = RU_Average = RU_Variance = 0;
            YTD_NBMC_Banker = YTD_Pitches_Banker = LiveMandates_Banker = 0;
            AverageFee_Banker = AverageFee_Average = AverageFee_Variance = 0;
            LiveMandates_Average = LiveMandates_Variance = 0;
            YTD_NBMC_Average = YTD_NBMC_Variance = 0;
            YTD_Pitches_Average = YTD_Pitches_Variance = 0;
            YTD_RU_Banker = YTD_RU_Average = YTD_RU_Variance = 0;
            
            grandTotalFeeYTD_CPS = grandTotalExpansesYTD_CPS = grandTotalFeeRevenue_CPS = grandTotalPARevenue_CPS = 0;
            subtotalFeeYTD_OFI = subtotalExpansesYTD_OFI = subtotalFeeRevenue_OFI = 0;

            totDealHours = 0;
            totDevHours = 0;
            totTotalHours = 0;
            totAverageUsage = 0;
            totVariance = 0;
        }
    } 
    
    global class FeesInvoiced implements Comparable
    {
        public String company {get; set;}
        public String projectName {get; set;}
        public String projectCode {get; set;}
        public String recordtype {get; set;}
        public String role {get; set;}
        public String stage {get; set;}
        public Decimal txnsize {get; set;}
        public Decimal revenue {get; set;}
        public Decimal totalInvoiceFees {get; set;}
        public Decimal revenueFees {get; set;}
        public Decimal revenueExpenses {get; set;}
        public String timing {get; set;}
        public String probability {get; set;}
        public Decimal PARevenu {get; set;}
        public String strCSBankerName   {   get;set;    }
        public Decimal netEstFeeRev     {get;set;}
        
        public FeesInvoiced(String p_company, String p_projectName,String p_projectCode,String p_recordtype, String p_role,String p_stage, Decimal p_txnsize, Decimal p_revenue,Decimal p_totalInvoiceFees, Decimal p_revenueFees,Decimal p_revenueExpenses,String p_timing,String p_probability,Decimal p_PARevenu,String strCSBankerName, Decimal netEstFeeRev)
        {
            company = p_company;
            projectName = p_projectName;
            projectCode = p_projectCode;
            recordtype = p_recordtype;
            role = p_role;
            stage = p_stage;
            txnsize = p_txnsize;
            revenue = (p_revenue != null ? p_revenue : 0);//p_revenue;
            totalInvoiceFees = p_totalInvoiceFees;
            revenueFees = p_revenueFees;
            revenueExpenses = p_revenueExpenses;
            timing = p_timing;
            probability = p_probability;
            PARevenu = p_PARevenu;
            this.strCSBankerName = strCSBankerName;
            this.netEstFeeRev = netEstFeeRev ;
        }
        global Integer compareTo(Object compareTo)
        {
        	FeesInvoiced compareToFee = (FeesInvoiced)compareTo;
	        
	        if (timing == compareToFee.timing && company == compareToFee.company) return 0;
	        
	        if (timing.compareTo(compareToFee.timing) < 0)
	        {
				return -1;
	        }
	        else if (timing.compareTo(compareToFee.timing) == 0)
	        {
	        	return company.compareTo(compareToFee.company);
	        }

	        return 1;
        }
    }
    
    class PitchesYTD
    {
        public String company {get; set;}
        public String projectCode {get; set;}
        public String role {get; set;}
        public String recordType {get; set;}
        public String team {get; set;}
        public Decimal revenue {get; set;}
        public String stage {get; set;}
        public String reason {get; set;}
        public Decimal PARevenu {get; set;}
        public String projectName       {   get;set;    }
        public Date pitchDate           {   get;set;    }
        public Decimal txnSize          {   get;set;    }
        public String expectedTiming    {   get;set;    }
        
        public PitchesYTD(String p_company,String p_projectCode,String p_role,String p_recordType,
                          String p_team,Decimal p_revenue,String p_stage,String p_reason,Decimal p_PARevenu,
                          String projectName, Date pitchDate, Decimal txnSize, String expectedTiming)
        {
            company = p_company;
            projectCode = p_projectCode;
            role = p_role;
            recordType = p_recordType;
            team = p_team;
            revenue = (p_revenue != null ? p_revenue : 0);//p_revenue;
            stage = p_stage;
            reason = p_reason;
            PARevenu = p_PARevenu;
            this.projectName = projectName;
            this.pitchDate = pitchDate;
            this.txnSize = txnSize;
            this.expectedTiming = expectedTiming;
        }
    }
    
    class ResourcesUtilizationCurrentPeriod
    {
        public String title {get; set;}
        public Decimal dealHours {get; set;}
        public Decimal devHours {get; set;}
        public Decimal totalHours {get; set;}
        public Decimal averageUsage {get; set;}
        public Decimal variance {get; set;}
        
        public ResourcesUtilizationCurrentPeriod(String p_title,Decimal p_dealHours,Decimal p_devHours,Decimal p_totalHours,Decimal p_averageUsage,Decimal p_Variance)
        {
            title = p_title;
            dealHours = p_dealHours;
            devHours = p_devHours;
            totalHours = p_totalHours;
            averageUsage = p_averageUsage;
            variance = p_Variance;
        }
    }
    
    class NearTermTransactions
    {
        public String Company {get; set;}
        public Date TargetYear {get; set;}
        public String Tier {get; set;}
        public String Type {get; set;}
        public Integer Meetings {get; set;}
        public Integer MeetingsYTD {get; set;}
        public String Description {get; set;}
        public String projectName           {   get;set; }
        public String projectCode           {   get;set; }
        public Decimal txnSize              {   get;set; }
        public Decimal estFees              {   get;set; }
        public String dealProb              {   get;set; }  
        public String moelisProb            {   get;set; }
        public String expectedTiming        {   get;set; }
        public String targetStatus          {   get;set; }
        public String srAssistance          {   get;set; }
        public String productAssistance     {   get;set; }
        public String industryAssistance    {   get;set; }
        
        public NearTermTransactions(String p_Company,Date p_TargetYear,String p_Tier,String p_Type,Integer p_Meetings,Integer p_MeetingsYTD,String p_Description,
             String projectName ,String projectCode ,Decimal txnSize, Decimal estFees, String dealProb, String moelisProb, String expectedTiming, String targetStatus, 
             String srAssistance, String productAssistance  ,String industryAssistance)
        {
            Company = p_Company;
            TargetYear = p_TargetYear;
            Tier = p_Tier;
            Type = p_Type;
            Meetings = p_Meetings;
            MeetingsYTD = p_MeetingsYTD;
            Description = p_Description;
            this.projectName = projectName;
            this.projectCode = projectCode;
            this.txnSize = txnSize;
            this.estFees = estFees;
            this.dealProb = dealProb;
            this.moelisProb = moelisProb;
            this.expectedTiming = expectedTiming;
            this.targetStatus = targetStatus;
            this.srAssistance = srAssistance;
            this.productAssistance = productAssistance;
            this.industryAssistance = industryAssistance;
        }
    }
}