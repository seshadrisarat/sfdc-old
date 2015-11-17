/****************************************************************************************
Name            : psaManageMilestoneController
Author          : CLD
Created Date    : January 21, 2014
Description     : Contains methods for the Manage Milestone custom VF Page.
******************************************************************************************/
public with sharing class psaManageMilestoneController {

    public pse__Proj__c project {get; set;} 
    //public List<Milestone_Template__c> msTemplateOptions {get; set;}
    //public List<SelectOption> msTemplateOptionsSelectList {get; set;}
    //public Contact throwawayContact {get; set;}
    public List<MilestoneWrapper> msWrapperList {get; set;}
    public List<pse__Milestone__c> existingMilestones {get; set;}
    //public string selectedMSTemplate {get; set;}
    private Date previousMilestoneEndDate {get; set;}
    public boolean hasChangedRows {get; set;}
    public MilestoneWrapper oSummary { get; set; }
    public List<SelectOption> ProjectPhases { get; private set; }
    public Boolean isAllBoxChecked {
        get;
        set {
            for ( MilestoneWrapper oItem : this.msWrapperList ) {
                oItem.isMSChecked = value;
            }
        }
    }

    public List<MilestoneWrapper> getWrappers() {
        //this.rollupParentMilestoneFields();
        this.rollupSummaryFields();
        return this.msWrapperList;
    }

    public psaManageMilestoneController() {
    	ID idProject = (ID)ApexPages.currentPage().getParameters().get('projectID');
    	
        project = [select name, pse__Start_Date__c, pse__End_Date__c, pse__Stage__c from pse__Proj__c p where id = :idProject limit 1];
        //msTemplateOptions = [select name, id from Milestone_Template__c order by name asc];  
        
        this.ProjectPhases = new List<SelectOption>();
        for ( pse__Project_Phase__c oItem : [ SELECT Id, Name FROM pse__Project_Phase__c WHERE pse__Project__c = :idProject ORDER BY Order__c ] ) {
        	this.ProjectPhases.add( new SelectOption( oItem.Id, oItem.Name ) );
        }
        if ( this.ProjectPhases.isEmpty() ) {
            this.ProjectPhases.add( new SelectOption( '', '--None--' ) );
        }
        
        this.createMilestoneList();
    }
    
    /*public void changeChildStatuses() {
        String sParentId = ApexPages.currentPage().getParameters().get( 'pid' );
        String sParentStatus = ApexPages.currentPage().getParameters().get( 'ps' );

        if ( !String.isBlank( sParentId ) && !String.isBlank( sParentStatus ) ) {
            for ( MilestoneWrapper oItem : this.getChildren( sParentId ) ) {
                oItem.mStone.pse__Status__c = sParentStatus;
            }
        }
    }*/

    private void createMilestoneList() {
        //Instantiate existingMilestone list and populate with existing Milestones, if any 
        existingMilestones = new List<pse__Milestone__c>( [select name, Project_Phase__c, Parent_Milestone__c, pse__Milestone_Amount__c, Start_Date__c, End_Date__c, pse__Target_Date__c, pse__Status__c, Budget_Hours__c, pse__Billable_Hours_In_Financials__c, Estimated_Hours__c, RecordTypeId, ( SELECT Id FROM pse__Timecards__r limit 1 ), ( SELECT Id FROM pse__Expense_Reps__r limit 1 ) from pse__Milestone__c where pse__Project__c = :this.project.Id order by Project_Phase__r.Order__c, Parent_Milestone__c NULLS FIRST, Start_Date__c asc, Name asc] ); 

        //Instantiate Milestone Wrapper List, which will be used for populating/managing the table of milestones
        msWrapperList = new List<MilestoneWrapper>(); 
        
        //Add count variable for calculating index of existing milestones
        Integer count = 0; 
        
        //Add existingMilestones to MilestoneWrapper list so they display in table
        for ( pse__Milestone__c ms: existingMilestones ) {
            MilestoneWrapper msWrapper = new MilestoneWrapper(ms); 
            msWrapper.isExistingMS = true;
            msWrapper.index = count++; 
            
            //Only set duration if Start and End Date values are non-null
            if (ms.Start_Date__c != null && ms.End_Date__c != null){
                msWrapper.duration = ms.Start_Date__c.daysBetween(ms.End_Date__c); 
            }
            
            msWrapperList.add(msWrapper);
        }
        
        //Create Select List Options For Milestone Templates 
        /*msTemplateOptionsSelectList = new List<SelectOption>(); 
        for (Milestone_Template__c ms: msTemplateOptions){
            msTemplateOptionsSelectList.add(new SelectOption(ms.id, ms.name)); 
        }*/
        
        //Instantiate Opportunity, which will be used for date input field. Set default value for field when page loads 
        //throwawayContact = new Contact(); 
        //throwawayContact.BirthDate = Date.today(); 
        
        this.hasChangedRows = false;
        //Temporary validation loop, if there are milestones in the collection that aren't existing milestones, set the hasChangedRows flag
        /*for (MilestoneWrapper msw: msWrapperlist){
            if (msw.isExistingMS == false){
                hasChangedRows = true; 
                break; 
            }
        }*/

        this.msWrapperlist = this.sort();
    }

    private List<MilestoneWrapper> sort() {
        List<MilestoneWrapper> aResult = new List<MilestoneWrapper>();

        for ( MilestoneWrapper oItem : this.msWrapperlist ) {
            if ( oItem.isParent ) {
                aResult.add( oItem );
                aResult.addAll( this.getChildren( oItem.mStone.Id ) );
            }
        }

        return aResult;
    }

    private List<MilestoneWrapper> getChildren( ID idParent ) {
        List<MilestoneWrapper> aResult = new List<MilestoneWrapper>();

        if ( idParent == null ) {
            return aResult;
        }

        for ( MilestoneWrapper oItem : this.msWrapperlist ) {
            if ( oItem.mStone.Parent_Milestone__c == idParent ) {
                aResult.add( oItem );
            }
        }

        return aResult;
    }

    private void rollupSummaryFields() {
        this.oSummary = new MilestoneWrapper(
            new pse__Milestone__c(
                pse__Billable_Hours_In_Financials__c = 0.00,
                Estimated_Hours__c = 0.00,
                Budget_Hours__c = 0.00
            )
        );

        for ( MilestoneWrapper oItem : this.msWrapperList ) {
            if ( oItem.isParent ) {
                oItem.mStone.Estimated_Hours__c = 0.00;
                //oItem.duration = 0;
                //oItem.mStone.pse__Billable_Hours_In_Financials__c = 0.00;                
                //oItem.mStone.Budget_Hours__c = 0.00;
                
                for ( MilestoneWrapper oChild : this.getChildren( oItem.mStone.Id ) ) {
                    if ( oChild.mStone.pse__Status__c != 'Canceled' ) {
                        //oItem.duration += oChild.duration;
                        //try { oItem.mStone.pse__Billable_Hours_In_Financials__c += oChild.mStone.pse__Billable_Hours_In_Financials__c; } catch ( Exception e ) { }
                        //try { oItem.mStone.Budget_Hours__c += oChild.mStone.Budget_Hours__c; } catch ( Exception e ) { }
                        try { oItem.mStone.Estimated_Hours__c += oChild.mStone.Estimated_Hours__c; } catch ( Exception e ) { }
                    }
                }

                this.oSummary.duration += oItem.duration;
                this.oSummary.mStone.pse__Billable_Hours_In_Financials__c += oItem.mStone.pse__Billable_Hours_In_Financials__c;
                this.oSummary.mStone.Budget_Hours__c += oItem.mStone.Budget_Hours__c;
                this.oSummary.mStone.Estimated_Hours__c += oItem.mStone.Estimated_Hours__c;
            }
        }
    }

    public class MilestoneWrapper{
        public MilestoneWrapper(pse__Milestone__c inputMilestone){
            mStone = inputMilestone; 
            isEditable = true; 
            isMSChecked = false; 
            duration = 0; 
            isExistingMS = false; 
            hasChanges = false; 
            index = 0;
            
            if ( mStone.pse__Billable_Hours_In_Financials__c == null ) {
                mStone.pse__Billable_Hours_In_Financials__c = 0.00;
            }
            if ( mStone.Estimated_Hours__c == null ) {
                mStone.Estimated_Hours__c = 0.00;
            }
            if ( mStone.pse__Milestone_Amount__c == null ) {
                mStone.pse__Milestone_Amount__c = 0.00;
            }
            if ( mStone.Budget_Hours__c == null ) {
                mStone.Budget_Hours__c = 0.00;
            }      
        }
        public pse__Milestone__c mStone {get; set;}
        public boolean isEditable {get; set;}
        public boolean isMSChecked {get; set;}
        public Integer duration {get; set;}
        public boolean isExistingMS {get; set;}
        //This value is used to determine which object in the list of MilestoneWrappers should be updated with the "changed" flag. The point is avoiding iterating over the entire collection to figure out which item we need to change. 
        public Integer index {get; set;}
        //This value indicates whether a particular row has changes that have not yet been saved
        public boolean hasChanges {get; set;}
        public Boolean isParent {
            get {
                return mStone.RecordTypeId == psaUtils.idRTParentTask;
            }
        }
        public Boolean isChild {
            get {
                return mStone.RecordTypeId == psaUtils.idRTChildTask;
            }
        }
        public Boolean isBillable {
            get {
                return mStone.RecordTypeId == psaUtils.idRTBillable;
            }
        }        
    }
    
    public PageReference setHasChangesBool(){
        hasChangedRows = true; 
        return null;
    }
    
    private Boolean validate() {
        Boolean bResult = true;

        for ( MilestoneWrapper msw: msWrapperList ) { 
            if ( String.isBlank( msw.mStone.Name ) ) {
                msw.mStone.Name.addError( 'You must enter a value.' );
                bResult = false;
            }
            if ( msw.isParent && String.isBlank( msw.mStone.Project_Phase__c ) ) {
                msw.mStone.Project_Phase__c.addError( 'You must select a value.' );
                bResult = false;
            }
        }

        return bResult;
    }

    public PageReference save() {
        this.saveMilestones();
        return null;
    }

    public PageReference saveAndClose() {
        if ( this.saveMilestones() ) {
            return new PageReference( '/' + project.id );
        }
        return null;
    }

    private Boolean saveMilestones(){
        Boolean bResult = false;

        System.debug('calling save method'); 

        if ( !validate() ) {
            return bResult;
        }
        
        this.rollupSummaryFields();

        List<pse__Milestone__c> toSaveMS = new List<pse__Milestone__c>(); 
        List<pse__Milestone__c> toSaveCMS = new List<pse__Milestone__c>();
		set<String> setNewParentNames = new set<String>();
        for ( MilestoneWrapper msw: msWrapperList ) { 
           toSaveMS.add(msw.mStone); 
           if (msw.mStone.Id == null) {
           		setNewParentNames.add(msw.mStone.Name);
           }
        }
        
        map<string,list<Milestone_Template_Items__c>> mapMTIs = new map<string,list<Milestone_Template_Items__c>>();
        for (Milestone_Template_Items__c item:[Select Id, Milestone_Template__c, Name_Prefix__c, Milestone_Template__r.Name
        				FROM Milestone_Template_Items__c WHERE Milestone_Template__r.Name IN :setNewParentNames]) {
        	if (!mapMTIs.containsKey(item.Milestone_Template__r.Name)) mapMTIs.put(item.Milestone_Template__r.Name, new list<Milestone_Template_Items__c>());
        	mapMTIs.get(item.Milestone_Template__r.Name).add(item);
        }
        
        //Do necessary before-save checks: set target date field to end date, and default end date to start date if no end date is present. 
        if ( !toSaveMS.isEmpty() ) {
            //Before-save checks...
            for (pse__Milestone__c ms: toSaveMS){
                if (ms.End_Date__c == null){
                    ms.End_Date__c = ms.Start_Date__c; 
                }
                if (ms.pse__Target_Date__c == null){
                    ms.pse__Target_Date__c = ms.End_Date__c; 
                }
            }
            try {
            	
                upsert toSaveMS;
                
                for (pse__Milestone__c ms: toSaveMS){
	                if (ms.RecordTypeId == psaUtils.idRTParentTask && mapMTIs.containsKey(ms.Name)) {
			        	for (Milestone_Template_Items__c mti:mapMTIs.get(ms.Name)) {
			                toSaveCMS.add(
			                    new pse__Milestone__c(
			                    	Name = mti.Name_Prefix__c,
			                        pse__Project__c = project.id,
			                        Start_Date__c = ms.Start_Date__c,
			                        End_Date__c = ms.End_Date__c,
			                        pse__Target_Date__c = ms.End_Date__c,
			                        RecordTypeId = psaUtils.idRTChildTask,
			                        pse__Closed_for_Time_Entry__c = false,
	                    			pse__Closed_for_Expense_Entry__c = false,
	                    			pse__Exclude_from_Billing__c = ms.pse__Exclude_from_Billing__c,
	                    			pse__Status__c = 'Open',
			                        Parent_Milestone__c = ms.Id
			                    )
			                );
			        	}
			        }
                }
		        if (!toSaveCMS.isEmpty()) upsert toSaveCMS;
		        
                this.createMilestoneList();
            } catch ( Exception ex ) {
                psaUtils.addPageErrorMessage( 'An error occured: ' + ex );
                return bResult;
            }
            for ( MilestoneWrapper msw: msWrapperList ) { 
               msw.isExistingMS = true;
            }
            psaUtils.addPageInfoMessage( 'Saving was successful.' );
            bResult = true;
        } else {
            psaUtils.addPageErrorMessage( 'You currently do not have any milestones to save.  Please add milestones in order to save, otherwise, press Cancel.' );
        }
        
        return bResult; 
    }
    
    public PageReference deleteSelected(){
        System.debug('calling deleteSelected');

        if ( this.deleteSaved() ) {
            this.deleteNotSaved();
            this.clearCheckboxes();
        }

        /*//Build list of selected records
        List<MilestoneWrapper> toDelete = new List<MilestoneWrapper>(); 
        for ( MilestoneWrapper mw: msWrapperList ) {
            if ( mw.isMSChecked && ( !mw.isParent || !mw.isExistingMS ) ) {
                toDelete.add( mw );
            } else {
                psaUtils.addPageErrorMessage( 'You can\'t delete the PARENT Milestones.' );
            }
        }
        
        if ( toDelete.isEmpty() ) {
            psaUtils.addPageErrorMessage( 'Please select at least one Milestone record to delete.' );
            return null;
        }

        
        Boolean bHasError = false;

        List<pse__Milestone__c> finalDelete = new List<pse__Milestone__c>();

        //Ensure that all milestones marked for deletion have a status of canceled
        for ( MilestoneWrapper mw : toDelete ) {
            if ( mw.isExistingMS ) {
                if ( mw.mStone.pse__Status__c != 'Canceled' ) {
                    psaUtils.addPageErrorMessage( 'All milestones MUST have a status of \'Canceled\' in order to be deleted. Please change the status(es) of your milestones and try again.' );
                    mw.mStone.pse__Status__c.addError( 'You must select \'Canceled\' status in order to be deleted.' );
                    bHasError = true;
                } else {
                    finalDelete.add( mw.mStone );
                }
            }
        }

        if ( bHasError ) {
            return null;
        }
        
        
        try {
            //Delete milestones in the database, if any
            if ( !finalDelete.isEmpty() ) {
               delete finalDelete; 
            }
            
            //Remove records from msWrapperList, just in case records don't already exist. They might be persisted by view state, so we need to manually remove
            Integer i = 0;
            while(i < msWrapperList.size()){
                if ( msWrapperList[i].isMSChecked ) {
                    msWrapperList.remove(i);
                } else {
                    ++i;    
                }
            }
            
            clearCheckboxes();

        } catch( Exception ex ) {
            psaUtils.addPageErrorMessage( 'An error occured: ' + ex );
        }*/

        return null;
    }
    
    private void deleteNotSaved() {
        Integer i = 0;
        while( i < msWrapperList.size() ) {
            if ( msWrapperList[ i ].isMSChecked && !msWrapperList[ i ].isExistingMS ) {
                msWrapperList.remove( i );
            } else {
                i++;
            }
        }
    }

    private Boolean deleteSaved() {
        Boolean bResult = true;

        List<pse__Milestone__c> finalDelete = new List<pse__Milestone__c>();

        //Ensure that all milestones marked for deletion have a status of canceled
        for ( MilestoneWrapper mw : this.msWrapperList ) {
            if ( mw.isMSChecked && mw.isExistingMS ) {
                if ( mw.isParent ) {
                    if ( !this.checkStatusToDelete( mw ) ) {
                        bResult = false;
                    }
                    if ( mw.mStone.Budget_Hours__c != null && mw.mStone.Budget_Hours__c != 0 ) {
                        psaUtils.addPageErrorMessage( 'All PARENT milestones should not have a Budget Hours greater than 0 in order to be deleted.' );
                        bResult = false;
                    } else {
                        for ( MilestoneWrapper oChild : this.getChildren( mw.mStone.Id ) ) {
                            if ( !oChild.isMSChecked ) {
                                oChild.isMSChecked = true;
                            }
                        }
                    }
                } else if ( !this.checkChildToDelete( mw ) ) {
                    bResult = false;
                }
                if ( bResult ) {
                    finalDelete.add( mw.mStone );
                }
            }
        }

        if ( bResult && !finalDelete.isEmpty() ) {
            try {
                delete finalDelete;
                //psaProjectRefesh.psaRefreshProject_Milestones( new Set<ID>{ project.id } );
                psaProjectRefesh.refreshProjectFields( new Set<ID>{ project.id } );
            } catch ( Exception e ) {
                psaUtils.addPageErrorMessage( 'Delete Exception: ' + e.getMessage() + '; line: ' + e.getLineNumber() );
                return false;
            }

            Integer i = 0;
            while ( i < msWrapperList.size() ) {
                if ( msWrapperList[ i ].isMSChecked ) {
                    msWrapperList.remove( i );
                } else {
                    i++;
                }
            }
        }

        return bResult;
    }

    private Boolean checkStatusToDelete( MilestoneWrapper oMilestone ) {
        if ( oMilestone.mStone.pse__Status__c != 'Canceled' ) {
            psaUtils.addPageErrorMessage( 'All milestones MUST have a status of \'Canceled\' in order to be deleted. Please change the status(es) of your milestones and try again.' );
            oMilestone.mStone.pse__Status__c.addError( 'You must select \'Canceled\' status in order to be deleted.' );
            return false;
        }
        return true;
    }

    private Boolean checkChildToDelete( MilestoneWrapper oMilestone ) {
        Boolean bResult = checkStatusToDelete( oMilestone );

        if ( oMilestone.mStone.pse__Timecards__r != null && !oMilestone.mStone.pse__Timecards__r.isEmpty() ) {
            psaUtils.addPageErrorMessage( 'You can\'t delete the CHILD Milestones if it has Timecards.' );
            bResult = false;
        }
        if ( oMilestone.mStone.pse__Expense_Reps__r != null && !oMilestone.mStone.pse__Expense_Reps__r.isEmpty() ) {
            psaUtils.addPageErrorMessage( 'You can\'t delete the CHILD Milestones if it has Expense Reports.' );
            bResult = false;
        }
        return bResult;
    }

    private void clearCheckboxes() {
        this.isAllBoxChecked = false;
    }

    public PageReference cancel() {
        return new PageReference( '/' + ApexPages.currentPage().getParameters().get( 'projectID' ) );
    }
    
    /*public PageReference recalculateDates(){
        System.debug('calling recalculate dates'); 
        
        //Declare variables that will be used for iterating through msWrapperList 
        previousMilestoneEndDate = null; 
        Integer count = 0; 
        Integer startingIndex = 0; 
        
        //Find the index of the list that we will start re-calculation of start/end dates
        for (MilestoneWrapper ms: msWrapperList){
            if (ms.isMSChecked == true){
                startingIndex = count; 
                break;
            }
            count++; 
        }
        
        //Make sure index is equal to count if the startingIndex is equal to 0. We don't want anything to happen if the user hasn't selected a row to base the re-calculation upon 
        if (startingIndex == 0 && count != 0){
            psaUtils.addPageErrorMessage( 'A row must be selected as the basis for the date re-calculation. Please select a milestone and try again.' );
            return null; 
        }
        
        //Update msWrapperList objects with new date calculations, based on current values
        for (Integer i = startingIndex; i < msWrapperList.size(); i++){
                if (msWrapperList[i].mStone.Start_Date__c == null){
                        msWrapperList[i].mStone.Start_Date__c = Date.today(); 
                }
            //If this is first iteration, only set end date, otherwise, set start and end date based on duration
            if (i == startingIndex){
                msWrapperList[i].mStone.End_Date__c = msWrapperList[i].mStone.Start_Date__c.addDays((Integer)msWrapperList[i].Duration); 
            }
            else {
                msWrapperList[i].mStone.Start_Date__c = previousMilestoneEndDate; 
                msWrapperList[i].mStone.End_Date__c = msWrapperList[i].mStone.Start_Date__c.addDays((Integer)msWrapperList[i].Duration); 
            }
            
            previousMilestoneEndDate = msWrapperList[i].mStone.End_Date__c; 
        }
        
        //Set hasChangedRows so save button will be enabled
        hasChangedRows = true; 
        
        return null; 
    }*/

    public PageReference addChildTask() {
        System.debug('calling add child task');

        try {
            for ( MilestoneWrapper oItem : this.msWrapperList ) {
                if ( oItem.isMSChecked && oItem.isParent && !oItem.isExistingMS ) {
                    if ( !this.saveMilestones() ) {
                        return null;
                    }
                    break;
                }
            }
            
            List<MilestoneWrapper> aResult = new List<MilestoneWrapper>();

            for ( MilestoneWrapper oItem : this.msWrapperList ) {
                aResult.add( oItem );               
                if ( oItem.mStone.Id != null ) {
                    oItem.isExistingMS = true;
                    if ( oItem.isMSChecked && oItem.isParent ) {
                        aResult.add(
                            new MilestoneWrapper( 
                                new pse__Milestone__c(
                                    pse__Project__c = project.id,
                                    Start_Date__c = Date.today(),
                                    End_Date__c = Date.today(),
                                    pse__Target_Date__c = Date.today(),
                                    RecordTypeId = psaUtils.idRTChildTask,
                                    pse__Closed_for_Time_Entry__c = false,
	                				pse__Closed_for_Expense_Entry__c = false,
                                    Parent_Milestone__c = oItem.mStone.Id
                                )
                            )
                        );
                    }
                }
            }
			
            if ( this.msWrapperList.size() < aResult.size() ) {
                this.hasChangedRows = true;
                this.msWrapperList = aResult;
            } else {
                psaUtils.addPageErrorMessage( 'Please select parent milestones and try again.' ); 
            }
        } catch ( Exception e ) {
            psaUtils.addPageErrorMessage( e.getMessage() + '; line: ' + e.getLineNumber() ); 
        }

        return null;
    }

    public PageReference addParentTask() {
        System.debug('calling add parent task');
		
        this.msWrapperList.add(
            new MilestoneWrapper( 
                new pse__Milestone__c(
                    pse__Project__c = project.id,
                    Start_Date__c = Date.today(),
                    End_Date__c = Date.today(),
                    pse__Target_Date__c = Date.today(),
                    pse__Closed_for_Time_Entry__c = false,
	                pse__Closed_for_Expense_Entry__c = false,
                    RecordTypeId = psaUtils.idRTParentTask
                )
            )
        );
        
        //Make sure hasChangedRows is set to true so save button is enabled
        this.hasChangedRows = true;

        return null;
    }

    public PageReference refreshProject() {
        psaProjectRefesh.psaRefreshProjectFuture( new Set<ID>{ this.project.Id } );
        psaUtils.addPageInfoMessage( 'Project will be refreshed as soon as possible.' );
        return null;
    }

    /*public PageReference applyTemplate(){
        //Get collection of MilestoneTemplateItems associated with the selected template
        List<Milestone_Template_Items__c> msTemplateItems = new List<Milestone_Template_Items__c>(); 
        msTemplateItems = [select name, Name_Prefix__c, duration__c, WBS__c, Default_Status__c from Milestone_Template_Items__c msi where msi.Milestone_Template__r.id = :selectedMSTemplate order by WBS__c asc]; 
        
        Integer count = 1; 
        
        //Iterate through Template Items collection and add new Milestone to msWrapper collection for each item, with correct defaults
        for (Milestone_Template_Items__c msi: msTemplateItems){
            pse__Milestone__c ms = new pse__Milestone__c(pse__Project__c = project.id); 
            
            //Set default values for fields 
            ms.Name = msi.Name_Prefix__c + ' - ' + msi.Name; 
            ms.pse__Status__c = msi.Default_Status__c; 
            
            //If this is the first milestone created by template, set the start date based on "First Milestone Date" field. If not, set start date based on end date of previous milestone
            if (count == 1){
                ms.Start_Date__c = throwawayContact.BirthDate; 
            }
            
            else {
                ms.Start_Date__c = previousMilestoneEndDate; 
            }
            
            if(ms.Start_Date__c == null)
            {
                ms.Start_Date__c = date.today();
            }
            
            //Set Milestone End Date equal to Start date plus duration. If end date is less than start date 
            ms.End_Date__c = ms.Start_Date__c.addDays((Integer)msi.Duration__c); 
            
            //Set Milestone Target Date, it's a required field. We're going to default it to the End Date as defined by the user on this page
            ms.pse__Target_date__c = ms.End_Date__c; 
            
            //Create new MilestoneWrapper class based on milestone that was just created
            MilestoneWrapper msWrapper = new MilestoneWrapper(ms); 
            msWrapper.duration = (Integer)msi.Duration__c; 
            msWrapper.isExistingMS = false; 
            
            //Add MilestoneWrapper to MilestoneWrapper list so it will appear in datatable
            msWrapperList.add(msWrapper); 
            
            count++; 
            previousMilestoneEndDate = ms.End_Date__c; 
            
            //Set haschanges equal to true so save button is enabled
            hasChangedRows = true; 
        }
        
        return null; 
    }*/
}