public class BES_addAttachmentsController
{
    public static testMethod void testMethod1()
    {
        BES_addAttachmentsController obj = new BES_addAttachmentsController();
        obj.parentId = [SELECT Id FROM Account LIMIT 1].Id; 
        obj.addPresetDocsToList(10);
        obj.saveAttachments();
        obj.goBack();
    }
    
    
    public BES_addAttachmentsController()
    {
        try
        {
            parentId = ApexPages.currentPage().getParameters().get('parentId');
            addPresetDocsToList(10);
            
            
        }
        catch(Exception Ex)
        {
            // DO NOTHING
        }
        
    }
    
    public void addPresetDocsToList(Integer No)
    {
        attachments = new list<Attachment>();
        for(integer i = 0; i < No; i++)
        {
           addDocumentToList();
        }
    }
    
    private void addDocumentToList()
    {
         Attachment attachment = new Attachment();
         attachment.parentId = parentId;
         attachments.add(attachment);
    }
    
    public list<Attachment> attachments
    {
        set
        {
            attachments = value;
        }
        get
        {
            return attachments;
        }
        
    }
    public Id parentId
    {
        set
        {
            parentId = value;
        }
        get
        {
            return parentId;
        }    
    }
    
    public PageReference saveAttachments()
    {
        try
        {
            for(integer i=0; i<attachments.size(); i++)
            {
                if(attachments[i].body == null || attachments[i].name == null)
                {
                    attachments.remove(i);
                    i = 0;
                }
            }
            if(attachments.size()>0)
            {
                Database.SaveResult[] lsr =  Database.insert(attachments);
                return goBack();
            }
        }
        catch(Exception Ex)
        {
            ApexPages.addMessages(Ex);
        }
        return null;
        
    }
    
    public PageReference goBack()
    {
        PageReference pageRef = new PageReference('/'+parentId);
        pageRef.setRedirect(true);
        return pageRef; 
    }
}