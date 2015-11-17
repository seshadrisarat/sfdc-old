public without sharing class SecondaryAdvisoryPhonebookReport {


    String currFundName; 
    
    public List<RowClass> getRecords() { 
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
        
        
        /*old code against Opp
        return[Select ID, Name, Account.Type, Account.Name,Account.ID, vced2__Fund__c,vced2__Fund__r.Name, Account.Consultant__c,
        			  (SELECT Description,ActivityDate from ActivityHistories where ActivityType in ('Call','Meeting') and ActivityDate >= :mindate and ActivityDate <= :maxdate order by ActivityDate desc),
        Maximum_Commitment_Size__c, Minimum_Commitment_Size__c, StageName, NextStep, Materials_Sent__c, Account.Sales_coverage__c, LastActivityDate
                from Opportunity 
                where vced2__Fund__c = :ApexPages.currentPage().getParameters().get('fund')
                order by StageName, Account.Name] ;
        */
		List<RowClass> lstResult = new List<RowClass>();
		for(Fundraising_Deal__c item : [SELECT ID, Name, Company__r.Type, Company__r.Name,Company__r.ID, Fund__c,Fund__r.Name, Company__r.Consultant__c,Source__c,fee__c,
        			  (SELECT Description,ActivityDate from ActivityHistories where ActivityType in ('Call','Meeting','Email') 
        			  	and ActivityDate >= :mindate and ActivityDate <= :maxdate order by ActivityDate desc),
        				Maximum_Commitment_Size__c, Minimum_Commitment_Size__c, Stage__c, Next_Step__c, Materials_Sent__c, Status__c, 
        				Company__r.Sales_coverage__c, LastActivityDate
                FROM Fundraising_Deal__c 
                WHERE Fund__c = :ApexPages.currentPage().getParameters().get('fund')
                ORDER BY Status__c, Company__r.Name])
		{
			lstResult.add(new RowClass(item));
		}
		
	    return lstResult;                
    } 
    
    public static testMethod void testThis()  {
        vced2__Fund__c testFund = new vced2__Fund__c (Name='testFund');
        insert testFund;
    	Fundraising_Deal__c testFD = new Fundraising_Deal__c(Fund__c=testFund.Id);
    	insert testFD;
    	
    	ApexPages.currentPage().getParameters().put('mint', '2010-10-10');
    	ApexPages.currentPage().getParameters().put('maxt', '2011-11-11');
    	ApexPages.currentPage().getParameters().put('fund', testFund.Id);
    	
    	SecondaryAdvisoryPhonebookReport con = new SecondaryAdvisoryPhonebookReport();
    	con.getFundName();
    	con.setFundName('test');
    	for(RowClass item : con.getRecords()) {
    		item.getMaterialsSent();
    		item.getSalesCoverage();
    	}
    }
    
    
    
    public void setFundName(String currFund) {
		this.currFundName = currFund; 
	}
    
    public String getFundName() {
		vced2__Fund__c Fund = [select Id, Name from vced2__Fund__c where id = :ApexPages.currentPage().getParameters().get('fund')];
		return Fund.Name; 
	}
	
	public class RowClass {
		public RowClass(Fundraising_Deal__c p_fd) {
			fd = p_fd;
		}
		public Fundraising_Deal__c fd {get;set;}
		public String getMaterialsSent() {
			String strResult = '';
			if (fd.Materials_Sent__c != null)
				strResult = fd.Materials_Sent__c.replace(';', '; ');
			return strResult;
		}
		public String getSalesCoverage() {
			String strResult = '';
			if (fd.Company__r.Sales_coverage__c != null)
				strResult = fd.Company__r.Sales_coverage__c.replace(';', '; ');
			return strResult;
		}
	}
	
	public static testMethod void testMyController()  {
        String testFundName; 
        placementPhonebookReport controller = new placementPhonebookReport();
        vced2__Fund__c testFund = new vced2__Fund__c (Name='testFundSecAdvis');
        insert testFund;
        
        Opportunity testOpp = new Opportunity(Name='testOppSecAdvis',vced2__Fund__c = testFund.Id, StageName='Circled', CloseDate=System.Today());
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