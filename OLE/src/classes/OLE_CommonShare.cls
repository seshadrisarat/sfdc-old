public class OLE_CommonShare 
{
    /* Start Constructor */
    public OLE_CommonShare()
    {
        //do nothing
    }
    /* End Constructor */
    
    /* Start - Current login user information */
    public static User getCurrentLoginUserInfo()
    {
        List<User> lstUser = [SELECT Id, 
                                     Name, 
                                     AccountId, 
                                     ContactId,
                                     Contact.Name,
                                     FullPhotoUrl,
                                     TimeZoneSidKey
                                FROM User 
                               WHERE Id =: UserInfo.getUserId()];
                               
        return lstUser.isEmpty() ? new User() : lstUser[0];
    }
    /* End - Current login user information */
        
    /* Start - redirectToSignInPage */
    public static PageReference redirectToSignInPage()
    {
        if(!(Userinfo.getUserType() == 'CspLitePortal' || Userinfo.getUserType() == 'PowerCustomerSuccess'))
        {
            return  new PageReference(Site.getBaseUrl()+'/SignIn'); 
        }
        
        return null;
    }
    /* End - redirectToSignInPage */
    
    /* Start - redirectAuthenticatedUser */
    public static Pagereference redirectAuthenticatedUser(String strRetURL)
    {   
        if(Userinfo.getUserType() == 'CspLitePortal' || Userinfo.getUserType() == 'PowerCustomerSuccess')
        {
            if(String.isEmpty(strRetURL)) 
                return new Pagereference(Site.getBaseUrl()+'/Landing');
            else
                return new Pagereference(strRetURL.replace('retURL=', ''));
        }
        
        return null;
    } 
    /* End - redirectAuthenticatedUser */
    
    /* Start - Get the comma seprated field from field set.*/
    public static String getCSVField(String strSobjectName, String strLeftFieldSetName, String strRightFieldSetName)
    {
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(strSobjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        
        if(String.isEmpty(strLeftFieldSetName) && String.isEmpty(strRightFieldSetName))
            return '';
            
        String strCSV = '';    
        if(!String.isEmpty(strLeftFieldSetName))
        {
            for(Schema.FieldSetMember f : DescribeSObjectResultObj.fieldSets.getMap().get(strLeftFieldSetName).getFields())
            {
                strCSV +=  (String.isEmpty(strCSV) && !strCSV.containsIgnorecase(f.getFieldPath())) 
                           ? f.getFieldPath() : !strCSV.containsIgnorecase(f.getFieldPath()) 
                           ? ', ' + f.getFieldPath() : '';
            }
        }
        
        if(!String.isEmpty(strRightFieldSetName))
        {  

            for(Schema.FieldSetMember f : DescribeSObjectResultObj.fieldSets.getMap().get(strRightFieldSetName).getFields())
            {
                strCSV +=  (String.isEmpty(strCSV) && !strCSV.containsIgnorecase(f.getFieldPath())) 
                           ? f.getFieldPath() : !strCSV.containsIgnorecase(f.getFieldPath()) 
                           ? ', ' + f.getFieldPath() : '';
            }
        }
        
        strCSV += (strSobjectName == 'zqu__ZProduct__c' && !strCSV.contains('Name')) ? ',Name' : '';
        return strCSV;
    }
    /* End - Get the comma seprated field from field set.*/
    
    /* Start - prepareQuery */
    public static String prepareQuery(String strSobjectName, String strCSVFields, String strParentObjectFieldAPI, 
                                      String strParentId, String strWhereClauses, String strOrderByFieldAPIName, 
                                      String strOrderDirection, String strLimit)
    {
        if(String.isEmpty(strSobjectName) || String.isEmpty(strCSVFields))
            return '';
            
        strCSVFields = !strCSVFields.containsIgnorecase('Id') ? 'Id, ' + strCSVFields : strCSVFields;
        
        String strQuery = 'SELECT ' + strCSVFields+ ' FROM ' + strSobjectName;
        
        strWhereClauses += (!String.isEmpty(strWhereClauses) && !String.isEmpty(strParentObjectFieldAPI) && !String.isEmpty(strParentId)) 
                           ? ' AND ' + strParentObjectFieldAPI +' = \''+ strParentId + '\'' : (!String.isEmpty(strParentObjectFieldAPI) && !String.isEmpty(strParentId))
                           ? ' ' + strParentObjectFieldAPI +' = \''+ strParentId + '\'' : '';
        
        strQuery += (!String.isEmpty(strWhereClauses)) ? ' WHERE '+strWhereClauses : '';
        
        strQuery += (!String.isEmpty(strOrderByFieldAPIName) && !String.isEmpty(strOrderDirection)) ? ' ORDER BY ' + strOrderByFieldAPIName + ' ' + strOrderDirection : '';
        
        strQuery += (!String.isEmpty(strLimit)) ? ' LIMIT ' + strLimit : '';
        
        system.debug('===strQuery=='+strQuery);
        
        return strQuery;
    }
    /* End - prepareQuery */
    
    /* Start - getSobjectRecords */
    public static List<Sobject> getSobjectRecords(String strQuery)
    {
        return Database.query(strQuery);
    }
    /* End - getSobjectRecords.*/
}