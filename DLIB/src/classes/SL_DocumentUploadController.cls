public with sharing class SL_DocumentUploadController 
{
	
	public ContentVersion objContentVersion	{	get; set;	}							// Obj to insert record of type ContentVersion
	public String strFileName 				{	get; set;	}							// filename to be attached
	public Integer imageSize 				{	get; set;	}							// int to keep file size value
	public blob attachmentBody 				{ 	get; set;	}							//file to be attached 
	public List<SelectOption> options		{ 	get; set;	}							// list to display all the libaries
	
	public String selectedLibrary			{	get; set; 	}
	public String strTitle					{	get; set;	}
	private String currentURL;
	private String widgetId ;
	
	
	List<SelectOption> lstOfLibraries = new List<SelectOption>();				// list to store all the libraries
	
	//controller
	public SL_DocumentUploadController() 
	{
		strTitle = '';
		objContentVersion = new ContentVersion();
		getallValuesForSelectList();
		currentURL = ApexPages.currentPage().getHeaders().get('Referer');
		widgetId = ApexPages.currentPage().getParameters().get('widgetid');
	}
	
	/**
    @MethodName : getallValuesForSelectList
    @Description: This method will retrieve all the library names and put it in a list which displys them in select list.
    **/
	public List<Selectoption> getallValuesForSelectList()
	{ 
		// initialize the list
 		options = new List<SelectOption>();
 		options.add(new SelectOption('','--Select a library--'));
 		//query all the library names and put it inside the options.
		for(ContentWorkspace W : [Select id, Name From ContentWorkspace])
 			options.add(new SelectOption(W.Id, W.Name));
 		return options;
 	}
	
	/**
    @MethodName : save
    @Description: This method will insert ContentVersion records.
    **/
	public PageReference uploadDocument() 
	{
		//  Checks whether the selected User has an attachment and file size not exceeding the limit
		if(attachmentBody != null)
		{
			try		
			{
				objContentVersion.VersionData = attachmentBody;
				objContentVersion.PathOnClient = strFileName;
				objContentVersion.FirstPublishLocationId = selectedLibrary;

				if(String.isBlank(strTitle))
					strTitle = strFileName;
					
				objContentVersion.Title = strTitle;
				insert objContentVersion;
				
				// set all the fields empty once the record is inserted
				attachmentBody = null;
				SelectedLibrary = strFileName = '';
				imageSize = 0;
				objContentVersion = new ContentVersion();
		  		return new PageReference('/apex/SL_DocumentUpload?Success=true&widgetId='+widgetId).setRedirect(true);
			}	
	  		catch(Exception ex)
	  		{
	  			ApexPages.addMessage( new ApexPages.message(ApexPages.severity.ERROR, 'Insufficent Privilages'));
	  			attachmentBody = null;
	  			SelectedLibrary = strFileName = '';
				imageSize = 0;
				objContentVersion = new ContentVersion();
	  			return new PageReference('/apex/SL_DocumentUpload?Success=false&widgetId='+widgetId).setRedirect(true);
	  		}
		}
		return new PageReference('/apex/SL_DocumentUpload?Success=false&widgetId='+widgetId).setRedirect(true);
		
	}       
	
}