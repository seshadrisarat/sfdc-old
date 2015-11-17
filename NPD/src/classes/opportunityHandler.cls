public with sharing class opportunityHandler {
    
    //This Method updates opportunity with the current Billing Contact info.
    //The parameter was sent from the OpportunityBillingContactInfo trigger.
    //03-26-2015: ERP Changes to Billing/Shipping Address (KR)
    
    public static void opptyBillingContactInfoHandler(Opportunity[] oppties) {
    
        string varAddress = null;  
        
        List<OpportunityContactRole> ocrs = [select ContactId, Contact.AccountId, Contact.Email, Contact.Phone, Contact.Fax, Contact.MailingCity, Contact.Mailing_Country_Code__c, Contact.MailingPostalCode, Contact.Mailing_State_Province_Code__c, Contact.MailingStreet, Contact.Name, Id, Role, Opportunity.AccountId, OpportunityId from OpportunityContactRole where opportunityId in :Oppties and role in ('Billing Contact','Shipping Contact','Billing and Shipping Contact','cc Billing')];
        
        for (Opportunity oppty : oppties) {
        
            oppty.To_Be_Emailed__c = null;
            
            oppty.Billing_Contact_Info_Name__c = null;
            oppty.Billing_Contact_Info_Email__c = null;
            oppty.Billing_Contact_Info_Phone__c = null;
            oppty.Billing_Contact_Info_Fax__c = null;
            oppty.Billing_Contact_Info_Address__c = null;
            oppty.Billing_Contact_Street__c = null;
            oppty.Billing_Contact_City__c = null;
            oppty.Billing_Contact_State__c = null;
            oppty.Billing_Contact_Zip_Code__c = null;
            oppty.Billing_Contact_Country__c = null;

            oppty.Shipping_Contact_Info_Name__c = null;
            oppty.Shipping_Contact_Info_Email__c = null;
            oppty.Shipping_Contact_Info_Phone__c = null;
            oppty.Shipping_Contact_Info_Fax__c = null;
            oppty.Shipping_Contact_Info_Address__c = null;
            oppty.Shipping_Contact_Street__c = null;
            oppty.Shipping_Contact_City__c = null;
            oppty.Shipping_Contact_State__c = null;
            oppty.Shipping_Contact_Zip_Code__c = null;
            oppty.Shipping_Contact_Country__c = null;
  
            if(oppty.Billing_Split_Master__c == 'No') {
                oppty.Billing_Contact_Info_Address__c = 'SEE BILLING MASTER';               
            }
                    
            if (ocrs.size()>0) {
                for (OpportunityContactRole ocr : ocrs){
                    if((ocr.OpportunityId == oppty.id) && (oppty.Billing_Split_Master__c != 'No')) {
                        if(ocr.Contact.AccountId == oppty.AccountId) { 
                            if(ocr.Role == 'Billing Contact' || ocr.Role == 'Billing and Shipping Contact') {
                            oppty.Billing_Contact_Info_Name__c = ocr.Contact.Name;           
                            oppty.Billing_Contact_Info_Email__c = ocr.Contact.Email;           
                            oppty.Billing_Contact_Info_Phone__c = ocr.Contact.Phone;           
                            oppty.Billing_Contact_Info_Fax__c = ocr.Contact.Fax;
                            oppty.Billing_Contact_Street__c = ocr.Contact.MailingStreet;
                            oppty.Billing_Contact_City__c = ocr.Contact.MailingCity;
                            oppty.Billing_Contact_State__c = ocr.Contact.Mailing_State_Province_Code__c;
                            oppty.Billing_Contact_Zip_Code__c = ocr.Contact.MailingPostalCode;
                            oppty.Billing_Contact_Country__c = ocr.Contact.Mailing_Country_Code__c;
                            varAddress = ocr.Contact.MailingStreet;
                            if(ocr.Contact.MailingCity != null) {
                               if(varAddress == null) {
                                   varAddress = ocr.Contact.MailingCity;
                                  } else {
                                  varAddress = varAddress + '\n' + ocr.Contact.MailingCity;
                               }
                            }
                            if(ocr.Contact.Mailing_State_Province_Code__c != null){
                               if(varAddress == null){
                                  varAddress = ocr.Contact.Mailing_State_Province_Code__c;
                               } else {
                                  if(ocr.Contact.MailingCity != null){
                                     varAddress = varAddress + ', ' + ocr.Contact.Mailing_State_Province_Code__c;
                                  } else {
                                     varAddress = varAddress + '\n' + ocr.Contact.Mailing_State_Province_Code__c;
                                  }
                               }
                            }
                            if(ocr.Contact.MailingPostalCode != null) {
                               if(varAddress == null){
                                  varAddress = ocr.Contact.MailingPostalCode;
                               } else {
                                  if(ocr.Contact.MailingCity == null && ocr.Contact.Mailing_State_Province_Code__c == null){
                                     varAddress = varAddress + '\n' + ocr.Contact.MailingPostalCode;
                                  } else {
                                     varAddress = varAddress + '  ' + ocr.Contact.MailingPostalCode;
                                  }
                               }
                            }
                            if(ocr.Contact.Mailing_Country_Code__c != null){
                               if(varAddress == null){
                                  varAddress = ocr.Contact.Mailing_Country_Code__c;
                               } else {
                                  varAddress = varAddress + '\n' + ocr.Contact.Mailing_Country_Code__c;
                               }
                            }
                            if(varAddress == null) {
                                oppty.addError('The Billing Contact you selected does not have an address.');
                            } else {
                                varAddress = varAddress.Trim();
                                oppty.Billing_Contact_Info_Address__c = varAddress;
                            }
                            if(oppty.To_Be_Emailed__c == null) {
                                oppty.To_Be_Emailed__c = oppty.Billing_Contact_Info_Email__c;
                            } else {
                                if(oppty.To_Be_Emailed__c.contains(oppty.Billing_Contact_Info_Email__c) == false) {
                                   oppty.To_Be_Emailed__c = oppty.To_Be_Emailed__c + ', ' + oppty.Billing_Contact_Info_Email__c;
                                }
                            }
                        }
                         if(ocr.Role == 'Shipping Contact' || ocr.Role == 'Billing and Shipping Contact') {  
                            oppty.Shipping_Contact_Info_Name__c = ocr.Contact.Name;           
                            oppty.Shipping_Contact_Info_Email__c = ocr.Contact.Email;           
                            oppty.Shipping_Contact_Info_Phone__c = ocr.Contact.Phone;           
                            oppty.Shipping_Contact_Info_Fax__c = ocr.Contact.Fax;
                            oppty.Shipping_Contact_Street__c = ocr.Contact.MailingStreet;
                            oppty.Shipping_Contact_City__c = ocr.Contact.MailingCity;
                            oppty.Shipping_Contact_State__c = ocr.Contact.Mailing_State_Province_Code__c;
                            oppty.Shipping_Contact_Zip_Code__c = ocr.Contact.MailingPostalCode;
                            oppty.Shipping_Contact_Country__c = ocr.Contact.Mailing_Country_Code__c;
                            varAddress = ocr.Contact.MailingStreet;
                            if(ocr.Contact.MailingCity != null) {
                               if(varAddress == null) {
                                  varAddress = ocr.Contact.MailingCity;
                                  } else {
                                  varAddress = varAddress + '\n' + ocr.Contact.MailingCity;
                               }
                            }
                            if(ocr.Contact.Mailing_State_Province_Code__c != null){
                               if(varAddress == null){
                                  varAddress = ocr.Contact.Mailing_State_Province_Code__c;
                               } else {
                                  if(ocr.Contact.MailingCity != null){
                                     varAddress = varAddress + ', ' + ocr.Contact.Mailing_State_Province_Code__c;
                                  } else {
                                     varAddress = varAddress + '\n' + ocr.Contact.Mailing_State_Province_Code__c;
                                  }
                               }
                            }
                            if(ocr.Contact.MailingPostalCode != null) {
                               if(varAddress == null){
                                  varAddress = ocr.Contact.MailingPostalCode;
                               } else {
                                  if(ocr.Contact.MailingCity == null && ocr.Contact.Mailing_State_Province_Code__c == null){
                                     varAddress = varAddress + '\n' + ocr.Contact.MailingPostalCode;
                                  } else {
                                     varAddress = varAddress + '  ' + ocr.Contact.MailingPostalCode;
                                  }
                               }
                            }
                            if(ocr.Contact.Mailing_Country_Code__c != null){
                               if(varAddress == null){
                                  varAddress = ocr.Contact.Mailing_Country_Code__c;
                               } else {
                                  varAddress = varAddress + '\n' + ocr.Contact.Mailing_Country_Code__c;
                               }
                            }
                            if(varAddress == null) {
                                oppty.addError('The Shipping Contact you selected does not have an address.');
                            } else {
                                varAddress = varAddress.Trim();
                                oppty.Shipping_Contact_Info_Address__c = varAddress;
                            }
                            if(oppty.To_Be_Emailed__c == null) {
                                oppty.To_Be_Emailed__c = oppty.Shipping_Contact_Info_Email__c;
                            } else {
                                if(oppty.To_Be_Emailed__c.contains(oppty.Shipping_Contact_Info_Email__c) == false) {
                                oppty.To_Be_Emailed__c = oppty.To_Be_Emailed__c + ', ' + oppty.Shipping_Contact_Info_Email__c;
                                }
                            }
                        }
                         if(ocr.Role == 'cc Billing') {
                            if(oppty.To_Be_Emailed__c == null) {
                                oppty.To_Be_Emailed__c = ocr.Contact.Email;
                            } else {
                               if(oppty.To_Be_Emailed__c.contains(ocr.Contact.Email) == false) {
                                  oppty.To_Be_Emailed__c = oppty.To_Be_Emailed__c + ', ' + ocr.Contact.Email;
                               }
                            }
                         
                         }   
                        
                        }else {oppty.addError('The contact you selected belongs to a different Account. Please select a Contact that belongs to the Account this Opportunity is related to. If the Contact does not exist under this Account, please create it.');
                        } 
                              
                    }               
                }
            }
        }       
    }
    


    public static void summarize_AU_PA_Sector(Opportunity[] oppties) {
        
    //2013.06.15 NC Added functionality to summarize AU, PA and Sector on Opportunity record
    //2013.11.15 NC Added functionality to summarize Country/Company on Opportunity record

            List<OpportunityLineItem> olisList = [select id, OpportunityId, Opportunity_Dept__c, Opportunity_BU__c, Opportunity_Sector__c, Country_NPD_Company__c from OpportunityLineItem where opportunityid in :oppties];

//            if (olisList.size()>0) {                

                for(Opportunity oppty : oppties) {
                    
                    oppty.LOB_Summary__c = null;
                    oppty.PA_Summary__c = null;
                    oppty.Sector_Summary__c = null;
                    oppty.Country_Summary__c = null;

//                  Set<ID> oIds = new Set<ID>();
//                  oIds.add(oppty.id);
                    
//                  List<OpportunityLineItem> olisList = [select id, OpportunityId, Opportunity_Dept__c, Opportunity_BU__c, Opportunity_Sector__c from OpportunityLineItem where opportunityid in :oIds];
                    
                    if (olisList.size()>0 && oppty.hasopportunitylineitem == true ) {                

                        Set<String> OppAUSumm = new Set<String>();    
                        Set<String> OppPASumm = new Set<String>();    
                        Set<String> OppSectorSumm = new Set<String>();    
                        Set<String> OppCountrySumm = new Set<String>();    
                        List<String> OppAUSummLst = new List<String>();    
                        List<String> OppPASummLst = new List<String>();    
                        List<String> OppSectorSummLst = new List<String>();    
                        List<String> OppCountrySummLst = new List<String>();    

                        for(OpportunityLineItem allOL : olisList) {

                            if (oppty.id == allOL.OpportunityId) {
                                OppAUSumm.add(allOL.Opportunity_Dept__c);
                                OppPASumm.add(allOL.Opportunity_BU__c);
                                OppsectorSumm.add(allOL.Opportunity_Sector__c);
                                OppCountrySumm.add(allOL.Country_NPD_Company__c);
                            }        
                        }
                    
                        if (OppAUSumm.size()>0) {
                            OppAUSummLst.addAll(OppAUSumm);
                            OppAUSummLst.sort();
                            oppty.LOB_Summary__c = 'MASTER:"' + oppty.MasterOpportunityDept__c.substring(0,10) + '"';           
                            for(String s : OppAUSummLst){
                                oppty.LOB_Summary__c = oppty.LOB_Summary__c + ',"' + s + '"';    
                            }
                        }
                    
                        if (OppPASumm.size()>0) {
                            OppPASummLst.addAll(OppPASumm);
                            OppPASummLst.sort();
                            oppty.PA_Summary__c = 'MASTER:"' + oppty.MasterOpportunityBU__c + '"';           
                            for(String s : OppPASummLst){
                                if (oppty.MasterOpportunityBU__c != s) {
                                    oppty.PA_Summary__c = oppty.PA_Summary__c + ',"' + s + '"';
                                }    
                            }
                        }
                        
                        if (OppSectorSumm.size()>0) {
                            OppSectorSummLst.addAll(OppSectorSumm);
                            OppSectorSummLst.sort();
                            oppty.Sector_Summary__c = 'MASTER:"' + oppty.Master_Opportunity_Sector__c + '"';           
                            for(String s : OppSectorSummLst){
                                oppty.Sector_Summary__c = oppty.Sector_Summary__c + ',"' + s + '"';    
                            }

                        if (OppCountrySumm.size()>0) {
                            OppCountrySummLst.addAll(OppCountrySumm);
                            OppCountrySummLst.sort();
                            oppty.Country_Summary__c = 'MASTER:"' + oppty.Master_Country__c + '"';           
                            for(String s : OppCountrySummLst){
                                oppty.Country_Summary__c = oppty.Country_Summary__c + ',"' + s + '"';    
                            }
                        }

                        }
                    }                
                }
//            }                                                 
    }


}