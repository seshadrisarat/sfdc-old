public class placementPhonebookReport {
    String currFundName; 
    
    public Opportunity[] getRecords() { 
    /** No longer necessary since API 18 removes list size limte   
    	integer oppnum = [select count() from Opportunity where vced2__Fund__c = :ApexPages.currentPage().getParameters().get('fund')];
        if(oppnum == 0 || ApexPages.currentPage().getParameters().get('mint') <> null || ApexPages.currentPage().getParameters().get('maxt') <> null)
          oppnum = 1;
        integer activitylim = 1000/oppnum;
        system.debug('*****oppnum: ' + oppnum);
        system.debug('*****activitylim: ' + activitylim);
    **/   
        Date mindate = Date.Today().addyears(-100);
        Date maxdate = Date.Today().addyears(100); 
        if(ApexPages.currentPage().getParameters().get('mint') <> null)
        	mindate = Date.valueof(ApexPages.currentPage().getParameters().get('mint'));
        if(ApexPages.currentPage().getParameters().get('maxt') <> null)	
        	maxdate = Date.valueof(ApexPages.currentPage().getParameters().get('maxt'));
        	
        system.debug('*****mindate: '+mindate);
        system.debug('*****maxdate: '+maxdate);
        
        
        
        return[Select ID, Name, Account.Type, Account.Name,Account.ID, vced2__Fund__c,vced2__Fund__r.Name, Account.Consultant__c,
        			  (SELECT Description,ActivityDate from ActivityHistories where ActivityType in ('Call','Meeting') and ActivityDate >= :mindate and ActivityDate <= :maxdate order by ActivityDate desc),
        Maximum_Commitment_Size__c, Minimum_Commitment_Size__c, StageName, NextStep, Materials_Sent__c, Account.Sales_coverage__c, LastActivityDate
                from Opportunity 
                where vced2__Fund__c = :ApexPages.currentPage().getParameters().get('fund')
                order by StageName, Account.Name] ;
    } 
    
    
    public void setFundName(String currFund){
            this.currFundName = currFund; 
        }
    
    public String getFundName(){
            vced2__Fund__c Fund = [select Id, Name from vced2__Fund__c where id = :ApexPages.currentPage().getParameters().get('fund')];
            
            return Fund.Name; 
        }
   // public String getRetint(String val)
    //{
    //    return val;
   // }
        
        
public static testMethod void testMyController()  {
      
        String testFundName; 
        placementPhonebookReport controller = new placementPhonebookReport();
        vced2__Fund__c testFund = new vced2__Fund__c (Name='testFund');
        insert testFund;
        
        Opportunity testOpp = new Opportunity(Name='testOpp',vced2__Fund__c = testFund.Id, StageName='Circled', CloseDate=System.Today());
        insert testOpp;
        
        Opportunity [] testFundDeals;
        
        
        
        
        PageReference pageRef = Page.PhonebookReport;
        system.assert(testFund.Id != null); 
        
        // Add parameters to page URL
        pageRef.getParameters().put('fund', testFund.Id);
        
        Test.setCurrentPage(pageRef);
      // Add parameters to page URL
        pageRef.getParameters().put('fund', testFund.Id);
        
        
        //get the records for this page parameter
        testFundDeals = controller.getRecords(); 
         
        testFundName = controller.getFundName();
        
        controller.setFundName('testFund');
        
        
        // Verify that page fails without parameters
        System.assert(testFundDeals[0].Name <> '' );
        System.assert(testFundName <> '' );
             
    }    
    
  
}