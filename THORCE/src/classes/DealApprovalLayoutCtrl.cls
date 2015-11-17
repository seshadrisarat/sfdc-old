/*
*	DealApprovalLayoutCtrl – This is the controller class referenced by the layout components used within the
*								Deal Approval page (Office, Retail, Amendment, Memo)
* 	Authors :  Sahir Ali, Don Koppel 3/15/2014	
*/
public with sharing class DealApprovalLayoutCtrl {
	
	public Id parentSObjectId 						{get;set;}
	private Deal__c dealForApproval 				{get;set;}
	private Deal__c deal							{get;set;}
	private Deal_Contact__c dealContact 			{get;set;}
	private Deal_Contact__c dealContactTen 			{get;set;}
	private Deal_Contact__c dealContactBro 			{get;set;}
	private Property__c dealProperty 				{get;set;}
	private ProcessInstanceStep dealApproval		{get;set;}
	public list<RentRow> rentDetails 				{get; private set;}
    public integer rentDetailsSize 					{get { return this.rentDetails!=null?this.rentDetails.size():0; } }
    public list<RentRow> rentIncreaseDetails		{get; private set;}
    public integer rentIncreaseDetailsSize			{get { return this.rentIncreaseDetails!=null?this.rentIncreaseDetails.size():0; } }
    public list<RentRow> optionRentDetails 			{get; private set;}
    public integer optionRentDetailsSize 			{get { return this.optionRentDetails!=null?this.optionRentDetails.size():0; } }
    public list<RentRow> optionRentIncreaseDetails	{get; private set;}
    public integer optionRentIncreaseDetailsSize	{get { return this.optionRentIncreaseDetails!=null?this.optionRentIncreaseDetails.size():0; } }
	public Integer twoColumns						{get;set;}
	public Integer threeColumns						{get;set;}

    public enum RENT_TERM_UNIT 					{Day, Week, Month, Year}
    public RENT_TERM_UNIT rentTermUnit 			{get; private set;}
    public RENT_TERM_UNIT optionRentTermUnit 	{get; private set;}

    public string columnHeaderAnnualAmount { get { return rentTermUnit==RENT_TERM_UNIT.Year ? 'Annual Amount' : 'Total Flat Fee'; } }
    public string columnHeaderUnitPeriodlyAmount { get { return rentTermUnit==RENT_TERM_UNIT.Year ? 'Monthly Amount' : this.rentTermUnit+'(s) Flat Amount'; } }
    public string labelFootage { get { return this.dealForApproval.Measurement_Unit__c=='Meter' ? 'Meterage' : 'Footage'; } }
    public string labelPSF { get { return this.dealForApproval.Measurement_Unit__c=='Meter' ? 'PSM Amount' : 'PSF Amount'; } }
    public integer termLengthInDays { get; private set; }
    public integer optionTermLengthInDays { get; private set; }

	//This property returns the first rent record for the initial lease term, or an empty record if no increases are defined
	//Values are used to populate fields within the Rental section
	public Deal_Rent__c rentFirstRecord				{
														get {
															if(rentDetailsSize > 0)
																return rentDetails[0].record;
															else
																return new Deal_Rent__c();
													 	}
													 	private set;
													}	

	//This property returns the first rent increase record, or an empty record if no increases are defined
	//Values are used to populate fields within the Rental section
	public Deal_Rent__c rentIncreaseFirstRecord		{
														get {
															if(rentIncreaseDetailsSize > 0)
																return rentIncreaseDetails[0].record;
															else
																return new Deal_Rent__c();
													 	}
													 	private set;
	}	

	//This property returns the first option rent increase record, or an empty record if no increases are defined
	//Values are used to populate fields within the Rental section
	public Deal_Rent__c optionRentFirstRecord		{
														get {
															if(optionRentDetailsSize > 0)
																return optionRentDetails[0].record;
															else
																return new Deal_Rent__c();
													 	}
													 	private set;
	}	

	//This property returns the first rent increase record, or an empty record if no increases are defined
	//Values are used to populate fields within the Rental section
	public Deal_Rent__c optionRentIncreaseFirstRecord{
														get {
															if(optionRentIncreaseDetailsSize > 0)
																return optionRentIncreaseDetails[0].record;
															else
																return new Deal_Rent__c();
													 	}
													 	private set;
	}	
	
	//This property returns the number of years in the initial lease term
	public Integer initialTerm {
														get {
															Integer years = 0;
															Decimal yearsDec = 0.0;
															
															if (dealForApproval != null) {
																if (dealForApproval.Commencement_Date__c != null && dealForApproval.Expiration_Date__c != null){
																	yearsDec = (dealForApproval.Commencement_Date__c.DaysBetween(dealForApproval.Expiration_Date__c)/365.25) + 0.5;
																	years = Integer.valueOf(yearsDec.round());
																}
																else
																	years = 0;
															}
															return years;
														}
														private set;
	}
	
	//This property returns the number of years in the optional lease term
	public Integer initialTermOption {
														get {
															Integer years = 0;
															
															if (dealForApproval != null) {
																if (dealForApproval.Option_Start_Date__c != null && dealForApproval.Option_End_Date__c != null)
																	return dealForApproval.Option_End_Date__c.year() - dealForApproval.Option_Start_Date__c.year();
																else
																	return 0;
															}
															return years;
														}
														private set;
	}
    
    public DealApprovalLayoutCtrl(){
    	
    	init();
    }
    
    public void init(){
    	
        //twoColumns = 2;
        //threeColumns = 2;
    	
    	System.debug('In component deal: ' + parentSObjectId);
    	if(parentSObjectId !=null) {
	    	System.debug('Deal id: ' + parentSObjectId);
	    	string query = 'select ' + generateListOfDealFields() + ' From Deal__c where Id=:parentSObjectId';
	        this.dealForApproval = database.query(query); 
    	}
    }
        
    private void computeRentTermUnit(boolean isOption) {
    	Date localStartDate, localEndDate;
    	integer localTermLengthInDays;
    	RENT_TERM_UNIT localRentTermUnit;
    	
    	if(isOption) {
	    	localStartDate = this.dealForApproval.Option_Start_Date__c;
	    	localEndDate = this.dealForApproval.Option_End_Date__c;
	    	this.optionTermLengthInDays = -1;
	    	this.optionRentTermUnit = null;
    	}
    	else {
    		localStartDate = this.dealForApproval.Commencement_Date__c;
	    	localEndDate = this.dealForApproval.Expiration_Date__c;
	    	this.termLengthInDays = -1;
	    	this.rentTermUnit = null;
    	}
    	
    	// both start date and end date must be populated before continuing
		if(localStartDate==null || localEndDate==null)
			return;
			
    	// option term length in days must be greater than or equal to zero
        localTermLengthInDays = localStartDate.daysBetween(localEndDate) + 1;
        localRentTermUnit = localTermLengthInDays<=6 ? RENT_TERM_UNIT.Day :
        				localTermLengthInDays<=28 ? RENT_TERM_UNIT.Week :
        				localTermLengthInDays<=364 ? RENT_TERM_UNIT.Month :
        				RENT_TERM_UNIT.Year;
        
        // set this. variables
        if(isOption) {
        	this.optionTermLengthInDays = localTermLengthInDays;
        	this.optionRentTermUnit = localRentTermUnit;
        }
        else {
        	this.termLengthInDays = localTermLengthInDays;
        	this.rentTermUnit = localRentTermUnit;
        }
    }
    
	private string generateListOfDealConFields() {
        return string.join(new list<string>(Schema.SObjectType.Deal_Contact__c.fields.getMap().keySet()), ',');
    }
	                                                
	private string generateListOfDealFields() {
        return string.join(new list<string>(Schema.SObjectType.Deal__c.fields.getMap().keySet()), ',');
    }
	
	public Deal__c getdealForApproval(){
		System.debug('In getdealapprova emthod');
		if(parentSObjectId !=null) {
	    	System.debug('Deal id: ' + parentSObjectId);
	    	string query = 'select ' + generateListOfDealFields() + ',Tenant__r.Tenant_Trade_Name__c, Tenant__r.Legal_Name__c, Tenant__r.Tenant_Type__c, Owner.Name, Property__r.Name From Deal__c where Id=:parentSObjectId';
	        this.dealForApproval = database.query(query);
    	}
    	return dealForApproval;
	}

    public ProcessInstanceStep getdealApproval()
    {
    	List<String> statuses = new List<String>{'Approved', 'Rejected'};

    	//deal__c curDeal;
    	Id userId = UserInfo.getUserId();
    	ProcessInstanceStep approvalHistory = new ProcessInstanceStep(); 
        
        List<ProcessInstanceStep> approvalHistoryList = [SELECT p.Id, p.ProcessInstanceId, p.ActorId, p.StepStatus, p.CreatedDate, 
        												p.Comments, p.ProcessInstance.TargetObjectId 
        											FROM ProcessInstanceStep p
        											WHERE ActorId = :userId
        											AND   p.StepStatus IN :statuses
        											AND   p.ProcessInstance.TargetObjectId = :parentSObjectId
        											ORDER BY p.CreatedDate DESC
        											LIMIT 1];
        											
		if (approvalHistoryList.size() > 0) {
			approvalHistory = approvalHistoryList[0];
		}
    	
		return approvalHistory;
    }
	
	public Deal_Contact__c getdealContact(){
		String role = 'Guarantor';
		if(parentSObjectId !=null) {
	    	System.debug('inside deal contact Deal id: ' + parentSObjectId);
	
	    	try{
				this.dealContact = [select Contact__r.Name, account_zip_loop__c,phone_loop__c,createdbyid,lastmodifieddate,id,role__c,name,isdeleted,fax_loop__c,systemmodstamp,account_city_loop__c,account_state_loop__c,contact__c,deal__c,primary__c,createddate,emial_loop__c,tenant_trade_name_loop__c,account_trade_name_loop__c,tenant_tax_id_loop__c,contact_title_loop__c,account_name__c,legal_name_loop__c,account_street_loop__c,lastmodifiedbyid 
									From Deal_Contact__c 
									where role__c = 'Guarantor' AND deal__c=:parentSObjectId limit 1];
					System.debug('dealcontact' + dealContact);				
				
				return dealContact;
	    	}
	    	catch(Exception ex){
	    		return null;
			}
		}
		return null;
	}	

	public Deal_Contact__c getdealContactBro(){
			
			if(parentSObjectId !=null) {
	    	System.debug('inside deal contact Deal id: ' + parentSObjectId);

	    	try{
		    	this.dealContactBro = [select Contact__r.Name, account_zip_loop__c,phone_loop__c,createdbyid,lastmodifieddate,id,role__c,name,isdeleted,fax_loop__c,systemmodstamp,account_city_loop__c,account_state_loop__c,contact__c,deal__c,primary__c,createddate,emial_loop__c,tenant_trade_name_loop__c,account_trade_name_loop__c,tenant_tax_id_loop__c,contact_title_loop__c,account_name__c,legal_name_loop__c,account_street_loop__c,lastmodifiedbyid 
		    						From Deal_Contact__c 
		    						where role__c = 'Broker' AND deal__c=:parentSObjectId limit 1];
		    		System.debug('dealcontact' + dealContactBro);				
		    	
		    	return dealContactBro;
	    	}
	    	catch(Exception ex){
	    		return null;
			}
		}
		return null;
	}	

	public Deal_Contact__c getdealContactTen(){
		
		if(parentSObjectId !=null) {
	    	System.debug('inside deal contact Deal id: ' + parentSObjectId);

	    	try{
		    	this.dealContactTen = [select Contact__r.Name, account_zip_loop__c,phone_loop__c,createdbyid,lastmodifieddate,id,role__c,name,isdeleted,fax_loop__c,systemmodstamp,account_city_loop__c,account_state_loop__c,contact__c,deal__c,primary__c,createddate,emial_loop__c,tenant_trade_name_loop__c,account_trade_name_loop__c,tenant_tax_id_loop__c,contact_title_loop__c,account_name__c,legal_name_loop__c,account_street_loop__c,lastmodifiedbyid 
		    						From Deal_Contact__c 
		    						where role__c = 'Tenant' AND deal__c=:parentSObjectId limit 1];
		    		System.debug('dealcontact' + dealContact);				
		    	
		    	return dealContactTen;
	    	}
	    	catch(Exception ex){
	    		return null;
			}
		}
	
		return null;
	}	

	public Property__c getdealProperty(){
			
			if(parentSObjectId !=null) {
	    	//System.debug('inside deal contact Deal id: ' + parentSObjectId);

	    	try{
		    	this.dealProperty = [SELECT Name 
			    						FROM Property__c
			    						WHERE Id IN (
			    							SELECT Property__c
			    							FROM Deal_Property__c
			    							WHERE Deal__c = :parentSObjectId) LIMIT 1];
		    	
		    	return dealProperty;
	    	}
	    	catch(Exception ex){
	    		return null;
			}
		}
		return null;
	}	
	
	public list<RentRow> getOptionRentRecords()
	{
		this.loadDealRentData();
		return optionRentDetails;
	}
	
	public list<RentRow> getRentRecords()
	{
		this.loadDealRentData() ;
		
		return rentDetails;
	}
    
    // loads the deal record and term rent and option term rent data into array list
    private void loadDealRentData() {
		this.rentDetails = new list<RentRow>();
		this.rentIncreaseDetails = new list<RentRow>();
		this.optionRentDetails = new list<RentRow>();
		this.optionRentIncreaseDetails = new list<RentRow>();
		if(this.parentSObjectId!=null){
			Id dealId = this.parentSObjectId;
			system.debug('in loaddealrentdata, id is ' + dealId);
			string query = 'select ' + generateListOfDealFields() + ' From Deal__c where Id=:dealId';
			this.deal = database.query(query); 
			system.debug('deal is ' + parentSObjectId);
			Integer counter = 0;
        	
			// retrieve child Deal_Rent__c data - Note: there's 2 different record types: Rent and Rent Increase
            for(Deal_Rent__c dr : [select Id,
            							  RecordType.Name,
            							  Is_Option__c,
            							  Leasing_Deal__c,
                                          Start_Period__c, 
                                          End_Period__c, 
                                          Annual_Rent_Amount__c, 
                                          Unit_Periodly_Rent_Amount__c, 
                                          PSF_Rent_Amount__c,
                                          Unnatural_Break__c,
                                          Natural_Break_Formula__c,
                                          Base_Rent_Increase_Type__c, 
                                          Base_Rent_Increase_Amount__c, 
                                          Base_Rent_Increase_Frequency_Amount__c,
                                          Base_Rent_Increase_Frequency_Unit__c
                                          from Deal_Rent__c 
                                   where Leasing_Deal__c = :this.parentSObjectId 
                                   order by Start_Period__c asc]) {
                // add record to corresponding this. array list
                if('Rent'.equals(dr.RecordType.Name) && !dr.Is_Option__c)
	                this.rentDetails.add(new RentRow(this.deal, dr, ++counter));
	            else if('Rent'.equals(dr.RecordType.Name) && dr.Is_Option__c)
	            	this.optionRentDetails.add(new RentRow(this.deal, dr, ++counter));
	           	else if('Rent Increase'.equals(dr.RecordType.Name) && !dr.Is_Option__c)
               		this.rentIncreaseDetails.add(new RentRow(this.deal, dr, counter++));
               	else
               		this.optionRentIncreaseDetails.add(new RentRow(this.deal, dr, counter++));
            }
            system.debug('rent list is ' + rentDetails);            
            system.debug('rent increase list is ' + rentIncreaseDetails);
            system.debug('option rent list is ' + optionRentDetails);            
            system.debug('option rent increase list is ' + optionRentIncreaseDetails);

            computeRentTermUnit(false);
            computeRentTermUnit(true);
    	}
    }
	
	public void SetNumberOfColumns(Integer screenSize){
		//twoColumns = 2;

		//if(screenSize < 480){
			twoColumns = 1;
			threeColumns = 1;
		//}
		System.Debug('twocol = ' + twoColumns);
	}
	  
	// Wrapper class for Deal_Rent__c object
    public class RentRow {
        private Deal__c deal 		{get; private set; }
        public Deal_Rent__c record 	{get; private set; }
        public integer indx 		{get; private set; }
        public decimal psfAmt { 
            get { 
                decimal returnVal = 0.0;
                if(record.Annual_Rent_Amount__c != null &&  deal.Estimated_Square_Footage__c != null)
                {
                    returnVal = (record.Annual_Rent_Amount__c / deal.Estimated_Square_Footage__c).setScale(2);
                }
                return returnVal;
            }       
        }
        
        public decimal naturalBreak { 
        	get { 
	            decimal returnVal = 0.0;
	            if(record.Annual_Rent_Amount__c != null &&  deal.Percentage_Rent__c != null &&  deal.Percentage_Rent__c != 0)
	            {
	                returnVal = (record.Annual_Rent_Amount__c / deal.Percentage_Rent__c * 100).setScale(2);
	            }
	            return returnVal;
        	}
        }
        
        public RentRow(Deal__c d, Deal_Rent__c r, integer i) {
            deal = d;
            record = r;
            indx = i;
		}
	}
}