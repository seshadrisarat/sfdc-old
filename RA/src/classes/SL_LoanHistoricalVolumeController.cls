/** 
    * \arg ClassName             : SL_LoanHistoricalVolumeController
    * \arg JIRA Ticket           : RA-4
    * \arg CreatedOn             : 19/06/2015
    * \arg LastModifiedOn        : 23/06/2015
    * \arg CreatededBy           : Shailendra Singh 
    * \arg ModifiedBy            : Pankaj Ganwani 
    * \arg Description           : This is a class for Loan_HistoricalVolume component which Fetch records for 
    								'Total Historical Volume'.                     
**/
public with sharing class SL_LoanHistoricalVolumeController 
{
     /* start constructor */
    public SL_LoanHistoricalVolumeController(){}
    /* End constructor */
    
    /* Wrapper Class to hold aggregate Data*/
    public class WrapperClass
    {
    	/* Start variable */
    	public String strStage							{	get;set;	} // String for Loan Stage
    	public Integer intCount							{	get;set;	} // Integer for Loan Count
    	public Double dblCommitment						{	get;set;	} // Double for Loan Commitment
    	/* End variable */
    	
    	/* start Constructor */
    	public WrapperClass(AggregateResult objAggregateResult)
    	{
    		strStage = (String) objAggregateResult.get('Loan_Stage__c');
    		intCount = (Integer) objAggregateResult.get('CountLoan');
    		dblCommitment = (Double) objAggregateResult.get('Commitment');
    	}
    	/* End constructor */
    }
    /* End */
    
     /*!
        * MethodName  : getHistoricalVolumeRecords
        * param       : NA
        * Description : This method will fetch records to display in 'Total Historical Volume' table chart.
	*/
    public List<WrapperClass> getHistoricalVolumeRecords()
    {
    	List<WrapperClass> lstWrapperClass = new List<WrapperClass>();
        for(AggregateResult objAggregateResult: [Select Loan_Stage__c,COUNT_DISTINCT(Loan_Number__c) CountLoan,sum(Total_Commitment__c) Commitment From Loan__c Where Loan_Stage__c In('Paid Off', 'REO','Funded')  group by Loan_Stage__c])
			lstWrapperClass.add(new WrapperClass(objAggregateResult));
                                                
        return lstWrapperClass;
    }  
    /* End */
}