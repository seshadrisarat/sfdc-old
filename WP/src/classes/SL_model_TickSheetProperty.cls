/*
 * \author Vladimir Dobrelya
 * \date July 22, 2013
 * \see https://silverline.jira.com/browse/WP-102
 */
public with sharing class SL_model_TickSheetProperty {
	private ID idContact; // the ID of the Contact passed through URL
	private Map<String, Set<String>> aMSPFieldToAllVallues;
	private Map<String, Set<String>> aMSPFieldToAvailableValues;
	private String sIndustrySaveLocation = 'Industry__c'; // additional save locations
	public Contact oEmployeeContact; //contact where ticksheet values should be saved.
	public List<SL_TickSheet.Section> aSections; // all sections, fields and values displayed on the page
	public String sCurrentTicksheet { get; set; } // the current Tick-Sheet
	public List<SelectOption> aAvailableTicksheet { get; set; } // the list of Available Tick-Sheets for user
	public Boolean bButtonDisabled {
		get {
			return this.oEmployeeContact == null;
		}
	}
	private Contact oContact {
		get {
			if ( oContact == null ) {
				for ( Contact oItem : [ SELECT Tick_Sheet__c, Available_Ticksheets__c FROM Contact WHERE User_Id__c = :UserInfo.getUserId() limit 1 ] ) {
					oContact = oItem;
				}
			}
			return oContact;
		} set;
	}
	
	public SL_model_TickSheetProperty() {
		this.idContact = ApexPages.currentPage().getParameters().get( 'id' );

		this.aMSPFieldToAllVallues = this.getAllMSPValues();
		this.aMSPFieldToAvailableValues = new Map<String, Set<String>>();
		this.aAvailableTicksheet = this.getAvailableTicksheetList();
		
		this.sCurrentTicksheet = 'London'; //default office location is London. This if the office location of the employee's contact.
		if ( this.oContact != null && this.oContact.Tick_Sheet__c != null ) {
			this.sCurrentTicksheet = this.oContact.Tick_Sheet__c;
		}
		this.initTickSheet();
	}
	
	private List<SelectOption> getAvailableTicksheetList() {
		List<SelectOption> aResult = new List<SelectOption>();

		if ( this.oContact.Available_Ticksheets__c != null ) {
			for ( String sItem : this.oContact.Available_Ticksheets__c.split( ';' ) ) {
				aResult.add( new SelectOption( sItem, sItem ) );
			}
		}

		return aResult;
	}

	public PageReference changeTicksheet() {
		this.Save( null );
		
		this.oContact.Tick_Sheet__c = this.sCurrentTicksheet;
		update this.oContact;

		this.initTickSheet();
		return null;
	}

	public PageReference Save() {
		if ( !this.bButtonDisabled ) {
			return this.Save( this.getContactDetailPageReference() );
		}
		return null;
	}

	public PageReference Cancel() {
		if ( !this.bButtonDisabled ) {
			return this.getContactDetailPageReference();
		}
		return null;
	}


	private void initTickSheet() {
		List<Ticksheet_Property__c> aSections = new List<Ticksheet_Property__c>();
		Map<ID, List<Ticksheet_Property__c>> aSubsections = new Map<ID, List<Ticksheet_Property__c>>();
		Map<ID, List<Ticksheet_Property__c>> aProperties = new Map<ID, List<Ticksheet_Property__c>>();
		this.aMSPFieldToAvailableValues.clear();

		for ( Ticksheet_Property__c oItem : [
			SELECT Id, Name, Display_Name__c, Bold__c, Column__c, Highlight__c, Italics__c, Justification__c, Tick_sheet__c, Tick_sheet_Property__c, Type__c,
				Order__c, Save_Location__c, Industry_Save_Value__c, Auto_Select_Parent__c, Tick_sheet_Property__r.Name, Tick_sheet_Property__r.Save_Location__c 
			FROM Ticksheet_Property__c
			WHERE Tick_sheet__c includes ( :this.sCurrentTicksheet ) AND
				( Type__c = 'Section' OR (
					( Type__c = 'Field' OR Type__c = 'Value' ) AND
					Tick_sheet_Property__c != null )
				)
			ORDER BY Order__c, Column__c ]
		) {
			if ( oItem.Type__c == 'Section' ) {
				aSections.add( oItem );
			} else if ( oItem.Type__c == 'Field' ) {
				if ( !aSubsections.containsKey( oItem.Tick_sheet_Property__c ) ) {
					aSubsections.put( oItem.Tick_sheet_Property__c, new List<Ticksheet_Property__c>() );
				}
				aSubsections.get( oItem.Tick_sheet_Property__c ).add( oItem );
			} else if ( oItem.Type__c == 'Value' ) {
				if ( !aProperties.containsKey( oItem.Tick_sheet_Property__c ) ) {
					aProperties.put( oItem.Tick_sheet_Property__c, new List<Ticksheet_Property__c>() );
				}
				aProperties.get( oItem.Tick_sheet_Property__c ).add( oItem );
			}

			this.addAvailableValue( oItem.Save_Location__c, oItem.Save_Location__c, oItem.Name );
			/*this.addAvailableValue( oItem.Industry_Save_Value__c, this.sIndustrySaveLocation, oItem.Industry_Save_Value__c );		

			if ( oItem.Auto_Select_Parent__c ) {
				if ( String.isNotBlank( oItem.Tick_sheet_Property__r.Save_Location__c ) ) {
					this.addAvailableValue( oItem.Tick_sheet_Property__r.Save_Location__c, oItem.Tick_sheet_Property__r.Save_Location__c, oItem.Tick_sheet_Property__r.Name );
				}
			}*/
		}

		Map<String, Set<String>> aValues = new Map<String, Set<String>>();
		
		if ( !this.aMSPFieldToAllVallues.isEmpty() ) {
			this.oEmployeeContact = this.getEmployeeContact( this.aMSPFieldToAllVallues.keySet(), this.idContact );
			
			if ( this.oEmployeeContact != null ) {
				for ( String sItem : this.aMSPFieldToAllVallues.keySet() ) {
					if ( !aValues.containsKey( sItem ) ) {
						aValues.put( sItem, this.getCurrentSelectedValues( this.oEmployeeContact.get( sItem ) ) );
					}
				}
			}
		}
		
		this.aSections = new List<SL_TickSheet.Section>();

		SL_TickSheet.init( aSubsections, aProperties, aValues );
		
		for ( Ticksheet_Property__c oItemSection : aSections ) {
			this.aSections.add( new SL_TickSheet.Section( oItemSection ) );
		}
	}

	private void addAvailableValue( String sField, String sLocation, String sValue ) {
		if ( String.isNotBlank( sField ) ) {
			if ( !this.aMSPFieldToAvailableValues.containsKey( sLocation ) ) {
				this.aMSPFieldToAvailableValues.put( sLocation, new Set<String>() );
			}
			this.aMSPFieldToAvailableValues.get( sLocation ).add( sValue );
		}
	}

	private PageReference Save( PageReference oPageReference ) {
		if ( this.aSections.isEmpty() || this.oEmployeeContact == null ) {
			return null;
		}
		
		Map<String, Set<String>> aValues = new Map<String, Set<String>>();
		
		for ( SL_TickSheet.Section oSection : this.aSections ) {
			for ( SL_TickSheet.SectionRow oSectionRow : oSection.aRows ) {
				for ( SL_TickSheet.SectionColumn oSectionColumn : oSectionRow.aColumns ) {
					for ( SL_TickSheet.Subsection oSubsection : oSectionColumn.aSubsections ) {
						this.addProperty( aValues, oSubsection );
						for ( SL_TickSheet.SubsectionRow oRow : oSubsection.aRows ) {
							for ( SL_TickSheet.Property oProperty : oRow.aColumns ) {
								this.addProperty( aValues, oProperty );
							}
						}
					}
				}
			}
		}

		for ( String sField : this.aMSPFieldToAllVallues.keySet() ) {
			if ( aValues.containsKey( sField ) ) {
				this.oEmployeeContact.put( sField, String.join( this.getAvailableSelectedValues( sField, this.oEmployeeContact.get( sField ), aValues.get( sField ) ), ';' ) );
			}			
		}

		system.debug( '$$$ aValues : ' + aValues );

		update this.oEmployeeContact;

		return oPageReference;
	}

	private void addProperty( Map<String, Set<String>> aValues, SL_TickSheet.Item oProperty ) {
		this.addProperty( aValues, oProperty.bChecked, oProperty.sSaveLocation, oProperty.sName );
		this.addProperty( aValues, oProperty.bChecked, this.sIndustrySaveLocation, oProperty.sIndustrySaveValue );
		if ( oProperty.bAutoSelectParent && oProperty.oParent != null ) {
			this.addProperty( aValues, oProperty.bChecked, oProperty.oParent.Save_Location__c, oProperty.oParent.Name );
		}
	}

	private void addProperty( Map<String, Set<String>> aValues, Boolean isChecked, String sLocation, String sPropertyName ) {
		if ( String.isNotBlank( sLocation ) && String.isNotBlank( sPropertyName ) ) {
			if ( !aValues.containsKey( sLocation ) ) {
				aValues.put( sLocation, new Set<String>() );
			}
			if ( isChecked ) {
				aValues.get( sLocation ).add( sPropertyName );
			}
		}
	}

	// returns a list of all Multi-Select Picklists selected in Save_Location__c
	private Map<String, Set<String>> getAllMSPValues() {
		Map<String, Set<String>> aResult = new Map<String, Set<String>>();
		Map<String, Schema.SObjectField> aFields = Schema.SObjectType.Contact.fields.getMap();

		Schema.DescribeFieldResult oDescribe;

		for ( Ticksheet_Property__c oItem : [ SELECT Save_Location__c FROM Ticksheet_Property__c WHERE Save_Location__c != null ] ) {
			if ( !aResult.containsKey( oItem.Save_Location__c ) && aFields.containsKey( oItem.Save_Location__c ) ) {
				oDescribe = aFields.get( oItem.Save_Location__c ).getDescribe();
				if ( oDescribe.getType() == Schema.DisplayType.MultiPicklist ) {
					aResult.put( oItem.Save_Location__c, this.getMSPValues( oDescribe ) );
				}
			}
		}

		if ( !aResult.containsKey( this.sIndustrySaveLocation ) && aFields.containsKey( this.sIndustrySaveLocation ) ) {
			oDescribe = aFields.get( this.sIndustrySaveLocation ).getDescribe();
			if ( oDescribe.getType() == Schema.DisplayType.MultiPicklist ) {
				aResult.put( this.sIndustrySaveLocation, this.getMSPValues( oDescribe ) );
			}
		}
		
		return aResult;
	}

	// returns a set of values from Schema.SObjectField objects
	private Set<String> getMSPValues( Schema.DescribeFieldResult oFieldDescribe ) {
		Set<String> aResult = new Set<String>();

		for ( Schema.PicklistEntry oPicklistEntry : oFieldDescribe.getPicklistValues() ) {
			if ( oPicklistEntry.isActive() ) {
				aResult.add( oPicklistEntry.getValue() );
			}
		}

		return aResult;
	}

	private List<String> getAvailableSelectedValues( String sField, Object oFieldCurrentValue, Set<String> aValues ) {
		Set<String> aResult = new Set<String>( aValues );
		Set<String> aCurrentValues = this.getCurrentSelectedValues( oFieldCurrentValue );

		for ( String sValue : this.aMSPFieldToAllVallues.get( sField ) ) {
			if ( !this.aMSPFieldToAvailableValues.containsKey( sField ) || !this.aMSPFieldToAvailableValues.get( sField ).contains( sValue ) ) {
				if ( aCurrentValues.contains( sValue ) ) {
					aResult.add( sValue );
				}
			}

			/*if ( this.aMSPFieldToAvailableValues.containsKey( sField ) && this.aMSPFieldToAvailableValues.get( sField ).contains( sValue ) ) {
				if ( aValues.contains( sValue ) ) {
					aResult.add( sValue );
				}
			} else if ( aCurrentValues.contains( sValue ) ) {
				aResult.add( sValue );
			}*/
		}

		system.debug(
			'\n$$$ ' + sField + 
			'\naCurrentValues : ' + aCurrentValues +
			'\naResult : ' + aResult +
			'\naValues : ' + aValues
		);

		return new List<String>( aResult );
	}

	private Set<String> getCurrentSelectedValues( Object oFieldValue ) {
		if ( oFieldValue != null ) {
			return new Set<String>( ( ( String )oFieldValue ).split( ';' ) );
		}
		return new Set<String>();
	}

	private Contact getEmployeeContact( Set<String> aFields, ID idContact ) {
		Set<String> aFielsToSelect = new Set<String>( aFields );
		aFielsToSelect.add( this.sIndustrySaveLocation ); // to avoid the exception if there is no Ticksheet Property with Save_Location__c = 'Industry__c'
		//aFielsToSelect.add( this.sGeographySaveLocation );
		aFielsToSelect.add( 'Name' );

		for ( Contact oItem : Database.query( 'SELECT ' + String.join( new List<String>( aFielsToSelect ), ',' ) + ' FROM Contact WHERE Id = :idContact limit 1' ) ) {
			return oItem;
		}
		
		ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Could not find a contact with ID \'' + idContact + '\'.' ) );
		return null;
	}

	private PageReference getContactDetailPageReference() {
		return new PageReference( '/' + this.oEmployeeContact.Id );
	}
}