public with sharing class SL_CMTracker_Controller {
    static final List<String> MILESTONSE_FIELDS = new String[] {'Initial_Contact_Made__c', 'Teaser_Sent__c', 'CA_Sent__c', 'CA_Signed__c', 'CA_Under_Negotiation__c', 'CIM_Info_Package_Sent__c', 'CIM_Info_Package_Returned__c', 'CIM_Number__c', 'Mgmt_Presentation__c', 'Data_Room_Access__c', 'Winner__c', 'Meeting_Date__c', 'Model_Sent__c', 'Onsite_Date__c', 'Process_Letter_Term_Sheet_Sent__c', 'Term_Sheet_Received__c', 'Declined__c'};
    static Map<String, Schema.DescribeFieldResult> milestoneFieldDescribeFieldResultMap {get; private set;}
    
    Id dealId;
    public Ibanking_Project__c deal{get; private set;}
    public List<ReportItem> targetBuyers {get; private set;}
    public String logoId {get; private set;}
    public Boolean renderLogo {get{return logoId != null;}}
    public String getTitle(){
        String buf = ' - Capital Markets Tracker Fund Recap';
        return deal.Client__r.Name.toUpperCase() + buf.toUpperCase();
    }
    public String getToday(){
        return DateTime.now().format();
    }
    /*public String dealUrl {
        get{ 
            PageReference dealPage = new ApexPages.StandardController(deal).view();
            return dealPage.getUrl();
        }
    } */
    
    public SL_CMTracker_Controller(){
        
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
        if(!deals.isEmpty())
        {
            deal = deals[0];

            //Select logo
            List<Attachment> attachments = [Select Id, body, contentType from Attachment where ParentId = : dealId AND (Name LIKE 'logo.%' OR Name = 'logo' )Order by CreatedDate limit 1];
            if(!attachments.isEmpty())
            {
                logoId = attachments[0].Id;
            }

            Set<Id> targetBuyersIds = new Set<Id>();
            targetBuyers = new List<ReportItem>();

            String targetBuyerQuerySoql = 'Id,TargetBuyer__c, TargetBuyer__r.Name, TargetBuyer__r.BillingStreet, TargetBuyer__r.BillingCity,'; 
            targetBuyerQuerySoql += 'TargetBuyer__r.BillingState, TargetBuyer__r.BillingPostalCode, TargetBuyer__r.Type,Status__c,';
            targetBuyerQuerySoql += 'Fund__c,Amount__c,Limited_Partner__c, CurrencyIsoCode, ';


                // Start of Target_Buyer_Contacts__r
                targetBuyerQuerySoql += '(SELECT tbc.Contact__r.Account.Name, tbc.Roles__c,tbc.Contact__r.FirstName, tbc.Contact__r.Nickname__c, tbc.Contact__r.LastName,';
                    targetBuyerQuerySoql += 'tbc.Contact__r.Name, tbc.Contact__r.Title, tbc.Contact__r.Phone, tbc.Contact__r.MobilePhone, tbc.Contact__r.Email,';
                    targetBuyerQuerySoql += 'tbc.Contact__r.MailingStreet, tbc.Contact__r.MailingCity, tbc.Contact__r.MailingState, tbc.Contact__r.MailingPostalCode,';
                    targetBuyerQuerySoql += 'tbc.Contact__r.Account.BillingStreet, tbc.Manager__c ';
                targetBuyerQuerySoql += 'FROM t.Target_Buyer_Contacts__r tbc ';
                targetBuyerQuerySoql += 'ORDER BY tbc.Roles__c, tbc.Contact__r.LastName ),';
                // end of Target_Buyer_Contacts__r
                
                // Start of Target_Buyers_Resources__r
                targetBuyerQuerySoql += '(SELECT tbr.Banker__r.First_Name__c, tbr.Banker__r.Last_Name__c, tbr.Manager__c '; 
                targetBuyerQuerySoql += 'FROM t.Target_Buyers_Resources__r tbr ';
                targetBuyerQuerySoql += 'WHERE tbr.Manager__c = true ) ';
                // end of Target_Buyers_Resources__r

            targetBuyerQuerySoql += 'FROM Potential_Buyer_Investor__c t ';
            targetBuyerQuerySoql += 'WHERE t.Project__c = :dealId ';
            targetBuyerQuerySoql += 'ORDER BY t.TargetBuyer__r.Name ASC NULLS LAST, t.Limited_Partner__c ASC NULLS LAST'; // cannot sort by limited partner beacuse it's long text

            
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


            System.debug('soql: ' + targetBuyerQuerySoql);

            //Get DescribeFieldResult for Milestones fields
            for(Potential_Buyer_Investor__c pbi : lstPotentialBuyerInvestorQueried)
            {
                if(pbi.TargetBuyer__c != null)
                        {
                                if(mapInvestor_LstInvestorContactWithOrderedRole.containskey(pbi.Id)  &&   mapInvestor_LstInvestorContactWithOrderedRole.get(pbi.Id) != null)
                                    targetBuyers.add(new ReportItem(pbi,mapInvestor_LstInvestorContactWithOrderedRole.get(pbi.Id)));
                                else
                                    targetBuyers.add(new ReportItem(pbi,new List<Potential_Buyer_Investor_Contact__c>()));
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
                Id targetBuyerId;//= t.whoId;
                if(targetBuyerId == null) targetBuyerId = t.whatId;
                if(targetBuyerIdActivitiesMap.get(targetBuyerId) == null)
                    targetBuyerIdActivitiesMap.put(targetBuyerId, new List<Activity>());
                targetBuyerIdActivitiesMap.get(targetBuyerId).add(new Activity(t));
            }

            for(ReportItem tb : targetBuyers)
            {
                System.Debug('tb.dataDAO: '+tb.dataDAO);
                System.Debug('targetBuyerIdActivitiesMap.get(tb.dataDAO.Id): '+targetBuyerIdActivitiesMap.get(tb.dataDAO.Id));
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
        public String limitedPartner {get; private set;}
        public String fund {get; private set;}
        public Decimal amount {get; private set;}
        public String manager {get; private set;}
        public String contacts {get; private set;}
        public string milestones {get; private set;}
        public List<Activity> activities {get; private set;}
        public Boolean isInactive {get{return dataDAO.Status__c == 'Inactive';}}
        public String currencySymbol {get;set;}
        
        public ReportItem(Potential_Buyer_Investor__c pbInvestor, List<Potential_Buyer_Investor_Contact__c> lstInvestorContact)
        {
            dataDAO = pbInvestor;
            currencySymbol = (pbInvestor.CurrencyIsoCode !=null?' [' + pbInvestor.CurrencyIsoCode + ']':'');
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
            //initialize limited Partner column
            limitedPartner = '';
            if(pbInvestor.Limited_Partner__c != null) limitedPartner += pbInvestor.Limited_Partner__c;
            //initialize fund column
            fund = '';
            if(pbInvestor.Fund__c != null) fund += pbInvestor.Fund__c;
            //initialize Amount column
            amount = 0;
            if(pbInvestor.Amount__c != null) amount = amount + pbInvestor.Amount__c;
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
                    if(a.activityDate !=null)
                    {
                        dateSet.add(a.activityDate);
                        if(dateActivityMap.get(a.activityDate) == null)
                            dateActivityMap.put(a.activityDate, new List<Activity>());
                        dateActivityMap.get(a.activityDate).add(a); 
                    }
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

            //null check the date, typecast it, and set it.
            if (activityObj.get('ActivityDate') !=null && Date.valueOf(activityObj.get('ActivityDate')) !=null) 
                activityDate = Date.valueOf(activityObj.get('ActivityDate'));

            //null check the description, typecast it, and set it.
            description = '';
            if(activityObj.get('Subject') != null && String.valueOf(activityObj.get('Subject')) !=null)
                description  = String.valueOf(activityObj.get('Subject'));
            
            if(activityObj.get('Description') != null && String.valueOf(activityObj.get('Description')) != null)
                description  += '<br/>' + String.valueOf(activityObj.get('Description'));
        }
    }
}