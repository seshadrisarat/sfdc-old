/*
 * \author Vladimir Dobrelya
 * \date July 23, 2013
 * \see https://silverline.jira.com/browse/WP-102
 * \brief The test class for SL_ctrl_TickSheetProperty, SL_model_TickSheetProperty, SL_TickSheet classes
 */
@isTest
private class SL_test_ctrl_TickSheetProperty {
    static String sTickSheetLondon = 'London';
    static String sTickSheetHealthcare = 'Healthcare';
	static String sAvailableTicksheets = SL_test_ctrl_TickSheetProperty.sTickSheetLondon + ';' + SL_test_ctrl_TickSheetProperty.sTickSheetHealthcare;

	static void CreateData() {
		List<Ticksheet_Property__c> aSections = new List<Ticksheet_Property__c>();
		aSections.add( CreateTickSheetProperty( 'INDUSTRY EXPERTISE (select all that apply)', 'Section', null, null, 1, 5, 'Center', true, true ) );
		aSections.add( CreateTickSheetProperty( 'GEOGRAPHY EXPERTISE (select all that apply)', 'Section', null, null, 2, 5, 'Center', true, true ) );
		aSections.add( CreateTickSheetProperty( 'SPECIFIC CONTACT TYPE RELATED FIELDS', 'Section', null, null, 3, 5, 'Center', true, true ) );
		insert aSections;
		
		List<Ticksheet_Property__c> aSubsections = new List<Ticksheet_Property__c>();
		// INDUSTRY EXPERTISE
		aSubsections.add( CreateTickSheetProperty( 'Consumer (C)',     'Field', aSections[ 0 ].Id, 'Industry__c', 1, 6.0000,  'Left', false, true ) );
		aSubsections.add( CreateTickSheetProperty( 'Services (S)',     'Field', aSections[ 0 ].Id, 'Industry__c', 2, 7.0000,  'Left', false, true ) );
		aSubsections.add( CreateTickSheetProperty( 'Industrial (I)',   'Field', aSections[ 0 ].Id, 'Industry__c', 3, 8.0000,  'Left', false, true ) );
		aSubsections.add( CreateTickSheetProperty( 'Healthcare (H)',   'Field', aSections[ 0 ].Id, 'Industry__c', 4, 9.0000,  'Left', false, true ) );
		aSubsections.add( CreateTickSheetProperty( 'Financial Services (FS)', 'Field', aSections[ 0 ].Id, 'Industry__c', 4, 9.1000, 'Left', false, true ) );
		aSubsections.add( CreateTickSheetProperty( 'Real Estate (RE)', 'Field', aSections[ 0 ].Id, 'Industry__c', 4, 9.2000,  'Left', false, true ) );
		aSubsections.add( CreateTickSheetProperty( 'TMT (T)',          'Field', aSections[ 0 ].Id, 'Industry__c', 1, 10.0000, 'Left', false, true ) );
		aSubsections.add( CreateTickSheetProperty( 'Energy (E)',       'Field', aSections[ 0 ].Id, 'Industry__c', 2, 12.0000, 'Left', false, true ) );
		// GEOGRAPHY EXPERTISE
		aSubsections.add( CreateTickSheetProperty( 'Western Europe (WE)',  'Field', aSections[ 1 ].Id, 'Geography__c', 1, 20.0000, 'Left', false, true ) );
		aSubsections.add( CreateTickSheetProperty( 'Emerging Europe (EE)', 'Field', aSections[ 1 ].Id, 'Geography__c', 2, 21.0000, 'Left', false, true ) );
		// SPECIFIC CONTACT TYPE RELATED FIELDS
		aSubsections.add( CreateTickSheetProperty( 'Investment Banker', 'Field', aSections[ 2 ].Id, null, 1, 24.0000, 'Left', false, true ) );
		aSubsections.add( CreateTickSheetProperty( 'Management Pool',   'Field', aSections[ 2 ].Id, null, 2, 26.0000, 'Center', false, true ) );
		insert aSubsections;
		
		List<Ticksheet_Property__c> aProperties = new List<Ticksheet_Property__c>();
		// INDUSTRY EXPERTISE
		aProperties.add( CreateTickSheetProperty( 'Consumer Goods (CG)',      'Value', aSubsections[ 0 ].Id, 'Sub_Industry__c', 1, 6.0100,  'Left', false, false ) );
		aProperties.add( CreateTickSheetProperty( 'BPO / Outsourcing (SO)',   'Value', aSubsections[ 1 ].Id, 'Sub_Industry__c', 2, 7.0100,  'Left', false, false ) );
		aProperties.add( CreateTickSheetProperty( 'Automotive (IA)',          'Value', aSubsections[ 2 ].Id, 'Sub_Industry__c', 3, 8.0100,  'Left', false, false ) );
		aProperties.add( CreateTickSheetProperty( 'Healthcare Services (HS)', 'Value', aSubsections[ 3 ].Id, 'Sub_Industry__c', 4, 9.0100,  'Left', false, false ) );
		aProperties.add( CreateTickSheetProperty( 'Asset Management (FAM)',   'Value', aSubsections[ 4 ].Id, 'Sub_Industry__c', 4, 12.0100, 'Left', false, false ) );
		aProperties.add( CreateTickSheetProperty( 'Generalist',               'Value', aSubsections[ 5 ].Id, 'Sub_Industry__c', 4, 13.0100, 'Left', false, false ) );
		aProperties.add( CreateTickSheetProperty( 'Telco & Cable (TC)',       'Value', aSubsections[ 6 ].Id, 'Sub_Industry__c', 1, 10.0100, 'Left', false, false ) );
		aProperties.add( CreateTickSheetProperty( 'Alternatives - Bio-fuels (EAB)', 'Value', aSubsections[ 7 ].Id, 'Sub_Industry__c', 2, 11.0100, 'Left', false, false ) );
		aProperties.add( CreateTickSheetProperty( 'Nuclear (EN)',             'Value', aSubsections[ 7 ].Id, 'Sub_Industry__c', 'Industrial (I)', 3, 11.0200, 'Left', false, false ) );
		aProperties.add( CreateTickSheetProperty( 'Alternatives - Other (EAO)', 'Value', aSubsections[ 7 ].Id, 'Sub_Industry__c', 2, 11.0300, 'Left', false, false ) );
		// GEOGRAPHY EXPERTISE
		aProperties.add( CreateTickSheetProperty( 'Benelux (WB)', 'Value', aSubsections[ 8 ].Id, 'Sub_Geography__c', null, true, 1, 20.0100, 'Left', false, false ) );
		aProperties.add( CreateTickSheetProperty( 'Balkans (EB)', 'Value', aSubsections[ 9 ].Id, 'Sub_Geography__c', null, true, 2, 21.0100, 'Left', false, false ) );
		// SPECIFIC CONTACT TYPE RELATED FIELDS
		aProperties.add( CreateTickSheetProperty( 'Equities',  'Value', aSubsections[ 10 ].Id, 'Specific_Investment_Banker_Dept__c', 1, 25.0100, 'Left', false, false ) );
		aProperties.add( CreateTickSheetProperty( 'CEO', 'Value', aSubsections[ 11 ].Id, 'Specific_Management_Pool_Role__c', 2, 26.0100, 'Left', false, false ) );
		aProperties.add( CreateTickSheetProperty( 'Full-time', 'Value', aSubsections[ 11 ].Id, 'Specific_Management_Pool_Avaliability__c', 3, 27.0100, 'Left', false, false ) );		
		insert aProperties;
	}
	
