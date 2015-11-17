/*
 * \author Vladimir Dobrelya, Julia Kolesnik
 * \see https://silverline.jira.com/browse/SLFF-24
 * \TODO: rewrite this whole thing
 */
public class psaProjectSetup {
    public static Boolean isService                         {get;set;}
    public static map<string, set<string>> mapOLIPhases     {get;set;}
    public static Date dEventHorizon                        {get;set;}
    private static map<id,set<string>> mapProductPhases     {get;set;}
    private static map<id,id> mapOppProject                 {get;set;}
    public static map<string,string> mapFieldNameByLabel            {get;set;}
    public static map<string, pse__Milestone__c>    mapParentMilestones         {get;set;}
    public static map<string, pse__Milestone__c>    mapChildMilestones          {get;set;}
    public static map<Id,map<string, decimal>>      mapProjectRates             {get;set;}
    

    public static List<pse__Milestone__c> psaBuildParentTaskMilestones( List<pse__Proj__c> aProjects ) {
        List<pse__Milestone__c> aResult = new List<pse__Milestone__c>();

        Map<ID, List<OpportunityLineItem>> aProjectId_OppLineItems = getOppLineItemsByProject( aProjects );
        Map<ID, Date> aProjectId_DefaultTargetDates = getDefaultTargetDates( aProjects );
        Map<Id, Boolean> mapProjectIsFixedFee = getIsFixedFee( aProjects );
        Map<ID, Date> aProjectId_DefaultEndDates = new Map<ID, Date>();
        
        
        set<Id> setProjectIds = new set<Id>();
        for (pse__Proj__c item:aProjects) {
            setProjectIds.add(item.Id);
            aProjectId_DefaultEndDates.put(item.Id, item.pse__End_Date__c);
        }
        
        //to find Opps before EventHorizon
        dEventHorizon = null;
        Map<String, JfrsnSettings__c> mapOCF = JfrsnSettings__c.getAll();
        if (mapOCF.containsKey('standard')) {
            dEventHorizon = mapOCF.get('standard').EventHorizon__c;
        }
        
        //we need to get new list of Projects (with pse__Opportunity__r.CreatedDate)
        List<pse__Proj__c> lstProjects = getProjectByIds(setProjectIds);
        Map<Id, Boolean> mapProjectIsWithOCF = getIsWithOCF( lstProjects );
        
        isService = true;
        
        Map<Id, list<pse__Project_Phase__c>> mapProjectPhases = getProjectPhases(setProjectIds, mapProjectIsWithOCF);
        
        mapParentMilestones = getParentMilestoneKeys(setProjectIds);
        //to set Rates on the Project
        mapProjectRates = new map<Id,map<string, decimal>>();
        
        Map<ID, List<OpportunityLineItem>> mapProjectIdAllOLI = getAllOppLineItemsByProject(setProjectIds);
        for ( ID idProject : aProjectId_OppLineItems.keySet() ) {
            if (mapProjectPhases.containsKey(idProject)) {
                aResult.addAll( convertOppLineItemsToMilestones( idProject, aProjectId_OppLineItems.get( idProject ), mapProjectIdAllOLI.get(idProject), mapProjectPhases.get(idProject), aProjectId_DefaultTargetDates.get( idProject ), aProjectId_DefaultEndDates.get( idProject ), mapProjectIsFixedFee.get(idProject), mapProjectIsWithOCF.get(idProject) ) );
            }
        }
        
        //psaUpdateProjectRates(lstProjects);
        
        return aResult;
    }
    
