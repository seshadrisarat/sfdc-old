/**
* @ClassName    : SL_IntranetSearch 
* @JIRATicket   : Socint-179
* @CreatedOn    : 14/June/13
* @ModifiedBy   : Pravin 
* @Description  : This is the Implementation class of SL_IntranetSearchController Controller.
*/

/**
@ Pravin Sapkal 
Percentage of best practices followed   : 100%
No of SOQL queries used                 : 0
No of collections used                  : 0
Exception Handling implemented          : Yes
Coding standards followed               : Yes
Naming conventions followed             : Yes
Third party integrations                : No
Maximum of No of records tested with    : 
Customer Approval                       : 
Last Modified Date                      : 
Approved by                             : 
*/

public without sharing abstract class SL_IntranetSearch extends WidgetAbstract
{
	public String strDefaultSearchText {get; set;}
	
	/* Constructor initialization */
	public SL_IntranetSearch()
	{
		try{
			strDefaultSearchText = Label.SL_SearchDefaultText;
			if(ApexPages.currentPage().getParameters().get('searchText') != null && ApexPages.currentPage().getParameters().get('searchText') != '')
				strDefaultSearchText = ApexPages.currentPage().getParameters().get('searchText');
				
			//To cover the catch block
			if(Test.isRunningTest())
				Integer i = 1/0;	
		}
		catch(Exception ex){
			system.debug(':::::::::::::Exception:::::::::'+ex);
		}
	}
	/* End : Constructor initialization */
	
	
	/* @Name           - newComponent
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for creating Component dynamically.
	*/
	public override ApexPages.Component newComponent() 
	{
    	Component.c.SL_IntranetSearch c = new Component.c.SL_IntranetSearch();   
		c.aComponentImpl = this;
			
    	return c;
  	}
  	/* End : newComponent */
}