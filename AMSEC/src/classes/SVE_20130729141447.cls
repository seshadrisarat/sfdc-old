global with sharing class SVE_20130729141447 extends SkyEditor2.SkyEditorPageBaseWithSharing {
    
    public Account record {get{return (Account)mainRecord;}}
    public class CanvasException extends Exception {}

    
    
    public Component213 Component213 {get; private set;}
    public Component105 Component105 {get; private set;}
    public Component121 Component121 {get; private set;}
    public Component127 Component127 {get; private set;}
    public Component137 Component137 {get; private set;}
    public Component151 Component151 {get; private set;}
    public Component165 Component165 {get; private set;}
    public Component175 Component175 {get; private set;}
    public Component185 Component185 {get; private set;}
    public Component195 Component195 {get; private set;}
    public SkyEditor2.RecordTypeSelector recordTypeSelector {get; private set;}
    
    public SVE_20130729141447(ApexPages.StandardController controller) {
        super(controller);


        SObjectField f;

        f = Account.fields.Name;
        f = Account.fields.Investor_Name__c;
        f = Account.fields.Alternate_Names__c;
        f = Account.fields.Type;
        f = Account.fields.Description;
        f = Account.fields.ParentId;
        f = Account.fields.Coverage_Level__c;
        f = Account.fields.Short_Company_Name__c;
        f = Account.fields.RecordTypeId;
        f = Account.fields.Specialty__c;
        f = Account.fields.Phone;
        f = Account.fields.Fax;
        f = Account.fields.Website;
        f = Account.fields.Archived__c;
        f = Account.fields.BillingStreet;
        f = Account.fields.BillingCity;
        f = Account.fields.BillingState;
        f = Account.fields.BillingPostalCode;
        f = Account.fields.BillingCountry;
        f = Account.fields.ShippingStreet;
        f = Account.fields.ShippingCity;
        f = Account.fields.ShippingState;
        f = Account.fields.ShippingPostalCode;
        f = Account.fields.ShippingCountry;
        f = Contact.fields.FirstName;
        f = Contact.fields.LastName;
        f = Contact.fields.Title;
        f = Contact.fields.Email;
        f = Contact.fields.Phone;
        f = Account.fields.Consultant__c;
        f = Account.fields.Typical_Commitment__c;
        f = Account.fields.Co_Invest_Interest__c;
        f = Account.fields.Co_Invest_Amount__c;
        f = Account.fields.Co_Invest_Process__c;
        f = Account.fields.Primary_Contact_for_Co_Invest__c;
        f = Account.fields.Secondary_Contact_for_Co_Invest__c;
        f = Account.fields.Mark_for_Deletion__c;
        f = Contact.fields.Name;
        f = Contact.fields.MobilePhone;
        f = Contact.fields.MailingCity;
        f = SA_ADDCTS__Additional_Contact__c.fields.Name;
        f = SA_ADDCTS__Additional_Contact__c.fields.SA_ADDCTS__Role__c;
        f = Industry_Group_Coverage__c.fields.View__c;
        f = Industry_Group_Coverage__c.fields.Industry_Group_Coverage_Level__c;
        f = Industry_Group_Coverage__c.fields.Primary_For_Group__c;
        f = Industry_Group_Coverage__c.fields.Inactive__c;
        f = Address__c.fields.Description__c;
        f = Address__c.fields.Street_Address__c;
        f = Address__c.fields.City__c;
        f = Address__c.fields.State_Province__c;
        f = Address__c.fields.Zip_Postal_Code__c;
        f = Address__c.fields.Country__c;
        f = Amendment_Waiver__c.fields.Name;
        f = Amendment_Waiver__c.fields.Fee__c;
        f = Amendment_Waiver__c.fields.Type__c;
        f = Amendment_Waiver__c.fields.Document_Date__c;
        f = Amendment_Waiver__c.fields.Description__c;
        f = Amendment_Waiver__c.fields.Status__c;
        f = Deal__c.fields.Name;
        f = Deal__c.fields.EBITDA__c;
        f = Deal__c.fields.Final_AS_Stage__c;
        f = Deal__c.fields.Deal_Entry_Date__c;
        f = Deal_Fees__c.fields.Name;
        f = Deal_Fees__c.fields.Fee_Date__c;
        f = Deal_Fees__c.fields.Fee_Type__c;
        f = Deal_Fees__c.fields.Fee_Amount__c;

        List<RecordTypeInfo> recordTypes;
        try {
            mainSObjectType = Account.SObjectType;
            setPageReferenceFactory(new PageReferenceFactory());
            
            recordTypeSelector = new SkyEditor2.RecordTypeSelector(Account.SObjectType);
            
            mainQuery = new SkyEditor2.Query('Account');
            mainQuery.addField('Name');
            mainQuery.addField('Investor_Name__c');
            mainQuery.addField('Alternate_Names__c');
            mainQuery.addField('Type');
            mainQuery.addField('Description');
            mainQuery.addField('ParentId');
            mainQuery.addField('Coverage_Level__c');
            mainQuery.addField('Short_Company_Name__c');
            mainQuery.addField('RecordTypeId');
            mainQuery.addField('Specialty__c');
            mainQuery.addField('Phone');
            mainQuery.addField('Fax');
            mainQuery.addField('Website');
            mainQuery.addField('Archived__c');
            mainQuery.addField('BillingStreet');
            mainQuery.addField('BillingCity');
            mainQuery.addField('BillingState');
            mainQuery.addField('BillingPostalCode');
            mainQuery.addField('BillingCountry');
            mainQuery.addField('ShippingStreet');
            mainQuery.addField('ShippingCity');
            mainQuery.addField('ShippingState');
            mainQuery.addField('ShippingPostalCode');
            mainQuery.addField('ShippingCountry');
            mainQuery.addField('Consultant__c');
            mainQuery.addField('Typical_Commitment__c');
            mainQuery.addField('Co_Invest_Interest__c');
            mainQuery.addField('Co_Invest_Amount__c');
            mainQuery.addField('Co_Invest_Process__c');
            mainQuery.addField('Primary_Contact_for_Co_Invest__c');
            mainQuery.addField('Secondary_Contact_for_Co_Invest__c');
            mainQuery.addField('Mark_for_Deletion__c');
            mainQuery.addFieldAsOutput('RecordTypeId');
            mainQuery.addWhere('Id', mainRecord.Id, SkyEditor2.WhereOperator.Eq)
                .limitRecords(1);
            
            
            
            mode = SkyEditor2.LayoutMode.LayoutSalesforce; 
            
            queryMap = new Map<String, SkyEditor2.Query>();
            SkyEditor2.Query query;
            
            Component213 = new Component213(new List<Contact>(), new List<Component213Item>(), new List<Contact>(), null);
            listItemHolders.put('Component213', Component213);
            query = new SkyEditor2.Query('Contact');
            query.addField('FirstName');
            query.addField('LastName');
            query.addField('Title');
            query.addField('Email');
            query.addField('Phone');
            query.addFieldAsOutput('RecordTypeId');
            query.addWhere('AccountId', mainRecord.Id, SkyEditor2.WhereOperator.Eq);
            relationFields.put('Component213', 'AccountId');
            Component213.queryRelatedEvent = False;
            query.limitRecords(500);
            queryMap.put('Component213', query);
            
            Component105 = new Component105(new List<Contact>(), new List<Component105Item>(), new List<Contact>(), null);
            listItemHolders.put('Component105', Component105);
            query = new SkyEditor2.Query('Contact');
            query.addField('Title');
            query.addField('Phone');
            query.addField('MobilePhone');
            query.addField('Email');
            query.addField('MailingCity');
            query.addField('LastName');
            query.addFieldAsOutput('Name');
            query.addFieldAsOutput('RecordTypeId');
            query.addWhere('AccountId', mainRecord.Id, SkyEditor2.WhereOperator.Eq);
            relationFields.put('Component105', 'AccountId');
            Component105.queryRelatedEvent = False;
            query.limitRecords(500);
            queryMap.put('Component105', query);
            
            Component121 = new Component121(new List<SA_ADDCTS__Additional_Contact__c>(), new List<Component121Item>(), new List<SA_ADDCTS__Additional_Contact__c>(), null);
            listItemHolders.put('Component121', Component121);
            query = new SkyEditor2.Query('SA_ADDCTS__Additional_Contact__c');
            query.addField('SA_ADDCTS__Role__c');
            query.addFieldAsOutput('Name');
            query.addWhere('SA_ADDCTS__Account__c', mainRecord.Id, SkyEditor2.WhereOperator.Eq);
            relationFields.put('Component121', 'SA_ADDCTS__Account__c');
            Component121.queryRelatedEvent = False;
            query.limitRecords(500);
            queryMap.put('Component121', query);
            
            Component127 = new Component127(new List<Industry_Group_Coverage__c>(), new List<Component127Item>(), new List<Industry_Group_Coverage__c>(), null);
            listItemHolders.put('Component127', Component127);
            query = new SkyEditor2.Query('Industry_Group_Coverage__c');
            query.addField('Industry_Group_Coverage_Level__c');
            query.addField('Primary_For_Group__c');
            query.addField('Inactive__c');
            query.addFieldAsOutput('View__c');
            query.addWhere('Company_Contact__c', mainRecord.Id, SkyEditor2.WhereOperator.Eq);
            relationFields.put('Component127', 'Company_Contact__c');
            Component127.queryRelatedEvent = False;
            query.limitRecords(500);
            queryMap.put('Component127', query);
            
            Component137 = new Component137(new List<Address__c>(), new List<Component137Item>(), new List<Address__c>(), null);
            listItemHolders.put('Component137', Component137);
            query = new SkyEditor2.Query('Address__c');
            query.addField('Description__c');
            query.addField('Street_Address__c');
            query.addField('City__c');
            query.addField('State_Province__c');
            query.addField('Zip_Postal_Code__c');
            query.addField('Country__c');
            query.addFieldAsOutput('RecordTypeId');
            query.addWhere('Account__c', mainRecord.Id, SkyEditor2.WhereOperator.Eq);
            relationFields.put('Component137', 'Account__c');
            Component137.queryRelatedEvent = False;
            query.limitRecords(500);
            queryMap.put('Component137', query);
            
            Component151 = new Component151(new List<Amendment_Waiver__c>(), new List<Component151Item>(), new List<Amendment_Waiver__c>(), null);
            listItemHolders.put('Component151', Component151);
            query = new SkyEditor2.Query('Amendment_Waiver__c');
            query.addField('Fee__c');
            query.addField('Type__c');
            query.addField('Document_Date__c');
            query.addField('Description__c');
            query.addField('Status__c');
            query.addFieldAsOutput('Name');
            query.addWhere('Lender__c', mainRecord.Id, SkyEditor2.WhereOperator.Eq);
            relationFields.put('Component151', 'Lender__c');
            Component151.queryRelatedEvent = False;
            query.limitRecords(500);
            queryMap.put('Component151', query);
            
            Component165 = new Component165(new List<Deal__c>(), new List<Component165Item>(), new List<Deal__c>(), null);
            listItemHolders.put('Component165', Component165);
            query = new SkyEditor2.Query('Deal__c');
            query.addField('Name');
            query.addField('EBITDA__c');
            query.addField('Final_AS_Stage__c');
            query.addField('Deal_Entry_Date__c');
            query.addFieldAsOutput('RecordTypeId');
            query.addWhere('Co_Source_Company__c', mainRecord.Id, SkyEditor2.WhereOperator.Eq);
            relationFields.put('Component165', 'Co_Source_Company__c');
            Component165.queryRelatedEvent = False;
            query.limitRecords(500);
            queryMap.put('Component165', query);
            
            Component175 = new Component175(new List<Deal__c>(), new List<Component175Item>(), new List<Deal__c>(), null);
            listItemHolders.put('Component175', Component175);
            query = new SkyEditor2.Query('Deal__c');
            query.addField('Name');
            query.addField('EBITDA__c');
            query.addField('Final_AS_Stage__c');
            query.addField('Deal_Entry_Date__c');
            query.addFieldAsOutput('RecordTypeId');
            query.addWhere('Co_Source_Company__c', mainRecord.Id, SkyEditor2.WhereOperator.Eq);
            relationFields.put('Component175', 'Co_Source_Company__c');
            Component175.queryRelatedEvent = False;
            query.limitRecords(500);
            queryMap.put('Component175', query);
            
            Component185 = new Component185(new List<Deal__c>(), new List<Component185Item>(), new List<Deal__c>(), null);
            listItemHolders.put('Component185', Component185);
            query = new SkyEditor2.Query('Deal__c');
            query.addField('Name');
            query.addField('EBITDA__c');
            query.addField('Final_AS_Stage__c');
            query.addField('Deal_Entry_Date__c');
            query.addFieldAsOutput('RecordTypeId');
            query.addWhere('Co_Source_Company__c', mainRecord.Id, SkyEditor2.WhereOperator.Eq);
            relationFields.put('Component185', 'Co_Source_Company__c');
            Component185.queryRelatedEvent = False;
            query.limitRecords(500);
            queryMap.put('Component185', query);
            
            Component195 = new Component195(new List<Deal_Fees__c>(), new List<Component195Item>(), new List<Deal_Fees__c>(), null);
            listItemHolders.put('Component195', Component195);
            query = new SkyEditor2.Query('Deal_Fees__c');
            query.addField('Fee_Date__c');
            query.addField('Fee_Type__c');
            query.addField('Fee_Amount__c');
            query.addFieldAsOutput('Name');
            query.addWhere('Fee_Paid_To__c', mainRecord.Id, SkyEditor2.WhereOperator.Eq);
            relationFields.put('Component195', 'Fee_Paid_To__c');
            Component195.queryRelatedEvent = False;
            query.limitRecords(500);
            queryMap.put('Component195', query);
            
            registRelatedList('Contacts', 'Component213');
            registRelatedList('Contacts', 'Component105');
            registRelatedList('SA_ADDCTS__Additional_Contacts__r', 'Component121');
            registRelatedList('Industry_Coverages_Company2__pr', 'Component127');
            registRelatedList('Addresses__r', 'Component137');
            registRelatedList('Amendments_Waivers__r', 'Component151');
            registRelatedList('Deals_Co_Source__r', 'Component165');
            registRelatedList('Deals_Co_Source__r', 'Component175');
            registRelatedList('Deals_Co_Source__r', 'Component185');
            registRelatedList('Deal_Fees__r', 'Component195');
            
            addInheritParameter('RecordTypeId', 'RecordType');
            init();
            
            Component213.extender = this.extender;
            Component105.extender = this.extender;
            Component121.extender = this.extender;
            Component127.extender = this.extender;
            Component137.extender = this.extender;
            Component151.extender = this.extender;
            Component165.extender = this.extender;
            Component175.extender = this.extender;
            Component185.extender = this.extender;
            Component195.extender = this.extender;
            if (record.Id == null) {
                
                saveOldValues();
                
                if(record.RecordTypeId == null) recordTypeSelector.applyDefault(record);
                
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
    
    private static testMethod void testPageMethods() {        SVE_20130729141447 extension = new SVE_20130729141447(new ApexPages.StandardController(new Account()));
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
    global class Component213Item extends SkyEditor2.ListItem {
        public Contact record{get; private set;}
        Component213Item(Component213 holder, Contact record, SkyEditor2.RecordTypeSelector recordTypeSelector) {
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
    global class Component213 extends SkyEditor2.ListItemHolder {
        public List<Component213Item> items{get; private set;}
        Component213(List<SObject> records, List<SkyEditor2.ListItem> items, List<SObject> deleteRecords, SkyEditor2.RecordTypeSelector recordTypeSelector) {
            super(records, items, deleteRecords, recordTypeSelector);
            this.items = (List<Component213Item>)items;
        }
        global override SkyEditor2.ListItem create(SObject data) {
            return new Component213Item(this, (Contact)data, recordTypeSelector);
        }
    }
    private static testMethod void testComponent213() {
        Component213 Component213 = new Component213(new List<Contact>(), new List<Component213Item>(), new List<Contact>(), null);
        Component213.create(new Contact());
    }
    
    global class Component105Item extends SkyEditor2.ListItem {
        public Contact record{get; private set;}
        Component105Item(Component105 holder, Contact record, SkyEditor2.RecordTypeSelector recordTypeSelector) {
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
    global class Component105 extends SkyEditor2.ListItemHolder {
        public List<Component105Item> items{get; private set;}
        Component105(List<SObject> records, List<SkyEditor2.ListItem> items, List<SObject> deleteRecords, SkyEditor2.RecordTypeSelector recordTypeSelector) {
            super(records, items, deleteRecords, recordTypeSelector);
            this.items = (List<Component105Item>)items;
        }
        global override SkyEditor2.ListItem create(SObject data) {
            return new Component105Item(this, (Contact)data, recordTypeSelector);
        }
    }
    private static testMethod void testComponent105() {
        Component105 Component105 = new Component105(new List<Contact>(), new List<Component105Item>(), new List<Contact>(), null);
        Component105.create(new Contact());
    }
    
    global class Component121Item extends SkyEditor2.ListItem {
        public SA_ADDCTS__Additional_Contact__c record{get; private set;}
        Component121Item(Component121 holder, SA_ADDCTS__Additional_Contact__c record, SkyEditor2.RecordTypeSelector recordTypeSelector) {
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
    global class Component121 extends SkyEditor2.ListItemHolder {
        public List<Component121Item> items{get; private set;}
        Component121(List<SObject> records, List<SkyEditor2.ListItem> items, List<SObject> deleteRecords, SkyEditor2.RecordTypeSelector recordTypeSelector) {
            super(records, items, deleteRecords, recordTypeSelector);
            this.items = (List<Component121Item>)items;
        }
        global override SkyEditor2.ListItem create(SObject data) {
            return new Component121Item(this, (SA_ADDCTS__Additional_Contact__c)data, recordTypeSelector);
        }
    }
    private static testMethod void testComponent121() {
        Component121 Component121 = new Component121(new List<SA_ADDCTS__Additional_Contact__c>(), new List<Component121Item>(), new List<SA_ADDCTS__Additional_Contact__c>(), null);
        Component121.create(new SA_ADDCTS__Additional_Contact__c());
    }
    
    global class Component127Item extends SkyEditor2.ListItem {
        public Industry_Group_Coverage__c record{get; private set;}
        Component127Item(Component127 holder, Industry_Group_Coverage__c record, SkyEditor2.RecordTypeSelector recordTypeSelector) {
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
    global class Component127 extends SkyEditor2.ListItemHolder {
        public List<Component127Item> items{get; private set;}
        Component127(List<SObject> records, List<SkyEditor2.ListItem> items, List<SObject> deleteRecords, SkyEditor2.RecordTypeSelector recordTypeSelector) {
            super(records, items, deleteRecords, recordTypeSelector);
            this.items = (List<Component127Item>)items;
        }
        global override SkyEditor2.ListItem create(SObject data) {
            return new Component127Item(this, (Industry_Group_Coverage__c)data, recordTypeSelector);
        }
    }
    private static testMethod void testComponent127() {
        Component127 Component127 = new Component127(new List<Industry_Group_Coverage__c>(), new List<Component127Item>(), new List<Industry_Group_Coverage__c>(), null);
        Component127.create(new Industry_Group_Coverage__c());
    }
    
    global class Component137Item extends SkyEditor2.ListItem {
        public Address__c record{get; private set;}
        Component137Item(Component137 holder, Address__c record, SkyEditor2.RecordTypeSelector recordTypeSelector) {
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
    global class Component137 extends SkyEditor2.ListItemHolder {
        public List<Component137Item> items{get; private set;}
        Component137(List<SObject> records, List<SkyEditor2.ListItem> items, List<SObject> deleteRecords, SkyEditor2.RecordTypeSelector recordTypeSelector) {
            super(records, items, deleteRecords, recordTypeSelector);
            this.items = (List<Component137Item>)items;
        }
        global override SkyEditor2.ListItem create(SObject data) {
            return new Component137Item(this, (Address__c)data, recordTypeSelector);
        }
    }
    private static testMethod void testComponent137() {
        Component137 Component137 = new Component137(new List<Address__c>(), new List<Component137Item>(), new List<Address__c>(), null);
        Component137.create(new Address__c());
    }
    
    global class Component151Item extends SkyEditor2.ListItem {
        public Amendment_Waiver__c record{get; private set;}
        Component151Item(Component151 holder, Amendment_Waiver__c record, SkyEditor2.RecordTypeSelector recordTypeSelector) {
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
    global class Component151 extends SkyEditor2.ListItemHolder {
        public List<Component151Item> items{get; private set;}
        Component151(List<SObject> records, List<SkyEditor2.ListItem> items, List<SObject> deleteRecords, SkyEditor2.RecordTypeSelector recordTypeSelector) {
            super(records, items, deleteRecords, recordTypeSelector);
            this.items = (List<Component151Item>)items;
        }
        global override SkyEditor2.ListItem create(SObject data) {
            return new Component151Item(this, (Amendment_Waiver__c)data, recordTypeSelector);
        }
    }
    private static testMethod void testComponent151() {
        Component151 Component151 = new Component151(new List<Amendment_Waiver__c>(), new List<Component151Item>(), new List<Amendment_Waiver__c>(), null);
        Component151.create(new Amendment_Waiver__c());
    }
    
    global class Component165Item extends SkyEditor2.ListItem {
        public Deal__c record{get; private set;}
        Component165Item(Component165 holder, Deal__c record, SkyEditor2.RecordTypeSelector recordTypeSelector) {
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
    global class Component165 extends SkyEditor2.ListItemHolder {
        public List<Component165Item> items{get; private set;}
        Component165(List<SObject> records, List<SkyEditor2.ListItem> items, List<SObject> deleteRecords, SkyEditor2.RecordTypeSelector recordTypeSelector) {
            super(records, items, deleteRecords, recordTypeSelector);
            this.items = (List<Component165Item>)items;
        }
        global override SkyEditor2.ListItem create(SObject data) {
            return new Component165Item(this, (Deal__c)data, recordTypeSelector);
        }
    }
    private static testMethod void testComponent165() {
        Component165 Component165 = new Component165(new List<Deal__c>(), new List<Component165Item>(), new List<Deal__c>(), null);
        Component165.create(new Deal__c());
    }
    
    global class Component175Item extends SkyEditor2.ListItem {
        public Deal__c record{get; private set;}
        Component175Item(Component175 holder, Deal__c record, SkyEditor2.RecordTypeSelector recordTypeSelector) {
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
    global class Component175 extends SkyEditor2.ListItemHolder {
        public List<Component175Item> items{get; private set;}
        Component175(List<SObject> records, List<SkyEditor2.ListItem> items, List<SObject> deleteRecords, SkyEditor2.RecordTypeSelector recordTypeSelector) {
            super(records, items, deleteRecords, recordTypeSelector);
            this.items = (List<Component175Item>)items;
        }
        global override SkyEditor2.ListItem create(SObject data) {
            return new Component175Item(this, (Deal__c)data, recordTypeSelector);
        }
    }
    private static testMethod void testComponent175() {
        Component175 Component175 = new Component175(new List<Deal__c>(), new List<Component175Item>(), new List<Deal__c>(), null);
        Component175.create(new Deal__c());
    }
    
    global class Component185Item extends SkyEditor2.ListItem {
        public Deal__c record{get; private set;}
        Component185Item(Component185 holder, Deal__c record, SkyEditor2.RecordTypeSelector recordTypeSelector) {
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
    global class Component185 extends SkyEditor2.ListItemHolder {
        public List<Component185Item> items{get; private set;}
        Component185(List<SObject> records, List<SkyEditor2.ListItem> items, List<SObject> deleteRecords, SkyEditor2.RecordTypeSelector recordTypeSelector) {
            super(records, items, deleteRecords, recordTypeSelector);
            this.items = (List<Component185Item>)items;
        }
        global override SkyEditor2.ListItem create(SObject data) {
            return new Component185Item(this, (Deal__c)data, recordTypeSelector);
        }
    }
    private static testMethod void testComponent185() {
        Component185 Component185 = new Component185(new List<Deal__c>(), new List<Component185Item>(), new List<Deal__c>(), null);
        Component185.create(new Deal__c());
    }
    
    global class Component195Item extends SkyEditor2.ListItem {
        public Deal_Fees__c record{get; private set;}
        Component195Item(Component195 holder, Deal_Fees__c record, SkyEditor2.RecordTypeSelector recordTypeSelector) {
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
    global class Component195 extends SkyEditor2.ListItemHolder {
        public List<Component195Item> items{get; private set;}
        Component195(List<SObject> records, List<SkyEditor2.ListItem> items, List<SObject> deleteRecords, SkyEditor2.RecordTypeSelector recordTypeSelector) {
            super(records, items, deleteRecords, recordTypeSelector);
            this.items = (List<Component195Item>)items;
        }
        global override SkyEditor2.ListItem create(SObject data) {
            return new Component195Item(this, (Deal_Fees__c)data, recordTypeSelector);
        }
    }
    private static testMethod void testComponent195() {
        Component195 Component195 = new Component195(new List<Deal_Fees__c>(), new List<Component195Item>(), new List<Deal_Fees__c>(), null);
        Component195.create(new Deal_Fees__c());
    }
    
    class PageReferenceFactory implements SkyEditor2.PageReferenceFactory.Implementation {
        public PageReference newPageReference(String url) {
            PageReference ref = new PageReference(url);
            ref.setRedirect(true);
            return ref;
        }
    }
}