    public static List<pse__Milestone__c> convertOppLineItemsToMilestones( ID idProject, List<OpportunityLineItem> lstOLI, List<OpportunityLineItem> lstAllOLI, list<pse__Project_Phase__c>lstPP, Date dDefaultTargetDate, Date dDefaultEndDate, boolean isFixedFee, boolean isWithOCF) {
        system.debug(LoggingLevel.ERROR, 'idProject: ' + JSON.serialize(idProject));
        system.debug(LoggingLevel.ERROR, 'lstOLI: ' + JSON.serialize(lstOLI));
        system.debug(LoggingLevel.ERROR, 'lstAllOLI: ' + JSON.serialize(lstAllOLI));
        system.debug(LoggingLevel.ERROR, 'isWithOCF: ' + JSON.serialize(isWithOCF));
        system.debug(LoggingLevel.ERROR, 'isFixedFee: ' + JSON.serialize(isFixedFee));
        system.debug(LoggingLevel.ERROR, 'dDefaultEndDate: ' + JSON.serialize(dDefaultEndDate));
        system.debug(LoggingLevel.ERROR, 'dDefaultTargetDate: ' + JSON.serialize(dDefaultTargetDate));
        system.debug(LoggingLevel.ERROR, 'lstPP: ' + JSON.serialize(lstPP));
        system.debug(LoggingLevel.ERROR, 'lstAllOLI: ' + JSON.serialize(lstAllOLI));

        list<pse__Milestone__c> lstMilestones = new list<pse__Milestone__c>();
        map<string,Id> mapProjectPhaseIds = new map<string,Id>();
        if (lstPP==null||lstPP.isEmpty()) return lstMilestones;
        
        for (pse__Project_Phase__c item:lstPP) {
            mapProjectPhaseIds.put(item.Template_Key__c, item.Id);
        }
        
        pse__Milestone__c newMilestone;
        pse__Milestone__c oldMilestone;
        Id phaseId;
        string key;
        string olikey;
    

        system.debug(LoggingLevel.ERROR, mapProjectPhaseIds);
        system.debug(LoggingLevel.ERROR, mapProductPhases);
        system.debug(LoggingLevel.ERROR, lstAllOLI);
        
        map<string, decimal> mapCurProjectRates = new map<string, decimal>();

        map<string,list<decimal>> mapKey_Quantity = new map<string,list<decimal>>();
        map<string,list<decimal>> mapKey_Amount = new map<string,list<decimal>>();
        for (OpportunityLineItem item:lstAllOLI) {
            //if (mapProductPhases.containsKey(item.PricebookEntry.Product2Id)) {
                //for (string phase:mapProductPhases.get(item.PricebookEntry.Product2Id)) {
                    //if (mapProjectPhaseIds.containsKey(phase+'-'+idProject)) phaseId = mapProjectPhaseIds.get(phase+'-'+idProject);
                    //else phaseId = null;
                    //system.debug(LoggingLevel.ERROR, phaseId);
                    //todo: prevent phaseId = null in logic
                    //key = phaseId + '-' + idProject + '-' + item.PricebookEntry.Product2Id;//+ '-' + item.UnitPrice;
                    key = idProject + '-' + item.PricebookEntry.Product2Id;//+ '-' + item.UnitPrice;
                    if (!mapKey_Quantity.containskey(key))  mapKey_Quantity.put(key,new list<decimal>());
                    mapKey_Quantity.get(key).add(item.Quantity);
                    if (!mapKey_Amount.containskey(key))  mapKey_Amount.put(key,new list<decimal>());
                    mapKey_Amount.get(key).add(item.TotalPrice);
                //}
            //}
            
            if (!mapCurProjectRates.containsKey(item.Role__c)) {
                mapCurProjectRates.put(item.Role__c, item.UnitPrice);
            }
        }
        
        mapProjectRates.put(idProject, mapCurProjectRates);
        if(isWithOCF == null) isWithOCF = false;
        
        if(mapOLIPhases != null ) {
            for (OpportunityLineItem item:lstOLI) {
                if (mapProductPhases.containsKey(item.PricebookEntry.Product2Id)) {
                    for (string phase:mapProductPhases.get(item.PricebookEntry.Product2Id)) {
                        //because now many MTIs have empty Phases
                        //if(phase==null) continue;
                        system.debug(LoggingLevel.ERROR, JSON.serialize(item));
                        system.debug(LoggingLevel.ERROR, 'mapOLIPhases: ' + mapOLIPhases);
                        olikey = item.OpportunityId + '' + item.PricebookEntry.Product2Id;
                        
                        //Daniel's variant(?) but it doesn't work for CO
                        //if (mapOLIPhases.containsKey(olikey) && (mapOLIPhases.get(olikey).contains(phase)||!isWithOCF)) {
                        
                        //to create (only Milestones for which we have OCF) OR (if they wrere created before EVENtHorizon - without OCF logic)
                        if (mapOLIPhases.containsKey(olikey) && (mapOLIPhases.get(olikey).contains(phase))||!isWithOCF) {
                            if (mapProjectPhaseIds.containsKey(phase+'-'+idProject)) phaseId = mapProjectPhaseIds.get(phase+'-'+idProject);
                            else phaseId = null;
                            //todo: prevent phaseId = null in logic
                            //key = phaseId + '-' + idProject + '-' + item.PricebookEntry.Product2Id; // + '-' + item.UnitPrice;
                            key = idProject + '-' + item.PricebookEntry.Product2Id; // + '-' + item.UnitPrice;
                            newMilestone = getMilestoneByKey(phaseId, phase, idProject, item.PricebookEntry.Product2Id, item.UnitPrice, dDefaultTargetDate, dDefaultEndDate, isFixedFee, item);
                            mapParentMilestones.put(key,newMilestone);
                            system.debug(LoggingLevel.ERROR, mapKey_Quantity);
                            
                            newMilestone.Budget_Hours__c = 0;
                            if (mapKey_Quantity.containsKey(key)) {
                                for (Decimal qty:mapKey_Quantity.get(key)){
                                    newMilestone.Budget_Hours__c += qty;
                                }
                            } else {
                                newMilestone.Budget_Hours__c += item.Quantity;
                            }
                            
                            newMilestone.pse__Milestone_Amount__c = 0;
                            if (mapKey_Amount.containsKey(key)) {
                                for (Decimal totalprice:mapKey_Amount.get(key)){
                                    newMilestone.pse__Milestone_Amount__c += totalprice;
                                }
                            } else {
                                newMilestone.pse__Milestone_Amount__c += item.TotalPrice;
                            }
                        }
                    }
                } 
            }
        }
         system.debug(LoggingLevel.ERROR, mapParentMilestones);
        return mapParentMilestones.values();
    }
    
    //private static Map<Id, decimal> getSumBudgetHoursPerProduct(List<OpportunityLineItem> lstOLI) {
    //  Map<Id, decimal> aggr = new Map<Id, decimal>();

    //  for(OpportunityLineItem o : lstOLI)
    //  {
    //      aggr.put(o.PricebookEntry.ProductId, aggr.get(o.PricebookEntry.ProductId) == null ? 0 : aggr.get(o.PricebookEntry.ProductId).Budget_Hours__c + o.Budget )
    //  }
    //}

