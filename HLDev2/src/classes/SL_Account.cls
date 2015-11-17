/*
 * Author Stefan Schwaab
 *
 * Created June 23 2014 
 * 
 * Account methods
 *
 */
public without sharing class SL_Account
{ 
    // When a CapIQ Company is added to an Account, search the Investments and add the Account to the Portfolio and Sponsor Account fields 
    public static void updateInvestmentAccounts( List<Account> newAccounts ) {
        // Initialize variables
        Id currCapIQCompanyId;
        List<Investment__c> investmentsToUpdate = new List<Investment__c>{};
        List<Investment__c> sponsorInvestments = new List<Investment__c>{};
        List<Investment__c> portfolioInvestments = new List<Investment__c>{};
        List<Investment__c> investmentsForThisCapIQId = new List<Investment__c>{}; 
        Map<Id, List<Investment__c>> mapSponsorInvestments = new Map<Id, List<Investment__c>>{};
        Map<Id, List<Investment__c>> mapPortfolioInvestments = new Map<Id, List<Investment__c>>{};
        Set<Id> setCapIQCompanyIds = new Set<Id>{};
        // Populate Set of CapIQ Company Ids
        for (Account newAccount : newAccounts) {
            if (newAccount.CapIQ_Company__c != null) {
                setCapIQCompanyIds.add(newAccount.CapIQ_Company__c);
            }
        }
        system.debug('>>>>> Set CapIQ Company Ids = ' + setCapIQCompanyIds);
        // Query Sponsor Investments for these CapIQ Ids
        sponsorInvestments = [SELECT Id, Name, Sponsor_CapIQ_Company__c, Portfolio_CapIQ_Company__c, Company__c, Sponsor__c FROM Investment__c WHERE Sponsor_CapIQ_Company__c IN :setCapIQCompanyIds ORDER BY Sponsor_CapIQ_Company__c]; 
        system.debug('>>>>> Sponsor Investments = ' + sponsorInvestments);
        // Process all Sponsor Investments found
        if (sponsorInvestments.size() > 0) {
            // Set current CapIQ Company Id
            currCapIQCompanyId = sponsorInvestments[0].Sponsor_CapIQ_Company__c;
            system.debug('>>>>> Current CapIQ Company Id = ' + currCapIQCompanyId);
            // Loop through List of Sponsor Investments
            // If Sponsor CapIQ Company Id = current CapIQ Company Id then add this Investment to the List of Investments for this CapIQ Id
            // If Sponsor CapIQ Company Id <> current CapIQ Company Id then put the List of Investments for this CapIQ Id in the Sponsor Investments Map, clear the List, and reset the current CapIQ Company Id
            for (Investment__c sponsorInvestment : sponsorInvestments) {
                system.debug('>>>>> Investment Record = ' + sponsorInvestment);
                if (sponsorInvestment.Sponsor_CapIQ_Company__c == currCapIQCompanyId) {
                    investmentsForThisCapIQId.add(sponsorInvestment);
                    system.debug('>>>>> Investments For This CapIQ Id = ' + investmentsForThisCapIQId);
                } else {
                    mapSponsorInvestments.put(currCapIQCompanyId, investmentsForThisCapIQId.deepClone(true, true, true));
                    investmentsForThisCapIQId.clear();
                    system.debug('>>>>> Map Sponsor Investments = ' + mapSponsorInvestments);
                    currCapIQCompanyId = sponsorInvestment.Sponsor_CapIQ_Company__c;
                }
            }
            // Capture the last row in the Sponsor Investments Map and clear the List
            mapSponsorInvestments.put(currCapIQCompanyId, investmentsForThisCapIQId.deepClone(true, true, true));
            investmentsForThisCapIQId.clear();
            system.debug('>>>>> Map Sponsor Investments = ' + mapSponsorInvestments);
        }   
        // Query Portfolio Investments for these CapIQ Ids
        portfolioInvestments = [SELECT Id, Name, Sponsor_CapIQ_Company__c, Portfolio_CapIQ_Company__c, Company__c, Sponsor__c FROM Investment__c WHERE Portfolio_CapIQ_Company__c IN :setCapIQCompanyIds ORDER BY Portfolio_CapIQ_Company__c]; 
        system.debug('>>>>> Portfolio Investments = ' + portfolioInvestments);
        // Process all Portfolio Investments found
        if (portfolioInvestments.size() > 0) {
            // Set current CapIQ Company Id
            currCapIQCompanyId = portfolioInvestments[0].Portfolio_CapIQ_Company__c;
            system.debug('>>>>> Current CapIQ Company Id = ' + currCapIQCompanyId);
            // Loop through List of Portfolio Investments
            // If Portfolio CapIQ Company Id = current CapIQ Company Id then add this Investment to the List of Investments for this CapIQ Id
            // If Portfolio CapIQ Company Id <> current CapIQ Company Id then put the List of Investments for this CapIQ Id in the Portfolio Investments Map, clear the List, and reset the current CapIQ Company Id
            for (Investment__c portfolioInvestment : portfolioInvestments) {
                system.debug('>>>>> Investment Record = ' + portfolioInvestment);
                if (portfolioInvestment.Portfolio_CapIQ_Company__c == currCapIQCompanyId) {
                    investmentsForThisCapIQId.add(portfolioInvestment);
                    system.debug('>>>>> Investments For This CapIQ Id = ' + investmentsForThisCapIQId);
                } else {
                    mapPortfolioInvestments.put(currCapIQCompanyId, investmentsForThisCapIQId.deepClone(true, true, true));
                    investmentsForThisCapIQId.clear();
                    system.debug('>>>>> Map Portfolio Investments = ' + mapPortfolioInvestments);
                    currCapIQCompanyId = portfolioInvestment.Portfolio_CapIQ_Company__c;
                }
            }
            // Capture the last row in the Portfolio Investments Map and clear the List
            mapPortfolioInvestments.put(currCapIQCompanyId, investmentsForThisCapIQId.deepClone(true, true, true));
            investmentsForThisCapIQId.clear();
            system.debug('>>>>> Map Portfolio Investments = ' + mapPortfolioInvestments);
        }
        // Process all updated or inserted Accounts
        // TODO - Add removal of previous Investments if change CapIQ_Company__c value
        for (Account newAccount : newAccounts) {
            // Check if CapIQ Company lookup field is filled in
            if (newAccount.CapIQ_Company__c != null) {
                // Search for Sponsor Investments for the CapIQ Company
                List<Investment__c> sponsorInvestmentList = mapSponsorInvestments.get(newAccount.CapIQ_Company__c);
                // If Sponsor Investments found, set the Sponsor field in the existing Investment record to the Sponsor Account Id
                if (sponsorInvestmentList != null) {
                    for (Investment__c sponsorInvestment : sponsorInvestmentList) {
                        sponsorInvestment.Sponsor__c = newAccount.Id;
                        investmentsToUpdate.add(sponsorInvestment);
                        system.debug('>>>>> Sponsor Investment FOUND = ' + sponsorInvestment);
                    }
                }
                // Search for Portfolio Investments for the CapIQ Company
                List<Investment__c> portfolioInvestmentList = mapPortfolioInvestments.get(newAccount.CapIQ_Company__c);
                // If Portfolio Investments found, set the Company field in the existing Investment record to the Portfolio Account Id
                if (portfolioInvestmentList != null) {
                    for (Investment__c portfolioInvestment : portfolioInvestmentList) {
                        portfolioInvestment.Company__c = newAccount.Id;
                        investmentsToUpdate.add(portfolioInvestment);
                        system.debug('>>>>> Portfolio Investment FOUND = ' + portfolioInvestment);
                    }
                }
            }
        }
        // Update changed Investment records
        system.debug('>>>>> Investments To Update = ' + investmentsToUpdate);
        if (investmentsToUpdate.size() > 0) {
            update investmentsToUpdate;
        }
    }
}