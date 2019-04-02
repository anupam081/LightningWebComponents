/*
Description: Class to test smart investor trigger and util class 
                                        
    Owner:  Certification Candidate (207295)
    Associated APEX class: TestDataCreationUtil
    Dependencies: none 
    Change History: 
    Date           Person                                   Responsible Details 
    10/15/2016     Certification Candidate (207295)         Created
*/
@isTest(SeeAllData=false)
private class TransactionAfterTriggerUtilsTest {
	static List<User> userList = new List<User>();
    Static User finAdvicerSMIUser, fundManagerSMIUser, investorSMIUser;
    
    static{
        List<String> profileNameList = new List<String>();
        profileNameList.add('SMI Financial Advisor');
        profileNameList.add('SMI Fund Manager');
        profileNameList.add('SMI Investor');
        
        List<Profile> profileList = [ SELECT Id,Name FROM profile WHERE Name IN: profileNameList];
        
        Profile finAdvicerSMIProfile, fundManagerSMIProfile, investorSMIProfile;
        
        for(Profile pro : profileList){
	        if(pro.Name == 'SMI Financial Advisor'){
	            finAdvicerSMIProfile = pro;	           
	        }else if(pro.Name == 'SMI Fund Manager'){
	            fundManagerSMIProfile = pro;	            
	        } else if(pro.Name == 'SMI Investor'){
	            investorSMIProfile = pro;	            
	        } 
        } 
        
        User finAdvicerUser = new User(alias = 'finAdv', email = 'financeadvisor@salesforce.com', 
            emailencodingkey = 'UTF-8', lastname = 'Advisor', languagelocalekey='en_US', localesidkey = 'en_US', 
            profileid = finAdvicerSMIProfile.Id, timezonesidkey = 'America/Los_Angeles', username = 'finadvisor@advdev.com');
        
        userList.add(finAdvicerUser);
        
        User fundManagerUser = new User(alias = 'fundMang', email = 'fundmanager@salesforce.com', 
            emailencodingkey = 'UTF-8', lastname = 'FundManager', languagelocalekey='en_US', localesidkey = 'en_US', 
            profileid = fundManagerSMIProfile.Id, timezonesidkey = 'America/Los_Angeles', username = 'fundmanager@advdev.com');
        
        userList.add(fundManagerUser);
        
        User investorUser = new User(alias = 'investor', email = 'investor@salesforce.com', 
            emailencodingkey = 'UTF-8', lastname = 'Investor', languagelocalekey='en_US', localesidkey = 'en_US', 
            profileid = investorSMIProfile.Id, timezonesidkey = 'America/Los_Angeles', username = 'investor@advdev.com');
        
        userList.add(investorUser);
       
        insert userList;
        
        //Get user for creating data and validate scenario
        for(User usr : userList){
	        if(usr.UserName == 'finadvisor@advdev.com'){
	            finAdvicerSMIUser = usr;
	        }else if(usr.UserName == 'fundmanager@advdev.com'){
	            fundManagerSMIUser = usr;
	        } else if(usr.UserName == 'investor@advdev.com'){
	            investorSMIUser = usr;
	        }    
        }    
    }
    
