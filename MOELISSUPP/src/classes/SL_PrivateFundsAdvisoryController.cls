/**
* \arg ClassName      : SL_PrivateFundsAdvisoryController
* \arg JIRATicket     : MOELISSUPP-41
* \arg CreatedOn      : 13/JAN/2015
* \arg LastModifiedOn : 11/Feb/2015
* \arg CreatededBy    : Sandeep
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This class is used to display data for private funds.
*/
public with sharing class SL_PrivateFundsAdvisoryController 
{
    public Ibanking_Project__c deal         {get; private set;}
    public String logoId                    {get; private set;}
    public Boolean renderLogo               {get{return logoId != null;}}
    List<String> lstMilestonesFileds; 
    
    public String getTitle()
    {
        return (deal.Client__r.Name != null) ? deal.Client__r.Name.toUpperCase() + ' - Investor Activity Report'.toUpperCase() : '';
    }
    
    public String getToday()
    {
        return DateTime.now().format();
    }
    
    /* Start - Constructor */
    public SL_PrivateFundsAdvisoryController()
    {
        /* Calling initialization method */
        initialization();
    }
    /* End - Constructor */
    
    /*
     @MethodName: initialization
     @param: na
     @Description: to initialize variables
    */
    void initialization()
    {
        SL_Milestonesfields__c mileStonefields = new SL_Milestonesfields__c();
        lstMilestonesFileds = new List<String>();
        
        if(!SL_Milestonesfields__c.getall().values().isEmpty()) 
            mileStonefields = SL_Milestonesfields__c.getall().values();
        
        if(mileStonefields.Field_API_Names__c != null && mileStonefields.Field_API_Names__c != '')
            lstMilestonesFileds = mileStonefields.Field_API_Names__c.split(',');
    }
    
    /*
     @MethodName: fetchPotentialBuyers
     @param: na
     @Description: Get all potential buyers related to deal
    */
    public List<ReportItem> getfetchPotentialBuyers()
    {
        Id dealId;
        Id recordTypeId;
        
        List<ReportItem> targetBuyers = new List<ReportItem>();
        List<Potential_Buyer_Investor__c> lstPotentialBuyerInvestorQueried = new List<Potential_Buyer_Investor__c>();// Variable to store queried records
        Map<String, Schema.DescribeFieldResult> MapMilestoneFieldDescribeFieldResult;
        Map<Id,List<Potential_Buyer_Investor_Contact__c>> mapInvestor_LstInvestorContactWithoutNullRole 
                                    = new Map<Id,List<Potential_Buyer_Investor_Contact__c>>();// Map to store Investor Contact with a proper role
        Map<Id,List<Potential_Buyer_Investor_Contact__c>> mapInvestor_LstInvestorContactWithNullRole
                                    = new Map<Id,List<Potential_Buyer_Investor_Contact__c>>();// Map to store Investor Contact with a Role as None
        Map<Id, List<Potential_Buyer_Investor_Contact__c>> mapInvestor_LstInvestorContactWithOrderedRole 
                    = new Map<Id,List<Potential_Buyer_Investor_Contact__c>>();// Map to store Investor contacts order based on Role with nulls at last
        
        
        try
        {
            dealId = ApexPages.currentPage().getParameters().get('dealid');
            recordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Potential_Buyer_Investor__c' AND developerName ='Private_Funds_Advisory' ].Id;
            List<Ibanking_Project__c> deals = [SELECT id, Name, Client__c, Client__r.Name FROM Ibanking_Project__c WHERE id = :dealId];
             
            /* Calling method */
            MapMilestoneFieldDescribeFieldResult = fillMilestoneFieldDescribeFieldResultMap();
            
            if(deals != null && deals.size() > 0)
            {
                deal = deals[0];
            
                /* Getting the logo from attachment */ 
                List<Attachment> attachments = [SELECT Id, body, contentType FROM Attachment 
                                                 WHERE ParentId = : dealId AND (Name LIKE 'logo.%' OR Name = 'logo' )ORDER BY CreatedDate LIMIT 1];
                
                if(!attachments.isEmpty()) 
                    logoId = attachments[0].Id;
                
                Set<Id> targetBuyersIds = new Set<Id>();
                targetBuyers = new List<ReportItem>();
                
                String targetBuyerQuerySoql = 'Id,Interest_Level__c, TargetBuyer__c, TargetBuyer__r.Name, TargetBuyer__r.BillingStreet, TargetBuyer__r.BillingCity,'; 
                targetBuyerQuerySoql += 'TargetBuyer__r.BillingState, TargetBuyer__r.BillingPostalCode, PFA_LP_Sub_Type__c,';
                targetBuyerQuerySoql += '(SELECT tbc.Contact__r.Account.Name, tbc.Contact__r.FirstName, tbc.Contact__r.Nickname__c ,tbc.Contact__r.LastName,';
                targetBuyerQuerySoql += 'tbc.Contact__r.Name, tbc.Contact__r.Title, tbc.Contact__r.Phone, tbc.Contact__r.MobilePhone, tbc.Contact__r.Email,';
                targetBuyerQuerySoql += 'tbc.Contact__r.MailingStreet, tbc.Contact__r.MailingCity, tbc.Contact__r.MailingState, tbc.Contact__r.MailingPostalCode,Roles__c,';
                targetBuyerQuerySoql += 'tbc.Contact__r.Account.BillingStreet, tbc.Manager__c ';
                targetBuyerQuerySoql += 'FROM t.Target_Buyer_Contacts__r tbc ORDER BY tbc.Roles__c , tbc.Contact__r.LastName ),';
                targetBuyerQuerySoql += '(SELECT tbr.Banker__r.First_Name__c, tbr.Banker__r.Last_Name__c, tbr.Manager__c '; 
                targetBuyerQuerySoql += 'FROM t.Target_Buyers_Resources__r tbr ),';
                targetBuyerQuerySoql += 'Status__c, Purchased_Amount_mm__c, Soft_Circle_High_mm__c, Soft_Circle_Low_mm__c, Next_Steps__c, PFA_Coverage__c ';
                targetBuyerQuerySoql += 'From Potential_Buyer_Investor__c t ';
                targetBuyerQuerySoql += 'WHERE t.Project__c = :dealId AND t.RecordTypeId = :recordTypeId ' ;
                targetBuyerQuerySoql += 'ORDER BY t.TargetBuyer__r.Name';
                
                /* Insert Milestones fields in query */
                targetBuyerQuerySoql = insertMilestonesFields(targetBuyerQuerySoql);
                
                /* Query investors */
                lstPotentialBuyerInvestorQueried = Database.query(targetBuyerQuerySoql);
                
                /* Create maps of investor contact with roles and map of investor contact with no role */
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
                
                /* Create a ordered map of Investor contact based on Role with nulls at last if investor  has a investor contact */
                for(Id objPotentialBuyerInvestorId : mapInvestor_LstInvestorContactWithoutNullRole.keyset())
                {
                    mapInvestor_LstInvestorContactWithOrderedRole.put(objPotentialBuyerInvestorId, mapInvestor_LstInvestorContactWithoutNullRole.get(objPotentialBuyerInvestorId));
                    
                    if(mapInvestor_LstInvestorContactWithOrderedRole.get(objPotentialBuyerInvestorId) != null 
                       && mapInvestor_LstInvestorContactWithNullRole.get(objPotentialBuyerInvestorId) != null)
                        mapInvestor_LstInvestorContactWithOrderedRole.get(objPotentialBuyerInvestorId).addAll(mapInvestor_LstInvestorContactWithNullRole.get(objPotentialBuyerInvestorId));
                }
                
                /* Create a ordered map of Investor contact  nulls at last if investor does not have a investor contact */
                for(Id objPotentialBuyerInvestorId : mapInvestor_LstInvestorContactWithNullRole.keyset())
                {
                    if(!mapInvestor_LstInvestorContactWithOrderedRole.containskey(objPotentialBuyerInvestorId))
                        mapInvestor_LstInvestorContactWithOrderedRole.put(objPotentialBuyerInvestorId,mapInvestor_LstInvestorContactWithNullRole.get(objPotentialBuyerInvestorId));
                }
                
                
                /* Get DescribeFieldResult for Milestones fields */ 
                for(Potential_Buyer_Investor__c pbi : lstPotentialBuyerInvestorQueried)
                {
                    if(pbi.TargetBuyer__c != null)
                    {
                        if(mapInvestor_LstInvestorContactWithOrderedRole.containskey(pbi.Id)  &&   mapInvestor_LstInvestorContactWithOrderedRole.get(pbi.Id) != null)
                        {
                            targetBuyers.add(new ReportItem(pbi, mapInvestor_LstInvestorContactWithOrderedRole.get(pbi.Id), lstMilestonesFileds, MapMilestoneFieldDescribeFieldResult));
                        }
                        else
                        {
                            targetBuyers.add(new ReportItem(pbi, new List<Potential_Buyer_Investor_Contact__c>(), lstMilestonesFileds, MapMilestoneFieldDescribeFieldResult));
                        }
                        targetBuyersIds.add(pbi.Id);
                    }
                }
                    
                /* Select associated activities */
                Map<Id, List<Activity>> targetBuyerIdActivitiesMap = new Map<Id, List<Activity>>();
                for(Event e : [SELECT Subject, Description, ActivityDate, WhatId, WhoId 
                                 FROM Event WHERE WhatId IN : targetBuyersIds OR WhoId IN : targetBuyersIds ORDER BY ActivityDate])
                {
                    Id targetBuyerId;
                    if(targetBuyerId == null) targetBuyerId = e.whatId;
                    if(targetBuyerIdActivitiesMap.get(targetBuyerId) == null)
                        targetBuyerIdActivitiesMap.put(targetBuyerId, new List<Activity>());
                    targetBuyerIdActivitiesMap.get(targetBuyerId).add(new Activity(e));
                }
                
                for(Task t : [SELECT Subject, Description, ActivityDate, WhatId, WhoId 
                                FROM Task WHERE WhatId IN : targetBuyersIds OR WhoId IN : targetBuyersIds ORDER BY ActivityDate])
                {
                    Id targetBuyerId;
                    if(targetBuyerId == null) targetBuyerId = t.whatId;
                    if(targetBuyerIdActivitiesMap.get(targetBuyerId) == null)
                        targetBuyerIdActivitiesMap.put(targetBuyerId, new List<Activity>());
                    targetBuyerIdActivitiesMap.get(targetBuyerId).add(new Activity(t));
                }
                
                for(ReportItem tb : targetBuyers)
                {
                    tb.sortActivitiesRecords(targetBuyerIdActivitiesMap.get(tb.dataDAO.Id));
                }
                
            }
            return targetBuyers;
        }
        catch(Exception ex)
        {   
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Potential/Buyer records to display '));
            return null;
        }
    }
    
    /*
     @MethodName: insertMilestonesFields
     @param : String 
     @Description: insert Milestones fields in query 
    */
    String insertMilestonesFields(String query)
    {
        String result = 'SELECT ';
        String querytoLowCase = query.toLowerCase();
        
        for(String field : lstMilestonesFileds)
            if(!querytoLowCase.contains(field.toLowerCase()))
                result += field + ', ';
                
        result += query;
        return result;
    }
    
    /*
     @MethodName: fillMilestoneFieldDescribeFieldResultMap
     @param None
     @Description: Get DescribeFieldResult for Milestones fields 
    */
    Map<String, Schema.DescribeFieldResult> fillMilestoneFieldDescribeFieldResultMap()
    {
        Map<String, Schema.DescribeFieldResult> MapMileStoneFieldDesRes = new Map<String, Schema.DescribeFieldResult>();
        Map<String, Schema.SObjectField> PotentialBuyerInvestorFieldsDescribe = SObjectType.Potential_Buyer_Investor__c.fields.getMap();
        
        for(String fieldName : lstMilestonesFileds)
        {
            MapMileStoneFieldDesRes .put(fieldName, PotentialBuyerInvestorFieldsDescribe.get(fieldName).getDescribe());
        }
        return MapMileStoneFieldDesRes;
    }
    
     /*
     @InnerClassName: ReportItem
     @param None
     @Description: Wrraper class to bind data
    */
    public class ReportItem
    {
        public Potential_Buyer_Investor__c dataDAO          {get; private set;}
        public String investors                             {get; private set;}
        public String investorType                          {get; private set;}
        public String interestLevel                         {get; private set;}
        public String manager                               {get; private set;}
        public String contacts                              {get; private set;}
        public string milestones                            {get; private set;}
        public List<Activity> activities                    {get; private set;}
        public Boolean isInactive                           {get{return dataDAO.Status__c == 'Inactive';}}
        public Double minAmount                             {get; private set;}
        public Double maxAmount                             {get; private set;}
        public Double closeAmount                           {get; private set;}
        public String nextSteps                             {get; private set;}
        
        public ReportItem(Potential_Buyer_Investor__c pbInvestor, List<Potential_Buyer_Investor_Contact__c> lstInvestorContact, List<String> lstMileStoneAPIName, 
                          Map<String, Schema.DescribeFieldResult> milestoneFieldDescribeFieldResultMap)
        {
            dataDAO = pbInvestor;
            manager = '';
            minAmount = pbInvestor.Soft_Circle_Low_mm__c;
            maxAmount = pbInvestor.Soft_Circle_High_mm__c;
            closeAmount = pbInvestor.Purchased_Amount_mm__c;
            nextSteps = (pbInvestor.Next_Steps__c != null ? pbInvestor.Next_Steps__c : '');
            
            /* Investors column */ 
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
           
            /* For Investor Type column */
            investorType = '';
            if(pbInvestor.PFA_LP_Sub_Type__c != null) investorType += pbInvestor.PFA_LP_Sub_Type__c;
           
            /* For interestLevel column */
            interestLevel = '';
            if(pbInvestor.Interest_Level__c != null) interestLevel += pbInvestor.Interest_Level__c;
           
            /* For Manager column */
            if(pbInvestor.PFA_Coverage__c != null)
                manager = pbInvestor.PFA_Coverage__c;   
            
            if(lstInvestorContact.size() > 0 && lstInvestorContact != null)
            {
                /* For Contacts column */
                contacts = '';
                String strContactName = '';
                for(Potential_Buyer_Investor_Contact__c  tbc :lstInvestorContact)
                {
                    strContactName = (tbc.Contact__r.Nickname__c != null? (tbc.Contact__r.Nickname__c +' ' +tbc.Contact__r.LastName):(tbc.Contact__r.FirstName +
                                  ' ' + tbc.Contact__r.LastName));
                
                    if(contacts != '') contacts += '<br/>';
                    contacts += '<b>' + strContactName + '</b>';
                    if(tbc.Contact__r.Title != null) contacts += '<br/>' + tbc.Contact__r.Title;
                    
                    /* This code has been commented since we have to only show name and title of contact as per the requirement of MOELISSUPP-49 */
                    //if(tbc.Contact__r.Phone != null) contacts += '<br/>Tel: ' + tbc.Contact__r.Phone;
                    //if(tbc.Contact__r.MobilePhone != null) contacts += '<br/>Cell: ' + tbc.Contact__r.MobilePhone;
                    //if(tbc.Contact__r.Email != null) contacts +=  '<br/>'+ tbc.Contact__r.Email;
                   /* if(tbc.Contact__r.MailingStreet != tbc.Contact__r.Account.BillingStreet)
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
                    }*/
                  contacts += '<br/>';
                }
            }
            
            /* For Milestones column */
            milestones = '';
            
            for(String fieldName : lstMileStoneAPIName)
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
                    
                    if(milestoneFieldDescribeFieldResultMap.get(fieldName).getLabel() == 'Data Room Access')
                        milestones += 'Data Room' + ': ' + milestoneStr;
                    else if(milestoneFieldDescribeFieldResultMap.get(fieldName).getLabel() == 'CIM / PPM / Info Package Sent')
                        milestones += 'PPM Sent' + ': ' + milestoneStr;         
                    else if(milestoneFieldDescribeFieldResultMap.get(fieldName).getLabel() == 'Initial Contact Made')
                        milestones += 'Initial Contact' + ': ' + milestoneStr;
                    else
                        milestones += milestoneFieldDescribeFieldResultMap.get(fieldName).getLabel() + ': ' + milestoneStr;  
                }
            }
        }
        
        /*
         @MethodName: sortActivitiesRecords
         @param: List of Activity Wrraper class 
         @Description: Sorting activities
        */
        public void sortActivitiesRecords(List<Activity> lstActivities)
        {
            List<Activity> sortedActivities = new List<Activity>();
            try
            {
                if(lstActivities != null)
                {
                    Map<Date, List<Activity>> dateActivityMap = new Map<Date, List<Activity>>();
                    List<Date> dateList = new List<Date>();
                    Set<Date> dateSet = new Set<Date>();
                    
                    for(Activity a : lstActivities)
                    {
                        dateSet.add(a.activityDate);
                        if(dateActivityMap.get(a.activityDate) == null)
                            dateActivityMap.put(a.activityDate, new List<Activity>());
                        dateActivityMap.get(a.activityDate).add(a);
                    }
                    
                    dateList.addAll(dateSet);
                    dateList.sort();//sorting the list in ascending order
                    
                    //sorting the list in descending order
                    for(Integer i=dateList.size() - 1; i >= 0 ; i--)//Date d : dateList
                    {
                        sortedActivities.addAll(dateActivityMap.get(dateList[i]));
                    }
                }
                activities = sortedActivities;
            }    
            catch(Exception ex)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            }                               
        }
        /* End Of sortActivitiesRecords method */
    }
    
    /*
     @InnerClassName: Activity
     @param None
     @Description: Activity class to bind data
    */
    public class Activity
    {
        public String description       {get; private set;}
        public Date activityDate        {get; private set;}
        public String strActivityDate   {get; private set;}
        
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
            activityDate = (Date.valueOf(activityObj.get('ActivityDate')));
            if(activityDate != null)
                strActivityDate = activityDate.format();
            description = String.valueOf(activityObj.get('Subject'));
            String descr = String.valueOf(activityObj.get('Description'));
            if(descr != null)
                description += '<br/>' + descr;
        }
    }
     /* End of Activity Class */
}