    public static map<id,list<pse__Project_Phase__c>> getProjectPhases(set<Id> setProjectIds, Map<Id, Boolean> mapProjectIsWithOCF) {
        map<id,list<pse__Project_Phase__c>> result = new map<id,list<pse__Project_Phase__c>>();
        
        mapOppProject = getOppProject(setProjectIds);
        mapOLIPhases = getOLIPhases(setProjectIds);
        
        set<Id> setProductIds = new set<Id>();
        map<Id, set<string>> setNeededProjectPhases = new map<Id, set<string>>();
        Id tmpProjId = null;
        for (OpportunityLineItem item:[Select Id, PricebookEntry.Product2Id, OpportunityId FROM OpportunityLineItem
                                WHERE OpportunityId IN :mapOppProject.keySet()]) {
            setProductIds.add(item.PricebookEntry.Product2Id);
            if (mapOLIPhases.containsKey(item.OpportunityId+''+item.PricebookEntry.Product2Id)) {
                tmpProjId = mapOppProject.get(item.OpportunityId);
                if (!setNeededProjectPhases.containsKey(tmpProjId)) setNeededProjectPhases.put(tmpProjId, new set<string>());
                setNeededProjectPhases.get(tmpProjId).addAll(mapOLIPhases.get(item.OpportunityId+''+item.PricebookEntry.Product2Id));
            }
        }
        
        map<string,Id> mapProducts2MilestoneTemplates = new map<string,Id>();
        mapProductPhases = new map<id,set<string>>();
        set<string> setPhases = new set<string>();
        map<string,decimal> mapPhase2Order = new map<string,decimal>();
        
        /*for (Milestone_Template__c item:[Select Id, Phase__c, Product__c, Phase_Order__c FROM Milestone_Template__c WHERE Product__c IN :setProductIds]) {
            setPhases.add(item.Phase__c);
            if (!mapProductPhases.containsKey(item.Product__c)) mapProductPhases.put(item.Product__c, new set<string>());
            mapProductPhases.get(item.Product__c).add(item.Phase__c);
            mapProducts2MilestoneTemplates.put(item.Product__c+'-'+item.Phase__c, item.Id);
            mapPhase2Order.put(item.Phase__c, item.Phase_Order__c);
        }*/
        for (Milestone_Template_Items__c item:[Select Milestone_Template__r.Id, Phase__c, Milestone_Template__r.Product__c, Phase_Order__c 
        				FROM Milestone_Template_Items__c WHERE Milestone_Template__r.Product__c IN :setProductIds AND Phase__c!=null]) {
            setPhases.add(item.Phase__c);
            if (!mapProductPhases.containsKey(item.Milestone_Template__r.Product__c)) mapProductPhases.put(item.Milestone_Template__r.Product__c, new set<string>());
            mapProductPhases.get(item.Milestone_Template__r.Product__c).add(item.Phase__c);
            //mapProducts2MilestoneTemplates.put(item.Milestone_Template__r.Product__c+'-'+item.Phase__c, item.Milestone_Template__r.Id);
            mapProducts2MilestoneTemplates.put(item.Milestone_Template__r.Product__c, item.Milestone_Template__r.Id);
            mapPhase2Order.put(item.Phase__c, item.Phase_Order__c);
        }
        
        map<string,Id> mapProjectPhaseIds = new map<string,Id>();
        for (pse__Project_Phase__c item:[Select Id, Name, pse__Project__c FROM pse__Project_Phase__c 
                            WHERE Name IN :setPhases AND pse__Project__c IN :setProjectIds]) {
            mapProjectPhaseIds.put(item.Name + '-' + item.pse__Project__c, item.Id);
        }
        
        pse__Project_Phase__c curPP;
        list<pse__Project_Phase__c> lstPP = new list<pse__Project_Phase__c>();
        for (string phase:setPhases) {
            for (Id projId:setProjectIds) {
                if (    (!mapProjectPhaseIds.containsKey(phase+'-'+projId)) 
                        && 
                        (
                            (setNeededProjectPhases.containsKey(projId) && setNeededProjectPhases.get(projId).contains(phase))
                            ||
                            //(!mapProjectIsWithOCF.containsKey(projId))
                            //because mapProjectIsWithOCF always has projId as Key, but if this Opp must be proceed without OCF - it will be false
                            (!mapProjectIsWithOCF.get(projId))
                        ) 
                    ) {
                            
                    curPP = new pse__Project_Phase__c(pse__Project__c = projId, Name = phase, Template_Key__c = phase+'-'+projId);
                    if (mapPhase2Order.containsKey(phase)) curPP.DisplayOrder__c = mapPhase2Order.get(phase);
                    else curPP.DisplayOrder__c = 0;
                    lstPP.add(curPP);
                }
            }
        }
        
        if (lstPP.size()>0) insert lstPP;
        
        for (pse__Project_Phase__c item:[Select Id, Name, pse__Project__c, Template_Key__c FROM pse__Project_Phase__c 
                            WHERE Name IN :setPhases AND pse__Project__c IN :setProjectIds]) {
            if (!result.containsKey(item.pse__Project__c))   result.put(item.pse__Project__c, new list<pse__Project_Phase__c>());
            result.get(item.pse__Project__c).add(item);         
        }
        
        return result;
    }
    
    public static map<string, pse__Milestone__c> getParentMilestoneKeys(set<Id> setProjectIds) {
        map<string, pse__Milestone__c> result = new map<string, pse__Milestone__c>();
        string key;
        for (pse__Milestone__c item:[Select Id, OpportunityLineItem_Id__c, Product__c, Project_Phase__c, pse__Project__c, pse__Default_Bill_Rate__c, 
                                    Budget_Hours__c, pse__Milestone_Amount__c, Template_Key__c, OpportunityId__c,  pse__Project__r.pse__Opportunity__c 
                                    FROM pse__Milestone__c WHERE pse__Project__c IN :setProjectIds AND RecordType.DeveloperName = 'PARENT_TASK']) {
            if (item.pse__Default_Bill_Rate__c==null) item.pse__Default_Bill_Rate__c = 0.00;
            //key = item.Project_Phase__c + '-' + item.pse__Project__c + '-' + item.Product__c; //+ '-' + item.pse__Default_Bill_Rate__c.setScale(2);
            key = item.pse__Project__c + '-' + item.Product__c; //+ '-' + item.pse__Default_Bill_Rate__c.setScale(2);
            result.put(key, item);
        }
        return result;
    }
    
    public static map<string, pse__Milestone__c> getChildMilestoneKeys(set<Id> setProjectIds) {
        map<string, pse__Milestone__c> result = new map<string, pse__Milestone__c>();
        string key;
        
        for (pse__Milestone__c item:[Select Id, Name, pse__Exclude_from_Billing__c, Parent_Milestone__c, Start_Date__c, End_Date__c, RecordTypeId, pse__Project__c, 
                                    pse__Status__c, OpportunityLineItem_Id__c, pse__Target_Date__c
                                    FROM pse__Milestone__c WHERE Parent_Milestone__r.pse__Project__c IN :setProjectIds AND RecordType.DeveloperName = 'CHILD_TASK']) {
            key = item.Parent_Milestone__c + '-' + item.Name;
            result.put(key, item);
        }
        return result;
    }
    
    private static pse__Milestone__c getMilestoneByKey(id phaseId, string phase, id idProject, id productId, decimal UnitPrice, Date dDefaultTargetDate, Date dDefaultEndDate, boolean isFixedFee, OpportunityLineItem item) {
        //string key = phaseId + '-' + idProject + '-' + item.PricebookEntry.Product2Id; // + '-' + item.UnitPrice;
        string key = idProject + '-' + item.PricebookEntry.Product2Id;
        
        if(mapParentMilestones.containsKey(key) && item.OpportunityId!=mapParentMilestones.get(key).OpportunityId__c) {
        	pse__Milestone__c oldMilestone = mapParentMilestones.get(key);
        	oldMilestone.IsNew__c = false;
        	return oldMilestone;
        }

        pse__Milestone__c newMilestone = new pse__Milestone__c(
                        Name = item.PricebookEntry.Product2.Name,
                        Product__c = item.PricebookEntry.Product2Id,
                        pse__Exclude_from_Billing__c = isFixedFee,
                        RecordTypeId = psaUtils.idRTParentTask,
                        pse__Project__c = idProject,
                        OpportunityLineItem_Id__c = item.Id,
                        OpportunityId__c = item.OpportunityId,
                        pse__Default_Bill_Rate__c = item.UnitPrice,
                        //new logic removes Project_Phase__c from Parent Milestones
                        //Project_Phase__c = phaseId,
                        Budget_Hours__c = item.Quantity,
                        Template_Key__c = phase + '-' + idProject,
                        pse__Milestone_Amount__c = item.TotalPrice,
                        Start_Date__c = dDefaultTargetDate,
                        End_Date__c = dDefaultEndDate,
                        pse__Closed_for_Time_Entry__c = true,
                        pse__Closed_for_Expense_Entry__c = true,
                        pse__Status__c = 'Open',
                        //for closed changeorders
                        IsNew__c = true,
                        //Estimated_Hours__c must be populated via rollup 
                        //Estimated_Hours__c = item.Quantity, // Default Est to Budget value
                        pse__Target_Date__c = item.ServiceDate != null ? item.ServiceDate : dDefaultTargetDate
                    );
        return newMilestone;
    }
    