    /**
	@Method Name : testSingletransactions
    @description: Method to test single transaction insertion on investment account
    @param: None
    @return: None
    **/
    static testMethod void testSingletransactions() {
        
        Test.startTest();
        
        System.runAs(investorSMIUser) {
            TestDataCreationUtil.createInvAccount(1);
        } 
        
        System.runAs(fundManagerSMIUser) {
            TestDataCreationUtil.createInvestmentFunds(4); 
        }
        
                
        System.runAs(finAdvicerSMIUser) {
            TestDataCreationUtil.createbulkInvestments(4);
            
            
            					
				//check buy senario
				Decimal Cashvalue = TestDataCreationUtil.invAccList[0].Cash_Value__c;
            	TestDataCreationUtil.createSingleTransactions('BUY', 0, TestDataCreationUtil.investmentList[0].id, 1);
            	
            	Investment__c invObj = [select id, Investment_Account__r.Cash_Value__c, Shares__c from Investment__c where id = : TestDataCreationUtil.investmentList[0].id 
            							and Investment_Account__c = :TestDataCreationUtil.invAccList[0].id];
            	
            	system.assertEquals(Cashvalue + 1 * TestDataCreationUtil.invFundList[0].Price__c * -1 , invObj.Investment_Account__r.Cash_Value__c , 'The buy price is deducted from the investment account cash value');
            	system.assertEquals(TestDataCreationUtil.investmentList[0].Shares__c + 1  , invObj.Shares__c , 'The number of shares increased in buy scenarios on the investment');
            	
            	
            	
            	//check sell scenario
            	Cashvalue = invObj.Investment_Account__r.Cash_Value__c;
            	Decimal shares = invObj.Shares__c;
            	TestDataCreationUtil.createSingleTransactions('SELL', 0, TestDataCreationUtil.investmentList[0].id, 1);
            	invObj = [select id, Investment_Account__r.Cash_Value__c, Shares__c from Investment__c where id = : TestDataCreationUtil.investmentList[0].id 
            							and Investment_Account__c = :TestDataCreationUtil.invAccList[0].id];
            	
            	system.assertEquals(Cashvalue + 1 * TestDataCreationUtil.invFundList[0].Price__c , invObj.Investment_Account__r.Cash_Value__c , 'The sell price is added to the investment account cash value');
            	system.assertEquals(shares - 1  , invObj.Shares__c , 'The number of shares decreased in sell scenarios on the investment');
            	
            	//check deposit scenario
            	Cashvalue = invObj.Investment_Account__r.Cash_Value__c;
            	System.debug('---- cash value before deposit -- > '+Cashvalue);
            	TestDataCreationUtil.createSingleTransactions('DEPOSIT', 100, null, 0);
            	
            	Investment_Account__c invAccObj = [select id, Cash_Value__c from Investment_Account__c where id = : TestDataCreationUtil.invAccList[0].id ];     
            	System.debug('---- cash value after deposit -- > '+invAccObj.Cash_Value__c);       	
            	system.assertEquals( Cashvalue + 100 , invAccObj.Cash_Value__c ,'The deposited amount is added to investment account cash value');
            	
            	//check withdraw scenario
            	Cashvalue = invAccObj.Cash_Value__c;
            	TestDataCreationUtil.createSingleTransactions('WITHDRAW', 100, null, 0);
            	
            	invAccObj = [select id, Cash_Value__c from Investment_Account__c where id = : TestDataCreationUtil.invAccList[0].id ];
            	system.assertEquals( Cashvalue - 100 , invAccObj.Cash_Value__c , 'The deposited amount is deducted from investment account cash value');
            	
           	
            	//check rebalance scneario            	
            	
            	//make investment inactive and test
            	TestDataCreationUtil.investmentList[1].Active__c = false;
            	update TestDataCreationUtil.investmentList[1];
            	
            	Decimal investmentVal, totalActVal, targetCashVal, rebalanceAmt = 0;
            	Map<id, Investment__c> investmentMap = new Map<id, Investment__c>();
            	Decimal oldAccountCashValue = 0;
            	
            	for(Investment_Account__c act :[Select id, Cash_Value__c, Cash_Reserve_Percent__c, (Select id, Investment_Account__c, Active__c, Value__c, Shares__c, 
                                                    Price__c, Auto_Invest_Percent__c From Investments__r) 
                                                    From Investment_Account__c  where id = : TestDataCreationUtil.invAccList[0].id]){
                        System.debug('--- Account in test before rebalance -- '+ act); 
            			totalActVal = act.Cash_Value__c;
            			oldAccountCashValue = act.Cash_Value__c;
            			investmentVal = 0;
            			 for(Investment__c inv : act.Investments__r){
            			 	System.debug('--- Investment in test before rebalance -- '+ inv);
            			 	totalActVal += inv.Value__c;
            			 	investmentVal += inv.Value__c;
            			 	investmentMap.put(inv.id, inv);
            			 }
            											
            	}
            	
            	targetCashVal = totalActVal * (TestDataCreationUtil.invAccList[0].Cash_Reserve_Percent__c/100);
            	rebalanceAmt = totalActVal - targetCashVal;
            	
            	
            	System.debug('--- investmentVal -- '+ investmentVal);
            	System.debug('--- totalActVal -- '+ totalActVal);
            	System.debug('--- targetCashVal -- '+ targetCashVal);
            	System.debug('--- rebalanceAmt -- '+ rebalanceAmt);
            	            	
            	//rebalance
            	TestDataCreationUtil.createSingleTransactions('REBALANCE', 0, null, 0);
            	
            	//check the result
            	
            	System.debug('--- oldAccountCashValue -- '+ oldAccountCashValue); 
            	Decimal newAccountCashValue = 0;
            	
            	for(Investment_Account__c act :[Select id, Cash_Value__c, Cash_Reserve_Percent__c, (Select id, Investment_Account__c, Active__c, Value__c, Shares__c, 
                                                    Price__c, Auto_Invest_Percent__c From Investments__r) 
                                                    From Investment_Account__c  where id = : TestDataCreationUtil.invAccList[0].id]){
            			 
            	   
            			 System.debug('--- Account in test after rebalance -- '+ act);     
            			 newAccountCashValue = newAccountCashValue + act.Cash_Value__c;   			 
            			
            			 for(Investment__c inv : act.Investments__r){
            			 	
            			 	System.debug('--- investment in test after rebalance -- '+ inv);
            			 	
            			 	
            			 	
            			 	if(!inv.Active__c){
            			 		
            			 		system.assertEquals( inv.Shares__c , 0 , 'The share on the inactive investment is zero');
            			 		system.assertEquals( inv.Value__c , 0 , 'The value on the inactive investment is zero');
            			 		
            			 		oldAccountCashValue = oldAccountCashValue + investmentMap.get(inv.id).Shares__c * investmentMap.get(inv.id).Price__c;
            			 		
            			 	}else if(investmentMap.containskey(inv.id) && investmentMap.get(inv.id).Value__c > (rebalanceAmt * (investmentMap.get(inv.id).Auto_Invest_Percent__c/100))){
            			 		
            			 		 	
            			 		 system.assertEquals(investmentMap.get(inv.id).Shares__c - ((investmentMap.get(inv.id).Value__c - (rebalanceAmt * investmentMap.get(inv.id).Auto_Invest_Percent__c/100))/investmentMap.get(inv.id).Price__c).round(System.RoundingMode.FLOOR)  , inv.Shares__c , 'The share are sold from this investment');
            			 		 oldAccountCashValue = oldAccountCashValue + (((investmentMap.get(inv.id).Value__c - (rebalanceAmt * (investmentMap.get(inv.id).Auto_Invest_Percent__c/100)))/investmentMap.get(inv.id).Price__c).round(System.RoundingMode.FLOOR) * investmentMap.get(inv.id).Price__c);
            			 		 
            			 	}else if(investmentMap.containskey(inv.id) && investmentMap.get(inv.id).Value__c < (rebalanceAmt * (investmentMap.get(inv.id).Auto_Invest_Percent__c/100))){
            			 		
            			 		
            			 		system.assertEquals(investmentMap.get(inv.id).Shares__c + (((rebalanceAmt * investmentMap.get(inv.id).Auto_Invest_Percent__c/100) - investmentMap.get(inv.id).Value__c)/investmentMap.get(inv.id).Price__c).round(System.RoundingMode.FLOOR) , inv.Shares__c , 'The shares are bought from this investment');
            			 		oldAccountCashValue = oldAccountCashValue - (((rebalanceAmt * (investmentMap.get(inv.id).Auto_Invest_Percent__c/100)) - investmentMap.get(inv.id).Value__c)/investmentMap.get(inv.id).Price__c).round(System.RoundingMode.FLOOR)  * investmentMap.get(inv.id).Price__c;
            			 		
            			 	}else if(investmentMap.containskey(inv.id) && investmentMap.get(inv.id).Value__c == (rebalanceAmt * (investmentMap.get(inv.id).Auto_Invest_Percent__c/100))){
            			 		
            			 		system.assertEquals(investmentMap.get(inv.id).Shares__c , inv.Shares__c , 'The shares are same on this investment');
            			 		system.assertEquals(investmentMap.get(inv.id).Value__c , inv.Value__c , 'The value is also same on this investment');
            			 	} 
            			 }
            											
            	}
            	
            	system.assertEquals(oldAccountCashValue , newAccountCashValue , 'The account cash value is equal to target cash value');	 
           
        }
        
        Test.stopTest();
            
        //clean data
        delete TestDataCreationUtil.invAccList;
        
    }
    
