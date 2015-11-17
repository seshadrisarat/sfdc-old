public with sharing class SL_TimeEntryController {
     public Boolean isSystemAdmin {get;set;}
     public List<String> inputFields { get; set; }
     public List<SelectOption> availableUsers {get;set;} 
     public List<SelectOption> timeOptions {get;set;}
     public String currentDate {get;set;}
     public String currentDateStatus {get;set;}
     public String selectDate {get;set;}
     public String selectedUser {get;set;}
     public String nextClosedDate {get;set;}
     public Map<String,String> mtdMap {get;set;}
     public Map<String,String> mapPrjCmpnyNameToEndDate;
     public Map<String,String> mapPrjCmpnyNameToHealth;
     public Map<String,String> mapPrjCmpnyNameToEffort;
     public Map<String,List<String>> mtdMapDaily {get;set;}
     public Map<String,String> mtdMapNames {get;set;}
     public Map<String,String> mtdMapNamesNoSpace {get;set;}
     public Map<String,String> mapNamesToCompany {get;set;}
     public Map<String,Decimal> mtdMapHoursProject {get;set;}
     public Map<String,Map<ID,Decimal>> mapProjectToWGHours;
     public Map<String,String> mapWGMTDHoursText {get;set;}
     public Map<String,Map<ID,Decimal>> mapProjectToLTDWGHours;
     public Map<String,String> mapWGLTDHoursText {get;set;}
     public Map<String,Decimal> LTDMapHoursProject {get;set;}
     public Decimal userMTDHoursTotal {get;set;}// needs to be transient
     public Map<ID,String> mapUserToInitials;
     public Map<String,String> existingTimecardsMap {get;set;}
     public String selectedProject {get;set;}
     public Map<String,Integer> crossMap {get;set;}
     public Map<String,List<AS_Project_Status__c>> projectStatuses;
     public Decimal currentPercentComplete {get;set;}
     public String currentPercentCompleteLastModified {get;set;}
     //public String currentComments {get;set;}
     //public String currentCommentsLastModified {get;set;}
     public String currentLastSteps {get;set;}
     public String currentDueDate {get;set;}
     public String currentLastStepsLastModified {get;set;}
     public String currentNextSteps {get;set;}
     public String currentNextStepsLastModified {get;set;}
     public String currentStatusLocked {get;set;}
     public Map<String,tempStatusStorage> statusStorage;
     public Map<String,ID> projectNameMap {get;set;}
     public List<AS_Project__c> allOtherActiveProjects {get;set;}
     public List<AS_Project__c> closedProjects {get;set;}
     public List<ID> allOtherActiveProjectsIDs;
     public List<Contact> userContact;
     public List<External_Working_Group_Member__c> workingGroups;
     public String addProject {get;set;}
     public String reProject {get;set;}
     public String dailyOrMonthly {get;set;}
     public String weekOrMonth {get;set;}
     public AS_Project__c objASProjectSpecific          {get;set;}
     public AS_Project__c objASProjectCross             {get;set;}
     public AS_Project__c objASProjectDiligence         {get;set;}
     public Boolean isInsert                {get;set;}
     public String strCompanyId             {get; set;}
     public String strSelectedCompanyIds    {get; set;}
     public String strCompanyName           {get; set;}
     public String strInvestmentOppId       {get; set;}
     public String strInvestmentOppName     {get; set;}
     public Boolean isValid                 {get; set;}
     public Boolean isRenderOtherFields     {get; set;}
     public Boolean isDiligencePresent      {get; set;}
     public Boolean isCrossPortfolio        {get; set;}
     public Boolean isExistsProjectName  {get; set;}
     public String strFieldsetName;
     public List<ID> projects;
     public List<AS_Project_Status__c> projectStat;
     public List<GroupMemberWrapper> lstGroupMemberWrapper          {get;set;}
     public List<ColumnWrapper> lstContactColumnWrapper             {get;set;}
     public List<ColumnWrapper> lstWGMColumnWrapper                 {get;set;}
     public List<ColumnWrapper> lstASProjectColumnWrapper           {get;set;}
     public List<External_Working_Group_Member__c>  lstEWGMember    {get;set;} 
     public List<ColumnWrapper> lstASProjectCWSpecific              {get;set;}
     public List<ColumnWrapper> lstASProjectCWCross                 {get;set;} 
     public List<ColumnWrapper> lstASProjectCWDiligence             {get;set;}
     public String strProjectCategory                               {get;set;}
     public String strSelectedProjectCategory                       {get;set;}
     public String strCompaniesHaveCurrentProject                   {get;set;}
     private Map<String, Schema.SObjectType> GlobalDescribeMap ;//orginally private
     public List<EndDateWrapper> lstEndDateWrapper {get;set;}
     public List<HealthWrapper> lstHealthWrapper {get;set;}
     public List<EffortWrapper> lstEffortWrapper {get;set;}
     public String strEndDateWrapper {get;set;}
     public String strHealthWrapper {get;set;}
     public String strEffortWrapper {get;set;}
     public Boolean isPrevPercentSame {get;set;}
     public Map<String,String> projCloseDates {get;set;}
     public String oldselectproject {get;set;}
     public Boolean seeAllProjects {get;set;}

     
    public SL_TimeEntryController() {
        
        initialization();
        if(ApexPages.currentPage().getParameters().containsKey('isInsert'))
        {
            lstASProjectCWSpecific = prepareColumnWrapper('NewASProject');
            lstASProjectCWCross = prepareColumnWrapper('NewASCrossPortfolioProject');
            lstASProjectCWDiligence = prepareColumnWrapper('NewAsDiligenceProject');
        }   
        isPrevPercentSame = false;
        strSelectedProjectCategory = 'none';
        strEndDateWrapper = '';
        strHealthWrapper = '';
        strEffortWrapper = '';
        addProject = '';
        selectedProject='';
        currentPercentComplete = 0;
        //currentComments = '';
        currentLastSteps = '';
        currentNextSteps = '';
        currentDueDate = '';
        currentDateStatus = '';
        oldselectproject = '';
        currentPercentCompleteLastModified = '';
        currentLastStepsLastModified = '';
        currentNextStepsLastModified = '';
        //currentCommentsLastModified = '';
        currentStatusLocked = '';
        userMTDHoursTotal = 0.00;
        availableUsers = new List<SelectOption>();
        allOtherActiveProjects = new List<AS_Project__c>();
        allOtherActiveProjectsIDs = new List<ID>();
        closedProjects = new List<AS_Project__c>();
        mtdMap = new Map<String,String>();
        mapPrjCmpnyNameToEndDate = new Map<String, String>();
        mtdMapNames = new Map<String,String>();
        mtdMapNamesNoSpace = new Map<String,String>();
        mapNamesToCompany = new Map<String,String>();
        mtdMapDaily = new Map<String,List<String>>();
        crossMap = new Map<String,Integer>();
        projCloseDates = new Map<String,String>();
        mtdMapHoursProject = new Map<String,Decimal>();
        LTDMapHoursProject = new Map<String,Decimal>(); 
        mapProjectToWGHours = new Map<String,Map<ID,Decimal>>();
        mapUserToInitials= new Map<ID,String>();
        mapWGMTDHoursText = new Map<String,String>();
        mapWGLTDHoursText = new Map<String,String>();
        userContact = new List<Contact>();
        timeOptions = new List<SelectOption>();
        inputFields = new List<String>();
        existingTimecardsMap = new Map<String,String>();
        statusStorage = new Map<String,tempStatusStorage>();
        projectNameMap = new Map<String,ID>();
        workingGroups = new List<External_Working_Group_Member__c>();
        isSystemAdmin = false;
        seeAllProjects = false;
        List<User> selectUserList = [SELECT ID,Name,Time_Entry_Preference__c FROM USER WHERE ID =:UserInfo.getUserId()];
        dailyOrMonthly = selectUserList[0].Time_Entry_Preference__c;
        if(dailyOrMonthly=='Monthly')
        {
            weekOrMonth = 'Month';
        }
        else
        {
            weekOrMonth = 'Week';
        }
       /* List<AS_Project__c> totalProjects = [SELECT ID, NAME,Company_project_name_formula__c FROM AS_Project__c];
        for(AS_Project__c p:totalProjects)
        {
            projectNameMap.put(p.Company_project_name_formula__c,p.ID);
        }*/
        selectedUser = UserInfo.getUserId();
        timeOptions.add(new SelectOption('Monthly','-Monthly'));
        timeOptions.add(new SelectOption('Daily','-Daily'));
        
        List<Profile> profiles = [SELECT ID,Name FROM Profile where Name = 'System Administrator' LIMIT 1];
        if(profiles.size()>0)
        {
             if(UserInfo.getProfileID()==profiles[0].ID)
             {
                isSystemAdmin = true;
             }
        }
        
        getLastHoursEntered();
       // fillDailyExistingTimecards();
        mtdHours();
        fillInitials();
        //List<AS_Project_Status__c> projectStat = [SELECT ID,Percent_Complete__c,AS_Project__c,AS_Project__r.Company_project_name_formula__c,Comments__c,Last_Steps__c,Month_Ending__c,Next_Steps__c from AS_Project_Status__c where AS_Project__r.Company_project_name_formula__c in:existingTimecardsMap.keyset()];
        List<AS_Project_Status__c> projectStat = [SELECT ID,Percent_Complete__c,AS_Project__c,AS_Project__r.Company_project_name_formula__c,Last_Steps__c,Month_Ending__c,Next_Steps__c from AS_Project_Status__c where AS_Project__r.Company_project_name_formula__c in:existingTimecardsMap.keyset()];
        availableUsers.add(new SelectOption(selectUserList[0].ID,selectUserList[0].Name));
        List<Delegate__c> userDelegates = [SELECT Delegate__c,Manager__r.Name,Manager__c from Delegate__c where Delegate__c =:UserInfo.getUserId() AND Active__c =true AND Time_Tracking__c=true];
        for(Delegate__c d: userDelegates)
        {
            availableUsers.add(new SelectOption(d.Manager__c,d.Manager__r.Name));
        }
        for(Integer i = 0; i<7; i++)
        {
            Date dayMonth = (Date.valueof(selectDate)-1).toStartOfWeek()+1+i;
            String datemonth = dayMonth.month() + '/' + dayMonth.day();
            if(i==0)
                inputFields.add('Mon\n'+datemonth);
            if(i==1)
                inputFields.add('Tue\n'+datemonth);
            if(i==2)
                inputFields.add('Wed\n'+datemonth);
            if(i==3)
                inputFields.add('Thu\n'+datemonth);
            if(i==4)
                inputFields.add('Fri\n'+datemonth);
            if(i==5)
                inputFields.add('Sat\n'+datemonth);
            if(i==6)
                inputFields.add('Sun\n'+datemonth);
        }
        getNextClosedDate();

       
    }
    /* Start - Project End Date Wrapper */
    public class EndDateWrapper
    {
        public String strProjectName {get;set;}
        public String strEndDate {get;set;}
        
        public EndDateWrapper(String strProjectName, String strEndDate)
        {
            this.strProjectName = strProjectName;
            this.strEndDate = strEndDate;
        }
    }
    /* End - Project End Date Wrapper */
    /* Start - Project End Date Wrapper */
    public class HealthWrapper
    {
        public String strProjectName {get;set;}
        public String strHealth {get;set;}
        
        public HealthWrapper(String strProjectName, String strHealth)
        {
            this.strProjectName = strProjectName;
            this.strHealth = strHealth;
        }
    }
    /* End - Project End Date Wrapper */
     /* Start - Project End Date Wrapper */
    public class EffortWrapper
    {
        public String strProjectName {get;set;}
        public String strEffort {get;set;}
        
        public EffortWrapper(String strProjectName, String strEffort)
        {
            this.strProjectName = strProjectName;
            this.strEffort = strEffort;
        }
    }
    /* End - Project End Date Wrapper */
    public void getAllCrossPortfolio()
    {
        crossMap = new Map<String,Integer>();
        List<AS_Project__c> allProjects = [SELECT ID,Name,Company_project_name_formula__c from AS_Project__c where Id in: projects];
        for(AS_Project__c proj: allProjects)
        {
            if(crossMap.get(proj.Name)==null)
            {
                crossMap.put(proj.Name,1);
            }
            else
            {
                Integer i = crossMap.get(proj.Name);
                i++;
                crossMap.put(proj.Name,i);
            }
        }
    }
    public void getUserTotalMTDHours()
    {
        userMTDHoursTotal = 0.00;
        Date selectDateStartOfMonth = Date.valueof(selectDate).toStartofMonth();
        Date selectDateEndOfMonth = selectDateStartOfMonth+Date.daysInMonth(selectDateStartOfMonth.year(), selectDateStartOfMonth.month())-1;
        List<Project_Time_Tracking__c> allmtdtimecards = [SELECT Hours__c from Project_Time_Tracking__c where Resource_User__c=:selectedUser AND Date__c>=: selectDateStartOfMonth AND Date__c<=:selectDateEndOfMonth];
        for(Project_Time_Tracking__c t:allmtdtimecards)
        {
            userMTDHoursTotal +=t.Hours__c;
        }
    }
    public void getNextClosedDate()
    {
         List<Project_Closed_Date__c> allProjCustomSetting = [SELECT NAME,Day_of_Month__c from Project_Closed_Date__c where Name = 'Systemprojcloseddate' LIMIT 1];

         if(allprojCustomSetting.size()>0)
         {
            Integer dayofMonth = Integer.valueof(allProjCustomSetting[0].Day_of_Month__c);
            Date today = Date.today();
            today = today.toStartOfMonth();
            today = today.addMonths(1);
            nextClosedDate = today.month()+ '/'+dayOfMonth + '/'+today.year();
         }
    }
    public void getProjectClosedDates()
    {
        List<AS_Project__c> closingProject = [SELECT ID,Close_Date__c,Company_project_name_formula__c FROM AS_Project__c WHERE ID in: projects AND Active__c=true];
        for(AS_Project__c proj:closingProject)
        {
            String closeDate = '';
            if(proj.Close_Date__c!=null)
            {
                closeDate=proj.Close_Date__c.Month()+'/'+proj.Close_Date__c.Day()+'/' +proj.Close_Date__c.Year();
            }
            projCloseDates.put(proj.Company_project_name_formula__c,closeDate);
        }
    }

    public void fillInitials()
    {
        List<External_Working_Group_Member__c> allWG = [SELECT Contact__r.Salesforce_User__c,Contact__r.AS_Alias__c from External_Working_Group_Member__c where AS_Project__c in:projects];
        for(External_Working_Group_Member__c wgMemb: allWG)
        {
            mapUserToInitials.put(wgMemb.Contact__r.Salesforce_User__c,wgMemb.Contact__r.AS_Alias__c);
        }
    }
    public void getLastHoursEntered()
    {
        List<User> currUser = [SELECT ID, NAME FROM USER WHERE ID =:selectedUser];
        userContact = new List<Contact>();
        if(currUser.size()>0)
        {
            userContact = [SELECT ID FROM Contact where Salesforce_User__c =: currUser[0].ID];
        }
        workingGroups = new List<External_Working_Group_Member__c>();
        if(userContact.size()>0){
            workingGroups = [SELECT AS_Project__c FROM External_Working_Group_Member__c WHERE Contact__c =: userContact[0].ID AND AS_Project__c!=null AND AS_Project__r.Active__c =true];
        }
        projects = new List<ID>();
        for(External_Working_Group_Member__c wg: workingGroups)
        {
            projects.add(wg.AS_Project__c);
        }
        List<Project_Time_Tracking__c> alltimecards = [SELECT ID, Date__c,Project_Name__r.End_Date__c FROM Project_Time_Tracking__c WHERE Project_Name__c in:projects Order By Date__c DESC];
        if(alltimecards.size()>0)
        {
            Project_Time_Tracking__c lastTimecard = alltimecards[0];
            Date lastDate = lastTimecard.Date__c + 7;
            Integer month = lastDate.month();

            if(lastDate<Date.today()||dailyOrMonthly=='Monthly')
            {
                if(dailyOrMonthly=='Monthly')
                {
                    lastDate=Date.today();
                    month = lastDate.month();
                    if(lastDate.day()<=15)
                    {
                            month -= 1;
                            currentDate = month+'/'+lastDate.year();
                            selectDate = lastDate.year()+'-'+month+'-'+'01';
                    }
                    else
                    {
                            currentDate = month+'/'+lastDate.year();
                            selectDate = lastDate.year()+'-'+month+'-'+'01';
                    }
                }
                else
                {
                        currentDate = month+'/'+lastDate.day()+'/'+lastDate.year();
                        selectDate = lastDate.year()+'-'+month+'-'+lastDate.day();
                }
            }
            else
            {
                getDate();
            }
        }
        else
        {
            getDate();
        }

    }
    /*
        @MethodName : initialization 
        @param      : NA
        @Description: method for intializing variables. 
    */
    private void initialization()
    {
        //isInsert = Apexpages.currentPage().getParameters().containsKey('isInsert') ? true : false;
        strCompaniesHaveCurrentProject = '';
        strSelectedCompanyIds = '';
        strFieldsetName = '';
        strCompanyId = '';
        strInvestmentOppId = '';
        strCompanyName = '';
        strInvestmentOppName = '';
        //isInsert = false;
        isInsert = Apexpages.currentPage().getParameters().containsKey('isInsert') ? true : false;
        isExistsProjectName = false;
        isValid = false;
        isRenderOtherFields = false;
        isDiligencePresent = false;
        isCrossPortfolio = false;
        // objASProject = new AS_Project__c();
        objASProjectSpecific = new AS_Project__c();
        objASProjectCross = new AS_Project__c();  
        objASProjectDiligence = new AS_Project__c();
        GlobalDescribeMap = Schema.getGlobalDescribe();
        lstGroupMemberWrapper = new List<GroupMemberWrapper>(); 
        lstEWGMember = new List<External_Working_Group_Member__c>();
        lstContactColumnWrapper = new List<columnWrapper>();
        lstASProjectColumnWrapper = new List<columnWrapper>();
        lstWGMColumnWrapper = new List<columnWrapper>();
        lstASProjectCWSpecific = new List<ColumnWrapper>();
        lstASProjectCWCross = new List<ColumnWrapper>();
        lstASProjectCWDiligence = new List<ColumnWrapper>();
        lstEndDateWrapper = new List<EndDateWrapper>(); 
        lstHealthWrapper = new List<HealthWrapper>();
        lstEffortWrapper = new List<EffortWrapper>();

        strProjectCategory = '';
    }

    public void getClosedProjects()
    {
        closedProjects = [SELECT ID,Active__c, Name,Portfolio_Company__r.Name, Company_project_name_formula__c from AS_Project__c where Active__c=:false];
    }

    public void getOtherProjects()
    {
        List<ID> WGIds = new List<ID>();
        for(External_Working_Group_Member__c memb: workingGroups)
        {
            WGIds.add(memb.AS_Project__c);
        }
        allOtherActiveProjects = [SELECT ID, Name,Portfolio_Company__r.Name, Company_project_name_formula__c FROM AS_Project__c WHERE ID NOT in: WGIds AND Active__c =:true ORDER BY Company_project_name_formula__c ASC];
        for(AS_Project__c p:allOtherActiveProjects)
        {
            allOtherActiveProjectsIDs.add(p.ID);
            mtdMapHoursProject.put(p.Company_project_name_formula__c,0.00);
            LTDMapHoursProject.put(p.Company_project_name_formula__c,0.00);
            mapWGMTDHoursText.put(p.Company_project_name_formula__c,'');
            mapWGLTDHoursText.put(p.Company_project_name_formula__c,'');
            mtdMapNames.put(p.Company_project_name_formula__c,p.Name);
            mtdMapNamesNoSpace.put(p.Company_project_name_formula__c,removeSpace(p.Name));
        }
    }
    public String removeSpace(String projName)
    {
        return  projName.replaceAll( '\\s+', '').replace('.', '-').replace(',','-');
    }
    public class tempStatusStorage
    {
        Decimal tempPercentComplete;
        String tempLastSteps;
        String tempNextSteps;
        //String tempComments;
        String templocked;
        String tempDueDate;
        public tempStatusStorage()
        {
            tempPercentComplete =0;
            tempLastSteps ='';
            tempNextSteps = '';
            //tempComments = '';
            templocked = '';
            tempDueDate = '';
        }
    }

    public void getDate()
    {
        Date today = Date.today();
        Integer month = today.month();
        if(dailyOrMonthly=='Monthly')
        {
            if(today.day()<15)
            {
                month -= 1;
                    currentDate = month+'/'+today.year();
                    selectDate = today.year()+'-'+month+'-'+'01';
            }
            else
            {
                    currentDate = month+'/'+today.year();
                    selectDate = today.year()+'-'+month+'-'+'01';
            }
        }
        else
        {
                currentDate = month+'/'+today.day()+'/'+today.year();
                selectDate = today.year()+'-'+month+'-'+today.day();
        }
    }
    
    public void selectUserChanged()
    {
        List<User> currUser = [SELECT Time_Entry_Preference__c FROM USER WHERE ID =:selectedUser];
         if(currUser.size()>0)
        {
            dailyOrMonthly = currUser[0].Time_Entry_Preference__c;
        }
        Date today = date.valueOf(selectDate);
        Integer month = today.month();
        if(dailyOrMonthly=='Monthly')
        {
                    weekOrMonth = 'Month';
                    currentDate = month+'/'+today.year();
                    selectDate = today.year()+'-'+month+'-'+'01';
        }
        else
        {
                weekOrMonth = 'Week';
                currentDate = month+'/'+today.day()+'/'+today.year();
                selectDate = today.year()+'-'+month+'-'+today.day();
        }
    }

    public PageReference updateDateRange()
    {
        inputFields = new List<String>();
       // pagereference pageRef = new PageReference('/apex/SL_TimeEntry2?retProj='+EncodingUtil.urlEncode(selectedProject, 'UTF-8'));
        //pageref.getParameters().put('retProj',selectedProject);
        //pageref.setRedirect(true);
        oldselectproject=selectedProject;
        for(Integer i = 0; i<7; i++)
        {
            Date dayMonth = (Date.valueof(selectDate)-1).toStartOfWeek()+1+i;
            String datemonth = dayMonth.month() + '/' + dayMonth.day();
            if(i==0)
                inputFields.add('Mon\n'+datemonth);
            if(i==1)
                inputFields.add('Tue\n'+datemonth);
            if(i==2)
                inputFields.add('Wed\n'+datemonth);
            if(i==3)
                inputFields.add('Thu\n'+datemonth);
            if(i==4)
                inputFields.add('Fri\n'+datemonth);
            if(i==5)
                inputFields.add('Sat\n'+datemonth);
            if(i==6)
                inputFields.add('Sun\n'+datemonth);
        }
        mtdHours();
        //fillDailyExistingTimecards();
        //PageReference pageRef = new PageReference(ApexPages.currentPage()+'?'+selectedProject);

        return null;
    }
    public PageReference unlockTimeRecords()
    {
        List<CronTrigger> jobs = [SELECT CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.JobType = '7' AND CronJobDetail.Name='SL_RelockTimeRecordsBatch' ORDER BY CreatedDate];
        if(jobs.size()==0)
        {
            Date selectedDateStart;
            if((Date.valueOf(selectDate)).day()==1)
            {
                selectedDateStart =  (Date.valueOf(selectDate));
            }
            else
            {
                selectedDateStart = (Date.valueOf(selectDate)).toStartofMonth();
            }
          
            Date selectedDateEnd = selectedDateStart + Date.daysInMonth(selectedDateStart.year(),selectedDateStart.month())-1;
            List<Project_Time_Tracking__c> getTimecards = [SELECT ID,Resource_User__c,Project_Name__c,Project_Name__r.End_Date__c,Date__c,Locked__c,Hours__c FROM Project_Time_Tracking__c where Resource_User__c =: selectedUser AND Project_Name__c in: projects AND Date__c <=:selectedDateEnd AND Date__c >=:selectedDateStart And Locked__c = true];
            SET<ID> remainingproject = new Set<ID>(projects);
            for(Project_Time_Tracking__c t: getTimecards)
            {
                if(remainingproject.contains(t.Project_Name__c))
                {
                    remainingproject.remove(t.Project_Name__c);
                }
                t.Locked__c=false;
            }
            update getTimecards;
            List<Project_Time_Tracking__c> newTimecards = new List<Project_Time_Tracking__c>();
            for(ID remainProj:remainingproject)
            {
                Project_Time_Tracking__c insertEntryHolder = new Project_Time_Tracking__c();
                insertEntryHolder.Date__c = selectedDateStart;
                insertEntryHolder.Hours__c = 0.00;
                insertEntryHolder.Locked__c = false;
                insertEntryHolder.Resource_User__c = selectedUser;
                insertEntryHolder.Project_Name__c = remainProj;
                newTimecards.add(insertEntryHolder);
            }
            insert newTimecards;
            LIST<Relock_Time_Setting__c> relockCS = [SELECT Hours__c from Relock_Time_Setting__c where Name = 'SystemRelockHours'];
            Integer timeAdd = 0;
            DateTime today =Datetime.now();
            if(relockCS.size()>0)
            {
                timeAdd = Integer.valueOf(relockCS[0].Hours__c);
            }
            else
            {
                timeadd = 24;
            }
            DateTime newDate =today.addHours(timeAdd);
            String year = String.valueOf(newDate.year());
            String month = String.valueOf(newDate.month());
            String day =String.valueOf(newDate.day());
            String hour = String.valueOf(newDate.hour());
            String min = String.valueOf(newDate.minute()); 
            String ss = String.valueOf(newDate.second());

            //parse to cron expression
            String nextFireTime = ss + ' ' + min + ' ' + hour + ' '+ day + ' ' +month+ ' ? '+ year;
            SL_RelockTimeEntries SC = new SL_RelockTimeEntries(); 
            System.schedule('SL_RelockTimeRecordsBatch', nextFireTime, SC);
        }
        return null;

    }
    /*public void deleteTime()
    {
        delete[Select ID from Project_Time_Tracking__c];
        mtdHours();
    }*/
    public void seeAllProjectsAction()
    {
        seeAllProjects = true;
    }
    public void fillTempDaily()
    {
        statusStorage = new Map<String,tempStatusStorage>();
        selectedProject = '';
        currentPercentComplete = 0;
        //currentComments = '';
        currentLastSteps = '';
        currentNextSteps = '';
        currentDueDate = '';
        Decimal mtdHoursAll = 0.00;
        mtdMapDaily = new Map<String,List<String>>();
        List<User> currUser = [SELECT ID, NAME FROM USER WHERE ID =:selectedUser];
        userContact = new List<Contact>();
        if(currUser.size()>0)
        {
            userContact = [SELECT ID, Name FROM Contact where Salesforce_User__c =: currUser[0].ID];
        }
        workingGroups = new List<External_Working_Group_Member__c>();
        if(userContact.size()>0){
             if(seeAllProjects)
                workingGroups = [SELECT ID,AS_Project__c,AS_Project__r.End_Date__c,AS_Project__r.Company_project_name_formula__c,Contact__c,End_Date__c FROM External_Working_Group_Member__c WHERE AS_Project__c!=null AND AS_Project__r.Active__c =true AND (End_Date__c >: Date.valueof(selectDate) OR End_Date__c =: null)];
            else
            workingGroups = [SELECT ID,AS_Project__c,AS_Project__r.End_Date__c,AS_Project__r.Company_project_name_formula__c,Contact__c,End_Date__c FROM External_Working_Group_Member__c WHERE Contact__c =: userContact[0].ID AND AS_Project__c!=null AND AS_Project__r.Active__c =true AND (End_Date__c >: Date.valueof(selectDate) OR End_Date__c =: null)];
        }

        projects = new List<ID>();
        Date selectDateVal = Date.valueOf(selectDate);
        Date selectDateStart = (selectDateVal-1).toStartOfWeek()+1;
        Date selectDateEnd = selectDateStart+6;
        for(External_Working_Group_Member__c wg: workingGroups)
        {
            projects.add(wg.AS_Project__c);
            List<String> initList = new List<String>{'','','','','','',''};
            if(wg.End_Date__c < selectDateEnd)
            {
                for(Integer p=6; p>=Math.abs(wg.End_Date__c.daysBetween(selectDateStart));p--)
                {
                    initList[p] ='EndDate';
                }
            }
            
            mtdMapDaily.put(wg.AS_Project__r.Company_project_name_formula__c,initList);
        }
    }
    public void fillDailyExistingTimecards()
    {
        statusStorage = new Map<String,tempStatusStorage>();
        selectedProject = '';
        currentPercentComplete = 0;
        //currentComments = '';
        currentLastSteps = '';
        currentNextSteps = '';
        currentDueDate = '';
        Decimal mtdHoursAll = 0.00;
        mtdMapDaily = new Map<String,List<String>>();
        List<User> currUser = [SELECT ID, NAME FROM USER WHERE ID =:selectedUser];
        userContact = new List<Contact>();
        if(currUser.size()>0)
        {
            userContact = [SELECT ID, Name FROM Contact where Salesforce_User__c =: currUser[0].ID];
        }
        workingGroups = new List<External_Working_Group_Member__c>();
        if(userContact.size()>0){
            if(seeAllProjects)
                workingGroups = [SELECT ID,AS_Project__c,AS_Project__r.End_Date__c,AS_Project__r.Company_project_name_formula__c,Contact__c,End_Date__c FROM External_Working_Group_Member__c WHERE AS_Project__c!=null AND AS_Project__r.Active__c =true AND (End_Date__c >: Date.valueof(selectDate) OR End_Date__c =: null)];
            else
            workingGroups = [SELECT ID,AS_Project__c,AS_Project__r.End_Date__c,AS_Project__r.Company_project_name_formula__c,Contact__c,End_Date__c FROM External_Working_Group_Member__c WHERE Contact__c =: userContact[0].ID AND AS_Project__c!=null AND AS_Project__r.Active__c =true AND (End_Date__c >: Date.valueof(selectDate) OR End_Date__c =: null)];
        }

        projects = new List<ID>();
        Date selectDateVal = Date.valueOf(selectDate);
        Date selectDateStart = (selectDateVal-1).toStartOfWeek()+1;
        Date selectDateEnd = selectDateStart+6;
        for(External_Working_Group_Member__c wg: workingGroups)
        {
            projects.add(wg.AS_Project__c);
            List<String> initList = new List<String>{'','','','','','',''};
            if(wg.End_Date__c < selectDateEnd)
            {
                for(Integer p=6; p>=Math.abs(wg.End_Date__c.daysBetween(selectDateStart));p--)
                {
                    initList[p] ='EndDate';
                }
            }
            
            mtdMapDaily.put(wg.AS_Project__r.Company_project_name_formula__c,initList);
        }
        if(dailyOrMonthly=='Daily')
        {
            getExistingTimecards(projects,selectDateStart,selectDateEnd);
        }
        Map<String,Project_Time_Tracking__c> projectTimeMap = new Map<String,Project_Time_Tracking__c>();
        List<Project_Time_Tracking__c> userTimecards = [SELECT ID, Hours__c,Project_Name__r.End_Date__c,Project_Name__r.Name,Project_Name__r.Company_project_name_formula__c,Project_Name__c,Date__c,Locked__c from Project_Time_Tracking__c where Resource_User__c =: selectedUser AND Project_Name__c in:projects AND Date__c >=: selectDateStart AND Date__c <=: selectDateEnd];
        Date selectDateEndMonth;
        if(selectDateEnd.month()==selectDateStart.month())
        {
            selectDateEndMonth= selectDateStart.toStartOfMonth() + date.daysInMonth(selectDateStart.year(),selectDateStart.month())-1;
        }
        else
        {
            selectDateEndMonth = selectDateStart.toStartOfMonth() + date.daysInMonth(selectDateStart.year(),selectDateStart.month())+date.daysInMonth(selectDateEnd.year(),selectDateEnd.month()) -1;
        }
        List<Project_Time_Tracking__c> userTimecardsMonth = [SELECT ID, Hours__c,Project_Name__r.Name,Project_Name__r.End_Date__c,Project_Name__r.Company_project_name_formula__c,Project_Name__c,Date__c,Locked__c from Project_Time_Tracking__c where Resource_User__c =: selectedUser AND Project_Name__c in:projects AND Date__c >=: selectDateStart.toStartOfMonth() AND Date__c <=: selectDateEndMonth];
       //Check if any time entries for this month are locked
        Map<Date,Map<String,Boolean>> isLockedMap = new Map<Date,Map<String,Boolean>>();
        Map<Date,Map<String,Project_Time_Tracking__c>> hasTimecard =new Map<Date,Map<String,Project_Time_Tracking__c>>();
        for(Project_Time_Tracking__c timeEntryMonth:userTimecardsMonth)
        {
            projectTimeMap.put(timeEntryMonth.Project_Name__r.Company_project_name_formula__c,timeEntryMonth);
            if(timeEntryMonth.Locked__c)
            {
                Map<String,Boolean> projLockMap = new Map<String,Boolean>();
                if(isLockedMap.get(timeEntryMonth.Date__c.toStartOfMonth())==null)
                {
                 projLockMap.put(timeEntryMonth.Project_Name__r.Company_project_name_formula__c,True);   
                }
                else
                {
                    projLockMap= isLockedMap.get(timeEntryMonth.Date__c.toStartOfMonth());
                    projLockMap.put(timeEntryMonth.Project_Name__r.Company_project_name_formula__c,True);
                }
                isLockedMap.put(timeEntryMonth.Date__c.toStartOfMonth(),projLockMap);
            }
            else
            {
                Map<String,Project_Time_Tracking__c> timeEntryMap = new Map<String,Project_Time_Tracking__c>();
                if(hasTimecard.get(timeEntryMonth.Date__c.toStartOfMonth())!=null)
                {
                    timeEntryMap =hasTimecard.get(timeEntryMonth.Date__c.toStartOfMonth());
                }
                timeEntryMap.put(timeEntryMonth.Project_Name__r.Company_project_name_formula__c,timeEntryMonth);
                hasTimecard.put(timeEntryMonth.Date__c.toStartOfMonth(),timeEntryMap);

            }
        }
        List<Boolean> lockCheckList = new List<Boolean>();

        for(Project_Time_Tracking__c timeEntry:userTimecards)
        {
                List<String> templst =mtdMapDaily.get(timeEntry.Project_Name__r.Company_project_name_formula__c);
                Integer days = selectDateStart.daysBetween(timeEntry.Date__c);
                Integer curmonth;
                Integer nextmonth;
                if(isLockedMap.get(((selectDateStart+days).toStartOfMonth()))!=null)
                {
                    if(isLockedMap.get(((selectDateStart+days).toStartOfMonth())).get(timeEntry.Project_Name__r.Company_project_name_formula__c)!=null)
                    {
                        if(isLockedMap.get(((selectDateStart+days).toStartOfMonth())).get(timeEntry.Project_Name__r.Company_project_name_formula__c))
                        {
                         templst[days] = 'LockedCell'+String.valueOf(timeEntry.Hours__c);   
                        }
                        else
                        {
                            templst[days] = String.valueOf(timeEntry.Hours__c);
                        }
                    }
                    else
                    {
                    templst[days] = String.valueOf(timeEntry.Hours__c);
                    }
                }
                else
                {
                    templst[days] = String.valueOf(timeEntry.Hours__c);
                }
                mtdMapDaily.put(timeEntry.project_Name__r.Company_project_name_formula__c,tempLst);
        }
        for(String proj:mtdMapDaily.keySet())
        {
            List<String> tempTempList = mtdMapDaily.get(proj);
            Boolean notEmpty = false;
            Integer lockmonthselect = 0;
            if(date.today().day()<15)
            {
                lockmonthselect = -1;
            }
            for(Integer st=0; st<7; st++)
            {
                if(isLockedMap.get(((selectDateStart+st).toStartOfMonth()))!=null)
                {
                  if(isLockedMap.get(((selectDateStart+st).toStartOfMonth())).get(proj)!=null)
                  {  
                      if(tempTempList[st]==''&&tempTempList[st]!='EndDate'&&isLockedMap.get(((selectDateStart+st).toStartOfMonth())).get(proj))
                      {
                        tempTempList[st]='LockedCell';
                      }
                  }
                  else if(hasTimecard.get(((selectDateStart+st).toStartOfMonth()))==null && (selectDateStart+st)<(date.today().toStartOfMonth()))
                  {
                        tempTempList[st]='LockedCell';
                   }
                   else if(hasTimecard.get(((selectDateStart+st).toStartOfMonth())).get(proj)==null && (selectDateStart+st)<(date.today().toStartOfMonth()))
                   {
                       tempTempList[st]='LockedCell';
                   }
               }
               else if(hasTimecard.get(((selectDateStart+st).toStartOfMonth()))==null && (selectDateStart+st)<(date.today().toStartOfMonth().addMonths(lockmonthselect)))
               {
                    tempTempList[st]='LockedCell';
               }
               else if(hasTimecard.get(((selectDateStart+st).toStartOfMonth()))!=null && hasTimecard.get(((selectDateStart+st).toStartOfMonth())).get(proj)==null && (selectDateStart+st)<(date.today().toStartOfMonth().addMonths(lockmonthselect)))
               {
                   tempTempList[st]='LockedCell';
               }
            }
        }
    }

    public String stripQuotes(String name)
    {
        name = name.replace('\'', '\\\'');
        return name;
    }
    //General refresh all elements function
    public PageReference mtdHours()
    {
        statusStorage = new Map<String,tempStatusStorage>();
        selectedProject = '';
        currentPercentComplete = 0;
        //currentComments = '';
        currentLastSteps = '';
        currentNextSteps = '';
        currentDueDate = '';
        currentPercentCompleteLastModified = '';
        currentLastStepsLastModified = '';
        currentNextStepsLastModified = '';
        //currentCommentsLastModified = '';
        currentDateStatus = '';
        isPrevPercentSame = false;
        mapProjectToWGHours = new Map<String,Map<ID,Decimal>>();
        mapProjectToLTDWGHours = new Map<String,Map<ID,Decimal>>();
        Decimal mtdHoursAll = 0.00;
        selectUserChanged();
        getUserTotalMTDHours();
        mtdMap = new Map<String,String>();
        mapPrjCmpnyNameToEndDate = new Map<String,String>();
        mapPrjCmpnyNameToHealth= new Map<String,String>();
        mapPrjCmpnyNameToEffort= new Map<String,String>();
        lstEndDateWrapper = new List<EndDateWrapper>();
        lstHealthWrapper = new List<HealthWrapper>();
        lstEffortWrapper = new List<EffortWrapper>();
        List<User> currUser = [SELECT ID,Time_Entry_Preference__c FROM USER WHERE ID =:selectedUser];
        userContact = new List<Contact>();
        if(currUser.size()>0)
        {
            userContact = [SELECT ID, Name FROM Contact where Salesforce_User__c =: currUser[0].ID];
            dailyOrMonthly = currUser[0].Time_Entry_Preference__c;
        }
        workingGroups = new List<External_Working_Group_Member__c>();
        if(userContact.size()>0){
            if(seeAllProjects)
                workingGroups = [SELECT ID,AS_Project__r.End_Date__c,AS_Project__c,AS_Project__r.Name,AS_Project__r.Project_Health__c,AS_Project__r.Effort__C,AS_Project__r.Company_project_name_formula__c,AS_Project__r.Portfolio_Company__r.Name,Contact__c,End_Date__c FROM External_Working_Group_Member__c WHERE AS_Project__c!=null AND AS_Project__r.Active__c =true AND (End_Date__c >: Date.valueof(selectDate) OR End_Date__c =: null)];
            else
                workingGroups = [SELECT ID,AS_Project__r.End_Date__c,AS_Project__c,AS_Project__r.Name,AS_Project__r.Project_Health__c,AS_Project__r.Effort__C,AS_Project__r.Company_project_name_formula__c,AS_Project__r.Portfolio_Company__r.Name,Contact__c,End_Date__c FROM External_Working_Group_Member__c WHERE Contact__c =: userContact[0].ID AND AS_Project__c!=null AND AS_Project__r.Active__c =true AND (End_Date__c >: Date.valueof(selectDate) OR End_Date__c =: null)];
        }
        getOtherProjects();
        getClosedProjects();
        List<ID> projects = new List<ID>();
        
        for(External_Working_Group_Member__c wg: workingGroups)
        {
            if(!mapPrjCmpnyNameToEndDate.containsKey(wg.AS_Project__r.Company_project_name_formula__c))
            {
                if(wg.AS_Project__r.End_Date__c != null)
                {
                    mapPrjCmpnyNameToEndDate.put(wg.AS_Project__r.Company_project_name_formula__c, String.valueOf(wg.AS_Project__r.End_Date__c));
                    lstEndDateWrapper.add(new EndDateWrapper(wg.AS_Project__r.Company_project_name_formula__c, String.valueOf(wg.AS_Project__r.End_Date__c)));
                }
                else
                {
                    mapPrjCmpnyNameToEndDate.put(wg.AS_Project__r.Company_project_name_formula__c, '');
                    lstEndDateWrapper.add(new EndDateWrapper(wg.AS_Project__r.Company_project_name_formula__c, ''));
                }   
            }
             if(!mapPrjCmpnyNameToHealth.containsKey(wg.AS_Project__r.Company_project_name_formula__c))
            {
                if(wg.AS_Project__r.Project_Health__c != null)
                {
                    mapPrjCmpnyNameToHealth.put(wg.AS_Project__r.Company_project_name_formula__c, wg.AS_Project__r.Project_Health__c);
                    lstHealthWrapper.add(new HealthWrapper(wg.AS_Project__r.Company_project_name_formula__c, wg.AS_Project__r.Project_Health__c));
                }
                else
                {
                    mapPrjCmpnyNameToHealth.put(wg.AS_Project__r.Company_project_name_formula__c, '');
                    lstHealthWrapper.add(new HealthWrapper(wg.AS_Project__r.Company_project_name_formula__c, ''));
                }   
            }
             if(!mapPrjCmpnyNameToEffort.containsKey(wg.AS_Project__r.Company_project_name_formula__c))
            {
                if(wg.AS_Project__r.Effort__c != null)
                {
                    mapPrjCmpnyNameToEffort.put(wg.AS_Project__r.Company_project_name_formula__c, wg.AS_Project__r.Effort__c);
                    lstEffortWrapper.add(new EffortWrapper(wg.AS_Project__r.Company_project_name_formula__c, wg.AS_Project__r.Effort__c));
                }
                else
                {
                    mapPrjCmpnyNameToEffort.put(wg.AS_Project__r.Company_project_name_formula__c, '');
                    lstEffortWrapper.add(new EffortWrapper(wg.AS_Project__r.Company_project_name_formula__c, ''));
                }   
            }               
            projects.add(wg.AS_Project__c);
            mtdMap.put(wg.AS_Project__r.Company_project_name_formula__c,'0.00');
            mtdMapHoursProject.put(wg.AS_Project__r.Company_project_name_formula__c,0.00);
            LTDMapHoursProject.put(wg.AS_Project__r.Company_project_name_formula__c,0.00);
            mapWGMTDHoursText.put(wg.AS_Project__r.Company_project_name_formula__c,'');
            mapWGLTDHoursText.put(wg.AS_Project__r.Company_project_name_formula__c,'');
            mtdMapNames.put(wg.AS_Project__r.Company_project_name_formula__c,wg.AS_Project__r.Name);
            mtdMapNamesNoSpace.put(wg.AS_Project__r.Company_project_name_formula__c,removeSpace(wg.AS_Project__r.Name));
            mapNamesToCompany.put(wg.AS_Project__r.Company_project_name_formula__c,wg.AS_Project__r.Portfolio_Company__r.Name);

            if((Date.today().Day()>15 && Date.valueOf(selectDate).toStartofMonth()<Date.today().toStartofMonth())||(Date.valueOf(selectDate).toStartofMonth()<(Date.today().toStartofMonth()-1).toStartofMonth()))
                existingTimecardsMap.put(wg.AS_Project__r.Company_project_name_formula__c,'LockedCell0.00');
            else
                existingTimecardsMap.put(wg.AS_Project__r.Company_project_name_formula__c,'0.00');
        }
        Date dateselect;
        if(dailyOrMonthly=='Daily')
        {
            weekOrMonth = 'Week';
            dateselect = (Date.valueOf(selectDate)-1).toStartOfWeek()+1;
        }
        else
        {
            weekOrMonth = 'Month';
            dateSelect = Date.valueOf(selectDate);
        }

        List<AS_Project__c> totalProjects = [SELECT ID, NAME,Company_project_name_formula__c FROM AS_Project__c];
        for(AS_Project__c p:totalProjects)
        {
            projectNameMap.put(p.Company_project_name_formula__c,p.ID);
        }

        Date selectDateVal = dateSelect;
        Date selectDateStart = selectDateVal.toStartOfMonth();
        Date selectDateStartYear = Date.valueof(selectDateVal.year() + '-01-01');
        Date selectDateEndYear = Date.valueof((selectDateVal.year()+1) + '-01-01');
        Integer selectDateDays = Date.daysInMonth(selectDateVal.year(), selectDateVal.month())-1;
        Date selectDateEnd = selectDateStart+selectDateDays;
        if(dailyOrMonthly=='Monthly')
        {
            getExistingTimecards(projects,selectDateStart,selectDateEnd);
        }
        List<Project_Time_Tracking__c> userTimecards = [SELECT ID, Hours__c,Project_Name__r.End_Date__c,Project_Name__r.Project_Health__c,Project_Name__r.Effort__c,Project_Name__r.Name,Project_Name__r.Company_project_name_formula__c,Project_Name__c,Date__c from Project_Time_Tracking__c where Resource_User__c =: selectedUser AND Project_Name__c in:projects AND Date__c >=: selectDateStart AND Date__c <=: selectDateEnd];
        List<Project_Time_Tracking__c> allWGMembersTimecards = [SELECT ID, Hours__c,Project_Name__r.End_Date__c,Project_Name__r.Name,Project_Name__r.Company_project_name_formula__c,Project_Name__c,Date__c,Resource_User__c from Project_Time_Tracking__c where Project_Name__c in: projects];//[SELECT ID, Hours__c,Project_Name__r.End_Date__c,Project_Name__r.Name,Project_Name__r.Company_project_name_formula__c,Project_Name__c,Date__c,Resource_User__c from Project_Time_Tracking__c where Project_Name__c in: projects OR Project_Name__c in:allOtherActiveProjectsIDs];
        for(Project_Time_Tracking__c timeEntry:userTimecards)
        {
            if(!mapPrjCmpnyNameToEndDate.containsKey(timeEntry.Project_Name__r.Company_project_name_formula__c))
            {
                if(timeEntry.Project_Name__r.End_Date__c != null)
                {
                    lstEndDateWrapper.add(new EndDateWrapper(timeEntry.Project_Name__r.Company_project_name_formula__c, String.valueOf(timeEntry.Project_Name__r.End_Date__c)));
                    mapPrjCmpnyNameToEndDate.put(timeEntry.Project_Name__r.Company_project_name_formula__c, String.valueOf(timeEntry.Project_Name__r.End_Date__c));
                }
                else    
                {
                    lstEndDateWrapper.add(new EndDateWrapper(timeEntry.Project_Name__r.Company_project_name_formula__c, ''));
                    mapPrjCmpnyNameToEndDate.put(timeEntry.Project_Name__r.Company_project_name_formula__c, '');
                }
            }
            if(!mapPrjCmpnyNameToHealth.containsKey(timeEntry.Project_Name__r.Company_project_name_formula__c))
            {
                if(timeEntry.Project_Name__r.Project_Health__c != null)
                {
                    lstHealthWrapper.add(new HealthWrapper(timeEntry.Project_Name__r.Company_project_name_formula__c, timeEntry.Project_Name__r.Project_Health__c));
                    mapPrjCmpnyNameToHealth.put(timeEntry.Project_Name__r.Company_project_name_formula__c, timeEntry.Project_Name__r.Project_Health__c);
                }
                else    
                {
                    lstHealthWrapper.add(new HealthWrapper(timeEntry.Project_Name__r.Company_project_name_formula__c, ''));
                    mapPrjCmpnyNameToHealth.put(timeEntry.Project_Name__r.Company_project_name_formula__c, '');
                }
            }
            if(!mapPrjCmpnyNameToEffort.containsKey(timeEntry.Project_Name__r.Company_project_name_formula__c))
            {
                if(timeEntry.Project_Name__r.Effort__c != null)
                {
                    lstEffortWrapper.add(new EffortWrapper(timeEntry.Project_Name__r.Company_project_name_formula__c, timeEntry.Project_Name__r.Effort__c));
                    mapPrjCmpnyNameToEffort.put(timeEntry.Project_Name__r.Company_project_name_formula__c, timeEntry.Project_Name__r.Effort__c);
                }
                else    
                {
                    lstEffortWrapper.add(new EffortWrapper(timeEntry.Project_Name__r.Company_project_name_formula__c, ''));
                    mapPrjCmpnyNameToEffort.put(timeEntry.Project_Name__r.Company_project_name_formula__c, '');
                }
            }
            if(mtdMap.get(timeEntry.Project_Name__r.Company_project_name_formula__c)==null)
            {
                mtdMap.put(timeEntry.Project_Name__r.Company_project_name_formula__c,String.valueOf(timeEntry.Hours__c));
            }
            else
            {

                Decimal totalHours = Decimal.valueOf(mtdMap.get(timeEntry.Project_Name__r.Company_project_name_formula__c));
                totalHours += timeEntry.Hours__c;
                mtdMap.put(timeEntry.Project_Name__r.Company_project_name_formula__c,String.valueOf(totalHours));
            }
        }
        strEndDateWrapper = JSON.serialize(lstEndDateWrapper);
        strEndDateWrapper = stripQuotes(strEndDateWrapper);
        strHealthWrapper = JSON.serialize(lstHealthWrapper);
        strHealthWrapper = stripQuotes(strHealthWrapper);
        strEffortWrapper = JSON.serialize(lstEffortWrapper);
        strEffortWrapper = stripQuotes(strEffortWrapper);
        for(Project_Time_Tracking__c alltimeEntry:allWGMembersTimecards)
        {
            //MTD WG Member Hours gathering
            if(alltimeEntry.Date__c >= selectDateStart && allTimeEntry.Date__c <= selectDateEnd)
            {
                if(mapProjectToWGHours.get(allTimeEntry.Project_Name__r.Company_project_name_formula__c)==null)
                {
                    Map<ID,Decimal> WGmembHours = new Map<ID,Decimal>();
                    WGmembHours.put(allTimeEntry.Resource_User__c,allTimeEntry.Hours__c);
                    mapProjectToWGHours.put(allTimeEntry.Project_Name__r.Company_project_name_formula__c,WGmembHours);
                }
                else
                {
                    Map<ID,Decimal> WGmembHours = mapProjectToWGHours.get(allTimeEntry.Project_Name__r.Company_project_name_formula__c);
                    if(WGmembHours.get(allTimeEntry.Resource_User__c)==null)
                    {
                        WGmembHours.put(allTimeEntry.Resource_User__c,allTimeEntry.Hours__c);
                    }
                    else
                    {
                        Decimal memberHours = WGmembHours.get(allTimeEntry.Resource_User__c);
                        memberHours+= allTimeEntry.Hours__c;
                         WGmembHours.put(allTimeEntry.Resource_User__c,memberHours);
                    }
                    mapProjectToWGHours.put(allTimeEntry.Project_Name__r.Company_project_name_formula__c,WGmembHours);
                }
                Decimal sumHoursMTD = mtdMapHoursProject.get(allTimeEntry.Project_Name__r.Company_project_name_formula__c);
                sumHoursMTD += allTimeEntry.Hours__c;
                mtdMapHoursProject.put(allTimeEntry.Project_Name__r.Company_project_name_formula__c,sumHoursMTD);
                
            }
            //LTD WG Member Hours gathering
            if(mapProjectToLTDWGHours.get(allTimeEntry.Project_Name__r.Company_project_name_formula__c)==null)
            {
                Map<ID,Decimal> WGmembHours = new Map<ID,Decimal>();
                WGmembHours.put(allTimeEntry.Resource_User__c,allTimeEntry.Hours__c);
                mapProjectToLTDWGHours.put(allTimeEntry.Project_Name__r.Company_project_name_formula__c,WGmembHours);
            }
            else
            {
                Map<ID,Decimal> WGmembHours = mapProjectToLTDWGHours.get(allTimeEntry.Project_Name__r.Company_project_name_formula__c);
                if(WGmembHours.get(allTimeEntry.Resource_User__c)==null)
                {
                    WGmembHours.put(allTimeEntry.Resource_User__c,allTimeEntry.Hours__c);
                }
                else
                {
                    Decimal memberHours = WGmembHours.get(allTimeEntry.Resource_User__c);
                    memberHours+= allTimeEntry.Hours__c;
                    WGmembHours.put(allTimeEntry.Resource_User__c,memberHours);
                }
                mapProjectToLTDWGHours.put(allTimeEntry.Project_Name__r.Company_project_name_formula__c,WGmembHours);
            }

            Decimal sumHoursLTD = LTDMapHoursProject.get(allTimeEntry.Project_Name__r.Company_project_name_formula__c);
            sumHoursLTD += alltimeEntry.Hours__c;
            LTDMapHoursProject.put(allTimeEntry.Project_Name__r.Company_project_name_formula__c,sumHoursLTD);
        }
        for(String selectProject:mapProjectToLTDWGHours.keyset())
        {
            String popupTextMTD = '';
            String popupTextLTD = '';
            if(mapProjectToWgHours.get(selectProject)!=null)
            {
                Map<ID,Decimal> selectWGMembMap = mapProjectToWgHours.get(selectProject);
                for(ID selectWGMembID: selectWGMembMap.keySet())
                {
                    popupTextMTD += mapUserToInitials.get(selectWGMembID)+ ' : ' + selectWGMembMap.get(selectWGMembID) + '<br />';
                }
                mapWGMTDHoursText.put(selectProject,popupTextMTD);
            }
            if(mapProjectToLTDWgHours.get(selectProject)!=null)
            {
                Map<ID,Decimal> selectWGMembMap = mapProjectToLTDWgHours.get(selectProject);
                for(ID selectWGMembID: selectWGMembMap.keySet())
                {
                    popupTextLTD += mapUserToInitials.get(selectWGMembID)+ ' : ' + selectWGMembMap.get(selectWGMembID) + '<br />';
                }
                mapWGLTDHoursText.put(selectProject,popupTextLTD);
            }
        }
        if(dailyOrMonthly=='Daily')
        {
            fillDailyExistingTimecards();
        }
        else
        {
            fillTempDaily();
        }
        getAllCrossPortfolio();
        getProjectClosedDates();
        System.debug(mtdMap);
        return null;
    }

    public void loadStatusLastModified()
    {
        Boolean foundPercent = false;
        Boolean foundLastSteps = false;
        Boolean foundNextSteps = false;
        //Boolean foundComments = false;
        currentPercentCompleteLastModified = '';
        currentLastStepsLastModified = '';
        currentNextStepsLastModified = '';
        //currentCommentsLastModified = '';
        String createdDate;
        String createdBy;

        Date dateselect;
        if(dailyOrMonthly=='Daily')
        {
            dateSelect= (Date.valueOf(selectDate)-1).toStartOfWeek()+1;
        } 
        else
        {
            dateSelect=date.valueOf(selectDate);
        }
        Date month = dateselect.toStartOfMonth();
        Map<Id,User> userMap = new Map<Id,User>([SELECT ID, NAME FROM USER]);
        //List<AS_Project_Status__c> projectStatuses = [SELECT Last_Steps__c,Percent_Complete__c,Next_Steps__c,Comments__c from AS_Project_Status__c WHERE AS_Project__r.Company_project_name_formula__c =: selectedProject and Month_Ending__c =:month LIMIT 1];
        List<AS_Project_Status__c> projectStatuses = [SELECT Last_Steps__c,Percent_Complete__c,Next_Steps__c from AS_Project_Status__c WHERE AS_Project__r.Company_project_name_formula__c =: selectedProject and Month_Ending__c =:month LIMIT 1];
        List<AS_Project_Status__c> projectStatusHistory = [SELECT (Select OldValue, NewValue, Field, CreatedDate,CreatedByID From Histories Order By CreatedDate DESC) FROM AS_Project_Status__c where AS_Project__r.Company_project_name_formula__c =: selectedProject and Month_Ending__c =:month LIMIT 1];
        if(projectStatusHistory.size()>0)
        {
            List<AS_Project_Status__History> historyRecord = projectStatusHistory[0].Histories;
            for(Integer i =0; i<historyRecord.size();i++)
            {
                if(historyRecord[i].Field == 'Percent_Complete__c' && foundPercent ==false)
                {
                    foundPercent = true;
                    if(historyRecord[i].CreatedDate.minute()<10)
                        currentPercentCompleteLastModified = userMap.get(historyRecord[i].CreatedByID).Name + ' ' + historyRecord[i].CreatedDate.format('M/d/y h:0ma');
                    else
                        currentPercentCompleteLastModified = userMap.get(historyRecord[i].CreatedByID).Name + ' ' + historyRecord[i].CreatedDate.format('M/d/y h:ma');
                }
                else if(historyRecord[i].Field == 'Last_Steps__c' && foundLastSteps ==false)
                {
                    foundLastSteps =  true;
                    if(historyRecord[i].CreatedDate.minute()<10)
                     currentLastStepsLastModified = userMap.get(historyRecord[i].CreatedByID).Name + ' ' + historyRecord[i].CreatedDate.format('M/d/y h:0ma');
                    else
                     currentLastStepsLastModified = userMap.get(historyRecord[i].CreatedByID).Name + ' ' + historyRecord[i].CreatedDate.format('M/d/y h:ma');
                }
                else if(historyRecord[i].Field == 'Next_Steps__c' && foundNextSteps ==false)
                {
                    foundNextSteps = true;
                    if(historyRecord[i].CreatedDate.minute()<10)
                     currentNextStepsLastModified = userMap.get(historyRecord[i].CreatedByID).Name + ' ' + historyRecord[i].CreatedDate.format('M/d/y h:0ma');
                    else
                     currentNextStepsLastModified = userMap.get(historyRecord[i].CreatedByID).Name + ' ' + historyRecord[i].CreatedDate.format('M/d/y h:ma');
                }
                /*else if(historyRecord[i].Field == 'Comments__c' && foundComments ==false)
                {
                    foundComments = true;
                    if(historyRecord[i].CreatedDate.minute()<10)
                     currentCommentsLastModified = userMap.get(historyRecord[i].CreatedByID).Name + ' ' + historyRecord[i].CreatedDate.format('M/d/y h:0ma');
                    else
                     currentCommentsLastModified = userMap.get(historyRecord[i].CreatedByID).Name + ' ' + historyRecord[i].CreatedDate.format('M/d/y h:ma');
                }*/
                else if(historyRecord[i].Field == 'created')
                {
                    if(historyRecord[i].CreatedDate.minute()<10)
                      createdDate = historyRecord[i].CreatedDate.format('M/d/y h:0ma');
                    else
                      createdDate = historyRecord[i].CreatedDate.format('M/d/y h:ma');
                    createdBy = UserMap.get(historyRecord[i].CreatedByID).Name;
                }
                //if(foundPercent==true && foundLastSteps == true && foundNextSteps==true && foundComments == true)
                if(foundPercent==true && foundLastSteps == true && foundNextSteps==true)
                {
                    break;
                }
            }
            //history not found, check to see if record is created but has not been changed
            if(projectStatuses.size()>0)
            {
                if(foundPercent==false)
                {
                    if(projectStatuses[0].Percent_Complete__c!=0)
                    {
                        currentPercentCompleteLastModified = createdBy + ' ' + createdDate;
                    }
                }
                if(foundLastSteps ==false)
                {
                     if(projectStatuses[0].Last_Steps__c!=null)
                     {
                        currentLastStepsLastModified = createdBy + ' ' + createdDate;
                    }
                }
                if(foundNextSteps==false)
                {
                     if(projectStatuses[0].Next_Steps__c!=null)
                     {
                        currentNextStepsLastModified = createdBy + ' ' + createdDate;
                     }
                }
                /*if(foundComments==false)
                {
                     if(projectStatuses[0].Comments__c!=null)
                     {
                        currentCommentsLastModified = createdBy + ' ' + createdDate;
                    }
                }*/
            }
        }

    }
    public PageReference loadStatus()
    {
        if(selectedProject!='')
        {
            List<Reporting_Month__c> currentProjCustomSetting = [SELECT Day_of_Month__c from Reporting_Month__c];
            Integer dayOfMonth =15;
            if(currentProjCustomSetting.size()>0)
            {
                dayofMonth = Integer.valueof(currentProjCustomSetting[0].Day_of_Month__c);
            }
            List<AS_Project_Status__c> lstPerCheck = [SELECT Percent_Complete__c FROM AS_Project_Status__c WHERE AS_Project__r.Company_project_name_formula__c =: selectedProject AND Month_Ending__c != null AND CALENDAR_MONTH(Month_Ending__c) >: Date.valueof(selectDate).addMonths(-2).month() AND CALENDAR_MONTH(Month_Ending__c) <=: Date.valueof(selectDate).month() ORDER BY Month_Ending__c];
            if(lstPerCheck.size() > 1)
            {
                isPrevPercentSame = (lstPerCheck[0].Percent_Complete__c == lstPerCheck[1].Percent_Complete__c) ? true : false;
            }
            
            loadStatusLastModified();
            Date dateselect= null;
            if(dailyOrMonthly=='Daily')
            {
                dateselect = (Date.valueOf(selectDate)-1).toStartOfWeek()+1;
            }
            else
            {
                dateselect = Date.valueOf(selectDate);
            }
            if(statusStorage.get(selectedProject)==null)
            {
                 //List<AS_Project_Status__c> projectStat = [SELECT Percent_Complete__c,AS_Project__r.Company_project_name_formula__c,Comments__c,Last_Steps__c,Month_Ending__c,Next_Steps__c,Due_Date__c,Locked__c from AS_Project_Status__c where AS_Project__r.Company_project_name_formula__c =:selectedProject Order BY Month_Ending__c DESC];
                 List<AS_Project_Status__c> projectStat = [SELECT Percent_Complete__c,AS_Project__r.Company_project_name_formula__c,Last_Steps__c,Month_Ending__c,Next_Steps__c,Due_Date__c,Locked__c from AS_Project_Status__c where AS_Project__r.Company_project_name_formula__c =:selectedProject Order BY Month_Ending__c DESC];
                 Boolean noStatus = true;
                 for(AS_Project_Status__c status: projectStat)
                 {
                    
                    if(dateselect.toStartOfMonth()==status.Month_Ending__c)
                    {
                        noStatus = false;
                        if(status.Locked__c||(dateselect>=Date.today().toStartofMonth().addMonths(1)|| (Date.today().day()<dayOfMonth && dateSelect.month()==Date.today().month())))
                        {
                            currentStatusLocked = 'LockedCell';
                        }
                        else
                        {
                            currentStatusLocked = '';
                        }
                            currentPercentComplete = status.Percent_Complete__c;
                            //currentComments = status.Comments__c;
                            currentNextSteps = status.Next_Steps__c;
                            currentLastSteps = status.Last_Steps__c;
                            if(status.Due_Date__c!=null)
                            {
                            currentDueDate = status.Due_Date__c.month()+'/'+status.Due_Date__c.day()+'/'+status.Due_Date__c.year();
                            }
                            else
                            {
                                currentDueDate = '';
                            }
                        break;
                    }
                 }
                 if(noStatus)
                 {
                        currentPercentComplete = 0;
                        //currentComments = '';
                        currentNextSteps = '';
                        currentDueDate = '';
                        //if(((Date.Valueof(selectDate))<(Date.Today().toStartOfMonth()-1).toStartofMonth())||(Date.today().day()>=15 && (Date.Valueof(selectDate))<Date.Today().toStartOfMonth())||(dateselect>=Date.today().toStartofMonth().addMonths(1)|| (Date.today().day()<dayOfMonth && dateSelect.month()==Date.today().month())))
                        if((dateselect>=Date.today().toStartofMonth().addMonths(1)|| (Date.today().day()<dayOfMonth && dateSelect.month()==Date.today().month())))
                        {
                             currentStatusLocked = 'LockedCell';
                        }
                        else
                        {
                            currentStatusLocked = '';  
                        }
                        if(projectStat.size()>0)
                        {
                            currentLastSteps = projectStat[0].Next_Steps__c;
                            currentPercentComplete = projectStat[0].Percent_Complete__c;
                            isPrevPercentSame = true;
                            //currentStatusLocked = '';
                            currentLastStepsLastModified = 'Transferred from ' + getMonthWord((Date.Valueof(selectDate).toStartOfMonth()-1).month()) + '\'s Next Steps';
                        }
                        else
                        {
                            currentLastSteps = '';
                        }
                 }
            }
            else
            {
                if(dateselect>=Date.today().toStartofMonth().addMonths(1)|| (Date.today().day()<dayOfMonth && dateSelect.month()==Date.today().month()))
                {
                    currentStatusLocked = 'LockedCell';
                }
                else
                {
                    currentStatusLocked='';
                }
                    currentPercentComplete = statusStorage.get(selectedProject).tempPercentComplete;
                    //currentComments = statusStorage.get(selectedProject).tempComments;
                    currentNextSteps = statusStorage.get(selectedProject).tempNextSteps;
                    currentLastSteps = statusStorage.get(selectedProject).tempLastSteps;
                    currentStatusLocked = statusStorage.get(selectedProject).templocked;
                    currentDueDate = statusStorage.get(selectedProject).tempDueDate;
            }
            if(dailyOrMonthly=='Daily')
            {
                currentDateStatus = getMonthWord(((Date.valueOf(selectDate)-1).toStartOfWeek()+1).month())+ ' ' + String.valueOf(((Date.valueOf(selectDate)-1).toStartOfWeek()+1).year());
            }
            else
            {
                currentDateStatus = getMonthWord((Date.valueOf(selectDate).month())) + ' ' + String.valueOf(Date.valueOf(selectDate).year());
            }

        }
        return null;
    }
    public String getMonthWord(Integer month)
    {
        String monthWord = '';
        if(month == 1)
            monthWord='- Jan';
        else if(month==2)
            monthWord='- Feb';
        else if(month==3)
            monthWord='- Mar';
        else if(month==4)
            monthWord='- Apr';
        else if(month==5)
            monthWord='- May';
        else if(month==6)
            monthWord='- Jun';
        else if(month==7)
            monthWord='- Jul';
        else if(month==8)
            monthWord='- Aug'; 
        else if(month==9)
            monthWord='- Sept';
        else if(month==10)
            monthWord='- Oct';
        else if(month==11)
            monthWord='- Nov';
        else if(month==12)
            monthWord='- Dec';
        return monthword;
    }
    public void prevWeek()
    {
        currentDate = (Date.valueOf(selectDate)-7).month()+'/'+(Date.valueOf(selectDate)-7).day()+'/'+(Date.valueOf(selectDate)-7).year();
        selectDate = (Date.valueOf(selectDate)-7).year()+'-'+(Date.valueOf(selectDate)-7).month()+'-'+(Date.valueOf(selectDate)-7).day();
        mtdHours();
        updateDateRange();
    }

    public void nextWeek()
    {
        currentDate = (Date.valueOf(selectDate)+7).month()+'/'+(Date.valueOf(selectDate)+7).day()+'/'+(Date.valueOf(selectDate)+7).year();
        selectDate = (Date.valueOf(selectDate)+7).year()+'-'+(Date.valueOf(selectDate)+7).month()+'-'+(Date.valueOf(selectDate)+7).day();
        mtdHours();
        updateDateRange();
    }

    public void getExistingTimecards(List<ID> projectList,Date dateStart,Date dateEnd)
    {
        List<Project_Time_Tracking__c> existingTimecards = [Select Date__c,Project_Name__r.Company_project_name_formula__c,Hours__c,Locked__c from Project_Time_Tracking__c where Project_Name__c in: projectList AND Date__c >=: dateStart AND Date__c <=: dateEnd AND Resource_User__c =:selectedUser];
        for(Project_Time_Tracking__c t:existingTimecards)
        {
            if(t.Locked__c)
            {
                if(t.Date__c.Day()==1)
                {
                    existingTimecardsMap.put(t.Project_Name__r.Company_project_name_formula__c,'LockedCell'+t.Hours__c);
                }
            }
            else
            {
                if(t.Date__c.Day()==1)
                {
                    existingTimecardsMap.put(t.Project_Name__r.Company_project_name_formula__c,String.valueOf(t.Hours__c));
                }
            }
        }
    }

    public void statusChanged()
    {
        if(currentPercentComplete!=null&&currentNextSteps!=null&&currentLastSteps!=null&&currentDueDate!=null)
        {
            tempStatusStorage enterStatus = new tempStatusStorage();
            tempStatusStorage oldtempStatus = statusStorage.get(selectedProject);
            if(oldtempStatus!=null)
            {
                Decimal oldPercent = oldtempStatus.tempPercentComplete;
                String oldNSteps = oldtempStatus.tempNextSteps;
                String oldLSteps = oldtempStatus.tempLastSteps;
               // String oldComments = oldtempStatus.tempComments;
                String oldlocked = oldtempStatus.tempLocked;
                String oldDueDate = oldtempStatus.tempDueDate;
                //Percent Changed
                if(oldPercent != currentPercentComplete)
                     enterStatus.tempPercentComplete = currentPercentComplete;
                else
                     enterStatus.tempPercentComplete = oldPercent;
                //NextSteps Changed
                if(oldNSteps != currentNextSteps)
                    enterStatus.tempNextSteps = currentNextSteps;
                else
                    enterStatus.tempNextSteps = oldNSteps;
                //LastSteps Changed
                if(oldLSteps != currentLastSteps)
                    enterStatus.tempLastSteps = currentLastSteps;
                else
                    enterStatus.tempLastSteps = oldLSteps;
                //Comments Changed
                /*if(oldComments != currentComments)
                   enterStatus.tempComments = currentComments;
                else
                    enterStatus.tempComments = oldComments;*/

                if(oldDueDate != currentDueDate)
                   enterStatus.tempDueDate = currentDueDate;
                else
                    enterStatus.tempDueDate = oldDueDate;

                enterStatus.templocked = currentStatusLocked;
                statusStorage.put(selectedProject,enterStatus);
            }
            else if(selectedProject!='')
            {
                enterStatus.tempPercentComplete = currentPercentComplete;
                enterStatus.tempLastSteps = currentLastSteps;
                enterStatus.tempNextSteps = currentNextSteps;
               // enterStatus.tempComments = currentComments;
                enterStatus.templocked = currentStatusLocked;
                enterStatus.tempDueDate = currentDueDate;
                statusStorage.put(selectedProject,enterStatus);
            }
        }
    }

    public void submitStatus()
    {
        Date dateSelect;
        if(dailyOrMonthly=='Daily')
        {
            dateselect = (Date.valueOf(selectDate)-1).toStartOfWeek()+1;
        }
        else
        {
            dateSelect = Date.valueOf(selectDate);
        }
        List<Reporting_Month__c> currentProjCustomSetting = [SELECT Day_of_Month__c from Reporting_Month__c];
        Integer dayOfMonth =15;
        if(currentProjCustomSetting.size()>0)
        {
            dayofMonth = Integer.valueof(currentProjCustomSetting[0].Day_of_Month__c);
        }
        //List<AS_Project_Status__c> statusList = [SELECT ID,Percent_Complete__c,Comments__c,Next_Steps__c,Last_Steps__c,Month_Ending__c,AS_Project__c,AS_Project__r.Company_project_name_formula__c,Due_Date__c FROM AS_Project_Status__c Where Month_Ending__c=:dateselect.toStartOfMonth()];
        List<AS_Project_Status__c> statusList = [SELECT ID,Percent_Complete__c,Next_Steps__c,Last_Steps__c,Month_Ending__c,AS_Project__c,AS_Project__r.Company_project_name_formula__c,Due_Date__c FROM AS_Project_Status__c Where Month_Ending__c=:dateselect.toStartOfMonth()];
        Map<String,AS_Project_Status__c> projectToStatus = new Map<String,AS_Project_Status__c>();
        for(AS_Project_Status__c pStat:statusList)
        {
            projectToStatus.put(pStat.AS_Project__r.Company_project_name_formula__c,pStat);
        }
        List<AS_Project_Status__c> updateStatuses = new List<AS_Project_Status__c>();
        List<AS_Project_Status__c> insertStatuses = new List<AS_Project_Status__c>();
        System.debug('thisisstatusstorage'+statusStorage);
        for(String proj:statusStorage.keySet())
        {
            tempStatusStorage status = statusStorage.get(proj);
                if(projectNameMap.get(proj)!=null)
                {
                    if(!(dateselect>=Date.today().toStartofMonth().addMonths(1)|| (Date.today().day()<dayOfMonth && dateSelect.month()==Date.today().month())))
                    {
                        if(projectToStatus.get(proj)!=null)
                        {
                            projectToStatus.get(proj).Percent_Complete__c = status.tempPercentComplete;
                            //projectToStatus.get(proj).Comments__c =status.tempComments;
                            projectToStatus.get(proj).Next_Steps__c= status.tempNextSteps;
                            projectToStatus.get(proj).Last_Steps__c= status.tempLastSteps;
                            if(status.tempDueDate!='')
                                projectToStatus.get(proj).Due_Date__c= Date.parse(status.tempDueDate);
                            else
                                projectToStatus.get(proj).Due_Date__c = null;
                            if(status.tempLocked!='LockedCell')
                                updateStatuses.add(projectToStatus.get(proj));
                        }
                        else
                        {
                            AS_Project_Status__c statusInsert = new AS_Project_Status__c();
                            statusInsert.Percent_Complete__c = status.tempPercentComplete;
                            //statusInsert.Comments__c =status.tempComments;
                            statusInsert.Next_Steps__c= status.tempNextSteps;
                            statusInsert.Last_Steps__c= status.tempLastSteps;
                            //statusInsert.Month_Ending__c= Date.valueOf(selectDate).toStartOfMonth();
                            statusInsert.Month_Ending__c=dateselect.toStartOfMonth();
                            if(status.tempDueDate!='')
                                statusInsert.Due_Date__c = Date.parse(status.tempDueDate);
                            else
                                statusInsert.Due_Date__c = null;
                            statusInsert.AS_Project__c = projectNameMap.get(proj);
                            if(status.tempLocked!='LockedCell')
                                insertStatuses.add(statusInsert);
                        }
                    }
                 }
        }
        update updateStatuses;
        insert insertStatuses;
    }
    public void addToProject() {
        External_Working_Group_Member__c addWorkingGroup = new External_Working_Group_Member__c();
        List<External_Working_Group_Member__c> existingWorkingGroups = new List<External_Working_Group_Member__c>();
        LIST<AS_Project__c> projList = [SELECT ID FROM AS_Project__c WHERE Company_project_name_formula__c =: addProject LIMIT 1];
        if(projList.size()>0&& userContact.size()>0)
        {
            existingWorkingGroups = [SELECT ID,End_Date__c,AS_Project__c, AS_Project__r.End_Date__c, Contact__c FROM External_Working_Group_Member__c where AS_Project__c =: projList[0].ID and Contact__c=:userContact[0].ID LIMIT 1];
        }
        if(existingWorkingGroups.size()>0)
        {
            existingWorkingGroups[0].End_Date__c = null;
            update existingWorkingGroups;
        }
        else
        {
            if(projList.size()>0)
            {
                addWorkingGroup.AS_Project__c = projList[0].ID;
                addWorkingGroup.Initial_Participation_Date__c = System.today();
                addWorkingGroup.Role__c = 'AS Resource';
                if(userContact.size()>0)
                {
                    addWorkingGroup.Contact__c = userContact[0].Id;
                }
            }
            insert addWorkingGroup;
        }
        
        //mtdHours();
    }
     public void reactivateProject() {
        External_Working_Group_Member__c addWorkingGroup = new External_Working_Group_Member__c();
        List<External_Working_Group_Member__c> existingWorkingGroups = new List<External_Working_Group_Member__c>();
        LIST<AS_Project__c> projList = [SELECT ID FROM AS_Project__c WHERE Company_project_name_formula__c =: reProject LIMIT 1];
        if(projList.size()>0&& userContact.size()>0)
        {
            existingWorkingGroups = [SELECT ID,End_Date__c,AS_Project__c, AS_Project__r.End_Date__c, Contact__c FROM External_Working_Group_Member__c where AS_Project__c =: projList[0].ID and Contact__c=:userContact[0].ID LIMIT 1];
            projList[0].Active__c=true;
            projList[0].Close_Date__c=null;
        }
        update projList;
        if(existingWorkingGroups.size()>0)
        {
            existingWorkingGroups[0].End_Date__c = null;
            update existingWorkingGroups;
        }
        else
        {
            if(projList.size()>0)
            {
                addWorkingGroup.AS_Project__c = projList[0].ID;
                addWorkingGroup.Initial_Participation_Date__c = System.today();
                addWorkingGroup.Role__c = 'AS Resource';
                if(userContact.size()>0)
                {
                    addWorkingGroup.Contact__c = userContact[0].Id;
                }
            }
            insert addWorkingGroup;
        }
        
        //mtdHours();
    }

    @RemoteAction
    public static boolean allStatusAccess()
    {
        List<GroupMember> pubgroup =[SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName='Edit_All_Project_Statuses'];
        ID curUser = UserInfo.getUserId();
        for(GroupMember mem:pubgroup)
        {
            if(mem.UserOrGroupID==curUser)
            {
                return true;
            }
        }
        return false;
    }
    @RemoteAction
    public static void radioChanged(Id userID,String radioSelect,String deleteTimeMonth)
    {
        List<User> updateUserList = [SELECT ID, Time_Entry_Preference__c FROM User where ID = : userId Limit 1];
        if(updateUserList.size()>0)
        {
            updateUserList[0].Time_Entry_Preference__c = radioSelect;
        }
        update updateUserList;
        List<Project_Time_Tracking__c> timeCardList = [SELECT ID, Date__c FROM Project_Time_Tracking__c where Resource_User__c=: userID];
        List<Project_Time_Tracking__c> deleteTimeCardList = new List<Project_Time_Tracking__c>();
        for(Project_Time_Tracking__c timeCard :timeCardList)
        {
            if(timecard.Date__c.monthsBetween(Date.valueof(Date.today()))==0)
            {
                deleteTimeCardList.add(timecard);
            }
        }
        delete deleteTimeCardList;
    }
    @RemoteAction
    public static boolean checkClosed(String projectName)
    {
       /* List<String> buttonValueSplit = projectName.split(' ',6);
        String buttonValue = buttonValueSplit[4];
        String buttonValueSub = buttonValue.substring(6,buttonValue.length());*/
        Boolean retValue = false;
        List<AS_Project__c> qProj = [SELECT ID, Close_Date__c FROM AS_Project__c where Company_project_name_formula__c =:projectName Limit 1];
        if(qProj.size()>0)
        {
            if(qProj[0].Close_Date__c!=null)
            {
                retValue=true;
            }
        }
        return retValue;
    }

    @RemoteAction
    public static String getProjectHealth()
    {
        String options = '';
        Schema.DescribeFieldResult fieldResult = AS_Project__c.Project_Health__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
           options+=f.getLabel()+'|';
        }
        options = options.removeEnd('|');
       return options;
    }

    @RemoteAction
    public static String getProjectEffort()
    {
        String options = '';
        Schema.DescribeFieldResult fieldResult = AS_Project__c.Effort__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
           options+=f.getLabel()+'|';
        }
        options = options.removeEnd('|');
       return options;
    }



    @RemoteAction
    public static void closeProject(String project) {
        List<AS_Project__c> getProject = [SELECT ID,Company_project_name_formula__c,Close_Date__c FROM AS_Project__c WHERE Company_project_name_formula__c =:project LIMIT 1];

        Date closedDate;
        if(getProject.size()>0)
        {
            List<External_Working_Group_Member__c> projMembers = [SELECT ID,End_Date__c From External_Working_Group_Member__c where AS_Project__c=:getProject[0].ID];
            Integer dayOfMonth = 1;
            List<Project_Closed_Date__c> currentProjCustomSetting = [SELECT Day_of_Month__c from Project_Closed_Date__c where Name =: getProject[0].Company_project_name_formula__c LIMIT 1];
            if(currentProjCustomSetting.size()>0)
            {
                dayofMonth = Integer.valueof(currentProjCustomSetting[0].Day_of_Month__c);
            }
            else
            {
                List<Project_Closed_Date__c> allProjCustomSetting = [SELECT Day_of_Month__c from Project_Closed_Date__c where Name = 'Systemprojcloseddate' LIMIT 1];
                if(allprojCustomSetting.size()>0)
                {
                    dayofMonth = Integer.valueof(allProjCustomSetting[0].Day_of_Month__c);
                }
            }
            if(dayOfMonth!=0)
            {
                Date today = date.today();
                today = today.addMonths(1);
                closedDate = Date.valueOf(today.year()+'-'+today.month()+'-'+dayOfMonth);
                getProject[0].Close_Date__c = closedDate;
            }
            for(External_Working_Group_Member__c wg:projMembers)
            {
                if((wg.End_Date__c!=null&&wg.End_Date__c>getProject[0].Close_Date__c)||(wg.End_Date__c==null))
                {
                    wg.End_Date__c=getProject[0].Close_Date__c;
                }
            }
            update projMembers;
        }

        update getProject;
    }
    @RemoteAction
    public static void removeProject(String project,ID userID) {
        List<Contact> uCon = [SELECT ID from Contact where Salesforce_User__c =: userID];
        if(uCon.size()>0)
        {
             List<External_Working_Group_Member__c> wGroups = [SELECT ID,End_Date__c FROM External_Working_Group_Member__c WHERE AS_Project__r.Company_project_name_formula__c =:project AND Contact__c =:uCon[0].ID];
             for(External_Working_Group_Member__c selectGroup:wGroups)
             {
                selectGroup.End_Date__c = Date.today();
             }
             update wGroups;
        }
       
    }

    @RemoteAction
    public static void SubmitTimeEntry(String projects,ID userID,String cDate,String dayOfWeek,String strPrjCmpnyNameToEndDate,String strPrjCmpnyNameToHealth,String strPrjCmpnyNameToEffort) {
        //Map<ID,AS_Project__c> mapIdToASProjectToUpdate = new Map<ID,AS_Project__c>();
        Map<String, Object> edates= (Map<String, Object>)JSON.deserializeUntyped(strPrjCmpnyNameToEndDate);
        Map<String, Object> pHealth= (Map<String, Object>)JSON.deserializeUntyped(strPrjCmpnyNameToHealth);
        Map<String, Object> pEffort= (Map<String, Object>)JSON.deserializeUntyped(strPrjCmpnyNameToEffort);

        List<AS_Project__c> updateProjects = [SELECT ID,Project_Health__c,End_Date__c,Effort__c, Company_project_name_formula__c from AS_Project__c where Company_project_name_formula__c in: edates.keyset() OR Company_project_name_formula__c in: pHealth.keySet() OR Company_project_name_formula__c in: pEffort.keySet()];
        //String strPrjToEndDate = strPrjCmpnyNameToEndDate.replaceFirst(',', '');
        List<Project_Time_Tracking__c> removeTimecards = new List<Project_Time_Tracking__c>();
        for(AS_Project__c uProject:updateProjects)
        {
            if(edates.get(uProject.Company_project_name_formula__c)!=null)
            {
                List<String> lstDateLiteral = ((String)edates.get(uProject.Company_project_name_formula__c)).split('/');
                if(lstDateLiteral.size() > 2)
                {
                    Date dtEndDate = Date.newInstance(Integer.valueOf(lstDateLiteral[2]), Integer.valueOf(lstDateLiteral[0]), Integer.valueOf(lstDateLiteral[1]));
                    uProject.End_Date__c = dtEndDate;
                    //mapIdToASProjectToUpdate.put(eProject.Id, new AS_Project__c(Id = eProject.Id, End_Date__c = dtEndDate));
                }
            }
            if(pHealth.get(uProject.Company_project_name_formula__c)!=null)
            {
                uProject.Project_Health__c =((String)pHealth.get(uProject.Company_project_name_formula__c));
            }
            if(pEffort.get(uProject.Company_project_name_formula__c)!=null)
            {
                uProject.Effort__c =((String)pEffort.get(uProject.Company_project_name_formula__c));
            }
        }
        update updateProjects;

        //Monthly
        if(dayOfWeek=='')
        {

            Date selectDate = Date.valueOf(cDate);
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(projects);
            Map<ID,AS_Project__c> currentUserProjects = new Map<Id,AS_Project__c>([SELECT ID, NAME,Company_project_name_formula__c,End_Date__c FROM AS_Project__c where Company_project_name_formula__c in:m.keyset()]);
            
            List<Project_Time_Tracking__c> timecards = new List<Project_Time_Tracking__c>();
            List<Project_Time_Tracking__c> existingTimecards = [Select ID,Project_Name__c,Project_Name__r.Company_project_name_formula__c,Hours__c from Project_Time_Tracking__c where Project_Name__c in: currentUserProjects.keyset() AND Date__c =:selectDate AND Resource_User__c =:userID];
            for(Project_Time_Tracking__c entry:existingTimecards)
            {
                if((String)m.get(entry.Project_Name__r.Company_project_name_formula__c)=='')
                {
                    removeTimecards.add(entry);
                }
                else if(Decimal.valueOf((String)m.get(entry.Project_Name__r.Company_project_name_formula__c))!=0)
                {
                    entry.Hours__c = Decimal.valueOf((String)m.get(entry.Project_Name__r.Company_project_name_formula__c));
                    currentUserProjects.remove(entry.Project_Name__c);
                }
            }
            update existingTimecards;
            delete removeTimecards;
            for(AS_Project__c selectProject:currentUserProjects.values())
            {
                //if(strPrjCmpnyNameToEndDate!=''&&strPrjCmpnyNameToEndDate!=null)
                //{
                    //Update End date for project
                    //for(String str : strPrjToEndDate.split(','))
                    //for(integer i =0; i<obj.size();i++)
                    //{
                        /*List<String> lstDateLiteral;
                        List<String> lstString = str.split('_');
                        if(lstString.size() > 1)
                            lstDateLiteral = lstString[1].split('/');
                        if(lstDateLiteral.size() > 2)
                           dtEndDate = Date.newInstance(Integer.valueOf(lstDateLiteral[2]), Integer.valueOf(lstDateLiteral[0]), Integer.valueOf(lstDateLiteral[1]));  
                        if(lstString.size() == 2 && selectProject.Company_project_name_formula__c == lstString[0])
                            mapIdToASProjectToUpdate.put(selectProject.Id, new AS_Project__c(Id = selectProject.Id, End_Date__c = dtEndDate));   */ 
                    //}
               // }
                if(Decimal.valueOf((String)m.get(selectProject.Company_project_name_formula__c))!=0)
                {
                    Project_Time_Tracking__c timeEntry = new Project_Time_Tracking__c();
                    timeEntry.Hours__c = Decimal.valueOf((String)m.get(selectProject.Company_project_name_formula__c));
                    timeEntry.Project_Name__c = selectProject.ID;
                    timeEntry.Resource_User__c = userID;
                    timeEntry.Date__c = selectDate;
                    timecards.add(timeEntry);
                }      
            }
            //update mapIdToASProjectToUpdate.values();
            insert timecards;
        }
        else
        {
            Date startDate = (Date.valueOf(cDate)-1).toStartOfWeek()+1;
            Integer daySelectNumber =0;

            if(dayOfWeek=='Mon')
                daySelectNumber = 0;
            else if(dayOfWeek=='Tue')
                daySelectNumber = 1;
            else if(dayOfWeek=='Wed')
                daySelectNumber = 2;
            else if(dayOfWeek=='Thu')
                daySelectNumber = 3;
            else if(dayOfWeek=='Fri')
                daySelectNumber = 4;
            else if(dayOfWeek=='Sat')
                daySelectNumber = 5;
            else if(dayOfWeek=='Sun')
                daySelectNumber = 6;

            Date selectDate = startDate+daySelectNumber;
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(projects);
            Map<ID,AS_Project__c> currentUserProjects = new Map<Id,AS_Project__c>([SELECT ID, NAME,Company_project_name_formula__c,End_Date__c FROM AS_Project__c where Company_project_name_formula__c in:m.keyset()]);

            List<Project_Time_Tracking__c> timecards = new List<Project_Time_Tracking__c>();
            List<Project_Time_Tracking__c> existingTimecards = [Select ID,Project_Name__c,Project_Name__r.Company_project_name_formula__c,Hours__c from Project_Time_Tracking__c where Project_Name__c in: currentUserProjects.keyset() AND Date__c =:selectDate AND Resource_User__c =:userID];
            for(Project_Time_Tracking__c entry:existingTimecards)
            {
                if((String)m.get(entry.Project_Name__r.Company_project_name_formula__c)=='')
                {
                    removeTimecards.add(entry);
                }
                else if((String)m.get(entry.Project_Name__r.Company_project_name_formula__c)!='EndDate')
                {
                    entry.Hours__c = Decimal.valueOf((String)m.get(entry.Project_Name__r.Company_project_name_formula__c));
                    currentUserProjects.remove(entry.Project_Name__c);
                }
            }
            update existingTimecards;
            delete removeTimecards;
            for(AS_Project__c selectProject:currentUserProjects.values())
            {
                 /* if(strPrjCmpnyNameToEndDate!=''&&strPrjCmpnyNameToEndDate!=null)
                {
                      if(edates.get(selectProject.Company_project_name_formula__c)!=null)
                        {
                            List<String> lstDateLiteral = ((String)edates.get(selectProject.Company_project_name_formula__c)).split('/');
                            if(lstDateLiteral.size() > 2)
                            {
                                Date dtEndDate = Date.newInstance(Integer.valueOf(lstDateLiteral[2]), Integer.valueOf(lstDateLiteral[0]), Integer.valueOf(lstDateLiteral[1]));
                                mapIdToASProjectToUpdate.put(selectProject.Id, new AS_Project__c(Id = selectProject.Id, End_Date__c = dtEndDate));
                            }
                        }
                /*for(String str : strPrjToEndDate.split(','))
                {
                    Date dtEndDate;
                    List<String> lstDateLiteral= new List<String>();
                    List<String> lstString = str.split('_');
                    if(lstString.size() > 1)
                        lstDateLiteral = lstString[1].split('/');
                    if(lstDateLiteral.size() > 2)
                    {
                        System.debug(Integer.valueOf(lstDateLiteral[2])+'Year');
                            System.debug(Integer.valueOf(lstDateLiteral[0])+'month');
                                System.debug(Integer.valueOf(lstDateLiteral[1])+'day');
                       dtEndDate = Date.newInstance(Integer.valueOf(lstDateLiteral[2]), Integer.valueOf(lstDateLiteral[0]), Integer.valueOf(lstDateLiteral[1]));  
                    }
                    if(lstString.size() == 2 && selectProject.Company_project_name_formula__c == lstString[0])
                        mapIdToASProjectToUpdate.put(selectProject.Id, new AS_Project__c(Id = selectProject.Id, End_Date__c = dtEndDate));    
                }
                }*/
                if((String)m.get(selectProject.Company_project_name_formula__c)!=''&&(String)m.get(selectProject.Company_project_name_formula__c)!='EndDate')
                {
                    Project_Time_Tracking__c timeEntry = new Project_Time_Tracking__c();
                    timeEntry.Hours__c = Decimal.valueOf((String)m.get(selectProject.Company_project_name_formula__c));
                    timeEntry.Project_Name__c = selectProject.ID;
                    timeEntry.Resource_User__c = userID;
                    timeEntry.Date__c = selectDate;
                    timecards.add(timeEntry);
                }      
            }
            //update mapIdToASProjectToUpdate.values();
            insert timecards;
        }
       
    }
    
    /*
        @MethodName : getPicklistValue 
        @param      : Sobject name and filed api name.
        @Description: method to get picklist value from field.
    */
    public List<SelectOption> getProjectCategoryOptions()
    {
        List<SelectOption> options = new List<SelectOption>();
        Schema.SObjectType targetType = GlobalDescribeMap.get('AS_Project__c');//!< From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //!< grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //!< describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //!< get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get('Project_Category__c').getDescribe().getPickListValues(); 
                                                        //!< grab the list of picklist values for the passed field on the sobject
        options.add(new SelectOption('none', '---None---'));
        for (Schema.PicklistEntry a : pick_list_values) 
        { 
            options.add(new SelectOption(a.getValue(), a.getLabel()));
        }
        return options;
    }
    /* End */
    
    /*
        @MethodName : checkDiligenceOnInvOpportunity 
        @param      : NA
        @Description: method for checking the diligence project in the selected Investment Opportunity. 
    */
    public void checkDiligenceOnInvOpportunity()
    {
        isDiligencePresent = false;
        if(!string.isBlank(strInvestmentOppId))
        {
            List<Deal__c> lstDeal = new List<Deal__c>();
            lstDeal = [SELECT Id, 
                              Salesforce_Company__c, 
                              (SELECT Id 
                                 FROM AS_Projects__r 
                                WHERE Project_Type__c = 'Diligence' LIMIT 1) 
                         FROM Deal__c 
                        WHERE Id =: strInvestmentOppId];
            if(!lstDeal[0].AS_Projects__r.isEmpty())
            {
                isDiligencePresent = true;
                strInvestmentOppId = '';
                strInvestmentOppName = '';
            }
            if(!lstDeal.isEmpty())
                 strCompanyId = lstDeal[0].Salesforce_Company__c;
        }
    }
    
    /*
        @MethodName : populateContact 
        @param      : NA
        @Description: method for populating contact whose title is CEO or Chief Executive Officer on select of company. 
    */
    public void populateContact()
    {
        if(!string.isBlank(strCompanyId))
        {
            List<Contact> lstContact = [SELECT Id 
                                          FROM Contact 
                                         WHERE AccountId =: strCompanyId 
                                           AND ((Title = 'CEO') OR (Title = 'Chief Executive Officer')) LIMIT 1];   
            
            if(strSelectedProjectCategory == 'Diligence') 
                objASProjectDiligence.Sponsor_Name__c = (lstContact.size() != 0) ? lstContact[0].Id : null;
            else if(strSelectedProjectCategory == 'Cross Portfolio')   
                objASProjectCross.Sponsor_Name__c = (lstContact.size() != 0) ? lstContact[0].Id : null;
            else
                objASProjectSpecific.Sponsor_Name__c = (lstContact.size() != 0) ? lstContact[0].Id : null;
            // objASProject.Sponsor_Name__c = (lstContact.size() != 0) ? lstContact[0].Id : null; 
        }    
    }
    
     /*
        @MethodName : populateFields 
        @param      : NA
        @Description: method used to populate other fields on New Project creation page based on the Project Type field. 
    */
    public void populateFields()
    {
        isCrossPortfolio = false;
        isRenderOtherFields = false;
        strInvestmentOppId = '';
        strInvestmentOppName = '';
        strCompanyId = '';
        strCompanyName = '';
        lstGroupMemberWrapper = new List<GroupMemberWrapper>();
        lstContactColumnWrapper = new List<ColumnWrapper>();
        lstWGMColumnWrapper = new List<ColumnWrapper>();
        
        if(strSelectedProjectCategory == 'Cross Portfolio')
            isCrossPortfolio = true;
            
        strFieldsetName = (strSelectedProjectCategory == 'Diligence') 
                          ? 'NewAsDiligenceProject'
                          : (strSelectedProjectCategory == 'Cross Portfolio')
                          ? 'NewASCrossPortfolioProject'
                          : (strSelectedProjectCategory == 'Portfolio Company Specific')
                          ? 'NewASProject' : '';
        strProjectCategory = (strSelectedProjectCategory == 'Diligence') 
                           ? 'Diligence'
                           : (strSelectedProjectCategory == 'Cross Portfolio')
                           ? 'CrossPortfolio'
                           : (strSelectedProjectCategory == 'Portfolio Company Specific')
                           ? 'PortfolioCompanySpecific' : '';
                                   
        if(strFieldsetName != '')
        {
            lstGroupMemberWrapper = prepareGroupMemberWrapper();
            //lstASProjectColumnWrapper = prepareColumnWrapper(strFieldsetName);
            isRenderOtherFields = true;
        }    
    }
    
    /*  
     @MethodName   : getPortfolioCompanies
     @param        : NA
     @Description  : This method will create JSON data for all the Porfolio Comapanies id and names.
    */
    public String getPortfolioCompanies()
    {
        String strRecordTypeId = [SELECT Id FROM RecordType  WHERE RecordType.DeveloperName = 'Portfolio_Company' LIMIT 1].Id;
        String strAccountJSON = '[';
        try 
        {
            for(Account objAccount : [SELECT Id, 
                                          Name 
                                     FROM Account WHERE RecordTypeId =: strRecordTypeId])
            {
                strAccountJSON += ',{\"id\":"' + objAccount.Id + '", \"name\":"' + objAccount.Name + '"}';
            }
            strAccountJSON = strAccountJSON.replaceFirst(',', '') + ']';
            return strAccountJSON;
        }
        catch(Exception e)
        {
            return strAccountJSON;
        }         
    }
    /* End */
    
    /*
        @MethodName : populateFields 
        @param      : NA
        @Description: method used to populate other fields on New Project creation page based on the Project Type field. 
    */
    public List<ColumnWrapper> prepareColumnWrapper(String strFieldsetName)
    {
        List<ColumnWrapper> lstColumnWrapper = new List<ColumnWrapper>();
        
        //Preparing list of column wrapper list for AS Project 
        for(FieldSetMember objFSM : GlobalDescribeMap.get('AS_Project__c').getDescribe().FieldSets.getMap().get(strFieldsetName).getFields())
        {
            if(objFSM.getDBRequired() || objFSM.getRequired())
                lstColumnWrapper.add(new ColumnWrapper(objFSM.getLabel(), objFSM.getFieldPath(), '', true));
            else
                lstColumnWrapper.add(new ColumnWrapper(objFSM.getLabel(), objFSM.getFieldPath(), '', false));    
        }
        return lstColumnWrapper;
    }
    
    
    /*
        @MethodName : createProject 
        @param      : NA
        @Description: method used to create project record. 
    */
    public void createProject()
    {
        try
        {
            AS_Project__c objASProject = new AS_Project__c();
            objASProject = (strSelectedProjectCategory == 'Diligence') 
                           ? objASProjectDiligence
                           : (strSelectedProjectCategory == 'Cross Portfolio')
                           ? objASProjectCross
                           : (strSelectedProjectCategory == 'Portfolio Company Specific')
                           ? objASProjectSpecific: new AS_Project__c();
            
            List<External_Working_Group_Member__c> lstEWGMemberToInsert = new List<External_Working_Group_Member__c>();
            List<AS_Project__c> lstASPojectToInsert = new List<AS_Project__c>();
            String strRequiredFields = '';
            Integer intCount = 0; 
            isValid = true;
            isExistsProjectName = false;
            objASProject.Investment_Opportunity__c = String.isBlank(strInvestmentOppId) ? null : strInvestmentOppId; 
            objASProject.Start_Date__c = Date.today();
            objASProject.Project_Category__c = strSelectedProjectCategory;
            if(strSelectedProjectCategory != 'Cross Portfolio')
                objASProject.Portfolio_Company__c = String.isBlank(strCompanyId) ? null : strCompanyId;  
            else
                objASProject.Portfolio_Company__c = (!String.isBlank(strSelectedCompanyIds) && strSelectedCompanyIds.split(',').size() > 0) ? strSelectedCompanyIds.split(',')[0] : null; 
            
            if(strSelectedProjectCategory == 'Portfolio Company Specific')
            {
                strCompaniesHaveCurrentProject = '';
                List<AS_Project__c> lstASProjectPCF = new List<AS_Project__c>();
                lstASProjectPCF = [SELECT Id 
                                      FROM AS_Project__c 
                                     WHERE Portfolio_Company__c =: objASProject.Portfolio_Company__c 
                                       AND Name LIKE : objASProject.Name];
                
                if(!lstASProjectPCF.isEmpty())
                {
                    strCompaniesHaveCurrentProject = strCompanyName;
                    isExistsProjectName = true;
                    isValid = false;
                    return;
                }
            }
            
            else if(strSelectedProjectCategory == 'Cross Portfolio' && strSelectedCompanyIds != '')
            {
                strCompaniesHaveCurrentProject = '';
                Set<String> setSelectedCompanies = new Set<String>();
                setSelectedCompanies.addAll(strSelectedCompanyIds.split(','));
                Map<Id, Account> mapIdToAccount = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id IN : setSelectedCompanies]);
                List<AS_Project__c> lstASProjectCP = new List<AS_Project__c>();
                lstASProjectCP = [SELECT Id, 
                                       Portfolio_Company__c
                                  FROM AS_Project__c 
                                 WHERE Portfolio_Company__c IN : setSelectedCompanies 
                                   AND Name LIKE : objASProject.Name 
                              ORDER BY Portfolio_Company__r.Name];
                
                for(AS_Project__c objASP : lstASProjectCP)
                {
                    intCount++;
                    strCompaniesHaveCurrentProject += (intCount < lstASProjectCP.size() || lstASProjectCP.size() == 1) 
                                                       ? (', ' + mapIdToAccount.get(objASP.Portfolio_Company__c).Name)
                                                       : (' and ' + mapIdToAccount.get(objASP.Portfolio_Company__c).Name);
                }
                strCompaniesHaveCurrentProject = strCompaniesHaveCurrentProject.replaceFirst(', ', '');
                
                if(!lstASProjectCP.isEmpty())
                {
                    isValid = false;
                    isExistsProjectName = true;
                    return;
                } 
            }
            
            List<AS_Project__c> allProjectsDupeCheck = [SELECT ID, Company_project_name_formula__c FROM AS_Project__c];
            MAP<ID,Account> allCompanies = new Map<ID,Account>([SELECT ID, NAME FROM ACCOUNT]);
            Set<String> projectDupeSet = new Set<String>();
            for(AS_Project__c proj:allProjectsDupeCheck)
            {
                projectDupeSet.add(proj.Company_project_name_formula__c);
            }
            if(strSelectedProjectCategory == 'Cross Portfolio' && strSelectedCompanyIds != '')
            {
                for(String strCompanyId : strSelectedCompanyIds.split(','))
                {
                    String projconcatName = '';
                    AS_Project__c objASPrj = new AS_Project__c();
                    objASPrj = objASProject.clone();
                    objASPrj.Portfolio_Company__c = strCompanyId;
                    projconcatName = allCompanies.get(strCompanyId).Name + ' - ' + objASPrj.Name;
                    if(!projectDupeSet.contains(projconcatName))
                    {
                        lstASPojectToInsert.add(objASPrj);
                    }
                }
            }
            if(strSelectedProjectCategory=='Diligence')
            {
                objASProject.Project_Type__c = 'Diligence';
            }
            //Iterating over field set to validate the required fields
            for(FieldSetMember objFSM : GlobalDescribeMap.get('AS_Project__c').getDescribe().FieldSets.getMap().get(strFieldsetName).getFields())
            {
                if((objFSM.getDBRequired() || objFSM.getRequired())  && (objASProject.get(objFSM.getFieldPath()) == '' || objASProject.get(objFSM.getFieldPath()) == null))
                {
                    strRequiredFields += ', ' + objFSM.getLabel(); 
                }    
            }
            strRequiredFields = strRequiredFields.replaceFirst(',', '');
            
            //When project category is not equals to delignece 
            if(strFieldsetName != 'NewAsDiligenceProject' && strRequiredFields != '')
            {
                isValid = false;
                strRequiredFields = 'Required fields are missing : [' + strRequiredFields + ' ]';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, strRequiredFields));
            }
            //When project category is delignece and there are no reqired fields is blank but selected Investment Opportunity does not have value in PortFolio Comapany
            else if(strFieldsetName == 'NewAsDiligenceProject' && strRequiredFields == '' && objASProject.Portfolio_Company__c == null)
            {
                isValid = false;
                strRequiredFields = 'The Investment Opportunity you enter needs to have a : [ Salesforce Company ]';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, strRequiredFields));
            }
            //When project category is delignece and there are any reqired fields is blank on the New Project creation page
            else if(strRequiredFields != '' && strFieldsetName == 'NewAsDiligenceProject')
            {
                isValid = false;
                strRequiredFields = 'Required fields are missing : [' + strRequiredFields + ' ]';    
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, strRequiredFields));
            }
            
            //if all the required field has values on page then check whether at least one Working group member is selected or not
            else
            {
                intCount = 0;
                for(GroupMemberWrapper objGMW : lstGroupMemberWrapper)
                {
                    if(objGMW.isSelected)
                        intCount++;
                }
                if(intCount < 1)
                {
                    isValid = false;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select at least one Working Group Member to create Project record'));
                }    
                else
                {
                    if(strSelectedProjectCategory == 'Cross Portfolio')
                        insert lstASPojectToInsert;
                    else
                        insert objASProject; 
                }    
            }   
            
            //Creating group member record for each AS Project 
            if(strSelectedProjectCategory == 'Cross Portfolio')
            {
                for(AS_Project__c objASPrj : lstASPojectToInsert)
                {
                    for(GroupMemberWrapper objGMW : lstGroupMemberWrapper)
                    {
                        if(objGMW.isSelected)
                        {
                            External_Working_Group_Member__c objEWGM = new External_Working_Group_Member__c();
                            objEWGM = objGMW.EWGMember.clone();
                            objEWGM.Initial_Participation_Date__c = Date.today();
                            objEWGM.AS_Project__c = objASPrj.Id;
                            lstEWGMemberToInsert.add(objEWGM);
                        }   
                    }
                }
                if(!lstEWGMemberToInsert.isEmpty())
                    insert lstEWGMemberToInsert;
            }
            else
            {
                //Inserting selected Working group member on the newly inserted AS Project
                if(objASProject.Id != null)    
                {
                    //Iterating on GroupMemberWrapper to insert External_Working_Group_Member__c corresponding to the contact 
                    for(GroupMemberWrapper objGMW : lstGroupMemberWrapper)
                    {
                        if(objGMW.isSelected)
                        {
                            objGMW.EWGMember.Initial_Participation_Date__c = Date.today();
                            objGMW.EWGMember.AS_Project__c = objASProject.Id;
                            lstEWGMemberToInsert.add(objGMW.EWGMember);
                        }   
                    }
                    if(!lstEWGMemberToInsert.isEmpty())
                        insert lstEWGMemberToInsert;
                }   
            }
        }
        catch(Exception ex)
        {
            isValid = false;
        }
    }
    
    /************************Start - Create Working Group Members Section**************************/
    /* Start - Group Member Wrapper Class */ 
    public class GroupMemberWrapper
    {
        public Contact contact                              {   get;set;    }
        public External_Working_Group_Member__c EWGMember   {   get;set;    }
        public Boolean isSelected                           {   get;set;    }
        
        public GroupMemberWrapper(External_Working_Group_Member__c EWGMember, Contact contact, Boolean isSelected)
        {
            this.contact = contact;
            // this.EWGMember = new External_Working_Group_Member__c(Contact__c = contact.Id);
            this.EWGMember = EWGMember;
            this.isSelected = isSelected;
        }
    }
    /* End - Group Member Wrapper Class */
    
    /* Start - Column Wrapper Class */ 
    public class ColumnWrapper
    {
        public String strFieldLabel     {   get;set;    }
        public String strFieldAPI       {   get;set;    }
        public String strFieldType      {   get;set;    }
        public Boolean isRequired       {   get;set;    }
        public Integer intIndex         {   get;set;    }
        
        public ColumnWrapper(String strFieldLabel, String strFieldAPI, String strFieldType, Integer intIndex)
        {
            this.strFieldLabel = strFieldLabel;
            this.strFieldAPI = strFieldAPI;
            this.strFieldType = strFieldType;
            this.intIndex = intIndex;
        }
        
        public ColumnWrapper(String strFieldLabel, String strFieldAPI, String strFieldType, Boolean isRequired)
        {
            this.strFieldLabel = strFieldLabel;
            this.strFieldAPI = strFieldAPI;
            this.strFieldType = strFieldType;
            this.isRequired = isRequired;
        }
    }
    /* End - Column Wrapper Class */ 
    
    /*
        * MethodName    : prepareGroupMemberWrapper()
        * param         : NA
        * Description   : This method is used for preparing list of GroupMemberWrapper. 
    */
    public List<GroupMemberWrapper> prepareGroupMemberWrapper()
    {
        List<GroupMemberWrapper> lstGroupMemberWrapper = new List<GroupMemberWrapper>();
        String strCurrentUserId = (ApexPages.currentPage().getParameters().containsKey('isInsert')) 
                                  ? ApexPages.currentPage().getParameters().get('isInsert') : '';
        String strContactFields = '';
        Integer i = 1;
        //Iterating over working group member field set to prepare list of contact columnWrapper and Working Group ColumnWrapper
        for(Schema.FieldSetMember objFSM : External_Working_Group_Member__c.sObjectType.getDescribe().FieldSets.getMap().get('WGMProjectAdd').getFields())
        {
            if(objFSM.getFieldPath().contains('Contact__r'))
            {
                strContactFields += ',' + objFSM.getFieldPath().split('\\.')[1];
                lstContactColumnWrapper.add(new ColumnWrapper(objFSM.getLabel(), objFSM.getFieldPath().split('\\.')[1], 'reference',1));
            }    
            else
            {
                if(objFSM.getFieldPath().contains('.'))
                    lstWGMColumnWrapper.add(new ColumnWrapper(objFSM.getLabel(), objFSM.getFieldPath(), 'reference', i));
                else
                    lstWGMColumnWrapper.add(new ColumnWrapper(objFSM.getLabel(), objFSM.getFieldPath(), 'other', i));
                i++;                    
            }
        }
        
        strContactFields = strContactFields.replaceFirst(',','');
        
        Set<Id> setUserOrRoleId = new Set<Id>();
        Set<Id> setGroupMemberId = new Set<Id>();
        
        //Fetching all the group member records from Default_Diligence_Project_Members public group
        for(GroupMember objGroupMember : [SELECT UserOrGroupId, 
                                                 Group.DeveloperName
                                            FROM GroupMember 
                                          WHERE Group.DeveloperName = 'Default_Diligence_Project_Members' 
                                              OR Group.DeveloperName = 'Resource_Group'])
        {
            if(objGroupMember.Group.DeveloperName == 'Default_Diligence_Project_Members')
                setGroupMemberId.add(objGroupMember.UserOrGroupId);
            else
                setUserOrRoleId.add(objGroupMember.UserOrGroupId);
        }
        
        //Fetching all the group member records from groups containing another group
        for(GroupMember objGroupMember : [SELECT UserOrGroupId, 
                                                 Group.DeveloperName
                                            FROM GroupMember 
                                           WHERE GroupId IN : setGroupMemberId 
                                              OR GroupId IN : setUserOrRoleId])
        {
            if(objGroupMember.Group.DeveloperName == 'Default_Diligence_Project_Members')
                setGroupMemberId.add(objGroupMember.UserOrGroupId);
            else
                setUserOrRoleId.add(objGroupMember.UserOrGroupId);
        }
        
        //Iterating over Group object to get all the user associated with it
        for(Group objGroup : [SELECT RelatedId FROM Group WHERE Id IN : setUserOrRoleId AND RelatedId != null])
        {
            setUserOrRoleId.add(objGroup.RelatedId);
        }
        
        //Iterating over UserRole to fetch all the user corresponding to the Resource_Group_Member Role
        for(User objUser : [SELECT Id FROM User WHERE UserRoleId IN : setUserOrRoleId])
        {
            setUserOrRoleId.add(objUser.Id);
        }
        System.debug(setUserOrRoleId);
        List<GroupMemberWrapper> lstGroupMemberWrapperTemp = new List<GroupMemberWrapper>();
        //Iterating on contact to prepare lstGroupMemberWrapper
        for(Contact objContact : Database.query('SELECT '+ strContactFields + ', Salesforce_User__c FROM Contact WHERE '+ 
                                                'RecordType.Name = \'AS Employee\' AND Salesforce_User__r.IsActive = true'))
        {
            System.debug(objContact);
            if(objContact.Salesforce_User__c == strCurrentUserId && ((setUserOrRoleId.contains(objContact.Salesforce_User__c) || setGroupMemberId.contains(objContact.Salesforce_User__c))))
            {
                lstGroupMemberWrapperTemp.add(new GroupMemberWrapper(new External_Working_Group_Member__c(Contact__c = objContact.Id, Role__c = 'AS Resource'), objContact, true));
            }
            else if(strSelectedProjectCategory == 'Diligence' && setGroupMemberId.contains(objContact.Salesforce_User__c)/* && setUserOrRoleId.contains(objContact.Salesforce_User__c)*/)
            {
                lstGroupMemberWrapperTemp.add(new GroupMemberWrapper(new External_Working_Group_Member__c(Contact__c = objContact.Id, Role__c = 'AS Resource'), objContact, true));
            }
            else if(setUserOrRoleId.contains(objContact.Salesforce_User__c))
            { 
                lstGroupMemberWrapperTemp.add(new GroupMemberWrapper(new External_Working_Group_Member__c(Contact__c = objContact.Id, Role__c = 'AS Resource'), objContact, false));
            }
            else if(strSelectedProjectCategory == 'Diligence' && !setGroupMemberId.contains(objContact.Salesforce_User__c) && setUserOrRoleId.contains(objContact.Salesforce_User__c))
            {
                lstGroupMemberWrapperTemp.add(new GroupMemberWrapper(new External_Working_Group_Member__c(Contact__c = objContact.Id), objContact, false));
            }
        }
        
        //Iterating over temp groupmember wrapper list to show all selected working group member first
        for(GroupMemberWrapper objWGMWrapper : lstGroupMemberWrapperTemp)
        {
            if(objWGMWrapper.isSelected)
                lstGroupMemberWrapper.add(objWGMWrapper);
        }
        
        //Iterating over temp groupmember wrapper list to show all unselected working group member that are associated with Resource group Public group
        for(GroupMemberWrapper objWGMWrapper : lstGroupMemberWrapperTemp)
        {
            if(!objWGMWrapper.isSelected && setUserOrRoleId.contains(objWGMWrapper.contact.Salesforce_User__c))
                lstGroupMemberWrapper.add(objWGMWrapper);
        }
        
        //Iterating over temp groupmember wrapper list to show all unselected working group members that are associated with Default_Diligence_Project_Members 
        for(GroupMemberWrapper objWGMWrapper : lstGroupMemberWrapperTemp)
        {
            if(!objWGMWrapper.isSelected && !setUserOrRoleId.contains(objWGMWrapper.contact.Salesforce_User__c))
                lstGroupMemberWrapper.add(objWGMWrapper);
        }
        return lstGroupMemberWrapper;
    }
    /* End */
    /************************End - Create Working Group Members Section**************************/
    
    
}