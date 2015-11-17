/****************************************************************************************
Name            : psaTimecardAlert_Test
Author          : CLD Partners
Created Date    : May 10, 2013
Description     : Test class for the psaTimecardAlert class.
******************************************************************************************/
@isTest(SeeAllData=true)
private class psaTimecardAlert_Test {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test

        //TestUtilities utils = new TestUtilities();  // this class has nice methods for create users, accts, etc
        account acct = new account();
        contact employeeResource = new contact();
        user approver = new user();
        user employeeUser = new user();
        datetime weekStartDtm;
        datetime weekEndDtm;
        date weekStart;
        date weekEnd;

        // get the week's Start Date and End Date value for the date that was passed to the method
        //weekEndDtm = datetime.valueOf(string.valueOf(calcDate) + '00:00:00');
        weekEndDtm = getWeekEndingDatetime(datetime.valueOf(string.valueOf(date.today()) + ' 00:00:00'));
        weekStartDtm = weekEndDtm.addDays(-6);
        weekEnd = date.valueOf(weekEndDtm.formatGmt('yyyy-MM-dd'));
        weekStart = date.valueOf(weekStartDtm.formatGmt('yyyy-MM-dd'));

        // turn of PSA triggers that do all the actuals processing
        disableAsmTriggers();

        // Insert a new Region
        pse__Region__c region = new pse__Region__c();
        region.Name = 'Corporate';
        region.pse__Hierarchy_Depth__c = 0;
        insert region;

        // Insert a temp project
        pse__Proj__c TcaProject = new pse__Proj__c();
        TcaProject.Name = 'TC Alert';
        TcaProject.pse__Is_Active__c = True;
        TcaProject.pse__Is_Billable__c = False;
        TcaProject.pse__Region__c = region.Id;
        TcaProject.pse__Allow_Timecards_Without_Assignment__c = True;
        insert TcaProject;

        pse__Milestone__c milestone = new pse__Milestone__c();
        milestone.pse__Project__c = TcaProject.Id;
        milestone.pse__Default_Bill_Rate__c = 10;
        milestone.pse__Target_Date__c = date.today();
        insert milestone;

        // Setup user and resource [contact] records
        //acct = utils.createAccount();
        //employeeUser = utils.createUser(approver.Id, true);
        //employeeResource = utils.createContact(employeeUser, approver, acct.Id);
        acct = createAccount();
        approver = createUser();
        employeeUser = createUser();
        employeeResource = createContact(employeeUser, acct.Id, region.Id);

        // set the User.Manager value on the employeeUser (there is TOR validation that the User.Manager must be set)
        employeeUser.ManagerId = approver.Id;
        update employeeUser;

        system.debug('*** TCA TEST CLASS: Approver:' + approver);
        system.debug('*** TCA TEST CLASS: employeeUser:' + employeeUser);
        system.debug('*** TCA TEST CLASS: employeeResource:' + employeeResource);

        // Create a Timecard Edit Permission Control record
        pse__Permission_Control__c pControl = new pse__Permission_Control__c();
        pControl.pse__Timecard_Entry__c = True;
        pControl.pse__Timecard_Ops_Edit__c = True;
        pControl.pse__Resource__c = employeeResource.id;
        pControl.pse__User__c = UserInfo.getUserId();
        insert pControl;


        // Create a Timecard Record
        pse__Timecard_Header__c Tc = new pse__Timecard_Header__c();

        Tc.pse__Project__c = TcaProject.Id;
        Tc.pse__Milestone__c = milestone.Id;
        Tc.pse__Resource__c = employeeResource.Id;
        Tc.pse__Start_Date__c = weekStart;
        Tc.pse__End_Date__c = weekEnd;
        Tc.pse__Monday_Hours__c = 8;
        Tc.pse__Status__c = 'Saved';
        Tc.pse__Billable__c = False;
        Tc.CurrencyIsoCode = 'USD';
        insert Tc;
        system.debug('*** TCA TEST CLASS: Tc:' + Tc);

        // Run test
        test.startTest();

        // call method to calc Timecard Availabilty
        //psaTimecardAlert.calculateResourceTimecardHours(weekEnd, employeeResource.Id);
        psaTimecardAlertBatch batch = new psaTimecardAlertBatch();
        Id batchId = database.executeBatch(batch);

