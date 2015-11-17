/**
* \arg ClassName      : SL_ManageNRI_FilesController
* \arg JIRATicket     : SEGAL-4
* \arg CreatedOn      : 16/DEC/2014
* \arg LastModifiedOn : 17th/March/2014
* \arg CreatededBy    : Sandeep
* \arg ModifiedBy     : Sandeep
* \arg Description    : This class is used to manage NRI documents.
*/
public with sharing class SL_ManageNRIVFFilesController 
{
    
    public String sObjectRecordId                           {get;set;}      
    public String strObjectIdTodelete                       {get;set;} 
    public String strSaveAllOrOne                           {get;set;}
    public String strRemoveSelectedOrOne                    {get;set;}
    public String strBaseURL                                {get;set;}
    public Boolean isHeadCheck                              {get;set;}
    public Boolean isRemoveSelected                         {get;set;} 
    public Id selectActionId                                {get;set;}
    public List<AttachmentsWrapper> lstAttachmentsWrapper   {get;set;}
    
    /* Start - Constructor */
    public SL_ManageNRIVFFilesController()
    {
        initializeVariables();
    }
    /* End - Constructor */
    
    /*
     @InnerClassName: AttachmentsWrapper
     @param None
     @Description: Wrraper class to bind data
    */
    public class AttachmentsWrapper
    {
        public Attachment objAttachment         {get;set;}
        public String strDocumentLocation       {get;set;}
        public Boolean isSaveOrCancelRecord     {get;set;}
        public Boolean isViewOrRemoveRecord     {get;set;}
        public Boolean isCheckedRecord          {get;set;}
        public Boolean isCancel                 {get;set;}
        public Boolean isSave                   {get;set;}
        public String strRefNumber              {get;set;}
        public String strDocumentType           {get;set;}
        
        public AttachmentsWrapper(Attachment objAttachment, String strDocumentLocation,Boolean isSaveOrCancelRecord, Boolean isViewOrRemoveRecord, Boolean isCheckedRecord, 
                                  String strRefNumber, Boolean isCancel,String strDocumentType)
        {
            this.objAttachment =  objAttachment;
            this.strDocumentLocation = strDocumentLocation;
            this.isSaveOrCancelRecord = isSaveOrCancelRecord;
            this.isViewOrRemoveRecord = isViewOrRemoveRecord;
            this.isCheckedRecord = isCheckedRecord;
            this.isCancel = isCancel;
            this.isSave = false;
            this.strRefNumber = strRefNumber;
            this.strDocumentType = strDocumentType;
        }
   }
   /* End of AttachmentsWrapper Class */
    
    /*
     @MethodName: initializeVariables
     @param: None
     @Description: Initializing all global variables
    */
    public void initializeVariables()
    {
        strBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        lstAttachmentsWrapper = new List<AttachmentsWrapper>();
        isRemoveSelected = false;
    }
    /* End of initializeVariables method */
       
    /*
     @MethodName: fetchNRIDocAttachments
     @param: None
     @Description: Fetches all NRI records for sobject Id and storing in Inner class
    */
    public void fetchNRIDocAttachments()
    {
        try
        {
            lstAttachmentsWrapper = new List<AttachmentsWrapper>();
            
            /* Fetching all attachment records present for sobject Id */ 
            for(Attachment objAttachmentDoc : [SELECT Id, Name, Body, Description FROM Attachment WHERE ParentId =: sObjectRecordId ])
            {
                if(objAttachmentDoc.Name.contains('.nrl'))
                {
                    String strBody= objAttachmentDoc.Body.toString();
                    lstAttachmentsWrapper.add(new AttachmentsWrapper(objAttachmentDoc, strBody.substring(0, strBody.IndexOf('DMS')), 
                                                                    false, true, false, 
                                                                    strBody.substring(strBody.IndexOf(':!document:')+11, strBody.IndexOf(',1:')), 
                                                                    false, objAttachmentDoc.Description));
                }
                    
            }
            
            if(lstAttachmentsWrapper.isEmpty())
            {
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'No records to display'));
            }
        }
        catch(Exception ex)
        {
            System.debug('=======Exception while fectching============'+ex.getLineNumber());
        }
    }
    /* End of fetchNRIDocAttachments method */
   
    /*
     @MethodName: checkAllRecords
     @param: None
     @Description: checkAllRecords function will check all the checkboxes to true
    */   
    public void checkAllRecords()
    {
        try
        {
            if(lstAttachmentsWrapper.size() > 0 )
            {
                for(AttachmentsWrapper objInner : lstAttachmentsWrapper)
                {
                    if(isHeadCheck == true)
                        objInner.isCheckedRecord = true;
                    
                    if(isHeadCheck == false)
                        objInner.isCheckedRecord = false;
                }
            }
        }
        catch(Exception ex)
        {
            System.debug('=======Exception ======'+ex.getMessage());
        }               
    }
    /* End of checkAllRecords method */
    
    /*
     @MethodName: unSelectCheckRecords
     @param: None
     @Description: unSelectCheck function will set checkboxes to uncheck if any rows is check box is unselected  
    */
    public void unSelectCheckRecords()
    {
        try
        {
            if(isHeadCheck == true)
            {
                for(AttachmentsWrapper objInner : lstAttachmentsWrapper)
                {
                    if(!objInner.isCheckedRecord)
                        isHeadCheck = false;
                }
            }
        }
        catch(Exception ex)
        {
            System.debug('=======Exception ======'+ex.getMessage());
        }   
    }
    /* End of unSelectCheckRecords method */
    
    /*
     @MethodName: addNewNRIDocument
     @param: None
     @Description: Adding new empty row
    */
    public void addNewNRIDocument()
    {
        lstAttachmentsWrapper.add(new AttachmentsWrapper(new Attachment(), null, true, false, false, null, false, null));
    }
    /* End of addNewNRIDoc method */
        
    /*
     @MethodName: deleteNRIDocument
     @param: None
     @Description: Deleting NRI documents
    */
    public void deleteNRIDocument()
    {
        try
        {
            /* List to store all records to be delete from Org */
            List<Attachment> lstAttachmentToDelete = new List<Attachment>();
            
            /* Looping from whole inner class list to check which record should be deleted */
            for(Integer i=0; i < lstAttachmentsWrapper.size(); i++)
            {
                
                /* Comparing the Id which need to be remove from org */
                if((strRemoveSelectedOrOne == 'One' && lstAttachmentsWrapper[i].objAttachment.Id == selectActionId ) ||
                   (strRemoveSelectedOrOne == 'Selected' && lstAttachmentsWrapper[i].isCheckedRecord ))
                {
                    isRemoveSelected = true;
                    
                    /* Adding the object in list to delete that record from org */
                    if(lstAttachmentsWrapper[i].objAttachment.Id != null)
                        lstAttachmentToDelete.add(lstAttachmentsWrapper[i].objAttachment);
                    
                    lstAttachmentsWrapper.remove(i);
                    i = i-1;
               }
            }
            
            if(isRemoveSelected == false )
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Please select atleast one record to remove'));
            
            if(lstAttachmentsWrapper.size() == 0)
                isHeadCheck = false;
               
            /* Checking the list contains any records or not to be deleted */
            if(!lstAttachmentToDelete.isEmpty())
            {   
                delete lstAttachmentToDelete;
            }   
        }
        catch(Exception ex)
        {
             System.debug('=======Exception ======'+ex.getMessage());
        }
    }
    /* End of deleteNRIDoc method */
    
    /*
     @MethodName: saveAllRecords
     @param: None
     @Description: It will Save all NRI documents records for sobject Id 
    */
    public void saveAllRecords()
    {
        List<Attachment> lstAttachmentToSave= new List<Attachment>();
        List<AttachmentsWrapper> lstAttachmentsWrapperNew= new List<AttachmentsWrapper>();
        
        String strNriDoc;
        
        try
        {
            if(lstAttachmentsWrapper.isEmpty())
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'No records to display'));
            if(!isValidateAttachments())
            {
                for(Integer i=0;i < lstAttachmentsWrapper.size(); i++)
                {
                    strNriDoc = lstAttachmentsWrapper[i].strDocumentLocation + 'DMS' + '\r\n' + '!nrtdms:0:!session:' + lstAttachmentsWrapper[i].strDocumentLocation + 
                                'DMS:!database:' + lstAttachmentsWrapper[i].strDocumentLocation + ':!document:' + lstAttachmentsWrapper[i].strRefNumber + ',1:' + '\r\n' + 
                                '[Version]' + '\r\n' + 'Latest=Y';
                    
                    if( strSaveAllOrOne == 'All' || (strSaveAllOrOne == 'One' && !lstAttachmentsWrapper[i].isSaveOrCancelRecord))
                    {
                        lstAttachmentsWrapper[i].isSaveOrCancelRecord =  false;
                        lstAttachmentsWrapper[i].isViewOrRemoveRecord =  true;  
                        
                        String strDocName = '';
                        
                        if((lstAttachmentsWrapper[i].objAttachment.Name).contains('.nrl'))
                            strDocName = lstAttachmentsWrapper[i].objAttachment.Name;
                        else
                            strDocName = lstAttachmentsWrapper[i].objAttachment.Name + '.nrl';
                        
                        /* Creating a Attachments record to be save. */
                        Attachment objAttachDoc = new Attachment(id = lstAttachmentsWrapper[i].objAttachment.Id, Name = strDocName, Body = Blob.valueOf(strNriDoc), 
                                                                 ParentId = sObjectRecordId, Description = lstAttachmentsWrapper[i].strDocumentType); 
                        
                        
                        if((lstAttachmentsWrapper[i].strRefNumber == '' || lstAttachmentsWrapper[i].strRefNumber == null) && (lstAttachmentsWrapper[i].strDocumentLocation == '' || lstAttachmentsWrapper[i].strDocumentLocation == null || lstAttachmentsWrapper[i].strDocumentLocation == '--None--'))
                        {
                        	lstAttachmentsWrapperNew.add(lstAttachmentsWrapper[i]); 
                            lstAttachmentsWrapper[i].isSaveOrCancelRecord = true;
                            lstAttachmentsWrapper[i].isViewOrRemoveRecord = false;
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please enter the Document # and Document Library'));
							break;
                        }
                        else if(lstAttachmentsWrapper[i].strRefNumber == '' || lstAttachmentsWrapper[i].strRefNumber == null )
                        {
                            lstAttachmentsWrapperNew.add(lstAttachmentsWrapper[i]); 
                            lstAttachmentsWrapper[i].isSaveOrCancelRecord = true;
                            lstAttachmentsWrapper[i].isViewOrRemoveRecord = false;
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please enter the Document #'));
                            break;    
                        }
                        else if(lstAttachmentsWrapper[i].strDocumentLocation == '' || lstAttachmentsWrapper[i].strDocumentLocation == null || lstAttachmentsWrapper[i].strDocumentLocation == '--None--')
                        {
                        	lstAttachmentsWrapperNew.add(lstAttachmentsWrapper[i]); 
                            lstAttachmentsWrapper[i].isSaveOrCancelRecord = true;
                            lstAttachmentsWrapper[i].isViewOrRemoveRecord = false;
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please enter the Document Library'));
                            break;
                        }
                        else
                        {
                           lstAttachmentToSave.add(objAttachDoc);
                           lstAttachmentsWrapper[i].objAttachment = objAttachDoc;
                        }         
                    }
                    else
                    {
                        lstAttachmentsWrapper[i].isSaveOrCancelRecord =  true;
                        lstAttachmentsWrapper[i].isViewOrRemoveRecord =  false; 
                    }
                    lstAttachmentsWrapperNew.add(lstAttachmentsWrapper[i]);
                }
                
                if(lstAttachmentsWrapperNew.size() > 0 )
                {
                    lstAttachmentsWrapper = new List<AttachmentsWrapper>();
                    lstAttachmentsWrapper.addAll(lstAttachmentsWrapperNew);
                }
                
                /* Checking the list contains any records or not */
                if(!lstAttachmentToSave.isEmpty())
                    Database.upsert(lstAttachmentToSave, false);
            }
        }
        catch(Exception ex)
        {
            System.debug('=======Exception ======'+ex.getMessage());
        }           
    }
    /* End of saveAllRecords method */
    
    /*
      @MethodName: canceDocuments
      @param: None
      @Description: Cancelling the attachment to save 
    */
    public void canceDocuments()
    {
        for(Integer i=0;i < lstAttachmentsWrapper.size(); i++)
        {
            if(lstAttachmentsWrapper[i].isCancel == true)
            {
                lstAttachmentsWrapper.remove(i);
                break;
            }
        }
        
        if(lstAttachmentsWrapper.isEmpty())
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'No records to display'));
    }
    /* End of canceDocuments method */
   
    /*
     @MethodName: savesDocuments
     @param: None
     @Description: Saving attachemnts on click of save button
    */
    public void savesDocuments()
    {
        List<Attachment> lstAttachmentToSave= new List<Attachment>();
        String strNriDoc; 
        
        try
        {
            for(Integer i=0;i < lstAttachmentsWrapper.size(); i++)
            {
                strNriDoc = lstAttachmentsWrapper[i].strDocumentLocation + 'DMS'+ '\r\n' + '!nrtdms:0:!session:' + lstAttachmentsWrapper[i].strDocumentLocation 
                            + 'DMS:!database:' + lstAttachmentsWrapper[i].strDocumentLocation + ':!document:' + lstAttachmentsWrapper[i].strRefNumber + 
                            ',1:' + '\r\n' + '[Version]' + '\r\n' + 'Latest=Y';
                if(lstAttachmentsWrapper[i].isSave)
                {
                    String strDocName = '';
                    
                    if(lstAttachmentsWrapper[i].objAttachment.Name == null || lstAttachmentsWrapper[i].objAttachment.Name == '')
                    {
                        lstAttachmentsWrapper[i].isSaveOrCancelRecord = true;
                        lstAttachmentsWrapper[i].isViewOrRemoveRecord = false;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please enter Name'));
                        break;
                    }
                    
                    if((lstAttachmentsWrapper[i].strRefNumber == null || lstAttachmentsWrapper[i].strRefNumber == '') && (lstAttachmentsWrapper[i].strDocumentLocation == null || lstAttachmentsWrapper[i].strDocumentLocation == '' || lstAttachmentsWrapper[i].strDocumentLocation == '--None--'))
                    {
                		lstAttachmentsWrapper[i].isSaveOrCancelRecord = true;
                    	lstAttachmentsWrapper[i].isViewOrRemoveRecord = false;
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please enter the Document # and Document Library'));
						break;	
                    }
                    
                    if(lstAttachmentsWrapper[i].strRefNumber == null || lstAttachmentsWrapper[i].strRefNumber == '')
                    {
                        lstAttachmentsWrapper[i].isSaveOrCancelRecord = true;
                        lstAttachmentsWrapper[i].isViewOrRemoveRecord = false;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please enter the Document #'));
                        break;
                    }
                    
                    if(lstAttachmentsWrapper[i].strDocumentLocation == null || lstAttachmentsWrapper[i].strDocumentLocation == '' || lstAttachmentsWrapper[i].strDocumentLocation == '--None--')
                    {
                        lstAttachmentsWrapper[i].isSaveOrCancelRecord = true;
                        lstAttachmentsWrapper[i].isViewOrRemoveRecord = false;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please enter the Document Library'));
                        break;
                    }
                    
                    if((lstAttachmentsWrapper[i].objAttachment.Name).contains('.nrl'))
                        strDocName = lstAttachmentsWrapper[i].objAttachment.Name;
                    else
                        strDocName = lstAttachmentsWrapper[i].objAttachment.Name + '.nrl';
                    
                    /* Creating a Attachments record to be save. */
                    Attachment objAttachDoc = new Attachment(Name = strDocName, Body = Blob.valueOf(strNriDoc), ParentId = sObjectRecordId, 
                                                             Description = lstAttachmentsWrapper[i].strDocumentType); 
                    
                    lstAttachmentToSave.add(objAttachDoc);
                    
                    /* Adding the object in List */
                    lstAttachmentsWrapper[i].objAttachment= objAttachDoc;
                    lstAttachmentsWrapper[i].isSaveOrCancelRecord = false;
                    lstAttachmentsWrapper[i].isViewOrRemoveRecord =  true;
                    lstAttachmentsWrapper[i].isSave = false;
                }
            }
        
            if(!lstAttachmentToSave.isEmpty())
                Database.insert(lstAttachmentToSave, false);
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid attachments'));
        }       
    }
    /* End of savesDocuments method */
    
    /*
     @MethodName: isValidateAttachments
     @param: None
     @Description: validationg the attachments documents
    */
    public Boolean isValidateAttachments()
    {
        try
        {
            /* Setting by default value as false, if got any error then set this as true. */
            Boolean isError = false;
            
            /* Looping on all records in list */
            if(lstAttachmentsWrapper != NULL && lstAttachmentsWrapper.size() > 0)
            {
                for(Integer i=0; i < lstAttachmentsWrapper.size(); i++)
                {
                    
                    if(lstAttachmentsWrapper[i].objAttachment.Name == Null || lstAttachmentsWrapper[i].objAttachment.Name == '')
                    {   
                        isError = true;
                        lstAttachmentsWrapper[i].isSaveOrCancelRecord = true;
                        lstAttachmentsWrapper[i].isViewOrRemoveRecord = false;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Please enter Name'));
                        return isError;
                    }
                }
            }
            else
            {
                return isError;
            }
            return isError;
        }       
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid data'));
            return true;
        }   
    }
    /* End of isValidateAttachments method */
    
    /*
     @MethodName: getDocumentLocation
     @param: None
     @Description: getting document location from custom setting
    */
    public List<Selectoption> getDocumentLocation()
    {
        List<SelectOption> lstDocumentLocation = new List<Selectoption>();
        
        lstDocumentLocation.add(new SelectOption('--None--', '--None--'));
        for(DocumentLocation__c objDocumentLocation : DocumentLocation__c.getall().values())
        {
            lstDocumentLocation.add(new SelectOption(objDocumentLocation.Name, objDocumentLocation.Name));
        }
        return lstDocumentLocation;
    }
    /* End of getDocumentLocation method */
    
    /*
     @MethodName: getDocumentType
     @param: None
     @Description: getting document type from custom setting
    */
    public List<Selectoption> getDocumentType()
    {
        List<SelectOption> lstDocumentType = new List<Selectoption>();
        for(DocumentType__c objDocumentLocation : DocumentType__c.getall().values())
        {
            lstDocumentType.add(new SelectOption(objDocumentLocation.Name, objDocumentLocation.Name));
        }
        return lstDocumentType;
    }
    
}