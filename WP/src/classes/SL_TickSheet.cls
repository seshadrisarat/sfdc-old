/*
 * \author Vladimir Dobrelya
 * \date July 25, 2013
 * \see https://silverline.jira.com/browse/WP-102
 */
public with sharing class SL_TickSheet {
	private static Map<ID, List<Ticksheet_Property__c>> aAllSubsections;
	private static Map<ID, List<Ticksheet_Property__c>> aAllProperties;
	private static Map<String, Set<String>> aAllValues;
	
	public static void init( Map<ID, List<Ticksheet_Property__c>> aSubsections, Map<ID, List<Ticksheet_Property__c>> aProperties, Map<String, Set<String>> aValues ) {
		SL_TickSheet.aAllSubsections = aSubsections;
		SL_TickSheet.aAllProperties = aProperties;
		SL_TickSheet.aAllValues = aValues;
	}
	
	public abstract class Item {
		public String sName { get; private set; }
		public String sTitle { get; private set; }
		public Boolean bBold { get; private set; }
		public Boolean bItalic { get; private set; }
		public String sJustification { get; private set; }
		public String sSaveLocation { get; private set; }
		public String sIndustrySaveValue { get; private set; }
		public Boolean bChecked { get; set; }
		public Boolean bAutoSelectParent { get; set; }
		public Ticksheet_Property__c oParent { get; set; }
		
		public Item( Ticksheet_Property__c oProperty ) {
			if ( oProperty == null ) {
				return;
			}
			this.sName = oProperty.Name;
			this.sTitle = oProperty.Display_Name__c != null ? oProperty.Display_Name__c : oProperty.Name;
			this.bBold = oProperty.Bold__c;
			this.bItalic = oProperty.Italics__c;
			this.sJustification = oProperty.Justification__c.toLowerCase();
			this.sSaveLocation = oProperty.Save_Location__c;
			this.sIndustrySaveValue = oProperty.Industry_Save_Value__c;
			this.bAutoSelectParent = oProperty.Auto_Select_Parent__c;
			if ( this.bAutoSelectParent ) {
				this.oParent = this.getParent( oProperty );
			}			

			if ( this.getCheckboxRendered() && aAllValues.containsKey( oProperty.Save_Location__c ) && aAllValues.get( oProperty.Save_Location__c ).contains( oProperty.Name ) ) {
				this.bChecked = true;
			} else {
				this.bChecked = false;
			}
		}
		
		public Boolean getCheckboxRendered() {
			if ( this.sSaveLocation == null ) {
				return false;
			}
			return true;
		}

		private Ticksheet_Property__c getParent( Ticksheet_Property__c oProperty ) {
			for ( Ticksheet_Property__c oItem : oProperty.Tick_sheet_Property__r ) {
				return oItem;
			}
			return null;
		}
	}
	
	public class Section extends Item {
		public List<SectionRow> aRows { get; private set; }
		public Boolean bNotFull { get; private set; }
		
		public Section( Ticksheet_Property__c oProperty ) {
			super( oProperty );
			this.bNotFull = false;
			this.aRows = new List<SectionRow>();
			this.GenerateRows( oProperty.Id );
		}
		
		private void GenerateRows( ID idProperty ) {
			if ( !aAllSubsections.containsKey( idProperty ) ) {
				return;
			}
			
			List<SectionColumn> aRowItems = new List<SectionColumn>();
			SectionColumn oColumn = new SectionColumn( null );
			for ( Ticksheet_Property__c oItem : aAllSubsections.get( idProperty ) ) {
				if ( oColumn.nColumn == oItem.Column__c ) {
					oColumn.AddSubsection( oItem );
				} else if ( oItem.Column__c > oColumn.nColumn ) {
					aRowItems.add( oColumn );
					oColumn = new SectionColumn( oItem );
				} else {
					aRowItems.add( oColumn );
					this.aRows.add( new SectionRow( aRowItems ) );
					aRowItems = new List<SectionColumn>();
					oColumn = new SectionColumn( oItem );
				}
			}
			aRowItems.add( oColumn );
			this.aRows.add( new SectionRow( aRowItems ) );
			this.AddColumns();
		}
		
		private void AddColumns() {
			if ( this.aRows.size() == 1 && this.aRows.get( 0 ).aColumns.size() < 4 ) {
				Integer nMaxColumn = this.getMaxColumnNumber( this.aRows.get( 0 ) );
				if ( nMaxColumn < 4 ) {
					this.bNotFull = true;
					for ( Integer nI = nMaxColumn; nI < 4; nI++ ) {
						this.aRows.get( 0 ).aColumns.add( new SectionColumn( null ) );
					}
				}
			}
		}
		
		private Integer getMaxColumnNumber( SectionRow oRow ) {
			Integer nResult = 0;
			
			for ( SectionColumn oColumn : oRow.aColumns ) {
				if ( !oColumn.aSubsections.isEmpty() && !oColumn.aSubsections.get( 0 ).aRows.isEmpty() ) {
					nResult += oColumn.aSubsections.get( 0 ).aRows.get( 0 ).aColumns.size();
				} else {
					nResult++;
				}
			}
							
			return nResult;
		}
	}
	
	public class SectionRow {
		public List<SectionColumn> aColumns { get; private set; }
		
		public SectionRow( List<SectionColumn> aColumns ) {
			this.aColumns = aColumns;
		}
	}
	
	public class SectionColumn {
		public List<Subsection> aSubsections { get; private set; }
		public Integer nColumn { get; set; }
		public Integer nColspan {
			get {
				if ( !this.aSubsections.isEmpty() ) {
					if ( !this.aSubsections.get( 0 ).aRows.isEmpty() ) {
						if ( !this.aSubsections.get( 0 ).aRows.get( 0 ).aColumns.isEmpty() ) {
							return this.aSubsections.get( 0 ).aRows.get( 0 ).aColumns.size();
						}
					}
				}
				return 1;
			}
		}
		public Integer nRowspan {
			get {
				if ( this.aSubsections.size() > 1 ) {
					return 2;
				}
				return 1;
			}
		}
		public String sWidth {
			get {
				if ( !this.aSubsections.isEmpty() ) {
					if ( !this.aSubsections.get( 0 ).aRows.isEmpty() ) {
						if ( !this.aSubsections.get( 0 ).aRows.get( 0 ).aColumns.isEmpty() ) {
							return 'width:' + ( 25 * this.aSubsections.get( 0 ).aRows.get( 0 ).aColumns.size() ) + '%';
						}
					}
				}
				return 'width:25%';
			}
		}
		
		public SectionColumn( Ticksheet_Property__c oSubsection ) {
			this.aSubsections = new List<Subsection>();
			
			if ( oSubsection != null ) {
				this.AddSubsection( oSubsection );
				this.nColumn = Integer.valueOf( oSubsection.Column__c );
			}
			
			if ( this.nColumn == null ) {
				this.nColumn = 1;
			}
		}
		
		public void AddSubsection( Ticksheet_Property__c oSubsection ) {
			this.aSubsections.add( new Subsection( oSubsection ) );
		}
	}
	
	public class Subsection extends Item {
		public List<SubsectionRow> aRows { get; private set; }
		public Boolean bEmpty { get; private set; }
		
		public Subsection( Ticksheet_Property__c oProperty ) {
			super( oProperty );
			
			this.bEmpty = ( oProperty == null );
			
			this.aRows = new List<SubsectionRow>();
			if ( oProperty != null ) {
				this.GenerateProperties( oProperty.Id );
			}
		}
		
		private void GenerateProperties( ID idProperty ) {
			if ( !aAllProperties.containsKey( idProperty ) ) {
				return;
			}
			
			Integer nColumn = 0;
			List<Ticksheet_Property__c> aItems = new List<Ticksheet_Property__c>();
			for ( Ticksheet_Property__c oItem : aAllProperties.get( idProperty ) ) {
				if ( oItem.Column__c > nColumn ) {
					aItems.add( oItem );
				} else {
					this.aRows.add( new SubsectionRow( aItems ) );
					aItems.clear();
					aItems.add( oItem );
				}
				nColumn = Integer.valueOf( oItem.Column__c );
			}
			if ( !aItems.isEmpty() ) {
				this.aRows.add( new SubsectionRow( aItems ) );
			}
		}
	}
	
	public class SubsectionRow {
		public List<Property> aColumns { get; set; }
		
		public SubsectionRow( List<Ticksheet_Property__c> aProperties ) {
			this.aColumns = new List<Property>();
			for ( Ticksheet_Property__c oItem : aProperties ) {
				if ( oItem != null ) {
					this.aColumns.add( new Property( oItem ) );
				}
			}
		}		
	}
	
	public class Property extends Item {
		public Property( Ticksheet_Property__c oProperty ) {
			super( oProperty );
		}
	}
}