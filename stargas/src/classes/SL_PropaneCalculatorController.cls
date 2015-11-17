/**
*  ClassName      : SL_PropaneCalculatorController
*  JIRATicket     : STARGAS-15
*  CreatedOn      : 11/AUG/2014
*  ModifiedBy     : Pankaj Ganwani
*  Description    : This class serves as controller for Propane Calcualator page.
*/
public without sharing class SL_PropaneCalculatorController 
{
	/* Start - Page Variables */
	public Opportunity objOpportunity			{get;set;} // This object is used to contain the values of Opportunity
	public Integer Sum_Of_Selected_Purposes		{get;set;} // This variable is used to hold the sum of selected pupose values
	public Integer Count_Of_Route_Methods		{get;set;} // This variable is used to hold the checked count of barbeque grill, Cooking range, dryer-clothes, generator and Fireplace-decorative.
	public Integer Count_Of_Non_Route_Methods	{get;set;} // This variable is used to hold the checked count of non route methods
	/* End - Page Variables */
	 
	/* Start - class Variables */
	private Map<String,Propane_Calculator_Table__c> PurposeType_To_PropaneCalculator; // this map contains the purpose type of propane to its contents
	private Map<Decimal,List<String>> DeliveriesPerYear_To_lstOfRouteNumbers; // this map contains the deliveries per year to corresponding list of numbers
	private Map<String,Map<Decimal,String>> GallonageBreakDownType_To_GallonageBreakdownAndSubLevel;
	private Set<Decimal> setKFA2; //list of KFA2 numbers to calculate the minimum value.
	private Decimal Usage_Value;	// this variable is used to hold the value of usage
	private Decimal Sum_Of_KFA;		// this variable is used to hold the sum of KFA values.
	private Decimal Sum_Of_HWG;		// this variable is used to hold the sum of HWG values.
	private Boolean Logical_OR_HWH;// this variable is used to hold the ORing of HWH values.
	private Boolean Logical_OR_VHW;// this variable is used to hold the ORing of VHW values.
	/* End - class Variables */
	
	/* Start - Constructor */
	public SL_PropaneCalculatorController(Apexpages.standardcontroller objStandardController)
	{
		initialize();
		// Fetching all the purpose values from Opportunity object which are related to current opportunity record
		List<Opportunity> lstOpportunity = [SELECT Barbeque_Grill__c, Cooking_Range__c, Hot_Water__c, Space_Heating_Fireplace__c, Swimming_Pool_Only__c,
												   Swimming_Pool_With_Spa__c, Dryer_Clothes__c, Primary_Heat_Small__c, Primary_Heat_Medium__c, Primary_Heat_Large__c,
												   Generator__c, Fireplace_Decorative__c, Employee__c, K_Factor__c, Route_Table__c, HW_Gallons__c, Separate_HW__c, 
												   Sub_Level__c, Usage__c, Planned_Tank_Size_Gallons__c												   
											FROM   Opportunity 
										    WHERE  Id=:objStandardController.getId() LIMIT 1];
		
		//Checking if Opportunity is not null and not empty
		if(lstOpportunity!=null && !lstOpportunity.isEmpty())
			objOpportunity = lstOpportunity[0];//Assigning the value of 0th index to object
	}
	/* End - Constructor */
	
	/*
        * MethodName        : initialize
        * param             : -
        * Description       : This function will be called to initialize all page variables
    */
	private void initialize()
	{
	    //Initializing all decimal values with 0
	    Usage_Value = Sum_Of_KFA = Sum_Of_HWG = Sum_Of_Selected_Purposes = 0;				
		//Initializing all boolean values with false
		Logical_OR_HWH = Logical_OR_VHW = false;
		setKFA2 = new Set<Decimal>();
		PurposeType_To_PropaneCalculator = getPropaneCalculatorTableContents();
		DeliveriesPerYear_To_lstOfRouteNumbers = getDeliveriesPerYearTolstOfRouteNumbers();	
		GallonageBreakDownType_To_GallonageBreakdownAndSubLevel = getGallonageBreakDownTypeToGallonageBreakdownAndSubLevel();			
	}
	
	/*
        * MethodName        : getPropaneCalculatorTableContents
        * param             : -
        * Description       : This function will be called to fill the map Map<String,Propane_Calculator_Table__c>.
    */
    private Map<String,Propane_Calculator_Table__c> getPropaneCalculatorTableContents()
    {
    	Map<String,Propane_Calculator_Table__c> PurposeType_To_PropaneCalculator = new Map<String,Propane_Calculator_Table__c>();
    	
    	//Iterating over Propane_Calculator_Table__c to fill the map with purpose type and its corresponding propane calculator parameters
    	for(Propane_Calculator_Table__c objPropaneCalculator : [SELECT Type__c, KFA__c, KFA2__c, HWG__c, HWH__c, Period__c, Route__c, VHW__c, Estimated_Annual_Usage_Gal__c 
    															FROM   Propane_Calculator_Table__c])
		{
			PurposeType_To_PropaneCalculator.put(objPropaneCalculator.Type__c, objPropaneCalculator);
		}
		return PurposeType_To_PropaneCalculator;
    }
    
    /*
        * MethodName        : getDeliveriesPerYearTolstOfRouteNumbers
        * param             : -
        * Description       : This function will be called to fill the map with route number and its corresponding deliveries per year
    */
    private Map<Decimal,List<String>> getDeliveriesPerYearTolstOfRouteNumbers()
    {
    	Map<Decimal,List<String>> DeliveriesPerYear_To_lstOfRouteNumbers = new Map<Decimal,List<String>>();
    	
    	//Iterating over Propane_Route_Table__c to fill the map with route number and its corresponding deliveries per year
    	for(Propane_Route_Table__c objPropaneRouteTable : [SELECT Deliveries_Per_Year__c, Route_Number__c
    													   FROM   Propane_Route_Table__c ORDER BY Name])
		{
			if(!DeliveriesPerYear_To_lstOfRouteNumbers.containskey(objPropaneRouteTable.Deliveries_Per_Year__c))
				DeliveriesPerYear_To_lstOfRouteNumbers.put(objPropaneRouteTable.Deliveries_Per_Year__c, new List<String>{objPropaneRouteTable.Route_Number__c});
			else
				DeliveriesPerYear_To_lstOfRouteNumbers.get(objPropaneRouteTable.Deliveries_Per_Year__c).add(objPropaneRouteTable.Route_Number__c);
		}
		return DeliveriesPerYear_To_lstOfRouteNumbers;
    }
    
    /*
        * MethodName        : getGallonageBreakDownTypeToGallonageBreakdownAndSubLevel
        * param             : -
        * Description       : This function will be called to fill the map with gallonage break down type and its corresponding gallonage breakdown and sub level
    */
    private Map<String,Map<Decimal,String>> getGallonageBreakDownTypeToGallonageBreakdownAndSubLevel()
    {
    	Map<String,Map<Decimal,String>> GallonageBreakDownType_To_GallonageBreakdownAndSubLevel = new Map<String,Map<Decimal,String>>();
    	
    	//Iterating over Propane_Gallonage_Table__c to fill the map with gallonage break down type and its corresponding gallonage breakdown and sub level
    	for(Propane_Gallonage_Table__c objPropaneGallonage : [SELECT Gallonage_Breakdown_Type__c, Gallonage_Breakdown__c, BPC_Sublevel__c
    														  FROM 	 Propane_Gallonage_Table__c])
		{
		  	if(!GallonageBreakDownType_To_GallonageBreakdownAndSubLevel.containskey(objPropaneGallonage.Gallonage_Breakdown_Type__c))
		  		GallonageBreakDownType_To_GallonageBreakdownAndSubLevel.put(objPropaneGallonage.Gallonage_Breakdown_Type__c, 
		  																	new Map<Decimal,String>{objPropaneGallonage.Gallonage_Breakdown__c=>objPropaneGallonage.BPC_Sublevel__c});
		    else
		    	GallonageBreakDownType_To_GallonageBreakdownAndSubLevel.get(objPropaneGallonage.Gallonage_Breakdown_Type__c).put(objPropaneGallonage.Gallonage_Breakdown__c,objPropaneGallonage.BPC_Sublevel__c);
		}
		return GallonageBreakDownType_To_GallonageBreakdownAndSubLevel;
    }
    
    /*
        * MethodName        : calculatePropane
        * param             : -
        * Description       : This function will be called to calculate propane value
    */
    public void calculatePropane()
    {   		
   		Decimal Route_Table_Number = 0;
	   	Decimal Route_Table_DeliveriesPerYear = 0;
   		try
   		{
	   		calculateOutputValues(objOpportunity.Barbeque_Grill__c,'Barbeque Grill');
	   		calculateOutputValues(objOpportunity.Cooking_Range__c,'Cooking Range');
	   		calculateOutputValues(objOpportunity.Hot_Water__c,'Hot Water');
	   		calculateOutputValues(objOpportunity.Space_Heating_Fireplace__c,'Space Heating - Fireplace');
	   		calculateOutputValues(objOpportunity.Swimming_Pool_Only__c,'Swimming Pool Only');
	   		calculateOutputValues(objOpportunity.Swimming_Pool_With_Spa__c,'Swimming Pool With Spa');
	   		calculateOutputValues(objOpportunity.Dryer_Clothes__c,'Dryer - Clothes');
	   		calculateOutputValues(objOpportunity.Primary_Heat_Small__c,'Primary Heat - Small');
	   		calculateOutputValues(objOpportunity.Primary_Heat_Medium__c,'Primary Heat - Medium');
	   		calculateOutputValues(objOpportunity.Primary_Heat_Large__c,'Primary Heat - Large');
	   		calculateOutputValues(objOpportunity.Generator__c,'Generator');
	   		calculateOutputValues(objOpportunity.Fireplace_Decorative__c,'Fireplace - Decorative');
	   		Route_Table_DeliveriesPerYear = (Count_Of_Route_Methods > 1 && Count_Of_Non_Route_Methods == 0) ? (objOpportunity.Planned_Tank_Size_Gallons__c==null || objOpportunity.Planned_Tank_Size_Gallons__c == 0 ? 0 : Math.ceil(Usage_Value/(objOpportunity.Planned_Tank_Size_Gallons__c * 0.75))):0;
	   		Route_Table_Number = DeliveriesPerYear_To_lstOfRouteNumbers.containskey(Route_Table_DeliveriesPerYear) && DeliveriesPerYear_To_lstOfRouteNumbers.get(Route_Table_DeliveriesPerYear)!=null ? Decimal.valueOf(DeliveriesPerYear_To_lstOfRouteNumbers.get(Route_Table_DeliveriesPerYear)[0]) : 0;
	   		objOpportunity.Usage__c = Usage_Value;
	   		objOpportunity.Sub_Level__c = Decimal.valueOf(getSubLevel(Usage_Value));
	   		Decimal Min_Of_KFA2 = getMinKFA2();
	   		objOpportunity.K_Factor__c = Route_Table_Number > 0 ? 0 : (Sum_Of_KFA <=25 &&  Sum_Of_KFA > 0) ? Sum_Of_KFA : Min_Of_KFA2 == null ? 0 : Min_Of_KFA2 ;
	   		objOpportunity.HW_Gallons__c = Route_Table_Number > 0 ? 0 : (Logical_OR_VHW) ? 0 : Sum_Of_HWG;
	   		objOpportunity.Separate_HW__c = Route_Table_Number > 0 ? 'N' : Logical_OR_HWH ? 'Y' : 'N';
	   		objOpportunity.Route_Table__c = Route_Table_Number > 0 ? Route_Table_Number : (Sum_Of_KFA > 25) ? Sum_Of_KFA : 0;
	   		update objOpportunity;
   		}
   		catch(Exception ex)
   		{
   			Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR,ex.getMessage()));
   			System.debug('======================='+ex.getMessage()+'======================'+ex.getLineNumber());
   		}
   		finally
   		{
   			//Intializing all decimal variables with 0 to recalculate the values each time the button is clicked
	   		Usage_Value = Sum_Of_KFA = Sum_Of_HWG = 0;   		
	   		//Initializing all boolean values with false
			Logical_OR_HWH = Logical_OR_VHW = false;
			setKFA2.clear();//clearing the list to recalculate the min value of KFA2
   		}
    }
    
    /*
        * MethodName        : calculateOutputValues
        * param             : purpose value and name of the purpose
        * Description       : This function is used to calculate the values of different parameters on the basis of purpose value and name of the purpose
    */
    private void calculateOutputValues(Boolean purposeStatus, String purpose)
    {    	
    	Propane_Calculator_Table__c objPropaneCalculator;//declaring the reference of propane calculator table object
    	if(purposeStatus)
    	{
    		objPropaneCalculator = PurposeType_To_PropaneCalculator.get(purpose.trim());//instantiating the reference with Propane_Calculator_Table__c object
    		//Adding the value of estimated annual usage to calculate the value of usage
    		Usage_Value += objPropaneCalculator.Estimated_Annual_Usage_Gal__c!=null ? objPropaneCalculator.Estimated_Annual_Usage_Gal__c : 0;
    		Sum_Of_KFA += Sum_Of_Selected_Purposes > 1 ? 0 : objPropaneCalculator.KFA__c;
    		Sum_Of_HWG += Sum_Of_Selected_Purposes > 1 ? (purpose.trim() == 'Hot Water' ? objPropaneCalculator.HWG__c:(objPropaneCalculator.HWG__c!=null ? objPropaneCalculator.HWG__c : 0)) : 0;   		
    		Logical_OR_HWH = Sum_Of_Selected_Purposes > 1 ? (Logical_OR_HWH || (objPropaneCalculator.HWH__c == 'Y' ? true:false)):(purpose.trim() == 'Cooking Range' || purpose.trim() == 'Dryer - Clothes') ? (Logical_OR_HWH || false):(Logical_OR_HWH || (objPropaneCalculator.HWH__c == 'Y' ? true:false));
    		Logical_OR_VHW = Sum_Of_Selected_Purposes > 1 ? (Logical_OR_VHW || (objPropaneCalculator.VHW__c == 'Y' ? true:false)):false;
    		setKFA2.add(Sum_Of_Selected_Purposes > 1 ? objPropaneCalculator.KFA2__c : null);
    	}
    	else
    	{
    		Logical_OR_HWH = (Logical_OR_HWH || false);
    		Logical_OR_VHW = (Logical_OR_VHW || false);
    		setKFA2.add(null);
    	}    	
    }
    
     /*
        * MethodName        : getSubLevel
        * param             : value of Route Number
        * Description       : This function is used to calculate the value of sub level on the basis of Usage value
    */
    private String getSubLevel(Decimal Usage)
    {
    	String Sub_Level = '1';//Default value as per the data
    	List<Decimal> lstGallonageBreakdownValues = new List<Decimal>();//list to hold the gallonage breakdown numbers.
    	//getting the mappings of gallonage number and its sub level on the basis of break down type
    	Map<Decimal,String> GallonageBreakdown_To_SubLevel = objOpportunity.Employee__c 
    														&& GallonageBreakDownType_To_GallonageBreakdownAndSubLevel.containskey('Employee') 
    														&& GallonageBreakDownType_To_GallonageBreakdownAndSubLevel.get('Employee')!=null
    														?  GallonageBreakDownType_To_GallonageBreakdownAndSubLevel.get('Employee') 
    														:  GallonageBreakDownType_To_GallonageBreakdownAndSubLevel.get('Non-Employee');
    	//assigning the map values to a list
    	lstGallonageBreakdownValues.addAll(GallonageBreakdown_To_SubLevel.keyset());
    	//sorting the list in the ascending order
    	lstGallonageBreakdownValues.sort();
    	//Iterating over above list to find the value of sub level
    	for(Integer i = 0 ; i < lstGallonageBreakdownValues.size();i++)
    	{
    		if(i+1 < lstGallonageBreakdownValues.size())
    		{
	    		if(lstGallonageBreakdownValues[i] <= Usage && lstGallonageBreakdownValues[i+1] > Usage)
	    		{
	    			Sub_Level = GallonageBreakdown_To_SubLevel.get(lstGallonageBreakdownValues[i]);
	    			break;
	    		}
    		}
    		else
    		{
    			Sub_Level = GallonageBreakdown_To_SubLevel.get(lstGallonageBreakdownValues[i]);
	    		break;
    		}	    			 
    	}
    	return Sub_Level;
    }
     /*
        * MethodName        : getMinKFA2
        * param             : -
        * Description       : This function is used to calculate the minimum value of KFA2
    */
    private Decimal getMinKFA2()
    {
    	Decimal Min_KFA2;
    	List<Decimal> lstKFA2 = new List<Decimal>();
    	if(setKFA2.contains(null))
    		setKFA2.remove(null);
    	if(!setKFA2.isEmpty())
    	{
	    	lstKFA2.addAll(setKFA2);
	    	Min_KFA2 = lstKFA2[0];
	    	for(Integer i = 0; i < lstKFA2.size();i++)
	    	{
	    		if(lstKFA2[i] < Min_KFA2)
	    			Min_KFA2 = lstKFA2[i];
	    	}
    	}
    	return Min_KFA2;
    }
}