        test.StopTest();
    }

    /*** HELPER METHODS THAT CAN OFTEN BE FOUND IN UTILITY CLASS (INCLUDED HERE FOR SIMPLIFICATION) ***/
    // Create test account
    private static Account createAccount(){
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.BillingCity = 'New York';
        acc.BillingStreet = '100 Main st';
        acc.BillingState = 'NY';
        acc.BillingPostalCode = '11111';
        acc.BillingCountry = 'US';
        insert acc;
        return acc;
    }

   // Create test User
   private static User createUser(){
        Integer i = Math.random().intValue();
        Profile pf = [Select id from Profile where  name = 'System Administrator' LIMIT 1];

        User u1 = new User();
        u1.firstName = 'test' + i;
        u1.LastName = 'test' + i;
        u1.Alias = 'tst' + i;
        u1.Email = 'test' + i + '.test@mailinator.com';
        u1.UserName='test'+ i + '_' + Math.random().format() + System.now().millisecond().format() + 'user1@gmail.com';
        u1.ProfileId = pf.Id;
        u1.EmailEncodingKey ='ISO-8859-1';
        u1.LanguageLocaleKey = 'en_US';
        u1.TimeZoneSidKey ='America/New_York';
        u1.LocaleSidKey = 'en_US';
        u1.IsActive = true;
        u1.Title = 'Title';
        u1.Department = 'TestDepartment';
        insert u1;
        return u1;
    }


    // Create test Resource
    private static Contact createContact(User SFUser, Id accId, Id regionId){
        Contact contact = new Contact(firstName ='Test Contact',lastName = 'last name' ,email='test@example.com');
        contact.pse__Is_Resource__c = true;
        contact.pse__Is_Resource_Active__c = true;
        contact.pse__Salesforce_User__c = SFUser.Id;
        contact.pse__Start_Date__c = date.today().toStartofWeek().addDays(-15);
        contact.accountId = accId;
        contact.pse__Region__c = regionId;
        insert contact;
        return contact;
    }

    /*** Takes a date and determines the week ending date ****/
    private static Datetime getWeekEndingDatetime(Datetime dtm){

    // Note: GMT is used from the datetime that is passed in
    //datetime dtm = datetime.valueOf(string.valueOf(dt) + '00:00:00');
    system.debug('*** psaTimecardAlert.getWeekEndingDateString: getWeekEndingDateString dtm=' + dtm);

    if(dtm == null) {
        return datetime.valueOf('1970-01-01');
    }

    datetime dtmWeekEndingGmt = datetime.newInstanceGmt(dtm.dateGMT(), Time.newInstance(0,0,0,0));
    string weekday = dtmWeekEndingGmt.formatGmt('E');

    // Note: assumes week ends on Saturday
    system.Debug('*** psaTimecardAlert.getWeekEndingDateString: Weekday for ' + dtmWeekEndingGmt + '=' + weekday);

    if(weekday == 'Mon'){
        dtmWeekEndingGmt = dtmWeekEndingGmt.addDays(5);
    } else if(weekday == 'Tue'){
        dtmWeekEndingGmt = dtmWeekEndingGmt.addDays(4);
    } else if(weekday == 'Wed'){
        dtmWeekEndingGmt = dtmWeekEndingGmt.addDays(3);
    } else if(weekday == 'Thu'){
        dtmWeekEndingGmt = dtmWeekEndingGmt.addDays(2);
    } else if(weekday == 'Fri'){
        dtmWeekEndingGmt = dtmWeekEndingGmt.addDays(1);
    } else if(weekday == 'Sat'){
        //do nothing
    } else if(weekday == 'Sun'){
        dtmWeekEndingGmt = dtmWeekEndingGmt.addDays(6);
    }

    string stringWeekEndingDate = dtmWeekEndingGmt.formatGmt('yyyy-MM-dd');
    system.debug('*** psaTimecardAlert.getWeekEndingDatetime: stringWeekEndingDate=' + stringWeekEndingDate);

    //return stringWeekEndingDate;
    return dtmWeekEndingGmt;
    }

    // disables core PSA triggers that handle all the actual rollups and such (don't need them here.. they just cause governer limit exceptions)
    @isTest(SeeAllData=true)
    static void disableAsmTriggers()
    {
       system.debug('*** COW1: disableAsmTriggers');


        appirio_core__Config_Value__c actualsCoreValue = [
            select Id,
                   appirio_core__Value__c,
                   appirio_core__Config_Option__c
              from appirio_core__Config_Value__c
             where appirio_core__config_Option__r.appirio_core__Group_Key__c = 'asm-triggers'
               and appirio_core__config_Option__r.name = 'handleActualsForTransaction'
             limit 1];

           actualsCoreValue.appirio_core__Value__c = 'false';

           system.debug('*** COW2: actualsCoreValue: ' + actualsCoreValue);
           update actualsCoreValue;

        /*

        for (List<appirio_core__Config_Value__c> trigValList :
           [select Id, appirio_core__Value__c, appirio_core__Config_Option__c
           from appirio_core__Config_Value__c
           where appirio_core__config_Option__r.appirio_core__Group_Key__c = 'asm-triggers'
           and appirio_core__config_Option__r.name = 'handleActualsForTransaction'])
        {
            trigValList.appirio_core__Value__c = 'false';
            system.debug('*** COW: disable asm triggers: ' + trigValList.appirio_core__Config_Option__c);

            for (appirio_core__Config_Value__c cv : trigValList)
            {
                cv.appirio_core__Value__c = 'false';
                system.debug('*** COW: disable asm triggers: ' + cv.appirio_core__Config_Option__c);
            }

            update trigValList;

        }
        update trigValList;
        */
    }


}