/*
*       LeasingDealDetailController is used to perform Controller logic for Leasing Deal Detail VF Page.
* 
*       Author  :   Wilson Ng 
*       Date    :   November 7, 2012
* 
*		Last Modified  :  Mar 2014 - WNG - Phase 1.1 changes:
*											Updated calculator to handle short and long term leases.
*											Added dynamic increase types and new Option rent rows.
*											New currency symbol and manual rows.
*/
public with sharing class LeasingDealDetailController {

    static string GROSS_DEAL         = 'Gross Deal';
    static string PRO_RATA_SHARE     = 'Pro Rata Share';
    static string PRO_RATA_OVER_YEAR = 'Pro Rata Increase over Base Year';
    static string FIXED_CAM_CHARGE   = 'Fixed CAM Charge';
    static string SPECIFIC_CHARGE          = 'Specific Charge';
    static string INCLUDED_IN_BASE_RENT    = 'Included in Base Rent';
    static string SUBMETERED_ELECRIC               = 'Submetered';

    public string grossDeal { get { return GROSS_DEAL; } }
    public string proRataShare { get { return PRO_RATA_SHARE; } }
    public string proRataOverYear { get { return PRO_RATA_OVER_YEAR; } }
    public string fixedCAM { get { return FIXED_CAM_CHARGE; } }
    public string specificCharge { get { return SPECIFIC_CHARGE; } }
    public string includedInbaseRent { get { return INCLUDED_IN_BASE_RENT; } }
    public string SubmeteredElectric { get { return SUBMETERED_ELECRIC; } }
    public enum RENT_TERM_UNIT {Day, Week, Month, Year}
    public enum INC_TYPE {Dollar, Psf, Percent}

    public LeasingDealDetailController MyController {
        get; 
        set {
            MyController = value;
            this.deal = MyController.deal;
            this.rentDetails = MyController.rentDetails;
            this.rentIncreaseDetails = MyController.rentIncreaseDetails;
            this.optionRentDetails = MyController.optionRentDetails;
            this.optionRentIncreaseDetails = MyController.optionRentIncreaseDetails;
            this.canEdit = MyController.canEdit;
            this.isEditMode = MyController.isEditMode;
            this.counter = MyController.counter;
        }
    }
    
    public Deal__c deal {get; private set;}
    
    public list<RentRow> rentDetails {get; private set;}
    public integer rentDetailsSize { get { return this.rentDetails!=null?this.rentDetails.size():0; } }
    public list<RentRow> rentIncreaseDetails {get; private set;}
    public integer rentIncreaseDetailsSize { get { return this.rentIncreaseDetails!=null?this.rentIncreaseDetails.size():0; } }
    public RENT_TERM_UNIT rentTermUnit {get; private set;}
    
    public list<RentRow> optionRentDetails {get; private set;}
    public integer optionRentDetailsSize { get { return this.optionRentDetails!=null?this.optionRentDetails.size():0; } }
    public list<RentRow> optionRentIncreaseDetails {get; private set;}
    public integer optionRentIncreaseDetailsSize { get { return this.optionRentIncreaseDetails!=null?this.optionRentIncreaseDetails.size():0; } }
    public RENT_TERM_UNIT optionRentTermUnit {get; private set;}
    
    public boolean canEdit {get; private set;}
    public boolean isEditMode {get; private set;}
    public boolean isSysAdmin {get; private set;}
    public string sectionTitle { get { return (this.deal.Id != null) ? 'Leasing Deal' : 'New Leasing Deal'; } }
    public string inlineVFExpanderForDueDiligencePage { get { return (InlineVFExpander_Pages__c.getInstance('DueDiligenceChecklistPage')!=null?InlineVFExpander_Pages__c.getInstance('DueDiligenceChecklistPage').Page_Id__c:''); } }
    public integer counter {get; private set;}
    public string columnHeaderAnnualAmount { get { return rentTermUnit==RENT_TERM_UNIT.Year ? 'Annual Amount' : 'Total Flat Fee'; } }
    public string columnHeaderUnitPeriodlyAmount { get { return rentTermUnit==RENT_TERM_UNIT.Year ? 'Monthly Amount' : this.rentTermUnit+'(s) Flat Amount'; } }
    public string labelFootage { get { return this.deal.Measurement_Unit__c=='Meter' ? 'Meterage' : 'Footage'; } }
    public string labelPSF { get { return this.deal.Measurement_Unit__c=='Meter' ? 'PSM' : 'PSF'; } }
    public integer termLengthInDays { get; private set; }
    public integer optionTermLengthInDays { get; private set; }
    
    public LeasingDealDetailController() {
        string dealid = ApexPages.currentPage().getParameters().get('id');
        if(string.isNotEmpty(dealid))
            this.deal = [select id,
            					Deal_Stage__c,
                                Estimated_Square_Footage__c, 
                                Base_Rent__c,
                                Commencement_Date__c,
                                Expiration_Date__c,
                                Option_Base_Rent__c,
                                Option_Start_Date__c,
                                Option_End_Date__c,
                                Percentage_Rent__c,
                                Name from Deal__c where id = :dealid];
        else
            this.deal = new Deal__c();
        
        this.counter = 0;
        init();
        MyController = this;
    }
    
    public LeasingDealDetailController(ApexPages.standardController ctrl) {
        this.deal = (Deal__c) ctrl.getRecord();
        this.counter = 0;
        init();
        isEditMode = string.isNotEmpty(ApexPages.currentPage().getParameters().get('isedit'));
        MyController = this;       
    }
    
    public PageReference init() {
        // load deal and rent data
        loadDealRentData();
        
        // get sys admin profile id
        Id sysadminProfileId = ([select id from Profile where Name='System Administrator']).Id;
        this.isSysAdmin = (UserInfo.getProfileId() == sysadminProfileId);
        
        // if deal record is closed/won or lost/declined, only sys admin can edit calculator dates
        this.canEdit = (!isSysAdmin && ('Closed Won'.equals(this.deal.Deal_Stage__c) || 'Lost/Declined'.equals(this.deal.Deal_Stage__c))) ? false : true;
        return null;
    }
    
    public PageReference editMe() {
        isEditMode = true;
        return null;
    }
    
    public PageReference saveMe() {
        boolean isNew = false;
        try {
            if(this.deal.Id != null) {
                // update deal record
                update this.deal;
            }
            else {
                // insert deal record
                insert this.deal;
                isNew = true;
            }
            
            // insert Deal_Rent__c Rent child records
            // delete exiting records first
            list<Deal_Rent__c> delList = [select Id from Deal_Rent__c where Leasing_Deal__c = :this.deal.Id and RecordType.Name='Rent'];
            delete delList;
            if(rentDetails.size() > 0 || optionRentDetails.size() > 0) {
                list<Deal_Rent__c> drList = new list<Deal_Rent__c>();
                list<RentRow> masterList = new list<RentRow>(this.rentDetails);
            	masterList.addAll(this.optionRentDetails);
                for(RentRow rr : masterList) {
                    if(rr.record.Id == null || rr.record.Leasing_Deal__c == null)
                        rr.record.Leasing_Deal__c = this.deal.Id;
                    drList.add(rr.record.clone());
                }
                // then insert new records
                insert drList;
            }
            
            // insert Deal_Rent__c Rent Increase child records
            // delete existing records first
            delList = [select Id from Deal_Rent__c where Leasing_Deal__c = :this.deal.Id and RecordType.Name='Rent Increase'];
            delete delList;
            if(rentIncreaseDetails.size() > 0 || optionRentIncreaseDetails.size() > 0) {
            	list<Deal_Rent__c> drList = new list<Deal_Rent__c>();
            	list<RentRow> masterList = new list<RentRow>(this.rentIncreaseDetails);
            	masterList.addAll(this.optionRentIncreaseDetails);
                for(RentRow rr : masterList) {
                    if(rr.record.Id == null || rr.record.Leasing_Deal__c == null)
                        rr.record.Leasing_Deal__c = this.deal.Id;
                    drList.add(rr.record.clone());
                }
                // then insert new records
                insert drList;
            }
            isEditMode = false;
            loadDealRentData();
        }
        catch(Exception ex) {
            string msg = ex.getMessage();
            this.deal.addError(msg);
//          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Save Error: ' + msg));
        }
        
        return isNew ? new PageReference('/'+this.deal.Id) : null;
    }
    
    public PageReference cancelMe() {
        if(this.deal.Id != null) {
            isEditMode = false;
            //TODO - cancel if new deal record -???
            // reload the deal record
            loadDealRentData();
            return null;
        }
        else {
            // cancelled from NEW page
            return new PageReference(ApexPages.currentPage().getParameters().get('retURL'));
        }
    }
    
    public PageReference nothing() {
        return null;
    }
    
    private void computeRentTermUnit(boolean isOption) {
    	Date localStartDate, localEndDate;
    	integer localTermLengthInDays;
    	RENT_TERM_UNIT localRentTermUnit;
    	
    	if(isOption) {
	    	localStartDate = this.deal.Option_Start_Date__c;
	    	localEndDate = this.deal.Option_End_Date__c;
	    	this.optionTermLengthInDays = -1;
	    	this.optionRentTermUnit = null;
    	}
    	else {
    		localStartDate = this.deal.Commencement_Date__c;
	    	localEndDate = this.deal.Expiration_Date__c;
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
    
    // method returns false if validation okay
    private boolean validateDealDates() {
    	boolean retVal = true;
    	string msg = 'Please enter date ' + system.now().format('M/d/YYYY') + ' or later';
    	// only sys admin can enter old dates
    	if(!this.isSysAdmin && this.deal.Commencement_Date__c!=null && this.deal.Commencement_Date__c < System.Today()) {
    		this.deal.Commencement_Date__c.addError(msg);
    		retVal = false;
    	}
    	if(!this.isSysAdmin && this.deal.Expiration_Date__c!=null && this.deal.Expiration_Date__c < System.Today()) {
    		this.deal.Expiration_Date__c.addError(msg);
    		retVal = false;
    	}
    	
    	// option dates
    	if(!this.isSysAdmin && this.deal.Option_Start_Date__c!=null && this.deal.Option_Start_Date__c < System.Today()) {
    		this.deal.Option_Start_Date__c.addError(msg);
    		retVal = false;
    	}
    	if(!this.isSysAdmin && this.deal.Option_End_Date__c!=null && this.deal.Option_End_Date__c < System.Today()) {
    		this.deal.Option_End_Date__c.addError(msg);
    		retVal = false;
    	}
    	return retVal;
    }
    private boolean validateRentDates() {
    	boolean retVal = true;
    	string msg = 'Please enter date ' + system.now().format('M/d/YYYY') + ' or later';
    	// only sys admin can enter old dates
    	list<RentRow> masterList = new list<RentRow>(this.rentDetails);
        masterList.addAll(this.optionRentDetails);
    	for(RentRow rr : masterList) {
    		if(!this.isSysAdmin && rr.record.Start_Period__c!=null && rr.record.Start_Period__c < System.Today()) {
	    		rr.record.Start_Period__c.addError(msg);
	    		retVal = false;
	    	}
	    	if(!this.isSysAdmin && rr.record.End_Period__c!=null && rr.record.End_Period__c < System.Today()) {
	    		rr.record.End_Period__c.addError(msg);
	    		retVal = false;
	    	}
    	}
    	masterList = new list<RentRow>(this.rentIncreaseDetails);
        masterList.addAll(this.optionRentIncreaseDetails);
    	for(RentRow rr : masterList) {
	    	if(!this.isSysAdmin && rr.record.Start_Period__c!=null && rr.record.Start_Period__c < System.Today()) {
	    		rr.record.Start_Period__c.addError(msg);
	    		retVal = false;
	    	}
	    	if(!this.isSysAdmin && rr.record.End_Period__c!=null && rr.record.End_Period__c < System.Today()) {
	    		rr.record.End_Period__c.addError(msg);
	    		retVal = false;
	    	}
    	}
    	return retVal;
    }
    
    public PageReference computeRent() { return computeRent(false); }
    public PageReference computeOptionRent() { return computeRent(true); }
    private PageReference computeRent(boolean isOption) {
        //system.debug('in computeRent('+isOption+'), deal: '+this.deal);
        // validate dates
        boolean okay = validateDealDates() && validateRentDates();
    	if(!okay) return null;
    	
        // local variables
        RENT_TERM_UNIT localRentTermUnit;
        integer localTermLengthInDays;
        Date localStartDate, localEndDate;
        // blank out all rows and re-compute
        if(isOption) {
	        optionRentDetails = new list<RentRow>();
			computeRentTermUnit(true);
			// set local vars
			localRentTermUnit = optionRentTermUnit;
			localTermLengthInDays = optionTermLengthInDays;
			localStartDate = this.deal.Option_Start_Date__c;
			localEndDate = this.deal.Option_End_Date__c;
		}
		else {
			rentDetails = new list<RentRow>();
			computeRentTermUnit(false);
			// set local vars
			localRentTermUnit = rentTermUnit;
			localTermLengthInDays = termLengthInDays;
			localStartDate = this.deal.Commencement_Date__c;
			localEndDate = this.deal.Expiration_Date__c;
		}
        if(localRentTermUnit == null || localTermLengthInDays == null || localTermLengthInDays <= 0)
			return null;

        // fill per day map
        map<Date, decimal> perDayMap = this.fillPerDayMap(isOption);
          
        if(localRentTermUnit != RENT_TERM_UNIT.Year) {
        	// create single rent row
        	Deal_Rent__c dr = new Deal_Rent__c();
        	dr.RecordType = new RecordType(Name='Rent');
        	dr.Start_Period__c = localStartDate;
        	dr.End_Period__c = localEndDate; 
        	dr.Is_Option__c = isOption;
            dr.Annual_Rent_Amount__c = computeRentAmount(perDayMap, dr.Start_Period__c, dr.End_Period__c);
            // compute daily, weekly, and monthly amt rates for monthly column
            decimal perDayRate = computeRentAmount(perDayMap, dr.End_Period__c, dr.End_Period__c);	// get last day rent
       		//note: perDayRate is based on number of days in month
        	integer numDaysInLastMonth = Date.daysInMonth(dr.End_Period__c.year(), dr.End_Period__c.month());
	        dr.Unit_Periodly_Rent_Amount__c = localRentTermUnit==RENT_TERM_UNIT.Day ? perDayRate :
            									localRentTermUnit==RENT_TERM_UNIT.Week ? perDayRate*7 :
            									localRentTermUnit==RENT_TERM_UNIT.Month ? perDayRate*numDaysInLastMonth :
            									perDayRate;
        	if(isOption)
        		this.optionRentDetails.add(new RentRow(this.deal, dr, ++counter));
        	else
        		this.rentDetails.add(new RentRow(this.deal, dr, ++counter));
        }
        else {
        	// generate rows for initial lease term
        	boolean loopAgain = true;
        	Date startDt = localStartDate;
        	Date endDt = localEndDate;
	        while(loopAgain) {
	        	Date yearEndDt = startDt.addYears(1).addDays(-1);
	        	if(yearEndDt >= endDt) {
	        		yearEndDt = endDt;
	        		loopAgain = false;
	        	}
	        	Deal_Rent__c dr = new Deal_Rent__c();
	        	dr.RecordType = new RecordType(Name='Rent');
	        	dr.Start_Period__c = startDt;
	        	dr.End_Period__c = yearEndDt; 
	        	dr.Is_Option__c = IsOption;
	            dr.Annual_Rent_Amount__c = computeRentAmount(perDayMap, dr.Start_Period__c, dr.End_Period__c);
	            // compute monthly rate column value
	            // if full year, use annual amount / 12
	            // if not full year, then compute monthly rate based on last day rate times number of days in month
        		decimal perDayRate = computeRentAmount(perDayMap, dr.End_Period__c, dr.End_Period__c);
        		//note: perDayRate is based on number of days in month
        		integer numDaysInLastMonth = Date.daysInMonth(dr.End_Period__c.year(), dr.End_Period__c.month());
	            //debugstring += '\n1 - last day='+dr.End_Period__c+', last day rate='+perDayRate+', num days in mon='+numDaysInLastMonth;
	        	dr.Unit_Periodly_Rent_Amount__c = ( (dr.Start_Period__c.daysBetween(dr.End_Period__c)+1) >= 365 ? dr.Annual_Rent_Amount__c/12 : perDayRate*numDaysInLastMonth );		
	        	if(isOption)
	        		this.optionRentDetails.add(new RentRow(this.deal, dr, ++counter));
	        	else
	        		this.rentDetails.add(new RentRow(this.deal, dr, ++counter));
	        	
	        	// set variables for next loop
	        	startDt = yearEndDt + 1;
	        }
        }
        
        return null;
    }
    // debug string test - remove this
    private string debugstring = '';
    public string getdebugstring() { return debugstring; }
    
    // methods re-computes the rent rows without re-creating them.  i.e. if increase types changed
    public integer reComputeRentStartIndex { get; set; }
    public integer reComputeOptionRentStartIndex { get; set; }
    public PageReference reComputeRent() { return reComputeRent(false); }
    public PageReference reComputeOptionRent() { return reComputeRent(true); }
    private PageReference reComputeRent(boolean isOption) {
    	integer localReComputeRentStartIndex = isOption ? reComputeOptionRentStartIndex : reComputeRentStartIndex;
        //system.debug('in reComputeRent('+isOption+'), startIndex: '+localReComputeRentStartIndex);
        // validate rent dates
        boolean okay = validateRentDates();
    	if(!okay) return null;
    	
    	list<RentRow> localRentDetails = isOption ? this.optionRentDetails  : this.rentDetails;
        map<Date, decimal> perDayMap = this.fillPerDayMap(isOption);
    	
        if(localReComputeRentStartIndex == -1) {
        	// re-compute and apply inc type
	        for(RentRow rr : localRentDetails) {
	        	rr.record.Annual_Rent_Amount__c = computeRentAmount(perDayMap, rr.record.Start_Period__c, rr.record.End_Period__c);
				integer periodLen = rr.record.Start_Period__c.daysBetween(rr.record.End_Period__c) + 1;
        		decimal perDayRate = computeRentAmount(perDayMap, rr.record.End_Period__c, rr.record.End_Period__c);	// get last day rent           
        		//note: perDayRate is based on number of days in month
        		integer numDaysInLastMonth = Date.daysInMonth(rr.record.End_Period__c.year(), rr.record.End_Period__c.month());
	            //debugstring += '\n2 - last day='+rr.record.End_Period__c+', last day rate='+perDayRate+', num days in mon='+numDaysInLastMonth;
        		rr.record.Unit_Periodly_Rent_Amount__c = rentTermUnit==RENT_TERM_UNIT.Day ? perDayRate :
	            									rentTermUnit==RENT_TERM_UNIT.Week ? perDayRate*7 :
	            									rentTermUnit==RENT_TERM_UNIT.Month ? perDayRate*numDaysInLastMonth :
	            									( (rr.record.Start_Period__c.daysBetween(rr.record.End_Period__c)+1) >= 365 ? rr.record.Annual_Rent_Amount__c/12 : perDayRate*numDaysInLastMonth );
	        }
        }
        else {
        	// re-compute unit periodly rent amount for 1 index row
        	RentRow rr = findRentRow(localRentDetails, localReComputeRentStartIndex);
        	if(rr != null && rr.record.Annual_Rent_Amount__c != null &&	rr.record.Start_Period__c != null && rr.record.End_Period__c != null) {
        		integer periodLen = rr.record.Start_Period__c.daysBetween(rr.record.End_Period__c) + 1;
        		decimal perDayRate = computeRentAmount(perDayMap, rr.record.End_Period__c, rr.record.End_Period__c);	// get last day rent 
        		//note: perDayRate is based on number of days in month
        		integer numDaysInLastMonth = Date.daysInMonth(rr.record.End_Period__c.year(), rr.record.End_Period__c.month());
        		rr.record.Unit_Periodly_Rent_Amount__c = rentTermUnit==RENT_TERM_UNIT.Day ? perDayRate :
	            									rentTermUnit==RENT_TERM_UNIT.Week ? perDayRate*7 :
	            									rentTermUnit==RENT_TERM_UNIT.Month ? perDayRate*numDaysInLastMonth :
	            									( (rr.record.Start_Period__c.daysBetween(rr.record.End_Period__c)+1) >= 365 ? rr.record.Annual_Rent_Amount__c/12 : perDayRate*numDaysInLastMonth );
        	}
        }
        return null;
    }

	// finds and returns RentRow on indx value
	private RentRow findRentRow(list<RentRow> rentRows, integer indx) {
		RentRow ret = null;
		for(RentRow r : rentRows)
			if(r.indx == indx)
				ret = r;
		return ret;
	}

    
    // computes per day rate into map ... compounding the increase types
    // map includes dates up to option end date, if available, else up to expiration date
    private map<Date, decimal> fillPerDayMap(boolean isOption) {
   		//system.debug('calling fillPerDayMap('+isOption+')');
   		// clear out map
    	map<Date, decimal> perDayMap = new map<Date, decimal>();
    	
    	// local variables
    	Date localStartDate, localEndDate;
    	integer localTermLengthInDays;
    	decimal localBaseRent;
    	RENT_TERM_UNIT localRentTermUnit;
    	list<RentRow> localRentIncreaseDetails;
    	
    	if(isOption) {
	    	localStartDate = this.deal.Option_Start_Date__c;
	    	localEndDate = this.deal.Option_End_Date__c;
	    	localTermLengthInDays = this.optionTermLengthInDays;
	    	localBaseRent = this.deal.Option_Base_Rent__c;
	    	localRentTermUnit = this.optionRentTermUnit;
	    	localRentIncreaseDetails = this.optionRentIncreaseDetails;
    	}
    	else {
    		localStartDate = this.deal.Commencement_Date__c;
	    	localEndDate = this.deal.Expiration_Date__c;
	    	localTermLengthInDays = this.termLengthInDays;
	    	localBaseRent = this.deal.Base_Rent__c;
	    	localRentTermUnit = this.rentTermUnit;
	    	localRentIncreaseDetails = this.rentIncreaseDetails;
    	}

    	// cannot process without these fields
   		if(localStartDate==null || localBaseRent==null)
   			return perDayMap;
   			
    	// re-sort increase types into following order:  Dollar increase, $/psf Increase, % Increase
    	list<Deal_Rent__c> sortedIncTypes = new list<Deal_Rent__c>();
    	list<string> sortorder = new list<string> { 'Dollar Increase', '$/psf Increase', '% Increase' };
    	for(string ord : sortorder)
	    	for(RentRow rr : localRentIncreaseDetails)	// make sure row is valid, i.e. all fields populated
    			if(rr.record.Base_Rent_Increase_Type__c == ord &&
    				rr.record.Start_Period__c != null &&
    				rr.record.End_Period__c != null &&
    				rr.record.Base_Rent_Increase_Amount__c != null)
    				sortedIncTypes.add(rr.record);

    	// convert increase types into map of <date, inc type>
    	map<Date, IncType[]> incTypeMap = new map<Date, IncType[]>();
		for(Deal_Rent__c dr : sortedIncTypes) {

			INC_TYPE iType = sortorder[0].equals(dr.Base_Rent_Increase_Type__c) ? INC_TYPE.Dollar :
								sortorder[1].equals(dr.Base_Rent_Increase_Type__c) ? INC_TYPE.Psf :
								INC_TYPE.Percent;
			integer incFreqAmt = dr.Base_Rent_Increase_Frequency_Amount__c!=null ? dr.Base_Rent_Increase_Frequency_Amount__c.intValue() : 0;	// 0 equals 1-time apply
			string incFreqUnit = dr.Base_Rent_Increase_Frequency_Unit__c!=null ? dr.Base_Rent_Increase_Frequency_Unit__c : 'Year'; // i.e. Day, Week, Month, Year	
			decimal iAmt = (dr.Base_Rent_Increase_Amount__c!=null && dr.Base_Rent_Increase_Amount__c!=0) ? dr.Base_Rent_Increase_Amount__c : 0.0;
			// if inc type == percent, divide by 100, else divide into daily amt
			iAmt = (iType == INC_TYPE.Percent) ? iAmt / 100.0 : iAmt / (incFreqUnit!='Day'?360.0:365.0);		// yearly, monthly, weekly = 12 months x 30 days, else daily = 365
			
			integer dayCounter = 0;
			// loop thru all days in increase type and apply inc to dates at specified freq amt*units
			for(integer i=0; i<dr.Start_Period__c.daysBetween(dr.End_Period__c)+1; i++) {

				Date cDate = dr.Start_Period__c + i;
				if(dayCounter == 0) {
					list<IncType> iList = (incTypeMap.containsKey(cDate) ? incTypeMap.get(cDate) : new list<IncType>());
					//system.debug('cDate='+cDate+', iAmt='+iAmt+', iType='+iType);
					iList.add(new IncType(iAmt, iType, incFreqUnit));
					incTypeMap.put(cDate, iList);
					// reset dayCounter for next inc day
					dayCounter = (incFreqUnit=='Year' ? cDate.daysbetween(cDate.addYears(incFreqAmt)) :
									incFreqUnit=='Month' ? cDate.daysbetween(cDate.addMonths(incFreqAmt)) :
									incFreqUnit=='Week' ? incFreqAmt * 7 : incFreqAmt);
				}
				dayCounter--;
			}
		}
    		
    	// compute as monthly (divide by 12) first, then divide by number of days in month (30)
    	decimal perDayRent = localBaseRent / 360.0;	// initial base rent per day
    	decimal estFootage = (this.deal.Estimated_Square_Footage__c!=null ? this.deal.Estimated_Square_Footage__c : 0.0); //note - no conversion into meters
    	integer daysInMonthCounter = 0;
    	decimal daysOffsetMultiplier;
    	decimal dailyIncAmt = 0;
    	
    	// loop thru entire term for each day
    	for(integer i=0; i<localTermLengthInDays; i++) {
    		Date currDay = localStartDate + i;
	
	    	// set and use dayscounter and compute day offset multiplier here
    		if(daysInMonthCounter == 0) {
    			daysInMonthCounter = Date.daysInMonth(currDay.year(), currDay.month());
    			daysOffsetMultiplier = Decimal.valueOf(30) / Decimal.valueOf(daysInMonthCounter); // days offset multiplier, i.e. if daysinmonths equals 28, 29, 31
    			//system.debug('currDay='+currDay+', daysInMonthCounter='+daysInMonthCounter+', daysOffsetMultiplier=' + daysOffsetMultiplier);
    		}
   			daysInMonthCounter--;
    		
    		// check increase type map to apply increases
    		if(incTypeMap.containsKey(currDay)) {
    			for(IncType it : incTypeMap.get(currDay)) {
					decimal incAmt = (it.typ==INC_TYPE.Percent ? perDayRent*it.amt :
		                                it.typ==INC_TYPE.Psf ? estFootage*it.amt :
		                                it.typ==INC_TYPE.Dollar && it.frequnit!='Day' ? it.amt : 0.0);
		            if(it.typ==INC_TYPE.Dollar && it.frequnit=='Day')
		            	dailyIncAmt += it.amt;			// note daily dollar works differently
		            //system.debug('applying increase...currDay['+currDay+'], incAmt['+incAmt+'], daysOffsetMultiplier['+daysOffsetMultiplier+']');
		            perDayRent += incAmt; 
    			}
    		}
    		// add day item into map, computing with daysOffsetMultiplier
    		//system.debug('currDay:'+currDay+', preDayRent:'+perDayRent+', daysOffsetMultiplier:'+daysOffsetMultiplier+', dailyIncAmt:'+dailyIncAmt);
    		perDayMap.put(currDay, perDayRent * daysOffsetMultiplier + dailyIncAmt);
    	}
    	
    	return perDayMap;
    }
    
    // computes rent annual amount by summing up all per day rates with start and end dates
    private decimal computeRentAmount(map<Date, decimal> perDayMap, Date startDt, Date endDt) {
    	//system.debug('computeRentAmount for: start[' + startDt + '], end[' + endDt + ']');
    	integer periodLength = startDt.daysBetween(endDt) + 1;
    	
    	// loop thru perDayMap and sum up all per day rates from startDt and endDt
    	decimal rentAmount = Decimal.valueOf(0);
    	for(integer i=0; i<periodLength; i++) {
    		Date currDay = startDt + i;
    		rentAmount += perDayMap.containsKey(currDay) ? perDayMap.get(currDay) : 0.0;
    	}

    	//system.debug('rentAmount = ' + rentAmount);
    	return rentAmount.setScale(2);
    }
    
    // loads the deal record and term rent and option term rent data into array list
    private void loadDealRentData() {
        this.rentDetails = new list<RentRow>();
        this.rentIncreaseDetails = new list<RentRow>();
        this.optionRentDetails = new list<RentRow>();
        this.optionRentIncreaseDetails = new list<RentRow>();
        if(this.deal != null && this.deal.Id != null) {
            Id dealId = this.deal.Id;
            //system.debug('in loaddealrentdata, id is ' + dealId);
            string query = 'select ' + generateListOfDealFields() + ' From Deal__c where Id=:dealId';
            this.deal = database.query(query); 
            //system.debug('deal is ' + deal);
        	
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
                                   where Leasing_Deal__c = :this.deal.Id 
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
            //system.debug('rent list is ' + rentDetails);            
            //system.debug('rent increase list is ' + rentIncreaseDetails);
            //system.debug('option rent list is ' + optionRentDetails);            
            //system.debug('option rent increase list is ' + optionRentIncreaseDetails);
            
            computeRentTermUnit(false);
            computeRentTermUnit(true);
        }
        else {
            // new deal
            //system.debug('new deal condition...setting edit mode to true');
            this.deal.OwnerId = UserInfo.getUserId();
            this.isEditMode = true;
            // see if tenant__c is passed via url parameter
            if(string.isnotempty(ApexPages.currentPage().getParameters().get('tenant__c')))
                this.deal.Tenant__c = ApexPages.currentPage().getParameters().get('tenant__c');
        }
    }
    
    private string generateListOfDealFields() {
        return string.join(new list<string>(Schema.SObjectType.Deal__c.fields.getMap().keySet()), ',');
    }
    
    // methods for adding new rows to rent tables
    public PageReference addNewRentRow() {
    	this.rentDetails.add(createNewRentRow(false, false));
    	return null;
    }
    public PageReference addNewRentIncreaseRow() {
    	this.rentIncreaseDetails.add(createNewRentRow(false, true));
    	return null;
    }
    public PageReference addNewOptionRentRow() {
    	this.optionRentDetails.add(createNewRentRow(true, false));
    	return null;
    }
    public PageReference addNewOptionRentIncreaseRow() {
    	this.optionRentIncreaseDetails.add(createNewRentRow(true, true));
    	return null;
    }
    private RentRow createNewRentRow(boolean isOption, boolean isRentIncrease) {
    	return new RentRow(this.deal, new Deal_Rent__c(leasing_deal__c=this.deal.Id, Is_Option__c=isOption, RecordType=new RecordType(Name=(isRentIncrease ? 'Rent Increase' : 'Rent'))), ++counter);
    }
    
    
    public integer trashRentIndx { get; set; }
    public integer trashRentIncreaseIndx { get; set; }
    public integer trashOptionRentIndx { get; set; }
    public integer trashOptionRentIncreaseIndx { get; set; }
    public PageReference trashRentRow() { return trashRentRow(this.rentDetails, this.trashRentIndx); }
    public PageReference trashRentIncreaseRow() { return trashRentRow(this.rentIncreaseDetails, this.trashRentIncreaseIndx); }
    public PageReference trashOptionRentRow() { return trashRentRow(this.optionRentDetails, this.trashOptionRentIndx); }
    public PageReference trashOptionRentIncreaseRow() { return trashRentRow(this.optionRentIncreaseDetails, this.trashOptionRentIncreaseIndx); }
    private PageReference trashRentRow(list<RentRow> rrList, integer trashIndx) {
    	//system.debug('in trash rent row function.  trashindx is: ');
    	//system.debug(trashIndx);
    	integer del=-1;
    	for(integer i=0; i<rrList.size(); i++)
    		if(rrList[i].indx == trashIndx)
    			del=i;
    	//system.debug('DELETE index: ' + del);
    	if(del!=-1)
	    	rrList.remove(del);
    	return null;
    }
    
    //
    // Wrapper class for inc type
    private class IncType {
    	public decimal amt { get; private set; }
    	public INC_TYPE typ { get; private set; } 
    	public string frequnit { get; private set; }
    	public IncType(decimal amt, INC_TYPE typ, string frequnit) {
    		this.amt = amt;
    		this.typ = typ;
    		this.frequnit = frequnit;
    	}
    }
    
    //
    // Wrapper class for Deal_Rent__c object
    public class RentRow {
        private Deal__c deal { get; private set; }
        public Deal_Rent__c record { get; private set; }
        public integer indx { get; private set; }
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
        public decimal naturalBreak { get 
        { 
            decimal returnVal = 0.0;
            if(record.Annual_Rent_Amount__c != null &&  deal.Percentage_Rent__c != null &&  deal.Percentage_Rent__c != 0)
            {
                returnVal = (record.Annual_Rent_Amount__c / deal.Percentage_Rent__c * 100).setScale(2);
            }
            return returnVal;
        }}
        public RentRow(Deal__c d, Deal_Rent__c r, integer i) {
            deal = d;
            record = r;
            indx = i;
        }
    }
    

    //
    // test methods
    @isTest
    static void test_ShortAndLongTerm() {
        
        // create leasing deal
        Deal__c deal = new Deal__c(Name='test deal', RecordType=new Recordtype(Name='Leasing Deal'));
        insert deal;
        
        Test.startTest();
        
        PageReference testPageReference = Page.LeasingDealDetailPage;
        Test.setCurrentPage(testPageReference);
        LeasingDealDetailController controller = new LeasingDealDetailController();
        controller = new LeasingDealDetailController(new ApexPages.StandardController(deal));
        controller.init(); 
    
        // test actions
        controller.editMe();
        system.assertEquals(true, controller.isEditMode, 'Error: Edit method did not set isEditMode to true.'); 

        // test short term
        Date startDt = Date.newInstance(System.today().year(), 9, 1);
        Date endDt = Date.newInstance(System.today().year(), 9, 15);
        controller.deal.Base_Rent__c                    = 10000;
        controller.deal.Commencement_Date__c            = startDt;
        controller.deal.Expiration_Date__c				= endDt;
        controller.deal.Estimated_Square_Footage__c     = 5000;
                
        // compute the rent table
        controller.computeRent();
        system.assertEquals(1, controller.rentDetails.size(), 'Error: Rent computer did not generate correct number of rent rows.');

        // save all changes
        controller.saveMe();
        list<Deal_Rent__c> dealRents = [select Id, Start_Period__c, End_Period__c, Annual_Rent_Amount__c from Deal_Rent__c where Leasing_Deal__c = :deal.Id order by Start_Period__c asc];
        system.assertEquals(1, dealRents.size(), 'Error: Save action did not save correct number of deal rent records.');
        system.assertEquals(startDt, dealRents[0].Start_Period__c, 'Error: Start period date is incorrect.');
        system.assertEquals(endDt, dealRents[0].End_Period__c, 'Error: End period date is incorrect.');
    
    	// test long term - change expiration date to span into next year
    	Date endDt2 = Date.newInstance(System.today().year()+3, 6, 30);
        controller.deal.Expiration_Date__c				= endDt2;
        controller.computeRent();
        system.assertEquals(3, controller.rentDetails.size(), 'Error: Rent computer did not generate correct number of rent rows.');
        
        // save all changes
        controller.saveMe();
        dealRents = [select Id, Start_Period__c, End_Period__c, Annual_Rent_Amount__c from Deal_Rent__c where Leasing_Deal__c = :deal.Id order by Start_Period__c asc];
        system.assertEquals(3, dealRents.size(), 'Error: Save action did not save correct number of deal rent records.');
        system.assertEquals(startDt, dealRents[0].Start_Period__c, 'Error: 1st row Start period date is incorrect.');
        system.assertEquals(endDt2, dealRents[2].End_Period__c, 'Error: last row End period date is incorrect.');
        
    	// test add row and trash rows
    	controller.addNewRentRow();
        system.assertEquals(4, controller.rentDetails.size(), 'Error: Rent computer did not add a new rent row.');
    	controller.rentDetails[3].record.Start_Period__c = system.today() + 100;
    	controller.rentDetails[3].record.End_Period__c = system.today() + 150;
    	controller.rentDetails[3].record.Annual_Rent_Amount__c = 40000;
    	controller.reComputeRentStartIndex = controller.rentDetails[3].indx;
    	controller.reComputeRent();
    	controller.trashRentIndx = controller.rentDetails[3].indx;
    	controller.trashRentRow();
        system.assertEquals(3, controller.rentDetails.size(), 'Error: Rent computer did not trash rent row.');
    	
        // other actions
        decimal testdec = controller.rentDetails[0].psfAmt;
        testdec = controller.rentDetails[0].naturalBreak;
        controller.cancelMe(); 
        controller.nothing(); 
        
        Test.stopTest();
    }
    
    @isTest
    static void test_ShortAndLongOptionTerm() {
        
        // create leasing deal
        Deal__c deal = new Deal__c(Name='test deal', RecordType=new Recordtype(Name='Leasing Deal'));
        insert deal;
        
        Test.startTest();
        
        PageReference testPageReference = Page.LeasingDealDetailPage;
        Test.setCurrentPage(testPageReference);
        LeasingDealDetailController controller = new LeasingDealDetailController();
        controller = new LeasingDealDetailController(new ApexPages.StandardController(deal));
        controller.init(); 
    
        // test actions
        controller.editMe();
        system.assertEquals(true, controller.isEditMode, 'Error: Edit method did not set isEditMode to true.'); 

        // test short term
        Date startDt = Date.newInstance(System.today().year(), 9, 1);
        Date endDt = Date.newInstance(System.today().year(), 9, 15);
        controller.deal.Option_Base_Rent__c				= 10000;
        controller.deal.Option_Start_Date__c            = startDt;
        controller.deal.Option_End_Date__c				= endDt;
        controller.deal.Estimated_Square_Footage__c     = 5000;
                
        // compute the rent table
        controller.computeOptionRent();
        system.assertEquals(1, controller.optionRentDetails.size(), 'Error: Rent computer did not generate correct number of option rent rows.');

        // save all changes
        controller.saveMe();
        list<Deal_Rent__c> dealRents = [select Id, Start_Period__c, End_Period__c, Annual_Rent_Amount__c from Deal_Rent__c where Leasing_Deal__c = :deal.Id and Is_Option__c=true order by Start_Period__c asc];
        system.assertEquals(1, dealRents.size(), 'Error: Save action did not save correct number of deal option rent records.');
        system.assertEquals(startDt, dealRents[0].Start_Period__c, 'Error: Start period date is incorrect.');
        system.assertEquals(endDt, dealRents[0].End_Period__c, 'Error: End period date is incorrect.');
    
    	// test long term - change expiration date to span into next year
    	Date endDt2 = Date.newInstance(System.today().year()+3, 6, 30);
        controller.deal.Option_End_Date__c				= endDt2;
        controller.computeOptionRent();
        system.assertEquals(3, controller.optionRentDetails.size(), 'Error: Rent computer did not generate correct number of option rent rows.');
        
        // save all changes
        controller.saveMe();
        dealRents = [select Id, Start_Period__c, End_Period__c, Annual_Rent_Amount__c from Deal_Rent__c where Leasing_Deal__c = :deal.Id and Is_Option__c=true order by Start_Period__c asc];
        system.assertEquals(3, dealRents.size(), 'Error: Save action did not save correct number of deal option rent records.');
        system.assertEquals(startDt, dealRents[0].Start_Period__c, 'Error: 1st row Start period date is incorrect.');
        system.assertEquals(endDt2, dealRents[2].End_Period__c, 'Error: last row End period date is incorrect.');
        
    	// test add row and trash option rows
    	controller.addNewOptionRentRow();
        system.assertEquals(4, controller.optionRentDetails.size(), 'Error: Rent computer did not add a new option rent row.');
    	controller.optionRentDetails[3].record.Start_Period__c = system.today() + 100;
    	controller.optionRentDetails[3].record.End_Period__c = system.today() + 150;
    	controller.optionRentDetails[3].record.Annual_Rent_Amount__c = 40000;
    	controller.reComputeOptionRentStartIndex = controller.optionRentDetails[3].indx;
    	controller.reComputeOptionRent();
    	controller.trashOptionRentIndx = controller.optionRentDetails[3].indx;
    	controller.trashOptionRentRow();
        system.assertEquals(3, controller.optionRentDetails.size(), 'Error: Rent computer did not trash option rent row.');
    	
        // other actions
        decimal testdec = controller.optionRentDetails[0].psfAmt;
        testdec = controller.optionRentDetails[0].naturalBreak;
        controller.cancelMe(); 
        controller.nothing(); 
        
        Test.stopTest();
    }
    
    
    @isTest
    static void test_IncreaseTypes() {
        // create leasing deal
        Deal__c deal = new Deal__c(Name='test deal', RecordType=new Recordtype(Name='Leasing Deal'));
        insert deal;
        
        Test.startTest();
        
        PageReference testPageReference = Page.LeasingDealDetailPage;
        Test.setCurrentPage(testPageReference);
        LeasingDealDetailController controller = new LeasingDealDetailController();
        controller = new LeasingDealDetailController(new ApexPages.StandardController(deal));
        controller.init(); 
    
        // test actions
        controller.editMe();
        system.assertEquals(true, controller.isEditMode, 'Error: Edit method did not set isEditMode to true.'); 

        // add long term lease info
        Date startDt = Date.newInstance(System.today().year(), 9, 1);
        Date endDt = Date.newInstance(System.today().year()+4, 8, 31);
        controller.deal.Base_Rent__c                    = 10000;
        controller.deal.Commencement_Date__c            = startDt;
        controller.deal.Expiration_Date__c				= endDt;
        controller.deal.Estimated_Square_Footage__c     = 5000;
                
        // compute the rent table
        controller.computeRent();
        system.assertEquals(4, controller.rentDetails.size(), 'Error: Rent computer did not generate correct number of rent rows.');

		// add inc types
		controller.addNewRentIncreaseRow();
        system.assertEquals(1, controller.rentIncreaseDetails.size(), 'Error: Rent computer did not add new increase type rows.');
		controller.rentIncreaseDetails[0].record.Start_Period__c = startDt;
		controller.rentIncreaseDetails[0].record.End_Period__c = endDt;
		controller.rentIncreaseDetails[0].record.Base_Rent_Increase_Type__c = '% Increase';
		controller.rentIncreaseDetails[0].record.Base_Rent_Increase_Amount__c = 1000;
		controller.rentIncreaseDetails[0].record.Base_Rent_Increase_Frequency_Amount__c = 1;
		controller.rentIncreaseDetails[0].record.Base_Rent_Increase_Frequency_Unit__c = 'Year';
		controller.reComputeRentStartIndex = -1;
		controller.reComputeRent();
		
        // save all changes
        controller.saveMe();
        list<Deal_Rent__c> dealRents = [select Id, Start_Period__c, End_Period__c, Annual_Rent_Amount__c from Deal_Rent__c where Leasing_Deal__c = :deal.Id and RecordType.Name='Rent' order by Start_Period__c asc];
        system.assertEquals(4, dealRents.size(), 'Error: Save action did not save correct number of deal rent records.');
        
        list<Deal_Rent__c> dealRentsInc = [select Id, Start_Period__c, End_Period__c from Deal_Rent__c where Leasing_Deal__c = :deal.Id and RecordType.Name='Rent Increase' order by Start_Period__c asc];
        system.assertEquals(1, dealRentsInc.size(), 'Error: Save action did not save correct number of deal rent increase type records.');
        
        // trash
        controller.trashRentIncreaseIndx = controller.rentIncreaseDetails[0].indx;
    	controller.trashRentIncreaseRow();
        system.assertEquals(0, controller.rentIncreaseDetails.size(), 'Error: Rent computer did not trash rent increase row.');
        
        Test.stopTest();
    }
    
    @isTest
    static void test_OptionIncreaseTypes() {
        // create leasing deal
        Deal__c deal = new Deal__c(Name='test deal', RecordType=new Recordtype(Name='Leasing Deal'));
        insert deal;
        
        Test.startTest();
        
        PageReference testPageReference = Page.LeasingDealDetailPage;
        Test.setCurrentPage(testPageReference);
        LeasingDealDetailController controller = new LeasingDealDetailController();
        controller = new LeasingDealDetailController(new ApexPages.StandardController(deal));
        controller.init(); 
    
        // test actions
        controller.editMe();
        system.assertEquals(true, controller.isEditMode, 'Error: Edit method did not set isEditMode to true.'); 

        // add long option term lease info
        Date startDt = Date.newInstance(System.today().year(), 9, 1);
        Date endDt = Date.newInstance(System.today().year()+4, 8, 31);
        controller.deal.Option_Base_Rent__c				= 10000;
        controller.deal.Option_Start_Date__c            = startDt;
        controller.deal.Option_End_Date__c				= endDt;
        controller.deal.Estimated_Square_Footage__c     = 5000;
                
        // compute the rent table
        controller.computeOptionRent();
        system.assertEquals(4, controller.optionRentDetails.size(), 'Error: Rent computer did not generate correct number of option rent rows.');

		// add inc types
		controller.addNewOptionRentIncreaseRow();
        system.assertEquals(1, controller.optionRentIncreaseDetails.size(), 'Error: Rent computer did not add new option increase type rows.');
		controller.optionRentIncreaseDetails[0].record.Start_Period__c = startDt;
		controller.optionRentIncreaseDetails[0].record.End_Period__c = endDt;
		controller.optionRentIncreaseDetails[0].record.Base_Rent_Increase_Type__c = '% Increase';
		controller.optionRentIncreaseDetails[0].record.Base_Rent_Increase_Amount__c = 1000;
		controller.optionRentIncreaseDetails[0].record.Base_Rent_Increase_Frequency_Amount__c = 1;
		controller.optionRentIncreaseDetails[0].record.Base_Rent_Increase_Frequency_Unit__c = 'Year';
		controller.reComputeOptionRentStartIndex = -1;
		controller.reComputeOptionRent();
		
        // save all changes
        controller.saveMe();
        list<Deal_Rent__c> dealRents = [select Id, Start_Period__c, End_Period__c, Annual_Rent_Amount__c from Deal_Rent__c where Leasing_Deal__c = :deal.Id and RecordType.Name='Rent' and Is_Option__c=true order by Start_Period__c asc];
        system.assertEquals(4, dealRents.size(), 'Error: Save action did not save correct number of deal option rent records.');
        
        list<Deal_Rent__c> dealRentsInc = [select Id, Start_Period__c, End_Period__c from Deal_Rent__c where Leasing_Deal__c = :deal.Id and RecordType.Name='Rent Increase' and Is_Option__c=true order by Start_Period__c asc];
        system.assertEquals(1, dealRentsInc.size(), 'Error: Save action did not save correct number of deal option rent increase type records.');
        
        // trash
        controller.trashOptionRentIncreaseIndx = controller.optionRentIncreaseDetails[0].indx;
    	controller.trashOptionRentIncreaseRow();
        system.assertEquals(0, controller.optionRentIncreaseDetails.size(), 'Error: Rent computer did not trash option rent increase row.');
        
        Test.stopTest();
    }
    
    /* TODO
    @isTest
    static void test_DateValidations() {
    }
    */
}