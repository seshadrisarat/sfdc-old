public with sharing class UserList {
	public List<User> lstUser {get;set;}
	public UserList(){
		
		lstUser = [select Name from User];
	}
	

}