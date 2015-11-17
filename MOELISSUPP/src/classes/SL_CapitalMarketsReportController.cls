public with sharing class SL_CapitalMarketsReportController {
    static final List<String> MILESTONSE_FIELDS = new String[] {'Initial_Contact_Made__c', 'Teaser_Sent__c', 'CA_Sent__c', 'CA_Signed__c', 'CA_Under_Negotiation__c', 'CIM_Info_Package_Sent__c', 'CIM_Info_Package_Returned__c', 'CIM_Number__c', 'Mgmt_Presentation__c', 'Data_Room_Access__c', 'Declined__c', 'Winner__c', 'Meeting_Date__c', 'Model_Sent__c', 'Onsite_Date__c', 'Process_Letter_Term_Sheet_Sent__c','Term_Sheet_Received__c'};
    static Map<String, Schema.DescribeFieldResult> milestoneFieldDescribeFieldResultMap {get; private set;}
    
    Id dealId;
    public Ibanking_Project__c deal{get; private set;}
    public List<ReportItem> targetBuyers {get; private set;}
    public String logoId {get; private set;}
    public Boolean renderLogo {get{return logoId != null;}}
    public String getTitle(){
        String buf = ' - Investor Activity Report';
        return deal.Client__r.Name.toUpperCase() + buf.toUpperCase();
    }
    public String getToday(){
    //    return Date.today().format();
        return DateTime.now().format();
    }
    public String dealUrl {
        get{ 
            PageReference dealPage = new ApexPages.StandardController(deal).view();
            return dealPage.getUrl();
        }
    } 
    
    public SL_CapitalMarketsReportController(){
        
        List<Potential_Buyer_Investor__c> lstPotentialBuyerInvestorQueried = new List<Potential_Buyer_Investor__c>();///Variable to store queried records
        Map<Id,List<Potential_Buyer_Investor_Contact__c>> mapInvestor_LstInvestorContactWithoutNullRole 
                                    = new Map<Id,List<Potential_Buyer_Investor_Contact__c>>();///Map to store Investor Contact with a proper role
        Map<Id,List<Potential_Buyer_Investor_Contact__c>> mapInvestor_LstInvestorContactWithNullRole
                                    = new Map<Id,List<Potential_Buyer_Investor_Contact__c>>();///Map to store Investor Contact with a Role as None
        Map<Id, List<Potential_Buyer_Investor_Contact__c>> mapInvestor_LstInvestorContactWithOrderedRole 
                    = new Map<Id,List<Potential_Buyer_Investor_Contact__c>>();///Map to store Investor contacts order based on Role with nulls at last

        fillMilestoneFieldDescribeFieldResultMap();
        
        dealId = ApexPages.currentPage().getParameters().get('dealid');
        List<Ibanking_Project__c> deals = [SELECT id, Name, Client__c, Client__r.Name FROM Ibanking_Project__c WHERE id = :dealId];
        if(deals != null && deals.size() > 0)
        {
            deal = deals[0];
        
        //Select logo
        List<Attachment> attachments = [Select Id, body, contentType from Attachment where ParentId = : dealId AND (Name LIKE 'logo.%' OR Name = 'logo' )Order by CreatedDate limit 1];
        if(attachments.size()>0) 
        {
            logoId = attachments[0].Id;
        }
        Set<Id> targetBuyersIds = new Set<Id>();
        targetBuyers = new List<ReportItem>();
        String targetBuyerQuerySoql = 'Id,Tier__c, TargetBuyer__c, TargetBuyer__r.Name, TargetBuyer__r.BillingStreet, TargetBuyer__r.BillingCity,'; 
        targetBuyerQuerySoql += 'TargetBuyer__r.BillingState, TargetBuyer__r.BillingPostalCode, Type__c,';
        targetBuyerQuerySoql += '(SELECT tbc.Contact__r.Account.Name, tbc.Contact__r.FirstName, tbc.Contact__r.Nickname__c ,tbc.Contact__r.LastName,';
        targetBuyerQuerySoql += 'tbc.Contact__r.Name, tbc.Contact__r.Title, tbc.Contact__r.Phone, tbc.Contact__r.MobilePhone, tbc.Contact__r.Email,';
        targetBuyerQuerySoql += 'tbc.Contact__r.MailingStreet, tbc.Contact__r.MailingCity, tbc.Contact__r.MailingState, tbc.Contact__r.MailingPostalCode,Roles__c,';
        targetBuyerQuerySoql += 'tbc.Contact__r.Account.BillingStreet, tbc.Manager__c ';
        targetBuyerQuerySoql += 'FROM t.Target_Buyer_Contacts__r tbc ORDER BY tbc.Roles__c , tbc.Contact__r.LastName ),';
        targetBuyerQuerySoql += '(SELECT tbr.Banker__r.First_Name__c, tbr.Banker__r.Last_Name__c, tbr.Manager__c '; 
        targetBuyerQuerySoql += 'FROM t.Target_Buyers_Resources__r tbr ';
        targetBuyerQuerySoql += 'WHERE tbr.Manager__c = true ),';
        targetBuyerQuerySoql += 'Status__c ';
        targetBuyerQuerySoql += 'From Potential_Buyer_Investor__c t ';
        targetBuyerQuerySoql += 'WHERE t.Project__c = :dealId ';
        targetBuyerQuerySoql += 'ORDER BY t.TargetBuyer__r.Name';
        
        //insert Milestones fields in query
        targetBuyerQuerySoql = insertMilestonesFields(targetBuyerQuerySoql);

        //Query investors
        lstPotentialBuyerInvestorQueried = Database.query(targetBuyerQuerySoql);
        
        ///Create maps of investor contact with roles and map of investor contact with no role
        for(Potential_Buyer_Investor__c objPotentialBuyerInvestor:lstPotentialBuyerInvestorQueried)
        {
            for(Potential_Buyer_Investor_Contact__c objInvestorContact:objPotentialBuyerInvestor.Target_Buyer_Contacts__r)
            {
                if(objInvestorContact.Roles__c != null && objInvestorContact.Roles__c != '')
                {
                    if(!mapInvestor_LstInvestorContactWithoutNullRole.containskey(objPotentialBuyerInvestor.Id))
                    {
                        List<Potential_Buyer_Investor_Contact__c> lstInvestorContact = new List<Potential_Buyer_Investor_Contact__c> ();
                        lstInvestorContact.add(objInvestorContact);
                        mapInvestor_LstInvestorContactWithoutNullRole.put(objPotentialBuyerInvestor.Id, lstInvestorContact);
                    }
                    else
                        mapInvestor_LstInvestorContactWithoutNullRole.get(objPotentialBuyerInvestor.Id).add(objInvestorContact);
                }
                else
                {
                    if(!mapInvestor_LstInvestorContactWithNullRole.containskey(objPotentialBuyerInvestor.Id))
                    {
                        List<Potential_Buyer_Investor_Contact__c> lstInvestorContact = new List<Potential_Buyer_Investor_Contact__c> ();
                        lstInvestorContact.add(objInvestorContact);
                        mapInvestor_LstInvestorContactWithNullRole.put(objPotentialBuyerInvestor.Id, lstInvestorContact);
                    }
                    else
                        mapInvestor_LstInvestorContactWithNullRole.get(objPotentialBuyerInvestor.Id).add(objInvestorContact);
                }
            }
        }
        
        ///Create a ordered map of Investor contact based on Role with nulls at last if investor  has a investor contact
        for(Id objPotentialBuyerInvestorId : mapInvestor_LstInvestorContactWithoutNullRole.keyset())
        {
            mapInvestor_LstInvestorContactWithOrderedRole.put(objPotentialBuyerInvestorId, mapInvestor_LstInvestorContactWithoutNullRole.get(objPotentialBuyerInvestorId));
            
            if(mapInvestor_LstInvestorContactWithOrderedRole.get(objPotentialBuyerInvestorId) != null &&  mapInvestor_LstInvestorContactWithNullRole.get(objPotentialBuyerInvestorId) != null)
                mapInvestor_LstInvestorContactWithOrderedRole.get(objPotentialBuyerInvestorId).addAll(mapInvestor_LstInvestorContactWithNullRole.get(objPotentialBuyerInvestorId));
        }
        
        ///Create a ordered map of Investor contact  nulls at last if investor does not have a investor contact
        for(Id objPotentialBuyerInvestorId : mapInvestor_LstInvestorContactWithNullRole.keyset())
        {
            if(!mapInvestor_LstInvestorContactWithOrderedRole.containskey(objPotentialBuyerInvestorId))
                mapInvestor_LstInvestorContactWithOrderedRole.put(objPotentialBuyerInvestorId,mapInvestor_LstInvestorContactWithNullRole.get(objPotentialBuyerInvestorId));
        }
        
        
        //Get DescribeFieldResult for Milestones fields
        for(Potential_Buyer_Investor__c pbi : lstPotentialBuyerInvestorQueried)
        {
            if(pbi.TargetBuyer__c != null)
            {
                    if(mapInvestor_LstInvestorContactWithOrderedRole.containskey(pbi.Id)  &&   mapInvestor_LstInvestorContactWithOrderedRole.get(pbi.Id) != null)
                    {
                        targetBuyers.add(new ReportItem(pbi,mapInvestor_LstInvestorContactWithOrderedRole.get(pbi.Id)));
                    }
                    else
                    {
                        targetBuyers.add(new ReportItem(pbi,new List<Potential_Buyer_Investor_Contact__c>()));
                    }
                    targetBuyersIds.add(pbi.Id);
            }
        }
            
        //Select associated activities
        Map<Id, List<Activity>> targetBuyerIdActivitiesMap = new Map<Id, List<Activity>>();
        for(Event e : [SELECT Subject, Description, ActivityDate, WhatId, WhoId FROM Event WHERE WhatId IN : targetBuyersIds OR WhoId IN : targetBuyersIds ORDER BY ActivityDate])
        {
            Id targetBuyerId;// = e.whoId;
            if(targetBuyerId == null) targetBuyerId = e.whatId;
            if(targetBuyerIdActivitiesMap.get(targetBuyerId) == null)
                targetBuyerIdActivitiesMap.put(targetBuyerId, new List<Activity>());
            targetBuyerIdActivitiesMap.get(targetBuyerId).add(new Activity(e));
        }
        for(Task t : [SELECT Subject, Description, ActivityDate, WhatId, WhoId FROM Task WHERE WhatId IN : targetBuyersIds OR WhoId IN : targetBuyersIds ORDER BY ActivityDate])
        {
            Id targetBuyerId; //= t.whoId;
            if(targetBuyerId == null) targetBuyerId = t.whatId;
            if(targetBuyerIdActivitiesMap.get(targetBuyerId) == null)
                targetBuyerIdActivitiesMap.put(targetBuyerId, new List<Activity>());
            targetBuyerIdActivitiesMap.get(targetBuyerId).add(new Activity(t));
        }
        
        for(ReportItem tb : targetBuyers)
        {
            tb.setActivities(targetBuyerIdActivitiesMap.get(tb.dataDAO.Id));
        }
        
        }
    }
    
    //insert Milestones fields in query
    static String insertMilestonesFields(String query)
    {
        String result = 'SELECT ';
        String querytoLowCase = query.toLowerCase();
        
        for(String field : MILESTONSE_FIELDS)
            if(!querytoLowCase.contains(field.toLowerCase()))
                result += field + ', ';
                
        result += query;
        return result;
    }
    
    //Get DescribeFieldResult for Milestones fields
    static void fillMilestoneFieldDescribeFieldResultMap()
    {
        milestoneFieldDescribeFieldResultMap = new Map<String, Schema.DescribeFieldResult>();
        Map<String, Schema.SObjectField> PotentialBuyerInvestorFieldsDescribe;
        PotentialBuyerInvestorFieldsDescribe = SObjectType.Potential_Buyer_Investor__c.fields.getMap();
        
        for(String fieldName : MILESTONSE_FIELDS)
        {
            milestoneFieldDescribeFieldResultMap.put(fieldName, PotentialBuyerInvestorFieldsDescribe.get(fieldName).getDescribe());
        }
        
    }
    
    public class ReportItem
    {
        public Potential_Buyer_Investor__c dataDAO {get; private set;}
        public String investors {get; private set;}
        public String investorType {get; private set;}
        public String tier {get; private set;}
        public String manager {get; private set;}
        public String contacts {get; private set;}
        public string milestones {get; private set;}
        public List<Activity> activities {get; private set;}
        public Boolean isInactive {get{return dataDAO.Status__c == 'Inactive';}}
        
        public ReportItem(Potential_Buyer_Investor__c pbInvestor, List<Potential_Buyer_Investor_Contact__c> lstInvestorContact)
        {
            dataDAO = pbInvestor;//??
            //initialize Investors column
            investors = '';
            investors += '<b>' + pbInvestor.TargetBuyer__r.Name + '</b><br/>';
            if(pbInvestor.TargetBuyer__r.BillingStreet != null)
                investors += pbInvestor.TargetBuyer__r.BillingStreet + '<br/>';
            if((pbInvestor.TargetBuyer__r.BillingCity!=null)||(pbInvestor.TargetBuyer__r.BillingState!=null)||(pbInvestor.TargetBuyer__r.BillingPostalCode!=null))
            {
                if(pbInvestor.TargetBuyer__r.BillingCity != null)
                    investors += pbInvestor.TargetBuyer__r.BillingCity + ', ';
                if(pbInvestor.TargetBuyer__r.BillingState != null) investors += pbInvestor.TargetBuyer__r.BillingState + ' ';
                if(pbInvestor.TargetBuyer__r.BillingPostalCode != null) investors += pbInvestor.TargetBuyer__r.BillingPostalCode;
            }
            //--------
            //initialize Investor Type column
            investorType = '';
            if(pbInvestor.Type__c != null) investorType += pbInvestor.Type__c;
            //--------
            //initialize Tier column
            tier = '';
            if(pbInvestor.Tier__c != null) tier += pbInvestor.Tier__c;
            //--------
            //initialize Manager column
            manager = '';

            for(Potential_Buyer_Investor_Deal_Team__c  tbr :pbInvestor.Target_Buyers_Resources__r)
            {
                if(manager != '') manager += '<br/>';
                manager += 'Moelis - ' + tbr.Banker__r.First_Name__c.substring(0,1)+ tbr.Banker__r.Last_Name__c.substring(0,1);
            }
           
            if(lstInvestorContact.size() > 0 && lstInvestorContact != null)
            {
                for(Potential_Buyer_Investor_Contact__c  tbc :lstInvestorContact)
                {
                    if(tbc.Manager__c){
                        if(manager != '') manager += '<br/>';
                        manager += tbc.Contact__r.Account.Name + ' - ' + tbc.Contact__r.FirstName.substring(0,1) + tbc.Contact__r.LastName.substring(0,1);
                    }
                }
                //--------
                //initialize Contacts column
                contacts = '';
                String strContactName = '';
                for(Potential_Buyer_Investor_Contact__c  tbc :lstInvestorContact)
                {
                	strContactName = (tbc.Contact__r.Nickname__c != null? (tbc.Contact__r.Nickname__c +' ' +tbc.Contact__r.LastName):(tbc.Contact__r.FirstName +
                	                  ' ' + tbc.Contact__r.LastName));
                	
                    if(contacts != '') contacts += '<br/>';
                    contacts += '<b>' + strContactName + '</b>';
                    if(tbc.Contact__r.Title != null) contacts += '<br/>' + tbc.Contact__r.Title;
                    if(tbc.Contact__r.Phone != null) contacts += '<br/>Tel: ' + tbc.Contact__r.Phone;
                    if(tbc.Contact__r.MobilePhone != null) contacts += '<br/>Cell: ' + tbc.Contact__r.MobilePhone;
                    if(tbc.Contact__r.Email != null) contacts += '<br/>' + tbc.Contact__r.Email;
                    if(tbc.Contact__r.MailingStreet != tbc.Contact__r.Account.BillingStreet)
                    {
                        if(tbc.Contact__r.MailingStreet != null) contacts += '<br/>' + tbc.Contact__r.MailingStreet;
                        if((tbc.Contact__r.MailingCity != null)||(tbc.Contact__r.MailingState!=null)||(tbc.Contact__r.MailingPostalCode!=null))
                        {
                            contacts += '<br/>';
                            if(tbc.Contact__r.MailingCity != null)
                                contacts += tbc.Contact__r.MailingCity + ', ';
                            if(tbc.Contact__r.MailingState != null) contacts += tbc.Contact__r.MailingState + ' ';
                            if(tbc.Contact__r.MailingPostalCode != null) contacts += tbc.Contact__r.MailingPostalCode;
                        }
                    }
                }
            }
            //--------
            //initialize Milestones column
            milestones = '';
            for(String fieldName : MILESTONSE_FIELDS)
            {
                if(pbInvestor.get(fieldName) != null && pbInvestor.get(fieldName) != false)
                {
                    if(milestones != '')
                        milestones += '<br/>';
                    String milestoneStr;
                    if(milestoneFieldDescribeFieldResultMap.get(fieldName).getType() == Schema.DisplayType.Date)
                        milestoneStr = Date.valueOf(pbInvestor.get(fieldName)).format();
                    else if(milestoneFieldDescribeFieldResultMap.get(fieldName).getType() == Schema.DisplayType.DateTime)
                        milestoneStr = DateTime.valueOf(pbInvestor.get(fieldName)).format();
                    else
                        milestoneStr = String.valueOf(pbInvestor.get(fieldName));
                    milestones += milestoneFieldDescribeFieldResultMap.get(fieldName).getLabel()
                        + ':' + milestoneStr;
                }
            }
            //--------
        }
        
        public void setActivities(List<Activity> inActivities)
        {
            //Sort activities
            List<Activity> sortedActivities = new List<Activity>();
            if(inActivities != null)
            {
                Map<Date, List<Activity>> dateActivityMap = new Map<Date, List<Activity>>();
                List<Date> dateList = new List<Date>();
                Set<Date> dateSet = new Set<Date>();
                for(Activity a : inActivities)
                {
                    dateSet.add(a.activityDate);
                    if(dateActivityMap.get(a.activityDate) == null)
                        dateActivityMap.put(a.activityDate, new List<Activity>());
                    dateActivityMap.get(a.activityDate).add(a);
                }
                
                dateList.addAll(dateSet);
                dateList.sort();
                
                for(Date d : dateList)
                    sortedActivities.addAll(dateActivityMap.get(d));
            }
            activities = sortedActivities;
        }
    }
    
    public class Activity
    {
        public sObject activityDAO {get; private set;}
        public String description {get; private set;}
        public Date activityDate {get; private set;}
        public String activityDateStr {get{return activityDate.format();}}
        
        public Activity(Event event)
        {
            init(event);
        }
        
        public Activity(Task task)
        {
            init(task);
        }
        
        void init(sObject activityObj)
        {
            activityDAO = activityObj;
            activityDate = (Date.valueOf(activityObj.get('ActivityDate')));
            description = String.valueOf(activityObj.get('Subject'));
            String descr = String.valueOf(activityObj.get('Description'));
            if(descr != null)
                description += '<br/>' + descr;
        }
    }
    
    public static testMethod void test_SL_CapitalMarketsReportController()
    {
        //Creating Test Data
        Account a = new Account(Name='Test Account', BillingStreet='Billing Street', BillingCity='Billing City', BillingState='Billing State',
                                BillingPostalCode='11111', Type='Corporate');
        insert a;
        
        Contact objContact = new Contact(FirstName = 'Test First Name', LastName = 'Test Contact', AccountId = a.Id);
        insert objContact;
        
        Ibanking_Project__c pr = new Ibanking_Project__c(Client__c=a.Id);
        insert pr;
        
        Attachment objAttachment = new Attachment(Name = 'logo', Body = Blob.valueOf('Test Blob'), ParentId = pr.Id);
        insert objAttachment;
        
        Employee_Profile__c objEmployeeProfile = new Employee_Profile__c(First_Name__c = 'Test First Name', Last_Name__c = 'Test Last Name');
        insert objEmployeeProfile;
            
        
        List<Potential_Buyer_Investor__c> lstPBI = new List<Potential_Buyer_Investor__c>{
                                                                                            new Potential_Buyer_Investor__c(Project__c=pr.Id, TargetBuyer__c=a.Id, Tier__c='1'),
                                                                                            new Potential_Buyer_Investor__c(Project__c=pr.Id, TargetBuyer__c=a.Id, Tier__c='2')
                                                                                        };
        
        insert lstPBI;
        List<Potential_Buyer_Investor_Contact__c> lstPBC = new List<Potential_Buyer_Investor_Contact__c>{
                                                                                                            new Potential_Buyer_Investor_Contact__c(Target_Buyer__c = lstPBI[0].Id, Contact__c = objContact.Id, Roles__c = 'Primary'),
                                                                                                            new Potential_Buyer_Investor_Contact__c(Target_Buyer__c = lstPBI[0].Id, Contact__c = objContact.Id, Roles__c = 'Secondary'),
                                                                                                            new Potential_Buyer_Investor_Contact__c(Target_Buyer__c = lstPBI[0].Id, Contact__c = objContact.Id, Roles__c = 'Referral'),
                                                                                                            new Potential_Buyer_Investor_Contact__c(Target_Buyer__c = lstPBI[0].Id, Contact__c = objContact.Id),
                                                                                                            new Potential_Buyer_Investor_Contact__c(Target_Buyer__c = lstPBI[1].Id, Contact__c = objContact.Id)
                                                                                                        };
        insert lstPBC;
        
        List<Potential_Buyer_Investor_Deal_Team__c> lstPBDealTeam = new List<Potential_Buyer_Investor_Deal_Team__c>{
                                                                                                                        new Potential_Buyer_Investor_Deal_Team__c(Target_Buyer__c = lstPBI[0].Id, Role__c = 'Primary', Banker__c = objEmployeeProfile.Id, Manager__c = true),
                                                                                                                        new Potential_Buyer_Investor_Deal_Team__c(Target_Buyer__c = lstPBI[0].Id, Role__c = 'Secondary', Banker__c = objEmployeeProfile.Id, Manager__c = true)          
                                                                                                                    };
        insert lstPBDealTeam;
        
        Event e = new Event(WhatId=lstPBI[0].Id, StartDateTime=DateTime.now(), EndDateTime=DateTime.now().addHours(2));
        insert e;
        Task t = new Task(WhatId=lstPBI[0].Id, Subject='Test Task', Description='Description');
        insert t;
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('dealid', pr.Id);
        SL_CapitalMarketsReportController controller = new SL_CapitalMarketsReportController();
        SL_CMTracker_Controller objSL_CMTracker_Controller = new SL_CMTracker_Controller();
        controller.getToday();
        controller.getTitle();
        System.assertEquals(1, [SELECT Id FROM Attachment WHERE ParentId =: pr.Id LIMIT 1].size());
        objSL_CMTracker_Controller.getTitle();
        objSL_CMTracker_Controller.getToday();
        String url = controller.dealUrl;
        Test.stopTest();
    }
}