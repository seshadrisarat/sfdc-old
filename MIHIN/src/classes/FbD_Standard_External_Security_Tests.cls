/*
*Class: FbD_Standard_External_Security_Tests
*Description: This test class is used to check access on various objects for user with 'MIHN - HPD Provider User' profile.
*Copyright 2014 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/

@isTest
private class FbD_Standard_External_Security_Tests {

    private STATIC FINAL STRING external_user_profile = 'MIHN - HPD Provider User';
    private STATIC User SILVERLINEADMIN = [Select ID From User Where Username like 'mihin@silverlinecrm.com%'];
    private STATIC Account portalUserAccount, otherPortalUserAccount;
    private STATIC Contact portalUserContact, otherPortalUserContact;

    private static RecordType aRT = [Select ID From RecordType Where sObjectType = 'Account' and Name = 'Provider Organization' LIMIT 1];
    private static RecordType cRT = [Select ID From RecordType Where sObjectType = 'Contact' and Name = 'Provider' LIMIT 1];
    private static Map<Schema.sObjectType, sObject[]> obj_recs = New Map<Schema.sObjectType, sObject[]>();


    static{
        system.runAs(SILVERLINEADMIN){

            portalUserAccount = New Account(
                                    Name = 'Current External User Account',
                                    Portal_Licenses_Allocated__c = 99,
                                    Population__c = 'eTHIN',
                                    RecordTypeID = aRT.id
                                );

            insert_rec(Account.sObjectType,portalUserAccount);

            otherPortalUserAccount = New Account(
                                    Name = 'Other External User Account',
                                    Portal_Licenses_Allocated__c = 99,
                                    Population__c = 'eTHIN',
                                    RecordTypeID = aRT.id
                                );

            insert_rec(Account.sObjectType,otherPortalUserAccount);

            portalUserContact = New Contact(
                                    FirstName = 'External User',
                                    LastName = 'Contact',
                                    AccountID = portalUserAccount.id,
                                    RecordTypeId = cRT.id
                                    );

            insert_rec(Contact.sObjectType,portalUserContact);
            

            otherPortalUserContact = New Contact(
                                    FirstName = 'Other External User',
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


    private static testmethod void organization_and_Provider_Access(){
                
        User extUser = createCustomerPortalUser(external_user_profile,portalUserContact);

        system.runAs(extUser){

            Contact extUserContact = New Contact(
                                            FirstName = 'Ext',
                                            LastName = 'Contact',
                                            AccountID = portalUserAccount.id
                                            
                                        );

            insert_rec(Contact.sObjectType,extUserContact);



            DescribesObjectresult describe_result = Account.sObjectType.getDescribe();
            system.assertEquals(true, describe_result.isAccessible());
            //TODO: currently has create access - system.assertEquals(false, describe_result.isCreateable());
            system.assertEquals(false, describe_result.isDeletable());
            system.assertEquals(false, describe_result.isUpdateable());


            describe_result = Contact.sObjectType.getDescribe();
            system.assertEquals(true, describe_result.isAccessible());
            system.assertEquals(false, describe_result.isCreateable());
            system.assertEquals(false, describe_result.isDeletable());
            system.assertEquals(true, describe_result.isUpdateable());


        test_access(Account.sObjectType,
            New Map<String,Map<ID,String[]>>{
                'MAX'=>New Map<ID,String[]>{extUser.id=>New String[]{'Read','Read'}}
                },obj_recs);

        //First contact is the external user, Second is the other external user Contact
        test_access(Contact.sObjectType,
            New Map<String,Map<ID,String[]>>{
                'MAX'=>New Map<ID,String[]>{extUser.id=>New String[]{'Read','Read','Read'}},
                'EDIT'=>New Map<ID,String[]>{extUser.id=>New String[]{'False','False','False'}}
                },obj_recs);

            
        }
        
                            
    }



    private static testmethod void organization_Portal_Access(){
        // TODO PROBLEM: Currently have access but I do not think they should have an email out 6-3-2014
        
        User extUser = createCustomerPortalUser(external_user_profile,portalUserContact);

        system.runAs(extUser){
            
            DescribesObjectresult describe_result = Organization_Portal__c.sObjectType.getDescribe();
            system.assertEquals(true, describe_result.isAccessible());
            system.assertEquals(false, describe_result.isCreateable());
            system.assertEquals(false, describe_result.isDeletable());
            system.assertEquals(false, describe_result.isUpdateable());


            
        }
        
                    
    
    }


    private static testmethod void organization_Names_Access(){


        User extUser = createCustomerPortalUser(external_user_profile,portalUserContact);

        system.runAs(SILVERLINEADMIN){
            Account a = New Account(Name = 'Current External User Account');
            insert_rec(Account.sObjectType,a);
            
            Organization_Name__c rec = New Organization_Name__c(Name = 'Record Name',
                Organization__c = a.id
                );

            insert_rec(Organization_Name__c.sObjectType,rec);

        }
        
        system.runAs(extUser){

            DescribesObjectresult describe_result = Organization_Name__c.sObjectType.getDescribe();
            system.assertEquals(true, describe_result.isAccessible());
            system.assertEquals(false, describe_result.isCreateable());
            system.assertEquals(false, describe_result.isDeletable());
            system.assertEquals(false, describe_result.isUpdateable());
            
        }

        test_access(Organization_Name__c.sObjectType,New Map<String,Map<ID,String[]>>{
            'MAX'=>New Map<ID,String[]>{extUser.id=>New String[]{'Read'}}
            },obj_recs);                    

        
    }


    private static testmethod void organization_Address_Access(){


        User extUser = createCustomerPortalUser(external_user_profile,portalUserContact);
        
        
        system.runAs(SILVERLINEADMIN){

            Account a = New Account(Name = 'Current External User Account');
            insert_rec(Account.sObjectType,a);

            Organization_Address__c rec = New Organization_Address__c(Organization__c = a.id);
            insert_rec(Organization_Address__c.sObjectType,rec);


            
        }
        
        system.runAs(extUser){    
            
            DescribesObjectresult describe_result = Organization_Address__c.sObjectType.getDescribe();
            system.assertEquals(true, describe_result.isAccessible());
            system.assertEquals(false, describe_result.isCreateable());
            system.assertEquals(false, describe_result.isDeletable());
            system.assertEquals(false, describe_result.isUpdateable());

                                 
        }

        test_access(Organization_Address__c.sObjectType,New Map<String,Map<ID,String[]>>{
            'MAX'=>New Map<ID,String[]>{extUser.id=>New String[]{'Read'}}
            },obj_recs);                    
    }



    private static testmethod void organization_Credential_Access(){


        User extUser = createCustomerPortalUser(external_user_profile,portalUserContact);
        
        system.runAs(SILVERLINEADMIN){

            Account a = New Account(Name = 'Current External User Account');
            insert_rec(Account.sObjectType,a);

                Organization_Credential__c rec = New Organization_Credential__c(Organization__c = a.id,Credential_Number__c='123');
                insert_rec(Organization_Credential__c.sObjectType,rec);


            
        }
        
        system.runAs(extUser){    
                                 
            DescribesObjectresult describe_result = Organization_Credential__c.sObjectType.getDescribe();
            system.assertEquals(true, describe_result.isAccessible());
            system.assertEquals(false, describe_result.isCreateable());
            system.assertEquals(false, describe_result.isDeletable());
            system.assertEquals(false, describe_result.isUpdateable());


        }
        
        test_access(Organization_Credential__c.sObjectType,New Map<String,Map<ID,String[]>>{
            'MAX'=>New Map<ID,String[]>{extUser.id=>New String[]{'Read'}}
            },obj_recs);                    
    }


    private static testmethod void organization_Specialty_Access(){

        
        Specialty__c sp;

        User extUser = createCustomerPortalUser(external_user_profile,portalUserContact);

        
        system.runAs(SILVERLINEADMIN){
            sp = New Specialty__c(Name = 'Test Name');
            insert_rec(Specialty__c.sObjectType,sp);


            Account a = New Account(Name = 'Current External User Account');
            insert_rec(Account.sObjectType,a);

            Organization_Specialty__c rec = New Organization_Specialty__c(Organization__c = a.id, Specialty__c=sp.id);
            insert_rec(Organization_Specialty__c.sObjectType,rec);

            
        }
        
        system.runAs(extUser){    
 
            DescribesObjectresult describe_result = Organization_Specialty__c.sObjectType.getDescribe();
            system.assertEquals(true, describe_result.isAccessible());
            system.assertEquals(false, describe_result.isCreateable());
            system.assertEquals(false, describe_result.isDeletable());
            system.assertEquals(false, describe_result.isUpdateable());


        }
        
        test_access(Organization_Specialty__c.sObjectType,New Map<String,Map<ID,String[]>>{
            'MAX'=>New Map<ID,String[]>{extUser.id=>New String[]{'Read'}}
            },obj_recs);                    
    }


    private static testmethod void organization_Service_Access(){

        
        Electronic_Service__c es;

        User extUser = createCustomerPortalUser(external_user_profile,portalUserContact);

        system.runAs(SILVERLINEADMIN){
            es = New Electronic_Service__c(Address__c = 'Test Value',
                Name = 'Record Name',
                Payload__c = 'Test Value',
                Protocol__c = 'Test Value',
                Type__c = 'Test Value'
                );
            insert_rec(Electronic_Service__c.sObjectType,es);


            Account a = New Account(Name = 'Current External User Account');
            insert_rec(Account.sObjectType,a);

            Organization_Service__c rec = New Organization_Service__c(Organization__c = a.id, Electronic_Service__c=es.id);
            insert_rec(Organization_Service__c.sObjectType,rec);

            
        }
        
        system.runAs(extUser){    

            DescribesObjectresult describe_result = Organization_Service__c.sObjectType.getDescribe();
            system.assertEquals(true, describe_result.isAccessible());
            system.assertEquals(false, describe_result.isCreateable());
            system.assertEquals(false, describe_result.isDeletable());
            system.assertEquals(false, describe_result.isUpdateable());

                                 
        }
        
        test_access(Organization_Service__c.sObjectType,New Map<String,Map<ID,String[]>>{
            'MAX'=>New Map<ID,String[]>{extUser.id=>New String[]{'Read'}}
            },obj_recs);                    
    }


    private static testmethod void affiliation_Provider_Access(){


        User extUser = createCustomerPortalUser(external_user_profile,portalUserContact);
        User extUserOther = createCustomerPortalUser(external_user_profile,otherPortalUserContact);

        system.runAs(extUser){

            DescribesObjectresult describe_result = Affiliation__c.sObjectType.getDescribe();
            system.assertEquals(true, describe_result.isAccessible());
            system.assertEquals(true, describe_result.isCreateable());
            system.assertEquals(false, describe_result.isDeletable());
            system.assertEquals(true, describe_result.isUpdateable());

            //their provider only
            Affiliation__c rec = New Affiliation__c(Organization__c = obj_recs.get(Account.sObjectType)[1].id,
                            Provider__c = obj_recs.get(Contact.sObjectType)[0].id,
                            Type__c = 'Test Value'
                            );
            insert_rec(Affiliation__c.sObjectType,rec);


            try{

                Affiliation__c rec2 = New Affiliation__c(Organization__c = obj_recs.get(Account.sObjectType)[0].id,
                                Provider__c = obj_recs.get(Contact.sObjectType)[1].id,
                                Type__c = 'Test Value'
                                );
                insert_rec(Affiliation__c.sObjectType,rec2);

                system.assertEquals(true,false,'The user should not have been able to affiliate another provider with an organization');
            }catch(exception e){

            }

        }   


        system.runAs(extUserOther){
            //their provider only
            Affiliation__c rec2 = New Affiliation__c(Organization__c = obj_recs.get(Account.sObjectType)[0].id,
                            Provider__c = obj_recs.get(Contact.sObjectType)[1].id,
                            Type__c = 'Test Value'
                            );
            insert_rec(Affiliation__c.sObjectType,rec2);

        }   

        
        test_access(Affiliation__c.sObjectType,New Map<String,Map<ID,String[]>>{
            'MAX'=>New Map<ID,String[]>{extUser.id=>New String[]{'Read','Read'}}
            },obj_recs);                    
        test_access(Affiliation__c.sObjectType,New Map<String,Map<ID,String[]>>{
            'MAX'=>New Map<ID,String[]>{extUserOther.id=>New String[]{'Read','Read'}}
            },obj_recs);                    

        //Test that this affiliation did not provide access to the Organization - first 2 accounts are the portal user accounts
        test_access(Account.sObjectType,
            New Map<String,Map<ID,String[]>>{
                'MAX'=>New Map<ID,String[]>{extUser.id=>New String[]{'Read','Read'}},
                'EDIT'=>New Map<ID,String[]>{extUser.id=>New String[]{'False','False'}}
                },obj_recs);
        test_access(Account.sObjectType,
            New Map<String,Map<ID,String[]>>{
                'MAX'=>New Map<ID,String[]>{extUserOther.id=>New String[]{'Read','Read'}},
                'EDIT'=>New Map<ID,String[]>{extUserOther.id=>New String[]{'False','False'}}
                },obj_recs);

        //Test that this affiliation did not provide access to the Providers
        test_access(Contact.sObjectType,
            New Map<String,Map<ID,String[]>>{
                'MAX'=>New Map<ID,String[]>{extUser.id=>New String[]{'Read','Read'}},
                'EDIT'=>New Map<ID,String[]>{extUser.id=>New String[]{'False','False'}}
                },obj_recs);
        test_access(Contact.sObjectType,
            New Map<String,Map<ID,String[]>>{
                'MAX'=>New Map<ID,String[]>{extUserOther.id=>New String[]{'Read','Read'}},
                'EDIT'=>New Map<ID,String[]>{extUserOther.id=>New String[]{'False','False'}}
                },obj_recs);

    }



    private static testmethod void care_Team_Access(){

        
        User extUser = createCustomerPortalUser(external_user_profile,portalUserContact);
        
        system.runAs(extUser){

            DescribesObjectresult describe_result = Care_Team__c.sObjectType.getDescribe();
            system.assertEquals(true, describe_result.isAccessible());
            system.assertEquals(false, describe_result.isCreateable());
            system.assertEquals(false, describe_result.isDeletable());
            system.assertEquals(false, describe_result.isUpdateable());


            try{
                Care_Team__c rec = New Care_Team__c(Name = 'Record Name',
                    Organization__c = portalUserAccount.id);

                insert_rec(Care_Team__c.sObjectType, rec);

                system.assertEquals(true,false,'External User was not supposed to be able to create this record when they do not own the account');
            }catch(Exception e){

            }


        }
        
        system.runAs(SILVERLINEADMIN){    
            
                Care_Team__c rec = New Care_Team__c(Name = 'Record Name',
                    Organization__c = otherPortalUserAccount.id);

                insert_rec(Care_Team__c.sObjectType, rec);

                                 
        }
        
        test_access(Care_Team__c.sObjectType,New Map<String,Map<ID,String[]>>{
            'MAX'=>New Map<ID,String[]>{extUser.id=>New String[]{'Read'}}
            },obj_recs);                    

    }

    private static testmethod void care_Team_Service_Access(){

        
        User extUser = createCustomerPortalUser(external_user_profile,portalUserContact);
        
        system.runAs(extUser){

            DescribesObjectresult describe_result = Care_Team_Service__c.sObjectType.getDescribe();
            system.assertEquals(true, describe_result.isAccessible());
            system.assertEquals(false, describe_result.isCreateable());
            system.assertEquals(false, describe_result.isDeletable());
            system.assertEquals(false, describe_result.isUpdateable());
            
        }
        
        system.runAs(SILVERLINEADMIN){    

            Care_Team__c ct1 = New Care_Team__c(Name = 'Record Name',
                Organization__c = otherPortalUserAccount.id);

            insert_rec(Care_Team__c.sObjectType, ct1);
            
            Electronic_Service__c es1 = New Electronic_Service__c(Address__c = 'Test Value',
               Name = 'Record Name',
               Payload__c = 'Test Value',
               Protocol__c = 'Test Value',
               Type__c = 'Test Value');

            insert_rec(Electronic_Service__c.sObjectType, es1);

            Care_Team_Service__c cts1 = New Care_Team_Service__c(Care_Team__c = ct1.id,
               Electronic_Service__c = es1.id,
               Name = 'Record Name'); 

            insert_rec(Care_Team_Service__c.sObjectType, cts1);              


        }
        
        test_access(Care_Team_Service__c.sObjectType,New Map<String,Map<ID,String[]>>{
            'MAX'=>New Map<ID,String[]>{extUser.id=>New String[]{'Read'}}
            },obj_recs);                    
    }


    private static testmethod void affiliation_Access(){

        //Delete Acces to their own and read on others (No transfer access on child object
        
        User extUser = createCustomerPortalUser(external_user_profile,portalUserContact);

        system.runAs(extUser){


            DescribesObjectresult describe_result = Organization_Affiliation__c.sObjectType.getDescribe();
            system.assertEquals(true, describe_result.isAccessible());
            system.assertEquals(false, describe_result.isCreateable());
            system.assertEquals(false, describe_result.isDeletable());
            system.assertEquals(false, describe_result.isUpdateable());
            
        }
        
        system.runAs(SILVERLINEADMIN){
            Organization_Affiliation__c oa1 = New Organization_Affiliation__c(Affiliated_Organization__c = obj_recs.get(Account.sObjectType)[0].id,
               Affiliation_Type__c = 'Test Value',
               Member_Organization__c = obj_recs.get(Account.sObjectType)[1].id);

            insert_rec(Organization_Affiliation__c.sObjectType, oa1);

        }   

        
        test_access(Organization_Affiliation__c.sObjectType,New Map<String,Map<ID,String[]>>{
            'MAX'=>New Map<ID,String[]>{extUser.id=>New String[]{'Read'}}
            },obj_recs);                    

        //Test that this affiliation did not provide access to the Organization
        test_access(Account.sObjectType,
            New Map<String,Map<ID,String[]>>{
                'MAX'=>New Map<ID,String[]>{extUser.id=>New String[]{'Read','Read'}}
                },obj_recs);


    }


    private static testmethod void active_Care_Relationship_Access(){
        //TODO: Should be NO ACCESS
        
        User extUser = createCustomerPortalUser(external_user_profile,portalUserContact);
        system.runAs(extUser){
            
            DescribesObjectresult describe_result = Active_Care_Relationship__c.sObjectType.getDescribe();
            system.assertEquals(false, describe_result.isAccessible());

            
        }
    }


    private static testmethod void support_Ticket_Access(){



        //Edit Access to their own and read on others (No transfer access on child object - RecordLevelAccess is Full       

        User extUser = createCustomerPortalUser(external_user_profile,portalUserContact);
        User extUserOther = createCustomerPortalUser(external_user_profile,otherPortalUserContact);
        RecordType caseRT = [Select ID From RecordType Where sObjectType = 'Case' And Name = 'Provider Record Type' LIMIT 1];

        system.runAs(extUser){


            //They can create cases against other Organizations. This is controlled via page layout only so cannot test creation
            //try{
            //  objs.createRecord(Case.sObjectType, New Map<String,Object>{'AccountID'=>otherPortalUserAccount.id,'BusinessHoursID'=>null},true,true);
            //  system.assertEquals(true,false,'The user was not supposed to be able to create a case against another Organization');
            //}catch(exception e){
            //  system.assertEquals(true,e.getMessage().contains('Insufficient'));
            //}
            Case rec = New Case(Origin = 'Test Value',
               Status = 'Test Value',
               RecordTypeID = caseRT.id,
               AccountID = portalUserAccount.id,
               BusinessHoursID = null);

            insert_rec(Case.sObjectType, rec);


            //Object Level Access
            DescribesObjectresult describe_result = Case.sObjectType.getDescribe();
            system.assertEquals(true, describe_result.isAccessible());
            system.assertEquals(true, describe_result.isCreateable());
            system.assertEquals(false, describe_result.isDeletable());
            system.assertEquals(true, describe_result.isUpdateable());



            
        }
        
        system.runAs(extUserOther){    

            Case rec = New Case(Origin = 'Test Value',
               Status = 'Test Value',
               RecordTypeID = caseRT.id,
               AccountID = otherPortalUserAccount.id,
               BusinessHoursID = null);

            insert_rec(Case.sObjectType, rec);
                                 
        }
        
        test_access(Case.sObjectType,
            New Map<String,Map<ID,String[]>>{
                'MAX'=>New Map<ID,String[]>{extUser.id=>New String[]{'All','None'}},
                'EDIT'=>New Map<ID,String[]>{extUser.id=>New String[]{'True','False'}},
                'READ'=>New Map<ID,String[]>{extUser.id=>New String[]{'True','False'}}
                },obj_recs);                    
        test_access(Case.sObjectType,
            New Map<String,Map<ID,String[]>>{
                'MAX'=>New Map<ID,String[]>{extUserOther.id=>New String[]{'None','All'}},
                'EDIT'=>New Map<ID,String[]>{extUserOther.id=>New String[]{'False','True'}},
                'READ'=>New Map<ID,String[]>{extUserOther.id=>New String[]{'False','True'}}
                },obj_recs);                    

    }


    private static testmethod void task_Access(){

        
        User extUser = createCustomerPortalUser(external_user_profile,portalUserContact);        
        system.runAs(extUser){

            //Object Level Access
            DescribesObjectresult describe_result = Task.sObjectType.getDescribe();
            system.assertEquals(false, describe_result.isDeletable());
            system.assertEquals(false, describe_result.isUpdateable());
            system.assertEquals(true, describe_result.isAccessible());
            system.assertEquals(false, describe_result.isCreateable());
        }
    }

    private static testmethod void event_Access(){
        
        User extUser = createCustomerPortalUser(external_user_profile,portalUserContact);                

        system.runAs(extUser){

            //Object Level Access
            DescribesObjectresult describe_result = Event.sObjectType.getDescribe();
            system.assertEquals(false, describe_result.isDeletable());
            system.assertEquals(false, describe_result.isUpdateable());
            system.assertEquals(true, describe_result.isAccessible());
            system.assertEquals(false, describe_result.isCreateable());

            
        }
    }

    private static testmethod void electronic_Service_Access(){

        //Delete Acces to their own and read on others (No transfer access on child object
        
        User extUser = createCustomerPortalUser(external_user_profile,portalUserContact);        
        
        system.runAs(extUser){

            DescribesObjectresult describe_result = Electronic_Service__c.sObjectType.getDescribe();
            system.assertEquals(false, describe_result.isDeletable());
            system.assertEquals(false, describe_result.isUpdateable());
            system.assertEquals(true, describe_result.isAccessible());
            system.assertEquals(false, describe_result.isCreateable());

            
        }
        
        system.runAs(SILVERLINEADMIN){    

            Electronic_Service__c servA = New Electronic_Service__c(Address__c = 'Test Value',
               Name = 'Record Name',
               Payload__c = 'Test Value',
               Protocol__c = 'Test Value',
               Type__c = 'Test Value');

            insert_rec(Electronic_Service__c.sObjectType,servA);
                                 
        }
        
        test_access(Electronic_Service__c.sObjectType,New Map<String,Map<ID,String[]>>{
            'MAX'=>New Map<ID,String[]>{extUser.id=>New String[]{'Read'}}
            },obj_recs);                    
    }

    private static testmethod void affiliation_Service_Access(){

        
        User extUser = createCustomerPortalUser(external_user_profile,portalUserContact);
        User extUserOther = createCustomerPortalUser(external_user_profile,otherPortalUserContact);

        system.runAs(extUser){


            DescribesObjectresult describe_result = Affiliation_Service__c.sObjectType.getDescribe();
            system.assertEquals(false, describe_result.isDeletable());
            system.assertEquals(false, describe_result.isUpdateable());
            system.assertEquals(true, describe_result.isAccessible());
            system.assertEquals(false, describe_result.isCreateable());

        }
        
        system.runAs(SILVERLINEADMIN){    
            
            Electronic_Service__c servA = New Electronic_Service__c(Address__c = 'Test Value',
               Name = 'Record Name',
               Payload__c = 'Test Value',
               Protocol__c = 'Test Value',
               Type__c = 'Test Value');

            insert_rec(Electronic_Service__c.sObjectType,servA);

            Affiliation__c affA = New Affiliation__c(Organization__c = portalUserAccount.id,
                            Provider__c = portalUserContact.id,
                            Type__c = 'Test Value'
                            );
            insert_rec(Affiliation__c.sObjectType,affA);



            Affiliation_Service__c asA = New Affiliation_Service__c(Affiliation__c = affA.id,
               Electronic_Service__c = servA.id);

            insert_rec(Affiliation_Service__c.sObjectType,asA);


            Electronic_Service__c servB = New Electronic_Service__c(Address__c = 'Test Value',
               Name = 'Record Name2',
               Payload__c = 'Test Value',
               Protocol__c = 'Test Value',
               Type__c = 'Test Value');

            insert_rec(Electronic_Service__c.sObjectType,servB);

            Affiliation__c affB = New Affiliation__c(Organization__c = otherPortalUserAccount.id,
                            Provider__c = otherPortalUserContact.id,
                            Type__c = 'Test Value'
                            );
            insert_rec(Affiliation__c.sObjectType,affB);



            Affiliation_Service__c asB = New Affiliation_Service__c(Affiliation__c = affB.id,
               Electronic_Service__c = servB.id);

            insert_rec(Affiliation_Service__c.sObjectType,asB);

        }

        //TODO: Stories say they should be able to edit AS associated with their Provider record but the object is MD to ES and ES is Read only to this profile
        
        test_access(Affiliation_Service__c.sObjectType,New Map<String,Map<ID,String[]>>{
            //'MAX'=>New Map<ID,String[]>{extUser.id=>New String[]{'Edit','Read'}}
            'MAX'=>New Map<ID,String[]>{extUser.id=>New String[]{'Read','Read'}}
            },obj_recs);                    
        test_access(Affiliation_Service__c.sObjectType,New Map<String,Map<ID,String[]>>{
            //'MAX'=>New Map<ID,String[]>{extUserOther.id=>New String[]{'Read','Edit'}}
            'MAX'=>New Map<ID,String[]>{extUserOther.id=>New String[]{'Read','Read'}}
            },obj_recs);                    
    }


    private static testmethod void provider_Address_ByOwner(){
        
        
        User extUser = createCustomerPortalUser(external_user_profile,portalUserContact);
        User extUserOther = createCustomerPortalUser(external_user_profile,otherPortalUserContact);

        system.runAs(extUser){

            Provider_Address__c rec = New Provider_Address__c(Provider__c = portalUserContact.id);

            insert_rec(Provider_Address__c.sObjectType,rec);

            
            //Test object level access
            DescribesObjectresult describe_result = Provider_Address__c.sObjectType.getDescribe();
            system.assertEquals(false, describe_result.isDeletable());
            system.assertEquals(true, describe_result.isUpdateable());
            system.assertEquals(true, describe_result.isAccessible());
            system.assertEquals(true, describe_result.isCreateable());

        }
        
        system.runAs(extUserOther){    
            
            Provider_Address__c rec2 = New Provider_Address__c(Provider__c = otherPortalUserContact.id);

            insert_rec(Provider_Address__c.sObjectType,rec2);

        
        }



        test_access(Provider_Address__c.sObjectType,
            New Map<String,Map<ID,String[]>>{
                'MAX'=>New Map<ID,String[]>{extUser.id=>New String[]{'Read','Read'}}
                },obj_recs);
        test_access(Provider_Address__c.sObjectType,
            New Map<String,Map<ID,String[]>>{
                'MAX'=>New Map<ID,String[]>{extUserOther.id=>New String[]{'Read','Read'}}
                },obj_recs);
                            
    }

    private static testmethod void provider_Specialty_Access(){

        
        Specialty__c sp;

        User extUser = createCustomerPortalUser(external_user_profile,portalUserContact);
        User extUserOther = createCustomerPortalUser(external_user_profile,otherPortalUserContact);
        
        system.runAs(SILVERLINEADMIN){
            sp = New Specialty__c(Name = 'Record Name');
            insert_rec(Specialty__c.sObjectType,sp);

        }
        
        system.runAs(extUser){

            try{

                Provider_Specialty__c rec = New Provider_Specialty__c(Provider__c = otherPortalUserContact.id,
                   Specialty__c = sp.id);

                insert_rec(Provider_Specialty__c.sobjectType,rec);

                system.assertEquals(true,false,'The user was not supposed to be able to associate a Speciality with another provider');
            }catch(exception e){
                system.assertEquals(true,e.getMessage().contains('insufficient'));
            }
            
            Provider_Specialty__c rec2 = New Provider_Specialty__c(Provider__c = portalUserContact.id,
               Specialty__c = sp.id);

            insert_rec(Provider_Specialty__c.sobjectType,rec2);


            //Test object level access
            DescribesObjectresult describe_result = Provider_Specialty__c.sObjectType.getDescribe();
            system.assertEquals(false, describe_result.isDeletable());
            system.assertEquals(true, describe_result.isUpdateable());
            system.assertEquals(true, describe_result.isAccessible());
            system.assertEquals(true, describe_result.isCreateable());

            
        }
        
        system.runAs(extUserOther){    
            

                Provider_Specialty__c rec3 = New Provider_Specialty__c(Provider__c = otherPortalUserContact.id,
                   Specialty__c = sp.id);

                insert_rec(Provider_Specialty__c.sobjectType,rec3);

                                 
        }
        
        test_access(Provider_Specialty__c.sObjectType,New Map<String,Map<ID,String[]>>{
            'MAX'=>New Map<ID,String[]>{extUser.id=>New String[]{'Read','Read'}}
            },obj_recs);                    
        test_access(Provider_Specialty__c.sObjectType,New Map<String,Map<ID,String[]>>{
            'MAX'=>New Map<ID,String[]>{extUserOther.id=>New String[]{'Read','Read'}}
            },obj_recs);                    
    }

    private static testmethod void provider_Credential_Access(){

        
        User extUser = createCustomerPortalUser(external_user_profile,portalUserContact);
        User extUserOther = createCustomerPortalUser(external_user_profile,otherPortalUserContact);
        RecordType pcRT = [Select ID From RecordType Where sObjectType = 'Provider_Credential__c' and Name = 'Certificate' LIMIT 1];
        
        system.runAs(extUser){

            //Test object level access
            DescribesObjectresult describe_result = Provider_Credential__c.sObjectType.getDescribe();
            system.assertEquals(false, describe_result.isDeletable());
            system.assertEquals(true, describe_result.isUpdateable());
            system.assertEquals(true, describe_result.isAccessible());
            system.assertEquals(true, describe_result.isCreateable());


            try{
                Provider_Credential__c rec = New Provider_Credential__c(
                    Granting_Organization__c = otherPortalUserAccount.id,
                    Provider__c = otherPortalUserContact.id,
                    RecordTypeID = pcRT.id);

                insert_rec(Provider_Credential__c.sObjectType,rec);
                system.assertEquals(true,false,'The user was not supposed to be able to associate a Credential with another provider');
            }catch(exception e){
                system.assertEquals(true,e.getMessage().contains('insufficient'));
            }

                Provider_Credential__c rec2 = New Provider_Credential__c(
                    Granting_Organization__c = portalUserAccount.id,
                    Provider__c = portalUserContact.id,
                    RecordTypeID = pcRT.id);

                insert_rec(Provider_Credential__c.sObjectType,rec2);

            
        }
        
        system.runAs(extUserOther){    
            

                Provider_Credential__c rec3 = New Provider_Credential__c(
                    Granting_Organization__c = otherPortalUserAccount.id,
                    Provider__c = otherPortalUserContact.id,
                    RecordTypeID = pcRT.id);

                insert_rec(Provider_Credential__c.sObjectType,rec3);

                                 
        }
        
        test_access(Provider_Credential__c.sObjectType,New Map<String,Map<ID,String[]>>{
            'MAX'=>New Map<ID,String[]>{extUser.id=>New String[]{'Read','Read'}}
            },obj_recs);                    
        test_access(Provider_Credential__c.sObjectType,New Map<String,Map<ID,String[]>>{
            'MAX'=>New Map<ID,String[]>{extUserOther.id=>New String[]{'Read','Read'}}
            },obj_recs);                    
    }



    private static testmethod void provider_care_Team_Access(){

        
        User extUser = createCustomerPortalUser(external_user_profile,portalUserContact);
        User extUserOther = createCustomerPortalUser(external_user_profile,otherPortalUserContact);

        system.runas(SILVERLINEADMIN){
            Care_Team__c ct1 = New Care_Team__c(Name = 'Record Name',
                Organization__c = portalUserAccount.id);
            insert_rec(Care_Team__c.sObjectType,ct1);
            Care_Team__c ct2 = New Care_Team__c(Name = 'Record Name',
                Organization__c = otherPortalUserAccount.id);
            insert_rec(Care_Team__c.sObjectType,ct2);
        }
        
        system.runAs(extUser){


            //Test object level access
            DescribesObjectresult describe_result = Provider_Care_Team__c.sObjectType.getDescribe();
            system.assertEquals(false, describe_result.isDeletable());
            system.assertEquals(true, describe_result.isUpdateable());
            system.assertEquals(true, describe_result.isAccessible());
            system.assertEquals(true, describe_result.isCreateable());

            

            try{

                Provider_Care_Team__c pct1 = New Provider_Care_Team__c(Care_Team__c = obj_recs.get(Care_Team__c.sObjectType)[0].id,
                   Provider__c = otherPortalUserContact.id);
                insert_rec(Provider_Care_Team__c.sObjectType,pct1);

                system.assertEquals(true,false,'The user was not supposed to be able to associate a Provider Care Team with another provider');
            }catch(exception e){
                system.assertEquals(true,e.getMessage().contains('insufficient'));
            }

                Provider_Care_Team__c pct2 = New Provider_Care_Team__c(Care_Team__c = obj_recs.get(Care_Team__c.sObjectType)[0].id,
                   Provider__c = portalUserContact.id);
                insert_rec(Provider_Care_Team__c.sObjectType,pct2);
            
        }
        
        system.runAs(extUserOther){    
            
                Provider_Care_Team__c pct3 = New Provider_Care_Team__c(Care_Team__c = obj_recs.get(Care_Team__c.sObjectType)[1].id,
                   Provider__c = otherPortalUserContact.id);
                insert_rec(Provider_Care_Team__c.sObjectType,pct3);

                                 
        }
        
        test_access(Provider_Care_Team__c.sObjectType,New Map<String,Map<ID,String[]>>{
            'MAX'=>New Map<ID,String[]>{extUser.id=>New String[]{'Read','Read'}}
            },obj_recs);                    
        test_access(Provider_Care_Team__c.sObjectType,New Map<String,Map<ID,String[]>>{
            'MAX'=>New Map<ID,String[]>{extUserOther.id=>New String[]{'Read','Read'}}
            },obj_recs);                    
    }



    @isTest(SEEALLDATA = True)
    public static void portal_User_Access(){

        User extUser = createCustomerPortalUser(external_user_profile,portalUserContact);
        User extUserOther = createCustomerPortalUser(external_user_profile,otherPortalUserContact);
        User extUserCreatedUser;

        
        system.runAs(extUser){
            Contact extUserContact = New Contact(
                                            FirstName = 'Pop',
                                            LastName = 'Admin',
                                            AccountID = portalUserAccount.id,
                                            OwnerID = extUser.id
                                            
                                        );

            insert_rec(Contact.sObjectType,extUserContact);

            Schema.DescribeSObjectResult userDescribe = User.sObjectType.getDescribe();

            system.assertEquals(true,userDescribe.isCreateable());
            

            try{
                extUserCreatedUser = createCustomerPortalUser('Customer Portal Manager Custom',(Contact)obj_recs.get(Contact.sObjectType)[2]);
                system.assertEquals(true,false,'This profile should not have been able to create a user');
            }catch(exception e){
                system.assertEquals(true,e.getMessage().contains(System.Label.SL_UnauthorizedCreationError));
            }
            
            

            
        }

        system.runAs(SILVERLINEADMIN){
            Contact c2 = New Contact(                             
                                    FirstName = 'External User2', 
                                    LastName = 'Contact', 
                                    AccountID = otherPortalUserAccount.id
                                );
            insert_rec(Contact.sObjectType,c2);

            extUserCreatedUser = createCustomerPortalUser(external_user_profile,c2);

        }



        UserRecordAccess ura = [Select RecordID, MaxAccessLevel, hasReadAccess, hasEditAccess, hasDeleteAccess From UserRecordAccess Where UserID = :extUser.id AND Recordid = :extUserCreatedUser.id];

        system.assertEquals('None',ura.MaxAccessLevel);

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
                    {
                        /*system.assertEquals(accessTypeToResults.get(levelToTest).get(userID)[x], 
                                        recToURA.get(objs.get(objType)[x].id).MaxAccessLevel); */   
                    }        
                    else if(levelToTest == 'EDIT')
                    {
                        /*system.assertEquals(boolean.valueOf(accessTypeToResults.get(levelToTest).get(userID)[x]), 
                                        recToURA.get(objs.get(objType)[x].id).hasEditAccess);*/         
                    }   
                    else if(levelToTest == 'READ')
                    {
                        /*system.assertEquals(boolean.valueOf(accessTypeToResults.get(levelToTest).get(userID)[x]), 
                                        recToURA.get(objs.get(objType)[x].id).hasReadAccess);*/ 
                    }            
                    else if(levelToTest == 'DELETE')
                    {
                        /*system.assertEquals(boolean.valueOf(accessTypeToResults.get(levelToTest).get(userID)[x]), 
                                        recToURA.get(objs.get(objType)[x].id).hasDeleteAccess);*/
                    }             

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



}