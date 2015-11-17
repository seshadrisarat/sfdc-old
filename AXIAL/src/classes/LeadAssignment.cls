/*
    When lead is owned by AB, must still set MOA (or Secondary AE)
*/

public without sharing class LeadAssignment {
    public LeadAssignment() {
    }

    public static string MOA_PREFIX = 'MOA -';
    public static string AE_PREFIX  = 'AE -';
    public static User FOGEL  = [SELECT ID FROM User WHERE UserRole.Name = 'MOA - Inbound' LIMIT 1];

    private static Boolean firstPass = true;
    public static Boolean firstPass(){ return firstPass; }

    public static Map<Id, User> allUsers;
    public static List<User> reps;
    public static Map<String, RepTeam> repTeams;
    public static Set<String> teams;
    public static Map<Id, User> repMap;
    
    // Added as per AXIAL-2
    public static List<SObject> rotateOwner(Map<Id, SObject> triggerOldMap, Map<Id, SObject> maplstOfSobjRecs){
        // If oldMap isEMpty will not execute anything
        if(triggerOldMap.isEMpty())
            return new List<Sobject>();
            
        // List<SObject> lstUpdatedMqField = new List<SObject>();
        Set<String> setOfInputRoles = new Set<String>();
        
        for(SObject objRecs : maplstOfSobjRecs.values()){
           // Checking if the "Marketo_lastMQLdate__c" field changed then only adding into the new List
            if(objRecs.get('Lead_Rotator_Role_Name__c') != NULL && objRecs.get('Lead_Rotator_Role_Name__c') != '' && mqlFieldChanged(triggerOldMap, objRecs))
            {    
            	// lstUpdatedMqField.add(objRecs);
            	setOfInputRoles.add(String.valueOf(objRecs.get('Lead_Rotator_Role_Name__c')));
            }
            else{
            	maplstOfSobjRecs.remove(objRecs.Id);
            }
        }
        
        if(maplstOfSobjRecs.isEmpty() || setOfInputRoles.isEmpty())
            return new List<Sobject>();
        
        
        Map<String, User> mapOfUserRolesToListRecentUpdatedUsers = new Map<String, User>();
        List<SObject> lstUpdatedRecs = new List<SObject>();
        List<User> lstUsersToUpdate = new List<User>();
        
        for(User objUser : [Select UserRole.Name, Last_Lead_Assigned_Date__c 
                            From User /* Removed UserRole.Name!=NULL check from the SOQL since Name is required field for any object in salesforce - Updated By Pankaj Ganwani on 30/JUNE/2015 */
                            where UserRole.Name IN : setOfInputRoles AND isActive = true/* isActive check is added by Pankaj Ganwani on 29/JUNE/2015 to fetch the Active User records only because inactive user cannot hold the ownership of record.*/
                            	  AND Eligible_To_Receive_Leads__c = true
                            order By Last_Lead_Assigned_Date__c ASC NULLS LAST])
        {
        	if(!mapOfUserRolesToListRecentUpdatedUsers.containsKey(objUser.UserRole.Name))
        		mapOfUserRolesToListRecentUpdatedUsers.put(objUser.UserRole.Name, objUser);
        }
        
        // If no users found for the given Role.
        if(mapOfUserRolesToListRecentUpdatedUsers.isEmpty())
        	return new List<Sobject>();
        	
        Id objId = maplstOfSobjRecs.values()[0].Id; 
        String strName = String.valueOf(objId.getSobjectType());
        
        ///Set<Id> setSObjectRecIds = new Set<Id>();
        //setSObjectRecIds.addAll(maplstOfSobjRecs.keySet());
        
        //String strQuery = String.format('Select Id, OwnerId, Owner.UserRole.Name From {0} Where Id IN : setSObjectRecIds', new List<String> {strName}); 
        //system.debug('strQuery====>' +strQuery);
        
        
        
        if(strName.equals('Contact')){
        	for(Contact objContact : [Select Id, LastName, OwnerId, Owner.UserRole.Name From Contact Where Id IN : maplstOfSobjRecs.keySet()])
	        {
	        	if(objContact.Owner.UserRole.Name.contains(AE_PREFIX))
	        	{
	        		if(maplstOfSobjRecs.containsKey(objContact.Id))
	        			maplstOfSobjRecs.remove(objContact.Id);
	        	}
	        }
        }
        else if(strName.equals('Lead')){
        	for(Lead objLead : [Select Id, LastName, OwnerId, Owner.UserRole.Name From Lead Where Id IN : maplstOfSobjRecs.keySet()])
	        {
	        	if(objLead.Owner.UserRole.Name.contains(AE_PREFIX))
	        	{
	        		if(maplstOfSobjRecs.containsKey(objLead.Id))
	        			maplstOfSobjRecs.remove(objLead.Id);
	        	}
	        }
        }
        
        for(SObject objRecs : maplstOfSobjRecs.values()){
        	if(mapOfUserRolesToListRecentUpdatedUsers.containsKey(String.valueOf(objRecs.get('Lead_Rotator_Role_Name__c'))))
        	{
        		objRecs.put('OwnerId', mapOfUserRolesToListRecentUpdatedUsers.get(String.valueOf(objRecs.get('Lead_Rotator_Role_Name__c'))).Id);/* Updated By Pankaj Ganwani on 29/JUNE/2015 to assign Id to OwnerId field instead of assigning whole User object record.*/
        		lstUpdatedRecs.add(objRecs);
        		mapOfUserRolesToListRecentUpdatedUsers.get(String.valueOf(objRecs.get('Lead_Rotator_Role_Name__c'))).Last_Lead_Assigned_Date__c = DateTime.Now();
        	}
        }
        
        update mapOfUserRolesToListRecentUpdatedUsers.values();
        return lstUpdatedRecs;
    }
    
    
    public static void assignLeads(List<SObject> triggerNew, Map<Id, SObject> triggerOldMap, Boolean isInsert){

        Boolean runTwice = false;
        if(firstPass()){
            
            allUsers = new Map<Id, User>(
                [SELECT Id, UserRole.Name, Sales_Pod__c, MOA__c 
                FROM User 
                WHERE isActive = true]);
            reps = eligibleReps();

            repTeams = new Map<String, RepTeam>();
            teams = new Set<String> { 'AE - IBA Team', 
                                       'MOA - IBA', 
                                       'AE - PCM Team', 
                                       'MOA - PCM', 
                                       'AE - Private Companies Team', 
                                       'AE - Strategics Team', 
                                       'MOA - Strategics' };
            for(String t :teams){
                RepTeam rt = new RepTeam();
                repTeams.put(t, rt);
            }

            List<User> companies2List = companiesSecondaryList();
            RepTeam companies2 = new RepTeam(companies2List);
            repTeams.put('Companies Secondary', companies2);
     
            repMap = new Map<Id, User>();
            for(User u :reps){
                if(teams.contains(u.UserRole.Name)){
                    repMap.put(u.Id, u);
                    RepTeam rt = repTeams.get(u.UserRole.Name);
                    rt.addToTeam(u);
                }
            }

            for(SObject leed :triggerNew){
                if(!(String.valueOf(leed.get('Email')) == 'marketing@axial.net')){
                    String lastMQLTitle = String.valueOf(leed.get('Marketo_lastMQLtitle__c'));
                    // Determine Team
                    String team = '';
                    String ilrtMaster = String.ValueOf(leed.get('Inbound_Lead_Record_Type_Master__c'));
                    String transTypes = String.ValueOf(leed.get('Transaction_types__c'));

                    Set<String> nonAquisitiveTransactionTypes = new Set<String>{ 'Sell Companies', 'Raise Capital', 'Exploring Options' };
                    Set<String> pcmMatches = new Set<String>{'PE', 'Professional Investor/Lender', 'Professional Investor'};
                    Set<String> ibaMatches = new Set<String>{'IB', 'AB', 'Investment Banker', 'Business Broker'};
                    Set<String> pcsMatches = new Set<String>{'CA', 'Corp Dev Professional', 'CEO/CFO/President'};


                    if(leed.getSObjectType() == Contact.getSObjectType()){
                        if(leed.get('valuation_tool_valuation_id_c__c') != null){
                            if(nonAquisitiveTransactionTypes.contains(transTypes)){
                                team = 'AE - Private Companies Team';
                            }else{
                                team = 'MOA - Strategics';
                            }
                        }
                    }

                    if(pcmMatches.contains(ilrtMaster)){
                        team = 'AE - PCM Team';
                    }else if(ibaMatches.contains(ilrtMaster)){
                        team = 'AE - IBA Team';
                    }else if(pcsMatches.contains(ilrtMaster)){
                        if( nonAquisitiveTransactionTypes.contains(transTypes) ){
                            team = 'AE - Private Companies Team';
                        }else{
                            team = 'MOA - Strategics';
                        }
                    }

                    if(
                        (isInsert && leed.get('Marketo_lastMQLdate__c') != null) || 
                        (!isInsert && mqlFieldChanged(triggerOldMap, leed)) || 
                        (
                            leed.getSObjectType() == Contact.getSObjectType() && 
                            (leed.get('valuation_tool_valuation_id_c__c') != null)
                        ) || 
                        (isInsert && leed.get('Self_Signup_Date__c') != null) ||
                        (!isInsert && selfSignupFieldChanged(triggerOldMap, leed))
                    ){

                        /* 
                            This is a hack to get upserts to work.
                            Currently only self signup date uses upserts as
                            they comes from api calls via the sync.
                        */
                        if((isInsert && leed.get('Self_Signup_Date__c') != null) ||
                        (!isInsert && selfSignupFieldChanged(triggerOldMap, leed))){
                            runTwice = true;
                        }

                        if(team == 'AE - Private Companies Team'){
                            if(ownerIsAE(leed)){
                                String name = String.valueOf(leed.get('OwnerId'));
                                User owner = allUsers.get(name);
                                String moaId = owner.MOA__c;
                                leed.put('Moa__c', moaId);
                            }else{
                                RepTeam repT;
                                if(lastMQLTitle != null && lastMQLTitle.contains('Request')){
                                    repT = repTeams.get('AE - Private Companies Team');
                                }else{
                                    repT = repTeams.get('Companies Secondary');
                                }

                                if(repT != null){
                                    User nextEligibleRep = repT.nextUser();
                                    leed.put('OwnerId', nextEligibleRep.id);
                                    String moaId = nextEligibleRep.MOA__c;
                                    leed.put('MOA__c', moaId);
                                    repT.incrementIndex();                                
                                    nextEligibleRep.Last_Lead_Assigned_Date__c = DateTime.now();
                                }
                            }
                        }else if(team == 'AE - PCM Team' || team == 'AE - IBA Team' || team == 'MOA - Strategics'){
                                RepTeam repT = repTeams.get(team);
                                User nextEligibleRep = null;
                                if(repT != null) {
                                    nextEligibleRep = repT.nextUser();
                                }
                                
                                if(lastMQLTitle != null &&
                                   lastMQLTitle.contains('Request')){

                                    User owner = new User();
                                    if(ownerIsAE(leed)){
                                        String oid = String.valueOf(leed.get('OwnerId'));
                                        owner = allUsers.get(oid);
                                        leed.put('Moa__c', FOGEL.ID);
                                    }else{
                                        leed.put('OwnerId', FOGEL.ID);
                                        leed.put('Moa__c', FOGEL.ID);
                                    }                                   
                                }else{
                                    User owner = new User();
                                    if(ownerIsAE(leed)){
                                        String oid = String.valueOf(leed.get('OwnerId'));
                                        owner = allUsers.get(oid);
                                        leed.put('Moa__c', owner.MOA__c);
                                    }else{
                                        owner = nextEligibleRep;
                                        leed.put('OwnerId', nextEligibleRep.id);
                                        leed.put('Moa__c', nextEligibleRep.MOA__c);
                                        repT.incrementIndex();
                                        nextEligibleRep.Last_Lead_Assigned_Date__c = DateTime.now();                                
                                    }  
                                }
                        }
                    }
                }
            }
            update reps;
            update repTeams.get('Companies Secondary').getTeam();
        }

        if(!runTwice){
            firstPass = false;
        }// I know right
    }




    /* Helpers */

    public static Boolean ownerIsAE(SObject leed){
        User owner = allUsers.get(String.valueOf(leed.get('OwnerId')));
        if(owner != null && owner.UserRoleId != null){
            String ownerRole = String.valueOf(owner.UserRole.Name);
            Boolean isAE = ownerRole.contains('AE');
            Boolean isMGR = ownerRole.contains('MGR');
            return (isAE|| isMGR);           
        }else{
            return false;
        }
    }

    public static Boolean ownerIsMOA(SObject leed){
        User owner = allUsers.get(String.valueOf(leed.get('OwnerId')));
        return (
            owner != null &&
            owner.UserRoleId != null && 
            String.valueOf(owner.UserRole.Name).contains('MOA')
        );
    }

    public static List<User> eligibleReps(){
        return [SELECT Id, Sales_Pod__c, MOA__c, Last_Lead_Assigned_Date__c, Last_Secondary_Lead_Assigned__c, MOA__r.Name, MOA__r.Id, UserRole.Name
                    FROM  User 
                    WHERE Eligible_To_Receive_Leads__c = true
                    AND isActive = true
                    ORDER BY Last_Lead_Assigned_Date__c ASC];
    }

    public static Boolean marketoFieldsChanged(Map<Id, SObject> triggerOldMap, SObject leed){
        SObject oldLead = triggerOldMap.get(String.valueOf(leed.get('id')));

        Boolean rsvpChanged = oldLead.get('Count_Last_RSVP_Date__c') != leed.get('Count_Last_RSVP_Date__c');
        Boolean eventChanged = oldLead.get('Count_Last_Attended_Date__c') != leed.get('Count_Last_Attended_Date__c');
        Boolean webinarChanged = oldLead.get('Count_Last_Webinar_Date__c')  != leed.get('Count_Last_Webinar_Date__c');
        Boolean downloadChanged = oldLead.get('Count_Last_Download_Date__c') != leed.get('Count_Last_Download_Date__c');
        return ( rsvpChanged || eventChanged || webinarChanged || downloadChanged );
    }

    public static Boolean mqlFieldChanged(Map<Id, SObject> triggerOldMap, SObject leed){
        SObject oldLead = triggerOldMap.get(String.valueOf(leed.get('id')));
        Object oldLeadLastMQL = oldLead.get('Marketo_lastMQLdate__c');
        Object newLeadLastMQL = leed.get('Marketo_lastMQLdate__c');

        return (newLeadLastMQL != oldLeadLastMQL);
    }

    public static Boolean selfSignupFieldChanged(Map<Id, SObject> triggerOldMap, SObject leed){
        SObject oldLead = triggerOldMap.get(String.valueOf(leed.get('id')));
        Object oldSS = oldLead.get('Self_Signup_Date__c');
        Object newSS = leed.get('Self_Signup_Date__c');

        return (oldSS != newSS);
    }

    public static List<User> companiesSecondaryList(){
        return [SELECT Id, Last_Secondary_Lead_Assigned__c, MOA__c, UserRole.Name
                    FROM User
                    WHERE Eligible_To_Receive_Leads__c = true
                    AND UserRole.Name = 'AE - Private Companies Team'
                    AND isActive = true
                    ORDER By Last_Secondary_Lead_Assigned__c ASC];
    }

    private class RepTeam{

        private RepTeam(){
            index = 0;
            team = new List<User>();
        }

        private RepTeam(List<User> t){
            index = 0;
            team = t;
        }

        private Integer index;

        public void incrementIndex(){
            index = (index < team.size()-1 ? index+1 : 0);
        }
        
        private List<User> team;
        
        public List<User> getTeam(){
            return team;
        }

        public void addToTeam(User u){
            team.add(u);
        }

        public User nextUser(){
            return team.get(index);
        }
    }
}