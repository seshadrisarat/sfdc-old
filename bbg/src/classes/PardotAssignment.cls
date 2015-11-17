public class PardotAssignment {
    
    private static Map<Id, RecordType> allLeadRecordTypes {
        get{
            
            if (allLeadRecordTypes == null){
                allLeadRecordTypes = new Map<Id, RecordType>([Select Id, DeveloperName From RecordType Where SObjectType = 'Lead']);
            }
            system.debug('Lead record types: ' + allLeadRecordTypes);
            return allLeadRecordTypes;
        }
        set;
    }
    
    public static boolean currentUserIsPardotUser() {
    	return pardotUserIds.contains(UserInfo.getUserId());
    }
    
    public static set<Id> pardotUserIds {
    	get {
    		if (pardotUserIds == null) {
    			pardotUserIds = new set<Id>();
    			
    			map<string, Id> pardotMap = brandToPardotUserIdMap;
    			for (Id id : pardotMap.values()) {
    				pardotUserIds.add(id);
    			}
    		}
    		return pardotUserIds;
    	}
    }
    
    public static map<string, Id> brandToPardotUserIdMap {
    	get {
    		if (brandToPardotUserIdMap == null) {
    			brandToPardotUserIdMap = new map<string, Id>();	
    			
    			map<string, String> brandToPardotAlias = pardotUserAliases;
    			if (!brandToPardotAlias.isEmpty()) {
			    	map<string, User> aliasToUserMap = new map<string, User>();
			    	list<User> users = [select Alias, Id from User where alias in : brandToPardotAlias.values()];
			    	for (User user : users) {
			    		aliasToUserMap.put(user.Alias, user);	
			    	}
			    	if (!aliasToUserMap.isEmpty()) {
			    		system.debug(aliasToUserMap.keySet());
			    		for (string brand : brandToPardotAlias.keySet()) {
			    			string alias = brandToPardotAlias.get(brand);
			    			User pardotUser = aliasToUserMap.get(alias);
			    			if (pardotUser != null) {
			    				brandToPardotUserIdMap.put(brand, pardotUser.Id);	
			    			}
			    		}	
			    	}
    			}
    		}	
    		return brandToPardotUserIdMap;
    	}
    }
   
    
    @testVisible
    private static User getPardotUser(String userAlias) {
        User[] pardotUsers = [Select u.Id, u.FirstName From User u Where u.Alias = :userAlias];
        
        if (pardotUsers.size() > 0) {
            system.debug('Pardot user id: ' + pardotUsers[0].Id);
            return pardotUsers[0];
        } else {
            return null;
        }
    }
    
    private static Map<String, String> pardotUserAliases{
        get{
            if (pardotUserAliases == null){
                pardotUserAliases = new Map<String, String>();
                for (Pardot_Connector_User_Alias__c p : Pardot_Connector_User_Alias__c.getAll().values()){
                    
                    if (!pardotUserAliases.containsKey(p.Pardot_Instance__c)){
                        pardotUserAliases.put(p.Pardot_Instance__c, p.User_Alias__c);
                    }
                    
                }
            }
            system.debug('pardotUserAliases: ' + pardotUserAliases);
            return pardotUserAliases;
        }
        set;
    }
    
    //Assigns ObjectChangeLog record to Pardot Owners   
    public static void assignToPardotOwner(list<pi__ObjectChangeLog__c> newOCLs) {
        
        for(pi__ObjectChangeLog__c ocl : newOCLs){
            
            //Convert the String value into a record Id
            Id associatedRecordId = Id.valueOf(ocl.pi__ObjectFid__c);
            
            //Get the parent id, if it exists
            Id associatedRecordParentId = null; 
            if (ocl.bbg_ObjectParentFId__c != null) {
            	associatedRecordParentId = Id.valueOf(ocl.bbg_ObjectParentFId__c);
            }
            
            //Get the record type based on the record Id
            String associatedRecordType = associatedRecordId.getSObjectType().getDescribe().getName();
            system.debug('The ObjectChangeLog is associated with a: ' + associatedRecordType);
            
            SObjectType associatedRecordObjectType = associatedRecordId.getSObjectType();
            
            system.debug('Associated record id: ' + associatedRecordId);
            
            if (associatedRecordObjectType == Lead.sObjectType) {
                Lead associatedLead = [Select l.id, l.Name, l.Email, l.RecordTypeId From Lead l Where l.id = :associatedRecordId];
                
                system.debug('New lead record type: '+ associatedLead.RecordTypeId + ', Lead Id: ' + associatedLead.Id + ', Lead Name: ' + associatedLead.Name + ', Lead Email: ' + associatedLead.Email);
                
                if (associatedLead.RecordTypeId != null) {
                    RecordType leadRecordType = allLeadRecordTypes.get(associatedLead.RecordTypeId);
                    User pardotUser = null;
                    
                    if (leadRecordType != null) {
                        if (leadRecordType.DeveloperName.equalsIgnoreCase('Sea_Ray_Lead')) {
                            pardotUser = getPardotUser(pardotUserAliases.get('SR'));
                        } else if (leadRecordType.DeveloperName.equalsIgnoreCase('Bayliner_Lead')) {
                            pardotUser = getPardotUser(pardotUserAliases.get('BL'));
                        } else if (leadRecordType.DeveloperName.equalsIgnoreCase('Maxum_Lead')) {
                            pardotUser = getPardotUser(pardotUserAliases.get('MX'));
                        } else if (leadRecordType.DeveloperName.equalsIgnoreCase('Trophy_Lead')) {
                            pardotUser = getPardotUser(pardotUserAliases.get('TR'));
                        } else if (leadRecordType.DeveloperName.equalsIgnoreCase('Meridian_Yachts_Lead')) {
                            pardotUser = getPardotUser(pardotUserAliases.get('MD'));
                        } else if (leadRecordType.DeveloperName.equalsIgnoreCase('Boston_Whaler_Lead')) {
                            pardotUser = getPardotUser(pardotUserAliases.get('BW'));
                        }
                        
                        if (pardotUser != null) {
                            ocl.ownerId = pardotUser.Id;
                        } 
                        
                    } else {
                        system.debug('Unable to find lead record type');
                    }
                    
                } else {
                    system.debug('Lead does not have a record type');
                }
            } else if (associatedRecordObjectType == Account.sObjectType) {
            	Account associatedAccount = [Select a.id, a.brand__c From Account a Where a.id = :associatedRecordId];
                system.debug('Account brand: '+ associatedAccount.brand__c);
                
                User pardotUser;
				if (associatedAccount.brand__c != null) {
                    pardotUser = getPardotUser(pardotUserAliases.get(associatedAccount.brand__c.toUpperCase()));
                } else {
                    system.debug('Account Id: ' + associatedAccount + 'does not have a brand type');
                }        
                
                if (pardotUser != null) {
        			ocl.ownerId = pardotUser.Id;
        		} else {
        			system.debug('Unable to find a Pardot user for Account: ' + associatedAccount.Id);
        		}              
            }  else if (associatedRecordObjectType == Contact.sObjectType) {
            	
            	User pardotUser;
            	Account associatedAccount;
            	
            	if (associatedRecordParentId == null) {
            		system.debug('Working with a contact account');
            		pardotUser = getPardotUser(pardotUserAliases.get('contact'));
            	} else {
            		system.debug('Working with a person account');
            		associatedAccount = [Select a.id, a.brand__c From Account a Where a.id = :associatedRecordParentId];
            		
            		if (associatedAccount.brand__c != null) {
                    	pardotUser = getPardotUser(pardotUserAliases.get(associatedAccount.brand__c.toUpperCase()));
	                } else {
	                    system.debug('Account does not have a brand type');
	                }     
            	}
	        		
        		if (pardotUser != null) {
        			ocl.ownerId = pardotUser.Id;
        		} else {
        			system.debug('Unable to find a Pardot user for ' + associatedRecordParentId == null ? 'Contact: ' + associatedAccount.Id : 'person account: ' + associatedRecordParentId);
        		}
        	}
        }
    }
}