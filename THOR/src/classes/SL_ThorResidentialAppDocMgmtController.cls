/*
	*  ClassName      : SL_ThorResidentialAppDocMgmtController
	*  JIRATicket     : THOR-20
	*  CreatedOn      : 12/AUG/2014
	*  ModifiedBy     : Sandeep Sankhla
	*  Description    : This is the controller to attach documents.
*/
public without sharing class SL_ThorResidentialAppDocMgmtController 
{
	/* Start  - Page variables */
	public String strContactRoleFullName		{	get;set;	}
	public List<FileWrapper> lstFileWrapper		{	get;set;	} 
	public Boolean isDocumentSubmitted          {   get;set;    }
	/* End  - Page variables */
	 
	/* Start  - class variables */
	private Id opportunityId;
	private Id contactRoleId;
	/* End  - class variables */
	
	/* Constructor */
	public SL_ThorResidentialAppDocMgmtController()
	{
		/* Calling initialize method to initialize varibles */
		initialize();
	} 

	/* Start - Wrapper class */
    public class FileWrapper
    {
    	public transient String blbFile				{	get;set;	}
    	public String strUploadedfileName			{	get;set;	}
    	public String strCustSetDocumentName		{	get;set;	}
    	public String strFileType                   {   get;set;    }
    	
    	/* Wrapper class constructor */
    	public FileWrapper(String blbFile, String strUploadedfileName, String strCustSetDocumentName , String strFileType)
    	{
    		this.blbFile = blbFile;
    		this.strUploadedfileName = strUploadedfileName;
    		this.strCustSetDocumentName = strCustSetDocumentName;
    		this.strFileType = strFileType;
    	}
    }
     /* End  - Wrapper class */
	
	/*
    	* MethodName   : initialize
        * param        : None
        * Description  : This method is used to initialize varibles  
    */
	private void initialize()
	{
		try
		{
			List<SL_LeaseDocuments__c> lstLD = new  List<SL_LeaseDocuments__c>();
			lstFileWrapper = new List<FileWrapper>();
			isDocumentSubmitted = false;
			/* Getting Opportunity Id and Contact role Id from URL */
			if((ApexPages.currentPage().getParameters().containsKey('oppId') 
                && String.valueOf(Id.valueOf(ApexPages.currentPage().getParameters().get('oppId')).getSobjectType()) == 'Opportunity') 
                && (ApexPages.currentPage().getParameters().containsKey('conRoleId') 
                && String.valueOf(Id.valueOf(ApexPages.currentPage().getParameters().get('conRoleId')).getSobjectType()) == 'Contact_Role__c'))
			{
				opportunityId = ApexPages.currentPage().getParameters().get('oppId');
				contactRoleId = ApexPages.currentPage().getParameters().get('conRoleId');
			}
			else
			{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Insufficient Parameters.'));
				return;
			}	
			
			/* Getting list of Documents from Custom setting */
			lstLD = [ SELECT Name, Set_Order__c, Description__c 
					    FROM SL_LeaseDocuments__c 
				    Order By Set_Order__c ];
			
			/* Fetching contact roles First name and Last name */			
			List<Contact_Role__c> lstContactRole = [ SELECT Id,LastName__c, 
															FirstName__c 
													   FROM Contact_Role__c 
													  WHERE Id =: contactRoleId];
			
			if(lstContactRole != null && !lstContactRole.isEmpty())
			{
				strContactRoleFullName = (lstContactRole[0].FirstName__c == null ? '' : lstContactRole[0].FirstName__c) + ' ' + (lstContactRole[0].LastName__c == null ? '' : lstContactRole[0].LastName__c);
			}
			
			if(!lstLD.isEmpty())
			{
				for(SL_LeaseDocuments__c objLD : lstLD)
				{		
					lstFileWrapper.add(new FileWrapper(null, null, objLD.Name,null));		
				}
			}
			else
			{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, System.Label.SL_NoDocAvailable));
				return;
			}		
		}		
		catch(Exception e)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
			return;
		}
	}
	
	/*
    	* MethodName   : saveAttachments
        * param        : None
        * Description  : This method is used to save Attachments  
    */
	public void saveAttachments() 
	{
		List<Attachment> lstAttachment = new List<Attachment>();
 		isDocumentSubmitted = true;
		try
		{
			if (!lstFileWrapper.isEmpty())
			{ 
				Integer i = 0;
				
				List<Contact_Role__c> lstContactRole = [ SELECT Id FROM Contact_Role__c WHERE Id =: contactRoleId];
													        
													      
				for(FileWrapper objFileWrapper : lstFileWrapper)
				{
					if (objFileWrapper.blbFile != null && objFileWrapper.strUploadedfileName != null && objFileWrapper.strUploadedfileName != '')
					{ 
						if(objFileWrapper.strCustSetDocumentName == 'Photo Identification')
						{
							++i;
							lstContactRole[0].Submitted_PhotoId__c = true;
						}
						else if(objFileWrapper.strCustSetDocumentName == 'Employment Letter/Contract')
						{
							++i;
							lstContactRole[0].Submitted_Employment_Letter__c = true;
						}
						else if(objFileWrapper.strCustSetDocumentName == 'Most Recent Pay Stub')
						{
							++i;
							lstContactRole[0].Submitted_Pay_Stubs__c = true;
						}
						else if(objFileWrapper.strCustSetDocumentName == 'Most Recent Bank Statement')
						{
							++i;
							lstContactRole[0].Submitted_Bank_Statements__c = true;
						}
						else if(objFileWrapper.strCustSetDocumentName == 'Landlord Reference Letter')
						{
							++i;
							lstContactRole[0].Submitted_Landlord_Reference_Letter__c = true;
						}
						
						lstAttachment.add(new Attachment( Body = EncodingUtil.Base64Decode(objFileWrapper.blbFile), 
												 		  Name = (strContactRoleFullName == null ? '' : strContactRoleFullName) + ' - ' + objFileWrapper.strUploadedfileName,
												 		  ParentId = opportunityId,
												 		  Description = (objFileWrapper.strUploadedfileName == null ? '' : objFileWrapper.strUploadedfileName) + ' uploaded by '+ (strContactRoleFullName == null ? '' : strContactRoleFullName) + ' at '+ System.now().format(),
												 		  ContentType = objFileWrapper.strFileType
												 		 ));
					   lstAttachment.add(new Attachment( Body = EncodingUtil.Base64Decode(objFileWrapper.blbFile), 
												 		  Name = (strContactRoleFullName == null ? '' : strContactRoleFullName) + ' - ' + objFileWrapper.strUploadedfileName,
												 		  ParentId = contactRoleId,
												 		  Description = (objFileWrapper.strUploadedfileName == null ? '' : objFileWrapper.strUploadedfileName) + ' uploaded by '+ (strContactRoleFullName == null ? '' : strContactRoleFullName) + ' at '+ System.now().format(),
												 		  ContentType = objFileWrapper.strFileType
												 		 ));
					}
				}
				
				///Set status if atleast one document is uploaded
				if(i > 0)
					lstContactRole[0].Status__c = 'Documents Uploaded';
				
				if(!lstContactRole.isEmpty())
				{
					try
					{
						update lstContactRole[0];
					}
					catch(Exception ex)
					{
						system.debug('-------Exception-------->>>>>>>>>>>>>>'+ex);
					}
				}			
				if(!lstAttachment.isEmpty())
				{
					insert lstAttachment;
					ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.SL_DocSucessMsgLabel));
				}
				else
				{
					ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.SL_NoDocSelect));
				}	 
			}
			else
			{
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.SL_NoDocSelect));
			}
		}
		catch(DMLException e)
		{
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.SL_UnSucessMsg));
		}
		catch(Exception e)
		{
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
		}	 
	} /* End of saveAttachments methods */		
} /* End of class */