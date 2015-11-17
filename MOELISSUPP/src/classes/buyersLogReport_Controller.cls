/*
modified: Vika 05/14/2010 - Task #10350
*/
public class buyersLogReport_Controller {
 //Can be deleted
	//these variables keeps data from DB
	public List<Potential_Buyer_Investor__c> 			targetBuyersListFromDB 				= new List<Potential_Buyer_Investor__c>();
	public List<Potential_Buyer_Investor_Contact__c> 	targetBuyerContactsListFromDB 		= new List<Potential_Buyer_Investor_Contact__c>();
	public List<Potential_Buyer_Investor_Deal_Team__c> 	targetBuyersResourceListFromDB 		= new List<Potential_Buyer_Investor_Deal_Team__c>();
	public List<Potential_Buyer_Investor__c> 			activitiesInTargetBuyersListFromDB	= new List<Potential_Buyer_Investor__c>();
	public boolean isTest = false;

	public buyersLogReport_Controller () {
		if (getDealIdStr() == null) this.lProjectList = '';
		else this.lProjectList = [select Name from Ibanking_Project__c where Id = :getDealIdStr()].Name;
	}
	
	public String lProjectList {get; set;} 	

	public List<SelectOption> getProjectListItems() {
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('...select...','...select...'));
		integer iLimit = isTest?1:100;
		List<Ibanking_Project__c> projectList = [select id, name from Ibanking_Project__c order by CreatedDate desc limit :iLimit];
		for(Ibanking_Project__c item: projectList) {
			options.add(new SelectOption(item.Name, item.Name));
		}
		return options;
	}
	
	
	public String getDealIdStr() {
		String result = System.currentPageReference().getParameters().get('dealId');
		system.debug('===> getDealIdStr()=' + result); 
		return result;
	}
	
	public String getDealName() {
		//if (getDealIdStr() == null) return '';
		String result = this.lProjectList;
		system.debug('===> getDealName()=' + result); 
		return result;
	}
	
	public Pagereference toPDF() { 
		return new Pagereference('/apex/BuyersLogReport_PDF?dealId=' + getDealIdStr());
	}
	
	
	// the main method prepares data for the page
	public List<BuyersLogClass> getTargetBuyersList() {
		List<BuyersLogClass> resultList = new List<BuyersLogClass>();

		targetBuyersListFromDB = [select tb.Project__r.Id, tb.Id, tb.TargetBuyer__r.Name, tb.Type__c, tb.Initial_Contact_Made__c, tb.Teaser_Sent__c, tb.CA_Sent__c, tb.CIM_Info_Package_Sent__c, tb.CIM_Number__c, tb.X1st_Round_Bid_Process_Letter_Sent__c, tb.X3rd_Round_Bid_Process_Letter_Sent__c, tb.Declined__c from Potential_Buyer_Investor__c tb where tb.Project__r.Name = :this.lProjectList]; //Database.query(query);
		
		system.debug('targetBuyersListFromDB.size======' + targetBuyersListFromDB.size());
		
		//getting array of Ids
		List<ID> targetBuyerIdList = new List<ID>();
		for(Potential_Buyer_Investor__c item: targetBuyersListFromDB) targetBuyerIdList.add(item.Id);
		
		//fetching data from DB
		this.targetBuyersResourceListFromDB	    = [select tbr.Target_Buyer__r.ID, tbr.Banker__c, tbr.Banker__r.First_Name__c, tbr.Banker__r.Last_Name__c, tbr.Banker__r.Office_Location__c,	tbr.Banker__r.Phone__c, tbr.Role__c from Potential_Buyer_Investor_Deal_Team__c tbr where tbr.Target_Buyer__r.ID in :targetBuyerIdList];
		this.targetBuyerContactsListFromDB      = [select tbc.Target_Buyer__r.ID, tbc.Contact__r.ID, tbc.Contact__r.FirstName, tbc.Contact__r.LastName, tbc.Contact__r.Title, tbc.Contact__r.Phone, tbc.Contact__r.MobilePhone, tbc.Contact__r.Fax, tbc.Contact__r.Email, tbc.Contact__r.MailingState,					tbc.Contact__r.MailingPostalCode, tbc.Contact__r.MailingCountry, tbc.Contact__r.MailingCity, tbc.Contact__r.MailingStreet from Potential_Buyer_Investor_Contact__c tbc where tbc.Target_Buyer__r.ID in :targetBuyerIdList];
		this.activitiesInTargetBuyersListFromDB = [select Id, (select ActivityDate, ActivityType, LastModifiedDate, Subject, Description from ActivityHistories) from Potential_Buyer_Investor__c where Id in :targetBuyerIdList];//.ActivityHistories;


		
		for(Potential_Buyer_Investor__c item: targetBuyersListFromDB) {
			BuyersLogClass blc = new BuyersLogClass();
			blc.targetName = item.TargetBuyer__r.Name;
			blc.targetType = item.Type__c;
			
			ID targetBuyerId = item.Id;
			blc.targetProfessionals	= getTargetedProfessionals(targetBuyerId); //new List<TargetedProfessionalsClass>();
			blc.responsibleUsers	= getResponsibleUsers(targetBuyerId); //new List<ResponsibleUsersClass>();
			blc.acivityLogs			= getActivitiesList(targetBuyerId); //new List<ActivitiesClass>(); 

			// milestones 
				blc.ContactMade = dateToStr('Initial&nbsp;Contact&nbsp;Made:&nbsp;', item.Initial_Contact_Made__c);
				blc.TeaserSent  = dateToStr('Teaser&nbsp;Sent:&nbsp;', item.Teaser_Sent__c);
				blc.CASent      = dateToStr('CA&nbsp;Sent:&nbsp;', item.CA_Sent__c);
				//blc.CAStatus    = item.CA_Status__c;
				if (blc.CAStatus != null) { blc.CAStatus = 'CA&nbsp;Status:&nbsp;' + blc.CAStatus + '<br/>'; }

				blc.CIMSent     = dateToStr('CIM&nbsp;Status:&nbsp;', item.CIM_Info_Package_Sent__c);
				blc.CIMNumber   = item.CIM_Number__c;
				if (blc.CIMNumber != null) { blc.CIMNumber = 'CIM&nbsp;Number:&nbsp;' + blc.CIMNumber + '<br/>'; }
				
				blc.InitialBid  = dateToStr('Initial&nbsp;Bid&nbsp;Submitted:&nbsp;', item.X1st_Round_Bid_Process_Letter_Sent__c);
				blc.FinalBid    = dateToStr('Final&nbsp;Bid:&nbsp;', item.X3rd_Round_Bid_Process_Letter_Sent__c);
				blc.Declined    = dateToStr('Declined?:&nbsp;', item.Declined__c);
			

			resultList.add(blc);
		}
		return resultList;
	}
	
	
	// getActivitiesList(id) method is used by the getTargetBuyersList method
	private List<ActivitiesClass> getActivitiesList(ID targetBuyerId) {
		List<ActivitiesClass> resultList = new List<ActivitiesClass>();
		List<ActivityHistory> activityList = new List<ActivityHistory>(); 
		for (Potential_Buyer_Investor__c item: activitiesInTargetBuyersListFromDB) {
			if (item.Id == targetBuyerId) 
				activityList = item.ActivityHistories; 
		}
		for(ActivityHistory item: activityList) {
			ActivitiesClass ac = new ActivitiesClass();
			ac.actDateTime    = dateTimeToStr('Date/Time: ', item.LastModifiedDate);
			ac.actType        = 'Type: ' + item.ActivityType + '<br/>'; 
			ac.actSubject     = 'Subject: ' + item.Subject + '<br/>';
			ac.actNotes       = 'Notes: ' + ((item.Description==null)?'':item.Description) + '<br/>';
			resultList.add(ac);
		}
		return resultList;
	}
	
	
	
	// the prepareDate method is using by the getTargetBuyersList method for milestones
	private String dateToStr(String str, Date param) {
		if (param == null) {
			return null; 
		} else {
			return str + param.month() + '/' + param.day() + '/' + param.year() + '<br/>';
		} 
	}

	// the prepareDate method is using by the getTargetBuyersList method for milestones
	private String dateTimeToStr(String str, Datetime param) {
		if (param == null) {
			return null; 
		} else {
			return str + param.format('M/d/yyyy h:mm a') + '<br/>'; //month() + '/' + param.day() + '/' + param.year() + ' ' + param.'<br/>';
		} 
	}
	
	

	// getResponsibleUsers(id) method is used by the getTargetBuyersList method
	// “Responsible Users” = “Target Buyers Resource”.
	private List<ResponsibleUsersClass> getResponsibleUsers(ID targetBuyerId) {
		List<ResponsibleUsersClass> resUserList = new List<ResponsibleUsersClass>();

		List<Employee_Profile__c> employeeList = new List<Employee_Profile__c>();
		List<String> roleList = new List<String>();

		ID employeeProfileId;
		
		
		for(Potential_Buyer_Investor_Deal_Team__c item: targetBuyersResourceListFromDB) {
			if (item.Target_Buyer__r.ID == targetBuyerId) {
				ResponsibleUsersClass ruc = new ResponsibleUsersClass();
				
				ruc.role           = item.Role__c;
				ruc.fullName       = item.Banker__r.Last_Name__c + ', ' + item.Banker__r.First_Name__c;
				ruc.officeLocation = item.Banker__r.Office_Location__c;
				
				if (ruc.role != null)           { ruc.role           += '<br/>'; } 
				if (ruc.fullName != null)       { ruc.fullName       += '<br/>'; }
				if (ruc.officeLocation != null) { ruc.officeLocation += '<br/>'; }
				if (ruc.phone != null)          { ruc.phone          += '<br/>'; }
				
				resUserList.add(ruc);
			}
		}
		return resUserList;
	} // getResponsibleUsers(ID targetBuyerId)
	
 
	// getTargetedProfessionals(id) method is used by the getTargetBuyersList method
	private List<TargetedProfessionalsClass> getTargetedProfessionals(ID targetBuyerId) {
		List<Potential_Buyer_Investor_Contact__c> contactList = new List<Potential_Buyer_Investor_Contact__c>();
		ID contactId; 

		List<TargetedProfessionalsClass> tarProfList = new List<TargetedProfessionalsClass>();

		for(Potential_Buyer_Investor_Contact__c item: targetBuyerContactsListFromDB) {
			if (item.Target_Buyer__r.ID == targetBuyerId) {
				TargetedProfessionalsClass tpc = new TargetedProfessionalsClass();
				tpc.fullName 	= item.Contact__r.lastName + ', ' + item.Contact__r.FirstName;
				tpc.title 		= item.Contact__r.Title;
				tpc.phone 		= item.Contact__r.Phone;
				tpc.mobilePhone = item.Contact__r.MobilePhone;
				tpc.fax 		= item.Contact__r.Fax;
				tpc.email 		= item.Contact__r.Email;
				tpc.street 		= item.Contact__r.MailingStreet;
				tpc.city_state_pcode = item.Contact__r.MailingCity        != null ? item.Contact__r.MailingCity : '';
				tpc.city_state_pcode += tpc.city_state_pcode   != '' ? ', ' : ''; 
				tpc.city_state_pcode += item.Contact__r.MailingState      != null ? item.Contact__r.MailingState : '';
				tpc.city_state_pcode += tpc.city_state_pcode   != '' ? ' ' : '';  
				tpc.city_state_pcode += item.Contact__r.MailingPostalCode != null ? item.Contact__r.MailingPostalCode : '';    
				tpc.country 	= item.Contact__r.MailingCountry;
				
				if (tpc.fullName 		!= null) { tpc.fullName += '<br/>'; }
				if (tpc.title 			!= null) { tpc.title = 'Title: ' + tpc.title + '<br/>'; }
				if (tpc.phone 			!= null) { tpc.phone = 'Direct: ' + tpc.phone + '<br/>'; }
				if (tpc.mobilePhone 	!= null) { tpc.mobilePhone = 'Direct Fax: ' + tpc.mobilePhone + '<br/>'; }
				if (tpc.fax 			!= null) { tpc.fax = 'Mobile: ' + tpc.fax + '<br/>'; }
				if (tpc.email 			!= null) { tpc.email = 'Email: ' + tpc.email + '<br/>'; }
				if (tpc.street 			!= null) { tpc.street += '<br/>'; }
				if (tpc.city_state_pcode!= '')   { tpc.city_state_pcode += '<br/>'; }
				if (tpc.country 		!= null) { tpc.country += '<br/>'; }
				
				tarProfList.add(tpc);
			} 
		}
		
		return tarProfList;
	} // getTargetedProfessionals(ID targetBuyerId)
	
	public class BuyersLogClass {
		public String targetName { get; set; }
		public String targetType { get; set; }
		public List<TargetedProfessionalsClass> targetProfessionals { get; set; }
		public List<ResponsibleUsersClass> responsibleUsers { get; set; }
		public List<ActivitiesClass> acivityLogs { get; set; }

		public String ContactMade { get; set; }
		public String TeaserSent  { get; set; }
		public String CASent      { get; set; }
		public String CAStatus    { get; set; }
		public String CIMSent     { get; set; }
		public String CIMNumber   { get; set; }
		public String InitialBid  { get; set; }
		public String FinalBid    { get; set; }
		public String Declined    { get; set; }
	}

	public class ActivitiesClass {
		public String actDateTime    { get; set; }
		public String actType        { get; set; }
		public String actSubject     { get; set; }
		public String actNotes       { get; set; }
	}
	
	public class ResponsibleUsersClass {
		public String role           { get; set; }
		public String fullName       { get; set; }
		public String officeLocation { get; set; }
		public String phone          { get; set; }
	}
	
	public class TargetedProfessionalsClass {
		public String fullName          { get; set; }
		public String title             { get; set; }
		public String phone             { get; set; }
		public String mobilePhone       { get; set; }
		public String fax               { get; set; }
		public String email             { get; set; }
		public String street            { get; set; }
		public String city_state_pcode  { get; set; }
		public String country           { get; set; }
	}
}