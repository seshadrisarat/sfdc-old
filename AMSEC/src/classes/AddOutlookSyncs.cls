global with sharing class AddOutlookSyncs extends SkyEditor2.SkyEditorPageBaseWithSharing {
    
    public Contact record {get{return (Contact)mainRecord;}}
    public class CanvasException extends Exception {}

    
    
    public Component10 Component10 {get; private set;}
    public AddOutlookSyncs(ApexPages.StandardController controller) {
        super(controller);


        SObjectField f;

        f = Contact.fields.Outlook_Mobile_Sync__c;
        f = Outlook_Sync__c.fields.User_Alias__c;
        f = Outlook_Sync__c.fields.Personal_Contact__c;

        List<RecordTypeInfo> recordTypes;
        try {
            mainSObjectType = Contact.SObjectType;
            setPageReferenceFactory(new PageReferenceFactory());
            
            mainQuery = new SkyEditor2.Query('Contact');
            mainQuery.addFieldAsOutput('Name');
            mainQuery.addFieldAsOutput('RecordTypeId');
            mainQuery.addFieldAsOutput('Outlook_Mobile_Sync__c');
            mainQuery.addWhere('Id', mainRecord.Id, SkyEditor2.WhereOperator.Eq)
                .limitRecords(1);
            
            
            
            mode = SkyEditor2.LayoutMode.LayoutSalesforce; 
            
            queryMap = new Map<String, SkyEditor2.Query>();
            SkyEditor2.Query query;
            
            Component10 = new Component10(new List<Outlook_Sync__c>(), new List<Component10Item>(), new List<Outlook_Sync__c>(), null);
            listItemHolders.put('Component10', Component10);
            query = new SkyEditor2.Query('Outlook_Sync__c');
            query.addField('User_Alias__c');
            query.addField('Personal_Contact__c');
            query.addWhere('Contact__c', mainRecord.Id, SkyEditor2.WhereOperator.Eq);
            relationFields.put('Component10', 'Contact__c');
            Component10.queryRelatedEvent = False;
            query.limitRecords(500);
            queryMap.put('Component10', query);
            
            registRelatedList('Outlook_Sync__r', 'Component10');
            
            addInheritParameter('RecordTypeId', 'RecordType');
            init();
            
            Component10.extender = this.extender;
            if (record.Id == null) {
                
                saveOldValues();
                
            }

            
            
        }  catch (SkyEditor2.Errors.FieldNotFoundException e) {
            fieldNotFound(e);
        } catch (SkyEditor2.Errors.RecordNotFoundException e) {
            recordNotFound(e);
        } catch (SkyEditor2.ExtenderException e) {
            e.setMessagesToPage();
        }
    }
    

    private void sObjectNotFound(SkyEditor2.Errors.SObjectNotFoundException e) {
        SkyEditor2.Messages.addErrorMessage(e.getMessage());
        hidePageBody = true;
    }
    private void fieldNotFound(SkyEditor2.Errors.FieldNotFoundException e) {
        SkyEditor2.Messages.addErrorMessage(e.getMessage());
        hidePageBody = true;
    }
    private void recordNotFound(SkyEditor2.Errors.RecordNotFoundException e) {
        SkyEditor2.Messages.addErrorMessage(e.getMessage());
        hidePageBody = true;
    }
    
    private static testMethod void testPageMethods() {        AddOutlookSyncs extension = new AddOutlookSyncs(new ApexPages.StandardController(new Contact()));
        SkyEditor2.Messages.clear();
        extension.sObjectNotFound(new SkyEditor2.Errors.SObjectNotFoundException(SkyEditor2.Messages.sObjectNotFound('SkyEditor2__SkyEditorDummy__c')));
        System.assert(extension.getErrorMessages().endsWith(SkyEditor2.Messages.sObjectNotFound('SkyEditor2__SkyEditorDummy__c')));
        SkyEditor2.Messages.clear();
        extension.fieldNotFound(new SkyEditor2.Errors.FieldNotFoundException(SkyEditor2.Messages.fieldNotFound(SkyEditor2__SkyEditorDummy__c.SObjectType, 'Name')));
        System.assert(extension.getErrorMessages().endsWith(SkyEditor2.Messages.fieldNotFound(SkyEditor2__SkyEditorDummy__c.SObjectType, 'Name')));
        SkyEditor2.Messages.clear();
        extension.recordNotFound(new SkyEditor2.Errors.RecordNotFoundException(SkyEditor2.Messages.DATA_NOT_FOUND));
        System.assert(extension.getErrorMessages().endsWith(SkyEditor2.Messages.DATA_NOT_FOUND));

        Integer defaultSize;
    }
    global class Component10Item extends SkyEditor2.ListItem {
        public Outlook_Sync__c record{get; private set;}
        Component10Item(Component10 holder, Outlook_Sync__c record, SkyEditor2.RecordTypeSelector recordTypeSelector) {
            super(holder);
            if (record.Id == null ){
                if (recordTypeSelector != null) {
                    recordTypeSelector.applyDefault(record);
                }
                
            }
            this.record = record;
        }
        global override SObject getRecord() {return record;}
    }
    global class Component10 extends SkyEditor2.ListItemHolder {
        public List<Component10Item> items{get; private set;}
        Component10(List<SObject> records, List<SkyEditor2.ListItem> items, List<SObject> deleteRecords, SkyEditor2.RecordTypeSelector recordTypeSelector) {
            super(records, items, deleteRecords, recordTypeSelector);
            this.items = (List<Component10Item>)items;
        }
        global override SkyEditor2.ListItem create(SObject data) {
            return new Component10Item(this, (Outlook_Sync__c)data, recordTypeSelector);
        }
    }
    private static testMethod void testComponent10() {
        Component10 Component10 = new Component10(new List<Outlook_Sync__c>(), new List<Component10Item>(), new List<Outlook_Sync__c>(), null);
        Component10.create(new Outlook_Sync__c());
    }
    
    class PageReferenceFactory implements SkyEditor2.PageReferenceFactory.Implementation {
        public PageReference newPageReference(String url) {
            return new PageReference(url);
        }
    }
}