    /**
	@Method Name : testbulktransactions
    @description: Method to test bulk transaction insertions
    @param: None
    @return: None
    **/    
	 static testMethod void testbulktransactions() {
 	   
 	   Test.startTest();
 	   
 	   System.runAs(investorSMIUser) {
         TestDataCreationUtil.createInvAccount(1);
        } 
        
        System.runAs(fundManagerSMIUser) {
            TestDataCreationUtil.createInvestmentFunds(400);
        }
        
         System.runAs(investorSMIUser) {
            TestDataCreationUtil.createbulkInvestments(100);
            
				
				
				Decimal accCashValue = TestDataCreationUtil.invAccList[0].Cash_Value__c;
				
				//deposit scenario
            	TestDataCreationUtil.createBulkTransactions(100, 'DEPOSIT', 10, NULL, 0);
            	
            	Investment_Account__c invAccObj = [select id, Cash_Value__c from Investment_Account__c where id = : TestDataCreationUtil.invAccList[0].id ];
            	
            	system.assertEquals(accCashValue + (100 * 10) , invAccObj.Cash_Value__c , 'The cash value have increased after deposit');
            	
            	accCashValue = invAccObj.Cash_Value__c;
            	
            	
            	//Buy scenario
            	Map<id,Investment__c> investMap = new Map<id,Investment__c>();
            	//investMap.putAll(TestDataCreationUtil.investmentList);
            	
            	for(Investment__c inv : TestDataCreationUtil.investmentList){
            		investMap.put(inv.id, inv);
            	}
            	
            	
            	Map<id,Decimal> invest2SharesMap = new Map<id,Decimal>();
            	
            	
            	List<Transaction__c> tranList = TestDataCreationUtil.createBulkTransactions(100, 'BUY', 0, TestDataCreationUtil.investmentList, 1);
            	
            	for(Transaction__c tr : tranList){
            		if(tr.Investment__c != null){
            			invest2SharesMap.put(tr.Investment__c, tr.Shares__c);
            		}
            		
            		if(tr.Investment__c !=  null){
            			accCashValue = accCashValue - (tr.Shares__c * TestDataCreationUtil.invFundList[0].Price__c);
            			
            		}
            	}
            	
            	Map<id,Investment__c> investmntMap = new Map<id,Investment__c>();
            	
            	for(Investment__c inv : [select id, Investment_Account__r.Cash_Value__c, Shares__c from Investment__c where Investment_Account__c = :TestDataCreationUtil.invAccList[0].id]){
            		
            		system.assertEquals(accCashValue , inv.Investment_Account__r.Cash_Value__c , 'The cash value has decreased after buy');
            		
            		if(investMap.containskey(inv.id)){
            		   system.assertEquals(inv.Shares__c , invest2SharesMap.get(inv.id) + investMap.get(inv.id).Shares__c , 'The number of shares has increased after buy');
            		   investmntMap.put(inv.id, inv);
            		}
            	
            	}
            	
            	
            	//sell scenario
            	tranList = new List<Transaction__c>();
            	invest2SharesMap = new Map<id,Decimal>();
            	tranList = TestDataCreationUtil.createBulkTransactions(100, 'SELL', 0, TestDataCreationUtil.investmentList, 1);
            	
            	for(Transaction__c tr : tranList){
            		if(tr.Investment__c != null){
            			invest2SharesMap.put(tr.Investment__c, tr.Shares__c);
            		}
            		
            		if(tr.Investment__c !=  null ){
            			accCashValue = accCashValue + (tr.Shares__c * TestDataCreationUtil.invFundList[0].Price__c);
            			
            		}
            	}
            	
            	System.debug('--- accCashValue---' + accCashValue);
            	
            	for(Investment__c inv : [select id, Investment_Account__r.Cash_Value__c, Shares__c from Investment__c where Investment_Account__c = :TestDataCreationUtil.invAccList[0].id]){
            		
            		System.debug('--- inv.Investment_Account__r.Cash_Value__c---' + inv.Investment_Account__r.Cash_Value__c);
            		system.assertEquals(accCashValue , inv.Investment_Account__r.Cash_Value__c , 'The cash value has increased after sell');
            		
            		if(investMap.containskey(inv.id)){
            		   
            		   system.assertEquals(inv.Shares__c , investmntMap.get(inv.id).Shares__c - invest2SharesMap.get(inv.id) , 'The number of shares has decrease after sell');
            		}
            	
            	}
            	
            	
            	
            	//WITHDRAW scenario
            	TestDataCreationUtil.createBulkTransactions(100, 'WITHDRAW', 10, NULL, 0);
            	invAccObj = [select id, Cash_Value__c from Investment_Account__c where id = : TestDataCreationUtil.invAccList[0].id ];
            	
            	system.assertEquals(accCashValue - (100 * 10) , invAccObj.Cash_Value__c , 'The cash value have decreased after withdraw');
            	
            	accCashValue = invAccObj.Cash_Value__c;
            	
           
            	
            	//REBALANCE scenario
            	
            	//increase no of share on one investment
            	TestDataCreationUtil.investmentList[0].Shares__c = 20;
            	update TestDataCreationUtil.investmentList[0];
            	
            	Decimal investmentVal, totalActVal, targetCashVal, rebalanceAmt = 0;
            	Map<id, Investment__c> investmentMap = new Map<id, Investment__c>();
            	Decimal oldAccountCashValue = 0;
            	
            	for(Investment_Account__c act :[Select id, Cash_Value__c, Cash_Reserve_Percent__c, (Select id, Investment_Account__c, Active__c, Value__c, Shares__c, 
                                                    Price__c, Auto_Invest_Percent__c From Investments__r) 
                                                    From Investment_Account__c  where id = : TestDataCreationUtil.invAccList[0].id]){
                        System.debug('--- Account in test before rebalance -- '+ act); 
            			totalActVal = act.Cash_Value__c;
            			oldAccountCashValue = act.Cash_Value__c;
            			investmentVal = 0;
            			 for(Investment__c inv : act.Investments__r){
            			 	System.debug('--- Investment in test before rebalance -- '+ inv);
            			 	totalActVal += inv.Value__c;
            			 	investmentVal += inv.Value__c;
            			 	investmentMap.put(inv.id, inv);
            			 }
            											
            	}
            	
            	targetCashVal = totalActVal * (TestDataCreationUtil.invAccList[0].Cash_Reserve_Percent__c/100);
            	rebalanceAmt = totalActVal - targetCashVal;
            	
            	
            	System.debug('--- investmentVal -- '+ investmentVal);
            	System.debug('--- totalActVal -- '+ totalActVal);
            	System.debug('--- targetCashVal -- '+ targetCashVal);
            	System.debug('--- rebalanceAmt -- '+ rebalanceAmt);
            	
            	//create rebalance record
            	TestDataCreationUtil.createBulkTransactions(1, 'REBALANCE', 100, NULL, 0);
            	
            	//check the result
            	
            	System.debug('--- oldAccountCashValue -- '+ oldAccountCashValue); 
            	Decimal newAccountCashValue = 0;
            	
            	for(Investment_Account__c act :[Select id, Cash_Value__c, Cash_Reserve_Percent__c, (Select id, Investment_Account__c, Active__c, Value__c, Shares__c, 
                                                    Price__c, Auto_Invest_Percent__c From Investments__r) 
                                                    From Investment_Account__c  where id = : TestDataCreationUtil.invAccList[0].id]){
            			 
            	   
            			 System.debug('--- Account in test after rebalance -- '+ act);     
            			 newAccountCashValue = newAccountCashValue + act.Cash_Value__c;   			 
            			
            			 for(Investment__c inv : act.Investments__r){
            			 	
            			 	System.debug('--- investment in test after rebalance -- '+ inv);
            			 	
            			 	
            			 	
            			 	if(!inv.Active__c){
            			 		
            			 		system.assertEquals( inv.Shares__c , 0 , 'The share on the inactive investment is zero');
            			 		system.assertEquals( inv.Value__c , 0 , 'The value on the inactive investment is zero');
            			 		
            			 		oldAccountCashValue = oldAccountCashValue + investmentMap.get(inv.id).Shares__c * investmentMap.get(inv.id).Price__c;
            			 		
            			 	}else if(investmentMap.containskey(inv.id) && investmentMap.get(inv.id).Value__c > (rebalanceAmt * (investmentMap.get(inv.id).Auto_Invest_Percent__c/100))){
            			 		
            			 		 	
            			 		 system.assertEquals(investmentMap.get(inv.id).Shares__c - ((investmentMap.get(inv.id).Value__c - (rebalanceAmt * investmentMap.get(inv.id).Auto_Invest_Percent__c/100))/investmentMap.get(inv.id).Price__c).round(System.RoundingMode.FLOOR)  , inv.Shares__c , 'The share are sold from this investment');
            			 		 oldAccountCashValue = oldAccountCashValue + (((investmentMap.get(inv.id).Value__c - (rebalanceAmt * (investmentMap.get(inv.id).Auto_Invest_Percent__c/100)))/investmentMap.get(inv.id).Price__c).round(System.RoundingMode.FLOOR) * investmentMap.get(inv.id).Price__c);
            			 		 
            			 	}else if(investmentMap.containskey(inv.id) && investmentMap.get(inv.id).Value__c < (rebalanceAmt * (investmentMap.get(inv.id).Auto_Invest_Percent__c/100))){
            			 		
            			 		
            			 		system.assertEquals(investmentMap.get(inv.id).Shares__c + (((rebalanceAmt * investmentMap.get(inv.id).Auto_Invest_Percent__c/100) - investmentMap.get(inv.id).Value__c)/investmentMap.get(inv.id).Price__c).round(System.RoundingMode.FLOOR) , inv.Shares__c , 'The shares are bought for this investment');
            			 		oldAccountCashValue = oldAccountCashValue - (((rebalanceAmt * (investmentMap.get(inv.id).Auto_Invest_Percent__c/100)) - investmentMap.get(inv.id).Value__c)/investmentMap.get(inv.id).Price__c).round(System.RoundingMode.FLOOR)  * investmentMap.get(inv.id).Price__c;
            			 		
            			 	}else if(investmentMap.containskey(inv.id) && investmentMap.get(inv.id).Value__c == (rebalanceAmt * (investmentMap.get(inv.id).Auto_Invest_Percent__c/100))){
            			 		
            			 		system.assertEquals(investmentMap.get(inv.id).Shares__c , inv.Shares__c , 'The shares are same on this investment');
            			 		system.assertEquals(investmentMap.get(inv.id).Value__c , inv.Value__c , 'The value is also same on this investment');
            			 	} 
            			 }
            											
            	}
            	
            	system.assertEquals(oldAccountCashValue , newAccountCashValue , 'The account cash value is equal to target cash value');	 
            	
            	
            	//check rollback and error scenario.
            	TestDataCreationUtil.investmentList[0].Auto_Invest_Percent__c = 60;
            	update TestDataCreationUtil.investmentList[0];
            	
            	TestDataCreationUtil.createBulkTransactions(1, 'REBALANCE', 100, NULL, 0); // assuming only one rebalance transaction is enough to do rebalance
            	invAccObj = [select id, Cash_Value__c from Investment_Account__c where id = : TestDataCreationUtil.invAccList[0].id ];
            	
            	system.assertEquals(newAccountCashValue , invAccObj.Cash_Value__c , 'The cash value has not changed');
            	
            
        }
        
        Test.stopTest();
        
	 }
     
}