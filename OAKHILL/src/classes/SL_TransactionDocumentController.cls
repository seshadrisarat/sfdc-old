/**
* \arg ClassName      : SL_TransactionDocumentController
* \arg JIRATicket     : OAKHILL-7
* \arg CreatedOn      : 10/OCT/2014
* \arg LastModifiedOn : 30/DEC/2014
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This class serves as controller for SL_TransactionDocument component to show the related transaction documents on component.
*/
global with sharing class SL_TransactionDocumentController extends SL_Paginator
{
	
	/* Start - Variables */
	public String ReportGeneratorId								{get; set;}//variable to hold value of that report generator id related to which we have to fetch the transaction document records.
	public String strSortDirection								{get; set;}//variable to hold value of sort direction i.e. either ASC or DESC
	public String strSortExpresion								{get; set;}//variable to hold value of field name according to which we have to sort the records.
	public String strStatus										{get; set;}//variable to hold value of status i.e. either Rejected or Approved
	public List<String> lstHeaders								{get; private set;}// list to hold header values to display on the page
	public List<String> lstFieldAPINames						{get; private set;}// list to hold field api names that we are going to display on page
	public List<Investor_Report_Document__c> lstTransactionDocument	{get; set;}//list to hold transaction document records 
	public Map<String,String> mapFieldLabelToFieldAPI			{get; private set;}//map to contain field label to its corresponding field api name								
    public Map<String,String> mapFieldAPIToFieldType			{get; set;}
    /* End - Variables */
	
	/* Start - Class Variables*/
	String strfieldSetColumns;
	/* End -Class Variables */
	
	/* Start - Constructor */
	global SL_TransactionDocumentController()
	{
		initialize();
	}
	/* End - Constructor */
	
	/*!
      *  @MethodName: initialize
      *  @param None: None.
      *  @Description: This method is used to initialize all variables of the class.
    */
	private void initialize()
	{
		strSortDirection = 'ASC';
		strSortExpresion = 'Document_Link__c';
		intPageOffset = 0;
		strfieldSetColumns = '';
		lstHeaders = new List<String>();
		mapFieldLabelToFieldAPI = new Map<String,String>();
		lstTransactionDocument = new List<Investor_Report_Document__c>();
		lstFieldAPINames = new List<String>();
		mapFieldAPIToFieldType = new Map<String,String>();
	}	
	
	/*!
      *  @MethodName: readFieldSet
      *  @param None: None
      *  @Description: This method is used to read the field set and performing initial checks for custom setting and report generator type
    */
	private void readFieldSet()
	{
		Report_Generator__c objReportGenerator;//creating reference of report generator object
		
		List<Report_Generator__c> lstReportGenerator = [SELECT Report_Generator_Type__c FROM Report_Generator__c WHERE Id=:ReportGeneratorId LIMIT 1];
		
		//Checking if list is empty
		if(lstReportGenerator.isEmpty())
			return;
		
		objReportGenerator = lstReportGenerator[0];//assigning the value to report generator object
		
		//checking if report generator type is empty or not
		if(String.isEmpty(objReportGenerator.Report_Generator_Type__c))
		{
			Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO,'Please select report generator type.'));
			return;
		}			
		
		//reading field set and framing the soql for transaction document object
		strfieldSetColumns += formQueryString('SL_TransactionDocumentFieldSet', 'Investor_Report_Document__c',true);	
		
		//Getting custom setting record corresponding to report generator type
		SL_ReportGeneratorColumns__c objReportGeneratorColumns = SL_ReportGeneratorColumns__c.getInstance(objReportGenerator.Report_Generator_Type__c);
		
		//checking if report generator config has not been created
		if(objReportGeneratorColumns==null)
			return;
		//reading field set and framing soql as per the report generator type		
		strfieldSetColumns += ',' + formQueryString(objReportGeneratorColumns.Field_Set_Name__c, objReportGeneratorColumns.Source_Object_Name__c,false);		
	}
	
	/*!
      *  @MethodName: getRecords
      *  @param None: current offset value and sort expression
      *  @Description: This method is used to fetch the records
    */
	private void getRecords(Integer intOffset, String sortExpression)
	{	
		//checking if offset value is greater than 2000	
		if(intOffset > 2000)
			intOffset = 2000;//assigning 2000 to offset to avoid exception that occurs due to offset value have more than 2000
		
		try
		{
			if(mapFieldAPIToFieldType.get(sortExpression) != 'TEXTAREA')
			{
				//fetching the records
				lstTransactionDocument = Database.query(String.format('{0}{1}{2}{3}{4}{5}', new List<String>{'SELECT Id, '+strfieldSetColumns+' FROM Investor_Report_Document__c WHERE Report_Generator__c=:ReportGeneratorId',' ORDER BY ',sortExpression!=null ? (mapFieldAPIToFieldType.get(sortExpression) == 'REFERENCE' ? sortExpression.replace('__c', '__r.Name') : sortExpression) : strSortExpresion,' ',strSortDirection,' LIMIT : PageSize OFFSET : intOffset'}));
				//Checking if list is empty
				if(lstTransactionDocument.isEmpty())
					Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO,'No data to display.'));
			}
		}
		catch(Exception ex)
		{
			Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,'Due to some error, records can be displayed.'));
			System.debug('=========Exception=========='+ex.getMessage());
		}
	}
	
	/*!
      *  @MethodName: formQueryString
      *  @param None: name of field set and corresponding object name
      *  @Description: This method is used to form query string as per the fields mentioned in field set corresponding to passed object.
    */
    private String formQueryString(String strFieldSetName, String strSobjectName, Boolean isTransactionDoc)
    {
    	//fetching fields from field set corresponding to the object name
    	Schema.FieldSet objFieldSet = Schema.getGlobalDescribe().get(strSobjectName).getDescribe().FieldSets.getMap().get(strFieldSetName);
        String strQuery = '';//declaring variable to hold the value of comma separated fields of field set
        try
        {
            //Iterating over field set member object to fill the header list and field api list
            for(Schema.FieldSetMember objFieldSetMember : objFieldSet.getFields())
            {
                if(objFieldSetMember.getFieldPath()!='Id')
                {
	                String strHeaderName = objFieldSetMember.getFieldPath() == 'CreatedDate' ? 'Generated Date' : objFieldSetMember.getLabel();
	                lstHeaders.add(strHeaderName);
	                String strFieldAPIName = !isTransactionDoc ? strSobjectName.replace('__c', '__r.'+objFieldSetMember.getFieldPath()) : objFieldSetMember.getFieldPath();
	                mapFieldLabelToFieldAPI.put(strHeaderName, strFieldAPIName);
	                lstFieldAPINames.add(strFieldAPIName);
	                mapFieldAPIToFieldType.put(strFieldAPIName, String.valueOf(objFieldSetMember.getType()));
	                strQuery+= String.isBlank(strQuery) ? strFieldAPIName : ','+ strFieldAPIName;
                }
            }
        }
        catch(Exception ex)
        {
            System.debug('================'+ex.getMessage()+'======================'+ex.getLineNumber());
        }
    	return strQuery;
    }
	
	/*!
      *  @MethodName: sortRecords
      *  @param None: None.
      *  @Description: This method is used to sort the records based on the sort direction and sort expression parameters.
    */
	public void sortRecords()
	{
		strSortDirection = strSortDirection == 'ASC' ? 'DESC' : 'ASC';
		try
		{
			String strCurrentSortExpression = mapFieldLabelToFieldAPI.get(strSortExpresion);
			getRecords(intPageOffset,strCurrentSortExpression);
			strSortExpresion = strCurrentSortExpression;
		}
		catch(Exception ex)
		{
			System.debug('==============================='+ex.getMessage());
		}
	}
	
	/*!
      *  @MethodName: updateTransactionDocument
      *  @param None: transaction document id and status
      *  @Description: This method is used to update Transaction records status
    */
	@RemoteAction 
	global static void updateTransactionDocument(String documentId, String strStatus)
	{
		try
		{
			update new Investor_Report_Document__c(Id = documentId, Status__c = strStatus);
			List<Loop__Document_Request__c> lstDocumentQueue = [SELECT Id, Loop__Status__c FROM Loop__Document_Request__c WHERE Loop__Object_Id__c =: documentId];
			if(!lstDocumentQueue.isEmpty())
			{
				Loop__Document_Request__c objDocumentQueue = lstDocumentQueue[0];
				objDocumentQueue.Loop__Status__c = 'Rejected';
				update objDocumentQueue;
			}
		}
		catch(Exception ex)
		{
			System.debug('=============='+ex.getMessage()+'====================='+ex.getLineNumber());
			Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,'Record not saved.'));
		}
	}
	
	/*!
      *  @MethodName: fetchRecords
      *  @param None: None.
      *  @Description: This method is used to set the initial parametes for the pagination and fetch the records from object.
    */
	public void fetchRecords()
	{		
		readFieldSet();
		//calling method to initialize the variables related to Pagination
		initPagination();
	}
	
	/*!
      *  @MethodName: initPagination
      *  @param None: None.
      *  @Description: This method is used to set the initial required parameters for pagination.
    */
	private void initPagination()
	{
		page=1;//initally page is 1.     	
	    PageSize = 10;// no. of rows you want to show per page	  	    
	   	//Fetching the record list
	   	getRecords(intPageOffset,null);
	   	//Fetching total number of records
	   	TotalRows = [SELECT COUNT() FROM Investor_Report_Document__c WHERE Report_Generator__c=:ReportGeneratorId];// total rows to be spanned across pages	      
	    //Calculating last page
	    LastPage = Math.mod(TotalRows, PageSize) == 0 ? TotalRows / PageSize : TotalRows / PageSize + 1;// calculate the index of last page
	}
	
	/*!
      *  @MethodName: goToPage
      *  @param None: None.
      *  @Description: This method will redirect to the page number which is entered.
    */
	public void goToPage() 
	{
		//calling method of abstract class to go to any page
		anyPage();
		getRecords(intPageOffset,null);
	}
	
	/*!
      *  @MethodName: goToNextPage
      *  @param None: None.
      *  @Description: This method will redirect to the immediate next page from the current page.
    */
	public void goToNextPage()
	{
		//calling method of abstract class to go to immediate next page
		nextPage();
		getRecords(intPageOffset,null);
	}
	
	/*!
      *  @MethodName: goToPreviousPage
      *  @param None: None.
      *  @Description: This method will redirect to the immediate previous page from the current page.
    */
	public void goToPreviousPage()
	{
		//calling method of abstract class to go to immediate previous page
		previousPage();
		getRecords(intPageOffset,null);
	}
	
	/*!
      *  @MethodName: goToFirstPage
      *  @param None: None.
      *  @Description: This method will redirect to the first page from the current page.
    */
	public void goToFirstPage()
	{
		//calling method of abstract class to go to first page
		firstPage();
		getRecords(intPageOffset,null);
	}
	
	/*!
      *  @MethodName: goToLastPage
      *  @param None: None.
      *  @Description: This method will redirect to the last page from the current page.
    */
	public void goToLastPage()
	{
		//calling method of abstract class to go to last page.
		lastPage();
		getRecords(intPageOffset,null);
	}
	
	
	/*!
      *  @MethodName: recordApproved
      *  @param None: None.
      *  @Description: This method will change the status of the Transaction document.
    */
	public void approveOrRejectRecord()
	{
		list<Investor_Report_Document__c> lstTransactionDocumentUpdate = new list<Investor_Report_Document__c>();//list for update the Transaction document
		List<Loop__Document_Request__c> lstDocumentQueue = new List<Loop__Document_Request__c>();
		Set<String> setTransactionDocumentId = new Set<String>();
		//fetch the all Transaction Document for Report Generated record
		for(Investor_Report_Document__c objTranDoc : Database.query('SELECT Id, Status__c FROM Investor_Report_Document__c WHERE Report_Generator__c=:ReportGeneratorId'))
		{
			setTransactionDocumentId.add(objTranDoc.Id);
			if(objTranDoc.Status__c != strStatus)
			{
				objTranDoc.Status__c = strStatus;//set the Status Approved
				lstTransactionDocumentUpdate.add(objTranDoc);//add to the list for update the records
			}
		}
		//check wheather the list is empty or not, if not perform the update operation
		if(!lstTransactionDocumentUpdate.isEmpty())
			update lstTransactionDocumentUpdate;
		
		if(strStatus == 'Rejected')
		{
			//fetching all 
			for(Loop__Document_Request__c objDocumentQueue : [SELECT Id, Loop__Status__c FROM Loop__Document_Request__c WHERE Loop__Object_Id__c IN : setTransactionDocumentId])
			{
				lstDocumentQueue.add(new Loop__Document_Request__c(Id = objDocumentQueue.Id, Loop__Status__c = 'Rejected'));
			}
			
			if(!lstDocumentQueue.isEmpty())
				update lstDocumentQueue;
		}
		getRecords(intPageOffset,null);//call the getRecords methods for updated values
	}
}