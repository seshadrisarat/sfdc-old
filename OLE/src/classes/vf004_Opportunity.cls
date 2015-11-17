global class vf004_Opportunity {
    static boolean bCompleted_Before_Update=false;
    static boolean bCompleted_Before_Insert=false;

//PML-{000000} for the clear file 
    public static integer CURRENT_PML_COUNT { //current PML closed opportunity counter
        get {
            F8_Integration__c objCustomSetting=F8_Integration__c.getInstance('F8 Config Parameter-CURRENT_PML_COUNT');
            if(objCustomSetting==null) {
                objCustomSetting=new F8_Integration__c(name='F8 Config Parameter-CURRENT_PML_COUNT', Value__c='0');
                insert objCustomSetting;
            }
            return integer.valueof(objCustomSetting.Value__c); 
        } 
    }
    public static void  Save_CURRENT_PML_COUNT (integer iNewValue) {
            F8_Integration__c objCustomSetting=F8_Integration__c.getInstance('F8 Config Parameter-CURRENT_PML_COUNT');
            objCustomSetting.Value__c=string.valueof(iNewValue);
            update objCustomSetting;            
    }
    
    public static string AllocateNew_PML_COUNT() {
        integer iNewCount=CURRENT_PML_COUNT+1;
        Save_CURRENT_PML_COUNT(iNewCount);
        string sNew_PML_COUNT=string.valueof(iNewCount);
        if(sNew_PML_COUNT.length() < 6) sNew_PML_COUNT=('000000'+sNew_PML_COUNT).right(6);
        return 'PML-'+sNew_PML_COUNT;
    }

    //SL-{000000} for LP file
    public static integer CURRENT_SL_COUNT { //current PML closed opportunity counter
        get {
            F8_Integration__c objCustomSetting=F8_Integration__c.getInstance('F8 Config Parameter-CURRENT_SL_COUNT');
            if(objCustomSetting==null) {
                objCustomSetting=new F8_Integration__c(name='F8 Config Parameter-CURRENT_SL_COUNT', Value__c='0');
                insert objCustomSetting;
            }
            return integer.valueof(objCustomSetting.Value__c); 
        } 
    }
    public static void  Save_CURRENT_SL_COUNT (integer iNewValue) {
            F8_Integration__c objCustomSetting=F8_Integration__c.getInstance('F8 Config Parameter-CURRENT_SL_COUNT');
            objCustomSetting.Value__c=string.valueof(iNewValue);
            update objCustomSetting;            
    }
    
    public static string AllocateNew_SL_COUNT() {
        integer iNewCount=CURRENT_SL_COUNT+1;
        Save_CURRENT_SL_COUNT(iNewCount);
        string sNew_SL_COUNT=string.valueof(iNewCount);
        if(sNew_SL_COUNT.length() < 6) sNew_SL_COUNT=('000000'+sNew_SL_COUNT).right(6);
        return 'SL-'+sNew_SL_COUNT;
    }    

    public static List<recordtype> lrt=new List <recordtype>([select id, Name, SobjectType from recordtype where SobjectType IN ('Opportunity') AND (Name LIKE 'PML%' OR Name LIKE 'Sync%')]);
    
    public static set<Id> st_LP_Sync_Opportunity_RecordTypeID {
        get {
            if(st_LP_Sync_Opportunity_RecordTypeID==null) {
                st_LP_Sync_Opportunity_RecordTypeID=new set<Id>();
                for(recordtype rt: lrt) { if(rt.Name.startsWith('Sync')) { st_LP_Sync_Opportunity_RecordTypeID.add(rt.Id); } }
            }
            return st_LP_Sync_Opportunity_RecordTypeID;
        } set;
    }
    
    public static set<Id> st_Clear_PML_Opportunity_RecordTypeID {
        get {
            if(st_Clear_PML_Opportunity_RecordTypeID==null) {
                st_Clear_PML_Opportunity_RecordTypeID=new set<Id>();
                for(recordtype rt: lrt) { if(rt.Name.startsWith('PML')) { st_Clear_PML_Opportunity_RecordTypeID.add(rt.Id); } }
            }
            return st_Clear_PML_Opportunity_RecordTypeID;           
        } set;
    }
    
    public static void tr_Before_Update(List<Opportunity> triggerNew, List<Opportunity> triggerOld, Map<Id,Opportunity> triggerNewMap, Map<Id,Opportunity> triggerOldMap) {
        if(bCompleted_Before_Update==true) return; 
        for(Opportunity op_new: triggerNew) {
            Opportunity op_old=triggerOldMap.get(op_new.Id);
            if(
                (op_old.StageName != op_new.StageName || op_new.RecordTypeId != op_old.RecordTypeID) 
                && op_new.Opportunity_Number__c==null
                && op_new.IsWon==true
            ) {
                if( st_LP_Sync_Opportunity_RecordTypeID.contains(op_new.RecordTypeId) ) { op_new.Opportunity_Number__c=AllocateNew_SL_COUNT(); } //SL-{000000} for LP file 
                if( st_Clear_PML_Opportunity_RecordTypeID.contains(op_new.RecordTypeId) && op_new.StageName=='6-Closed/Won Invoiced') { op_new.Opportunity_Number__c=AllocateNew_PML_COUNT(); } //PML-{000000} for the clear file
            }
        }
        bCompleted_Before_Update=true;
    }
    
    public static void tr_Before_Insert(List<Opportunity> triggerNew, List<Opportunity> triggerOld, Map<Id,Opportunity> triggerNewMap, Map<Id,Opportunity> triggerOldMap) {
        if(bCompleted_Before_Insert==true) return; 
        for(Opportunity op_new: triggerNew) {
            if(
                op_new.Opportunity_Number__c==null
                && op_new.IsWon==true
            ) {
                if( st_LP_Sync_Opportunity_RecordTypeID.contains(op_new.RecordTypeId) ) op_new.Opportunity_Number__c=AllocateNew_SL_COUNT(); //SL-{000000} for LP file
                if( st_Clear_PML_Opportunity_RecordTypeID.contains(op_new.RecordTypeId) && op_new.StageName=='6-Closed/Won Invoiced' ) op_new.Opportunity_Number__c=AllocateNew_PML_COUNT(); //PML-{000000} for the clear file 
            }
        }
        bCompleted_Before_Insert=true;
    }   
}