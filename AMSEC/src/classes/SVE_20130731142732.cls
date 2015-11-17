global with sharing class SVE_20130731142732 extends SkyEditor2.SkyEditorPageBaseWithSharing {
    
    public Deal__c record {get{return (Deal__c)mainRecord;}}
    public class CanvasException extends Exception {}

    
    
    public Component366 Component366 {get; private set;}
    public Component388 Component388 {get; private set;}
    public Component405 Component405 {get; private set;}
    public Component419 Component419 {get; private set;}
    public Component431 Component431 {get; private set;}
    public SVE_20130731142732(ApexPages.StandardController controller) {
        super(controller);


        SObjectField f;

        f = Deal__c.fields.Next_Steps__c;
        f = Financing_Proposal__c.fields.Lender__c;
        f = Financing_Proposal__c.fields.View__c;
        f = Financing_Proposal__c.fields.Hold__c;
        f = Financing_Proposal__c.fields.Early_Leverage__c;
        f = Financing_Proposal__c.fields.Early_OID__c;
        f = Financing_Proposal__c.fields.Flex__c;
        f = Financing_Proposal__c.fields.Early_Floor__c;
        f = Financing_Proposal__c.fields.Early_LIBOR_Spread__c;
        f = Final_Financing__c.fields.View__c;
        f = Final_Financing__c.fields.Lender__c;
        f = Final_Financing__c.fields.Primary_Contact__c;
        f = Final_Financing__c.fields.Initial_Hold__c;
        f = Final_Financing__c.fields.Current_Hold__c;
        f = Final_Financing__c.fields.Allocation__c;
        f = Final_Financing__c.fields.Commitment__c;
        f = Final_Financing__c.fields.Status__c;
        f = Deal_Fees__c.fields.View__c;
        f = Deal_Fees__c.fields.Fee_Paid_To__c;
        f = Deal_Fees__c.fields.Fee_Type__c;
        f = Deal_Fees__c.fields.Fee_Date__c;
        f = Deal_Fees__c.fields.Fee_Amount__c;
        f = Deal_Fees__c.fields.Comments__c;
        f = External_Working_Group_Member__c.fields.View__c;
        f = External_Working_Group_Member__c.fields.Contact__c;
        f = External_Working_Group_Member__c.fields.Company__c;
        f = External_Working_Group_Member__c.fields.Role__c;
        f = External_Working_Group_Member__c.fields.Notes__c;
        f = Amendment_Waiver__c.fields.View__c;
        f = Amendment_Waiver__c.fields.Lender__c;
        f = Amendment_Waiver__c.fields.Description__c;
        f = Amendment_Waiver__c.fields.Type__c;
        f = Amendment_Waiver__c.fields.Status__c;
        f = Amendment_Waiver__c.fields.Notes__c;
        f = Deal__c.fields.Description__c;
        f = Deal__c.fields.Name;
        f = Deal__c.fields.Project_Name__c;
        f = Deal__c.fields.Industry_Deal__c;
        f = Deal__c.fields.Deal_Process__c;
        f = Deal__c.fields.Deal_Status__c;
        f = Deal__c.fields.Final_AS_Stage__c;
        f = Deal__c.fields.Sales__c;
        f = Deal__c.fields.EBITDA__c;
        f = Deal__c.fields.Free_Cash_Flow__c;
        f = Deal__c.fields.Salesforce_Company__c;
        f = Deal__c.fields.Headquarters__c;
        f = Deal__c.fields.Owner__c;
        f = Deal__c.fields.Currency__c;
        f = Deal__c.fields.Publicly_Traded__c;
        f = Deal__c.fields.Ticker__c;
        f = Deal__c.fields.Idea_Company__c;
        f = Deal__c.fields.Idea_Contact__c;
        f = Deal__c.fields.Idea_Phone__c;
        f = Deal__c.fields.Idea_Co_Type__c;
        f = Deal__c.fields.Add_Idea_Companies__c;
        f = Deal__c.fields.Idea_Quality__c;
        f = Deal__c.fields.Idea_Transacted__c;
        f = Deal__c.fields.Deal_Entry_Date__c;
        f = Deal__c.fields.Source_Company__c;
        f = Deal__c.fields.Source_Contact__c;
        f = Deal__c.fields.Source_Phone__c;
        f = Deal__c.fields.Source_Co_Type__c;
        f = Deal__c.fields.Co_Source_Company__c;
        f = Deal__c.fields.Co_Source_Contact__c;
        f = Deal__c.fields.Co_Source_Phone__c;
        f = Deal__c.fields.Co_Source_Co_Type__c;
        f = Deal__c.fields.Deal_Quality__c;
        f = Deal__c.fields.Add_Source_Companies__c;
        f = Deal__c.fields.Early_Look__c;
        f = Deal__c.fields.Deal_Launch_Date__c;
        f = Deal__c.fields.Initial_Bid_From__c;
        f = Deal__c.fields.Second_Round_Guidance__c;
        f = Deal__c.fields.Initial_Bid_From_Multiple__c;
        f = Deal__c.fields.Second_Round_Guidance_Multiple__c;
        f = Deal__c.fields.Initial_Bid_To__c;
        f = Deal__c.fields.Final_Bid__c;
        f = Deal__c.fields.Initial_Bid_To_Multiple__c;
        f = Deal__c.fields.Final_Bid_Multiple__c;
        f = Deal__c.fields.Bid_Date__c;
        f = Deal__c.fields.AS_Team__c;
        f = Deal__c.fields.AS_Resources__c;
        f = Deal__c.fields.Fireside_Chat__c;
        f = Deal__c.fields.Process_Status__c;
        f = Deal__c.fields.CA_Status__c;
        f = Deal__c.fields.Buyer__c;
        f = Deal__c.fields.Reason_AS_Passed__c;
        f = Deal__c.fields.Notes__c;
        f = Deal__c.fields.Close_Date__c;
        f = Deal__c.fields.Purchase_Price__c;
        f = Deal__c.fields.Total_Fees__c;
        f = Deal__c.fields.Fund__c;
        f = Deal__c.fields.Issuer_Name_ID__c;
        f = Deal__c.fields.Current_Hold_Total__c;
        f = Deal__c.fields.Financing_Size__c;
        f = Deal__c.fields.Bank_Meeting_Date__c;
        f = Deal__c.fields.Update_Call_Date__c;
        f = Deal__c.fields.S_P_Meeting_Date__c;
        f = Deal__c.fields.S_P_Update_Call_Date__c;
        f = Deal__c.fields.Moodys_Meeting_Date__c;
        f = Deal__c.fields.Moodys_Update_Call_Date__c;

        List<RecordTypeInfo> recordTypes;
        try {
            mainSObjectType = Deal__c.SObjectType;
            setPageReferenceFactory(new PageReferenceFactory());
            
            mainQuery = new SkyEditor2.Query('Deal__c');
            mainQuery.addFieldAsOutput('RecordTypeId');
            mainQuery.addFieldAsOutput('Next_Steps__c');
            mainQuery.addFieldAsOutput('Description__c');
            mainQuery.addFieldAsOutput('Name');
            mainQuery.addFieldAsOutput('Project_Name__c');
            mainQuery.addFieldAsOutput('Industry_Deal__c');
            mainQuery.addFieldAsOutput('Deal_Process__c');
            mainQuery.addFieldAsOutput('Deal_Status__c');
            mainQuery.addFieldAsOutput('Final_AS_Stage__c');
            mainQuery.addFieldAsOutput('Sales__c');
            mainQuery.addFieldAsOutput('EBITDA__c');
            mainQuery.addFieldAsOutput('Free_Cash_Flow__c');
            mainQuery.addFieldAsOutput('Salesforce_Company__c');
            mainQuery.addFieldAsOutput('Headquarters__c');
            mainQuery.addFieldAsOutput('Owner__c');
            mainQuery.addFieldAsOutput('Currency__c');
            mainQuery.addFieldAsOutput('Publicly_Traded__c');
            mainQuery.addFieldAsOutput('Ticker__c');
            mainQuery.addFieldAsOutput('Idea_Company__c');
            mainQuery.addFieldAsOutput('Idea_Contact__c');
            mainQuery.addFieldAsOutput('Idea_Phone__c');
            mainQuery.addFieldAsOutput('Idea_Co_Type__c');
            mainQuery.addFieldAsOutput('Add_Idea_Companies__c');
            mainQuery.addFieldAsOutput('Idea_Quality__c');
            mainQuery.addFieldAsOutput('Idea_Transacted__c');
            mainQuery.addFieldAsOutput('Deal_Entry_Date__c');
            mainQuery.addFieldAsOutput('Source_Company__c');
            mainQuery.addFieldAsOutput('Source_Contact__c');
            mainQuery.addFieldAsOutput('Source_Phone__c');
            mainQuery.addFieldAsOutput('Source_Co_Type__c');
            mainQuery.addFieldAsOutput('Co_Source_Company__c');
            mainQuery.addFieldAsOutput('Co_Source_Contact__c');
            mainQuery.addFieldAsOutput('Co_Source_Phone__c');
            mainQuery.addFieldAsOutput('Co_Source_Co_Type__c');
            mainQuery.addFieldAsOutput('Deal_Quality__c');
            mainQuery.addFieldAsOutput('Add_Source_Companies__c');
            mainQuery.addFieldAsOutput('Early_Look__c');
            mainQuery.addFieldAsOutput('Deal_Launch_Date__c');
            mainQuery.addFieldAsOutput('Initial_Bid_From__c');
            mainQuery.addFieldAsOutput('Second_Round_Guidance__c');
            mainQuery.addFieldAsOutput('Initial_Bid_From_Multiple__c');
            mainQuery.addFieldAsOutput('Second_Round_Guidance_Multiple__c');
            mainQuery.addFieldAsOutput('Initial_Bid_To__c');
            mainQuery.addFieldAsOutput('Final_Bid__c');
            mainQuery.addFieldAsOutput('Initial_Bid_To_Multiple__c');
            mainQuery.addFieldAsOutput('Final_Bid_Multiple__c');
            mainQuery.addFieldAsOutput('Bid_Date__c');
            mainQuery.addFieldAsOutput('AS_Team__c');
            mainQuery.addFieldAsOutput('AS_Resources__c');
            mainQuery.addFieldAsOutput('Fireside_Chat__c');
            mainQuery.addFieldAsOutput('Process_Status__c');
            mainQuery.addFieldAsOutput('CA_Status__c');
            mainQuery.addFieldAsOutput('Buyer__c');
            mainQuery.addFieldAsOutput('Reason_AS_Passed__c');
            mainQuery.addFieldAsOutput('Notes__c');
            mainQuery.addFieldAsOutput('Close_Date__c');
            mainQuery.addFieldAsOutput('Purchase_Price__c');
            mainQuery.addFieldAsOutput('Total_Fees__c');
            mainQuery.addFieldAsOutput('Fund__c');
            mainQuery.addFieldAsOutput('Issuer_Name_ID__c');
            mainQuery.addFieldAsOutput('Current_Hold_Total__c');
            mainQuery.addFieldAsOutput('Financing_Size__c');
            mainQuery.addFieldAsOutput('Bank_Meeting_Date__c');
            mainQuery.addFieldAsOutput('Update_Call_Date__c');
            mainQuery.addFieldAsOutput('S_P_Meeting_Date__c');
            mainQuery.addFieldAsOutput('S_P_Update_Call_Date__c');
            mainQuery.addFieldAsOutput('Moodys_Meeting_Date__c');
            mainQuery.addFieldAsOutput('Moodys_Update_Call_Date__c');
            mainQuery.addWhere('Id', mainRecord.Id, SkyEditor2.WhereOperator.Eq)
                .limitRecords(1);
            
            
            
            mode = SkyEditor2.LayoutMode.LayoutSalesforce; 
            
            queryMap = new Map<String, SkyEditor2.Query>();
            SkyEditor2.Query query;
            
            Component366 = new Component366(new List<Financing_Proposal__c>(), new List<Component366Item>(), new List<Financing_Proposal__c>(), null);
            listItemHolders.put('Component366', Component366);
            query = new SkyEditor2.Query('Financing_Proposal__c');
            query.addFieldAsOutput('Lender__c');
            query.addFieldAsOutput('View__c');
            query.addFieldAsOutput('Hold__c');
            query.addFieldAsOutput('Early_Leverage__c');
            query.addFieldAsOutput('Early_OID__c');
            query.addFieldAsOutput('Flex__c');
            query.addFieldAsOutput('Early_Floor__c');
            query.addFieldAsOutput('Early_LIBOR_Spread__c');
            query.addWhere('Deal__c', mainRecord.Id, SkyEditor2.WhereOperator.Eq);
            relationFields.put('Component366', 'Deal__c');
            Component366.queryRelatedEvent = False;
            query.limitRecords(500);
            queryMap.put('Component366', query);
            
            Component388 = new Component388(new List<Final_Financing__c>(), new List<Component388Item>(), new List<Final_Financing__c>(), null);
            listItemHolders.put('Component388', Component388);
            query = new SkyEditor2.Query('Final_Financing__c');
            query.addFieldAsOutput('View__c');
            query.addFieldAsOutput('Lender__c');
            query.addFieldAsOutput('Primary_Contact__c');
            query.addFieldAsOutput('Initial_Hold__c');
            query.addFieldAsOutput('Current_Hold__c');
            query.addFieldAsOutput('Allocation__c');
            query.addFieldAsOutput('Commitment__c');
            query.addFieldAsOutput('Status__c');
            query.addFieldAsOutput('RecordTypeId');
            query.addWhere('Deal__c', mainRecord.Id, SkyEditor2.WhereOperator.Eq);
            relationFields.put('Component388', 'Deal__c');
            Component388.queryRelatedEvent = False;
            query.limitRecords(500);
            queryMap.put('Component388', query);
            
            Component405 = new Component405(new List<Deal_Fees__c>(), new List<Component405Item>(), new List<Deal_Fees__c>(), null);
            listItemHolders.put('Component405', Component405);
            query = new SkyEditor2.Query('Deal_Fees__c');
            query.addFieldAsOutput('View__c');
            query.addFieldAsOutput('Fee_Paid_To__c');
            query.addFieldAsOutput('Fee_Type__c');
            query.addFieldAsOutput('Fee_Date__c');
            query.addFieldAsOutput('Fee_Amount__c');
            query.addFieldAsOutput('Comments__c');
            query.addWhere('Deal__c', mainRecord.Id, SkyEditor2.WhereOperator.Eq);
            relationFields.put('Component405', 'Deal__c');
            Component405.queryRelatedEvent = False;
            query.limitRecords(500);
            queryMap.put('Component405', query);
            
            Component419 = new Component419(new List<External_Working_Group_Member__c>(), new List<Component419Item>(), new List<External_Working_Group_Member__c>(), null);
            listItemHolders.put('Component419', Component419);
            query = new SkyEditor2.Query('External_Working_Group_Member__c');
            query.addFieldAsOutput('View__c');
            query.addFieldAsOutput('Contact__c');
            query.addFieldAsOutput('Company__c');
            query.addFieldAsOutput('Role__c');
            query.addFieldAsOutput('Notes__c');
            query.addWhere('Deal__c', mainRecord.Id, SkyEditor2.WhereOperator.Eq);
            relationFields.put('Component419', 'Deal__c');
            Component419.queryRelatedEvent = False;
            query.limitRecords(500);
            queryMap.put('Component419', query);
            
            Component431 = new Component431(new List<Amendment_Waiver__c>(), new List<Component431Item>(), new List<Amendment_Waiver__c>(), null);
            listItemHolders.put('Component431', Component431);
            query = new SkyEditor2.Query('Amendment_Waiver__c');
            query.addFieldAsOutput('View__c');
            query.addFieldAsOutput('Lender__c');
            query.addFieldAsOutput('Description__c');
            query.addFieldAsOutput('Type__c');
            query.addFieldAsOutput('Status__c');
            query.addFieldAsOutput('Notes__c');
            query.addWhere('Deal__c', mainRecord.Id, SkyEditor2.WhereOperator.Eq);
            relationFields.put('Component431', 'Deal__c');
            Component431.queryRelatedEvent = False;
            query.limitRecords(500);
            queryMap.put('Component431', query);
            
            registRelatedList('Financing_Proposal__r', 'Component366');
            registRelatedList('Financing_Details__r', 'Component388');
            registRelatedList('Deal_Fees__r', 'Component405');
            registRelatedList('External_Working_Group_Members__r', 'Component419');
            registRelatedList('Amendments_Waivers__r', 'Component431');
            
            addInheritParameter('RecordTypeId', 'RecordType');
            init();
            
            Component366.extender = this.extender;
            Component388.extender = this.extender;
            Component405.extender = this.extender;
            Component419.extender = this.extender;
            Component431.extender = this.extender;
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
    
    private static testMethod void testPageMethods() {        SVE_20130731142732 extension = new SVE_20130731142732(new ApexPages.StandardController(new Deal__c()));
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
    global class Component366Item extends SkyEditor2.ListItem {
        public Financing_Proposal__c record{get; private set;}
        Component366Item(Component366 holder, Financing_Proposal__c record, SkyEditor2.RecordTypeSelector recordTypeSelector) {
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
    global class Component366 extends SkyEditor2.ListItemHolder {
        public List<Component366Item> items{get; private set;}
        Component366(List<SObject> records, List<SkyEditor2.ListItem> items, List<SObject> deleteRecords, SkyEditor2.RecordTypeSelector recordTypeSelector) {
            super(records, items, deleteRecords, recordTypeSelector);
            this.items = (List<Component366Item>)items;
        }
        global override SkyEditor2.ListItem create(SObject data) {
            return new Component366Item(this, (Financing_Proposal__c)data, recordTypeSelector);
        }
    }
    private static testMethod void testComponent366() {
        Component366 Component366 = new Component366(new List<Financing_Proposal__c>(), new List<Component366Item>(), new List<Financing_Proposal__c>(), null);
        Component366.create(new Financing_Proposal__c());
    }
    
    global class Component388Item extends SkyEditor2.ListItem {
        public Final_Financing__c record{get; private set;}
        Component388Item(Component388 holder, Final_Financing__c record, SkyEditor2.RecordTypeSelector recordTypeSelector) {
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
    global class Component388 extends SkyEditor2.ListItemHolder {
        public List<Component388Item> items{get; private set;}
        Component388(List<SObject> records, List<SkyEditor2.ListItem> items, List<SObject> deleteRecords, SkyEditor2.RecordTypeSelector recordTypeSelector) {
            super(records, items, deleteRecords, recordTypeSelector);
            this.items = (List<Component388Item>)items;
        }
        global override SkyEditor2.ListItem create(SObject data) {
            return new Component388Item(this, (Final_Financing__c)data, recordTypeSelector);
        }
    }
    private static testMethod void testComponent388() {
        Component388 Component388 = new Component388(new List<Final_Financing__c>(), new List<Component388Item>(), new List<Final_Financing__c>(), null);
        Component388.create(new Final_Financing__c());
    }
    
    global class Component405Item extends SkyEditor2.ListItem {
        public Deal_Fees__c record{get; private set;}
        Component405Item(Component405 holder, Deal_Fees__c record, SkyEditor2.RecordTypeSelector recordTypeSelector) {
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
    global class Component405 extends SkyEditor2.ListItemHolder {
        public List<Component405Item> items{get; private set;}
        Component405(List<SObject> records, List<SkyEditor2.ListItem> items, List<SObject> deleteRecords, SkyEditor2.RecordTypeSelector recordTypeSelector) {
            super(records, items, deleteRecords, recordTypeSelector);
            this.items = (List<Component405Item>)items;
        }
        global override SkyEditor2.ListItem create(SObject data) {
            return new Component405Item(this, (Deal_Fees__c)data, recordTypeSelector);
        }
    }
    private static testMethod void testComponent405() {
        Component405 Component405 = new Component405(new List<Deal_Fees__c>(), new List<Component405Item>(), new List<Deal_Fees__c>(), null);
        Component405.create(new Deal_Fees__c());
    }
    
    global class Component419Item extends SkyEditor2.ListItem {
        public External_Working_Group_Member__c record{get; private set;}
        Component419Item(Component419 holder, External_Working_Group_Member__c record, SkyEditor2.RecordTypeSelector recordTypeSelector) {
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
    global class Component419 extends SkyEditor2.ListItemHolder {
        public List<Component419Item> items{get; private set;}
        Component419(List<SObject> records, List<SkyEditor2.ListItem> items, List<SObject> deleteRecords, SkyEditor2.RecordTypeSelector recordTypeSelector) {
            super(records, items, deleteRecords, recordTypeSelector);
            this.items = (List<Component419Item>)items;
        }
        global override SkyEditor2.ListItem create(SObject data) {
            return new Component419Item(this, (External_Working_Group_Member__c)data, recordTypeSelector);
        }
    }
    private static testMethod void testComponent419() {
        Component419 Component419 = new Component419(new List<External_Working_Group_Member__c>(), new List<Component419Item>(), new List<External_Working_Group_Member__c>(), null);
        Component419.create(new External_Working_Group_Member__c());
    }
    
    global class Component431Item extends SkyEditor2.ListItem {
        public Amendment_Waiver__c record{get; private set;}
        Component431Item(Component431 holder, Amendment_Waiver__c record, SkyEditor2.RecordTypeSelector recordTypeSelector) {
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
    global class Component431 extends SkyEditor2.ListItemHolder {
        public List<Component431Item> items{get; private set;}
        Component431(List<SObject> records, List<SkyEditor2.ListItem> items, List<SObject> deleteRecords, SkyEditor2.RecordTypeSelector recordTypeSelector) {
            super(records, items, deleteRecords, recordTypeSelector);
            this.items = (List<Component431Item>)items;
        }
        global override SkyEditor2.ListItem create(SObject data) {
            return new Component431Item(this, (Amendment_Waiver__c)data, recordTypeSelector);
        }
    }
    private static testMethod void testComponent431() {
        Component431 Component431 = new Component431(new List<Amendment_Waiver__c>(), new List<Component431Item>(), new List<Amendment_Waiver__c>(), null);
        Component431.create(new Amendment_Waiver__c());
    }
    
    class PageReferenceFactory implements SkyEditor2.PageReferenceFactory.Implementation {
        public PageReference newPageReference(String url) {
            PageReference ref = new PageReference(url);
            ref.setRedirect(true);
            return ref;
        }
    }
}