    public static pse__Budget__c generateBudget(Opportunity item, Id projectId, string sType, OpportunityLineItem oli) {
        pse__Budget__c result = new pse__Budget__c(Name = item.Name, 
                        pse__Project__c = projectId,
                        pse__Account__c = item.AccountId,
                        pse__Opportunity__c = item.Id,
                        pse__Status__c = 'Approved',
                        pse__Effective_Date__c = item.CloseDate,
                        pse__Amount__c = item.Amount,
                        Discount_Amount__c = oli.TotalPrice,
                        pse__Type__c = sType);
        return result;
    } 
    
    public static Map<ID, OpportunityLineItem> getDiscountOLIByOppId(set<Id> setOppIds) {
        Map<ID, OpportunityLineItem> result = new Map<ID, OpportunityLineItem>();
        for (OpportunityLineItem item:[Select Id, TotalPrice, OpportunityId FROM OpportunityLineItem 
                        WHERE OpportunityId IN :setOppIds AND PricebookEntry.Product2.ProductCode='Discount' 
                        AND PricebookEntry.Product2.IsActive = true]) {
            result.put(item.OpportunityId, item);
        }
        
        for (Id oppID:setOppIds) {
            if (!result.containsKey(oppID)) {
                result.put(oppID, new OpportunityLineItem());
            }
        }
        return result;
    }

    private static Map<ID, ID> getOppIdByProjectId( List<pse__Proj__c> aProjects ) {
        Map<ID, ID> aResult = new Map<ID, ID>();

        for ( pse__Proj__c oItem : aProjects ) {
            aResult.put( oItem.pse__Opportunity__c, oItem.Id );
        }

        return aResult;
    }

    public static Map<ID, Date> getDefaultTargetDates( List<pse__Proj__c> aProjects ) {
        Map<ID, Date> aResult = new Map<ID, Date>();

        for ( pse__Proj__c oItem : aProjects ) {
            //aResult.put( oItem.Id, oItem.pse__Start_Date__c );
            aResult.put( oItem.Id, oItem.Estimated_Start_Date__c );
        }

        return aResult;
    }
    
    public static Map<ID, Date> getDefaultTargetDatesForChangeOrders(list<Opportunity> lstCOOpps) {
        Map<ID, Date> result = new Map<ID, Date>();
        for (Opportunity item : lstCOOpps) {
            result.put(item.Project_Change_Order__r.PSA_Project__c, item.CloseDate);
        }
        return result;
    }
    
    public static Map<ID, Boolean> getIsFixedFee( List<pse__Proj__c> lstProjects ) {
        Map<ID, Boolean> result = new Map<ID, Boolean>();
        Boolean isFixedFee;
        for ( pse__Proj__c item : lstProjects ) {
            isFixedFee = item.pse__Billing_Type__c=='Fixed Fee' ? true : false ;
            result.put( item.Id, isFixedFee);
        }
        return result;
    }
    
    public static Map<ID, Boolean> getIsWithOCF( List<pse__Proj__c> lstProjects ) {
        Map<ID, Boolean> result = new Map<ID, Boolean>();
        Boolean isWithOCF;
        for ( pse__Proj__c item : lstProjects ) {
            //to ask what is default
            if (dEventHorizon==null) isWithOCF = false;
            else isWithOCF = item.pse__Opportunity__r.CreatedDate >=dEventHorizon ? true : false ;
            result.put( item.Id, isWithOCF);
        }
        return result;
    }
    
    public static List<pse__Proj__c> getProjectByIds( set<Id> setProjectIds ) {
        //we need to add rate fields here
        
        mapFieldNameByLabel = psaAssignmentHandler.getFieldNameByLabel(new String[]{'pse__Proj__c'});
        string strFields = String.join(mapFieldNameByLabel.values(), ',');
        if (!String.isBlank(strFields)) strFields += ',';
        string soql = 'Select '+strFields+' Id, pse__Start_Date__c, Estimated_Start_Date__c, pse__End_Date__c, pse__Billing_Type__c, CO_Hours__c, Budget_Amount__c, pse__Opportunity__r.CreatedDate FROM  pse__Proj__c WHERE Id IN :setProjectIds limit 10000';
        
        
        /*List<pse__Proj__c> lstProjects = new List<pse__Proj__c>([Select Id, pse__Start_Date__c, pse__End_Date__c, pse__Billing_Type__c, CO_Hours__c, 
                                pse__Opportunity__r.CreatedDate
                                FROM pse__Proj__c WHERE Id IN :setProjectIds]);*/
                                
        list<pse__Proj__c> lstProjects = database.query(soql);
        return lstProjects;
    }
    
    public static set<Id> getOppsWithBudget( set<Id> setOppIds ) {
        set<Id> result = new set<Id>();
        for (pse__Budget__c item:[Select Id, pse__Opportunity__c FROM pse__Budget__c WHERE pse__Opportunity__c IN :setOppIds]) {
            result.add(item.pse__Opportunity__c); 
        }
        return result;
    }
    
    public static List<Opportunity>  getClosedWonChangeOrderOpps( set<Id> setOppIds ) {
        List<Opportunity> result = new List<Opportunity>([Select Id, Name, AccountId, Amount, Project_Change_Order__c, Project_Change_Order__r.PSA_Project__c, CloseDate 
                        FROM Opportunity WHERE Id IN :setOppIds AND Recordtype.DeveloperName = 'Change_Orders' AND StageName='Closed Won']);
        return result;
    }

    private static Map<ID, List<OpportunityLineItem>> getOppLineItemsByProject( List<pse__Proj__c> aProjects ) {
        Map<ID, ID> aOppId_ProjectId = getOppIdByProjectId( aProjects );

        Map<ID, List<OpportunityLineItem>> aResult = new Map<ID, List<OpportunityLineItem>>();

        for ( OpportunityLineItem oItem : [ SELECT Id, UnitPrice, Role__c, Quantity, TotalPrice, ServiceDate, OpportunityId, PricebookEntry.Product2.Name, 
                                    PricebookEntry.Product2Id
                                    FROM OpportunityLineItem WHERE OpportunityId IN :aOppId_ProjectId.keySet() ] ) {
            if ( !aResult.containsKey( aOppId_ProjectId.get( oItem.OpportunityId ) ) ) {
                aResult.put( aOppId_ProjectId.get( oItem.OpportunityId ), new List<OpportunityLineItem>() );
            }
            aResult.get( aOppId_ProjectId.get( oItem.OpportunityId ) ).add( oItem );
        }

        return aResult;
    }
    
