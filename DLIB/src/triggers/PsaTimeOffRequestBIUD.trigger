/****************************************************************************************
Name            : PsaTimeOffRequestBIUD
Author          : CLD Partners
Created Date    : February 25, 2013
Description     : Sets the Approver (on insert), creates an Assignment (on Update) and
                : deletes Assignment (on delete)
******************************************************************************************/
trigger PsaTimeOffRequestBIUD on Time_Off_Request__c (before delete, before insert, before update) {

 private String debugHash {
    get {
      return '\n\n\n*** PsaTimeOffRequestBIUD:  ';
    }
  }
    

 /*********************** INSERT TRIGGER ***************************************************/
 if(trigger.IsInsert)
 {
    system.debug(debugHash + ' INSERT TRIGGER ');
    
    // We need to get the Contact record for the OwnerId because the "Employee__c" field is a lookup to the PSA Resource's Contact record (not User record)
    Set<Id> ownerIds = new Set<Id>();
    for (Time_Off_Request__c timeOff : Trigger.new)
    {
      ownerIds.add(timeOff.OwnerId);
    }
    
    // Now populate a Map of Contacts using the User Id.  Note, the Contact.pse__Salesforce_User__c field will be the link to the Contact's User record
    Map<Id,Id> userToContactMap = new Map<Id,Id> ();
    integer cntr = 0;
    for(contact res : [
        SELECT pse__Salesforce_User__c, Id 
          FROM Contact 
         WHERE pse__Salesforce_User__c in :ownerIds 
           AND pse__Is_Resource_Active__c = TRUE])     
    {
        cntr++;
        userToContactMap.put(res.pse__Salesforce_User__c, res.Id);
    }
    system.assert(cntr > 0, 'Employee not setup as a PSA Contact and/or User.');
    
    // Set the Employee__c field and assemble a list of employee IDs to be used below
    string msg = 'Employee not setup as an ACTIVE PSA Resource.  Ensure the "Is Resource Active" check box is set on the Employee Contact record.';
    Set<Id> employeeIds = new Set<Id>();
    for (Time_Off_Request__c timeOff : Trigger.new)
    {
        timeOff.Employee__c = userToContactMap.get(timeOff.OwnerId);
        employeeIds.add(timeOff.Employee__c);
    }

    // Create a mapping of employee's Resource Manager and User.Manager
    Map<Id, Contact> managerMap = new Map<Id, Contact>([
        SELECT Id, 
               Name, 
               pse__Salesforce_User__c, 
               pse__Salesforce_User__r.ManagerId,
               pse__Salesforce_User__r.Manager.IsActive
          FROM Contact
         WHERE id in :employeeIds]);
    
    system.debug(debugHash + ' - managerMap.*: ' + managerMap);

    // loop through again and set the Approver__c to the Region RM or user Manager valuenager
    for (Time_Off_Request__c timeOff : Trigger.new)
    {
            
        // set the Approver to the User.Manager 
        if(managerMap.get(timeOff.Employee__c).pse__Salesforce_User__r.ManagerId <> null && managerMap.get(timeOff.Employee__c).pse__Salesforce_User__r.Manager.IsActive)
        {
            timeOff.Approver__c = managerMap.get(timeOff.Employee__c).pse__Salesforce_User__r.ManagerId;
            system.debug(debugHash + 'timeOff.Approver__c: ' + timeOff.Approver__c);

        } 
        else
        {
            // throw error... no Approver to set for this guy
            timeOff.addError('Employee does not have a valid PSA Approver.  Please contact PSA Support to ensure that Employee has a valid PSA Approver on the Employee User record.');    
            system.debug(debugHash + 'timeOff.Approver__c - FAILED: ' + managerMap.get(timeOff.Employee__c));
      }
      
    }
 }

 /************************ UPDATE TRIGGER **************************************************/
 if (Trigger.isUpdate) 
 {
    system.debug(debugHash + 'UPDATE TRIGGER');
    
    // get list of the 'time off' global Projects from the Request_Type field on the TOR records (note, the Request_Type should be a pick-list with a valid global Project name)
    Set<String> projectNames = new Set<String>();
    for (Time_Off_Request__c timeOff : Trigger.new)
    {
      projectNames.add(timeOff.Request_Type__c);
    }
    
    // build map of Time Off projects that match the time off 'request types' in the Time_Off_Request__c.Request_Type__c pick list [NOTE: the project names should match the pick list value].
    Map<String, Id> requestTypeMap = new Map<String, Id>();
    for (pse__Proj__c p : [
        SELECT name, Id, pse__Account__c 
          FROM pse__Proj__c 
         WHERE name in :projectNames])
         //WHERE name in ('20.01 GLBL: Vacation', '50.00 GLBL: Training / MU')])
    {
        requestTypeMap.put(p.Name, p.Id);
    }
    system.debug(debugHash + 'requestTypeMap: ' + requestTypeMap);
    
    // Prepare lists for assignment/schedule inserts
    List<pse__Assignment__c> assignmentListInsert = new List<pse__Assignment__c>();
    List<pse__Schedule__c> scheduleListInsert = new List<pse__Schedule__c>();
    List<pse__Assignment__c> assignmentListUpdate = new List<pse__Assignment__c>();
    List<pse__Schedule__c> scheduleListUpdate = new List<pse__Schedule__c>();
    List<pse__Permission_Control__c> permissionControlListInsert = new List<pse__Permission_Control__c>();
    
    // load region for temporary permission control
    Id temporaryPCRegionId;
    for(pse__Region__c region : [
        SELECT Id 
          FROM pse__Region__c 
         WHERE pse__Hierarchy_Depth__c = 0 limit 1])
    {
        temporaryPCRegionId = region.id;
    } 
    
    // process bulk Time Off updates
    Integer i = 0;
    for (Time_Off_Request__c timeOffNew : Trigger.new)
    {
        // If approved, link TOR to an assignment, update schedule
        if (timeOffNew.Status__c == 'Approved') {
        system.debug(debugHash + 'timeOffNew.Status__c == Approved');

        try 
        {
            string resourceId = timeOffNew.Employee__c; 
            system.debug(debugHash + 'Trigger -  resourceId = ' + resourceId);

            if (resourceId == null)
            {
                // do nothing  
                system.debug(debugHash + 'No Resource is associated with Time Off Request record');
            }
            else
            {
                system.debug(debugHash + 'Create New Existing Time Off Assignment');

              pse__Assignment__c assignment;
              pse__Schedule__c schedule;
              pse__Permission_Control__c temporaryPermissionControl;
  
                // Add new assignment and schedule
                system.debug(debugHash + ' assignmentExists = false. Creating schedule.');
                                   
                string msg = 'Project not setup for the Time Off Request you are submitting.';
                system.assert(requestTypeMap.get(timeOffNew.request_type__c) != null, msg);
             
        // create new assignment
        assignment = new pse__Assignment__c();
        assignment.pse__Resource__c = resourceId;
        assignment.pse__Project__c = requestTypeMap.get(timeOffNew.request_type__c);  // have to do this with lookup since Request is now a pick-list (not a lookup onto Project)
        assignment.pse__Bill_Rate__c = 0;
        assignment.pse__Status__c = 'Scheduled';

        // create new schedule
        schedule = new pse__schedule__c();
        schedule.pse__Start_Date__c = timeOffNew.First_Day_Off__c;
        schedule.pse__end_Date__c = timeOffNew.Last_Day_Off__c;
        schedule.pse__Monday_Hours__c = 8;
        schedule.pse__Tuesday_Hours__c = 8;
        schedule.pse__Wednesday_Hours__c = 8;
        schedule.pse__Thursday_Hours__c = 8;
        schedule.pse__Friday_Hours__c = 8;
        schedule.pse__Action_Force_Schedule_Refresh__c = TRUE;

        // Create temporary Permission Control to allow Staffing
        temporaryPermissionControl = new pse__Permission_Control__c();
        system.debug(debugHash + ' pse__User__c: ' + timeOffNew.Approver__c);
        system.debug(debugHash + ' UserInfo.getUserId: ' + UserInfo.getUserId());
  
                temporaryPermissionControl.pse__User__c = UserInfo.getUserId();  // give Perm Control record to current user
  
                if(temporaryPCRegionId != null)
                {
                    temporaryPermissionControl.pse__Region__c = temporaryPCRegionId;
                }

        temporaryPermissionControl.pse__Cascading_Permission__c = true;
        temporaryPermissionControl.pse__Staffing__c = true;

        // Add to insert lists
        system.debug(debugHash + 'adding assignment to insert list');
        assignmentListInsert.add(assignment);
        scheduleListInsert.add(schedule);
        permissionControlListInsert.add(temporaryPermissionControl);

                System.debug(debugHash + 'Assignment = ' + assignment + '\n');
            }
        } 
        catch (Exception e)
        {
          system.debug(debugHash + 'An error occurred while creating an Assignment: ' + e);
        }
      } 
    } 

    if(assignmentListInsert.size()>0)
    {
        // insert new assignments and link to TOR
        try
        {
            // Insert temporary Permission Control 
            insert permissionControlListInsert;
            system.debug(debugHash + 'temporary Permission Control created ' + permissionControlListInsert.size());  
            
            insert scheduleListInsert;
            system.debug(debugHash + 'schedule created ' + scheduleListInsert.size());
  
          // Link new schedules to associated assignments before 'insert'
          for (Integer assignmentIndex = 0; assignmentIndex < scheduleListInsert.size(); assignmentIndex++)
          {
              assignmentListInsert[assignmentIndex].pse__Schedule__c = scheduleListInsert[assignmentIndex].Id;
          }
          insert assignmentListInsert; 
          system.debug('insert list size' + assignmentListInsert.size());
  
          // Delete temporary Permission Control
          delete permissionControlListInsert; 
          System.debug(debugHash + 'delete temporary Permission Control');
  
          // Update TOR with assignment Ids 
          system.debug(debugHash + 'update Time Off Request with Assignment Ids');
          
          Integer currentIndex = 0;
          for (Time_Off_Request__c d : Trigger.new)
          {
              if ((d.Assignment__c == null) && (currentIndex < assignmentListInsert.size()))
              {
                  d.Assignment__c = assignmentListInsert[currentIndex].Id;
                  currentIndex++;
              }
          }
    
          system.debug(debugHash + 'assignmentListInsert successfully inserted\n');  
        } 
        catch (Exception e)
        {
            system.debug(debugHash + 'An error occurred while inserting assignments: ' + e);
        }
    }

    system.debug(debugHash + 'Trigger - Finished Creating/Updating Existing Assignment');

  }
  
  /************************* DELETE TRIGGER *****************************************************/
  if (Trigger.isDelete) {

    // otherwise, if delete caused trigger, delete associated assignments
    system.debug(debugHash + 'Trigger -  PsaTimeOffRequestBud_CreateAssignment isDelete');  

    // assemble a list of existing assignments from the TOR being deleted
    Set<Id> assignmentIds = new Set<Id>();
    for (Time_Off_Request__c timeOff : Trigger.old)
    {
        assignmentIds.add(timeOff.Assignment__c);
    }

    List<pse__Assignment__c> assignmentListExisting = new List<pse__Assignment__c>();
    for (pse__Assignment__c a : [
        SELECT Id, 
               pse__Resource__c, 
               pse__Schedule__c
          FROM pse__Assignment__c
         WHERE Id in :assignmentIds])
    {
        assignmentListExisting.add(a);
    }
    system.debug(debugHash + 'Delete Trigger - assignments size = ' + assignmentIds.size() + '\n');

    // assemble a list of existing schedules from existing assignments
    Set <Id> scheduleIds = new Set<Id>();
    for (pse__Assignment__c a : assignmentListExisting)
    {
        scheduleIds.add(a.pse__Schedule__c);
    }

    // TODO Duplicate? Necessary?
    List<pse__Schedule__c> scheduleListExisting = new List<pse__Schedule__c>();
    scheduleListExisting = [SELECT Id FROM pse__Schedule__c WHERE Id in :scheduleIds];

    // delete existing assignments
    try 
    {
        system.debug(debugHash + 'Delete Trigger -  scheduleListExisting = ' + schedulelistexisting.size() + '\n');
        delete scheduleListExisting;
        
        system.debug(debugHash + 'Delete Trigger -  assignmentListExisting = ' + assignmentListExisting.size() + '\n');
        delete assignmentListExisting;
        system.debug(debugHash + 'Delete Trigger -  assignmentListExisting successfully deleted\n');  
    } 
    catch (Exception e)
    {
        system.debug(debugHash + 'An error occurred while deleting assignments: ' + e);
    }
  }

}