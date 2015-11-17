/**
* @ClassName    : SL_SocialIntranetPostInstall 
* @JIRATicket   : Socint-209, SOCINT-997
* @CreatedOn    : 23/July/2013
* @ModifiedBy   : Ritika
* @Description  : This is the class which will run after installation of WaterCooler Intranet package Phase II
*/

/**
@Developer Name                         : Anil Kumar
Percentage of best practices followed   : 100%
No of SOQL queries used                 : 0
No of collections used                  : 0
Exception Handling implemented          : Yes
Coding standards followed               : Yes
Naming conventions followed             : Yes
Third party integrations                : No
Maximum of No of records tested with    : 
Customer Approval                       : 
Last Modified Date                      : 
Approved by                             : 
*/

global without sharing class SL_SocialIntranetPostInstall implements InstallHandler
{
     /* 
        Name: onInstall
        Param: context object, which will provide the org ID, user ID, version number of the previously installed package, is this Upgrade or is it Push
        Description : To prepare the required and important data after package installation
    */
     global void onInstall(InstallContext context) 
     {
        try
        {
            
            //If installing the package first time
            if(context.previousVersion() == null)
            {
                //To set the default page size
                SL_Intranet_PaginationSettings__c objPaginationCS = new SL_Intranet_PaginationSettings__c(name='Page Size', 
                                                                                                          Calendar_PageSize__c = 20,
                                                                                                          Calendar_PageSize_Mobile__c = 20,
                                                                                                          Documents_PageSize__c = 20,
                                                                                                          Documents_PageSize_Mobile__c = 20,
                                                                                                          EmployeeDirectory_PageSize__c = 20,
                                                                                                          EmployeeDirectory_PageSize_Mobile__c = 20,
                                                                                                          FeedPost_PageSize__c = 20,
                                                                                                          ManageGroups_PageSize__c = 20,
                                                                                                          Notifications_PageSize__c = 20,
                                                                                                          Notifications_PageSize_Mobile__c = 20,
                                                                                                          Offices_PageSize_Mobile__c = 20,
                                                                                                          SearchResult_PageSize__c = 20,
                                                                                                          IntranetEventSummaryDetails_PageSize__c = 20,
                                                                                                          SearchResult_PageSize_Mobile__c = 20);
                insert objPaginationCS;
                
                //Creating a org-wide default hierarchical custom settings, it can be overwritten by user's own custom setting
                SL_CustomizableComponent__c objCustomizableCSSComponent = new SL_CustomizableComponent__c(name = 'CustomizableCSS', Default__c = true); //SetupOwnerId
                insert objCustomizableCSSComponent;
                
                //Creating a custom setting to store default Number of days for Recent Hires user.
                SL_IntranetApplicationSetting__c objNumOfDays_RecentHires = new SL_IntranetApplicationSetting__c(name = 'Default Settings', 
                                                                                                                 Of_Days_For_Recent_Hires__c = 21,
                                                                                                                 Recent_Updates_Days_Threshold__c = 10);
                insert objNumOfDays_RecentHires;
                
                
                SL_RecursionHelper.setIsAllowTrigger(false);
                
                List<Department__c> lstDepartments = new List<Department__c>();
                Department__c objDeptIT = new Department__c(Name='Information Technology');
                lstDepartments.add(objDeptIT);
                Department__c objDeptRD = new Department__c(Name='Research & Development');
                lstDepartments.add(objDeptRD);
                Department__c objDeptFin = new Department__c(Name='Finance');
                lstDepartments.add(objDeptFin);
                Department__c objDeptHR = new Department__c(Name='Human Resources');
                lstDepartments.add(objDeptHR);
                Department__c objDeptMarket = new Department__c(Name='Sales and Marketing');
                lstDepartments.add(objDeptMarket);
                insert lstDepartments;
                
                //Creating default Silverline NY and Chicago office records
                List<Office_Locations__c> lstOffices = new List<Office_Locations__c>();
                Office_Locations__c officeNY = new Office_Locations__c(Name = 'Silverline - New York', Address__c = '648 Broadway \n Suite 200 \n New York, NY 10012',
                                                                       Company_Name__c = 'Silverline - New York', Map__c = 'https://maps.google.com/maps?hl=en&q=648+broadway,+suite+200,+new+york,+ny+10012&ie=UTF-8&hq=&hnear=0x89c2598ffa7f976d:0x62cd8291d3d4116b,648+Broadway+%23200,+New+York,+NY+10012&gl=us&ei=ftZLUYOTJIa60gHRzYCQCw&ved=0CC0Q8gEwAA',
                                                                       Phone__c = '(646) 833-3430', Display_Order__c = 1, TimeZoneSidKey__c = 'America/New_York',
                                                                       Image__c = '<img alt="Default-added image" src="/resource/SLSI__SL_IntranetHub/IntranetHub/images/NYOffice.jpg">');
                lstOffices.add(officeNY);
                Office_Locations__c officeChicago = new Office_Locations__c(Name = 'Silverline - Chicago', Address__c = 'One South Dearborn \n Suite 2100 \n Chicago, IL',
                                                                            Company_Name__c = 'Silverline - Chicago', Map__c = 'https://maps.google.com/maps?client=safari&oe=UTF-8&q=One+South+Dearborn+Suite+2100+Chicago,+IL&ie=UTF-8&hq=&hnear=0x880e2cbb37da3aed:0x55954450bd06197f,1+S+Dearborn+St+%232100,+Chicago,+IL+60603&gl=us&ei=A9dLUcqlGern0QH134HICA&ved=0CDAQ8gEwAA',
                                                                            Phone__c = '(646) 833-3553', Display_Order__c = 2, TimeZoneSidKey__c = 'America/Chicago',
                                                                            Image__c = '<img alt="Default-added image" src="/resource/SLSI__SL_IntranetHub/IntranetHub/images/ChicagoOffice.jpg">');
                lstOffices.add(officeChicago);
                
                insert lstOffices;
                
                //Creating Notification record for example.
                date myDate = date.today();
                myDate = myDate.addDays(30);
                Notification__c objNotification = new Notification__c(Name = 'Example Notification', Active__c = true, Expiry_Date__c = myDate, Notification_Detail__c = 'This is an example Notification. \n\n ' +
                                                                      'This particular notification is set up to display to All Offices, \n ' +
                                                                      'but you can specify one or more offices to see it using a \n ' +
                                                                      'multi pick list. \n\n ' +
                                                                      'You can also set whether the Notifications are \n ' +
                                                                      'active/inactive and even set an expiration date so that the \n ' +
                                                                      'notifications will no longer display after that date.',
                                                                      For_All_Offices__c = true, 
                                                                      Selected_Offices_Ids__c = officeNY.id + ';' + officeChicago.id,
                                                                      Notification_Offices__c = officeNY.Name + '\n' + officeChicago.Name,
                                                                      Display_As_Of__c = date.today());
                insert objNotification; 
                
                //Creating Intranet App for WaterCooler Intranet Help (http://socialintranet.silverlinecrm.com?subid=)
                //https://silverline.secure.force.com/licensemanager/buylicense?orgid=)
                //String strOrgId = UserInfo.getOrganizationId();  
                List<Intranet_App__c> lstIntranetApps = new List<Intranet_App__c>();
                Intranet_App__c objApp1 = new Intranet_App__c(Name = 'Silverline Website', URL__c = 'http://www.silverlinecrm.com/', Active__c = true, For_All_Offices__c = true,
                                                              Selected_Office_Ids__c = officeNY.id + ';' + officeChicago.id,
                                                              IntranetApp_Offices__c = officeNY.Name + '\n' + officeChicago.Name);
                lstIntranetApps.add(objApp1);
                Intranet_App__c objApp2 = new Intranet_App__c(Name = 'The WaterCooler Help and Info', URL__c = 'http://silverline.force.com/thewatercooler', Active__c = true,
                                                              For_All_Offices__c = true,
                                                              Selected_Office_Ids__c = officeNY.id + ';' + officeChicago.id,
                                                              IntranetApp_Offices__c = officeNY.Name + '\n' + officeChicago.Name);
                lstIntranetApps.add(objApp2);
                
                insert lstIntranetApps;
                
                // Creating default Intranet Events records.  (Socint-113)  
                RecordType objRTCompany = [Select SobjectType, Name, DeveloperName From RecordType where SobjectType = 'Intranet_Event__c' and Name = 'Company Events'];
                RecordType objRTHoliday = [Select SobjectType, Name, DeveloperName From RecordType where SobjectType = 'Intranet_Event__c' and Name = 'Holidays'];
                RecordType objRTConference = [Select SobjectType, Name, DeveloperName From RecordType where SobjectType = 'Intranet_Event__c' and Name = 'Conferences'];
                List<Intranet_Event__c> lstEvents = new List<Intranet_Event__c>();
                
                Date dtEvent1 = Date.today() + 30;
                Intranet_Event__c objEvent1 = new Intranet_Event__c(Name = 'Example Holiday', Date_of_Event__c = dtEvent1, RecordTypeId = objRTHoliday.id,
                                                                    For_All_Offices__c = true,
                                                                    Selected_Offices_Ids__c = officeNY.id + ';' + officeChicago.id,
                                                                    Intranet_Event_Offices__c = officeNY.Name + '\n' + officeChicago.Name);
                lstEvents.add(objEvent1);
                
                Date dtEvent2 = Date.today() + 60;
                Intranet_Event__c objEvent2 = new Intranet_Event__c(Name = 'Example Conference', Date_of_Event__c = dtEvent2, RecordTypeId = objRTConference.id,
                                                                    For_All_Offices__c = true, 
                                                                    Selected_Offices_Ids__c = officeNY.id + ';' + officeChicago.id,
                                                                    Intranet_Event_Offices__c = officeNY.Name + '\n' + officeChicago.Name);
                lstEvents.add(objEvent2);
                
                Date dtEvent3 = Date.today() + 90;
                Intranet_Event__c objEvent3 = new Intranet_Event__c(Name = 'Example Company Event', Date_of_Event__c = dtEvent3, RecordTypeId = objRTCompany.id,
                                                                    For_All_Offices__c = true,
                                                                    Selected_Offices_Ids__c = officeNY.id + ';' + officeChicago.id,
                                                                    Intranet_Event_Offices__c = officeNY.Name + '\n' + officeChicago.Name);
                lstEvents.add(objEvent3);
                
                insert lstEvents;
                
                //Updating User field for allow configuraiton
               /* User objUser = new User(Id = UserInfo.getUserId());
                objUser.Intranet_Administrator__c = true;
                update objUser;
               */ 
                SL_IntranetCreateDefaultRecords objDefault = new SL_IntranetCreateDefaultRecords(true);
            }   
			
			//This part of code will execute on upgrade of package
			else
				SL_IntranetCreateDefaultRecords objDefaultRecord = new SL_IntranetCreateDefaultRecords();
		}
			
        catch(exception e)
        {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {'wc-dev@silverlinecrm.com'}; 
            mail.setToAddresses(toAddresses);
            mail.setSenderDisplayName('Salesforce Support');
            mail.setSubject('ERROR EMAIL : Socint Post Installation Script Error');
            mail.setHtmlBody('Error in funtion : ' + e + ' Line Number ' + e.getLineNumber());
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
     }
	
}