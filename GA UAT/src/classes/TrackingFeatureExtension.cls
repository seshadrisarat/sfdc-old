//S-175097 - Created by Nisha (Appirio India) on 01/09/2014
//Class is created to track if Company(Account) is tracked by logged in User
public with sharing class TrackingFeatureExtension {
	
	public String usrId {get;set;}
	public Account cmp {get;set;}
	public Boolean isTracked {get;set;}
	public Track_Company__c tc;
	public Boolean isError {get;set;}
	
	
	
	public TrackingFeatureExtension(ApexPages.StandardController controller){
		cmp = (Account)controller.getRecord();
		usrId = UserInfo.getUserId();		
	}

  public PageReference isTrackedByUser(){
  	List<Track_Company__c> tcLst = [Select id from Track_Company__c 
  																	where Company__c =:cmp.id and User__c = :usrId];
    isTracked =  tcLst.size() > 0; 	
    if(tcLst.size() > 0){
    	tc = tcLst.get(0);
    }																
  	return null;
  }
  
  
  public PageReference setToTracked(){
  	
  	if(!isTracked){
  		Track_Company__c tcIns = new Track_Company__c(Company__c = cmp.id, User__c =  usrId);
  		try{
  		insert tcIns;  		
  		isError = false;
  		}
  		catch(Exception e){
  			
  			if(e.getMessage().contains('INSUFFICIENT_ACCESS')){
  			isError = true;  	
  			}
  			
  		}
  		
  	}
  	
  		return null;
  	
  }
  
  public PageReference setToTrack(){
  	if(isTracked){
  		delete tc;
  	}
  	return null;
  }
}