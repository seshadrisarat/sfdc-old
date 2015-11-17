public with sharing class OperationsPricingQuoteInsertController {

    @TestVisible
    private static final String QUOTE_ATTACHMENT_NAME = 'Quote.prm';

    private ApexPages.StandardController controller {get; set;}
    
    public sObject pq { get; private set; }
    public String templateId { get; set; }
    
    public OperationsPricingQuoteInsertController (ApexPages.StandardController con)
    {
        controller = con;
        pq = con.getRecord();
    }
    
    public List<SelectOption> getTemplateOptions(){
        List<IST__SuperTRUMP_Template__c> templates = [SELECT ID, Name FROM IST__SuperTRUMP_Template__c LIMIT 50000];
        List<SelectOption> options = new List<SelectOption>();
        for (IST__SuperTRUMP_Template__c t : templates){
            options.add(new SelectOption(String.valueOf(t.ID), t.Name));
            if (t.Name == 'Economic Summary') this.templateId = String.valueOf(t.ID);
        }
        return options;
    }

    public PageReference save(){
        String transactionState;
        try{
            transactionState = prepareToSave();
        }
        catch(InternalException e){
            System.debug(System.LoggingLevel.ERROR, e);
            pq.addError(e.getMessage());
            return null;
        }
        PageReference ref = doSave(transactionState);
        
        if (pq.ID != null && transactionState != null){
            synchronizeQuoteData(pq.ID, transactionState);
        }
        
        return ref;
    }
    
    @TestVisible
    @Future(callout=true)
    private static void synchronizeQuoteData(ID quoteId, String transactionState){
        System.assertNotEquals(null, quoteId);
        System.assertNotEquals(null, transactionState);
        
        DescribeSObjectResult objDescribe = quoteId.getSObjectType().getDescribe();
        sObject quote = Database.query('SELECT ID, LastModifiedById, LastModifiedDate FROM '
            + objDescribe.getName() + ' WHERE ID = :quoteId LIMIT 1');
        
        IST.SuperTRUMPController.doSaveBlob(UserInfo.getSessionId(),
            String.valueOf(getTimeZoneOffset(DateTime.now())),
            String.valueOf(quoteId),
            '', // sfData - there isn't any
            transactionState,
            String.valueOf(quote.get('LastModifiedById')),
            (DateTime) quote.get('LastModifiedDate'),
            IST.SuperTRUMPServices.getNamespace(objDescribe.getName())
        );
    }
    
    @TestVisible 
    private static Integer getTimeZoneOffset(DateTime dt){
        Integer offset = UserInfo.getTimeZone().getOffset(dt);
        return offset != 0 ? offset / -60000 : offset;
    }
    
    @TestVisible
    private String prepareToSave(){
        DescribeSObjectResult quoteDescribe = pq.getSObjectType().getDescribe();
        if (!isCreateable(quoteDescribe, new List<String>{ 'Schedule__c', 'Template__c' })){
            // don't have permission to create
            throw new InternalException('You don\'t have the required permissions to create a quote.');
        }
        ID curTemplateId;
        if (this.templateId != null){
            curTemplateId = ID.valueOf(this.templateId);
        }
        if (curTemplateId == null){
            throw new InternalException('A SuperTRUMP template is required.');
        }
        if (!isSuperTRUMPTemplate(curTemplateId)){
            // Programmer error that should never happen
            throw new InsertionException('The template id must reference a SuperTRUMP Template');
        }
        String transactionState = getTransactionState(curTemplateId);
        if (transactionState == null){
            throw new InternalException('The data for the selected template could not be retrieved.');
        }
        
        Map<String, sObjectField> quoteFieldMap = quoteDescribe.fields.getMap();
        if (quoteFieldMap.containsKey('stExternalId__c')){
            pq.put('stExternalId__c', 'Z10001transaction');
        }
        else{
            throw new InsertionException('The field \'stExternalId__c\' must be present in the quote object.');
        }
        
        return transactionState;
    }
    
    @TestVisible
    private PageReference doSave(String transactionState){
        System.SavePoint sp = Database.setSavepoint();
        PageReference ref = controller.save();
        // when using controller.save(), the id is not populated to the pq object.
        pq.ID = controller.getId();
        if (pq.ID == null){
            // there was an error in the save
            return null;
        }
        
        if (!createPRM(transactionState)){
            pq.addError('Unable to save initial quote data.');
            Database.rollback(sp);
            return null;
        }
        
        return ref;
    }
    
    @TestVisible
    private String getTransactionState(ID templateId){
        String transactionState;
        try{
            transactionState = IST.SuperTRUMPController.GetTemplateTransactionState(templateId);
        }
        catch(Exception e){
            System.debug(e);
        }
        return transactionState;
    }
    
    @TestVisible
    private boolean createPRM(String transactionState){
        System.assertNotEquals(null, pq, 'The pricing quote cannot be null.');
        System.assertNotEquals(null, pq.ID, 'The pricing quote must have an id to create an attachment.');
        
        DescribeSObjectResult describeAttachment = Schema.sObjectType.Attachment;
        boolean isAttachmentCreateable = isCreateable(describeAttachment, new List<String> { 'Name', 'Body', 'ParentId' });
        if (!isAttachmentCreateable){
            throw new InternalException('You do not have the required permissions to create an Attachment.');
        }
        Blob attachBody = transactionState != null ? System.EncodingUtil.base64Decode(transactionState) : null;
        Attachment quotePRM = new Attachment(
            Name = QUOTE_ATTACHMENT_NAME,
            Body = attachBody,
            ParentId = pq.Id
        );
        try{
            insert quotePRM;
        }
        catch(DMLException e){
            System.debug(System.LoggingLevel.ERROR, e);
            return false;
        }
        return true;
    }
    
    @TestVisible
    private static boolean isSuperTRUMPTemplate(ID templateId){
        String templateObjectName = Schema.sObjectType.IST__SuperTRUMP_Template__c.getName();
        DescribeSObjectResult describeObj = templateId.getSObjectType().getDescribe();
        return (describeObj.getName() == templateObjectName);
    }
    
    @TestVisible
    private static boolean isCreateable(DescribeSObjectResult describeObj, List<String> fieldNames){
        if (!describeObj.isCreateable()) return false;
        
        if (fieldNames != null && fieldNames.size() > 0){
            Map<String, sObjectField> fieldMap = describeObj.fields.getMap();
            for (String fieldName : fieldNames){
                if (fieldMap.containsKey(fieldName) && !fieldMap.get(fieldName).getDescribe().isCreateable()){
                    return false;
                }
            }
        }
        return true;
    }

    @TestVisible
    private class InternalException extends Exception{}

    public class InsertionException extends Exception{}
}