    public static Map<ID, List<OpportunityLineItem>> getAllOppLineItemsByProject( set<Id> setProjectIds ) {

        Map<ID, List<OpportunityLineItem>> result = new Map<ID, List<OpportunityLineItem>>();
        map<Id,Id> mapAllOppProject = mapOppProject;
        //we need this logic for Project setup as well
        //if (!isService){
            for (pse__Proj__c item:[select Id, pse__Opportunity__c FROM pse__Proj__c WHERE Id IN :setProjectIds])
            {
                mapAllOppProject.put(item.pse__Opportunity__c, item.Id);
            }
        //}
        for ( OpportunityLineItem item : [ SELECT Id, UnitPrice, Role__c, Quantity, TotalPrice,  
                                OpportunityId, PricebookEntry.Product2.Name, PricebookEntry.Product2Id
                                FROM OpportunityLineItem 
                                WHERE OpportunityId IN :mapAllOppProject.keySet() AND Opportunity.StageName='Closed Won'] ) {
            if (!result.containsKey(mapAllOppProject.get(item.OpportunityId))) {
                result.put( mapAllOppProject.get(item.OpportunityId), new List<OpportunityLineItem>() );
            }
            result.get(mapAllOppProject.get(item.OpportunityId)).add(item);
        }
        return result;
    }
    
    public static Map<ID, List<OpportunityLineItem>> getOppLineItemsByProjectFROMOppIds( set<Id> setOppIds ) {
        Map<ID, List<OpportunityLineItem>> result = new Map<ID, List<OpportunityLineItem>>();
        for ( OpportunityLineItem item : [Select Id, PricebookEntry.Product2Id, UnitPrice, Role__c,  
                                        Quantity, ServiceDate, Opportunity.Billing_Type__c, 
                                        Opportunity.Project_Change_Order__r.PSA_Project__r.pse__Start_Date__c, 
                                        Opportunity.Project_Change_Order__r.PSA_Project__r.Estimated_Start_Date__c,
                                        Opportunity.Project_Change_Order__r.PSA_Project__c, TotalPrice, PricebookEntry.Product2.Name
                                        FROM OpportunityLineItem WHERE OpportunityId IN :setOppIds] ) {
            if (!result.containsKey(item.Opportunity.Project_Change_Order__r.PSA_Project__c)) {
                result.put(item.Opportunity.Project_Change_Order__r.PSA_Project__c, new List<OpportunityLineItem>() );
            }
            result.get(item.Opportunity.Project_Change_Order__r.PSA_Project__c).add(item);
        }

        return result;
    }
    
    public static Map<string, set<string>> getOLIPhases( set<Id> setProjectIds) {
        Map<string, set<string>> result = new Map<string, set<string>>();
        list<Opportunity_Component_Feature__c> lstOCF = new list<Opportunity_Component_Feature__c>();
        for ( Opportunity_Component_Feature__c item : [Select Id, Opportunity_Component__r.Opportunity__c, Sow_Group__c, Product__c
                                        FROM Opportunity_Component_Feature__c 
                                        WHERE Opportunity_Component__r.Opportunity__c IN :mapOppProject.keySet()] ) {
            if (!result.containsKey(item.Opportunity_Component__r.Opportunity__c+''+item.Product__c)) {
                result.put(item.Opportunity_Component__r.Opportunity__c+''+item.Product__c, new set<string>() );
            }
            result.get(item.Opportunity_Component__r.Opportunity__c+''+item.Product__c).add(item.Sow_Group__c);
        }
        return result;
    }
    
    public static map<Id,Id> getOppProject(set<Id> setProjectIds) {
        Map<Id, Id> result = new Map<Id, Id> ();
        if (isService) {
            for (pse__Proj__c item:[select Id, pse__Opportunity__c FROM pse__Proj__c WHERE Id IN :setProjectIds])
            {
                result.put(item.pse__Opportunity__c, item.Id);
            }
        } else {
            for (Opportunity item:[select Id, Project_Change_Order__r.PSA_Project__c FROM Opportunity WHERE Project_Change_Order__r.PSA_Project__c IN :setProjectIds])
            {
                result.put(item.Id, item.Project_Change_Order__r.PSA_Project__c);
            }
        }
        return result;
    }

    public static void createAssignments( set<Id> setProjectIds ) {
        set<id> setResourceRequestIds = new set<id>();
        for (pse__Resource_Request__c item:[Select Id FROM pse__Resource_Request__c WHERE pse__Opportunity__c IN (Select pse__Opportunity__c FROM pse__Proj__c WHERE Id IN :setProjectIds) limit 10000]) {
            setResourceRequestIds.add(item.Id);
        }
        if (setResourceRequestIds.size()>0) psaAutoCreateAssignments(setResourceRequestIds);
    }
    
