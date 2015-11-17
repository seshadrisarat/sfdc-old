/**
 * \author Vladimir Dobrelya
 * \date Nov 20, 2014
 * \see https://silverline.jira.com/browse/HL-53
 */
public with sharing class SL_OpportunityApproval {

    public static final String opportunityApprovalName = 'Opportunity_Approval__c';
    public PagePagination pagination { get; set; }

    private ID opportunityApprovalId;
    public Boolean access { get; set; } // indicates Opportunity Approval object accessibility
    public Opportunity_Approval__c initialOAData { get; set; } // additional needed data
    public Opportunity_Approval__c opportunityApproval { get; set; }
    private Opportunity_Approval__c srcOpportunityApproval { get; set; } // save logic: do not save a record if it has no changes

    public List<Section> sections { get; set; } // the available sections on the current page
    public List<RelatedList> relatedLists { get; set; } // the available related lists on the current page

    public List<Instructional_Text__c> instructionalText { get; set; } // instructional text list - see: https://silverline.jira.com/browse/HL-60
    private DependentProperties dependentProperties;
    public String form { get; set; }

    public SL_OpportunityApproval() {
        this.access = this.getOpportunityApprovalAccessibility();
        if ( this.access ) {
            this.opportunityApprovalId = ApexPages.currentPage().getParameters().get( 'id' );

            try {
                this.initialOAData = this.getInitialOpportunityApproval( this.opportunityApprovalId );
            } catch ( Exception e ) { 
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, e.getMessage() /*+ '; line: ' + e.getLineNumber()*/ ) );
                return;
            }

            this.pagination = this.getPagePagination( this.form );
            this.refreshSections(); 
        }
    }

    private Boolean getOpportunityApprovalAccessibility() {
        if ( !SL_Describe.isAccessible( opportunityApprovalName ) || !SL_Describe.isUpdateable( opportunityApprovalName ) ) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'You have no access to Opportunity Approval object.' ) );
            return false;
        }
        return true;
    }

    private PagePagination getPagePagination( String form ) {
        try {
            return new PagePagination( Integer.valueOf( ApexPages.currentPage().getParameters().get( 'p' ) ), form );
        } catch ( Exception e ) { }
        return new PagePagination( form );
    }

    private Opportunity_Approval__c getInitialOpportunityApproval( ID opportunityApprovalId ) {
        if ( opportunityApprovalId != null ) {
            for ( Opportunity_Approval__c record : [ SELECT Name, Form__c FROM Opportunity_Approval__c WHERE Id = :opportunityApprovalId ] ) {
                this.form = record.Form__c;
                return record;
            }
            throw new OpportunityApprovalNotFoundException( 'Could not find an Opportunity Approval object with \'' + opportunityApprovalId + '\' id.' );
        }
        this.form = ApexPages.currentPage().getParameters().get( 'form' );
        if ( this.form == null ) {
            throw new UrlParamRequiredValueException( 'URL-param form(Line of Business) is required.' );
        }
        ID oppId = ApexPages.currentPage().getParameters().get( 'oid' );
        if ( oppId == null ) {
            throw new UrlParamRequiredValueException( 'URL-param oid(Opportunity ID) is required.' );
        }
        return new Opportunity_Approval__c( Related_Opportunity__c = oppId );
    }

    // ---- BUTTONS ---- //

    public PageReference Save() {
        if ( this.opportunityApproval != null && this.isOpportunityApprovalChanged() ) {
            try {
                upsert this.opportunityApproval;
                if ( this.opportunityApprovalId == null ) {
                    this.opportunityApprovalId = this.opportunityApproval.Id;
                }
            } catch ( DmlException e ) {
                return addExceptionMessage( e );
            }
        }

        // Related list save
        List<SObject> toInsert = new List<SObject>();
        List<SObject> toUpdate = new List<SObject>();

        for ( RelatedList relatedList : this.relatedLists ) {
            toInsert.addAll( relatedList.getRecordsToInsert() );
            toUpdate.addAll( relatedList.getRecordsToUpdate() );
        }

        try {
            if ( !toInsert.isEmpty() ) {
                insert toInsert;
            }
            if ( !toUpdate.isEmpty() ) {
                update toUpdate;
            }
        } catch ( DmlException e ) {
            return addExceptionMessage( e );
        }
// DIFF COMMENT        return new PageReference( '/' + ( this.initialOpportunityApproval.Status__c == 'Approved' ? this.initialOpportunityApproval.Id : this.initialOpportunityApproval.Project__c ) );
        return new PageReference( '/' + this.opportunityApprovalId );
    }

    private Boolean isOpportunityApprovalChanged() {
        return this.isOpportunityApprovalChanged( this.getOpportunityApprovalFields() );
    }

    private Boolean isOpportunityApprovalChanged( Set<String> fields ) {
        if ( this.opportunityApproval != null ) {
            for ( String field : fields ) {
                if ( this.opportunityApproval.get( field ) != this.srcOpportunityApproval.get( field ) ) {
                    return true;
                }
            }
        }
        return false;
    }

    public PageReference Cancel() {
        return new PageReference( '/' + this.opportunityApprovalId );
    }

    public PageReference Previous() {
        if ( this.Save() != null ) {
            this.pagination.previous();
            this.refreshSections();
            return this.getPageReference();
        }
        return null;
    }

    public PageReference Next() {
        if ( this.Save() != null ) {
            this.pagination.next();
            this.refreshSections();
            return this.getPageReference();
        }        
        return null;
    }

    public PageReference ChangePage() {
        if ( this.Save() != null ) {
            this.refreshSections();
            return this.getPageReference();
        }
        return null;
    }    

    private PageReference getPageReference() {
        PageReference result = new PageReference( '/apex/SL_OpportunityApproval' );
        result.getParameters().put( 'id', this.opportunityApprovalId );
        //result.getParameters().put( 'form', this.form );        
        result.getParameters().put( 'p', String.valueOf( this.pagination.getPage() ) );
        if ( ApexPages.currentPage().getParameters().containsKey( 'retURL' ) ) {
            result.getParameters().put( 'retURL', ApexPages.currentPage().getParameters().get( 'retURL' ) );
        }
        result.setRedirect( true );
        return result;
    }

