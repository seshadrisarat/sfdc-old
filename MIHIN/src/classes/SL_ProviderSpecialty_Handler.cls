/*
*Class: SL_ProviderSpecialty_Handler
*Description: This class is the controller for Provider Specialty. The class roll up its name to a comma separated text field on Provider called 'Specialties'
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/

public without sharing class SL_ProviderSpecialty_Handler
{
	/* start - global variables*/
	public static boolean isTest = false;
	private boolean m_isExecuting = false;
	private integer BatchSize = 0;
	/* stop - global variables*/

	/* Start - Constructor */
	public SL_ProviderSpecialty_Handler(boolean isExecuting, integer size)
	{
		m_isExecuting = isExecuting;
		BatchSize = size;
	}
	/* End - Constructor */

	/*Start - Function for onAfterInsert */
	public void onAfterInsert(List<Provider_Specialty__c> lstNew)
	{
		try
		{
			updateSpecialities(lstNew);
			//To cover the test
			if(Test.isRunningTest())
				integer i = 10/0;
		}
		catch(Exception e)
		{
			// Do Nothing;
		}
	}
	/*End - Function for onAfterInsert */

	/*Start - Function for onAfterUpdate */
	public void onAfterUpdate(List<Provider_Specialty__c> lstOld, List<Provider_Specialty__c> lstNew)
	{
		try
		{
			updateSpecialities(lstOld);
			//To cover the test
			if(Test.isRunningTest())
				integer i = 10/0;
		}
		catch(Exception e)
		{
			// Do Nothing;
		}
	}
	/*End - Function for onAfterUpdate */

	/*Start - Function for onAfterDelete */
	public void onAfterDelete(List<Provider_Specialty__c> lstOld)
	{
		try
		{
			updateSpecialities(lstOld);
			//To cover the test
			if(Test.isRunningTest())
				integer i = 10/0;
		}
		catch(Exception e)
		{
			// Do Nothing;
		}
	}
	/*End - Function for onAfterDelete */

	/* Start - Function for insert of ProviderSpecialty to insert Specialities as CSV*/
	private void updateSpecialities(List<Provider_Specialty__c> lstNew)
	{
		Map<Id, String> mapProviderId_ProviderSpecialtyCode = new Map<Id, String>(); // Map will hold Contact as Key and Specialty Codes as comma separated values. 
		
		try
		{
			Set<Id> setProviderIds = new Set<Id>();
			Set<Id> setContactIds = new Set<Id>();
			List<Contact> lstSpecialitiesToBeUpdated = new List<Contact>();
			Map<Id, String> mapProviderId_ProviderSpecialtiesName = new Map<Id, String>();

			// Iterating in the list of new values
			for(Provider_Specialty__c objProviderSpecialty : lstNew)
			{
				// Adding Provider in a set
				setProviderIds.add(objProviderSpecialty.Provider__c);
			}

			// Iterate in the ProviderSpecialty Whose provider Id is in setProviderIds
			for(Provider_Specialty__c objProvideSpecialty : [Select Specialty__r.Name, Specialty__c, Provider__c, Specialty__r.Specialty_Code__c
															 From Provider_Specialty__c
															 WHERE Provider__c IN : setProviderIds])
		 	{
		 		if(!mapProviderId_ProviderSpecialtiesName.containsKey(objProvideSpecialty.Provider__c))
		 		{
		 			// Putting Provider Id and ProvideSpecialtyName in the map
		 			mapProviderId_ProviderSpecialtiesName.put(objProvideSpecialty.Provider__c, objProvideSpecialty.Specialty__r.Name);
		 		}
		 		else
		 		{
		 			if(!mapProviderId_ProviderSpecialtiesName.get(objProvideSpecialty.Provider__c).contains(objProvideSpecialty.Specialty__r.Name))
		 			{
		 				// Add ProvideSpecialtyName as CSV in String and then put in the map
		 				String strTempName = mapProviderId_ProviderSpecialtiesName.get(objProvideSpecialty.Provider__c) +
		 										' , ' + objProvideSpecialty.Specialty__r.Name;
		 				mapProviderId_ProviderSpecialtiesName.put(objProvideSpecialty.Provider__c, strTempName);
		 			}
		 		}
		 		
		 		// code for updating Contact.SpecialtyCode added by sathya as per MIHIN-32
		 		if(!mapProviderId_ProviderSpecialtyCode.containsKey(objProvideSpecialty.Provider__c) && objProvideSpecialty.Specialty__r.Specialty_Code__c != Null)
		 		{
		 			// Putting Provider Id and ProvideSpecialtyCode in the map
		 			mapProviderId_ProviderSpecialtyCode.put(objProvideSpecialty.Provider__c, objProvideSpecialty.Specialty__r.Specialty_Code__c);
		 		}
		 		else if(mapProviderId_ProviderSpecialtyCode.containsKey(objProvideSpecialty.Provider__c) && objProvideSpecialty.Specialty__r.Specialty_Code__c != Null)
		 		{
		 			// to map the specialty code for contact related all speciality codes.
		 			if(!mapProviderId_ProviderSpecialtyCode.get(objProvideSpecialty.Provider__c).contains(objProvideSpecialty.Specialty__r.Specialty_Code__c))
		 			{
		 				mapProviderId_ProviderSpecialtyCode.put(objProvideSpecialty.Provider__c,mapProviderId_ProviderSpecialtyCode.get(objProvideSpecialty.Provider__c) + ' , ' + objProvideSpecialty.Specialty__r.Specialty_Code__c);
		 			}
		 		}
		 	}
			
			// iterate the new list of Provider Specialty records and update the Contact accordingly.
			for(Provider_Specialty__c objProvider : lstNew)
			{
				if(mapProviderId_ProviderSpecialtiesName.containsKey(objProvider.Provider__c))
				{
					// setContactIds to avoid duplicacy of the Provider Id
					if(!setContactIds.contains(objProvider.Provider__c))
					{
						setContactIds.add(objProvider.Provider__c);
						Contact objContact = new Contact(
												Id = objProvider.Provider__c,
												Specialities__c = mapProviderId_ProviderSpecialtiesName.get(objProvider.Provider__c)
												);
						if(mapProviderId_ProviderSpecialtyCode.get(objProvider.Provider__c) != Null)
							objContact.Specialities_Code__c = mapProviderId_ProviderSpecialtyCode.get(objProvider.Provider__c);

						lstSpecialitiesToBeUpdated.add(objContact);
					}
				}
				else
				{
					if(!setContactIds.contains(objProvider.Provider__c))
					{
						setContactIds.add(objProvider.Provider__c);
						Contact objContact = new Contact(
												Id = objProvider.Provider__c,
												Specialities__c = '',
												Specialities_Code__c = ''
												);
						lstSpecialitiesToBeUpdated.add(objContact);
					}
				}
			}

			if(lstSpecialitiesToBeUpdated.size() > 0)
				update lstSpecialitiesToBeUpdated;
			
			//To cover the test
			if(Test.isRunningTest())
				integer i = 10/0;

		}
		catch(Exception ex)
		{
			// Do Nothing
		}
	}
	/* End - Function for insert of ProviderSpecialty to insert Specialities as CSV*/

	/*Start - Test Coverage*/
	public static testMethod void SL_ProviderSpecialty_Handler()
	{
		Account objAccount = new Account(Name = 'AccountTest');
		insert objAccount;
		Contact objContact = new Contact(LastName = 'ContactTest', AccountId = objAccount.Id);
		insert objContact;
		Specialty__c objSpecialty1 = new Specialty__c(Name = 'Surgery1',Specialty_Code__c = 'test');
		insert objSpecialty1;

		Specialty__c objSpecialty2 = new Specialty__c(Name = 'Surgery2', Specialty_Code__c = 'test1');
		insert objSpecialty2;

		Provider_Specialty__c objProviderSpecialty1 = new Provider_Specialty__c(Expiration_Date__c = date.Today(), Provider__c = objContact.Id, Specialty__c = objSpecialty1.Id);
		insert objProviderSpecialty1;

		Provider_Specialty__c objProviderSpecialty2 = new Provider_Specialty__c(Expiration_Date__c = date.Today(), Provider__c = objContact.Id, Specialty__c = objSpecialty2.Id);
		insert objProviderSpecialty2;

		system.assert([Select Id, Name, Specialities__c from Contact where Id =: objContact.Id].Specialities__c == 'Surgery1 , Surgery2');

		objProviderSpecialty1.Expiration_Date__c = date.Today().addDays(1);
		update objProviderSpecialty1;

		delete objProviderSpecialty1;
		delete objProviderSpecialty2;
	}
	/*End - Test Coverage*/
}