	static testMethod void UnitTest() {
		CreateData();
		
		SL_ctrl_TickSheetProperty oController = new SL_ctrl_TickSheetProperty();
		ApexPages.currentPage().getParameters().put( 'id', pContact.Id );
		
		Test.startTest();
		oController = new SL_ctrl_TickSheetProperty();
		system.assertEquals( 3, oController.Sections.size() );
		system.assertEquals( 'INDUSTRY EXPERTISE (select all that apply)', oController.Sections[ 0 ].sName );
		system.assertEquals( 'GEOGRAPHY EXPERTISE (select all that apply)', oController.Sections[ 1 ].sName );
		system.assertEquals( 'SPECIFIC CONTACT TYPE RELATED FIELDS', oController.Sections[ 2 ].sName );
		system.assertEquals( 2, oController.Sections[ 0 ].aRows.size() );
		system.assertEquals( 2, oController.Sections[ 0 ].aRows[ 1 ].aColumns[ 1 ].aSubsections[ 0 ].aRows[ 0 ].aColumns.size() );
		
		// Cancel
		oController.Sections[ 0 ].aRows[ 1 ].aColumns[ 1 ].aSubsections[ 0 ].bChecked = true;
		oController.Sections[ 0 ].aRows[ 1 ].aColumns[ 1 ].aSubsections[ 0 ].aRows[ 0 ].aColumns[ 0 ].bChecked = true;
		oController.Sections[ 0 ].aRows[ 1 ].aColumns[ 1 ].aSubsections[ 0 ].aRows[ 0 ].aColumns[ 1 ].bChecked = true;
		oController.Sections[ 1 ].aRows[ 0 ].aColumns[ 1 ].aSubsections[ 0 ].aRows[ 0 ].aColumns[ 0 ].bChecked = true;
		oController.Cancel();
		system.assertEquals( null, pContact.Industry__c );
		system.assertEquals( null, pContact.Geography__c );
		system.assertEquals( null, pContact.Sub_Industry__c );
		
		// Save
		oController.Sections[ 0 ].aRows[ 1 ].aColumns[ 1 ].aSubsections[ 0 ].bChecked = true;
		oController.Sections[ 0 ].aRows[ 1 ].aColumns[ 1 ].aSubsections[ 0 ].aRows[ 0 ].aColumns[ 0 ].bChecked = true;
		oController.Sections[ 0 ].aRows[ 1 ].aColumns[ 1 ].aSubsections[ 0 ].aRows[ 0 ].aColumns[ 1 ].bChecked = true;
		system.assertEquals( 'Balkans (EB)', oController.Sections[ 1 ].aRows[ 0 ].aColumns[ 1 ].aSubsections[ 0 ].aRows[ 0 ].aColumns[ 0 ].sName );
		oController.Sections[ 1 ].aRows[ 0 ].aColumns[ 1 ].aSubsections[ 0 ].aRows[ 0 ].aColumns[ 0 ].bChecked = true;
		oController.Save();
		Test.stopTest();
		
		oController = new SL_ctrl_TickSheetProperty();
		system.assert( pContact.Industry__c.contains( 'Energy (E)' ) );
		system.assert( pContact.Industry__c.contains( 'Industrial (I)' ) ); // WP-120 Auto-populate industry when sub-industry selected ( 'Nuclear (EN)'' has Industry_Save_Value__c = 'Industrial (I)' )
		system.assert( pContact.Geography__c.contains( 'Emerging Europe (EE)' ) ); // WP-121
		system.assert( pContact.Sub_Geography__c.contains( 'Balkans (EB)' ) ); // WP-121
		system.assert( pContact.Sub_Industry__c.contains( 'Alternatives - Bio-fuels (EAB)' ) );
		system.assert( pContact.Sub_Industry__c.contains( 'Nuclear (EN)' ) );
	}
	
