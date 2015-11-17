/**
* \arg ClassName  : SL_MultiselectComponent
* \arg JIRATicket : GREENHILL-26
* \arg CreatedBy  : Lodhi
* \arg ModifiedOn : 10/APRIL/2014
* \arg Description: This class is going to use for SL_MultiselectComponent component.
*/

public with sharing class SL_MultiselectComponent 
{
    // SelectOption lists for public consumption
    public SelectOption[] leftSideOptions 	{	get; set; 	}
    public SelectOption[] rightSideOptions 	{ 	get; set; 	}
    
    // Parse &-separated values and labels from value and 
    // put them in option
    private void setOptions(SelectOption[] options, String value) 
    {
        options.clear();
        String[] parts = value.split('&');
        for (Integer i=0; i<parts.size()/2; i++) 
        {
            options.add(new SelectOption(EncodingUtil.urlDecode(parts[i*2], 'UTF-8'), 
              EncodingUtil.urlDecode(parts[(i*2)+1], 'UTF-8')));
        }
    }
    
    // Backing for hidden text field containing the options from the
    // left list
    public String leftOptionsHidden 
    { 
    	get; 
    	set 
    	{
           leftOptionsHidden = value;
           setOptions(leftSideOptions, value);
        }
    }
    
    // Backing for hidden text field containing the options from the
    // right list
    public String rightOptionsHidden 
    { 
    	get; 
    	set 
    	{
           rightOptionsHidden = value;
           setOptions(rightSideOptions, value);
        }
    }
}