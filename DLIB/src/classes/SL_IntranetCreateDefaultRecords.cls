/**
* @ClassName    : SL_IntranetCreateDefaultRecords 
* @JIRATicket   : Socint-997
* @CreatedOn    : 27/11/14 Modified
* @ModifiedBy   : Ritika on 18 Dec/2014
* @Description  : This class is used for creating default Widget, Page, PageRegionWidget and their configuration when a user install a package or upgrade it.
*/


/**
@ Ritika Bhargava
Percentage of best practices followed   : 100%
No of SOQL queries used                 : 8
No of collections used                  : 
Exception Handling implemented          : Yes
Coding standards followed               : Yes
Naming conventions followed             : Yes
Third party integrations                : No
Maximum of No of records tested with    : 
Customer Approval                       : 
Last Modified Date                      : 
Approved by                             : 
*/

global class SL_IntranetCreateDefaultRecords {
    
    private Boolean isOnInstall = false;
    
    private static String strNameSpace;
    
     //Map to refer widget with their configuration on upgrade
    Map<String, Map<String,Object>> mapWidgetConfigUpgrade;
    //List to store only those widget, whose configuration has to be updated
	List<Widget__c> lstWidgetsNeedToBeUpdated;
    
	//Block to get NameSpace
    static
	{
		try
    	{
    		if(UserInfo.isCurrentUserLicensed('SLSI'))
    			strNameSpace = 'SLSI__';
    	}
    	catch(TypeException ex)
    	{
    		 strNameSpace = '';
    	}
	}
	
    global SL_IntranetCreateDefaultRecords(Boolean blnOnInstall)
    {
        isOnInstall = blnOnInstall;
        createIntranetRecords();
    }
	
	//Default constructor
	global SL_IntranetCreateDefaultRecords()
    {
		mapWidgetConfigUpgrade = new Map<String, Map<String,Object>>();
		lstWidgetsNeedToBeUpdated = new List<Widget__c>();
        updateExistingWidgetConfiguration();
    }
    
    
	/* @Name           - createIntranetRecords
	   @Parameters     - None 
	   @Return Type    - Void
	   @Description    - To prepare the required and important data after package installation
	*/
    private void createIntranetRecords()
    {
        //To delete the existing configuration records.
        if(!isOnInstall)
        {
            List<PageRegionWidget__c> lstPRW = new List<PageRegionWidget__c>();
            lstPRW = [SELECT Id from PageRegionWidget__c WHERE Name != null];
            if(lstPRW.size() > 0) delete lstPRW;
            
            List<PageRegion__c> lstPR = new List<PageRegion__c>();
            lstPR = [SELECT Id from PageRegion__c WHERE Name != null];
            if(lstPR.size() > 0) delete lstPR;
            
            List<Page__c> lstP = new List<Page__c>();
            lstP = [SELECT Id from Page__c WHERE Name != null];
            if(lstP.size() > 0) delete lstP;
            
            List<Region__c> lstR = new List<Region__c>();
            lstR = [SELECT Id from Region__c WHERE Name != null];
            if(lstR.size() > 0) delete lstR;
            
            List<Widget__c> lstW = new List<Widget__c>();
            lstW = [SELECT Id from Widget__c WHERE Name != null];
            if(lstW.size() > 0) delete lstW;
			
			Content_Chatter__c objCC = [SELECT Content_Id__c FROM Content_Chatter__c WHERE Content_Id__c = 'ContentFARecord' LIMIT 1];
            delete objCC;
        }
        
		//Creating a default record for uploading a file in chatter widget through referring this record as a parent to attachment object.
        Content_Chatter__c objContentChatter = new Content_Chatter__c(Content_Id__c = 'ContentFARecord');
        insert objContentChatter;
        
        /*** Start : Creating Page Records  ***/
        List<Page__c> lstPage = new List<Page__c>();
        Page__c objPage1 = new Page__c(Name = 'Home', LayoutType__c = '3 Column Layout Page', Order__c = 1, Target_Console__c = 'All');
        Page__c objPage2 = new Page__c(Name = 'Documents', LayoutType__c = '3 Column Layout Page', Order__c = 2, Target_Console__c = 'All');
        Page__c objPage3 = new Page__c(Name = 'Company Calendar', LayoutType__c = '3 Column Layout Page', Order__c = 3, Target_Console__c = 'All');
        Page__c objPage4 = new Page__c(Name = 'Employee Directory', LayoutType__c = '2 Column Layout Right Main Page', Order__c = 4, Target_Console__c = 'All');
        Page__c objPage5 = new Page__c(Name = 'Manage Groups', LayoutType__c = '2 Column Layout Right Main Page', Target_Console__c = 'All');
        Page__c objPage6 = new Page__c(Name = 'Search', LayoutType__c = '3 Column Layout Page', Target_Console__c = 'All');
        Page__c objPage7 = new Page__c(Name = 'Employee Profile', LayoutType__c = '3 Column Layout Page', Target_Console__c = 'All');
/*m*/   Page__c objPage8 = new Page__c(Name = 'Offices', LayoutType__c = '3 Column Layout Page', Target_Console__c = 'Mobile');
/*m*/   Page__c objPage9 = new Page__c(Name = 'Notifications', LayoutType__c = '3 Column Layout Page', Target_Console__c = 'Mobile');
        
        lstPage.add(objPage1);
        lstPage.add(objPage2);
        lstPage.add(objPage3);
        lstPage.add(objPage4);
        lstPage.add(objPage5);
        lstPage.add(objPage6);
        lstPage.add(objPage7);
/*m*/   lstPage.add(objPage8);
/*m*/   lstPage.add(objPage9);
        Database.insert(lstPage, false);
        /*** End : Creating Page Records  ***/
        
        /*** Start : Creating Region Records  ***/
        List<Region__c> lstRegion = new List<Region__c>();
        Region__c objRegion1 = new Region__c(Name = 'HeaderUserInfo');
        Region__c objRegion2 = new Region__c(Name = 'HeaderLogoSection');
        Region__c objRegion3 = new Region__c(Name = 'HeaderNavigationSection');
        Region__c objRegion4 = new Region__c(Name = 'BannerRegion');
        Region__c objRegion5 = new Region__c(Name = 'LeftSideBar');
        Region__c objRegion6 = new Region__c(Name = 'MainSection');
        Region__c objRegion7 = new Region__c(Name = 'RightSideBar');
        Region__c objRegion8 = new Region__c(Name = 'FooterSection');
/*m*/   Region__c objRegion9 = new Region__c(Name = 'MobileMainSection');
        lstRegion.add(objRegion1);
        lstRegion.add(objRegion2);
        lstRegion.add(objRegion3);
        lstRegion.add(objRegion4);
        lstRegion.add(objRegion5);
        lstRegion.add(objRegion6);
        lstRegion.add(objRegion7);
        lstRegion.add(objRegion8);
/*m*/   lstRegion.add(objRegion9);
        Database.insert(lstRegion, false);
        /*** End : Creating Region Records  ***/
        
        /*** Start : Creating PageRegion Records  ***/ 
        List<PageRegion__c> lstPageRegion = new List<PageRegion__c>();
        //For Home page
        PageRegion__c objPageRegion11 = new PageRegion__c(Page__c = objPage1.Id, Region__c = objRegion1.Id);
        PageRegion__c objPageRegion12 = new PageRegion__c(Page__c = objPage1.Id, Region__c = objRegion2.Id);
        PageRegion__c objPageRegion13 = new PageRegion__c(Page__c = objPage1.Id, Region__c = objRegion3.Id);
        PageRegion__c objPageRegion14 = new PageRegion__c(Page__c = objPage1.Id, Region__c = objRegion4.Id);
        PageRegion__c objPageRegion15 = new PageRegion__c(Page__c = objPage1.Id, Region__c = objRegion5.Id);
        PageRegion__c objPageRegion16 = new PageRegion__c(Page__c = objPage1.Id, Region__c = objRegion6.Id);
        PageRegion__c objPageRegion17 = new PageRegion__c(Page__c = objPage1.Id, Region__c = objRegion7.Id);
        PageRegion__c objPageRegion18 = new PageRegion__c(Page__c = objPage1.Id, Region__c = objRegion8.Id);
/*m*/   PageRegion__c objPageRegion19 = new PageRegion__c(Page__c = objPage1.Id, Region__c = objRegion9.Id);
        lstPageRegion.add(objPageRegion11);
        lstPageRegion.add(objPageRegion12);
        lstPageRegion.add(objPageRegion13);
        lstPageRegion.add(objPageRegion14);
        lstPageRegion.add(objPageRegion15);
        lstPageRegion.add(objPageRegion16);
        lstPageRegion.add(objPageRegion17);
        lstPageRegion.add(objPageRegion18);
/*m*/   lstPageRegion.add(objPageRegion19);
        //For Documents page
        PageRegion__c objPageRegion21 = new PageRegion__c(Page__c = objPage2.Id, Region__c = objRegion1.Id);
        PageRegion__c objPageRegion22 = new PageRegion__c(Page__c = objPage2.Id, Region__c = objRegion2.Id);
        PageRegion__c objPageRegion23 = new PageRegion__c(Page__c = objPage2.Id, Region__c = objRegion3.Id);
        PageRegion__c objPageRegion24 = new PageRegion__c(Page__c = objPage2.Id, Region__c = objRegion4.Id);
        PageRegion__c objPageRegion25 = new PageRegion__c(Page__c = objPage2.Id, Region__c = objRegion5.Id);
        PageRegion__c objPageRegion26 = new PageRegion__c(Page__c = objPage2.Id, Region__c = objRegion6.Id);
        PageRegion__c objPageRegion27 = new PageRegion__c(Page__c = objPage2.Id, Region__c = objRegion7.Id);
        PageRegion__c objPageRegion28 = new PageRegion__c(Page__c = objPage2.Id, Region__c = objRegion8.Id);
/*m*/   PageRegion__c objPageRegion29 = new PageRegion__c(Page__c = objPage2.Id, Region__c = objRegion9.Id);
        
        lstPageRegion.add(objPageRegion21);
        lstPageRegion.add(objPageRegion22);
        lstPageRegion.add(objPageRegion23);
        lstPageRegion.add(objPageRegion24);
        lstPageRegion.add(objPageRegion25);
        lstPageRegion.add(objPageRegion26);
        lstPageRegion.add(objPageRegion27);
        lstPageRegion.add(objPageRegion28);
/*m*/   lstPageRegion.add(objPageRegion29);
        //For Calendars page
        PageRegion__c objPageRegion31 = new PageRegion__c(Page__c = objPage3.Id, Region__c = objRegion1.Id);
        PageRegion__c objPageRegion32 = new PageRegion__c(Page__c = objPage3.Id, Region__c = objRegion2.Id);
        PageRegion__c objPageRegion33 = new PageRegion__c(Page__c = objPage3.Id, Region__c = objRegion3.Id);
        PageRegion__c objPageRegion34 = new PageRegion__c(Page__c = objPage3.Id, Region__c = objRegion4.Id);
        PageRegion__c objPageRegion35 = new PageRegion__c(Page__c = objPage3.Id, Region__c = objRegion5.Id);
        PageRegion__c objPageRegion36 = new PageRegion__c(Page__c = objPage3.Id, Region__c = objRegion6.Id);
        PageRegion__c objPageRegion37 = new PageRegion__c(Page__c = objPage3.Id, Region__c = objRegion7.Id);
        PageRegion__c objPageRegion38 = new PageRegion__c(Page__c = objPage3.Id, Region__c = objRegion8.Id);
/*m*/   PageRegion__c objPageRegion39 = new PageRegion__c(Page__c = objPage3.Id, Region__c = objRegion9.Id);
        
        lstPageRegion.add(objPageRegion31);
        lstPageRegion.add(objPageRegion32);
        lstPageRegion.add(objPageRegion33);
        lstPageRegion.add(objPageRegion34);
        lstPageRegion.add(objPageRegion35);
        lstPageRegion.add(objPageRegion36);
        lstPageRegion.add(objPageRegion37);
        lstPageRegion.add(objPageRegion38);
/*m*/   lstPageRegion.add(objPageRegion39);
        
        //For Employee Directory page
        PageRegion__c objPageRegion41 = new PageRegion__c(Page__c = objPage4.Id, Region__c = objRegion1.Id);
        PageRegion__c objPageRegion42 = new PageRegion__c(Page__c = objPage4.Id, Region__c = objRegion2.Id);
        PageRegion__c objPageRegion43 = new PageRegion__c(Page__c = objPage4.Id, Region__c = objRegion3.Id);
        PageRegion__c objPageRegion44 = new PageRegion__c(Page__c = objPage4.Id, Region__c = objRegion4.Id);
        PageRegion__c objPageRegion45 = new PageRegion__c(Page__c = objPage4.Id, Region__c = objRegion5.Id);
        PageRegion__c objPageRegion46 = new PageRegion__c(Page__c = objPage4.Id, Region__c = objRegion6.Id);
        PageRegion__c objPageRegion47 = new PageRegion__c(Page__c = objPage4.Id, Region__c = objRegion7.Id);
        PageRegion__c objPageRegion48 = new PageRegion__c(Page__c = objPage4.Id, Region__c = objRegion8.Id);
/*m*/   PageRegion__c objPageRegion49 = new PageRegion__c(Page__c = objPage4.Id, Region__c = objRegion9.Id);
        
        lstPageRegion.add(objPageRegion41);
        lstPageRegion.add(objPageRegion42);
        lstPageRegion.add(objPageRegion43);
        lstPageRegion.add(objPageRegion44);
        lstPageRegion.add(objPageRegion45);
        lstPageRegion.add(objPageRegion46);
        lstPageRegion.add(objPageRegion47);
        lstPageRegion.add(objPageRegion48);
/*m*/   lstPageRegion.add(objPageRegion49);
        
        //For Manage Groups page
        PageRegion__c objPageRegion51 = new PageRegion__c(Page__c = objPage5.Id, Region__c = objRegion1.Id);
        PageRegion__c objPageRegion52 = new PageRegion__c(Page__c = objPage5.Id, Region__c = objRegion2.Id);
        PageRegion__c objPageRegion53 = new PageRegion__c(Page__c = objPage5.Id, Region__c = objRegion3.Id);
        PageRegion__c objPageRegion54 = new PageRegion__c(Page__c = objPage5.Id, Region__c = objRegion4.Id);
        PageRegion__c objPageRegion55 = new PageRegion__c(Page__c = objPage5.Id, Region__c = objRegion5.Id);
        PageRegion__c objPageRegion56 = new PageRegion__c(Page__c = objPage5.Id, Region__c = objRegion6.Id);
        PageRegion__c objPageRegion57 = new PageRegion__c(Page__c = objPage5.Id, Region__c = objRegion7.Id);
        PageRegion__c objPageRegion58 = new PageRegion__c(Page__c = objPage5.Id, Region__c = objRegion8.Id);
/*m*/   PageRegion__c objPageRegion59 = new PageRegion__c(Page__c = objPage5.Id, Region__c = objRegion9.Id);
        
        lstPageRegion.add(objPageRegion51);
        lstPageRegion.add(objPageRegion52);
        lstPageRegion.add(objPageRegion53);
        lstPageRegion.add(objPageRegion54);
        lstPageRegion.add(objPageRegion55);
        lstPageRegion.add(objPageRegion56);
        lstPageRegion.add(objPageRegion57);
        lstPageRegion.add(objPageRegion58);
/*m*/   lstPageRegion.add(objPageRegion59);
        
        //For Employee Profile page
        PageRegion__c objPageRegion61 = new PageRegion__c(Page__c = objPage6.Id, Region__c = objRegion1.Id);
        PageRegion__c objPageRegion62 = new PageRegion__c(Page__c = objPage6.Id, Region__c = objRegion2.Id);
        PageRegion__c objPageRegion63 = new PageRegion__c(Page__c = objPage6.Id, Region__c = objRegion3.Id);
        PageRegion__c objPageRegion64 = new PageRegion__c(Page__c = objPage6.Id, Region__c = objRegion4.Id);
        PageRegion__c objPageRegion65 = new PageRegion__c(Page__c = objPage6.Id, Region__c = objRegion5.Id);
        PageRegion__c objPageRegion66 = new PageRegion__c(Page__c = objPage6.Id, Region__c = objRegion6.Id);
        PageRegion__c objPageRegion67 = new PageRegion__c(Page__c = objPage6.Id, Region__c = objRegion7.Id);
        PageRegion__c objPageRegion68 = new PageRegion__c(Page__c = objPage6.Id, Region__c = objRegion8.Id);
/*m*/   PageRegion__c objPageRegion69 = new PageRegion__c(Page__c = objPage6.Id, Region__c = objRegion9.Id);
        
        lstPageRegion.add(objPageRegion61);
        lstPageRegion.add(objPageRegion62);
        lstPageRegion.add(objPageRegion63);
        lstPageRegion.add(objPageRegion64);
        lstPageRegion.add(objPageRegion65);
        lstPageRegion.add(objPageRegion66);
        lstPageRegion.add(objPageRegion67);
        lstPageRegion.add(objPageRegion68);
/*m*/   lstPageRegion.add(objPageRegion69);
        
        //For Search page
        PageRegion__c objPageRegion71 = new PageRegion__c(Page__c = objPage7.Id, Region__c = objRegion1.Id);
        PageRegion__c objPageRegion72 = new PageRegion__c(Page__c = objPage7.Id, Region__c = objRegion2.Id);
        PageRegion__c objPageRegion73 = new PageRegion__c(Page__c = objPage7.Id, Region__c = objRegion3.Id);
        PageRegion__c objPageRegion74 = new PageRegion__c(Page__c = objPage7.Id, Region__c = objRegion4.Id);
        PageRegion__c objPageRegion75 = new PageRegion__c(Page__c = objPage7.Id, Region__c = objRegion5.Id);
        PageRegion__c objPageRegion76 = new PageRegion__c(Page__c = objPage7.Id, Region__c = objRegion6.Id);
        PageRegion__c objPageRegion77 = new PageRegion__c(Page__c = objPage7.Id, Region__c = objRegion7.Id);
        PageRegion__c objPageRegion78 = new PageRegion__c(Page__c = objPage7.Id, Region__c = objRegion8.Id);
/*m*/   PageRegion__c objPageRegion79 = new PageRegion__c(Page__c = objPage7.Id, Region__c = objRegion9.Id);
        
        lstPageRegion.add(objPageRegion71);
        lstPageRegion.add(objPageRegion72);
        lstPageRegion.add(objPageRegion73);
        lstPageRegion.add(objPageRegion74);
        lstPageRegion.add(objPageRegion75);
        lstPageRegion.add(objPageRegion76);
        lstPageRegion.add(objPageRegion77);
        lstPageRegion.add(objPageRegion78);
/*m*/   lstPageRegion.add(objPageRegion79);
        
        //For Offices (Mobile view)
/*mm*/  PageRegion__c objPageRegion81 = new PageRegion__c(Page__c = objPage8.Id, Region__c = objRegion1.Id);
        PageRegion__c objPageRegion82 = new PageRegion__c(Page__c = objPage8.Id, Region__c = objRegion2.Id);
        PageRegion__c objPageRegion83 = new PageRegion__c(Page__c = objPage8.Id, Region__c = objRegion3.Id);
        PageRegion__c objPageRegion84 = new PageRegion__c(Page__c = objPage8.Id, Region__c = objRegion4.Id);
        PageRegion__c objPageRegion85 = new PageRegion__c(Page__c = objPage8.Id, Region__c = objRegion5.Id);
        PageRegion__c objPageRegion86 = new PageRegion__c(Page__c = objPage8.Id, Region__c = objRegion6.Id);
        PageRegion__c objPageRegion87 = new PageRegion__c(Page__c = objPage8.Id, Region__c = objRegion7.Id);
        PageRegion__c objPageRegion88 = new PageRegion__c(Page__c = objPage8.Id, Region__c = objRegion8.Id);
        PageRegion__c objPageRegion89 = new PageRegion__c(Page__c = objPage8.Id, Region__c = objRegion9.Id);
        
        lstPageRegion.add(objPageRegion81);
        lstPageRegion.add(objPageRegion82);
        lstPageRegion.add(objPageRegion83);
        lstPageRegion.add(objPageRegion84);
        lstPageRegion.add(objPageRegion85);
        lstPageRegion.add(objPageRegion86);
        lstPageRegion.add(objPageRegion87);
        lstPageRegion.add(objPageRegion88);
        lstPageRegion.add(objPageRegion89);
        
        //For Notifications (Mobile view)
        PageRegion__c objPageRegion91 = new PageRegion__c(Page__c = objPage9.Id, Region__c = objRegion1.Id);
        PageRegion__c objPageRegion92 = new PageRegion__c(Page__c = objPage9.Id, Region__c = objRegion2.Id);
        PageRegion__c objPageRegion93 = new PageRegion__c(Page__c = objPage9.Id, Region__c = objRegion3.Id);
        PageRegion__c objPageRegion94 = new PageRegion__c(Page__c = objPage9.Id, Region__c = objRegion4.Id);
        PageRegion__c objPageRegion95 = new PageRegion__c(Page__c = objPage9.Id, Region__c = objRegion5.Id);
        PageRegion__c objPageRegion96 = new PageRegion__c(Page__c = objPage9.Id, Region__c = objRegion6.Id);
        PageRegion__c objPageRegion97 = new PageRegion__c(Page__c = objPage9.Id, Region__c = objRegion7.Id);
        PageRegion__c objPageRegion98 = new PageRegion__c(Page__c = objPage9.Id, Region__c = objRegion8.Id);
        PageRegion__c objPageRegion99 = new PageRegion__c(Page__c = objPage9.Id, Region__c = objRegion9.Id);
        
        lstPageRegion.add(objPageRegion91);
        lstPageRegion.add(objPageRegion92);
        lstPageRegion.add(objPageRegion93);
        lstPageRegion.add(objPageRegion94);
        lstPageRegion.add(objPageRegion95);
        lstPageRegion.add(objPageRegion96);
        lstPageRegion.add(objPageRegion97);
        lstPageRegion.add(objPageRegion98);
        lstPageRegion.add(objPageRegion99);
/*mm*/        
        Database.insert(lstPageRegion, false);
        /*** End : Creating PageRegion Records  ***/ 
        
        /*** Start : Creating Widgets Records  ***/ 
     	List<Widget__c> lstWidget = new List<Widget__c>();
        lstWidget.addAll(createWidgetRecord());
        
        Widget__c objWidgetApp = lstWidget[0];
        Widget__c objWidgetBanner = lstWidget[1];
        Widget__c objWidgetCustomChatter = lstWidget[2];
        Widget__c objWidgetChatterGroup = lstWidget[3];
        Widget__c objWidgetManageGroup = lstWidget[4];
        Widget__c objWidgetStandardChatter = lstWidget[5];
        Widget__c objWidgetDocType = lstWidget[6];
        Widget__c objWidgetDocument = lstWidget[7];
        Widget__c objWidgetEmbedded = lstWidget[8];
        Widget__c objWidgetEmpDirDetail = lstWidget[9];
        Widget__c objWidgetEmpDirList = lstWidget[10];
        Widget__c objWidgetEmpDirOffice = lstWidget[11];
        Widget__c objWidgetEmpDirReport = lstWidget[12];
        Widget__c objWidgetEventDetail = lstWidget[13];
        Widget__c objWidgetEventType = lstWidget[14];
        Widget__c objWidgetNavigation = lstWidget[15];
        Widget__c objWidgetNotifDetail = lstWidget[16];
        Widget__c objWidgetNotifList = lstWidget[17];
        Widget__c objWidgetOffices = lstWidget[18];
        Widget__c objWidgetQuickCreate = lstWidget[19];
        Widget__c objWidgetSearch = lstWidget[20];
        Widget__c objWidgetSearchResult = lstWidget[21];
        Widget__c objWidgetSearchType = lstWidget[22];
        Widget__c objWidgetStaffUpdate = lstWidget[23];
        Widget__c objWidgetUserInfo = lstWidget[24];
        Widget__c objWidgetSobjectList = lstWidget[25];
        Widget__c objWidgetSobjectDetail = lstWidget[26];
        Widget__c objWidgetOfficeDetail = lstWidget[27];
        Widget__c objWidgetDepartment = lstWidget[28];
        Widget__c objWidgetEventSummary = lstWidget[29];
        Widget__c objWidgetEventSummaryDetail = lstWidget[30];
        Widget__c objWidgetKeyContact = lstWidget[31];
        Widget__c objWidgetRecentUpdate = lstWidget[32];
        Widget__c objWidgetListView = lstWidget[33];
        Widget__c objWidgetRecentDocument = lstWidget[34];
        
        Database.insert(lstWidget, false);
		
        /*** End : Creating Widgets Records  ***/ 
        
        /** Start : Creating Default Page Region Widgets records for each pages **/
        //UserInfo widget
        List<PageRegionWidget__c> lstPageRegionWidget = new List<PageRegionWidget__c>();
        PageRegionWidget__c objPageRegionWidget11 = new PageRegionWidget__c(Widget__c = objWidgetUserInfo.Id, Page_Region__c = objPageRegion11.Id, Configuration__c = '');
        PageRegionWidget__c objPageRegionWidget12 = new PageRegionWidget__c(Widget__c = objWidgetUserInfo.Id, Page_Region__c = objPageRegion21.Id, Configuration__c = '');
        PageRegionWidget__c objPageRegionWidget13 = new PageRegionWidget__c(Widget__c = objWidgetUserInfo.Id, Page_Region__c = objPageRegion31.Id, Configuration__c = '');
        PageRegionWidget__c objPageRegionWidget14 = new PageRegionWidget__c(Widget__c = objWidgetUserInfo.Id, Page_Region__c = objPageRegion41.Id, Configuration__c = '');
        PageRegionWidget__c objPageRegionWidget15 = new PageRegionWidget__c(Widget__c = objWidgetUserInfo.Id, Page_Region__c = objPageRegion51.Id, Configuration__c = '');
        PageRegionWidget__c objPageRegionWidget16 = new PageRegionWidget__c(Widget__c = objWidgetUserInfo.Id, Page_Region__c = objPageRegion61.Id, Configuration__c = '');
        PageRegionWidget__c objPageRegionWidget17 = new PageRegionWidget__c(Widget__c = objWidgetUserInfo.Id, Page_Region__c = objPageRegion71.Id, Configuration__c = '');
     
        lstPageRegionWidget.add(objPageRegionWidget11);
        lstPageRegionWidget.add(objPageRegionWidget12);
        lstPageRegionWidget.add(objPageRegionWidget13);
        lstPageRegionWidget.add(objPageRegionWidget14);
        lstPageRegionWidget.add(objPageRegionWidget15);
        lstPageRegionWidget.add(objPageRegionWidget16);
        lstPageRegionWidget.add(objPageRegionWidget17);
        
        //Search widget
        PageRegionWidget__c objPageRegionWidget21 = new PageRegionWidget__c(Widget__c = objWidgetSearch.Id, Page_Region__c = objPageRegion12.Id, Configuration__c = '', Order__c = 1);
        PageRegionWidget__c objPageRegionWidget22 = new PageRegionWidget__c(Widget__c = objWidgetSearch.Id, Page_Region__c = objPageRegion22.Id, Configuration__c = '', Order__c = 1);
        PageRegionWidget__c objPageRegionWidget23 = new PageRegionWidget__c(Widget__c = objWidgetSearch.Id, Page_Region__c = objPageRegion32.Id, Configuration__c = '', Order__c = 1);
        PageRegionWidget__c objPageRegionWidget24 = new PageRegionWidget__c(Widget__c = objWidgetSearch.Id, Page_Region__c = objPageRegion42.Id, Configuration__c = '', Order__c = 1);
        PageRegionWidget__c objPageRegionWidget25 = new PageRegionWidget__c(Widget__c = objWidgetSearch.Id, Page_Region__c = objPageRegion52.Id, Configuration__c = '', Order__c = 1);
        PageRegionWidget__c objPageRegionWidget26 = new PageRegionWidget__c(Widget__c = objWidgetSearch.Id, Page_Region__c = objPageRegion62.Id, Configuration__c = '', Order__c = 1);
        PageRegionWidget__c objPageRegionWidget27 = new PageRegionWidget__c(Widget__c = objWidgetSearch.Id, Page_Region__c = objPageRegion72.Id, Configuration__c = '', Order__c = 1);
     
        lstPageRegionWidget.add(objPageRegionWidget21);
        lstPageRegionWidget.add(objPageRegionWidget22);
        lstPageRegionWidget.add(objPageRegionWidget23);
        lstPageRegionWidget.add(objPageRegionWidget24);
        lstPageRegionWidget.add(objPageRegionWidget25);
        lstPageRegionWidget.add(objPageRegionWidget26);
        lstPageRegionWidget.add(objPageRegionWidget27);
        
        //Application widget
        PageRegionWidget__c objPageRegionWidget31 = new PageRegionWidget__c(Widget__c = objWidgetApp.Id, Page_Region__c = objPageRegion12.Id, Configuration__c = '{"initialstate":"PICKLIST"}', Order__c = 2);
        PageRegionWidget__c objPageRegionWidget32 = new PageRegionWidget__c(Widget__c = objWidgetApp.Id, Page_Region__c = objPageRegion22.Id, Configuration__c = '{"initialstate":"PICKLIST"}', Order__c = 2);
        PageRegionWidget__c objPageRegionWidget33 = new PageRegionWidget__c(Widget__c = objWidgetApp.Id, Page_Region__c = objPageRegion32.Id, Configuration__c = '{"initialstate":"PICKLIST"}', Order__c = 2);
        PageRegionWidget__c objPageRegionWidget34 = new PageRegionWidget__c(Widget__c = objWidgetApp.Id, Page_Region__c = objPageRegion42.Id, Configuration__c = '{"initialstate":"PICKLIST"}', Order__c = 2);
        PageRegionWidget__c objPageRegionWidget35 = new PageRegionWidget__c(Widget__c = objWidgetApp.Id, Page_Region__c = objPageRegion52.Id, Configuration__c = '{"initialstate":"PICKLIST"}', Order__c = 2);
        PageRegionWidget__c objPageRegionWidget36 = new PageRegionWidget__c(Widget__c = objWidgetApp.Id, Page_Region__c = objPageRegion62.Id, Configuration__c = '{"initialstate":"PICKLIST"}', Order__c = 2);
        PageRegionWidget__c objPageRegionWidget37 = new PageRegionWidget__c(Widget__c = objWidgetApp.Id, Page_Region__c = objPageRegion72.Id, Configuration__c = '{"initialstate":"PICKLIST"}', Order__c = 2);
     
        lstPageRegionWidget.add(objPageRegionWidget31);
        lstPageRegionWidget.add(objPageRegionWidget32);
        lstPageRegionWidget.add(objPageRegionWidget33);
        lstPageRegionWidget.add(objPageRegionWidget34);
        lstPageRegionWidget.add(objPageRegionWidget35);
        lstPageRegionWidget.add(objPageRegionWidget36);
        lstPageRegionWidget.add(objPageRegionWidget37);
     
        //Navigation widget
        PageRegionWidget__c objPageRegionWidget41 = new PageRegionWidget__c(Widget__c = objWidgetNavigation.Id, Page_Region__c = objPageRegion13.Id, Configuration__c = '{"backgroundColor":"","fontColor":"","selectedBackgroundColor":"","selectedFontColor":"","pageOrder":"Home,Documents,Company Calendar,Employee Directory"}');
        PageRegionWidget__c objPageRegionWidget42 = new PageRegionWidget__c(Widget__c = objWidgetNavigation.Id, Page_Region__c = objPageRegion23.Id, Configuration__c = '{"backgroundColor":"","fontColor":"","selectedBackgroundColor":"","selectedFontColor":"","pageOrder":"Home,Documents,Company Calendar,Employee Directory"}');
        PageRegionWidget__c objPageRegionWidget43 = new PageRegionWidget__c(Widget__c = objWidgetNavigation.Id, Page_Region__c = objPageRegion33.Id, Configuration__c = '{"backgroundColor":"","fontColor":"","selectedBackgroundColor":"","selectedFontColor":"","pageOrder":"Home,Documents,Company Calendar,Employee Directory"}');
        PageRegionWidget__c objPageRegionWidget44 = new PageRegionWidget__c(Widget__c = objWidgetNavigation.Id, Page_Region__c = objPageRegion43.Id, Configuration__c = '{"backgroundColor":"","fontColor":"","selectedBackgroundColor":"","selectedFontColor":"","pageOrder":"Home,Documents,Company Calendar,Employee Directory"}');
        PageRegionWidget__c objPageRegionWidget45 = new PageRegionWidget__c(Widget__c = objWidgetNavigation.Id, Page_Region__c = objPageRegion53.Id, Configuration__c = '{"backgroundColor":"","fontColor":"","selectedBackgroundColor":"","selectedFontColor":"","pageOrder":"Home,Documents,Company Calendar,Employee Directory"}');
        PageRegionWidget__c objPageRegionWidget46 = new PageRegionWidget__c(Widget__c = objWidgetNavigation.Id, Page_Region__c = objPageRegion63.Id, Configuration__c = '{"backgroundColor":"","fontColor":"","selectedBackgroundColor":"","selectedFontColor":"","pageOrder":"Home,Documents,Company Calendar,Employee Directory"}');
        PageRegionWidget__c objPageRegionWidget47 = new PageRegionWidget__c(Widget__c = objWidgetNavigation.Id, Page_Region__c = objPageRegion73.Id, Configuration__c = '{"backgroundColor":"","fontColor":"","selectedBackgroundColor":"","selectedFontColor":"","pageOrder":"Home,Documents,Company Calendar,Employee Directory"}');
        
        lstPageRegionWidget.add(objPageRegionWidget41);
        lstPageRegionWidget.add(objPageRegionWidget42);
        lstPageRegionWidget.add(objPageRegionWidget43);
        lstPageRegionWidget.add(objPageRegionWidget44);
        lstPageRegionWidget.add(objPageRegionWidget45);
        lstPageRegionWidget.add(objPageRegionWidget46);
        lstPageRegionWidget.add(objPageRegionWidget47);
        
        //Home page Desktop widgets
        PageRegionWidget__c objPageRegionWidget51 = new PageRegionWidget__c(Widget__c = objWidgetChatterGroup.Id, Page_Region__c = objPageRegion15.Id, Order__c = 1, Configuration__c = '');
        PageRegionWidget__c objPageRegionWidget52 = new PageRegionWidget__c(Widget__c = objWidgetOffices.Id, Page_Region__c = objPageRegion15.Id, Order__c = 2, Configuration__c = '{"heading":"","fieldset1":"","fieldset2":"","fontcolor":"","fontstyle":""}');
        PageRegionWidget__c objPageRegionWidget53 = new PageRegionWidget__c(Widget__c = objWidgetCustomChatter.Id, Page_Region__c = objPageRegion16.Id, Order__c = 2, Configuration__c = '');
        PageRegionWidget__c objPageRegionWidget54 = new PageRegionWidget__c(Widget__c = objWidgetNotifList.Id, Page_Region__c = objPageRegion17.Id, Order__c = 1, Configuration__c = '{"fieldset":"","heading":"Notifications","numbertodisplay":4,"TotalRecords":10}');
        PageRegionWidget__c objPageRegionWidget55 = new PageRegionWidget__c(Widget__c = objWidgetStaffUpdate.Id, Page_Region__c = objPageRegion17.Id, Order__c = 2, Configuration__c = '{"fieldset":"","showAboutMe":false,"numbertodisplay":4,"TotalRecords":10}');
        PageRegionWidget__c objPageRegionWidget56 = new PageRegionWidget__c(Widget__c = objWidgetNotifDetail.Id, Page_Region__c = objPageRegion16.Id, Order__c = 1, Configuration__c = '{"initialstate":"hidden","fieldset":"","showfeed":false,"heading":""}');
                
        lstPageRegionWidget.add(objPageRegionWidget51);
        lstPageRegionWidget.add(objPageRegionWidget52);
        lstPageRegionWidget.add(objPageRegionWidget53);
        lstPageRegionWidget.add(objPageRegionWidget54);
        lstPageRegionWidget.add(objPageRegionWidget55);
        lstPageRegionWidget.add(objPageRegionWidget56);
        
        //Home page Mobile widgets
/*mm*/  PageRegionWidget__c objPageRegionWidget57 = new PageRegionWidget__c(Widget__c = objWidgetSearch.Id, Page_Region__c = objPageRegion19.Id, Order__c = 1, Configuration__c = '');
        PageRegionWidget__c objPageRegionWidget58 = new PageRegionWidget__c(Widget__c = objWidgetNavigation.Id, Page_Region__c = objPageRegion19.Id, Order__c = 2, Configuration__c = '{"backgroundColor":"","fontColor":"","selectedBackgroundColor":"","selectedFontColor":"","pageOrder":"Company Calendar,Documents,Employee Directory,Notifications,Offices"}');
                
        lstPageRegionWidget.add(objPageRegionWidget57);
        lstPageRegionWidget.add(objPageRegionWidget58);
/*mm*/     
        //Document page Desktop widgets
        PageRegionWidget__c objPageRegionWidget61 = new PageRegionWidget__c(Widget__c = objWidgetDocType.Id, Page_Region__c = objPageRegion25.Id, Configuration__c = '', Order__c = 1);
        PageRegionWidget__c objPageRegionWidget62 = new PageRegionWidget__c(Widget__c = objWidgetDocument.Id, Page_Region__c = objPageRegion26.Id, Configuration__c = '{"showfeed":false,"showFieldLabel":false,"fieldset":"","displayFilterLinks":true}', Order__c = 1);
        
        lstPageRegionWidget.add(objPageRegionWidget61);
        lstPageRegionWidget.add(objPageRegionWidget62);
        
        //Document page Mobile widgets
/*mm*/  PageRegionWidget__c objPageRegionWidget63 = new PageRegionWidget__c(Widget__c = objWidgetSearch.Id, Page_Region__c = objPageRegion29.Id, Configuration__c = '', Order__c = 1);
        PageRegionWidget__c objPageRegionWidget64 = new PageRegionWidget__c(Widget__c = objWidgetDocType.Id, Page_Region__c = objPageRegion29.Id, Configuration__c = '', Order__c = 2);
        PageRegionWidget__c objPageRegionWidget65 = new PageRegionWidget__c(Widget__c = objWidgetDocument.Id, Page_Region__c = objPageRegion29.Id, Configuration__c = '{"showfeed":false,"showFieldLabel":false,"fieldset":"","displayFilterLinks":true}', Order__c = 3);
        
        lstPageRegionWidget.add(objPageRegionWidget63);
        lstPageRegionWidget.add(objPageRegionWidget64);
        lstPageRegionWidget.add(objPageRegionWidget65);
/*mm*/        
        //Calendar page Desktop widgets
        PageRegionWidget__c objPageRegionWidget71 = new PageRegionWidget__c(Widget__c = objWidgetEventType.Id, Page_Region__c = objPageRegion35.Id, Configuration__c = '', Order__c = 1);
        PageRegionWidget__c objPageRegionWidget72 = new PageRegionWidget__c(Widget__c = objWidgetEventDetail.Id, Page_Region__c = objPageRegion36.Id, Configuration__c = '{"fieldset":"","fontcolor":"","fontstyle":""}', Order__c = 1);
     
        lstPageRegionWidget.add(objPageRegionWidget71);
        lstPageRegionWidget.add(objPageRegionWidget72);
        
        //Calendar page Mobile widgets
/*mm*/  PageRegionWidget__c objPageRegionWidget73 = new PageRegionWidget__c(Widget__c = objWidgetSearch.Id, Page_Region__c = objPageRegion39.Id, Configuration__c = '', Order__c = 1);
        PageRegionWidget__c objPageRegionWidget74 = new PageRegionWidget__c(Widget__c = objWidgetEventType.Id, Page_Region__c = objPageRegion39.Id, Configuration__c = '', Order__c = 2);
        PageRegionWidget__c objPageRegionWidget75 = new PageRegionWidget__c(Widget__c = objWidgetEventDetail.Id, Page_Region__c = objPageRegion39.Id, Configuration__c = '{"fieldset":"","fontcolor":"","fontstyle":""}', Order__c = 3);
     
        lstPageRegionWidget.add(objPageRegionWidget73);
        lstPageRegionWidget.add(objPageRegionWidget74);
        lstPageRegionWidget.add(objPageRegionWidget75);
/*mm*/        
        //Employee Directory page Desktop widgets
        PageRegionWidget__c objPageRegionWidget81 = new PageRegionWidget__c(Widget__c = objWidgetEmpDirOffice.Id, Page_Region__c = objPageRegion45.Id, Configuration__c = '{"Listviews":""}', Order__c = 1);
        PageRegionWidget__c objPageRegionWidget82 = new PageRegionWidget__c(Widget__c = objWidgetEmpDirList.Id, Page_Region__c = objPageRegion46.Id, Configuration__c = '{"sortfieldset":""}', Order__c = 1);
        
        lstPageRegionWidget.add(objPageRegionWidget81);
        lstPageRegionWidget.add(objPageRegionWidget82);
        
        //Employee Directory page Mobile widgets
/*mm*/  PageRegionWidget__c objPageRegionWidget83 = new PageRegionWidget__c(Widget__c = objWidgetSearch.Id, Page_Region__c = objPageRegion49.Id, Configuration__c = '', Order__c = 1);
        PageRegionWidget__c objPageRegionWidget84 = new PageRegionWidget__c(Widget__c = objWidgetEmpDirOffice.Id, Page_Region__c = objPageRegion49.Id, Configuration__c = '{"Listviews":""}', Order__c = 2);
        PageRegionWidget__c objPageRegionWidget85 = new PageRegionWidget__c(Widget__c = objWidgetEmpDirList.Id, Page_Region__c = objPageRegion49.Id, Configuration__c = '{"sortfieldset":""}', Order__c = 3);
        
        lstPageRegionWidget.add(objPageRegionWidget83);
        lstPageRegionWidget.add(objPageRegionWidget84);
        lstPageRegionWidget.add(objPageRegionWidget85);
/*mm*/        
        //Employee Profile page Desktop widgets
        PageRegionWidget__c objPageRegionWidget91 = new PageRegionWidget__c(Widget__c = objWidgetEmpDirDetail.Id, Page_Region__c = objPageRegion75.Id, Configuration__c = '{"fieldset":"","popupfieldset":"","showdefaultfields":true,"showheader":true}', Order__c = 1);
        PageRegionWidget__c objPageRegionWidget92 = new PageRegionWidget__c(Widget__c = objWidgetCustomChatter.Id, Page_Region__c = objPageRegion76.Id, Configuration__c = '', Order__c = 1);
        PageRegionWidget__c objPageRegionWidget93 = new PageRegionWidget__c(Widget__c = objWidgetEmpDirReport.Id, Page_Region__c = objPageRegion77.Id, Configuration__c = '{"numbertodisplay":5,"totalrecords":10}', Order__c = 1);
        
        lstPageRegionWidget.add(objPageRegionWidget91);
        lstPageRegionWidget.add(objPageRegionWidget92);
        lstPageRegionWidget.add(objPageRegionWidget93);
        
        //Employee Profile page Mobile widgets
/*mm*/  PageRegionWidget__c objPageRegionWidget94 = new PageRegionWidget__c(Widget__c = objWidgetSearch.Id, Page_Region__c = objPageRegion79.Id, Configuration__c = '', Order__c = 1);
        PageRegionWidget__c objPageRegionWidget95 = new PageRegionWidget__c(Widget__c = objWidgetEmpDirDetail.Id, Page_Region__c = objPageRegion79.Id, Configuration__c = '{"fieldset":"","popupfieldset":"","showdefaultfields":true,"showheader":true}', Order__c = 2);
        PageRegionWidget__c objPageRegionWidget96 = new PageRegionWidget__c(Widget__c = objWidgetEmpDirReport.Id, Page_Region__c = objPageRegion79.Id, Configuration__c = '{"numbertodisplay":5,"totalrecords":10}', Order__c = 3);
        
        lstPageRegionWidget.add(objPageRegionWidget94);
        lstPageRegionWidget.add(objPageRegionWidget95);
        lstPageRegionWidget.add(objPageRegionWidget96);
/*mm*/     
        //Manage page widgets
        PageRegionWidget__c objPageRegionWidget101 = new PageRegionWidget__c(Widget__c = objWidgetManageGroup.Id, Page_Region__c = objPageRegion56.Id, Configuration__c = '', Order__c = 1);
        
        lstPageRegionWidget.add(objPageRegionWidget101);
        
        //Search page Desktop widgets
        PageRegionWidget__c objPageRegionWidget111 = new PageRegionWidget__c(Widget__c = objWidgetSearchType.Id, Page_Region__c = objPageRegion65.Id, Configuration__c = '{"categories": "User:Employee Directory:'+strNameSpace+'SL_EmployeeDirectoryFieldSet:,Notification__c:Notifications::,ContentVersion:Secure Documents::,Intranet_Event__c:Calendar Entries::,FeedItem:Posts::"}', Order__c = 1);
        PageRegionWidget__c objPageRegionWidget112 = new PageRegionWidget__c(Widget__c = objWidgetSearchResult.Id, Page_Region__c = objPageRegion66.Id, Configuration__c = '', Order__c = 1);
        
        lstPageRegionWidget.add(objPageRegionWidget111);
        lstPageRegionWidget.add(objPageRegionWidget112);
        
        //Search page Mobile widgets
/*mm*/  PageRegionWidget__c objPageRegionWidget113 = new PageRegionWidget__c(Widget__c = objWidgetSearch.Id, Page_Region__c = objPageRegion69.Id, Configuration__c = '', Order__c = 1);
        PageRegionWidget__c objPageRegionWidget114 = new PageRegionWidget__c(Widget__c = objWidgetSearchResult.Id, Page_Region__c = objPageRegion69.Id, Configuration__c = '', Order__c = 2);
        
        lstPageRegionWidget.add(objPageRegionWidget113);
        lstPageRegionWidget.add(objPageRegionWidget114);
/*mm*/        
        //Office page Mobile widgets
/*mm*/  PageRegionWidget__c objPageRegionWidget121 = new PageRegionWidget__c(Widget__c = objWidgetOffices.Id, Page_Region__c = objPageRegion89.Id, Configuration__c = '{"heading":"","fieldset1":"","fieldset2":"","fontcolor":"","fontstyle":""}', Order__c = 1);
        PageRegionWidget__c objPageRegionWidget122 = new PageRegionWidget__c(Widget__c = objWidgetUserInfo.Id, Page_Region__c = objPageRegion81.Id, Configuration__c = '');
        
        lstPageRegionWidget.add(objPageRegionWidget121);
        lstPageRegionWidget.add(objPageRegionWidget122);
/*mm*/        
        //Notifications page Mobile widgets
/*mm*/  PageRegionWidget__c objPageRegionWidget131 = new PageRegionWidget__c(Widget__c = objWidgetNotifList.Id, Page_Region__c = objPageRegion99.Id, Configuration__c = '{"fieldset":"","heading":"Notifications","numbertodisplay":4,"TotalRecords":10}', Order__c = 1);
        PageRegionWidget__c objPageRegionWidget132 = new PageRegionWidget__c(Widget__c = objWidgetUserInfo.Id, Page_Region__c = objPageRegion91.Id, Configuration__c = '');
        
        lstPageRegionWidget.add(objPageRegionWidget131);
        lstPageRegionWidget.add(objPageRegionWidget132);
/*mm*/        
        Database.insert(lstPageRegionWidget, false);
        /** End : Creating Default Page Region Widgets records for each pages **/
     }
	 /* END Method--createIntranetRecords-- */
	 
	 
	 /* @Name           - createWidgetRecord
	   @Parameters     - None 
	   @Return Type    - List<Widget__c>
	   @Description    - To prepare widget Records
	*/
     public List<Widget__c> createWidgetRecord()
     {
     	List<Widget__c> lstWidget = new List<Widget__c>();
     	
     	// Apps & Links
		Widget__c objWidgetApp = new Widget__c(Name = 'Apps & Links', Type__c = 'SL_IntranetApplications', 
                                             Configuration__c = '{"initialstate":"picklist"}', 
                                             Regions__c = 'HeaderLogoSection;LeftSideBar;MainSection;RightSideBar;LeftMainSection;RightMainSection;LeftHalfSection;RightHalfSection');
    	lstWidget.add(objWidgetApp);
        // Banner
        Widget__c objWidgetBanner = new Widget__c(Name = 'Banner', Type__c = 'SL_IntranetBanner', 
                                             Configuration__c = '{"targetfolder":"","backgroundcolor":"white","fontcolor":"","transitiontype":"fade","widgetheight":250,"trasnitionseconds":10,"heading":"","fontstyle":"","showborder":true,"department":""}', 
                                             Regions__c = 'LeftSideBar;MainSection;RightSideBar;BannerRegion;LeftMainSection;RightMainSection;LeftHalfSection;RightHalfSection;MainFullSection');
        lstWidget.add(objWidgetBanner);
        // Chatter Custom Feed
        Widget__c objWidgetCustomChatter = new Widget__c(Name = 'Chatter Custom Feed', Type__c = 'SL_IntranetChatterFeeds', 
                                             Configuration__c = '', 
                                             Regions__c = 'MainSection;LeftHalfSection;RightHalfSection');
        lstWidget.add(objWidgetCustomChatter);
        // Chatter Groups
        Widget__c objWidgetChatterGroup = new Widget__c(Name = 'Chatter Groups', Type__c = 'SL_IntranetChatterGroups', 
                                             Configuration__c = '', 
                                             Regions__c = 'LeftSideBar');
        lstWidget.add(objWidgetChatterGroup);
        // Chatter Manage Groups
        Widget__c objWidgetManageGroup = new Widget__c(Name = 'Chatter Manage Groups', Type__c = 'SL_IntranetManageGroups', 
                                             Configuration__c = '', 
                                             Regions__c = 'LeftMainSection;RightMainSection');
        lstWidget.add(objWidgetManageGroup);
        // Chatter Standard Feed
        Widget__c objWidgetStandardChatter = new Widget__c(Name = 'Chatter Standard Feed', Type__c = 'SL_Intranet_StandardChatter', 
                                             Configuration__c = '', 
                                             Regions__c = 'MainSection;LeftMainSection;RightMainSection;LeftHalfSection;RightHalfSection');
        lstWidget.add(objWidgetStandardChatter);
        // Document Types
        Widget__c objWidgetDocType = new Widget__c(Name = 'Document Types', Type__c = 'SL_IntranetContentTypes', 
                                             Configuration__c = '', 
                                             Regions__c = 'LeftSideBar;RightSideBar;MobileMainSection');//;MobileMainSection
        lstWidget.add(objWidgetDocType);
        // Documents
        Widget__c objWidgetDocument = new Widget__c(Name = 'Documents', Type__c = 'SL_IntranetDocuments', 
                                             Configuration__c = '{"showfeed":false,"showFieldLabel":false,"fieldset":"","displayFilterLinks":true}', 
                                             Regions__c = 'MainSection;LeftHalfSection;RightHalfSection;MobileMainSection');//;MobileMainSection
        lstWidget.add(objWidgetDocument);
        // Embedded Content
        Widget__c objWidgetEmbedded = new Widget__c(Name = 'Embedded Content', Type__c = 'SL_IntranetEmbedded', 
                                              Configuration__c = '{"content": "You can enter text here or an embedded content URL","background":"","fontcolor":"","fontsize":"","fontfamily":"","fontstyle":"","heading":"","department":"","initialstate":"","buttontext":"Embedded Content","title":"","padding":"","fontweight":"","offices":""}', 
                                              Regions__c = 'LeftSideBar;MainSection;RightSideBar;LeftHalfSection;RightHalfSection;LeftMainSection;RightMainSection;MainFullSection');
        lstWidget.add(objWidgetEmbedded);
        // Employee Directory Detail
        Widget__c objWidgetEmpDirDetail = new Widget__c(Name = 'Employee Directory Detail', Type__c = 'SL_IntranetEmployeeProfile', 
                                              Configuration__c = '{"fieldset":"","popupfieldset":"","showdefaultfields":true,"showheader":true}', 
                                              Regions__c = 'LeftSideBar;MainSection;RightSideBar;MobileMainSection');//;MobileMainSection
        lstWidget.add(objWidgetEmpDirDetail);
        // Employee Directory List
        Widget__c objWidgetEmpDirList = new Widget__c(Name = 'Employee Directory List', Type__c = 'SL_IntranetEmployeeDirectory', 
                                              Configuration__c = '{"sortfieldset":""}', 
                                              Regions__c = 'LeftMainSection;RightMainSection;MobileMainSection');//;MobileMainSection
        lstWidget.add(objWidgetEmpDirList);
        // Employee Directory Offices
        Widget__c objWidgetEmpDirOffice = new Widget__c(Name = 'Employee Directory Offices', Type__c = 'SL_IntranetEmpDirectoryOffices', 
                                              Configuration__c = '{"Listviews":""}', 
                                              Regions__c = 'LeftSideBar;RightSideBar;MobileMainSection');//;MobileMainSection
        lstWidget.add(objWidgetEmpDirOffice);
        // Employee Directory Reporting Structure
        Widget__c objWidgetEmpDirReport = new Widget__c(Name = 'Employee Directory Reporting Structure', Type__c = 'SL_IntranetReportingStructure', 
                                              Configuration__c = '{"numbertodisplay":5,"totalrecords":10}', 
                                              Regions__c = 'LeftSideBar;RightSideBar;MobileMainSection');//;MobileMainSection
        lstWidget.add(objWidgetEmpDirReport);
        // Intranet Events Detail
        Widget__c objWidgetEventDetail = new Widget__c(Name = 'Intranet Events Detail', Type__c = 'SL_IntranetEvents', 
                                              Configuration__c = '{"fieldset":"","fontcolor":"","fontstyle":""}', 
                                              Regions__c = 'MainSection;LeftHalfSection;RightHalfSection;MobileMainSection');//;MobileMainSection
        lstWidget.add(objWidgetEventDetail);
        // Intranet Events Types
        Widget__c objWidgetEventType = new Widget__c(Name = 'Intranet Events Types', Type__c = 'SL_IntranetEventTypes', 
                                              Configuration__c = '', 
                                              Regions__c = 'LeftSideBar;RightSideBar;MobileMainSection');//;MobileMainSection
        lstWidget.add(objWidgetEventType);
        // Navigation
        Widget__c objWidgetNavigation = new Widget__c(Name = 'Navigation', Type__c = 'SL_IntranetNavigationBar', 
                                              Configuration__c = '{"backgroundColor":"","fontColor":"","selectedBackgroundColor":"","selectedFontColor":"","pageOrder":"Home,Documents,Company Calendar,Employee Directory"}', 
                                              Regions__c = 'HeaderNavigationSection;MobileMainSection');//;MobileMainSection
        lstWidget.add(objWidgetNavigation);
        // Notification Details
        Widget__c objWidgetNotifDetail = new Widget__c(Name = 'Notification Details', Type__c = 'SL_IntranetNotificationDetails', 
                                              Configuration__c = '{"initialstate":"hidden","fieldset":"","showfeed":false,"heading":""}', 
                                              Regions__c = 'MainSection;LeftHalfSection;RightHalfSection');
        lstWidget.add(objWidgetNotifDetail);
        // Notification List
        Widget__c objWidgetNotifList = new Widget__c(Name = 'Notification List', Type__c = 'SL_IntranetNotifications', 
                                              Configuration__c = '{"fieldset":"","heading":"","numbertodisplay":4,"TotalRecords":10}', 
                                              Regions__c = 'LeftSideBar;RightSideBar;MobileMainSection');//;MobileMainSection
        lstWidget.add(objWidgetNotifList);
        // Offices
        Widget__c objWidgetOffices = new Widget__c(Name = 'Offices', Type__c = 'SL_IntranetOffices', 
                                              Configuration__c = '{"heading":"","fieldset1":"","fieldset2":"","fontcolor":"","fontstyle":""}', 
                                              Regions__c = 'LeftSideBar;LeftHalfSection;MobileMainSection');//;MobileMainSection
        lstWidget.add(objWidgetOffices);
        // Quick Create
        Widget__c objWidgetQuickCreate = new Widget__c(Name = 'Quick Create', Type__c = 'SL_IntranetQuickCreate', 
                                              Configuration__c = '{"heading":"Quick Create","initialbutton":"Create a Case","instructiontext":"Customizable Instruction Text goes here. Uses Field Sets to determine what to include here","sobjectname":"Case","fieldsetname":"","successresponse":"Customizable Success Response Text goes here. Use this process to trigger workflow.","department":"","savebutton":"Create Case","logtransaction":false,"backgroundcolor":"","fontstyle":""}', 
                                              Regions__c = 'LeftSideBar;RightSideBar;MainSection;LeftHalfSection;RightHalfSection');
        lstWidget.add(objWidgetQuickCreate);
        // Search
        Widget__c objWidgetSearch = new Widget__c(Name = 'Search', Type__c = 'SL_IntranetSearch', 
                                              Configuration__c = '', 
                                              Regions__c = 'HeaderLogoSection;MobileMainSection');//;MobileMainSection
        lstWidget.add(objWidgetSearch);
        // Search Results List
        Widget__c objWidgetSearchResult = new Widget__c(Name = 'Search Results List', Type__c = 'SL_IntranetSearchResults', 
                                              Configuration__c = '', 
                                              Regions__c = 'MainSection;LeftHalfSection;RightHalfSection;MobileMainSection');//;MobileMainSection
        lstWidget.add(objWidgetSearchResult);
        // Search Results Types
        Widget__c objWidgetSearchType = new Widget__c(Name = 'Search Results Types', Type__c = 'SL_IntranetSearchTypes', 
                                              Configuration__c = '{"categories": "User:Employee Directory:'+strNameSpace+'SL_EmployeeDirectoryFieldSet:,Notification__c:Notifications::,ContentVersion:Secure Documents::,Intranet_Event__c:Calendar Entries::,FeedItem:Posts::"}', 
                                              Regions__c = 'LeftSideBar;RightSideBar');//;MobileMainSection
        lstWidget.add(objWidgetSearchType);
        // Staff Updates
        Widget__c objWidgetStaffUpdate = new Widget__c(Name = 'Staff Updates', Type__c = 'SL_IntranetStaffUpdates', 
                                              Configuration__c = '{"fieldset":"","showAboutMe":false,"numbertodisplay":4,"TotalRecords":10}', 
                                              Regions__c = 'LeftSideBar;RightSideBar');
        lstWidget.add(objWidgetStaffUpdate);
        // User Info
        Widget__c objWidgetUserInfo = new Widget__c(Name = 'User Info', Type__c = 'SL_IntranetUserInfo', 
                                              Configuration__c = '', 
                                              Regions__c = 'HeaderUserInfo');
        lstWidget.add(objWidgetUserInfo);
        // SObject List
        Widget__c objWidgetSobjectList = new Widget__c(Name = 'Object List', Type__c = 'SL_IntranetSobject', 
                                              Configuration__c = '{"sobjectname":"","fieldsetname":"","heading":"Object List View","showfieldlabel":true,"filtercriteria":"","numbertodisplay":4,"TotalRecords":10,"disableLinks":false}',
                                              Regions__c = 'MainSection;LeftSideBar;RightSideBar');
        lstWidget.add(objWidgetSobjectList);
        // SObject Detail
        Widget__c objWidgetSobjectDetail = new Widget__c(Name = 'Object Detail', Type__c = 'SL_IntranetSobjectDetail', 
                                              Configuration__c = '{"sobjectname":"","fieldsetname":"","showfeed":false,"heading":"","initialstate":"hidden","showattachment":true,"showfieldlabel":true,"filtercriteria":""}',
                                              Regions__c = 'MainSection;LeftHalfSection;RightHalfSection');
     	lstWidget.add(objWidgetSobjectDetail);
         // Office Detail
        Widget__c objWidgetOfficeDetail = new Widget__c(Name = 'Office Detail', Type__c = 'SL_IntranetOfficeDetails', 
                                              Configuration__c = '{"backgroundColor":"","fontColor":"","headingBackground":"","initialState":"","headingColor":"","fieldSet":""}', 
                                              Regions__c = 'MainSection;RightMainSection;RightHalfSection');
        lstWidget.add(objWidgetOfficeDetail);
        // Department filter
        Widget__c objWidgetDepartment = new Widget__c(Name = 'Departments', Type__c = 'SL_IntranetDepartments', 
                                             Configuration__c = '{"initialstate":"","initialselection":""}', 
                                             Regions__c = 'HeaderLogoSection;MainSection;LeftSideBar;RightSideBar');
        lstWidget.add(objWidgetDepartment);
        // Event Summary
        Widget__c objWidgetEventSummary = new Widget__c(Name = 'Event Summary', Type__c = 'SL_IntranetEventSummary', 
                                             Configuration__c = '{"fieldset":"","heading":" ","numbertodisplay":4,"TotalRecords":10}',
                                             Regions__c = 'LeftSideBar;RightSideBar;LeftHalfSection;RightHalfSection');
        lstWidget.add(objWidgetEventSummary);
        // Event Summary Detail
        Widget__c objWidgetEventSummaryDetail = new Widget__c(Name = 'Event Summary Detail', Type__c = 'SL_IntranetEventSummaryDetails', 
                                             Configuration__c = '{"fieldSet":"","showFeed":false}', 
                                             Regions__c = 'MainSection;LeftMainSection;RightMainSection;LeftHalfSection;RightHalfSection');                                     
        lstWidget.add(objWidgetEventSummaryDetail);
        // Key Contact
        Widget__c objWidgetKeyContact = new Widget__c(Name = 'Key Contacts', Type__c = 'SL_IntranetKeyContacts', 
                                             Configuration__c = '{"fieldset":"","showAboutMe":false}', 
                                             Regions__c = 'LeftSideBar;RightSideBar;LeftHalfSection;RightHalfSection');                                     
        lstWidget.add(objWidgetKeyContact);
        // Recent Updates
        Widget__c objWidgetRecentUpdate = new Widget__c(Name = 'Recent Updates', Type__c = 'SL_IntranetRecentUpdates', 
                                             Configuration__c = '{"heading":"","Objects":"","numbertodisplay":5,"TotalRecords":10}',
                                             Regions__c = 'LeftSideBar;RightSideBar;LeftHalfSection;RightHalfSection');  
        lstWidget.add(objWidgetRecentUpdate);
        // List Views
        Widget__c objWidgetListView = new Widget__c(Name = 'ListViews', Type__c = 'SL_IntranetListViews', 
                                             Configuration__c = '{"sobjectname":"","heading":"","Listviews":""}', 
                                             Regions__c = 'LeftSideBar; RightSideBar');                                    
   		lstWidget.add(objWidgetListView);
   		
   		//RecentDocument 
   		Widget__c objWidgetRecentDocument = new Widget__c(Name = 'Recent Document', Type__c = 'SL_IntranetRecentDocuments', 
                                             Configuration__c = '{"heading":"","numbertodisplay":5,"TotalRecords":10}', 
                                             Regions__c = 'LeftSideBar; RightSideBar');                                    
   		lstWidget.add(objWidgetRecentDocument);
        
		return lstWidget;
	}
	/*END :createWidgetRecord*/
	
	/* @Name           - updateExistingWidgetConfiguration
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Method To update existing widget configuration on time of upgrade install
	*/
	global void updateExistingWidgetConfiguration()
	{
		//Getting All the widget config as per newly made updates in configuration. 
		for(Widget__c objWNew : createWidgetRecord()) 
		{
		   if(String.isNotBlank(objWNew.configuration__c))
			   mapWidgetConfigUpgrade.put(objWNew.Name,(Map<String, Object>)JSON.deserializeUntyped(objWNew.configuration__c));
			else
			   mapWidgetConfigUpgrade.put(objWNew.Name,new Map<String, Object>()); 
		}

		//Querying all widget record from the target org to fetch the existing widgte and config options
		for(Widget__c objW : [SELECT Name, Configuration__c FROM Widget__c])
		{
			
			Map<String, Object> mapWidConfig = (mapWidgetConfigUpgrade.get(objW.Name) !=null && String.isNotBlank(objW.Configuration__c))? 
												(Map<String, Object>)JSON.deserializeUntyped(objW.Configuration__c):
												new Map<String, Object>();
			
			updateConfigs(objW, mapWidConfig) ;
		}

		update lstWidgetsNeedToBeUpdated; //updating widget record with new configuration options
		
		
		//Code to Update PageRegionWidget configuration after updating widget configuartion
		List<PageRegionWidget__c> lstPRWConfigUpdate = new List<PageRegionWidget__c>();
		
		for(PageRegionWidget__c objPRW : [Select Widget__r.Name, Configuration__c From PageRegionWidget__c where Widget__c IN : lstWidgetsNeedToBeUpdated])
		{
			
			Map<String, Object> mapPRWConfig = (String.isNotBlank(objPRW.Configuration__c))? 
											   (Map<String, Object>)JSON.deserializeUntyped(objPRW.Configuration__c):
											   new Map<String, Object>();
			
			
			objPRW.Configuration__c = updateConfigs(objPRW, mapPRWConfig);
					
			lstPRWConfigUpdate.add(objPRW);
		}

		update lstPRWConfigUpdate; //updating PageRegionWidgetRecord to work with updated configuration
	}
	/*END: updateExistingWidgetConfiguration*/
	
	
	/* @Name           - updateConfigs
	   @Parameters     - Widget, Map<String,Object>
	   @Return Type    - void
	   @Description    - To update widget record configuration based on existing and new widget Records configuration
	*/
	global void updateConfigs(Widget__c ObjWidget, Map<String,Object> mapWidConfig)
	{
		Set<String> setConfigsNeedToBeRemoved = new Set<String>();
		setConfigsNeedToBeRemoved.addAll(mapWidConfig.keySet());
		
		Set<String> setNewField = new Set<String>();
		setNewField.addAll(mapWidgetConfigUpgrade.get(ObjWidget.Name).keySet());
		
		setConfigsNeedToBeRemoved.removeAll(setNewField); //getting deleted configuration fields
		
		setNewField.removeAll(mapWidConfig.keySet()); //getting new configuration fields
		
	  	if(!setNewField.isEmpty() || !setConfigsNeedToBeRemoved.isEmpty())
	  	{
			for(String config :setConfigsNeedToBeRemoved){
	  			mapWidConfig.remove(config);
	  		}
	  		
			for(String str: setNewField){
				mapWidConfig.put(str, mapWidgetConfigUpgrade.get(ObjWidget.Name).get(str));  
			}
			
			ObjWidget.Configuration__c = (!mapWidConfig.isEmpty()) ? JSON.serialize(mapWidConfig) : '';
			
			lstWidgetsNeedToBeUpdated.add(ObjWidget);	
	  	}
	}
	/*END: updateConfigs */
	
	
	
	/* @Name           - createWidgetRecord
	   @Parameters     - PageRegionWidget__c, Map<String,Object>
	   @Return Type    - String
	   @Description    - Method to find new changes in PageRegionWidget configuration 
	*/
 	global String updateConfigs(PageRegionWidget__c ObjPRW, Map<String,Object> mapPRWConfig)
	{
		Set<String> setConfigsNeedToBeRemoved = new Set<String>();
		setConfigsNeedToBeRemoved.addAll(mapPRWConfig.keySet());
		
		Set<String> setNewField = new Set<String>();
		setNewField.addAll(mapWidgetConfigUpgrade.get(ObjPRW.Widget__r.Name).keySet());
		
		setConfigsNeedToBeRemoved.removeAll(setNewField); //getting deleted configuration field

		setNewField.removeAll(mapPRWConfig.keySet()); //getting new configuration fields
	  	if(!setNewField.isEmpty() || !setConfigsNeedToBeRemoved.isEmpty()){
	  		
	  		for(String config :setConfigsNeedToBeRemoved){
	  			mapPRWConfig.remove(config);
	  		}
	  		
			for(String str: setNewField)
				mapPRWConfig.put(str, mapWidgetConfigUpgrade.get(ObjPRW.Widget__r.Name).get(str));  
	  	}
		return (!mapPRWConfig.isEmpty()) ? JSON.serialize(mapPRWConfig) : '';
	}
	/*END: updateConfigs */
}