global class psaProjectSetupWS {
    webService static string projectSetup(Id oppId) {
        
            Opportunity opp = null;
            for (Opportunity item:[Select Id, Name, AccountId, Account.Name, Account.Type, RecordType.DeveloperName, pse__Region__c, pse__Practice__c, StageName, Projected_Start_Date__c,
                                    Business_Units_Involved__c, Project_Overview_Requirements__c, Billing_Type__c, Project_Goals_Objectives__c, CloseDate, CreatedDate, 
                                    Current_Challenges__c, Current_State_Description__c, Total_Estimate_Hours__c, Amount, Travel__c, Number_Of_Weeks__c, Billing_Notes__c,
                                    Project_Level__c, PC__c, EM__c, SA__c, BA__c, SME__c, SM__c, TA__c, DevMgmt__c, Dev__c, DMS__c, DIS__c,
                                    Project_Risks__c, Project_Risks_Details__c, Travel_Hourly_Rate__c
                                    FROM Opportunity WHERE Id=:oppId AND RecordType.DeveloperName='Services']) {
                opp = item;
            }
            
            
            if(Test.isRunningTest()) {
                insert new pse__Permission_Control__c(pse__User__c=UserInfo.getUserId(), pse__cascading_permission__C = true, pse__Region__c=opp.pse__Region__c, pse__Resource_Request_Entry__c=true, pse__Timecard_Ops_Edit__c = true, pse__Staffing__c = true);       
            }
            if (opp!=null) {
                if (opp.StageName=='Closed Won') {
                    list<pse__Proj__c> lstProj = new list <pse__Proj__c>([Select Id FROM pse__Proj__c WHERE pse__Opportunity__c=:opp.Id limit 1]);
                    if (lstProj.size()==0) {
                        Savepoint sp = Database.setSavepoint();
                        pse__Proj__c proj = new pse__Proj__c();
                        string oppName = opp.Name;
                        if (oppName.length()>70) oppName = oppName.substring(0, 70);
                        //proj.Name = oppName + ' - Project';
                        proj.Name = oppName;
                        proj.pse__Region__c = opp.pse__Region__c;
                        proj.pse__Practice__c = opp.pse__Practice__c;
                        proj.pse__Opportunity__c = oppId;
                        proj.pse__Account__c = opp.AccountId;
                        proj.pse__Is_Active__c = true;
                        proj.Estimated_Start_Date__c = opp.Projected_Start_Date__c;
                        if (opp.Number_Of_Weeks__c==null) opp.Number_Of_Weeks__c = 0;
                        proj.pse__End_Date__c = proj.Estimated_Start_Date__c.addDays((opp.Number_Of_Weeks__c*7).intValue());
                        proj.pse__Stage__c = 'Active';
                        proj.pse__Billing_Type__c = opp.Billing_Type__c;
                        proj.pse__Services_Billing_Time_Period_Type__c = opp.Billing_Type__c;
                        proj.Business_Units_Involved__c = opp.Business_Units_Involved__c;
                        proj.Project_Scope__c = opp.Project_Overview_Requirements__c;
                        proj.Project_Goals_Objectives__c = opp.Project_Goals_Objectives__c;
                        proj.Current_Challenges__c = opp.Current_Challenges__c;
                        proj.Current_State_Description__c = opp.Current_State_Description__c;
                        proj.pse__Planned_Hours__c = opp.Total_Estimate_Hours__c;
                        proj.Budget_Hours__c = opp.Total_Estimate_Hours__c;
                        proj.pse__Total_Assigned_Hours__c = opp.Total_Estimate_Hours__c;
                        proj.Estimated_Amount__c = opp.Amount;
                        proj.pse__Action_Count_Billing_Eligible_Records__c = true;
                        proj.pse__Action_Update_Current_Time_Period__c = true;
                        proj.pse__Actuals_Need_Recalc__c = true;
                        proj.pse__Allow_Expenses_Without_Assignment__c = false;
                        if (opp.Account.Type=='Internal') proj.pse__Project_Type__c='Internal';
                        
                        if (proj.pse__Project_Type__c=='Internal') {
                            proj.pse__Allow_Self_Staffing__c = false;
                            proj.pse__Is_Billable__c = false;
                        } else {
                            //defaut to true, unless the project type is internal
                            proj.pse__Allow_Self_Staffing__c = true;
                            //true if the project type is not internal
                            proj.pse__Is_Billable__c = true;
                        }
                        proj.pse__Allow_Timecards_Without_Assignment__c = false;
                        
                        proj.pse__Closed_for_Expense_Entry__c = false;
                        proj.pse__Daily_Timecard_Notes_Required__c = true;
                        proj.pse__Share_with_Project_Manager__c = true;
                        proj.pse__Share_with_Project_Resources__c = true;
                        
                        proj.Project_Level__c = opp.Project_Level__c;
                        proj.pse__Project_Type__c = opp.Account.Type;
                        
                        proj.PC__c = opp.PC__c;
                        proj.EM__c = opp.EM__c;
                        proj.SA__c = opp.SA__c;
                        proj.BA__c = opp.BA__c;
                        proj.SME__c = opp.SME__c;
                        proj.SM__c = opp.SM__c;
                        proj.TA__c = opp.TA__c;
                        proj.DevMgmt__c = opp.DevMgmt__c;
                        proj.Dev__c = opp.Dev__c;
                        proj.DA__c = opp.DMS__c;
                        proj.DIS__c = opp.DIS__c;
                        
                        proj.Project_Risks__c = opp.Project_Risks__c;
                        proj.Project_Risk_Details__c = opp.Project_Risks_Details__c;
                        
                        proj.Billing_Notes__c = opp.Billing_Notes__c;
                        
                        try {
                            insert proj;
                            system.debug(LoggingLevel.ERROR, psaProjectSetup.dEventHorizon);
                            
                            if (psaProjectSetup.mapOLIPhases.isEmpty() && psaProjectSetup.dEventHorizon!=null && psaProjectSetup.dEventHorizon<opp.CreatedDate) {
                                Database.rollback(sp);
                                return 'Please set Opportunity Component Features for the Project!';
                            }
                            
                            //create Project Contacts from Account Contact Roles
                            if (proj.pse__Account__c!=null) {
                                list<Project_Contacts__c> lstProjectContact = new list<Project_Contacts__c>();
                                list<AccountContactRole> lstContactRoles = new list<AccountContactRole>([SELECT Id, AccountId, ContactId, Role FROm AccountContactRole WHERE AccountId=:proj.pse__Account__c]);
                                for (AccountContactRole item:lstContactRoles) {
                                    lstProjectContact.add(new Project_Contacts__c(Project__c=proj.Id, Contact__c = item.ContactId));
                                }
                                if (!lstProjectContact.isEmpty()) insert lstProjectContact;
                            }

                            //assign agreement to the Project
                            list<echosign_dev1__SIGN_Agreement__c> lstAgreements = new list<echosign_dev1__SIGN_Agreement__c>([Select id, PSA_Project__c FROM echosign_dev1__SIGN_Agreement__c WHERE echosign_dev1__Opportunity__c=:opp.Id]);
                            for (echosign_dev1__SIGN_Agreement__c item:lstAgreements) {
                                item.PSA_Project__c = proj.Id;
                            }
                            if (!lstAgreements.isEmpty()) update lstAgreements;
                            
                            //assign chatter attachments to the Project
                            list<FeedItem> lstFIOpp = new list<FeedItem>([Select Visibility, Type, Title, RelatedRecordId, ParentId, NetworkScope, LinkUrl, 
                                            Body From FeedItem WHERE ParentId=:opp.Id AND type='ContentPost' limit 100]);
                            list<FeedItem> lstFIProj = new list<FeedItem>();
                            FeedItem fi;
                            for (FeedItem item:lstFIOpp) {
                                fi = item.clone();
                                fi.ParentId = proj.Id;
                                lstFIProj.add(fi);
                            }
                            if (!lstFIProj.isEmpty()) insert lstFIProj;
                            
                            list<Attachment> lstAttachOpp = new list<Attachment>([Select ParentId, Name, IsPrivate, Description, ContentType, BodyLength, Body From Attachment WHERE ParentId=:opp.Id limit 100]);
                            list<Attachment> lstAttachProj = new list<Attachment>();
                            Attachment a;
                            for (Attachment item:lstAttachOpp) {
                                a = item.clone();
                                a.ParentId = proj.Id;
                                lstAttachProj.add(a);
                            }
                            if (!lstAttachProj.isEmpty()) insert lstAttachProj;
                            
                            
                            psaProjectSetup.createChildMilestones(new set<Id>{proj.Id});
                            //2014-12-23 - commented due to skype conversation with Dina:
                            //Silverline-Dina Hamdan: these resource requests shouldn't be associated with the project/assignment at all
							//Silverline-Dina Hamdan: they're strictly for sales
							//Silverline-Dina Hamdan: its very different from the use case via JFRSN
							//Silverline-Dina Hamdan: we never do this
                            //psaProjectSetup.createAssignments(new set<Id>{proj.Id});
                            
                            Map<ID, OpportunityLineItem> mapDiscounts = psaProjectSetup.getDiscountOLIByOppId(new set<Id>{opp.Id});
                            
                            string budgettype = proj.pse__Project_Type__c == 'Internal' ? 'Internal' : 'SOW';
                            pse__Budget__c budget = psaProjectSetup.generateBudget(opp, proj.Id, budgettype, mapDiscounts.get(opp.Id));
                            insert budget;
                            
                            decimal travelrate = 75;
                            boolean isSetTravel = true;
                            travelrate = opp.Travel_Hourly_Rate__c;
                            decimal travelorder = 100;
                            decimal billableorder = null;
                            /*for (Milestone_Template__c item:[Select Id, Travel_Rate__c, Phase_Order__c, Phase__c FROM Milestone_Template__c WHERE Phase__c IN ('Travel', 'Billable')]) {
                                if (item.Phase__c=='Travel') {
                                    travelrate = item.Travel_Rate__c;
                                    isSetTravel = true;
                                    travelorder = item.Phase_Order__c;
                                } else {
                                    billableorder = item.Phase_Order__c;
                                }
                            }*/
                            
                            /*for (Milestone_Template_Items__c item:[Select Milestone_Template__r.Travel_Rate__c, Milestone_Template__r.Phase_Order__c, Phase__c FROM Milestone_Template_Items__c WHERE Phase__c IN ('Travel', 'Billable')]) {
                                if (item.Phase__c=='Travel') {
                                    travelrate = item.Milestone_Template__r.Travel_Rate__c;
                                    isSetTravel = true;
                                    travelorder = item.Milestone_Template__r.Phase_Order__c;
                                } else {
                                    billableorder = item.Milestone_Template__r.Phase_Order__c;
                                }
                            }*/
                            
                            
                            /*if (opp.Billing_Type__c=='Fixed Fee') {
                                pse__Project_Phase__c ppBillable = new pse__Project_Phase__c(Name='Billable', pse__Project__c=proj.Id, Order__c=billableorder);
                                insert ppBillable;
                                
                                pse__Milestone__c msBillable = new pse__Milestone__c(Name = 'Billable', 
                                            RecordTypeId = psaUtils.idRTBillable, 
                                            pse__Project__c = proj.Id,
                                            Opportunity__c = opp.Id,
                                            Project_Phase__c = ppBillable.Id,
                                            Start_Date__c = opp.Projected_Start_Date__c,
                                            End_Date__c = proj.pse__End_Date__c,
                                            pse__Status__c = 'Open',
                                            pse__Milestone_Amount__c = opp.Amount,
                                            pse__Target_Date__c = opp.Projected_Start_Date__c);
                                insert msBillable;
                            }*/
                            
                            if (isSetTravel) {
                                pse__Project_Phase__c ppTravel = new pse__Project_Phase__c(Name='Travel', pse__Project__c=proj.Id, Order__c=travelorder);
                                insert ppTravel;
                                
                                pse__Milestone__c msParent = null;
                                for (pse__Milestone__c item:[Select Id FROM pse__Milestone__c WHERE Name = 'Travel' AND RecordType.DeveloperName = 'PARENT_TASK'
                                                            AND Project_Phase__r.Name = 'Travel' AND pse__Project__c = :proj.Id]) {
                                    msParent = item;                
                                }
                                
                                if (msParent==null) {
                                        msParent = new pse__Milestone__c(Name = 'Travel', 
                                                RecordTypeId = psaUtils.idRTParentTask, 
                                                pse__Project__c = proj.Id,
                                                Start_Date__c = opp.Projected_Start_Date__c,
                                                End_Date__c = proj.pse__End_Date__c,
                                                pse__Status__c = 'Open',
                                                pse__Default_Bill_Rate__c = travelrate,
                                                Task_Type__c = 'Travel',
                                                //Project_Phase__c = ppTravel.Id,
                                                pse__Apply_Default_Bill_Rate_to_Timecard__c = true,
                                                pse__Closed_for_Time_Entry__c = true,
                                                pse__Closed_for_Expense_Entry__c = true, 
                                                pse__Target_Date__c = opp.Projected_Start_Date__c);
                                    if (opp.Travel__c=='Non-Billable') msParent.pse__Exclude_from_Billing__c = true;
                                    insert msParent;
                                    
                                    Boolean closedForExpenseEntry = true;
                                    if (opp.Travel__c=='Time & Expenses') closedForExpenseEntry = false;
                                
                                    pse__Milestone__c msChild = new pse__Milestone__c(Name = 'Travel: '+opp.Travel__c, 
                                            Parent_Milestone__c = msParent.Id, 
                                            Project_Phase__c = ppTravel.Id, 
                                            RecordTypeId = psaUtils.idRTChildTask, 
                                            pse__Project__c = proj.Id,
                                            pse__Default_Bill_Rate__c = travelrate,
                                            Start_Date__c = opp.Projected_Start_Date__c,
                                            End_Date__c = proj.pse__End_Date__c,
                                            Task_Type__c = 'Travel',
                                            /*SLFF-70 all Task milestones should be created with status = Closed and Closed for Time Entry = True*/
                                            //pse__Status__c = 'Open',
                                            pse__Status__c = 'Closed',
                                            pse__Closed_for_Time_Entry__c = true,
                                            pse__Closed_for_Expense_Entry__c = closedForExpenseEntry,
                                            pse__Apply_Default_Bill_Rate_to_Timecard__c = true,
                                            pse__Target_Date__c = opp.Projected_Start_Date__c);
                                    insert msChild;
                                }
                            }
                            
                            psaProjectRefesh.refreshProjectFields(new set<Id>{proj.Id});
                            //proj.Budget_Amount__c = budget.pse__Amount__c;
                            //update proj;
                        } catch (exception e) {
                            Database.rollback(sp);
                            return e.getMessage();
                        }
                        return 'Project has been created successfully!';
                    } else {
                        return 'Project for this Opportunity already exists.';
                    }
                } else {
                    return 'Only "Closed Won" Opportunity can be converted to Project!';
                }
            } else {
                return 'You can Setup Porject only for Services Opportunity.';
            }
        
    }
}