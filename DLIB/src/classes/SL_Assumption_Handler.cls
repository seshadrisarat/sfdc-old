/**
* @ClassName    : SL_Assumption_Handler
* @JIRATicket   : SLPSA-11
* @CreatedOn    : 04/MAR/2013
* @ModifiedBy   : SL
* @Description  : This class is used as Handler of the SL_Assumption Trigger 
*/


/**
@Developer Name                         :   Kamal
Percentage of best practices followed   :   100%
No of SOQL queries used                 :   NA	
No of collections used                  :   NA
Exception Handling implemented          :   NA
Coding standards followed               :   Yes
Naming conventions followed             :   Yes
Third party integrations                :   NA
Maximum of No of records tested with    :   
Customer Approval                       :   
Last Modified Date                      :    04/MAR/2013
Approved by                             :   

*/

public with sharing class SL_Assumption_Handler 
{
	/* Start - Variables */
    /* End - Variables */
  
  
    /* Start - Constructor */
	public SL_Assumption_Handler()
	{
  	
  	}
  	/* End - Constructor */
  
  	/* Start - Method called before insert */
	public void onBeforeInsert(List<Assumption__c> lstNewAssumption)
	{
	  	//Method is called to check the if Assumtion.Do_Not_Add_to_Library__c is not checked then picklist filed should not empty.
	  	validateAssumption(lstNewAssumption);
	}
	/* End - Method called before insert */
	
	/* Start - Method called before update */
	public void onBeforeUpdate(List<Assumption__c> lstNewAssumption)
	{
		validateAssumption(lstNewAssumption);
	}
	/* End - Method called before update */
	
	/* Start - Method to check Assumtion to be insert or not */
	private void validateAssumption(List<Assumption__c> lstNewAssumption)
	{
		try
		{
			for(Assumption__c objAssumption : lstNewAssumption)
			{
				//Checking the Do not add to library field
				if(!objAssumption.Do_Not_Add_to_Library__c)
				{
					if(objAssumption.Task_Type__c == null || objAssumption.Industries__c == null || objAssumption.Component__c == null)
					{
						objAssumption.addError('Please select at least one value for Task Type, Industries and Component.');
					}
				}
				if(objAssumption.Industries__c != null && objAssumption.Industries__c.contains('All'))
				{
					objAssumption.Industries__c = 'All';
				}
				if(objAssumption.Task_Type__c != null && objAssumption.Task_Type__c.contains('All'))
				{
					objAssumption.Task_Type__c = 'All';
				}
				if(objAssumption.Component__c != null && objAssumption.Component__c.contains('All'))
				{
					objAssumption.Component__c = 'All';
				}
				
				//Updating the Assumption_Detail_Text__c field
				if(objAssumption.Assumption_Detail__c != null && objAssumption.Assumption_Detail__c != '')
					objAssumption.Assumption_Detail_UI__c = objAssumption.Assumption_Detail__c.length()>255 ? objAssumption.Assumption_Detail__c.substring(0,252)+ '...':objAssumption.Assumption_Detail__c;
				else
					objAssumption.Assumption_Detail_UI__c = '';
			}
		}
		catch(Exception ex)
		{
			System.debug('===============Exception============'+ex);
		}
	}
	/* End - Method to check Assumtion to be insert or not */
    @isTest 
    static void SL_Assumption_Handler_Test()
    {
    	Assumption__c objAssumption1 = new Assumption__c(Name='Assumption',Task_Type__c = 'All,Configuration',Component__c = 'All,Account',Industries__c = 'All,Investment Banking');
    	insert objAssumption1;
    	objAssumption1.Do_Not_Add_to_Library__c = true;
    	update objAssumption1;
    	objAssumption1.Do_Not_Add_to_Library__c = false;
    	update objAssumption1;
    }
  
  
  
}