    public static void createChildMilestones( set<Id> setProjectIds ) {
        set<id> setOLIIds = new set<id>();
        set<id> setOppIds = new set<id>();
        map<id,id> mapOLIProducts = new map<id,id>();
        map<id,boolean> mapOLIWithOCF = new map<id,boolean>();
        map<string,id> mapPhases = new map<string,id>();
        map<string,id> mapProductPhaseIds = new map<string,id>();
        
        list<pse__Milestone__c> lstMilestones = new list<pse__Milestone__c>([Select Id, OpportunityLineItem_Id__c, Template_Key__c, Project_Phase__c, 
                                        pse__Project__c, pse__Project__r.pse__Billing_Type__c, pse__Project__r.pse__Start_Date__c, pse__Project__r.Estimated_Start_Date__c, pse__Exclude_from_Billing__c, Start_Date__c, End_Date__c  
                                        FROM pse__Milestone__c 
                                        WHERE pse__Project__c IN :setProjectIds 
                                        AND RecordType.DeveloperName = 'PARENT_TASK' 
                                        AND IsNew__c = true limit 10000]);
        for (pse__Milestone__c item:lstMilestones) {
            setOLIIds.add(item.OpportunityLineItem_Id__c);
        }
        
        //to find Opps before EventHorizon
        dEventHorizon = null;
        Map<String, JfrsnSettings__c> mapOCF = JfrsnSettings__c.getAll();
        if (mapOCF.containsKey('standard')) {
            dEventHorizon = mapOCF.get('standard').EventHorizon__c;
        }
        
        for (OpportunityLineItem item:[SELECT Id, PricebookEntry.Product2Id, OpportunityId, Opportunity.CreatedDate 
                                    FROM OpportunityLineItem WHERE Id IN :setOLIIds] ) {
            setOppIds.add(item.OpportunityId);
            mapOLIProducts.put(item.id, item.PricebookEntry.Product2Id);
            if (dEventHorizon==null || item.Opportunity.CreatedDate<dEventHorizon) mapOLIWithOCF.put(item.Id, false);
            else mapOLIWithOCF.put(item.Id, true);
        }
        
        map<string, set<string>> mapProducts2OCFBuild = new map<string, set<string>>();
        for (Opportunity_Component_Feature__c item:[Select Id, Product__c, Sow_Group__c, Opportunity_Component__c, Opportunity_Component__r.Description__c 
                                    FROM Opportunity_Component_Feature__c 
                                    WHERE Sow_Group__c='Build' AND Opportunity_Component__r.Opportunity__c IN :setOppIds]) {
            if (!mapProducts2OCFBuild.containsKey(item.Product__c+'-'+item.Sow_Group__c)) mapProducts2OCFBuild.put(item.Product__c+'-'+item.Sow_Group__c, new set<string>());
            mapProducts2OCFBuild.get(item.Product__c+'-'+item.Sow_Group__c).add(item.Opportunity_Component__r.Description__c);                  
        }
        
        set<Id> setMilestoneTemplateIds = new set<Id>();
        map<string,Id> mapProducts2MilestoneTemplates = new map<string,Id>();
        //for (Milestone_Template__c item:[Select Id, Phase__c, Product__c FROM Milestone_Template__c WHERE Product__c IN :mapOLIProducts.values()]) {
        for (Milestone_Template__c item:[Select Id, Product__c FROM Milestone_Template__c WHERE Product__c IN :mapOLIProducts.values()]) {
            setMilestoneTemplateIds.add(item.Id);
            mapProducts2MilestoneTemplates.put(item.Product__c, item.Id);
        }
        
        map<Id,list<Milestone_Template_Items__c>> mapMTIs = new map<Id,list<Milestone_Template_Items__c>>();
        /*for (Milestone_Template_Items__c item:[Select Id, Milestone_Template__c, Name_Prefix__c 
                        FROM Milestone_Template_Items__c WHERE Milestone_Template__c IN :setMilestoneTemplateIds]) {
            if (!mapMTIs.containsKey(item.Milestone_Template__c)) mapMTIs.put(item.Milestone_Template__c, new list<Milestone_Template_Items__c>());
            mapMTIs.get(item.Milestone_Template__c).add(item);
        }*/
        for (Milestone_Template_Items__c item:[Select Name_Prefix__c, Milestone_Template__r.Id, Phase__c, 
        				Milestone_Template__r.Product__c, Phase_Order__c, Child_Milestone_Order__c, Task_Type__c 
        				FROM Milestone_Template_Items__c WHERE Milestone_Template__r.Product__c IN :mapOLIProducts.values()]) {
            setMilestoneTemplateIds.add(item.Milestone_Template__r.Id);
            //mapProducts2MilestoneTemplates.put(item.Milestone_Template__r.Product__c+'-'+item.Phase__c, item.Milestone_Template__r.Id);
            mapProducts2MilestoneTemplates.put(item.Milestone_Template__r.Product__c, item.Milestone_Template__r.Id);
            if (!mapMTIs.containsKey(item.Milestone_Template__c)) mapMTIs.put(item.Milestone_Template__c, new list<Milestone_Template_Items__c>());
            mapMTIs.get(item.Milestone_Template__c).add(item);
        }
        
        Id rtChild = null;
        for (RecordType item:[Select Id, DeveloperName FROM RecordType WHERE sObjectType = 'pse__Milestone__c' AND DeveloperName='CHILD_TASK' limit 1]) {
            rtChild = item.Id;
        }
        
        map<string,Id> mapProjectPhaseIds = new map<string,Id>();
        for (pse__Project_Phase__c item:[Select Id, Name FROM pse__Project_Phase__c WHERE pse__Project__c IN :setProjectIds] ) {
            mapProjectPhaseIds.put(item.Name, item.Id);
        }
        
        mapChildMilestones = getChildMilestoneKeys(setProjectIds);
        
        pse__Milestone__c childMS;
        Id productId;
        Id milestonetemplateId;
        Id projectphaseId;
        string phase;
        Id oliId = null;
        list<pse__Milestone__c> lstChildMilestones = new list<pse__Milestone__c>();
        boolean isFixedFee;
        /*for (pse__Milestone__c item:lstMilestones) {
            isFixedFee = item.pse__Project__r.pse__Billing_Type__c == 'Fixed Fee' ? true : false;
            productId = mapOLIProducts.get(item.OpportunityLineItem_Id__c);
            if (item.Template_Key__c!=null && item.Template_Key__c.indexOf('-')>0) {
                phase = item.Template_Key__c.substring(0,item.Template_Key__c.indexOf('-'));
                try {
                    oliId = (Id)item.OpportunityLineItem_Id__c;
                } catch (exception e) {
                    oliId = null;
                }
                if (mapProjectPhaseIds.containsKey(phase)) {
                    projectphaseId = mapProjectPhaseIds.get(phase);
                } else {
                    projectphaseId = null;
                }
                
                //logic for Build phase
                if (phase=='Build' && oliId!=null && mapOLIWithOCF.get(oliId)) {
                    if (mapProducts2OCFBuild.containsKey(productId+'-'+phase)) {
                        for (string childname:mapProducts2OCFBuild.get(productId+'-'+phase)) {
                            childMS = getChildMilestone(childname, item, rtChild, isFixedFee, projectphaseId);
                            lstChildMilestones.add(childMS);
                        }
                    }
                } else {
                    milestonetemplateId = mapProducts2MilestoneTemplates.get(productId+'-'+phase);
                    if (mapMTIs.containsKey(milestonetemplateId)) {
                        for (Milestone_Template_Items__c mti:mapMTIs.get(milestonetemplateId)) {
                            childMS = getChildMilestone(mti.Name_Prefix__c, item, rtChild, isFixedFee, projectphaseId);
                            lstChildMilestones.add(childMS);
                        }
                    }
                }
            }
        }*/
        
        //now childs are formed only from MTIs, nothing from OCFs
        for (pse__Milestone__c item:lstMilestones) {
            isFixedFee = item.pse__Project__r.pse__Billing_Type__c == 'Fixed Fee' ? true : false;
            productId = mapOLIProducts.get(item.OpportunityLineItem_Id__c);
            try {
                oliId = (Id)item.OpportunityLineItem_Id__c;
            } catch (exception e) {
                oliId = null;
            }
            
            milestonetemplateId = mapProducts2MilestoneTemplates.get(productId);
            if (mapMTIs.containsKey(milestonetemplateId)) {
                for (Milestone_Template_Items__c mti:mapMTIs.get(milestonetemplateId)) {
                    if (mapProjectPhaseIds.containsKey(mti.Phase__c)) {
                        projectphaseId = mapProjectPhaseIds.get(mti.Phase__c);
                    } else {
                        projectphaseId = null;
                    }
                    childMS = getChildMilestone(mti, item, rtChild, isFixedFee, projectphaseId);
                    lstChildMilestones.add(childMS);
                }
            }
        }
        
        system.debug(LoggingLevel.ERROR, '--------trigger.upsert=');
        if (lstChildMilestones.size()>0) upsert lstChildMilestones;
    }
    
