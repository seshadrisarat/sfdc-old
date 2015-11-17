/** 
    * \arg ClassName             : SL_LoanCurrentVolumeController
    * \arg JIRA Ticket           : RA-4
    * \arg CreatedOn             : 19/06/2015
    * \arg LastModifiedOn        : 25/06/2015
    * \arg CreatededBy           : Shailendra Singh 
    * \arg ModifiedBy            : Pankaj Ganwani 
    * \arg Description           : This is a class for Loan_HistoricalVolume component which Fetch records for 
    								'Current Volume' table chart.                     
**/
public with sharing class SL_LoanCurrentVolumeController 
{
	/*Start variables*/
	public Map<String,Integer> mapQuarterToCount		{	get;set;	} //Map Quarter to Loan Count
	public Map<String,Double> mapQuarterToCommitment	{	get;set;	} //Map Quarter to Loan Commitment
	public Integer intYTDCount							{	get;set;	} // YTD count
	public Double dblYTDCommitment						{	get;set;	} // YTD Commitment 
    /*End variables*/
    
     /* start constructor */
    public SL_LoanCurrentVolumeController()
    {
        initialization();
    }
    /* End constructor */
    
    /*!
        * MethodName  : initialization
        * param       : NA
        * Description : This method will initialize variables.
	*/
    public void initialization()
    {
    	mapQuarterToCommitment = new Map<String,Double>{'PYQ1' => 0.00,
    													'PYQ2' => 0.00,
    													'PYQ3' => 0.00,
    													'PYQ4' => 0.00,
    													'CYQ1' => 0.00,
    													'CYQ2' => 0.00,
    													'CYQ3' => 0.00,
    													'CYQ4' => 0.00};
    	mapQuarterToCount = new Map<String,Integer>{'PYQ1' => 0,
													'PYQ2' => 0,
													'PYQ3' => 0,
													'PYQ4' => 0,
													'CYQ1' => 0,
													'CYQ2' => 0,
													'CYQ3' => 0,
													'CYQ4' => 0};
    	intYTDCount = 0;
    	dblYTDCommitment = 0.00;
        getCurrentVolumeRecords();
    }
    /* End */
    
     /*!
        * MethodName  : getCurrentVolumeRecords
        * param       : NA
        * Description : This method will fetch records to display in 'Current Volume' table chart.
	*/
	public void getCurrentVolumeRecords()
	{	
		/* start variable */
		String strQuarter = ''; // String for distinguish Loan in quarters
		Set<String> setLoanNumber = new Set<String>(); // set for Loan number
		/* End variable */		
		
		for(Loan__C objLoan : [Select Loan_Number__c,Total_Commitment__c,Loan_Stage__c,Closing_Date__c From Loan__c Where Loan_Stage__c In('Paid Off', 'REO','Funded') AND Closing_Date__c!= null])
		{
			strQuarter = objLoan.Closing_Date__c.year()  < date.today().year() ? objLoan.Closing_Date__c.year()  == date.today().year() - 1 ? 'PY'  : '' :objLoan.Closing_Date__c.year()  == date.today().year() ? 'CY' : '';
			strQuarter += objLoan.Closing_Date__c.month() <= 3 ? 'Q1':
						  objLoan.Closing_Date__c.month() <=6 ? 'Q2' :
						  objLoan.Closing_Date__c.month() <=9 ? 'Q3' :'Q4';
			
			// For Count
			if(!mapQuarterToCount.containsKey(strQuarter) && !setLoanNumber.contains(objLoan.Loan_Number__c)) 
				mapQuarterToCount.put(strQuarter,1);
			else if(mapQuarterToCount.containsKey(strQuarter) && !setLoanNumber.contains(objLoan.Loan_Number__c))
				mapQuarterToCount.put(strQuarter,mapQuarterToCount.get(strQuarter) + 1);
			else
				mapQuarterToCount.put(strQuarter,mapQuarterToCount.get(strQuarter));
			
			// For Commitment
			if(!mapQuarterToCommitment.containsKey(strQuarter))
				mapQuarterToCommitment.put(strQuarter,objLoan.Total_Commitment__c);
			else
				mapQuarterToCommitment.put(strQuarter,mapQuarterToCommitment.get(strQuarter) + objLoan.Total_Commitment__c);
				
			// For YTD Count
			if(objLoan.Closing_Date__c.year() == date.Today().year() && objLoan.Closing_Date__c <= date.Today())
			{
				if(!setLoanNumber.contains(objLoan.Loan_Number__c))
					intYTDCount++;
				dblYTDCommitment += objLoan.Total_Commitment__c; 
			}
			setLoanNumber.add(objLoan.Loan_Number__c);	
		}// End for
	}
	/* End getCurrentVolumeRecords */
}