	static testMethod void TickSheetTest() {
		SL_ctrl_TickSheetProperty oController = new SL_ctrl_TickSheetProperty();
		system.assertEquals( true, oController.getButtonDisabled() );
		oController.Save();
		oController.Cancel();

		ApexPages.currentPage().getParameters().put( 'id', pContact.Id );
		oController = new SL_ctrl_TickSheetProperty();
		system.assertEquals( false, oController.getButtonDisabled() );
		system.assert( oController.Sections.isEmpty() );
		oController.Save();
		
		SL_TickSheet.init( new Map<ID, List<Ticksheet_Property__c>>(), new Map<ID, List<Ticksheet_Property__c>>(), new Map<String, Set<String>>() );
		new SL_TickSheet.Property( null );
		new SL_TickSheet.Section( CreateTickSheetProperty( 'Test', 'Section', null, null, 1, 1.0000, 'Left', false, true ) );
		
		////////////////////////////////////////////////////////////////////
		
		Ticksheet_Property__c oSection = CreateTickSheetProperty( 'INDUSTRY EXPERTISE (select all that apply)', 'Section', null, null, 1, 5, 'Center', true, true );
		insert oSection;
		Ticksheet_Property__c oSubsection = CreateTickSheetProperty( 'Energy (E)', 'Field', oSection.Id, 'Industry__c', 1, 1.0000, 'Left', false, true );
		insert oSubsection;
		
		SL_TickSheet.SectionColumn oColumn = new SL_TickSheet.SectionColumn( oSubsection );
		system.assertEquals( 1, oColumn.nColspan );
		system.assertEquals( 1, oColumn.nRowspan );
		system.assertEquals( 'width:25%', oColumn.sWidth );
		
		List<Ticksheet_Property__c> aProperties = new List<Ticksheet_Property__c>();
		aProperties.add( CreateTickSheetProperty( 'Alternatives - Bio-fuels (EAB)', 'Value', oSubsection.Id, 'Sub_Industry__c', 1, 1.0100, 'Left', false, false ) );
		aProperties.add( CreateTickSheetProperty( 'Nuclear (EN)', 'Value', oSubsection.Id, 'Sub_Industry__c', 2, 1.0200, 'Left', false, false ) );
		insert aProperties;
		
		SL_TickSheet.init(
			new Map<ID, List<Ticksheet_Property__c>> { oSection.Id => new List<Ticksheet_Property__c> { oSubsection } },
			new Map<ID, List<Ticksheet_Property__c>> { oSubsection.Id => aProperties }, new Map<String, Set<String>>()
		);
		
		oColumn = new SL_TickSheet.SectionColumn( oSubsection );
		system.assertEquals( 2, oColumn.nColspan );
		system.assertEquals( 1, oColumn.nRowspan );
		system.assertEquals( 'width:50%', oColumn.sWidth );
		
		oController = new SL_ctrl_TickSheetProperty();
		system.assertEquals( pContact.Id, oController.EmployeeContact.Id );
		system.assertEquals( false, oController.getButtonDisabled() );

		system.assertEquals( oController.CurrentTicksheet, pContact.Tick_Sheet__c );
		system.assertNotEquals( null, oController.AvailableTicksheets );
		system.assert( sAvailableTicksheets.contains( oController.AvailableTicksheets[ 0 ].getValue() ) );
		system.assert( sAvailableTicksheets.contains( oController.AvailableTicksheets[ 1 ].getValue() ) );
		oController.CurrentTicksheet = SL_test_ctrl_TickSheetProperty.sTickSheetHealthcare;
	}