    private static pse__Milestone__c getChildMilestone(Milestone_Template_Items__c mti, pse__Milestone__c item, Id rtChild, Boolean isFixedFee, Id projectphaseId) {
        string key = item.Id + '-' + mti.Name_Prefix__c;
        if(mapChildMilestones.containsKey(key)) return mapChildMilestones.get(key);
        pse__Milestone__c childMS = new pse__Milestone__c (Name = mti.Name_Prefix__c, 
                                            pse__Exclude_from_Billing__c = item.pse__Exclude_from_Billing__c,
                                            Parent_Milestone__c = item.Id,
                                            //new functionality (Child Mileston related to Parent Ms and Phase)
                                            Project_Phase__c = projectphaseId, 
                                            Start_Date__c = item.Start_Date__c,
                                            End_Date__c = item.End_Date__c,
                                            RecordTypeId = rtChild, 
                                            pse__Project__c = item.pse__Project__c,
                                            pse__Closed_for_Expense_Entry__c = false,
                                            /*SLFF-70 all Task milestones should be created with status = Closed and Closed for Time Entry = True*/
                                            //pse__Closed_for_Time_Entry__c = false,
                                            //pse__Status__c = 'Open',
                                            pse__Closed_for_Time_Entry__c = true,
                                            pse__Status__c = 'Closed',
                                            Task_Type__c = mti.Task_Type__c,
                                            DisplayOrder__c = mti.Child_Milestone_Order__c,
                                            Timecards_are_Billable__c = !isFixedFee,
                                            OpportunityLineItem_Id__c = item.OpportunityLineItem_Id__c,
                                            //pse__Target_Date__c = item.pse__Project__r.pse__Start_Date__c);
                                            pse__Target_Date__c = item.pse__Project__r.Estimated_Start_Date__c);
        return childMS;
    }
    
    //this method is used only for ChangeOrders
    /*public static void createBillableMilestone(set<Id> setProjectIds) {
        
        map<Id,Id> mapOpp_Project = new map<Id,Id>();
        map<Id,decimal> mapOpp_Amount = new map<Id,decimal>();
        map<Id,date> mapProj_StartDate = new map<Id,date>();
        map<Id,date> mapProj_EndDate = new map<Id,date>();
        for (Opportunity item:[Select Id, Billing_Type__c, Amount, Project_Change_Order__r.PSA_Project__c, 
                                Project_Change_Order__r.PSA_Project__r.pse__Start_Date__c, 
                                Project_Change_Order__r.PSA_Project__r.Estimated_Start_Date__c, 
                                Project_Change_Order__r.PSA_Project__r.pse__End_Date__c FROM Opportunity
                                WHERE Project_Change_Order__r.PSA_Project__c IN :setProjectIds AND Billing_Type__c='Fixed Fee']) {
            mapOpp_Project.put(item.Id, item.Project_Change_Order__r.PSA_Project__c);
            mapOpp_Amount.put(item.Id, item.Amount);
            //mapProj_StartDate.put(item.Project_Change_Order__r.PSA_Project__c, item.Project_Change_Order__r.PSA_Project__r.pse__Start_Date__c);
            mapProj_StartDate.put(item.Project_Change_Order__r.PSA_Project__c, item.Project_Change_Order__r.PSA_Project__r.Estimated_Start_Date__c);
            mapProj_EndDate.put(item.Project_Change_Order__r.PSA_Project__c, item.Project_Change_Order__r.PSA_Project__r.pse__End_Date__c);
        }
        if (mapOpp_Project.isEmpty()) return;
        
        set<Id> setProjectWithBillablePhases = new set<Id>();
        set<Id> setMilestoneWithBillablePhases = new set<Id>();
        for (pse__Project_Phase__c item:[Select Id, pse__Project__c FROM pse__Project_Phase__c 
                WHERE Name = 'Billable' AND pse__Project__c IN :setProjectIds]) {
            setProjectWithBillablePhases.add(item.pse__Project__c);
        }
        
        decimal billableorder = null;
        if (setProjectWithBillablePhases.isEmpty()) {
            for (Milestone_Template__c item:[Select Id, Phase_Order__c FROM Milestone_Template__c WHERE Phase__c ='Billable']) {
                billableorder = item.Phase_Order__c;
            }
        }
        
        for (pse__Milestone__c item:[Select Id, pse__Project__c, Opportunity__c FROM pse__Milestone__c 
                WHERE RecordType.DeveloperName = 'BILLABLE' AND pse__Project__c IN :setProjectIds]) {
            setMilestoneWithBillablePhases.add(item.Opportunity__c);
        }
        
        list<pse__Project_Phase__c> lstPP = new list<pse__Project_Phase__c>();
        Id projId = null;
        for (Id oppId:mapOpp_Project.keySet()) {
            projId = mapOpp_Project.get(oppId);
            if (!setProjectWithBillablePhases.contains(projId) && !setMilestoneWithBillablePhases.contains(oppId)) {
                lstPP.add(new pse__Project_Phase__c(Name='Billable', pse__Project__c=projId, Order__c=billableorder));
            }
        }
        if (lstPP.size()>0) insert lstPP;
        
        map<Id,Id> mapProject_Phase = new map<Id,Id>();
        for (pse__Project_Phase__c item:[Select Id, pse__Project__c FROM pse__Project_Phase__c 
                WHERE Name = 'Billable' AND pse__Project__c IN :setProjectIds]) {
            mapProject_Phase.put(item.pse__Project__c, item.Id);
        }
        
        list<pse__Milestone__c> lstBillableMS = new list<pse__Milestone__c>();
        for (Id oppId:mapOpp_Project.keySet()) {
            projId = mapOpp_Project.get(oppId);
            if (projId!=null && !setMilestoneWithBillablePhases.contains(oppId)) {
                lstBillableMS.add(new pse__Milestone__c(Name = 'Billable', 
                                            RecordTypeId = psaUtils.idRTBillable, 
                                            pse__Project__c = projId,
                                            Opportunity__c = oppId,
                                            Project_Phase__c = mapProject_Phase.get(projId),
                                            pse__Milestone_Amount__c = mapOpp_Amount.get(oppId),
                                            Start_Date__c = mapProj_StartDate.get(projId),
                                            End_Date__c = mapProj_EndDate.get(projId),
                                            pse__Status__c = 'Open',
                                            pse__Target_Date__c = mapProj_StartDate.get(projId)));
            }
        }
        
        if (lstBillableMS.size()>0) insert lstBillableMS;
    }*/
    
