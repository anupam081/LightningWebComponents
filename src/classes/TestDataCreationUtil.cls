/*
Description: Class to create test data for testing the util and extension class for smart ivestor
                                        
    Owner:  Certification Candidate (207295)
    Associated APEX class: 
    Dependencies: none 
    Change History: 
    Date           Person                                   Responsible Details 
    10/15/2016     Certification Candidate (207295)         Created
*/

@isTest
public class TestDataCreationUtil {

    public static List<Investment_Account__c> invAccList = new List<Investment_Account__c>();
    public static List<Investment_Fund__c> invFundList = new List<Investment_Fund__c>();
    public static List<Investment__c> investmentList;
    public static List<Transaction__c> transactionsList;
   
    /** 
    * @Method Name : createInvAccount   
    * @description: Method for creating investment account test data     
    * @param: Integer : number of investment account to be created    
    * @return: Void    
    **/
    public static void createInvAccount(Integer AccCount){
        for(Integer index = 0; index < AccCount; index++){
            Investment_Account__c accObj = new Investment_Account__c();
            accObj.Name = 'Investment Account : ' +  index;  
            accObj.Cash_Reserve_Percent__c = 20;
            accObj.Cash_Value__c = 100;            
                      
            invAccList.add(accObj);
        }
        if(invAccList.size() > 0){
            insert invAccList;
        }   
    }
    
    /**    
    * @Method Name : createInvestmentFunds 
    * @description: Method for creating investment Funds test data     
    * @param: Integer : Number of records to create
    * @return: Void    
    **/
    public static void createInvestmentFunds(Integer fundCount){
        
            for(Integer index = 0; index < fundCount; index++){
                Investment_Fund__c objFund = new Investment_Fund__c();
                objFund.Name = 'Investment Fund : ' + index;
                objFund.Price__c = 10;
                objFund.Trading_Symbol__c = objFund.Name.substring(objFund.Name.length()-3, objFund.Name.length());
                invFundList.add(objFund);
            }
       
        if(invFundList.size() > 0){
            insert invFundList;
        } 
    }
    
        /**    
    * @Method Name : createSingleInvestments 
    * @description: Method for investments test data     
    * @param: Investment__c            
    * @return: Void    
    **/
    public static Investment__c createSingleInvestments(){
        
        Investment__c invobj = new Investment__c();
        if(invAccList.size() > 0 && invFundList.size() > 0){        
	            
	            invObj.Name = ' Single Investment' ;
	            invObj.Active__c = true;
	            invObj.Auto_Invest_Percent__c = 2;
	            invObj.Investment_Account__c = invAccList[0].id;	            
	            invObj.Investment_Fund__c = invFundList[100].id;	           
	            invObj.Shares__c = 1 ;            
	       
        }
        insert invobj;
        return invobj;
    }
    
    /**    
    * @Method Name : createInvestments 
    * @description: Method for investments test data     
    * @param: Integer : Number of records to create            
    * @return: Void    
    **/
    public static void createbulkInvestments(Integer invCount){
        
        investmentList = new List<Investment__c>();
        
        if(invAccList.size() > 0 && invFundList.size() > 0){ 
	        for(Integer index = 0; index < invCount; index++){
	            Investment__c invObj = new Investment__c();
	            invObj.Name = 'Investment : ' + index;
	            invObj.Active__c = true;
	            invObj.Auto_Invest_Percent__c = 1;
	            invObj.Investment_Account__c = invAccList[0].id;
	            if(index < invFundList.size()){
	            	invObj.Investment_Fund__c = invFundList[index].id;
	            }
	            invObj.Shares__c = 2;
	            investmentList.add(invObj);

	        }
        }
        if(investmentList.size() > 0){
            insert investmentList;
        } 
    }
    
    
     /**    
    * @Method Name : createSingleTransactions 
    * @description: Method to create single transaction test data     
    * @param: String, Decimal, Id, Integer           
    * @return: Transaction__c    
    **/
    public static Transaction__c createSingleTransactions(String transType, Decimal cash, Id investment, Integer shares){        
       
     	Transaction__c trObj = new Transaction__c();       
        trObj.Name = 'Transaction : ' + System.today();
        trObj.Transaction_Type__c = transType;        
        trObj.Investment_Account__c = invAccList[0].id;        
        if(transType == 'BUY' || transType == 'SELL'){
        	trObj.Investment__c = investment;
        	trObj.Shares__c = shares;    
        }
        
        if(transType == 'DEPOSIT' || transType == 'WITHDRAW'){
        	trObj.Cash__c = cash;
        }
        
        trObj.Transaction_Date__c = System.today();
        
       insert trObj;
       
       return trObj;
    }
    
    
     /**    
    * @Method Name : createBulkTransactions 
    * @description: Method to create bulk transaction test data     
    * @param: Integer : Number of records to create            
    * @return: Void    
    **/
    public static List<Transaction__c> createBulkTransactions(Integer tranCount, String transType, Decimal cash, List<Investment__c> investList, Integer shares){
        
        List<Transaction__c> invList = new List<Transaction__c>();
        for(Integer index = 0; index < tranCount; index++){
        	
        	Transaction__c trObj = new Transaction__c();       
	        trObj.Name = 'Transaction : ' + System.today();
	        trObj.Transaction_Type__c = transType;        
	        trObj.Investment_Account__c = invAccList[0].id;        
	        if(transType == 'BUY' || transType == 'SELL'){
	        	trObj.Investment__c = investList[index].id;
	        	trObj.Shares__c = shares;    
	        }
	        
	        if(transType == 'DEPOSIT' || transType == 'WITHDRAW'){
	        	trObj.Cash__c = cash;
	        }
	        
	        trObj.Transaction_Date__c = System.today();
	        invList.add(trObj);
        }
        
        insert invList;
        
        return invList;
       
    }
   
}