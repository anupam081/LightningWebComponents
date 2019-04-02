/*
Description: Extension class to do update investment account and rebalance investments
                                        
    Owner:  Certification Candidate (207295)
    Associated APEX class: none
    Dependencies: none 
    Change History: 
    Date           Person                                   Responsible Details 
    10/02/2016     Certification Candidate (207295)         Created
*/

public with sharing class InvestmentAccViewPageExt {
    
    //Variable and properties declaration start
    public Investment_Account__c invAccount;
    private integer index = 1;   
    
    public Decimal investmentValue{get;set;}
    public Decimal totalAccValue{get;set;}
    public List<Investment__c> invList{get; set;}
    public List<Investment__c> tempinvList{get; set;} 
    public Boolean isRebalance{get;set;}
   //Variable and properties declaration End      
    
    
    
    /**
    @Method Name : InvestmentAccViewPageExt
    @description: Extension constructor
    @param: ApexPages.StandardController
    @return: None
    **/
    public InvestmentAccViewPageExt(ApexPages.StandardController stdController) {
        
        try{
            this.invAccount = (Investment_Account__c)stdController.getRecord();
            
            isRebalance = false;
            
            if(invAccount != null){
                fetchInvestments();
            }
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, CustomExceptionMessagesUtil.getDMLExceptionMessage(e.getMessage())));
        }
    }
    
    /**
    @Method Name : fetchInvestments
    @description: Method to fetch investment on an investment account and calculate total account value and investment value
    @param: None
    @return: None
    **/
    private void fetchInvestments(){
         invList = new List<Investment__c>();
         investmentValue = 0;
         totalAccValue = 0;
         for(Investment__c inv : [Select Active__c,Shares__c, Price__c, Value__c, Auto_Invest_Percent__c, name, Trading_Symbol__c,
                                    Investment_Account__c From Investment__c  where Investment_Account__c =: invAccount.id
                                    order by Auto_Invest_Percent__c desc, Trading_Symbol__c asc]){
            investmentValue = (investmentValue + inv.Value__c).setScale(2);
            invList.add(inv);
         }
        totalAccValue = (investmentValue + invAccount.Cash_Value__c).setScale(2);
    }
    
    
    /**
    @Method Name : rebalance
    @description: Method called on Rebalance click button on the page. It changes the layout to figure 2 with pagination and edit capability on the investment
    @param: None
    @return: None
    **/
    public PageReference rebalance(){
        try{
        
            isRebalance = true;
            refreshinvestments();
            return null;
            
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, CustomExceptionMessagesUtil.getDMLExceptionMessage(e.getMessage())));
            return null;
        }

        
        return null;
    }
    
    /**
    @Method Name : profileName 
    @description: Method to return profile name for which page override is not required
    @param: None
    @return: None
    **/ 
    public String profileName {
        get {
            return SmartInvestorConstants.PROFILENAME;
        }
        set;
    }
    
    
    
    
    /**
    @Method Name : refreshinvestments
    @description: Method to refresh list with investment records to be show on each page during pagination
    @param: None
    @return: None
    **/   
    public void refreshinvestments(){
        
        
        tempinvList = new List<Investment__c>();
        
        System.debug('-- index-- '+index );
        System.debug('-- invList before refresh-- '+invList );
        
        Integer lastIndex = Math.Ceil(gettotalPage()) == index ? invList.size() : (SmartInvestorConstants.pageSize * index)  ; 
        
        System.debug('-- lastIndex-- '+lastIndex );         
        
        //update the temp list to show in the pagination table
        for(Integer i = ((index-1) * SmartInvestorConstants.pageSize); i < lastIndex ; i++){
            System.debug('-- refresh inv-- '+invList.get(i) );
            tempinvList.add(invList.get(i));
        }   
    
    }
    
    /**
    @Method Name : addChangedInvestment 
    @description: Method to refresh list with investment records to be show on each page during pagination
    @param: None
    @return: None
    **/ 
    private void addChangedInvestment(){
        
        try{
            if(tempinvList.size() > 0){
                Integer orgIndex = (index -1) * SmartInvestorConstants.pageSize;
                System.debug('-- Add index-- '+orgIndex );
                for(Investment__c inv : tempinvList){
                    System.debug('-- Add inv-- '+inv );
                    invList.set(orgIndex, inv);
                    orgIndex++;
                }
                System.debug('-- invList after add-- '+invList );
            }
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, CustomExceptionMessagesUtil.getDMLExceptionMessage(e.getMessage())));
            
        }
    }
    
    
    /**
    @Method Name : rebalanceNow 
    @description: Method called after rebalance now button click on the page. It validates the investment record, 
                  saves it and create rebalance transaction the investment account.
    @param: None
    @return: None
    **/    
    public PageReference rebalanceNow(){
        
        //Set savepoint for rollback
        Savepoint sp = Database.setSavepoint();
        try{
            Decimal totalAutoInvPercentage = 0;  
            Integer totalActiveInvestment = 0;  
            
                    
            addChangedInvestment();
            
            //error scenarios    
            for(Investment__c inv : invList){
                
                if(!inv.Active__c && inv.Auto_Invest_Percent__c != null && inv.Auto_Invest_Percent__c != 0){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, CustomExceptionMessagesUtil.getInactiveAutoPercentageExceptionMessage()));
                    return null;
                }
                
                if(inv.Active__c && inv.Auto_Invest_Percent__c != null){
                    totalAutoInvPercentage = totalAutoInvPercentage + inv.Auto_Invest_Percent__c;
                    totalActiveInvestment++;
                }
                
                if(totalAutoInvPercentage > 100){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, CustomExceptionMessagesUtil.getTotalInvestPercentageExceptionMessage()));
                    return null;
                }
                
                if(totalActiveInvestment > 100){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, CustomExceptionMessagesUtil.getActiveInvestmentExceptionMessage()));
                    return null;
                }
                
            }
            
            
            if(invList.size() > 0){
                //update investment
                update invList;
                
                //create rebalance transaction
                Transaction__c trObj = new Transaction__c();
                trObj.Investment_Account__c = invAccount.id;
                trObj.Transaction_Date__c = System.today();
                trObj.Transaction_Type__c = SmartInvestorConstants.TRANSACTIONTYPE_REBALANCE;
                
                insert trObj;
                
                //redirect to main page.
                PageReference pr = new PageReference(SmartInvestorConstants.HOMEPAGEURL + invAccount.id);
                pr.setRedirect(true);
                return pr;
            }
            return null;
            
        }catch(Exception e){
            //Rollback transaction to the initial savepoint
            Database.rollback(sp);            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, CustomExceptionMessagesUtil.getDMLExceptionMessage(e.getMessage())));          
            return null;
        }
    }
    
    /**
    @Method Name : gettotalPage 
    @description: Method to return total number of pages during pagination
    @param: None
    @return: None
    **/     
    public Decimal gettotalPage(){
        if(invList.size() > 0){
            return (invList.size()/(Decimal)SmartInvestorConstants.pageSize) == 0 ? 1 : (invList.size()/(Decimal)SmartInvestorConstants.pageSize) ;
        }
        
        return 1;
    }
    
    /**
    @Method Name : getrecordcountonPage 
    @description: Method to return record count on each page during pagination
    @param: None
    @return: None
    **/     
    public String getrecordcountonPage(){
        
        String recCount;
    
        
        if(index * SmartInvestorConstants.pageSize > invList.size()){
            
                recCount = (index * SmartInvestorConstants.pageSize + 1) - SmartInvestorConstants.pageSize + '-' +invList.size();
            
        }else{
                recCount = (index * SmartInvestorConstants.pageSize + 1) - SmartInvestorConstants.pageSize + '-' +index * SmartInvestorConstants.pageSize;
            }
        
        return recCount;
    }
    
    
    /**
    @Method Name : pageNumber 
    @description: Method to return current page number during pagination
    @param: None
    @return: None
    **/ 
    public Integer pageNumber {
        get {
            return index;
        }
        set;
    }
    
    
    /**
    @Method Name : hasNext 
    @description: Method to check if next page has any records during pagination
    @param: None
    @return: None
    **/
    public Boolean hasNext {
        get {
            if((index * SmartInvestorConstants.pageSize) >= invList.size()){
                return false;
            }else{
                return true;
            }
        }
        set;
    }
    
    /**
    @Method Name : hasPrevious 
    @description: Method to check whether there are more records before the current page set during pagination
    @param: None
    @return: None
    **/
      public Boolean hasPrevious {
            get {
                
                if(index == 1){
                    return false;
                }else{
                    return true;
                }
            }
            set;
        }
        
    
   /**
    @Method Name : next 
    @description: Method to change page number to next page during pagination
    @param: None
    @return: None
    **/ 
    public void next() {
         addChangedInvestment();
         index = index + 1;
         refreshinvestments();
   
    }
    
    
    /**
    @Method Name : first 
    @description: Method to change page number to first page during pagination
    @param: None
    @return: None
    **/
     public void first() {
         addChangedInvestment();    
         index = 1; 
         refreshinvestments();
     
     }
    
    
    /**
    @Method Name : last 
    @description: Method to change page number to last page during pagination
    @param: None
    @return: None
    **/
     public void last() {
         addChangedInvestment();
         index = (Integer)Math.ceil(gettotalPage());
         refreshinvestments();
     
     }
     
     
    /**
    @Method Name : previous 
    @description: Method to change page number to previous page during pagination
    @param: None
    @return: None
    **/
      public void previous() {
          addChangedInvestment();
          index = index - 1;
          refreshinvestments();
        
     }
     
    
}