    public static void psaAutoCreateAssignments(set<id> setResourceRequestIds) {
        list<pse__Resource_Request__c> lstRR = new list<pse__Resource_Request__c>([Select Id, pse__Opportunity__c, 
                            pse__Project__c, pse__Resource_Role__c, pse__Start_Date__c, pse__End_Date__c,
                            pse__SOW_Hours__c, pse__Requested_Bill_Rate__c, pse__Resource_Held__c, pse__Staffer_Resource__c
                            FROM pse__Resource_Request__c WHERE Id IN :setResourceRequestIds limit 10000]);
        set<Id> setOppIds = new set<Id>();
        set<String> setRoles = new set<String>();
        set<Date> setStartDates = new set<Date>();
        set<Date> setEndDates = new set<Date>();
        string key;
        map<string,pse__Resource_Request__c> mapResourceRequests = new map<string,pse__Resource_Request__c>();
        for (pse__Resource_Request__c item:lstRR) {
            setOppIds.add(item.pse__Opportunity__c);
            setRoles.add(item.pse__Resource_Role__c);
            setStartDates.add(item.pse__Start_Date__c);
            setEndDates.add(item.pse__End_Date__c);
            if (item.pse__Resource_Held__c) key = item.pse__Staffer_Resource__c+ '-';
            else key = 'dummy-';
            key += item.pse__Opportunity__c + '-' + item.pse__Resource_Role__c + '-' + item.pse__Start_Date__c + '-' + item.pse__End_Date__c;
            mapResourceRequests.put(key,item);
        }
        
        map<String,Id> mapDummyResources = new map<String,Id>();
        for (Contact item:[Select Id, LastName FROM Contact WHERE pse__Resource_Role__c='Generic']) {
            mapDummyResources.put(item.LastName, item.Id);
        }
        
        map<Id,Id> mapOpp2Project = new map<Id,Id>();
        for (pse__Proj__c item:[Select Id, pse__Opportunity__c FROM pse__Proj__c WHERE pse__Opportunity__c IN :setOppIds limit 10000]) {
            mapOpp2Project.put(item.pse__Opportunity__c, item.Id);
        }
        
        pse__Assignment__c curAssignment;
        pse__Resource_Request__c rr;
        list<pse__Assignment__c> lstAssignmentIns = new list<pse__Assignment__c>();
        set<String> setKeysWithoutSchedule = new set<String>();
        for (string rrkey:mapResourceRequests.keySet()) {
            rr = mapResourceRequests.get(rrkey);
            if (mapOpp2Project.containsKey(rr.pse__Opportunity__c)) {
                curAssignment = new pse__Assignment__c(pse__Project__c = mapOpp2Project.get(rr.pse__Opportunity__c), pse__Role__c = rr.pse__Resource_Role__c);
                curAssignment.pse__Planned_Hours__c = rr.pse__SOW_Hours__c;
                curAssignment.pse__Planned_Bill_Rate__c = rr.pse__Requested_Bill_Rate__c;
                curAssignment.pse__Bill_Rate__c = rr.pse__Requested_Bill_Rate__c;
                if(rr.pse__Resource_Held__c) {
                    curAssignment.pse__Resource__c = rr.pse__Staffer_Resource__c;
                    curAssignment.pse__Status__c = 'Booked';
                } else {
                    curAssignment.pse__Resource__c = mapDummyResources.get(curAssignment.pse__Role__c);
                    curAssignment.pse__Status__c = 'Soft Booked';
                }
                lstAssignmentIns.add(curAssignment);
            }
        }
        
        pse__Schedule__c curSchedule;
        list<pse__Schedule__c> lstSchedule = new list<pse__Schedule__c>();
        for (string rrkey:mapResourceRequests.keySet()) {
            curSchedule = new pse__Schedule__c(pse__Start_Date__c = mapResourceRequests.get(rrkey).pse__Start_Date__c, pse__End_Date__c = mapResourceRequests.get(rrkey).pse__End_Date__c);
            lstSchedule.add(curSchedule);
        }
        
        if (lstSchedule.size()>0) insert lstSchedule;

        integer i = 0;
        for (pse__Assignment__c item:lstAssignmentIns) {
            item.pse__Schedule__c = lstSchedule[i].Id;
            i++;
        }
        
        if (lstAssignmentIns.size()>0) insert lstAssignmentIns;
    }
    
    public static void psaUpdateProjectRates(list<pse__Proj__c> lstProjects) {
        Boolean isUpdateNeeded = false;
        string apiname = '';
        for (pse__Proj__c item:lstProjects) {
            if (mapProjectRates.containsKey(item.Id)) {
                for (string role: mapProjectRates.get(item.Id).keySet()) {
                    try {
                        if (mapFieldNameByLabel.containsKey(role)) {
                            apiname = mapFieldNameByLabel.get(role);
                            if (item.get(apiname)!=mapProjectRates.get(item.Id).get(role)) {
                                item.put(apiname,mapProjectRates.get(item.Id).get(role));
                                isUpdateNeeded = true;
                            }
                        }
                    } catch (exception e) {
                        system.debug(LoggingLevel.ERROR, e.getMessage() + ' ' + e.getStackTraceString());
                    }
                }
                
                for (string fieldlabel:mapFieldNameByLabel.keySet()) {
                    if (!mapProjectRates.get(item.Id).containsKey(fieldlabel)) {
                        item.put(mapFieldNameByLabel.get(fieldlabel),null);
                        isUpdateNeeded = true;
                    }
                }
            }
        }
        
        if (isUpdateNeeded) update lstProjects;
    }
}