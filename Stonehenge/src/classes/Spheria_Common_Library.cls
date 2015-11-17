public with sharing class Spheria_Common_Library {

	
	public static String NumberFormat(double inVal)
	{
		String retVal = '';
		
		String tmpStr = ''+inVal;
		String tmpStrLast = '';
		String tmpStr2 = '';
		integer k=0;
		if(tmpStr.indexOf('.')!=-1)
		{
			tmpStrLast = tmpStr.substring(tmpStr.indexOf('.'));
			tmpStr = tmpStr.substring(0,tmpStr.indexOf('.'));
		}
		
		for(integer y=tmpStr.length()-1;y>=0;y--)
		{
			if(k==3||k==6||k==9||k==12||k==15) tmpStr2 = tmpStr.substring(y,y+1)+','+tmpStr2;
			else tmpStr2 = tmpStr.substring(y,y+1)+tmpStr2;
			k++;
		}
		
		retVal = tmpStr2 + tmpStrLast;
		
		return retVal;
	}

	public static String NumberFormat(Decimal inVal)
	{
		String retVal = '';
		
		String tmpStr = ''+inVal;
		String tmpStrLast = '';
		String tmpStr2 = '';
		integer k=0;
		if(tmpStr.indexOf('.')!=-1)
		{
			tmpStrLast = tmpStr.substring(tmpStr.indexOf('.'));
			tmpStr = tmpStr.substring(0,tmpStr.indexOf('.'));
		}
		
		for(integer y=tmpStr.length()-1;y>=0;y--)
		{
			if(k==3||k==6||k==9||k==12||k==15) tmpStr2 = tmpStr.substring(y,y+1)+','+tmpStr2;
			else tmpStr2 = tmpStr.substring(y,y+1)+tmpStr2;
			k++;
		}
		
		retVal = tmpStr2 + tmpStrLast;
		
		return retVal;
	}

	public static testMethod void myUnitTest() 
    {
    	double testDVal = 3256785642.23;
    	Decimal testDVal2 = 23452345;
    	String FormVal = Spheria_Common_Library.NumberFormat(testDVal);
    	System.debug('Nubmer (Double) with correct Format: '+FormVal);
    	
    	String FormVal2 = Spheria_Common_Library.NumberFormat(testDVal2);
    	System.debug('Nubmer (Decimal) with correct Format: '+FormVal2);
    }
}