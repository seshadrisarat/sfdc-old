global with sharing class ChangeAddress extends SkyEditor2.SkyEditorPageBaseWithSharing {
    
    public Account record {get{return (Account)mainRecord;}}
    public class CanvasException extends Exception {}

    
    
    public Component10 Component10 {get; private set;}
    public ChangeAddress(ApexPages.StandardController controller) {
        super(controller);


        SObjectField f;

        f = Account.fields.BillingStreet;
        f = Account.fields.BillingCity;
        f = Account.fields.BillingState;
        f = Account.fields.BillingPostalCode;
        f = Account.fields.ShippingStreet;
        f = Account.fields.ShippingCity;
        f = Account.fields.ShippingState;
        f = Account.fields.ShippingPostalCode;
        f = Contact.fields.Name;
        f = Contact.fields.Record_Status_Contact__c;
        f = Contact.fields.MailingStreet;
        f = Contact.fields.MailingCity;
        f = Contact.fields.MailingState;
        f = Contact.fields.MailingPostalCode;

        List<RecordTypeInfo> recordTypes;
        try {
            mainSObjectType = Account.SObjectType;
            setPageReferenceFactory(new PageReferenceFactory());
            
            mainQuery = new SkyEditor2.Query('Account');
            mainQuery.addFieldAsOutput('Name');
            mainQuery.addFieldAsOutput('RecordTypeId');
            mainQuery.addFieldAsOutput('BillingStreet');
            mainQuery.addFieldAsOutput('BillingCity');
            mainQuery.addFieldAsOutput('BillingState');
            mainQuery.addFieldAsOutput('BillingPostalCode');
            mainQuery.addFieldAsOutput('ShippingStreet');
            mainQuery.addFieldAsOutput('ShippingCity');
            mainQuery.addFieldAsOutput('ShippingState');
            mainQuery.addFieldAsOutput('ShippingPostalCode');
            mainQuery.addWhere('Id', mainRecord.Id, SkyEditor2.WhereOperator.Eq)
                .limitRecords(1);
            
            
            
            mode = SkyEditor2.LayoutMode.LayoutSalesforce; 
            
            queryMap = new Map<String, SkyEditor2.Query>();
            SkyEditor2.Query query;
            
            Component10 = new Component10(new List<Contact>(), new List<Component10Item>(), new List<Contact>(), null);
            listItemHolders.put('Component10', Component10);
            query = new SkyEditor2.Query('Contact');
            query.addField('MailingStreet');
            query.addField('MailingCity');
            query.addField('MailingState');
            query.addField('MailingPostalCode');
            query.addFieldAsOutput('Name');
            query.addFieldAsOutput('Record_Status_Contact__c');
            query.addFieldAsOutput('RecordTypeId');
            query.addWhere('AccountId', mainRecord.Id, SkyEditor2.WhereOperator.Eq);
            relationFields.put('Component10', 'AccountId');
            Component10.queryRelatedEvent = False;
            query.limitRecords(500 + 1);
            queryMap.put('Component10', query);
            
            registRelatedList('Contacts', 'Component10');
            
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
    
    private static testMethod void testPageMethods() {        ChangeAddress extension = new ChangeAddress(new ApexPages.StandardController(new Account()));
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

        defaultSize = extension.Component10.items.size();
        extension.Component10.add();                               
        System.assertEquals(defaultSize + 1, extension.Component10.items.size());
        extension.Component10.items[defaultSize].selected = true;
        extension.callRemove_Component10();
        System.assertEquals(defaultSize, extension.Component10.items.size());
    }
    global class Component10Item extends SkyEditor2.ListItem {
        public Contact record{get; private set;}
        Component10Item(Component10 holder, Contact record, SkyEditor2.RecordTypeSelector recordTypeSelector) {
            super(holder);
            if (record.Id == null  && record.RecordTypeId == null){
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
            return new Component10Item(this, (Contact)data, recordTypeSelector);
        }
    }
    private static testMethod void testComponent10() {
        Component10 Component10 = new Component10(new List<Contact>(), new List<Component10Item>(), new List<Contact>(), null);
        Component10.create(new Contact());
    }
    
    public Contact Component10_table_Conversion { get { return new Contact();}}
    
    public String Component10_table_selectval { get; set; }
    
     public void callRemove_Component10() {
          for(Integer i = Component10.items.size() - 1; i >= 0; i--){
               Component10Item item = Component10.items[i];
               if(item.selected){
                    item.remove();
               }
          }
     }
    
    class PageReferenceFactory implements SkyEditor2.PageReferenceFactory.Implementation {
        public PageReference newPageReference(String url) {
            return new PageReference(url);
        }
    }
}