	static testMethod void WP117_WP18_test() {
		List<Ticksheet_Property__c> aSections = new List<Ticksheet_Property__c>();
		aSections.add( CreateTickSheetProperty( 'INDUSTRY EXPERTISE (select all that apply)', 'Section', null, null, 1, 5, 'Center', true, true ) );
		aSections.add( CreateTickSheetProperty( SL_test_ctrl_TickSheetProperty.sTickSheetHealthcare, 'INDUSTRY EXPERTISE (select all that apply)', 'Section', null, null, null, false, 1, 5, 'Center', true, true ) );
		insert aSections;
		
		String sSubsectionName = 'Energy (E)';

		List<Ticksheet_Property__c> aSubsections = new List<Ticksheet_Property__c>();
		aSubsections.add( CreateTickSheetProperty( sSubsectionName, 'Field', aSections[ 0 ].Id, 'Industry__c', 1, 1.0000, 'Left', false, true ) );
		aSubsections.add( CreateTickSheetProperty( SL_test_ctrl_TickSheetProperty.sTickSheetHealthcare, sSubsectionName, 'Field', aSections[ 1 ].Id, 'Industry__c', null, false, 1, 1.0000, 'Left', false, true ) );
		insert aSubsections;

		ApexPages.currentPage().getParameters().put( 'id', pContact.Id );
		SL_ctrl_TickSheetProperty oController = new SL_ctrl_TickSheetProperty();

		// current Tick-Sheet is SL_test_ctrl_TickSheetProperty.sTickSheetLondon
		system.assertNotEquals( SL_test_ctrl_TickSheetProperty.sTickSheetHealthcare, pContact.Tick_Sheet__c );

		oController.Sections[ 0 ].aRows[ 0 ].aColumns[ 0 ].aSubsections[ 0 ].bChecked = true;

		oController.CurrentTicksheet = SL_test_ctrl_TickSheetProperty.sTickSheetHealthcare;
		oController.ChangeTicksheet();
		system.assertEquals( SL_test_ctrl_TickSheetProperty.sTickSheetHealthcare, pContact.Tick_Sheet__c );

		system.assertEquals( sSubsectionName, pContact.Industry__c );
	}

