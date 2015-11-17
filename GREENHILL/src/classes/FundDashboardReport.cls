public class FundDashboardReport {
    
   public class OppGroup{
        public Opportunity opp {get; set;}
        public string styleclass {get; set;}
        public boolean PPM {get; set;}
        public boolean dataroom {get; set;}
        
        public OppGroup(Opportunity o, string style, boolean p, boolean d){
            opp = o;
            styleclass = style;
            PPM = p;
            dataroom = d;
        }
    }
	public class normalizedOppGroup {
		public OppGroup header {get;set;}
		public List<OppGroup> content {get;set;}
		public OppGroup footer {get;set;}
		public Integer ppm {get;set;}
		public Integer dataroom {get;set;}
		public Integer gp {get;set;}
		public Integer call {get;set;}
	}
	
    String currFundName; 
    
    public list<OppGroup> getRecords() {
        map<string,list<Opportunity>> oppmap = new map<string,list<Opportunity>>(); 
        list<OppGroup> ogroup = new list<OppGroup>();
         
        list<Opportunity> opps = [Select Account.Type, Account.Name,Account.ID, vced2__Fund__c, vced2__Fund__r.Name, Maximum_Commitment_Size__c, 
        Minimum_Commitment_Size__c, StageName, NextStep, Materials_Sent__c, Account.Sales_coverage__c, Call_Held_with_GP__c, Met_with_GP__c
                from Opportunity 
                where vced2__Fund__c = :ApexPages.currentPage().getParameters().get('fund')
                order by StageName, Account.Name];
        
        for(Opportunity opp : opps){
            if(oppmap.get(opp.StageName) == null)
                oppmap.put(opp.StageName, new list<Opportunity>());
            oppmap.get(opp.StageName).add(opp); 
        }
        
        list<String> StageOrder = new list<String>();
        StageOrder.add('Closed');
        StageOrder.add('Circled');
        StageOrder.add('Strong Interest');
        StageOrder.add('Continued Interest');
        StageOrder.add('Weak Interest');
        StageOrder.add('Pending');
        StageOrder.add('Meeting Scheduled');
        StageOrder.add('Prospect');
        StageOrder.add('Decline After Meeting');
        StageOrder.add('Decline Before Meeting');                
        
        for(string s : StageOrder){
            list<Opportunity> tempopps = oppmap.get(s);
            if(tempopps == null)
            	continue;
            
            ogroup.add(new OppGroup(null, s, false, false));
            Opportunity totalsopp = new Opportunity(Maximum_Commitment_Size__c=0,Minimum_Commitment_Size__c=0);
            	 
            for(Opportunity opp : tempopps){
                boolean PPM = true;
                boolean dataroom = true;
                if(opp.Materials_Sent__c == null){
                    PPM = false;
                    dataroom = false;
                }
                else{
                    if(opp.Materials_Sent__c.contains('PPM') == false)
                        PPM = false;
                    if(opp.Materials_Sent__c.contains('Dataroom Access') == false)
                        dataroom = false;    
                }
                
                if(opp.Maximum_Commitment_Size__c != null)
                	totalsopp.Maximum_Commitment_Size__c += opp.Maximum_Commitment_Size__c;
                if(opp.Minimum_Commitment_Size__c != null)
                	totalsopp.Minimum_Commitment_Size__c += opp.Minimum_Commitment_Size__c;
                		
                ogroup.add(new OppGroup(opp,'OPPORTUNITY', PPM, dataroom));
            }
            ogroup.add(new OppGroup(totalsopp,'TOTALS', false, false));
        }
                
        return ogroup;        
    } 

    public list<normalizedOppGroup> getNormalizedRecords() {
    	Integer ppmI = 0;
		Integer dataroomI = 0;
		Integer gpI = 0;
		Integer callI = 0;
    	
        map<string,list<Opportunity>> oppmap = new map<string,list<Opportunity>>(); 
        normalizedOppGroup normGroup = new normalizedOppGroup();
        list<normalizedOppGroup> result = new list<normalizedOppGroup>();  
        list<OppGroup> ogroup = new list<OppGroup>();
         
        list<Opportunity> opps = [Select Account.Type, Account.Name,Account.ID, vced2__Fund__c, vced2__Fund__r.Name, Maximum_Commitment_Size__c, 
        Minimum_Commitment_Size__c, StageName, NextStep, Materials_Sent__c, Account.Sales_coverage__c, Call_Held_with_GP__c, Met_with_GP__c
                from Opportunity 
                where vced2__Fund__c = :ApexPages.currentPage().getParameters().get('fund')
                order by StageName, Account.Name];
        
        for(Opportunity opp : opps){
            if(oppmap.get(opp.StageName) == null)
                oppmap.put(opp.StageName, new list<Opportunity>());
            oppmap.get(opp.StageName).add(opp); 
        }
        
        list<String> StageOrder = new list<String>();
        StageOrder.add('Closed');
        StageOrder.add('Circled');
        StageOrder.add('Strong Interest');
        StageOrder.add('Continued Interest');
        StageOrder.add('Weak Interest');
        StageOrder.add('Pending');
        StageOrder.add('Meeting Scheduled');
        StageOrder.add('Prospect');
        StageOrder.add('Decline After Meeting');
        StageOrder.add('Decline Before Meeting');                
        
        for(string s : StageOrder){
        	ppmI = 0;
			dataroomI = 0;
			gpI = 0;
			callI = 0;
        	
        	normGroup = new normalizedOppGroup();
            list<Opportunity> tempopps = oppmap.get(s);
            if(tempopps == null)
            	continue;
            
            normGroup.header = new OppGroup(null, s, false, false);
            Opportunity totalsopp = new Opportunity(Maximum_Commitment_Size__c=0,Minimum_Commitment_Size__c=0);
			ogroup = new list<OppGroup>();
			            	 
            for(Opportunity opp : tempopps){
                boolean PPM = true;
                boolean dataroom = true;
                if(opp.Materials_Sent__c == null){
                    PPM = false;
                    dataroom = false;
                }
                else{
                    if(opp.Materials_Sent__c.contains('PPM') == false)
                        PPM = false;
                    if(opp.Materials_Sent__c.contains('Dataroom Access') == false)
                        dataroom = false;    
                }
                
                if(opp.Maximum_Commitment_Size__c != null)
                	totalsopp.Maximum_Commitment_Size__c += opp.Maximum_Commitment_Size__c;
                if(opp.Minimum_Commitment_Size__c != null)
                	totalsopp.Minimum_Commitment_Size__c += opp.Minimum_Commitment_Size__c;
                if(PPM)
                	ppmI++;
				if(dataroom)
					dataroomI++;
				if (opp.Met_with_GP__c)
					gpI++;	
				if (opp.Call_Held_with_GP__c)
					callI++;	
                		
                ogroup.add(new OppGroup(opp,'OPPORTUNITY', PPM, dataroom));
            }
            normGroup.content = ogroup;
            normGroup.footer = new OppGroup(totalsopp,'TOTALS', false, false);
            normGroup.call = callI;
            normGroup.dataroom = dataroomI;
            normGroup.gp = gpI;
            normGroup.ppm = ppmI;
            result.add(normGroup);
        }
                
        return result;        
    } 
    
    
    public void setFundName(String currFund){
        this.currFundName = currFund; 
    }
    
    public String getFundName(){
       vced2__Fund__c Fund = [select Id, Name from vced2__Fund__c where id = :ApexPages.currentPage().getParameters().get('fund')];     
       return Fund.Name; 
   }
   
   
        
        
public static testMethod void testMyController()  {
      
        String testFundName; 
        FundDashboardReport controller = new FundDashboardReport();
        vced2__Fund__c testFund = new vced2__Fund__c (Name='testFund');
        insert testFund;
        
        Opportunity testOpp = new Opportunity(Name='testOpp',vced2__Fund__c = testFund.Id, StageName='Circled', CloseDate=System.Today(), Maximum_Commitment_size__c=1, Minimum_Commitment_Size__c=2);
        insert testOpp;
        
        list<OppGroup> testFundDeals;
        
        
        
        
        PageReference pageRef = Page.FundDashboardReport;
        system.assert(testFund.Id != null); 
        
        // Add parameters to page URL
        pageRef.getParameters().put('fund', testFund.Id);
        
        Test.setCurrentPage(pageRef);
      // Add parameters to page URL
        pageRef.getParameters().put('fund', testFund.Id);
        
        
        //get the records for this page parameter
        testFundDeals = controller.getRecords(); 
         
        testFundName = controller.getFundName();
        
        list<normalizedOppGroup> testListOG = controller.getNormalizedRecords();
        
        controller.setFundName('testFund');
        
        
        // Verify that page fails without parameters
        System.assert(testFundDeals <> null);
        System.assert(testFundName <> '' );
             
    }    
    

}