// DIFF COMMENT 
/*
    public Boolean isSubmitForApprovalButtonVisible {
        get {
            return this.pagination.isLastPage && this.opportunityApproval.Status__c != 'Submitted for Approval';
        }
    }

    public PageReference SubmitForApproval() {
        this.opportunityApproval.Status__c = 'Submitted for Approval';
        return this.Save();
    }
*/
    // ---- UTILS ---- //

    public class OpportunityApprovalNotFoundException extends Exception {}

    public static PageReference addExceptionMessage( DmlException e ) {
        for ( Integer idx = 0; idx < e.getNumDml(); idx++ ) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, e.getDmlMessage( idx ) ) );
        }
        return null;
    }

    public void refreshSections() {
        List<Opportunity_Approval_Section__c> sectionsRelatedList = new List<Opportunity_Approval_Section__c>();
        this.sections = new List<Section>();

        if ( !this.pagination.hasPages ) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'There are no pages to display.' ) );
            return;
        }

        List<Opportunity_Approval_Properties__c> allProperties = new List<Opportunity_Approval_Properties__c>();
        dependentProperties = new DependentProperties( this.pagination.getCurrentPageObject().Id );

        for ( Opportunity_Approval_Section__c section : [ 
            SELECT Name, Object_API_Name__c, Relationship_Field__c, Parent_Relationship_Field__c, RecordType.DeveloperName, ( 
                SELECT Name, Field_API_Name__c, Text__c, Read_only__c, Required__c, Hidden__c, Parent_Property__c, Parent_Property_Values__c, Parent_Property__r.Field_API_Name__c,
                    Parent_Property__r.Section__r.Object_API_Name__c, Parent_Property__r.Section__r.Relationship_Field__c, Parent_Property__r.Section__r.Parent_Relationship_Field__c,
                    Parent_Property__r.Section__r.Opportunity_Approval_Page__c, Parent_Property__r.Section__r.RecordType.DeveloperName
                FROM Opportunity_Approval_Properties__r
                WHERE Line_of_Business__c includes (:this.form)
                ORDER BY Order__c )
            FROM Opportunity_Approval_Section__c
            WHERE Opportunity_Approval_Page__r.Order__c = :this.pagination.getPageOrder()
            ORDER BY Opportunity_Approval_Page__r.Order__c, Order__c ]
        ) {
            if ( !section.Opportunity_Approval_Properties__r.isEmpty() ) {
                if ( section.RecordType.DeveloperName == 'Related_List' ) {
                    sectionsRelatedList.add( section );
                } else {
                    this.sections.add( new Section( section ) );
                }
                dependentProperties.add( section.Opportunity_Approval_Properties__r );
            }
        }

        this.initOpportunityApproval( this.opportunityApprovalId, sectionsRelatedList );
        this.dependentProperties.hideDependentProperties( this.opportunityApproval );

        this.relatedLists = new List<RelatedList>();
        for ( Opportunity_Approval_Section__c section : sectionsRelatedList ) {
            this.relatedLists.add( new RelatedList( section, this.opportunityApproval != null ? this.opportunityApproval : this.initialOAData ) );
        }
        this.instructionalText = this.getInstructionalText( this.pagination.getCurrentPageObject() );
    }    

    public String getDependentPropertiesJSON() {
        return JSON.serialize( this.dependentProperties.getDependentProperties() );
    }

    // get all not hidden properties which are on another page, select appropriate parent property data

    private void initOpportunityApproval( ID opportunityApprovalId, List<Opportunity_Approval_Section__c> relatedListSections ) {
        if ( opportunityApprovalId == null ) {
            if ( this.opportunityApproval == null ) {
                this.opportunityApproval = this.initialOAData.clone( true, true, true, true );
            }
            this.srcOpportunityApproval = this.opportunityApproval.clone( true, true, true, true );
            return;
        }
        this.opportunityApproval = null;

        Set<String> fields = this.getOpportunityApprovalFields( relatedListSections );
        fields.addAll( this.dependentProperties.getParentFields() );
        if ( fields.isEmpty() ) {
            return;
        }
        for ( Opportunity_Approval__c record : Database.query( 'SELECT ' + String.join( new List<String>( fields ), ',' ) + ' FROM ' + opportunityApprovalName + ' WHERE Id = :opportunityApprovalId' ) ) {
            this.opportunityApproval = record;
            this.srcOpportunityApproval = record.clone( true, true, true, true );
        }
        if ( this.opportunityApproval == null ) {
            throw new OpportunityApprovalNotFoundException( 'Could not find the ' + opportunityApprovalName + ' object with \'' + opportunityApprovalId + '\'' );
        }
    }

    public Set<String> getOpportunityApprovalFields() {
        Set<String> result = new Set<String>();
// DIFF COMMENT 
/*
        if ( this.pagination.isLastPage ) {
            result.add( 'Status__c' ); // Submit For Approval
        }
*/
        for ( Section section : this.sections ) {
            for ( Opportunity_Approval_Properties__c property : section.properties ) {
                if ( String.isNotBlank( property.Field_API_Name__c ) ) {
                    result.add( property.Field_API_Name__c.toLowerCase() );
                }
            }
        }
        return result;
    }

    public Set<String> getOpportunityApprovalFields( List<Opportunity_Approval_Section__c> relatedListSections ) {
        Set<String> result = new Set<String>( this.getOpportunityApprovalFields() );
        for ( Opportunity_Approval_Section__c section : relatedListSections ) {
            if ( String.isNotBlank( section.Parent_Relationship_Field__c ) ) {
                result.add( section.Parent_Relationship_Field__c.toLowerCase() );
            }
        }
        return result;
    }

    private List<Instructional_Text__c> getInstructionalText( Opportunity_Approval_Page__c page ) {
        return this.getInstructionalText( page.Id );
    }

    private List<Instructional_Text__c> getInstructionalText( ID pageId ) {
        return [ SELECT Text__c FROM Instructional_Text__c WHERE Opportunity_Approval_Page__c = :pageId ORDER BY Order__c ];
    }

    public virtual class Section {
        public Opportunity_Approval_Section__c obj { get; set; }
        public List<Opportunity_Approval_Properties__c> properties { get; set; }

        public Section( Opportunity_Approval_Section__c section ) {
            this.obj = section;
            this.properties = this.getSectionProperties( section );
        }

        private List<Opportunity_Approval_Properties__c> getSectionProperties( Opportunity_Approval_Section__c section ) {
            List<Opportunity_Approval_Properties__c> result = new List<Opportunity_Approval_Properties__c>();
            for ( Opportunity_Approval_Properties__c property : section.Opportunity_Approval_Properties__r ) {
                if ( String.isBlank( property.Field_API_Name__c ) || SL_Describe.isAccessible( section.Object_API_Name__c, property.Field_API_Name__c ) == true ) {
                    result.add( property );
                }
            }
            return result;
        }
    }


    // --- PAGE PAGINATION --- //

    public class PagePagination extends SL_Pagination {
        private List<Opportunity_Approval_Page__c> pages;
        public List<SelectOption> pageOptions { get; private set; }

        public PagePagination( String form ) {
            this( 1, form );
        }

        public PagePagination( Integer page, String form ) {
            super();
            this.pages = this.getPages( form );
            this.pageOptions = this.getPageOptions( this.pages );
            this.setRecordCount( this.pages.size() );
            this.setPage( page );
        }

        private List<Opportunity_Approval_Page__c> getPages( String form ) {
            List<Opportunity_Approval_Page__c> result = new List<Opportunity_Approval_Page__c>();
            if ( form != null ) {
                Set<Integer> addedPages = new Set<Integer>();
                Integer order;

                for ( Opportunity_Approval_Section__c section : [ 
                    SELECT Opportunity_Approval_Page__r.Name, Opportunity_Approval_Page__r.Order__c, Object_API_Name__c, ( 
                        SELECT Field_API_Name__c, Required__c 
                        FROM Opportunity_Approval_Properties__r 
                        WHERE Field_API_Name__c != null AND
                            Line_of_Business__c includes (:form)
                        )
                    FROM Opportunity_Approval_Section__c 
                    WHERE Opportunity_Approval_Page__c != null
                    ORDER BY Opportunity_Approval_Page__r.Order__c ]
                ) {
                    if ( !section.Opportunity_Approval_Properties__r.isEmpty() && !new Section( section ).properties.isEmpty() ) {
                        order = (Integer)section.Opportunity_Approval_Page__r.Order__c;
                        if ( !addedPages.contains( order ) ) { // only unique values
                            result.add( section.Opportunity_Approval_Page__r );
                            addedPages.add( order );
                        }
                    }
                }
            }            
            return result;
        }

        private List<SelectOption> getPageOptions( List<Opportunity_Approval_Page__c> pages ) {
            List<SelectOption> result = new List<SelectOption>();
            for ( Integer i = 0; i < pages.size(); i++ ) {
                result.add( new SelectOption( String.valueOf( i + 1 ), pages.get( i ).Name ) );
            }
            return result;
        }

        public Boolean hasPages {
            get {
                return !this.pages.isEmpty();
            }
        }

        public Integer getPageOrder() {
            return (Integer)this.pages.get( this.getPage() - 1 ).Order__c;
        }

        public Opportunity_Approval_Page__c getCurrentPageObject() {
            return this.pages.get( this.getPage() - 1 );
        }

        public String getPageName() {
            return this.pages.get( this.getPage() - 1 ).Name;
        }
    }


    // --- RELATED LIST --- //

    public class RelatedList extends Section {
        private Opportunity_Approval__c opportunityApproval;
        public List<RelatedListRecord> wrappers { get; set; }
        public List<String> requiredFields { get; set; }
        public Boolean selected { get; set; }
        public String sortBy { get; set; }
        public String sortDirection { get; set; }
        public Map<String, DescribeInfo> describeInfo { get; set; }

        public List<SelectOption> limitOptions { get; set; }

        public SL_QueryBuilder queryRecords { get; set; }
        public RelatedListPagination pagination { get; set; }

        public RelatedList( Opportunity_Approval_Section__c section, Opportunity_Approval__c data ) {
            super( section );

            this.opportunityApproval = data;
            this.requiredFields = this.getFieldApiNames( section, true );
            List<String> fields = this.getFieldApiNames( section, false );
            if ( fields.isEmpty() ) {
                return;
            }
            this.describeInfo = this.getDescribeInfo( section );

            this.selected = false;
            this.sortDirection = 'asc';

            this.limitOptions = new List<SelectOption> {
                new SelectOption( '1', '1' ),
                new SelectOption( '2', '2' ),
                new SelectOption( '5', '5' ),
                new SelectOption( '10', '10' ),
                new SelectOption( '50', '50' )
            };

            this.queryRecords = new SL_QueryBuilder( fields, section.Object_API_Name__c );

            if ( section.Object_API_Name__c == SL_OpportunityApproval.opportunityApprovalName ) {
                this.queryRecords.getWhereDefault().add( SL_OpportunityApproval.opportunityApprovalName + '=\'' + this.opportunityApproval.Id + '\'' );
            } else if ( String.isBlank( section.Parent_Relationship_Field__c ) ) {
                this.queryRecords.getWhereDefault().add( section.Relationship_Field__c + '=\'' + this.opportunityApproval.Id + '\'' );
            } else {
                this.queryRecords.getWhereDefault().add( section.Relationship_Field__c + '=\'' + SL_SObjectDigger.get( this.opportunityApproval, section.Parent_Relationship_Field__c ) + '\'' );
            }
            
            this.pagination = new RelatedListPagination( this.queryRecords, 5 );

            this.refreshRecords();
        }

        public PageReference Save() {
            List<SObject> toInsert = this.getRecordsToInsert();
            List<SObject> toUpdate = this.getRecordsToUpdate();

            try {
                if ( !toInsert.isEmpty() ) {
                    insert toInsert;
                    this.pagination.refreshRecordCount();
                }
                if ( !toUpdate.isEmpty() ) {
                    update toUpdate;
                }
            } catch ( DmlException e ) {
                SL_OpportunityApproval.addExceptionMessage( e );
                return ApexPages.currentPage();
            }
            return null;
        }

        public void SaveAndRefresh() {
            if ( this.Save() == null ) {
                this.refreshRecords();
            }
        }

        public void Cancel() {
            this.refreshRecords();
        }

        public void Next() {
            if ( this.Save() == null ) {
                this.selected = false;
                this.pagination.next();
                this.refreshRecords();
            }
        }

        public void Previous() {
            if ( this.Save() == null ) {
                this.selected = false;
                this.pagination.previous();
                this.refreshRecords();
            }
        }

        public void AddRow() {
            SObject newRecord = (SObject)Type.forName( this.obj.Object_API_Name__c ).newInstance();

            if ( SL_Describe.isExisting( this.obj.Object_API_Name__c, SL_OpportunityApproval.opportunityApprovalName ) ) {
                newRecord.put( SL_OpportunityApproval.opportunityApprovalName, this.opportunityApproval.Id );
            } else if ( String.isNotBlank( this.obj.Relationship_Field__c ) ) {
                if ( String.isBlank( this.obj.Parent_Relationship_Field__c ) ) {
                    newRecord.put( this.obj.Relationship_Field__c, this.opportunityApproval.Id );
                } else {
                    newRecord.put( this.obj.Relationship_Field__c, SL_SObjectDigger.get( this.opportunityApproval, this.obj.Parent_Relationship_Field__c ) );
                }
            }

            this.wrappers.add( new RelatedListRecord( newRecord ) );
        }

        public void RemoveRows() {
            List<SObject> recordsToDelete = new List<SObject>();
            List<RelatedListRecord> newWrappers = new List<RelatedListRecord>();
            for ( Integer i = 0; i < this.wrappers.size(); i++ ) {
                if ( this.wrappers[i].selected ) {
                    if ( this.wrappers[i].obj.Id != null ) {
                        recordsToDelete.add( this.wrappers[i].obj );
                    }
                    this.wrappers.remove( i-- );
                } else if ( this.wrappers[i].obj.Id == null ) {
                    newWrappers.add( this.wrappers[i] );
                }
            }

            this.selected = false;

            if ( !recordsToDelete.isEmpty() ) {
                delete recordsToDelete;
                this.pagination.refreshRecordCount();
            }

            if ( this.wrappers.isEmpty() ) {
                if ( this.pagination.getPage() >= this.pagination.getLastPage() - 1 ) {
                    this.pagination.setPage( this.pagination.getPage() - 1 );
                }
            }

            if ( !recordsToDelete.isEmpty() ) {
                this.refreshRecords();
                if ( !newWrappers.isEmpty() ) {
                    this.wrappers.addAll( newWrappers );
                }
            }
        }

        public List<SObject> getRecordsToInsert() {
            List<SObject> result = new List<SObject>();
            for ( RelatedListRecord record : this.wrappers ) {
                if ( record.isNew() ) {
                    record.validateRequiredFields( this.requiredFields );
                    result.add( record.obj );
                }
            }
            return result;
        }

        public List<SObject> getRecordsToUpdate() {
            List<SObject> result = new List<SObject>();
            for ( RelatedListRecord record : this.wrappers ) {
                if ( !record.isNew() && record.isChanged( this.describeInfo.keySet() ) ) {
                    record.validateRequiredFields( this.requiredFields );
                    result.add( record.obj );
                }
            }
            return result;
        }

        public void refreshRecordsAndPage() {
            this.pagination.setPage( 1 );
            this.refreshRecords();
        }

        public void refreshRecords() {
            this.selected = false;
            this.queryRecords.getOrderBy().clear();

            if ( this.sortBy != null ) {
                if ( SL_Describe.getType( this.obj.Object_API_Name__c, this.sortBy ) == DisplayType.Reference ) {
                    this.queryRecords.getOrderBy().add( SL_Describe.getRelationshipName( this.obj.Object_API_Name__c, this.sortBy ) + '.Name ' + this.sortDirection );
                } else {
                    this.queryRecords.getOrderBy().add( this.sortBy + ' ' + this.sortDirection );
                }
            }

            this.pagination.refreshRecordCount();
            this.wrappers = this.createRecordWrappers( Database.query( this.queryRecords.build() ) );
        }

        private List<RelatedListRecord> createRecordWrappers( List<SObject> records ) {
            List<RelatedListRecord> result = new List<RelatedListRecord>();
            if ( records == null ) {
                return result;
            }
            for ( SObject record : records ) {
                result.add( new RelatedListRecord( record ) );
            }
            return result;
        }

        public void selectAllRecords() {
            for ( RelatedListRecord wrapper : this.wrappers ) {
                wrapper.selected = this.selected;
            }
        }

        private List<String> getFieldApiNames( Opportunity_Approval_Section__c section, Boolean requiredOnly ) {
            List<String> result = new List<String>();

            for ( Opportunity_Approval_Properties__c property : section.Opportunity_Approval_Properties__r ) {
                if ( SL_Describe.isAccessible( section.Object_API_Name__c, property.Field_API_Name__c ) == true ) {
                    if ( SL_Describe.isRequired( section.Object_API_Name__c, property.Field_API_Name__c ) == true ) {
                        property.Required__c = true;
                    }
                    if ( !requiredOnly || ( requiredOnly && property.Required__c ) ) {
                        result.add( property.Field_API_Name__c );
                    }
                }
            }

            return result;
        }

        private Map<String, DescribeInfo> getDescribeInfo( Opportunity_Approval_Section__c section ) {
            Map<String, DescribeInfo> result = new Map<String, DescribeInfo>();
            Schema.DescribeFieldResult fieldDescribe;

            for ( Opportunity_Approval_Properties__c property : section.Opportunity_Approval_Properties__r ) {
                fieldDescribe = SL_Describe.getDescribe( section.Object_API_Name__c, property.Field_API_Name__c );
                if ( fieldDescribe != null && fieldDescribe.isAccessible() ) {
                    if ( !result.containsKey( property.Field_API_Name__c ) ) {
                        result.put( property.Field_API_Name__c, new DescribeInfo( fieldDescribe ) );
                    }
                }
            }

            return result;
        }
    }

    public class DescribeInfo {
        public Boolean isSortable { get; set; }
        
        public DescribeInfo( Schema.DescribeFieldResult fieldDescribe ) {
            this.isSortable = fieldDescribe.isSortable();
        }
    }

    // --- RELATED LIST RECORD WRAPPER --- //

    public class RelatedListRecord {
        public Boolean selected { get; set; }
        public SObject obj { get; set; }
        private SObject srcObj { get; set; }

        public RelatedListRecord( SObject obj ) {
            this.obj = obj;
            this.srcObj = obj.clone( true, true, true, true );
            this.selected = false;
        }

        public void selectRecord() {
            //this.selected = !this.selected;
        }

        public void validateRequiredFields( List<String> requiredFields ) {
            for ( String field : requiredFields ) {
                if ( this.obj.get( field ) == null ) {
                    this.obj.addError( field + ': You must enter a value.' );
                }
            }
        } 

        public Boolean isNew() {
            return this.obj.Id == null;
        }

        public Boolean isChanged( Set<String> fields ) {
            for ( String field : fields ) {
                if ( this.srcObj.get( field ) != this.obj.get( field ) ) {
                    return true;
                }
            }
            return false;
        }
    }


    // --- RELATED LIST PAGINATION --- //

    public class RelatedListPagination extends SL_Pagination {
        public SL_QueryBuilder queryRecordsCount { get; set; }
        private SL_QueryBuilder sourceQueryBuilder;

        public RelatedListPagination( SL_QueryBuilder queryBuilder, Integer itemsPerPage ) {
            super();
            this.sourceQueryBuilder = queryBuilder;
            this.queryRecordsCount = new SL_QueryBuilder( 'COUNT(Id) cnt', queryBuilder.sObjectName );
            this.queryRecordsCount.getWhereDefault().addAll( queryBuilder.getWhereDefault() );
            this.setItemsPerPage( itemsPerPage );
            this.refreshRecordCount();
        }

        public override void setPage( Integer value ) {
            super.setPage( value );
            this.sourceQueryBuilder.offsetCount = ( this.getPage() - 1 ) * this.getItemsPerPage();
        }

        public override void setItemsPerPage( Integer value ) {
            super.setItemsPerPage( value );
            this.sourceQueryBuilder.limitCount = this.getItemsPerPage();
        }

        public void refreshRecordCount() {
            this.queryRecordsCount.setWhere( this.sourceQueryBuilder.getWhere() );    
            this.setRecordCount( Integer.valueOf( Database.query( this.queryRecordsCount.build() ).get( 0 ).get( 'cnt' ) ) );
        }
    }

    public class DependentProperties {
        private Map<ID, Opportunity_Approval_Properties__c> properties; // map to exclude duplicates
        private ID currentPageId;

        public DependentProperties( ID currentPageId ) {
            this( currentPageId, new List<Opportunity_Approval_Properties__c>() );
        }

        public DependentProperties( ID currentPageId, List<Opportunity_Approval_Properties__c> properties ) {
            this.currentPageId = currentPageId;
            this.properties = this.getProperties( properties );
        }

        public void add( List<Opportunity_Approval_Properties__c> properties ) {
            this.properties.putAll( this.getProperties( properties ) );
        }

        public void clear() {
            this.properties.clear();
        }

        private Map<ID, Opportunity_Approval_Properties__c> getProperties( List<Opportunity_Approval_Properties__c> properties ) {
            Map<ID, Opportunity_Approval_Properties__c> result = new Map<ID, Opportunity_Approval_Properties__c>();

            for ( Opportunity_Approval_Properties__c property : properties ) {
                if ( property.Parent_Property__c != null && property.Parent_Property__r.Section__r.Object_API_Name__c != null &&
                    property.Parent_Property__r.Section__r.Object_API_Name__c.toLowerCase() == 'opportunity_approval__c' &&
                    property.Parent_Property__r.Field_API_Name__c != null && property.Parent_Property_Values__c != null
                ) {
                    result.put( property.Id, property );
                }
            }
            return result;
        }

        public Map<ID, List<Opportunity_Approval_Properties__c>> getDependentProperties() {
            Map<ID, List<Opportunity_Approval_Properties__c>> result = new Map<ID, List<Opportunity_Approval_Properties__c>>();

            for ( Opportunity_Approval_Properties__c property : this.properties.values() ) {
                if ( !result.containsKey( property.Parent_Property__c ) ) {
                    result.put( property.Parent_Property__c, new List<Opportunity_Approval_Properties__c>() );
                }
                result.get( property.Parent_Property__c ).add( property );
            }            
            return result;
        }

        public Set<String> getParentFields() {
            Set<String> result = new Set<String>();

            for ( Opportunity_Approval_Properties__c property : this.properties.values() ) {
                result.add( property.Parent_Property__r.Field_API_Name__c.toLowerCase() );
            }
            return result;
        }

        public void hideDependentProperties( Opportunity_Approval__c opportunityApproval ) {
            for ( Opportunity_Approval_Properties__c property : this.properties.values() ) {
                if ( !property.Hidden__c && property.Parent_Property__r.Section__r.Opportunity_Approval_Page__c != null && currentPageId != property.Parent_Property__r.Section__r.Opportunity_Approval_Page__c ) {
                    property.Hidden__c = isHidden( property, opportunityApproval );
                }
            }
        }

        private Boolean isHidden( Opportunity_Approval_Properties__c property, Opportunity_Approval__c opportunityApproval ) {
            return isHidden( property, (String)opportunityApproval.get( property.Parent_Property__r.Field_API_Name__c ) );
        }

        private Boolean isHidden( Opportunity_Approval_Properties__c property, String parentValue ) {
            return !new Set<String>( property.Parent_Property_Values__c.split( ';' ) ).contains( parentValue );
        }

    }

    private class UrlParamRequiredValueException extends Exception { }
}