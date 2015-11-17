/*
*Class: FbD_Org_Admin_External_Security_Tests
*Description: This test class is used to check access on various objects for currently loggedin portal user administrator
*Copyright 2014 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/

@isTest
private class FbD_Org_Admin_External_Security_Tests {
    /*

    private STATIC FINAL STRING org_admin_profile = 'MIHN - HPD Organization Administrator';
    private STATIC User CURRENTUSER = [Select ID From User Where id = :userInfo.getUserId()];
    private STATIC Account portalUserAccount, otherPortalUserAccount;
    private STATIC Contact portalUserContact, otherPortalUserContact;


    private static RecordType aRT = [Select ID From RecordType Where sObjectType = 'Account' and Name = 'Provider Organization' LIMIT 1];
    private static RecordType cRT = [Select ID From RecordType Where sObjectType = 'Contact' and Name = 'Provider' LIMIT 1];
    private static Map<Schema.sObjectType, sObject[]> obj_recs = New Map<Schema.sObjectType, sObject[]>();


    static{
    	system.runAs(CURRENTUSER){
	    	
            portalUserAccount = New Account(
	    							Name = 'Current Portal User Account',
	                            	Portal_Licenses_Allocated__c = 99,
                                    Population__c = 'eTHIN',
                                    RecordTypeID = aRT.id
								);

    	    insert_rec(Account.sObjectType,portalUserAccount);

            otherPortalUserAccount = New Account(
                                    Name = 'Other Portal User Account',
                                    Portal_Licenses_Allocated__c = 99,
                                    Population__c = 'eTHIN',
                                    RecordTypeID = aRT.id
                                );

            insert_rec(Account.sObjectType,otherPortalUserAccount);

	    	portalUserContact = New Contact(
                                    FirstName = 'Org Admin',
                                    LastName = 'Contact',
                                    AccountID = portalUserAccount.id,
                                    RecordTypeId = cRT.id
                                    );

            insert_rec(Contact.sObjectType,portalUserContact);
            

	    	otherPortalUserContact = New Contact(
                                    FirstName = 'Other Org Admin',
                                    LastName = 'Contact',
                                    AccountID = otherPortalUserAccount.id,
                                    RecordTypeId = cRT.id
                                    );

            insert_rec(Contact.sObjectType,otherPortalUserContact);


    	}
    }

    private Static void insert_rec(Schema.sObjecttype ot, sobject obj){
        insert obj;

        if(obj_recs.containsKey(ot))
            obj_recs.get(ot).add(obj);
        else
            obj_recs.put(ot,New sObject[]{obj});
    }


    private static testmethod void organization_and_Provider_Access_ByOwner(){
        
        //    Organization Admin has ALL access on their own Organization and Providers
        //    Organization Admin has READ access on Organizations and Providers not owned by their account
        

        User orgAdmin = createCustomerPortalUser(org_admin_profile,portalUserContact);
		User orgAdminOther = createCustomerPortalUser(org_admin_profile,otherPortalUserContact);

        system.runAs(orgAdmin){

            Contact c1 = New Contact(AccountId = portalUserAccount.id,
                    FirstName = 'Pop',
                    LastName = 'Admin',
                    Email = 'popuser@test.com',
                    RecordTypeId = cRT.id
                    );
            insert_rec(Contact.sObjectType, c1);

            
            //Create another contact that is part of Org and test access

            Contact c2 = New Contact(AccountId = portalUserAccount.id,
                    FirstName = 'Test',
                    LastName = 'User Good',
                    Email = 'gooduser@test.com',
                    RecordTypeId = cRT.id
                    );
            insert_rec(Contact.sObjectType, c2);
            
        }
        
        system.runAs(orgAdminOther){    
            
            Contact c3 = New Contact(AccountId = otherPortalUserAccount.id,
                    FirstName = 'Test',
                    LastName = 'User Bad',
                    Email = 'otheruser@test.com',
                    RecordTypeId = cRT.id
                    );
            insert_rec(Contact.sObjectType, c3);

        
        }


        test_access(Account.sObjectType,
            New Map<String,Map<ID,String[]>>{
                'MAX'=>New Map<ID,String[]>{orgAdmin.id=>New String[]{'Read','Read'}},
                'EDIT'=>New Map<ID,String[]>{orgAdmin.id=>New String[]{'False','False'}}
                },obj_recs);
        
        //First contact is the orgAdminContact, Second is the other Org Admin Contact
        test_access(Contact.sObjectType,
            New Map<String,Map<ID,String[]>>{
                'MAX'=>New Map<ID,String[]>{orgAdmin.id=>New String[]{'Edit','Read','Edit','Edit','Read'}},
                'EDIT'=>New Map<ID,String[]>{orgAdmin.id=>New String[]{'True','False', 'True','True','False'}}
                },obj_recs);
                            
    }



    private static testmethod void organization_Portal_Access(){
        // PROBLEM: Currently have access but I do not think they should have an email out 6-3-2014
        
        User orgAdmin = createCustomerPortalUser(org_admin_profile,portalUserContact);

        system.runAs(orgAdmin){
            
            DescribesObjectresult describe_result = Organization_Portal__c.sObjectType.getDescribe();
            system.assertEquals(true, describe_result.isAccessible());

            
        }
        
                    
    
    }


    private static testmethod void organization_Names_Access(){


        User orgAdmin = createCustomerPortalUser(org_admin_profile,portalUserContact);
        User orgAdminOther = createCustomerPortalUser(org_admin_profile,otherPortalUserContact);
        
        
        system.runAs(orgAdmin){

            
            try{
                
                Organization_Name__c onr = New Organization_Name__c(Name = 'Record Name',
                    Organization__c = portalUserAccount.id
                    );

                insert_rec(Organization_Name__c.sObjectType,onr);

            	system.assertEquals(true,false,'Org Admin was not supposed to be able to create this record when they do not own the account');
            }catch(Exception e){

            }

            Account a1 = New Account(Name = 'Organization Admin Account', RecordTypeID = aRT.id);
            insert_rec(Account.sObjectType, a1);
            
            Organization_Name__c on1 = New Organization_Name__c(Name = 'Record Name',
                Organization__c = a1.id
                );

            insert_rec(Organization_Name__c.sObjectType,on1);

            
        }
        
        system.runAs(orgAdminOther){    
            Account a2 = New Account(Name = 'Other Organization Admin Account', RecordTypeID = aRT.id);
            insert_rec(Account.sObjectType, a2);
            
            Organization_Name__c on2 = New Organization_Name__c(Name = 'Record Name',
                Organization__c = a2.id
                );

            insert_rec(Organization_Name__c.sObjectType,on2);
            
                                 
        }
        

        test_access(Organization_Name__c.sObjectType,New Map<String,Map<ID,String[]>>{
        	'MAX'=>New Map<ID,String[]>{orgAdmin.id=>New String[]{'Delete','Read'}}
        	},obj_recs);                    
        test_access(Organization_Name__c.sObjectType,New Map<String,Map<ID,String[]>>{
        	'MAX'=>New Map<ID,String[]>{orgAdminOther.id=>New String[]{'Read','Delete'}}
        	},obj_recs);                    
    }


    private static testmethod void organization_Address_Access(){

        //Delete Access to their own and read on others (No transfer access on child object

        User orgAdmin = createCustomerPortalUser(org_admin_profile,portalUserContact);
        User orgAdminOther = createCustomerPortalUser(org_admin_profile,otherPortalUserContact);
        
        system.runAs(orgAdmin){

            try{

                Organization_Address__c rec = New Organization_Address__c(Organization__c = portalUserAccount.id);
                insert_rec(Organization_Address__c.sObjectType,rec);

                system.assertEquals(true,false,'Org Admin was not supposed to be able to create this record when they do not own the account');
            }catch(Exception e){

            }

            Account a1 = New Account(Name = 'Current Organization Admin Account', RecordTypeID = aRT.id);
            insert_rec(Account.sObjectType, a1);
            
            Organization_Address__c rec2 = New Organization_Address__c(Organization__c = a1.id);
            insert_rec(Organization_Address__c.sObjectType,rec2);


            
        }
        
        system.runAs(orgAdminOther){    
            Account a2 = New Account(Name = 'Other Organization Admin Account', RecordTypeID = aRT.id);
            insert_rec(Account.sObjectType, a2);
            
            Organization_Address__c rec3 = New Organization_Address__c(Organization__c = a2.id);
            insert_rec(Organization_Address__c.sObjectType,rec3);
            
                                 
        }

        test_access(organization_Address__c.sObjectType,New Map<String,Map<ID,String[]>>{
            'MAX'=>New Map<ID,String[]>{orgAdmin.id=>New String[]{'Delete','Read'}}
            },obj_recs);                    
        test_access(organization_Address__c.sObjectType,New Map<String,Map<ID,String[]>>{
            'MAX'=>New Map<ID,String[]>{orgAdminOther.id=>New String[]{'Read','Delete'}}
            },obj_recs);                    
    }


    private static testmethod void organization_Credential_Access(){

        //Delete Access to their own and read on others (No transfer access on child object        

        User orgAdmin = createCustomerPortalUser(org_admin_profile,portalUserContact);
        User orgAdminOther = createCustomerPortalUser(org_admin_profile,otherPortalUserContact);
        
        system.runAs(orgAdmin){

            try{

                Organization_Credential__c rec = New Organization_Credential__c(Organization__c = portalUserAccount.id,Credential_Number__c='123');
                insert_rec(Organization_Credential__c.sObjectType,rec);
                system.assertEquals(true,false,'Org Admin was not supposed to be able to create this record when they do not own the account');
            }catch(Exception e){

            }

            Account a1 = New Account(Name = 'Current Organization Admin Account', RecordTypeID = aRT.id);
            insert_rec(Account.sObjectType, a1);

            Organization_Credential__c rec2 = New Organization_Credential__c(Organization__c = a1.id,Credential_Number__c='123');
            insert_rec(Organization_Credential__c.sObjectType,rec2);

            
        }
        
        system.runAs(orgAdminOther){    

            Account a2 = New Account(Name = 'Current Organization Admin Account', RecordTypeID = aRT.id);
            insert_rec(Account.sObjectType, a2);

            Organization_Credential__c rec3 = New Organization_Credential__c(Organization__c = a2.id,Credential_Number__c='123');
            insert_rec(Organization_Credential__c.sObjectType,rec3);

                                 
        }
        
        test_access(Organization_Credential__c.sObjectType,New Map<String,Map<ID,String[]>>{
            'MAX'=>New Map<ID,String[]>{orgAdmin.id=>New String[]{'Delete','Read'}}
            },obj_recs);                    
        test_access(Organization_Credential__c.sObjectType,New Map<String,Map<ID,String[]>>{
            'MAX'=>New Map<ID,String[]>{orgAdminOther.id=>New String[]{'Read','Delete'}}
            },obj_recs);                    
    }


    private static testmethod void organization_Specialty_Access(){

        //Delete Acces to their own and read on others (No transfer access on child object
        
        Specialty__c sp;

        User orgAdmin = createCustomerPortalUser(org_admin_profile,portalUserContact);
        User orgAdminOther = createCustomerPortalUser(org_admin_profile,otherPortalUserContact);

        
        system.runAs(currentUser){
            sp = New Specialty__c(Name = 'Test Name');
            insert_rec(Specialty__c.sObjectType,sp);
        }
        
        system.runAs(orgAdmin){

            try{

                Organization_Specialty__c rec = New Organization_Specialty__c(Organization__c = portalUserAccount.id, Specialty__c=sp.id);
                insert_rec(Organization_Specialty__c.sObjectType,rec);
                system.assertEquals(true,false,'Org Admin was not supposed to be able to create this record when they do not own the account');
            }catch(Exception e){

            }

            Account a1 = New Account(Name = 'Current Organization Admin Account', RecordTypeID = aRT.id);
            insert_rec(Account.sObjectType, a1);

            Organization_Specialty__c rec2 = New Organization_Specialty__c(Organization__c = a1.id, Specialty__c=sp.id);
            insert_rec(Organization_Specialty__c.sObjectType,rec2);

            
        }
        
        system.runAs(orgAdminOther){    

            Account a2 = New Account(Name = 'Other Organization Admin Account', RecordTypeID = aRT.id);
            insert_rec(Account.sObjectType, a2);

            Organization_Specialty__c rec3 = New Organization_Specialty__c(Organization__c = a2.id, Specialty__c=sp.id);
            insert_rec(Organization_Specialty__c.sObjectType,rec3);
                                 
        }
        
        test_access(Organization_Specialty__c.sObjectType,New Map<String,Map<ID,String[]>>{
            'MAX'=>New Map<ID,String[]>{orgAdmin.id=>New String[]{'Delete','Read'}}
            },obj_recs);                    
        test_access(Organization_Specialty__c.sObjectType,New Map<String,Map<ID,String[]>>{
            'MAX'=>New Map<ID,String[]>{orgAdminOther.id=>New String[]{'Read','Delete'}}
            },obj_recs);                    
    }



    private static testmethod void organization_Service_Access(){

        //Delete Acces to their own and read on others (No transfer access on child object
        
        Electronic_Service__c es;

        User orgAdmin = createCustomerPortalUser(org_admin_profile,portalUserContact);
        User orgAdminOther = createCustomerPortalUser(org_admin_profile,otherPortalUserContact);

        
        system.runAs(currentUser){
            es = New Electronic_Service__c(Address__c = 'Test Value',
                Name = 'Record Name',
                Payload__c = 'Test Value',
                Protocol__c = 'Test Value',
                Type__c = 'Test Value'
                );
            insert_rec(Electronic_Service__c.sObjectType,es);

        }
        
        system.runAs(orgAdmin){

            try{

                Organization_Service__c rec = New Organization_Service__c(Organization__c = portalUserAccount.id, Electronic_Service__c=es.id);
                insert_rec(Organization_Service__c.sObjectType,rec);
                
                system.assertEquals(true,false,'Org Admin was not supposed to be able to create this record when they do not own the account');
            }catch(Exception e){

            }

            try{

                Account a1 = New Account(Name = 'Current Organization Admin Account', RecordTypeID = aRT.id);
                insert_rec(Account.sObjectType, a1);

                Organization_Service__c rec2 = New Organization_Service__c(Organization__c = a1.id, Electronic_Service__c=es.id);
                insert_rec(Organization_Service__c.sObjectType,rec2);
                system.assertEquals(true,false,'User was not suposed to be able to create this record when they do not have access to the Electronic Service');

            }catch(exception e){

            }finally{

            }
            
        }
    
    /*    
        system.runAs(orgAdminOther){    

            Account a2 = New Account(Name = 'Current Organization Admin Account', RecordTypeID = aRT.id);
            insert_rec(Account.sObjectType, a2);

            Organization_Service__c rec3 = New Organization_Service__c(Organization__c = a2.id, Electronic_Service__c=es.id);
            insert_rec(Organization_Service__c.sObjectType,rec3);
                                 
        }
        
        test_access(Organization_Service__c.sObjectType,New Map<String,Map<ID,String[]>>{
            'MAX'=>New Map<ID,String[]>{orgAdmin.id=>New String[]{'Delete','Read'}}
            },obj_recs);                    
        test_access(Organization_Service__c.sObjectType,New Map<String,Map<ID,String[]>>{
            'MAX'=>New Map<ID,String[]>{orgAdminOther.id=>New String[]{'Read','Delete'}}
            },obj_recs);                    
    //*\/
    }


    private static testmethod void affiliation_Provider_Access(){

        //Delete Acces to their own and read on others (No transfer access on child object

        User orgAdmin = createCustomerPortalUser(org_admin_profile,portalUserContact);
        User orgAdminOther = createCustomerPortalUser(org_admin_profile,otherPortalUserContact);



        system.runAs(orgAdmin){

            Account a1 = New Account(Name = 'Current Organization Admin Account', RecordTypeID = aRT.id);
            insert_rec(Account.sObjectType, a1);

            Contact c1 = New Contact(AccountId = obj_recs.get(Account.sObjectType)[0].id,
                    FirstName = 'First',
                    LastName = 'Contact',
                    RecordTypeId = cRT.id
                    );
            insert_rec(Contact.sObjectType, c1);


            
        }
        
        system.runAs(orgAdminOther){    

            Account a2 = New Account(Name = 'Other Organization Admin Account', RecordTypeID = aRT.id);
            insert_rec(Account.sObjectType, a2);

            Contact c2 = New Contact(AccountId = obj_recs.get(Account.sObjectType)[1].id,
                    FirstName = 'Test',
                    LastName = 'User Bad',
                    Email = 'otheruser@test.com',
                    RecordTypeId = cRT.id
                    );
            insert_rec(Contact.sObjectType, c2);
            
        }

        system.runAs(orgAdmin){

            Affiliation__c rec = New Affiliation__c(Organization__c = obj_recs.get(Account.sObjectType)[2].id,
                            Provider__c = obj_recs.get(Contact.sObjectType)[2].id,
                            Type__c = 'Test Value'
                            );
            insert_rec(Affiliation__c.sObjectType,rec);

        }   

        system.runAs(orgAdminOther){
            Affiliation__c rec2 = New Affiliation__c(Organization__c = obj_recs.get(Account.sObjectType)[3].id,
                            Provider__c = obj_recs.get(Contact.sObjectType)[3].id,
                            Type__c = 'Test Value'
                            );
            insert_rec(Affiliation__c.sObjectType,rec2);


        }  

        
        test_access(Affiliation__c.sObjectType,New Map<String,Map<ID,String[]>>{
            'MAX'=>New Map<ID,String[]>{orgAdmin.id=>New String[]{'Delete','Read'}}
            },obj_recs);                    
        test_access(Affiliation__c.sObjectType,New Map<String,Map<ID,String[]>>{
            'MAX'=>New Map<ID,String[]>{orgAdminOther.id=>New String[]{'Read','Delete'}}
            },obj_recs);                    

        //Test that this affiliation did not provide access to the Organization - first 2 accounts are the portal user accounts
        test_access(Account.sObjectType,
            New Map<String,Map<ID,String[]>>{
                'MAX'=>New Map<ID,String[]>{orgAdmin.id=>New String[]{'Read','Read','All','Read'}},
                'EDIT'=>New Map<ID,String[]>{orgAdmin.id=>New String[]{'False','False','True','False'}}
                },obj_recs);
        test_access(Account.sObjectType,
            New Map<String,Map<ID,String[]>>{
                'MAX'=>New Map<ID,String[]>{orgAdminOther.id=>New String[]{'Read','Read','Read','All'}},
                'EDIT'=>New Map<ID,String[]>{orgAdminOther.id=>New String[]{'False','False','False','True'}}
                },obj_recs);

        //Test that this affiliation did not provide access to the Providers
        test_access(Contact.sObjectType,
            New Map<String,Map<ID,String[]>>{
                'MAX'=>New Map<ID,String[]>{orgAdmin.id=>New String[]{'Edit','Read','Edit','Read'}},
                'EDIT'=>New Map<ID,String[]>{orgAdmin.id=>New String[]{'True','False','True','False'}}
                },obj_recs);
        test_access(Contact.sObjectType,
            New Map<String,Map<ID,String[]>>{
                'MAX'=>New Map<ID,String[]>{orgAdminOther.id=>New String[]{'Read','Edit','Read','Edit'}},
                'EDIT'=>New Map<ID,String[]>{orgAdminOther.id=>New String[]{'False','True','False','True'}}
                },obj_recs);

    }


    private static testmethod void care_Team_Access(){

        //Delete Acces to their own and read on others (No transfer access on child object
        
        User orgAdmin = createCustomerPortalUser(org_admin_profile,portalUserContact);
        User orgAdminOther = createCustomerPortalUser(org_admin_profile,otherPortalUserContact);
        
        system.runAs(orgAdmin){

            try{
                Care_Team__c rec = New Care_Team__c(Name = 'Record Name',
                    Organization__c = portalUserAccount.id);

                insert_rec(Care_Team__c.sObjectType, rec);

                system.assertEquals(true,false,'Org Admin was not supposed to be able to create this record when they do not own the account');
            }catch(Exception e){

            }

            Account a1 = New Account(Name = 'Other Organization Admin Account', RecordTypeID = aRT.id);
            insert_rec(Account.sObjectType, a1);

            Care_Team__c rec = New Care_Team__c(Name = 'Record Name',
                Organization__c = a1.id);

            insert_rec(Care_Team__c.sObjectType, rec);

            
        }
        
        system.runAs(orgAdminOther){    

            Account a2 = New Account(Name = 'Other Organization Admin Account', RecordTypeID = aRT.id);
            insert_rec(Account.sObjectType, a2);

            Care_Team__c rec2 = New Care_Team__c(Name = 'Record Name',
                Organization__c = a2.id);

            insert_rec(Care_Team__c.sObjectType, rec2);
                                 
        }
        
        test_access(Care_Team__c.sObjectType,New Map<String,Map<ID,String[]>>{
            'MAX'=>New Map<ID,String[]>{orgAdmin.id=>New String[]{'Delete','Read'}}
            },obj_recs);                    
        test_access(Care_Team__c.sObjectType,New Map<String,Map<ID,String[]>>{
            'MAX'=>New Map<ID,String[]>{orgAdminOther.id=>New String[]{'Read','Delete'}}
            },obj_recs);                    
    }


    private static testmethod void care_Team_Service_Access(){

        //Delete Acces to their own and read on others (No transfer access on child object
        
        User orgAdmin = createCustomerPortalUser(org_admin_profile,portalUserContact);
        User orgAdminOther = createCustomerPortalUser(org_admin_profile,otherPortalUserContact);
        
        system.runAs(orgAdmin){

            Account a1 = New Account(Name = 'Current Org Admin Account', RecordTypeID = aRT.id);
            insert_rec(Account.sObjectType, a1);


            Care_Team__c ct1 = New Care_Team__c(Name = 'Record Name',
                Organization__c = a1.id);

            insert_rec(Care_Team__c.sObjectType, ct1);
            
            Electronic_Service__c es1 = New Electronic_Service__c(Address__c = 'Test Value',
               Name = 'Record Name',
               Payload__c = 'Test Value',
               Protocol__c = 'Test Value',
               Type__c = 'Test Value',
               Organization__c = a1.id);

            insert_rec(Electronic_Service__c.sObjectType, es1);

            Care_Team_Service__c cts1 = New Care_Team_Service__c(Care_Team__c = ct1.id,
               Electronic_Service__c = es1.id,
               Name = 'Record Name'); 

            insert_rec(Care_Team_Service__c.sObjectType, cts1);              


            
        }
        
        system.runAs(orgAdminOther){    

            Account a2 = New Account(Name = 'Other Org Admin Account', RecordTypeID = aRT.id);
            insert_rec(Account.sObjectType, a2);


            Care_Team__c ct2 = New Care_Team__c(Name = 'Record Name',
                Organization__c = a2.id);

            insert_rec(Care_Team__c.sObjectType, ct2);
            
            Electronic_Service__c es2 = New Electronic_Service__c(Address__c = 'Test Value',
               Name = 'Record Name2',
               Payload__c = 'Test Value2',
               Protocol__c = 'Test Value2',
               Type__c = 'Test Value',
               Organization__c = a2.id);

            insert_rec(Electronic_Service__c.sObjectType, es2);

            Care_Team_Service__c cts2 = New Care_Team_Service__c(Care_Team__c = ct2.id,
               Electronic_Service__c = es2.id,
               Name = 'Record Name');

           insert_rec(Care_Team_Service__c.sObjectType, cts2);                              
                                 
                                 
        }
        
        test_access(Care_Team_Service__c.sObjectType,New Map<String,Map<ID,String[]>>{
            'MAX'=>New Map<ID,String[]>{orgAdmin.id=>New String[]{'Delete','Read'}}
            },obj_recs);                    
        test_access(Care_Team_Service__c.sObjectType,New Map<String,Map<ID,String[]>>{
            'MAX'=>New Map<ID,String[]>{orgAdminOther.id=>New String[]{'Read','Delete'}}
            },obj_recs);                    
    }


    private static testmethod void affiliation_Access(){

        //Delete Acces to their own and read on others (No transfer access on child object
        
        User orgAdmin = createCustomerPortalUser(org_admin_profile,portalUserContact);
        User orgAdminOther = createCustomerPortalUser(org_admin_profile,otherPortalUserContact);

        system.runAs(orgAdmin){

            Account a1 = New Account(Name = 'Current Org Admin Account', RecordTypeID = aRT.id);
            insert_rec(Account.sObjectType, a1);

            
        }
        
        system.runAs(orgAdminOther){    

            Account a2 = New Account(Name = 'Other Org Admin Account', RecordTypeID = aRT.id);
            insert_rec(Account.sObjectType, a2);

        }

        system.runAs(orgAdmin){

            Organization_Affiliation__c oa1 = New Organization_Affiliation__c(Affiliated_Organization__c = obj_recs.get(Account.sObjectType)[3].id,
               Affiliation_Type__c = 'Test Value',
               Member_Organization__c = obj_recs.get(Account.sObjectType)[2].id);

            insert_rec(Organization_Affiliation__c.sObjectType, oa1);

            try{
                Organization_Affiliation__c oa2 = New Organization_Affiliation__c(Affiliated_Organization__c = obj_recs.get(Account.sObjectType)[2].id,
                   Affiliation_Type__c = 'Test Value',
                   Member_Organization__c = obj_recs.get(Account.sObjectType)[3].id);

                    insert_rec(Organization_Affiliation__c.sObjectType, oa2);                

                    system.assertEquals(true,false,'The Org Admin was not supposed to be able to create an affiliation with the master to an organization they do not own');
            }catch(exception e){

            }

        }   

        system.runAs(orgAdminOther){

            Organization_Affiliation__c oa3 = New Organization_Affiliation__c(Affiliated_Organization__c = obj_recs.get(Account.sObjectType)[2].id,
               Affiliation_Type__c = 'Test Value',
               Member_Organization__c = obj_recs.get(Account.sObjectType)[3].id);

            insert_rec(Organization_Affiliation__c.sObjectType, oa3);

        }  
        
        test_access(Organization_Affiliation__c.sObjectType,New Map<String,Map<ID,String[]>>{
            'MAX'=>New Map<ID,String[]>{orgAdmin.id=>New String[]{'Delete','Read'}}
            },obj_recs);                    
        test_access(Organization_Affiliation__c.sObjectType,New Map<String,Map<ID,String[]>>{
            'MAX'=>New Map<ID,String[]>{orgAdminOther.id=>New String[]{'Read','Delete'}}
            },obj_recs);                    

        //Test that this affiliation did not provide access to the Organization
        test_access(Account.sObjectType,
            New Map<String,Map<ID,String[]>>{
                'MAX'=>New Map<ID,String[]>{orgAdmin.id=>New String[]{'Read','Read','All','Read'}},
                'EDIT'=>New Map<ID,String[]>{orgAdmin.id=>New String[]{'False','False','True','False'}}
                },obj_recs);
        test_access(Account.sObjectType,
            New Map<String,Map<ID,String[]>>{
                'MAX'=>New Map<ID,String[]>{orgAdminOther.id=>New String[]{'Read','Read','Read','All'}},
                'EDIT'=>New Map<ID,String[]>{orgAdminOther.id=>New String[]{'Read','Read','False','true'}}
                },obj_recs);


    }


    private static testmethod void active_Care_Relationship_Access(){
        //TODO: Should be NO ACCESS
        
        User orgAdmin = createCustomerPortalUser(org_admin_profile,portalUserContact);
        system.runAs(orgAdmin){
            
            DescribesObjectresult describe_result = Active_Care_Relationship__c.sObjectType.getDescribe();
            system.assertEquals(true, describe_result.isAccessible());

            
        }
    }


    private static testmethod void support_Ticket_Access(){



        //Edit Access to their own and read on others (No transfer access on child object - RecordLevelAccess is Full       

        User orgAdmin = createCustomerPortalUser(org_admin_profile,portalUserContact);
        User orgAdminOther = createCustomerPortalUser(org_admin_profile,otherPortalUserContact);
        RecordType caseRT = [Select ID From RecordType Where sObjectType = 'Case' And Name = 'Provider Record Type' LIMIT 1];

        system.runAs(orgAdmin){

            Account a1 = New Account(Name = 'Current Org Admin Account', RecordTypeID = aRT.id);
            insert_rec(Account.sObjectType, a1);

            

            Case rec = New Case(Origin = 'Test Value',
               Status = 'Test Value',
               RecordTypeID = caseRT.id,
               AccountID = a1.id,
               BusinessHoursID = null);

            insert_rec(Case.sObjectType, rec);


            //Object Level Access is Edit
            DescribesObjectresult describe_result = Case.sObjectType.getDescribe();
            system.assertEquals(false, describe_result.isDeletable());


            
        }
        
        system.runAs(orgAdminOther){    

            Account a2 = New Account(Name = 'Other Org Admin Account', RecordTypeID = aRT.id);
            insert_rec(Account.sObjectType, a2);


            Case rec2 = New Case(Origin = 'Test Value',
               Status = 'Test Value',
               RecordTypeID = caseRT.id,
               AccountID = a2.id,
               BusinessHoursID = null);

            insert_rec(Case.sObjectType, rec2);

                                 
        }
        
        test_access(Case.sObjectType,
            New Map<String,Map<ID,String[]>>{
                'MAX'=>New Map<ID,String[]>{orgAdmin.id=>New String[]{'All','None'}},
                'EDIT'=>New Map<ID,String[]>{orgAdmin.id=>New String[]{'True','False'}},
                'READ'=>New Map<ID,String[]>{orgAdmin.id=>New String[]{'True','False'}}
                },obj_recs);                    
        test_access(Case.sObjectType,
            New Map<String,Map<ID,String[]>>{
                'MAX'=>New Map<ID,String[]>{orgAdminOther.id=>New String[]{'None','All'}},
                'EDIT'=>New Map<ID,String[]>{orgAdminOther.id=>New String[]{'False','True'}},
                'READ'=>New Map<ID,String[]>{orgAdminOther.id=>New String[]{'False','True'}}
                },obj_recs);                    

    }

    private static testmethod void task_Access(){

        
        User orgAdmin = createCustomerPortalUser(org_admin_profile,portalUserContact);        
        system.runAs(orgAdmin){

            //Object Level Access is Edit
            DescribesObjectresult describe_result = Task.sObjectType.getDescribe();
            system.assertEquals(false, describe_result.isDeletable());
            system.assertEquals(false, describe_result.isUpdateable());
            system.assertEquals(true, describe_result.isAccessible());
            system.assertEquals(false, describe_result.isCreateable());
        }
    }

    private static testmethod void event_Access(){
        
        User orgAdmin = createCustomerPortalUser(org_admin_profile,portalUserContact);                

        system.runAs(orgAdmin){

            //Object Level Access is Edit
            DescribesObjectresult describe_result = Event.sObjectType.getDescribe();
            system.assertEquals(false, describe_result.isDeletable());
            system.assertEquals(false, describe_result.isUpdateable());
            system.assertEquals(true, describe_result.isAccessible());
            system.assertEquals(false, describe_result.isCreateable());

            
        }
    }

    private static testmethod void electronic_Service_Access(){

        //Delete Acces to their own and read on others (No transfer access on child object
        
        User orgAdmin = createCustomerPortalUser(org_admin_profile,portalUserContact);
        User orgAdminOther = createCustomerPortalUser(org_admin_profile,otherPortalUserContact);
        
        system.runAs(orgAdmin){

            Electronic_Service__c servA = New Electronic_Service__c(Address__c = 'Test Value',
               Name = 'Record Name',
               Payload__c = 'Test Value',
               Protocol__c = 'Test Value',
               Type__c = 'Test Value');

            insert_rec(Electronic_Service__c.sObjectType,servA);

            
        }
        
        system.runAs(orgAdminOther){    
            
            Electronic_Service__c servB = New Electronic_Service__c(Address__c = 'Test Value',
               Name = 'Record Name2',
               Payload__c = 'Test Value',
               Protocol__c = 'Test Value',
               Type__c = 'Test Value');

            insert_rec(Electronic_Service__c.sObjectType,servB);

                                 
        }
        
        test_access(Electronic_Service__c.sObjectType,New Map<String,Map<ID,String[]>>{
            'MAX'=>New Map<ID,String[]>{orgAdmin.id=>New String[]{'All','Read'}},
            'EDIT'=>New Map<ID,String[]>{orgAdmin.id=>New String[]{'True','False'}}
            },obj_recs);                    
        test_access(Electronic_Service__c.sObjectType,New Map<String,Map<ID,String[]>>{
            'MAX'=>New Map<ID,String[]>{orgAdminOther.id=>New String[]{'Read','All'}},
            'EDIT'=>New Map<ID,String[]>{orgAdminOther.id=>New String[]{'False','True'}}
            },obj_recs);                    
    }

    private static testmethod void affiliation_Service_Access(){

        //Delete Acces to their own and read on others (No transfer access on child object
        
        User orgAdmin = createCustomerPortalUser(org_admin_profile,portalUserContact);
        User orgAdminOther = createCustomerPortalUser(org_admin_profile,otherPortalUserContact);


        system.runAs(orgAdmin){

            Account a1 = New Account(Name = 'Current Org Admin Account', RecordTypeID = aRT.id);
            insert_rec(Account.sObjectType, a1);

            Contact c1 = New Contact(AccountId = obj_recs.get(Account.sObjectType)[0].id,
                    FirstName = 'First',
                    LastName = 'Contact',
                    RecordTypeId = cRT.id
                    );
            insert_rec(Contact.sObjectType, c1);

            Electronic_Service__c servA = New Electronic_Service__c(Address__c = 'Test Value',
               Name = 'Record Name',
               Payload__c = 'Test Value',
               Protocol__c = 'Test Value',
               Type__c = 'Test Value');

            insert_rec(Electronic_Service__c.sObjectType,servA);

            Affiliation__c affA = New Affiliation__c(Organization__c = obj_recs.get(Account.sObjectType)[2].id,
                            Provider__c = obj_recs.get(Contact.sObjectType)[2].id,
                            Type__c = 'Test Value'
                            );
            insert_rec(Affiliation__c.sObjectType,affA);



            Affiliation_Service__c asA = New Affiliation_Service__c(Affiliation__c = affA.id,
               Electronic_Service__c = servA.id);

            insert_rec(Affiliation_Service__c.sObjectType,asA);

        }
        
        system.runAs(orgAdminOther){    

            
            Account a2 = New Account(Name = 'Other Population Admin Account', RecordTypeID = aRT.id);
            insert_rec(Account.sObjectType, a2);

            Contact c2 = New Contact(AccountId = obj_recs.get(Account.sObjectType)[1].id,
                    FirstName = 'Second',
                    LastName = 'Contact',
                    RecordTypeId = cRT.id
                    );
            insert_rec(Contact.sObjectType, c2);

            Electronic_Service__c servB = New Electronic_Service__c(Address__c = 'Test Value',
               Name = 'Record Name2',
               Payload__c = 'Test Value',
               Protocol__c = 'Test Value',
               Type__c = 'Test Value');

            insert_rec(Electronic_Service__c.sObjectType,servB);

            Affiliation__c affB = New Affiliation__c(Organization__c = obj_recs.get(Account.sObjectType)[3].id,
                            Provider__c = obj_recs.get(Contact.sObjectType)[3].id,
                            Type__c = 'Test Value'
                            );
            insert_rec(Affiliation__c.sObjectType,affB);



            Affiliation_Service__c asB = New Affiliation_Service__c(Affiliation__c = affB.id,
               Electronic_Service__c = servB.id);

            insert_rec(Affiliation_Service__c.sObjectType,asB);

        }
        
        test_access(Affiliation_Service__c.sObjectType,New Map<String,Map<ID,String[]>>{
            'MAX'=>New Map<ID,String[]>{orgAdmin.id=>New String[]{'Delete','Read'}}
            },obj_recs);                    
        test_access(Affiliation_Service__c.sObjectType,New Map<String,Map<ID,String[]>>{
            'MAX'=>New Map<ID,String[]>{orgAdminOther.id=>New String[]{'Read','Delete'}}
            },obj_recs);                    
    }


    private static testmethod void provider_Address_ByOwner(){
        
        
        User orgAdmin = createCustomerPortalUser(org_admin_profile,portalUserContact);
        User orgAdminOther = createCustomerPortalUser(org_admin_profile,otherPortalUserContact);


        system.runAs(orgAdmin){

            Account a1 = New Account(Name = 'Current Org Admin Account', RecordTypeID = aRT.id);
            insert_rec(Account.sObjectType, a1);

            Contact c1 = New Contact(AccountId = obj_recs.get(Account.sObjectType)[0].id,
                    FirstName = 'First',
                    LastName = 'Contact',
                    RecordTypeId = cRT.id
                    );
            insert_rec(Contact.sObjectType, c1);


            Provider_Address__c rec = New Provider_Address__c(Provider__c = obj_recs.get(Contact.sObjectType)[2].id);

            insert_rec(Provider_Address__c.sObjectType,rec);

            
            //Test object level access as max access shows delete but the user cannot delete at the object level
            DescribesObjectresult describe_result = Provider_Address__c.sObjectType.getDescribe();
            system.assertEquals(true, describe_result.isDeletable());
            system.assertEquals(true, describe_result.isUpdateable());
            system.assertEquals(true, describe_result.isAccessible());
            system.assertEquals(true, describe_result.isCreateable());

        }
        
        system.runAs(orgAdminOther){    

            Account a2 = New Account(Name = 'other Org Admin Account', RecordTypeID = aRT.id);
            insert_rec(Account.sObjectType, a2);

            Contact c2 = New Contact(AccountId = obj_recs.get(Account.sObjectType)[1].id,
                    FirstName = 'First',
                    LastName = 'Contact',
                    RecordTypeId = cRT.id
                    );
            insert_rec(Contact.sObjectType, c2);


            Provider_Address__c rec2 = New Provider_Address__c(Provider__c = obj_recs.get(Contact.sObjectType)[3].id);

            insert_rec(Provider_Address__c.sObjectType,rec2);
            
            //Create another Org and Provider
        
        }



        test_access(Provider_Address__c.sObjectType,
            New Map<String,Map<ID,String[]>>{
                'MAX'=>New Map<ID,String[]>{orgAdmin.id=>New String[]{'Delete','Read'}}
                },obj_recs);
        test_access(Provider_Address__c.sObjectType,
            New Map<String,Map<ID,String[]>>{
                'MAX'=>New Map<ID,String[]>{orgAdminOther.id=>New String[]{'Read','Delete'}}
                },obj_recs);
                            
    }

    private static testmethod void provider_Specialty_Access(){

        //Delete Acces to their own and read on others (No transfer access on child object
        
        Specialty__c sp;

        User orgAdmin = createCustomerPortalUser(org_admin_profile,portalUserContact);
        User orgAdminOther = createCustomerPortalUser(org_admin_profile,otherPortalUserContact);
        
        system.runAs(currentUser){
            sp = New Specialty__c(Name = 'Record Name');
            insert_rec(Specialty__c.sObjectType,sp);

        }
        
        system.runAs(orgAdmin){

            Account a1 = New Account(Name = 'Current Org Admin Account', RecordTypeID = aRT.id);
            insert_rec(Account.sObjectType, a1);

            Contact c1 = New Contact(AccountId = obj_recs.get(Account.sObjectType)[0].id,
                    FirstName = 'First',
                    LastName = 'Contact',
                    RecordTypeId = cRT.id
                    );
            insert_rec(Contact.sObjectType, c1);

            Provider_Specialty__c rec = New Provider_Specialty__c(Provider__c = c1.id,
               Specialty__c = sp.id);

            insert_rec(Provider_Specialty__c.sobjectType,rec);


            //Test object level access as max access shows delete but the user cannot delete at the object level
            DescribesObjectresult describe_result = Provider_Specialty__c.sObjectType.getDescribe();
            system.assertEquals(true, describe_result.isDeletable());
            system.assertEquals(true, describe_result.isUpdateable());
            system.assertEquals(true, describe_result.isAccessible());
            system.assertEquals(true, describe_result.isCreateable());

            
        }
        
        system.runAs(orgAdminOther){    

            Account a2 = New Account(Name = 'Other Org Admin Account', RecordTypeID = aRT.id);
            insert_rec(Account.sObjectType, a2);

            Contact c2 = New Contact(AccountId = obj_recs.get(Account.sObjectType)[1].id,
                    FirstName = 'Second',
                    LastName = 'Contact',
                    RecordTypeId = cRT.id
                    );
            insert_rec(Contact.sObjectType, c2);

            Provider_Specialty__c rec2 = New Provider_Specialty__c(Provider__c = c2.id,
               Specialty__c = sp.id);

            insert_rec(Provider_Specialty__c.sobjectType,rec2);
                                 
        }
        
        test_access(Provider_Specialty__c.sObjectType,New Map<String,Map<ID,String[]>>{
            'MAX'=>New Map<ID,String[]>{orgAdmin.id=>New String[]{'Delete','Read'}}
            },obj_recs);                    
        test_access(Provider_Specialty__c.sObjectType,New Map<String,Map<ID,String[]>>{
            'MAX'=>New Map<ID,String[]>{orgAdminOther.id=>New String[]{'Read','Delete'}}
            },obj_recs);                    
    }


    private static testmethod void provider_Credential_Access(){

        //Delete Acces to their own and read on others (No transfer access on child object
        
        User orgAdmin = createCustomerPortalUser(org_admin_profile,portalUserContact);
        User orgAdminOther = createCustomerPortalUser(org_admin_profile,otherPortalUserContact);
        RecordType pcRT = [Select ID From RecordType Where sObjectType = 'Provider_Credential__c' and Name = 'Certificate' LIMIT 1];

        system.runAs(orgAdmin){

            Account a1 = New Account(Name = 'Current Org Admin Account', RecordTypeID = aRT.id);
            insert_rec(Account.sObjectType, a1);

            Contact c1 = New Contact(AccountId = obj_recs.get(Account.sObjectType)[0].id,
                    FirstName = 'First',
                    LastName = 'Contact',
                    RecordTypeId = cRT.id
                    );
            insert_rec(Contact.sObjectType, c1);

            Provider_Credential__c rec = New Provider_Credential__c(Name = 'Record Name',
                Granting_Organization__c = a1.id,
               Provider__c = c1.id,
               RecordTypeID = pcRT.id);

            insert_rec(Provider_Credential__c.sObjectType,rec);

            
        }
        
        system.runAs(orgAdminOther){    

            Account a2 = New Account(Name = 'Other Org Admin Account', RecordTypeID = aRT.id);
            insert_rec(Account.sObjectType, a2);

            Contact c2 = New Contact(AccountId = obj_recs.get(Account.sObjectType)[1].id,
                    FirstName = 'Second',
                    LastName = 'Contact',
                    RecordTypeId = cRT.id
                    );
            insert_rec(Contact.sObjectType, c2);

            Provider_Credential__c rec2 = New Provider_Credential__c(Name = 'Record Name2',
                Granting_Organization__c = a2.id,
               Provider__c = c2.id,
               RecordTypeID = pcRT.id);

            insert_rec(Provider_Credential__c.sObjectType,rec2);

                                 
        }
        
        test_access(Provider_Credential__c.sObjectType,New Map<String,Map<ID,String[]>>{
            'MAX'=>New Map<ID,String[]>{orgAdmin.id=>New String[]{'Delete','Read'}}
            },obj_recs);                    
        test_access(Provider_Credential__c.sObjectType,New Map<String,Map<ID,String[]>>{
            'MAX'=>New Map<ID,String[]>{orgAdminOther.id=>New String[]{'Read','Delete'}}
            },obj_recs);                    
    }



    private static testmethod void provider_care_Team_Access(){

        //Delete Acces to their own and read on others (No transfer access on child object
        
        User orgAdmin = createCustomerPortalUser(org_admin_profile,portalUserContact);
        User orgAdminOther = createCustomerPortalUser(org_admin_profile,otherPortalUserContact);
        
        system.runAs(orgAdmin){

            Account a1 = New Account(Name = 'Current Org Admin Account', RecordTypeID = aRT.id);
            insert_rec(Account.sObjectType, a1);

            Contact c1 = New Contact(AccountId = obj_recs.get(Account.sObjectType)[0].id,
                    FirstName = 'First',
                    LastName = 'Contact',
                    RecordTypeId = cRT.id
                    );
            insert_rec(Contact.sObjectType, c1);

            Care_Team__c ct1 = New Care_Team__c(Name = 'Record Name',
                Organization__c = a1.id);

            insert_rec(Care_Team__c.sObjectType, ct1);

            Provider_Care_Team__c pct1 = New Provider_Care_Team__c(Care_Team__c = ct1.id,
               Provider__c = c1.id);

            insert_rec(Provider_Care_Team__c.sObjectType,pct1);
            
        }
        
        system.runAs(orgAdminOther){    

            Account a2 = New Account(Name = 'Other Org Admin Account', RecordTypeID = aRT.id);
            insert_rec(Account.sObjectType, a2);

            Contact c2 = New Contact(AccountId = obj_recs.get(Account.sObjectType)[1].id,
                    FirstName = 'Second',
                    LastName = 'Contact',
                    RecordTypeId = cRT.id
                    );
            insert_rec(Contact.sObjectType, c2);

            Care_Team__c ct2 = New Care_Team__c(Name = 'Record Name2',
                Organization__c = a2.id);

            insert_rec(Care_Team__c.sObjectType, ct2);

            Provider_Care_Team__c pct2 = New Provider_Care_Team__c(Care_Team__c = ct2.id,
               Provider__c = c2.id);

            insert_rec(Provider_Care_Team__c.sObjectType,pct2);
                                 
        }
        
        test_access(Provider_Care_Team__c.sObjectType,New Map<String,Map<ID,String[]>>{
            'MAX'=>New Map<ID,String[]>{orgAdmin.id=>New String[]{'Delete','Read'}}
            },obj_recs);                    
        test_access(Provider_Care_Team__c.sObjectType,New Map<String,Map<ID,String[]>>{
            'MAX'=>New Map<ID,String[]>{orgAdminOther.id=>New String[]{'Read','Delete'}}
            },obj_recs);                    
    }



    @isTest(SEEALLDATA = True)
    public static void portal_User_Access(){

        User orgAdmin = createCustomerPortalUser(org_admin_profile,portalUserContact);
        User orgAdminOther = createCustomerPortalUser(org_admin_profile,otherPortalUserContact);
        User orgAdminCreatedUser;

        
        system.runAs(orgAdmin){
            Contact orgAdminContact = New Contact(
                                            FirstName = 'Pop',
                                            LastName = 'Admin',
                                            AccountID = obj_recs.get(Account.sObjectType)[0].id,
                                            OwnerID = orgAdmin.id
                                            
                                        );
            insert_rec(Contact.sObjectType,orgAdminContact);

            Schema.DescribeSObjectResult userDescribe = User.sObjectType.getDescribe();

            system.assertEquals(true,userDescribe.isCreateable());
            

            try{
                orgAdminCreatedUser = createCustomerPortalUser('Customer Portal Manager Custom',(Contact)obj_recs.get(Contact.sObjectType)[2]);
                system.assertEquals(true,false,'This profile should not have been able to create a user');
            }catch(exception e){
                system.assertEquals(true,e.getMessage().contains(System.Label.SL_UnauthorizedCreationError));
            }
            

            
        }


        system.runAs(CURRENTUSER){
            Contact c = New Contact(                             
                                    FirstName = 'Org Admin2', 
                                    LastName = 'Contact', 
                                    AccountID = portalUserAccount.id
                                );
            insert_rec(Contact.sObjectType,c);

            orgAdminCreatedUser = createCustomerPortalUser(org_admin_profile,c);

        }

        system.runAs(orgAdmin){
            system.resetPassword(orgAdminCreatedUser.id,false);
        }

    }

    private static void test_access(sObjectType objType, Map<String,Map<ID,String[]>> accessTypeToResults, Map<Schema.sObjectType,sobject[]> objs){
    
        //Currently assumes ALL records have been inserted and have IDs
        //Also, MUST pass in Max Access Level
        Map<ID,UserRecordAccess> recToURA;
        ID[] tmp;
        
        //For each user being tested
        for(ID userID : accessTypeToResults.get('MAX').keySet()){
            //Clear variables
            recToURA = New Map<ID,UserRecordAccess>();
            tmp = New id[]{};
            for(sObject o : objs.get(objType))
            tmp.add(o.id);
            
            //Get list of records created and access level for current context user
            for(UserRecordAccess ura: [Select RecordID, MaxAccessLevel, hasReadAccess, hasEditAccess, hasDeleteAccess From UserRecordAccess Where UserID = : userID 
                                        AND Recordid IN :tmp]){
                                                        
                recToURA.put(ura.recordID,ura);
            }
    
            //Get list of records created
            sObject[] createdRecords = objs.get(objType);
            
            
            //For each record test max access. The desired results should be in the same index as the order the records were created
            for(String levelToTest : accessTypeToResults.keySet()){

                //If the list of desired results are not the same size as the records created, throw an assertion error with a meaningful message
                if(accessTypeToResults.get(levelToTest).get(userID).size() < createdRecords.size())
                    system.assertEquals('','There were more records created than desired results passed into the method');
                else if(accessTypeToResults.get(levelToTest).get(userID).size() > createdRecords.size())
                    system.assertEquals('','There were less records created than desired results passed into the method');

                for(integer x=0;x<accessTypeToResults.get(levelToTest).get(userID).size();x++){    
                    if(levelToTest == 'MAX')
                        system.assertEquals(accessTypeToResults.get(levelToTest).get(userID)[x], 
                                        recToURA.get(objs.get(objType)[x].id).MaxAccessLevel);             
                    else if(levelToTest == 'EDIT')
                        system.assertEquals(boolean.valueOf(accessTypeToResults.get(levelToTest).get(userID)[x]), 
                                        recToURA.get(objs.get(objType)[x].id).hasEditAccess);             
                    else if(levelToTest == 'READ')
                        system.assertEquals(boolean.valueOf(accessTypeToResults.get(levelToTest).get(userID)[x]), 
                                        recToURA.get(objs.get(objType)[x].id).hasReadAccess);             
                    else if(levelToTest == 'DELETE')
                        system.assertEquals(boolean.valueOf(accessTypeToResults.get(levelToTest).get(userID)[x]), 
                                        recToURA.get(objs.get(objType)[x].id).hasDeleteAccess);             

                }
            }
        }    

    
    }
    

    private static User createCustomerPortalUser(String profileName, Contact c){
        
            Profile[] p = [Select ID, Name from Profile Where Name = :profileName];


            user u = New User(
                UserName = 'test_' + math.random() + '@test.com',
                FirstName = c.FirstName,
                LastName = c.LastName,
                Alias = string.valueof(c.FirstName.substring(0,1) + c.LastName.substring(0,1)),
                email = 'test' + math.random() + '@test.com',
                CommunityNickName = string.valueOf(math.random()).substring(0,6),
                ProfileID = p[0].id,
                ContactID = c.id,
                TimeZoneSidKey = 'America/New_York', 
                LocaleSidKey = 'en_US', 
                EmailEncodingKey = 'UTF-8', 
                LanguageLocaleKey = 'en_US'
                
                
                );
                    
            insert u;
            return u;        
        }   

*/

}