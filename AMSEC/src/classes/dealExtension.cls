public class dealExtension {
	private final Deal__c deal;
	public string contactID {get ; set ;}
	public string IndustryID {get ; set ;}
	public dealExtension(ApexPages.StandardController dealController){
		this.deal=(Deal__c)dealController.getRecord();
		contactID=deal.Source_Contact__c;
		IndustryID=deal.Industry_Deal__c;
	}
	public List<selectOption> SourceContactOptions {get {
		List<selectOption> sourceContacts= new List<selectOption>();
		for(Contact ptr : [select name from Contact pt where pt.AccountId =: deal.Source_Company__C order by name])
			sourceContacts.add(new selectOption(ptr.id, ptr.name));
		return sourceContacts;
	}
	set;}
	
	public void resetSourceContact() {
		contactID=null;
	}
	public List<selectOption> IndustryOptions { get {
		List<selectOption> industry=new List<selectOption>();
		for(Industry_Group__c ptr : [select Name from Industry_Group__c order by Name])
			industry.add(new selectOption(ptr.id, ptr.Name));
		return industry;
	}
	set;}
	
	public PageReference step2() {
		return Page.DealWizard2;
	}
	
	public PageReference step3(){
		return Page.DealWizard3;
	}
	
	public PageReference bigSave(){
		deal.Industry_Deal__c = IndustryID;
		deal.Source_Contact__c = contactID;
		try {insert deal;}
		catch (DmlException de) {
			de.setmessage('The Deal was not added to the database.  Make sure that fields contain correct data. Ensure that Project Name contains the word Project if you are using it.');
		}
		return new ApexPages.Standardcontroller(new Deal__c(id=deal.Id)).view();
	}
}