	private static Ticksheet_Property__c CreateTickSheetProperty( String sName, String sType, ID idTickSheetProperty, String sSaveLocation, Decimal nColumn, Decimal nOrder, String sJustification, Boolean bItalic, Boolean bBold ) {
		return CreateTickSheetProperty( sName, sType, idTickSheetProperty, sSaveLocation, null, nColumn, nOrder, sJustification, bItalic, bBold );
	}

	private static Ticksheet_Property__c CreateTickSheetProperty( String sName, String sType, ID idTickSheetProperty, String sSaveLocation, String sIndustrySaveValue, Decimal nColumn, Decimal nOrder, String sJustification, Boolean bItalic, Boolean bBold ) {
		return CreateTickSheetProperty( SL_test_ctrl_TickSheetProperty.sTickSheetLondon, sName, sType, idTickSheetProperty, sSaveLocation, sIndustrySaveValue, false, nColumn, nOrder, sJustification, bItalic, bBold );
	}

	private static Ticksheet_Property__c CreateTickSheetProperty( String sName, String sType, ID idTickSheetProperty, String sSaveLocation, String sIndustrySaveValue, Boolean bAutoSelectParent, Decimal nColumn, Decimal nOrder, String sJustification, Boolean bItalic, Boolean bBold ) {
		return CreateTickSheetProperty( SL_test_ctrl_TickSheetProperty.sTickSheetLondon, sName, sType, idTickSheetProperty, sSaveLocation, sIndustrySaveValue, bAutoSelectParent, nColumn, nOrder, sJustification, bItalic, bBold );
	}
	
	private static Ticksheet_Property__c CreateTickSheetProperty( String sTickSheet, String sName, String sType, ID idTickSheetProperty, String sSaveLocation, String sIndustrySaveValue, Boolean bAutoSelectParent, Decimal nColumn, Decimal nOrder, String sJustification, Boolean bItalic, Boolean bBold ) {
		return new Ticksheet_Property__c(
			Name = sName,
			Tick_Sheet__c = sTickSheet,
			Type__c = sType,
			Tick_sheet_Property__c = idTickSheetProperty,
			Save_Location__c = sSaveLocation,
			Industry_Save_Value__c = sIndustrySaveValue,
			Auto_Select_Parent__c = bAutoSelectParent,
			Column__c = nColumn,
			Order__c = nOrder,
			Justification__c = sJustification,
			Italics__c = bItalic,
			Bold__c = bBold
		);
	}
	
	static Contact pContact {
		get {
			if ( pContact == null ) {
				pContact = new Contact(
					User_Id__c = UserInfo.getUserId(),
					Tick_Sheet__c = SL_test_ctrl_TickSheetProperty.sTickSheetLondon,
					Available_Ticksheets__c = sAvailableTicksheets,
					LastName = 'TestContact LN',
					Email = 'TestContact@test.ml'
				);
				insert pContact;
			}			
			return [ SELECT Id, Tick_Sheet__c, Industry__c, Geography__c, Sub_Geography__c, Sub_Industry__c FROM Contact WHERE Id = :pContact.Id limit 1 ];
		}
	}
}