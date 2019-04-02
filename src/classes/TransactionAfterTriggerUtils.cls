/*
Description: Trigger util class to update fields on the below object
                (a) The Cash Value [Cash_Value__c] on the Investment Account needs to be updated for DEPOSIT or WITHDRAW or BUY or SELL transaction.
                (b) The number of Shares [Shares__c] on the Investment needs to be updated for buy or sell transaction.
                (c) For a REBALANCE transaction
                    - Calculate the Total Account Value for the Investment Account.
                    - Calculate the “Target Cash Value” that needs to be left in the Investment Account in order to honor the Cash Reserve Percent   
                    - Create automatic transactions for sell and buy transactions
                        
    Owner:  Certification Candidate (207295)
    Associated APEX class: none
    Dependencies: none 
    Change History: 
    Date           Person                                   Details 
    02/02/2016     Certification Candidate (207295)         Created
*/

public with sharing class TransactionAfterTriggerUtils{
        
       
        
         /**
        @Method Name : processOnTransactionInsert
        @description: Method to process all transaction records in insert scenario.
        @param: List<Transaction__c >
        @return: None
        **/
        public void processOnTransactionInsert(List<Transaction__c > newList){
        
            /*Variable declaration*/
            Map<Id, Decimal> acc2cashValueMap = new Map<Id, Decimal>(); //map to hold acc id vs cash value
            Map<Id, Decimal> inv2SharesMap = new Map<Id, Decimal>(); //map to hold investment id vs no of shares
            Map<Id, Decimal> acc2TotalAccValMap = new Map<Id, Decimal>(); // map to hold acc id vs total account value
            Set<Id> accountIdSet = new Set<id>(); // for all other transactions except rebalance
            Set<Id> invIdSet = new Set<id>(); // for all other transactions except rebalance
            Set<Id> accIdSet = new Set<id>(); // account id for rebalance transactions
            Map<String, Date> acc2transDateMap = new Map<String, Date>(); // for rebalance transaction
            Decimal cashToUpdateAcc; //to get total account cash value
            Savepoint sp;  //savepoint variable
           
            
            try{
                
                /*Loop through the transaction list to collect accid and investment id*/
                for(Transaction__c tr : newList){
                    if(tr.Transaction_Type__c == SmartInvestorConstants.TRANSACTIONTYPE_SELL || tr.Transaction_Type__c == SmartInvestorConstants.TRANSACTIONTYPE_DEPOSIT 
                    	|| tr.Transaction_Type__c == SmartInvestorConstants.TRANSACTIONTYPE_BUY || tr.Transaction_Type__c == SmartInvestorConstants.TRANSACTIONTYPE_WITHDRAW){
                        
                        if(tr.Investment__c != null ){
                            invIdSet.add(tr.Investment__c);
                        }
                        
                        if(tr.Investment_Account__c != null){
                            accountIdSet.add(tr.Investment_Account__c);
                        }
                        
                        
                    }else{
                            
                            if(!acc2transDateMap.containsKey(tr.Investment_Account__c) && tr.Investment_Account__c != null && tr.Transaction_Type__c != null){
                                acc2transDateMap.put(tr.Investment_Account__c, System.today());
                            }
                            
                            if(tr.Investment_Account__c != null && tr.Transaction_Type__c != null){
                                accIdSet.add(tr.Investment_Account__c); 
                                acc2transDateMap.put(tr.Investment_Account__c, tr.Transaction_Date__c);  //assuming only one rebalance transaction per account                      
                            }
                    }
                    
                }
                
                System.debug('accIdSet--- '+accIdSet);
                System.debug('invIdSet--- '+invIdSet);
                
                
                /*Fetch all the investments*/
                Map<Id,Investment__c> investmentMap;
                
                if((invIdSet.size() > 0 || accountIdSet.size() > 0) && Limits.getLimitQueries()  > 0){
                    investmentMap = new Map<Id,Investment__c>([Select Price__c, Active__c,Shares__c,Investment_Account__r.Cash_Reserve_Percent__c, Investment_Account__r.Cash_Value__c, 
                                      Investment_Account__r.Id, Investment_Account__c From Investment__c  where id in : invIdSet
                                      or Investment_Account__c in : accountIdSet]);
                }
                
                
                  System.debug('investmentMap--- '+investmentMap);            
                            
                /*calculate the cash and shares to update*/                 
                
                if(investmentMap != null && investmentMap.size() > 0 ){
                
                    for(Transaction__c tr : newList){ 
                        
                        cashToUpdateAcc = 0;
                        
                        
                            
                        //add key to the map if not added for investments
                        if(!inv2SharesMap.containskey(tr.Investment__c) && tr.Transaction_Type__c != SmartInvestorConstants.TRANSACTIONTYPE_REBALANCE && tr.Investment__c != null){
                            inv2SharesMap.put(tr.Investment__c, 0);
                        }
                        
                        //add key to the map if not added
                        if(!acc2cashValueMap.containskey(tr.Investment_Account__c) && tr.Transaction_Type__c != SmartInvestorConstants.TRANSACTIONTYPE_REBALANCE && tr.Investment_Account__c != null){
                            acc2cashValueMap.put(tr.Investment_Account__c, 0);
                        }  
                        
                                        
                        System.debug('tr.Transaction_Amount__c == '+tr.Transaction_Amount__c);    
                        System.debug('tr.Transaction_Type__c == '+tr.Transaction_Type__c); 
                        
                        
                        //calculate total cash values and increase it in account cash
                        if(tr.Transaction_Type__c == SmartInvestorConstants.TRANSACTIONTYPE_SELL && investmentMap.get(tr.Investment__c) != null && investmentMap.get(tr.Investment__c).Price__c != null){                        
                            cashToUpdateAcc = acc2cashValueMap.get(tr.Investment_Account__c) + (investmentMap.get(tr.Investment__c).Price__c * tr.Shares__c);                                               
                            acc2cashValueMap.put(tr.Investment_Account__c, cashToUpdateAcc);
                            inv2SharesMap.put(tr.Investment__c, -tr.Shares__c);
                        }
                        
                        //calculate total cash values and increase it in account cash
                        if(tr.Transaction_Type__c == SmartInvestorConstants.TRANSACTIONTYPE_DEPOSIT  &&  tr.Cash__c != null){                        
                            cashToUpdateAcc = acc2cashValueMap.get(tr.Investment_Account__c) + tr.Cash__c;
                            acc2cashValueMap.put(tr.Investment_Account__c, cashToUpdateAcc);
                        }
                        
                         //calculate total cash values and decrease it from account cash
                        if(tr.Transaction_Type__c == SmartInvestorConstants.TRANSACTIONTYPE_BUY  && investmentMap.get(tr.Investment__c) != null && investmentMap.get(tr.Investment__c).Price__c != null){                       
                            cashToUpdateAcc = acc2cashValueMap.get(tr.Investment_Account__c) + (investmentMap.get(tr.Investment__c).Price__c * tr.Shares__c * -1);                         
                            acc2cashValueMap.put(tr.Investment_Account__c, cashToUpdateAcc);
                            inv2SharesMap.put(tr.Investment__c, tr.Shares__c);
                        }
                        
                         //calculate total cash values and decrease it from account cash
                        if(tr.Transaction_Type__c == SmartInvestorConstants.TRANSACTIONTYPE_WITHDRAW &&  tr.Cash__c != null){                       
                            cashToUpdateAcc = acc2cashValueMap.get(tr.Investment_Account__c) - tr.Cash__c;
                            acc2cashValueMap.put(tr.Investment_Account__c, cashToUpdateAcc);
                        }
                                         
                    }
                }
                
                
                     System.debug('acc2cashValueMap--- '+acc2cashValueMap);
                     System.debug('inv2SharesMap--- '+inv2SharesMap);
                    
                    //Set savepoint for rollback
                    sp = Database.setSavepoint();
                    
                    //update investment account
                    if(acc2cashValueMap.size() > 0 && investmentMap.size() > 0 ){                       
                        updateInvestmentAccount(acc2cashValueMap, investmentMap);
                    }
                    
                    //update investment
                    if(inv2SharesMap.size() > 0 && investmentMap.size() > 0){
                        updateInvestmentshares(inv2SharesMap, investmentMap);
                    }
                    
                    //create transaction records for rebalance 
                    if(accIdSet.size() > 0){
                        createRebalanceTransactions(accIdSet, acc2transDateMap);
                    }
                    
                    
        
           }catch(Exception e){
                
                //Rollback transaction to the initial savepoint
                Database.rollback(sp); 
                
                System.debug('-----Trigger Exception message------ :Message:- '+e.getMessage() +', Cause :- '+e.getCause() + ', --LineNumber:- '+e.getLineNumber());
            }
        }
        
        
         /**
        @Method Name : updateInvestmentAccount
        @description: Method to update the cash value on the investment account on transactions.
        @param: Map<Id, Decimal>
        @return: None
        **/
        public void updateInvestmentAccount(Map<Id, Decimal> updateAccMap, Map<id, Investment__c> investmentMap){
            
            System.debug('------------updateAccMap---------- :'+updateAccMap);
            
            List<Investment_Account__c> accUpdateList = new List<Investment_Account__c>();
              
	           set<Id> accountIdSet = new Set<Id>(); //set to hold unique account id's
	           
	           //iterate through investment to get the account cash and update it .
	           for(Investment__c inv : investmentMap.values()){
	                if(!accountIdSet.contains(inv.Investment_Account__c)){
		                Investment_Account__c accObj = new Investment_Account__c(id=inv.Investment_Account__c);
		                accObj.Cash_Value__c = inv.Investment_Account__r.Cash_Value__c + updateAccMap.get(inv.Investment_Account__c);
		                accUpdateList.add(accObj);
		                accountIdSet.add(inv.Investment_Account__c);
	                }
	            }
            
            //if update list is greater than zero update account
            if(accUpdateList.size() > 0 && Limits.getLimitDMLStatements() > 0){
                update accUpdateList;
            }
        }
    
    
        /**
        @Method Name : updateInvestmentshares
        @description: Method to update shares on the related investment records for an investment record on transaction insert.
        @param: Map<Id, Decimal>, Map<Id, Investment__c>
        @return: None
        **/
       public void updateInvestmentshares(Map<Id, Decimal> updateInvMap, Map<Id, Investment__c> invMap){
            
            System.debug('------------updateInvMap---------- :'+updateInvMap);
            
            List<Investment__c> invUpdateList = new List<Investment__c>();
            
            //iterate through investment to update shares
            for(Id invId : updateInvMap.keyset()){
                Investment__c invObj = new Investment__c(id=invId);
                invObj.Shares__c = invMap.get(invId).Shares__c + updateInvMap.get(invId);
                invUpdateList.add(invObj);
            }
           
     		//if update list is greater than zero update investments
            if(invUpdateList.size() > 0 && Limits.getLimitDMLStatements() > 0){
                update invUpdateList;
            }
        }
        
        
        /**
        @Method Name : createRebalanceTransactions
        @description: Method to rebalance investment records for an investment account on rebalance transaction insert.
        @param: Set<id>, Map<String, Date>
        @return: None
        **/
       public void createRebalanceTransactions(Set<id> accountids, Map<String, Date> tranDateMap){
            
             Map<Id, Decimal> acc2TotalAccValMap = new Map<Id, Decimal>(); // map to hold acc id vs total account value
             Map<Id, Decimal> acc2TargetCashValMap = new Map<Id, Decimal>(); // map to hold acc id vs total account value
             Map<Id, Decimal> acc2RebalanceAmtMap = new Map<Id, Decimal>(); // map to hold acc id vs total account value
             Set<Investment_Account__c> invAccountSet = new Set<Investment_Account__c>(); // set to hold account and investment records
             List<Transaction__c> transInsertList = new List<Transaction__c>(); // list to collect all rebalance transactions to be inserted
                         
             /*iterate to calculate the total account value*/
             if(Limits.getLimitQueries() > 0  && accountids.size() > 0 && Limits.getLimitQueries()  > 0){
                for(Investment_Account__c invAct : [Select id, Cash_Value__c, Cash_Reserve_Percent__c, (Select Investment_Account__c, Active__c, Value__c, Shares__c, 
                                                    Price__c, Auto_Invest_Percent__c From Investments__r) 
                                                    From Investment_Account__c  where id in : accountids]){
                                    
                    if(!acc2TotalAccValMap.containskey(invAct.id) && invAct.id != null){
                        acc2TotalAccValMap.put(invAct.id, 0);
                    }
                    
                    if(invAct.Cash_Value__c != null){
                        acc2TotalAccValMap.put(invAct.id, invAct.Cash_Value__c);
                    }
                    
                    if(invAct.Investments__r != null && invAct.Investments__r.size() > 0){
                        for(Investment__c inv : invAct.Investments__r){
                            if(inv.Value__c != null){
                                acc2TotalAccValMap.put(invAct.id, acc2TotalAccValMap.get(inv.Investment_Account__c) + inv.Value__c);
                            }
                        }
                    }
                    
                    // add account to invAccountSet
                    invAccountSet.add(invAct);
                
                }
             }
             
             System.debug('------------acc2TotalAccValMap---------- :'+acc2TotalAccValMap);        
             
             
            /*iterate to calculate the target cash value and rebalance amount*/
            if(invAccountSet.size() > 0){
                for(Investment_Account__c invAct : invAccountSet){
                    
                    if(!acc2TargetCashValMap.containskey(invAct.id) && invAct.id != null){
                        acc2TargetCashValMap.put(invAct.id, 0);
                    }
                    
                    if(!acc2RebalanceAmtMap.containskey(invAct.id) && invAct.id != null){
                        acc2RebalanceAmtMap.put(invAct.id, 0);
                    }
                    
                    //calcuate target cash value on account is null treat it as zero.
                    if(invAct.Cash_Reserve_Percent__c != null){
                   		 acc2TargetCashValMap.put(invAct.id, (acc2TotalAccValMap.get(invAct.id) * invAct.Cash_Reserve_Percent__c/100));
                    }else{
                    	 acc2TargetCashValMap.put(invAct.id, (acc2TotalAccValMap.get(invAct.id) * 0));
                    }  
                    
                    
                    //calcuate rebalance amount on account
                    acc2RebalanceAmtMap.put(invAct.id, (acc2TotalAccValMap.get(invAct.id) - acc2TargetCashValMap.get(invAct.id)));
                    
                    
                    
                    /*iterate investments records to create rebalance transactions*/
                    for(Investment__c inv : invAct.Investments__r){             
                        
                        //if the investment is not active create SELL transaction
                        if(!inv.Active__c){
                            if(inv.Shares__c >= 1){
                                transInsertList.add(createTransactionObjects(invAct.id, inv.id, inv.Shares__c, tranDateMap.get(invAct.id), SmartInvestorConstants.TRANSACTIONTYPE_SELL));
                            }
                        }
                        
                        //Sell transaction where value on investment is greater than rebalance amount * auto invest percentage
                        if(inv.Active__c && inv.Value__c > (acc2RebalanceAmtMap.get(invAct.id) * inv.Auto_Invest_Percent__c/100)){
                            
                            Decimal noOfshares = (inv.Value__c - (acc2RebalanceAmtMap.get(invAct.id) * inv.Auto_Invest_Percent__c/100))/inv.Price__c;
                            
                            if(noOfshares >= 1){                
                                transInsertList.add(createTransactionObjects(invAct.id, inv.id, noOfshares.round(System.RoundingMode.FLOOR), tranDateMap.get(invAct.id), SmartInvestorConstants.TRANSACTIONTYPE_SELL));
                            }
                        }
                        
                        //Buy transaction where value on investment is less than rebalance amount * auto invest percentage
                        if(inv.Active__c && inv.Value__c < (acc2RebalanceAmtMap.get(invAct.id) * inv.Auto_Invest_Percent__c/100)){
                            
                            Decimal noOfshares = ((acc2RebalanceAmtMap.get(invAct.id) * inv.Auto_Invest_Percent__c/100) - inv.Value__c)/inv.Price__c;
                            
                            if(noOfshares >= 1){ 
                                transInsertList.add(createTransactionObjects(invAct.id, inv.id, noOfshares.round(System.RoundingMode.FLOOR), tranDateMap.get(invAct.id), SmartInvestorConstants.TRANSACTIONTYPE_BUY));
                            }
                        }
                        
                    }
                }
                
                system.debug('-------transInsertList------'+transInsertList);
                //if insert list is greater than zero insert transactions
                if(transInsertList.size() > 0 && Limits.getLimitDMLStatements() > 0){
                    insert transInsertList;
                }
          }
         
        }
        
        
         /**
        @Method Name : createTransactionObjects
        @description: Method to create rebalance transaction records.
        @param: Id, Id, Decimal, Data, String
        @return: None
        **/
       private Transaction__c createTransactionObjects(Id AccId, Id invId, Decimal shares, Date tranDate, String tranType){
            
            Transaction__c tranObj = new Transaction__c();
            tranObj.Investment_Account__c = AccId;
            tranObj.Investment__c = invId;
            tranObj.Shares__c = shares; 
            tranObj.Transaction_Date__c = tranDate; 
            tranObj.Transaction_Type__c = tranType;
            
            return tranObj;
        }

}