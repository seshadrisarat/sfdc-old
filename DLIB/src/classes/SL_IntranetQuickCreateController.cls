public with sharing class SL_IntranetQuickCreateController extends ComponentControllerBase
{
	/* Constructor initialization */
	public SL_IntranetQuickCreateController()    
	{
		//Do nothing
	}
	/* End : Constructor initialization */
	
	public SL_IntranetQuickCreate getMyImpl()
	{  
		return (SL_IntranetQuickCreate)compImpl; 
	} 
	
	public void fieldSet() 
	{
		getMyImpl().FieldSetNamesOfSelectedSObject();  
	}
	
	public void retrieveAllField() 
	{
		getMyImpl().retrieveAllFields();  
	}
	
	public void createRecords() 
	{
		getMyImpl().btnCreateRecords();  
	}
	
	public void showMainSection() 
	{
		getMyImpl().showMainSection();  
	}
	
	public void cancel() 
	{
		getMyImpl().btnCancel();  
	}
	
	public void getFilteredByDepartment()
	{
		getMyImpl().getFilteredByDepartment();  
	}
	
}