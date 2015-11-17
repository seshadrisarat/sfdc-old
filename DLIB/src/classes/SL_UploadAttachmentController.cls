/**
* @ClassName 	:	SL_UploadAttachmentController
* @JIRATicket   :	CW-82
* @CreatedOn    :	7/Sept/12
* @CreatedBy    :	Pankaj Ganwani
* @Description  :	This class serves the controller for SL_UploadAttachment page that works as iframe in postAQuestion page. This class is used to upload the attachment from site page and associate it with the created Case record. 
*/
public class SL_UploadAttachmentController 
{
    public Attachment objAttachment    {get;set;}
    public String caseId               {get;set;}
    public Boolean controllerCalled    {get;set;}
    public String strCustomSettingName {get;set;}
    
    public SL_UploadAttachmentController()
    {
        objAttachment = new Attachment();
        strCustomSettingName = getCustomSettingName();
        controllerCalled = false;
    }
    
    
    public void createAttachment()    
    { 
        if(objAttachment.Body!=NULL)
        {
            Attachment objNewAttachment = objAttachment.clone(false, true, false, false);
            objAttachment = new Attachment();
            objNewAttachment.ParentId = caseId;
            
            insert objNewAttachment;
        }
        controllerCalled = true; 
    }
    
    /* Start - Method to get the Name used in custom setting */
	private String getCustomSettingName()
	{
		/* Getting info about the Name  */
		String strSitePrefix = Site.getName();
		if(strSitePrefix == Null)
			strSitePrefix = 'CalendarAnything_Website';
			
		SL_SiteName__c objNav = SL_SiteName__c.getAll().get(strSitePrefix);
		if(objNav != null)
			return objNav.SiteIdentifier__c;
		else
			return 'ca';
	}
	/* END -  */
}