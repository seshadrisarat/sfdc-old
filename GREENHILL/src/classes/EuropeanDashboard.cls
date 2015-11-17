public without sharing  class EuropeanDashboard {
   public class OppGroup{
        public Fundraising_Deal__c opp {get; set;}
        public string styleclass {get; set;}
        public string tierclass {get; set;}
        public boolean PPM {get; set;}
        public boolean dataroom {get; set;}
        public boolean blnTeaser {get; set;}
        public boolean blnFlipbook {get; set;}
        public integer iter {get; set;}

        public OppGroup(Fundraising_Deal__c o, string style, string tier, boolean p, boolean d, boolean t, boolean f,integer i){
            opp = o;
            styleclass = style;
            tierclass = tier;
            PPM = p;
            dataroom = d;
            blnTeaser = t;
            blnFlipbook = f;
            iter = i;
        }
    }
    public class normalizedOppGroup {
        public OppGroup header {get;set;}
        public List<OppGroup> content {get;set;}
        public OppGroup footer {get;set;}
        public Integer ppm {get;set;}
        public Integer dataroom {get;set;}
        public Integer intTeaser {get;set;}
        public Integer intFlipbook {get;set;}
        public Integer gp {get;set;}
        public Integer call {get;set;}
        public Integer iter {get;set;}
    }

    String currFundName;

    public list<OppGroup> getRecords() {
         //map<string,list<Fundraising_Deal__c>> oppmap = new map<string,list<Fundraising_Deal__c>>();
        map<string,map<string,list<Fundraising_Deal__c>>> oppmap = new map<string,map<string,list<Fundraising_Deal__c>>>();
        map<string,list<Fundraising_Deal__c>> tiermap = new map<string,list<Fundraising_Deal__c>>();

        string tier = '';
        list<OppGroup> ogroup = new list<OppGroup>();

        list<Fundraising_Deal__c> opps = [Select
        company__r.Type,
        company__r.Name,
        company__r.ID,
        Fund__c,
        Fund__r.Name,
        Maximum_Commitment_Size__c,
        Minimum_Commitment_Size__c,
        Stage__c,
        next_step__c,
        Materials_Sent__c,
        company__r.Sales_coverage__c,
        Call_Held_with_GP__c,
        Met_with_GP__c,
        Tier__c
                from Fundraising_Deal__c
                where Fund__c = :ApexPages.currentPage().getParameters().get('fund')
                order by Stage__c, company__r.Name];

        for(Fundraising_Deal__c opp : opps){
            tier = (opp.Tier__c == null) ?  'No Tier' : opp.Tier__c;

            if(oppmap.get(opp.Stage__c) == null) {
                oppmap.put(opp.Stage__c, new map<string,list<Fundraising_Deal__c>>());
                tiermap = new map<string,list<Fundraising_Deal__c>>();
            }

            if(tiermap.get(tier) == null)
            	tiermap.put(tier, new list<Fundraising_Deal__c>());
            tiermap.get(tier).add(opp);

			oppmap.put(opp.Stage__c, tiermap);
        }

        //system.debug('! -> '+oppmap);

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

        list<String> TierOrder = new list<String>();
        TierOrder.add('No Tier');
        Schema.DescribeFieldResult fieldResult = Fundraising_Deal__c.Tier__c.getDescribe();                
        List<Schema.PicklistEntry> picklistValue = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : picklistValue)
		{
		    TierOrder.add(f.getLabel());
		}


        for(string s : StageOrder){
        	map<string,list<Fundraising_Deal__c>> tempmap = oppmap.get(s);
            if (tempmap == null)
        		continue;
        	integer i = 0;
        	boolean PPM = true;
	        boolean dataroom = true;
	        boolean blnTeaser = true;
	        boolean blnFlipbook = true;

	        Fundraising_Deal__c totalsopp = new Fundraising_Deal__c(Maximum_Commitment_Size__c=0,Minimum_Commitment_Size__c=0);

            for (string t : TierOrder){
            	list<Fundraising_Deal__c> tempopps = tempmap.get(t);
	            if(tempopps == null)
	                continue;
	            ogroup.add(new OppGroup(null, s, t, false, false, false, false, i));

	            for(Fundraising_Deal__c opp : tempopps){
	           	    if(opp.Materials_Sent__c == null){
	                    PPM = false;
	                    dataroom = false;
	                    blnTeaser = false;
	                    blnFlipbook = false;
	                }
	                else{
	                    if(opp.Materials_Sent__c.contains('PPM') == false)
	                        PPM = false;
	                    if(opp.Materials_Sent__c.contains('Dataroom Access') == false)
	                        dataroom = false;
	                    if(opp.Materials_Sent__c.contains('Teaser') == false)
	                        blnTeaser = false;
	                    if(opp.Materials_Sent__c.contains('Flipbook') == false)
	                        blnFlipbook = false;
	                }

	                if(opp.Maximum_Commitment_Size__c != null)
	                    totalsopp.Maximum_Commitment_Size__c += opp.Maximum_Commitment_Size__c;
	                if(opp.Minimum_Commitment_Size__c != null)
	                    totalsopp.Minimum_Commitment_Size__c += opp.Minimum_Commitment_Size__c;

	                ogroup.add(new OppGroup(opp,'Fundraising Deal', '', PPM, dataroom, blnTeaser, blnFlipbook, 99));

	            }
	            i++;
            }
            ogroup.add(new OppGroup(totalsopp,'TOTALS', '', false, false, false, false, 99));
        }

        return ogroup;
    }

   public list<normalizedOppGroup> getNormalizedRecords() {
        Integer ppmI = 0;
        Integer dataroomI = 0;
        Integer intTeaser = 0;
        Integer intFlipbook = 0;
        Integer gpI = 0;
        Integer callI = 0;
        integer i = 0;

        //map<string,list<Fundraising_Deal__c>> oppmap = new map<string,list<Fundraising_Deal__c>>();
        map<string,map<string,list<Fundraising_Deal__c>>> oppmap = new map<string,map<string,list<Fundraising_Deal__c>>>();
        map<string,list<Fundraising_Deal__c>> tiermap = new map<string,list<Fundraising_Deal__c>>();

        string tier = '';

        normalizedOppGroup normGroup = new normalizedOppGroup();
        list<normalizedOppGroup> result = new list<normalizedOppGroup>();
        list<OppGroup> ogroup = new list<OppGroup>();

        list<Fundraising_Deal__c> opps = [Select
        company__r.Type,
        company__r.Name,
        company__r.ID,
        company__r.Mailing_Country__c,
        Fund__c,Fund__r.Name,
        Maximum_Commitment_Size__c,
        Minimum_Commitment_Size__c,
        Stage__c,
        next_step__c,
        Materials_Sent__c,
        company__r.Sales_coverage__c,
        Call_Held_with_GP__c,
        Met_with_GP__c,
        Tier__c
                from Fundraising_Deal__c
                where Fund__c = :ApexPages.currentPage().getParameters().get('fund')
                order by Stage__c, company__r.Name];

        for(Fundraising_Deal__c opp : opps){
            tier = (opp.Tier__c == null) ?  'No Tier' : opp.Tier__c;

            if(oppmap.get(opp.Stage__c) == null) {
                oppmap.put(opp.Stage__c, new map<string,list<Fundraising_Deal__c>>());
                tiermap = new map<string,list<Fundraising_Deal__c>>();
            }

            if(tiermap.get(tier) == null)
            	tiermap.put(tier, new list<Fundraising_Deal__c>());
            tiermap.get(tier).add(opp);

			oppmap.put(opp.Stage__c, tiermap);
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


        list<String> TierOrder = new list<String>();
        TierOrder.add('No Tier');
		Schema.DescribeFieldResult fieldResult = Fundraising_Deal__c.Tier__c.getDescribe();                
        List<Schema.PicklistEntry> picklistValue = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : picklistValue)
		{
		    TierOrder.add(f.getLabel());
		}
        system.debug('????????????StageOrder?????????????' + StageOrder);

        for(string s : StageOrder){
        	map<string,list<Fundraising_Deal__c>> tempmap = oppmap.get(s);
            if (tempmap == null)
        		continue;



        	Fundraising_Deal__c totalsopp = new Fundraising_Deal__c(Maximum_Commitment_Size__c=0,Minimum_Commitment_Size__c=0);
			ogroup = new list<OppGroup>();

			normGroup = new normalizedOppGroup();
		    normGroup.header = new OppGroup(null, s, '', false, false, false, false, 0);

			ppmI = 0;
            dataroomI = 0;
            intTeaser = 0;
            intFlipbook = 0;
            gpI = 0;
            callI = 0;

            for (string t : TierOrder){
            	    list<Fundraising_Deal__c> tempopps = tempmap.get(t);
		            if(tempopps == null)
		                continue;
		            i=0;

		            //normGroup.header.tierclass = t;
		            for(Fundraising_Deal__c opp : tempopps){
		            	boolean PPM = true;
		                boolean dataroom = true;
		                boolean blnFlipbook = true;
		                boolean blnTeaser = true;

		                if(opp.Materials_Sent__c == null){
		                    PPM = false;
		                    dataroom = false;
		                    blnFlipbook = false;
		                    blnTeaser = false;
		                }
		                else{
		                    if(opp.Materials_Sent__c.contains('PPM') == false)
		                        PPM = false;
		                    if(opp.Materials_Sent__c.contains('Dataroom Access') == false)
		                        dataroom = false;
		                    if(opp.Materials_Sent__c.contains('Teaser') == false)
		                        blnTeaser = false;
		                    if(opp.Materials_Sent__c.contains('Flipbook') == false)
		                        blnFlipbook = false;
		                }

		                if(opp.Maximum_Commitment_Size__c != null)
		                    totalsopp.Maximum_Commitment_Size__c += opp.Maximum_Commitment_Size__c;
		                if(opp.Minimum_Commitment_Size__c != null)
		                    totalsopp.Minimum_Commitment_Size__c += opp.Minimum_Commitment_Size__c;
		                if(PPM)
		                    ppmI++;
		                if(dataroom)
		                    dataroomI++;
		                if(blnTeaser)
		                    intTeaser++;
		                if(blnFlipbook)
		                    intFlipbook++;

		                if (opp.Met_with_GP__c)
		                    gpI++;
		                if (opp.Call_Held_with_GP__c)
		                    callI++;

		                if (i==0) {
		                	ogroup.add(new OppGroup(opp,'Fundraising Deal', t, PPM, dataroom, blnTeaser, blnFlipbook, i));
		                } else if (i>0) {
		                	ogroup.add(new OppGroup(opp,'Fundraising Deal', '', PPM, dataroom, blnTeaser, blnFlipbook, i));
		                }
		                i++;
		            }
		        }
		        normGroup.content = ogroup;
	            normGroup.footer = new OppGroup(totalsopp,'TOTALS', '', false, false, false, false, 99);
	            normGroup.call = callI;
	            normGroup.dataroom = dataroomI;
	            normGroup.intTeaser = intTeaser;
	            normGroup.intFlipbook = intFlipbook;
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
        EuropeanDashboard controller = new EuropeanDashboard();
        vced2__Fund__c testFund = new vced2__Fund__c (Name='testFund');
        insert testFund;

        Fundraising_Deal__c testOpp = new Fundraising_Deal__c(Name='testOpp', Materials_Sent__c = 'Teaser; Flipbook; PPM', Fund__c = testFund.Id, Stage__c='Circled', Tier__c= 'Tier I', Close_Date__c=System.Today(), Maximum_Commitment_size__c=1, Minimum_Commitment_Size__c=2);
        insert testOpp;

        list<OppGroup> testFundDeals;

        PageReference pageRef = Page.FundDashboardReportFundRaisingDeal;
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