/*
*Class: SL_RestResponseWrappers
*Description: To form the Rest APIs response
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
global abstract with sharing class SL_RestResponseWrappers 
{
    public abstract class BaseResponse 
    {
        public Integer totalSize;
        public Boolean done;
        
        public BaseResponse(Integer totalSize, Boolean done)
        {
            this.totalSize = totalSize;
            this.done = done;
        }
    }
    
    public class Addresses
    {
        public String Street_1;
        public String Street_2;
        public String City;
        public String County;
        public String State;
        public String Zip_Code;
        public Decimal Distance;
        
        public Addresses(String Street_1, String Street_2, String City, String County, String State, String Zip_Code, Decimal Distance)
        {
            this.Street_1 = Street_1;
            this.Street_2 = Street_2;
            this.City = City;
            this.County = County;
            this.State = State;
            this.Zip_Code = Zip_Code;
            this.Distance = Distance;
        }
    }
    
    public class Specialties
    {
        public Boolean isPrimary;
        public String Name;
        public String Description;
        public String Classification;
        public String Type;
        public String As_of_Date;
        public String Comments;
        public String Specialization;
        public String Specialty_Code;
        
        public Specialties(Boolean isPrimary, String Name, String Description, String Classification, String Type, String As_of_Date, String Comments, String Specialization, String Specialty_Code)
        {
            this.isPrimary = isPrimary;
            this.Name = Name;
            this.Description = Description;
            this.Classification = Classification;
            this.Type = Type;
            this.As_of_Date = As_of_Date;
            this.Comments = Comments;
            this.Specialization = Specialization;
            this.Specialty_Code = Specialty_Code;
        }
        
        public Specialties(Boolean isPrimary, String Description)
        {
            this.isPrimary = isPrimary;
            this.Description = Description;
        }
            
    }
    
    public class Credentials
    {
        public String Name;
        public String CredentialsNumber;
        public String Type;
        public String Status;
        public String Grant_Date;
        public String Granting_Organization;
        public String Expiration_Date;
        public String isSuspended;
        public String Suspended_Date;
        public String Limitations;
        public String Comments;
        
        /* Added by Lodhi as per MIHIN-35 on 3/JULY/2013 */
        public Credentials(String Name, String CredentialsNumber, String Type, String Status, 
        					String Grant_Date, String Granting_Organization, String Expiration_Date, 
        					String isSuspended, String Suspended_Date, String Limitations, String Comments)
        {
        	this.Name = Name;
        	this.CredentialsNumber = CredentialsNumber;
        	this.Type = Type;
        	this.Status = Status;   
        	this.Grant_Date = Grant_Date;
        	this.Granting_Organization = Granting_Organization;
        	this.Expiration_Date = Expiration_Date;
        	this.isSuspended = isSuspended;
        	this.Limitations = Limitations;
        	this.Comments = Comments;
        	this.Suspended_Date = Suspended_Date;
        }
        /* End */
        public Credentials()
        {
        	//do nothing.
        }
    }
    
    public class Identifiers
    {
        public String Identifier;
        public String Identifier_Type;
    }   
    
    /*
        Description: Used to form the response for provider search, MIHIN-26 
    */
    public class ProviderSearch extends SL_RestResponseWrappers 
    {
        public String Name;
        public String First_Name;
        public String Last_Name;
        public String Provider_ID;
        public String Organization;
        public String DIRECT_Email;
        public String Phone;
        public String Email;
        public String Fax;
        public String Gender;
        public String Type;
        public String Status;
        public String Languages;
        
        public List<Specialties> Specialties;
        public List<Addresses> Addresses;
        
        public ProviderSearch(String First_Name, String Last_Name, String Organization, String DIRECT_Email)
        {
            this.First_Name = First_Name;
            this.Last_Name = Last_Name;
            this.Organization = Organization;
            this.DIRECT_Email = DIRECT_Email;
        }
        
    }
    
    
    /* Test code coverage */
      
    public class testClass extends BaseResponse
    {
        public testClass()
        {
            super(1, true);
        }
    }
    
    @isTest
    static void testSL_RestResponseWrappers()
    {
        Addresses objAdd = new Addresses(' Street_1', 'Street_2', 'City', 'County', 'State', 'Zip_Cod',5);
        Specialties objSpec1 = new Specialties(true, 'Name', 'Description', 'Classification', 'Type', 'As_of_Date', 'Comments', 'Specialization', 'Specialty_Code');
        Specialties objSpec2 = new Specialties(true, 'Desc');
        Credentials objCreds = new Credentials();
        Identifiers objIden = new Identifiers();
        ProviderSearch objPS = new ProviderSearch('Name1', 'Name2', 'Org', 'Email');
        objCreds = new  Credentials('','','','','','','','','','','');
        testClass objTestClass = new testClass();
    }
    
    /* End  */
    
}