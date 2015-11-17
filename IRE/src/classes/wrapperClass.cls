public with sharing class wrapperClass {

	//public String accinp {get;set;}
	public List<Account> accs = new List<Account>();	// List of type Account
	public List<accountwrapper> accwrap {get;set;}		//List of type wrapper class
	public List<Account> selectedaccount {get;set;}		//List of type account after Accounts get selected
	public Account anacc {get;set;}						// variable of type Account

	public void Changetype(){
		for(Account ac:selectedaccount){
			ac.Type = anacc.Type;
		}
		
	}

	//Class constructor
	public wrapperClass() {
		accwrap = new List<accountwrapper>();
		anacc = new Account();

		accs=[select name, id, website, type
				From Account
				Where website != null
				order by name
				limit 100];
		accountWrapperObject();
	}

	public void accountWrapperObject(){
		for(Account a:accs){
			accountwrapper aw = new accountwrapper(a);
			accwrap.add(aw);
		}
	}

	public void getselected(){
		selectedaccount = new List<Account>();
		selectedaccount.clear();
		for(accountwrapper awrap:accwrap)
		if(awrap.selected==true){
			selectedaccount.add(awrap.acc);
		}
	}
	public class accountwrapper{
		public account acc {get;set;}
		public boolean selected {get;set;}

		//constructor for the wrapper class
		public accountWrapper(Account a){
			acc = a;
			selected = false;
		}
	}
}