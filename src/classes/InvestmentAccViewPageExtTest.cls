/*
Description: Class to test smart investor trigger and util class 
                                        
    Owner:  Certification Candidate (207295)
    Associated APEX class: InvestmentAccViewPageExt
    Dependencies: none 
    Change History: 
    Date           Person                                   Responsible Details 
    10/15/2016     Certification Candidate (207295)         Created
*/
@isTest(SeeAllData=false)
private class InvestmentAccViewPageExtTest {

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
	@Method Name : testPageflow
    @description: Method to test investment vf page flow
    @param: None
    @return: None
    **/
    static testMethod void testPageflow() {
        
       Test.startTest();
       
        System.runAs(investorSMIUser) {
            TestDataCreationUtil.createInvAccount(1);
        } 
        
        System.runAs(fundManagerSMIUser) {
            TestDataCreationUtil.createInvestmentFunds(10);
        }
        
        System.runAs(investorSMIUser) {
            TestDataCreationUtil.createbulkInvestments(10);
           
            
            	 ApexPages.StandardController stdCtlr = new ApexPages.StandardController(TestDataCreationUtil.invAccList[0]);
            	 InvestmentAccViewPageExt extension = new InvestmentAccViewPageExt(stdCtlr);
            	 PageReference pageRef = Page.investmentAccountViewPage;           		
            	 Test.setCurrentPage(pageRef);
            	 
            	 Decimal investvalue = 0;
            	 List<AggregateResult> aggResultInvestList = [Select sum(Value__c) suminvestment, Investment_Account__c from 
            	 												Investment__c Where Investment_Account__c in: TestDataCreationUtil.invAccList Group By Investment_Account__c ];
            	 												
            	 for(AggregateResult aggResult : aggResultInvestList){
            	 	investvalue = (Decimal)aggResult.get('suminvestment');
            	 }
            	 
            	 system.assertEquals(investvalue, extension.investmentValue, 'The investment account values matches'); 
            	 system.assertEquals(extension.invAccount.Cash_Value__c + investvalue, extension.totalAccValue, 'The total account value matches'); 
            	 
            	 //get profile name
            	 String profilename = extension.profileName;
            	 system.assertEquals(profilename, 'System Administrator', 'The profile is system admin');
            	 
            	 //rebalance
            	 extension.rebalance();
            	 system.assertEquals(Math.ceil(TestDataCreationUtil.investmentList.size()/(Decimal)SmartInvestorConstants.pageSize), extension.gettotalPage(), 'The total page count is 2.');			
            	
            	 
            	 system.assertEquals( false, extension.hasPrevious, 'Its the first page of the pagination table and does not have any previous page');
            	 system.assertEquals( 1, extension.pageNumber, 'Its the first page of the pagination table');
            	 
            	 system.assertEquals( true, extension.hasNext, 'Check if it has next page of the pagination table');
            	 system.assertEquals( '1-5', extension.getrecordcountonPage(), 'Five records on the first page');
            	 
            	 //go to next page            	 
            	 extension.next();
            	 system.assertEquals( 2, extension.pageNumber, 'Its the second page of the pagination table');
            	 
            	 system.assertEquals( false, extension.hasNext, 'There is no next page in the pagination table');
            	  system.assertEquals( '6-10', extension.getrecordcountonPage(), 'Five records on the second page');
            	
				 //go to previous page
				 system.assertEquals( true, extension.hasPrevious, 'The page has previous page');				 
				 extension.tempinvList[0].Auto_Invest_Percent__c = 15;
            	 extension.previous();
            	 system.assertEquals( 1, extension.pageNumber, 'Its the first page of the pagination table');
            	 
            	  //go to last page
            	  system.assertEquals( true, extension.hasNext, 'Check if it has next page of the pagination table');
            	  extension.last();
            	  system.assertEquals( 2, extension.pageNumber, 'Its the last page of the pagination table');
				             	
				  //go to First page
				  system.assertEquals( true,  extension.hasPrevious,'The page has previous page');
            	  extension.first();
            	  system.assertEquals( 1,  extension.pageNumber, 'Its the first page of the pagination table');
            	 
            	 //test rebalance
            	Decimal investmentVal, totalActVal, targetCashVal, rebalanceAmt = 0;
            	Map<id, Investment__c> investmentMap = new Map<id, Investment__c>();
            	investmentMap.putAll(extension.invList);
            	Decimal oldAccountCashValue = extension.invAccount.Cash_Value__c;
            	totalActVal = extension.totalAccValue;
            	investmentVal = extension.investmentValue;
            	
            	
            	targetCashVal = totalActVal * (TestDataCreationUtil.invAccList[0].Cash_Reserve_Percent__c/100);
            	rebalanceAmt = totalActVal - targetCashVal;
            	
            	
            	System.debug('--- investmentVal -- '+ investmentVal);
            	System.debug('--- totalActVal -- '+ totalActVal);
            	System.debug('--- targetCashVal -- '+ targetCashVal);
            	System.debug('--- rebalanceAmt -- '+ rebalanceAmt);
            	 
            	 //Click rebalance button
            	 PageReference pr = extension.rebalanceNow();	  
            	 
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
            			 		
            			 		system.assertEquals( 0 , inv.Shares__c , 'The share on the inactive investment is zero');
            			 		system.assertEquals( 0 , inv.Value__c , 'The value on the inactive investment is zero');
            			 		
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
            	         	 
            	//check that the page reference is not null is redirected to home page.
            	System.assertEquals(true, pr != null, 'The page reference is not null'); 
				             	
            
            
            delete TestDataCreationUtil.invAccList;
        }
        
        Test.stopTest();
    }
    
    /**
	@Method Name : testPaginationWithSinglepage
    @description: Method to test pagination with single page
    @param: None
    @return: None
    **/
    static testMethod void testPaginationWithSinglepage() {
        
        Test.startTest();
        System.runAs(investorSMIUser) {
            TestDataCreationUtil.createInvAccount(1);
        } 
        
        System.runAs(fundManagerSMIUser) {
            TestDataCreationUtil.createInvestmentFunds(4);
        }
        
        System.runAs(finAdvicerSMIUser) {
            TestDataCreationUtil.createbulkInvestments(4);
           
            
            	 ApexPages.StandardController stdCtlr = new ApexPages.StandardController(TestDataCreationUtil.invAccList[0]);
            	 InvestmentAccViewPageExt extension = new InvestmentAccViewPageExt(stdCtlr);
            	 PageReference pageRef = Page.investmentAccountViewPage;           		
            	 Test.setCurrentPage(pageRef);
            	 
            	 
            	
            	 
            	 extension.rebalance();            	 
            	 
            	 system.assertEquals( Math.ceil(TestDataCreationUtil.investmentList.size()/(Decimal)SmartInvestorConstants.pageSize), Math.ceil(extension.gettotalPage()), 'The total page count is 1.');
            	 system.assertEquals( '1-4', extension.getrecordcountonPage(), 'four records on the first page');			
            	
            	//check next page    
            	 system.assertEquals(false, extension.hasNext, 'There is no next page in the pagination table');      	 
            	
				 //check previous page
				 system.assertEquals(false, extension.hasPrevious, 'The page has no previous page');				 
				 
            	 system.assertEquals(1, extension.pageNumber, 'Its the first page of the pagination table');
            	 
            	  //go to last page
            	  system.assertEquals(false, extension.hasNext, 'There is no last page of the pagination table');
   			             	
				  //go to First page
				  system.assertEquals(false, extension.hasPrevious, 'The page has no previous page');
            	  
            	  system.assertEquals(1, extension.pageNumber, 'Its the first page of the pagination table');
            	 
            	 //rebalance button
            	 extension.rebalanceNow();	 
            	
            	
           
        }
        Test.stopTest();
        delete TestDataCreationUtil.invAccList;
    }
    
    
     /**
	@Method Name : testPaginationWithTwoepage
    @description: Method to test pagination with two page
    @param: None
    @return: None
    **/
     static testMethod void testPaginationWithTwoepage() {
        
        Test.startTest();
        System.runAs(investorSMIUser) {
            TestDataCreationUtil.createInvAccount(1);
        } 
        
        System.runAs(fundManagerSMIUser) {
            TestDataCreationUtil.createInvestmentFunds(12);
        }
        
        System.runAs(investorSMIUser) {
            TestDataCreationUtil.createbulkInvestments(12);
            
            
            	 ApexPages.StandardController stdCtlr = new ApexPages.StandardController(TestDataCreationUtil.invAccList[0]);
            	 InvestmentAccViewPageExt extension = new InvestmentAccViewPageExt(stdCtlr);
            	 PageReference pageRef = Page.investmentAccountViewPage;           		
            	 Test.setCurrentPage(pageRef);
            	 
            	 extension.rebalance();
            	 system.assertEquals( 3, Math.ceil(extension.gettotalPage()),  'The total page count is three.');			
            	
            	 system.assertEquals( false, extension.hasPrevious, 'Its the first page of the pagination table and does not have any previous page');
            	 system.assertEquals( 1, extension.pageNumber, 'Its the first page of the pagination table');
            	 
            	 system.assertEquals( true,  extension.hasNext,'Check if it has next page of the pagination table');
            	 system.assertEquals( '1-5', extension.getrecordcountonPage(), 'Five records on the first page');
            	 
            	 //go to next page            	 
            	 extension.next();
            	 system.assertEquals( 2, extension.pageNumber, 'Its the second page of the pagination table');
            	 
            	 system.assertEquals( true,  extension.hasNext, 'There is next page in the pagination table');
            	 system.assertEquals( '6-10', extension.getrecordcountonPage(),  'Five records on the second page');
            	
            	
            	//go again to next page            	 
            	 extension.next();
            	 system.assertEquals( 3, extension.pageNumber,  'Its the third page of the pagination table');
            	 
            	 system.assertEquals( false,  extension.hasNext, 'There is no next page in the pagination table');
            	 system.assertEquals( '11-12',  extension.getrecordcountonPage(), 'two records on the third page');
            	 
				 //go to previous page
				 system.assertEquals( true, extension.hasPrevious, 'The page has previous page');				 
				 extension.tempinvList[0].Auto_Invest_Percent__c = 15;
            	 extension.previous();
            	 system.assertEquals( 2, extension.pageNumber, 'Its the second page of the pagination table');
            	 
            	  //go to last page
            	  system.assertEquals( true,  extension.hasNext, 'Check if it has next page of the pagination table');
            	  extension.last();
            	  system.assertEquals( 3,  extension.pageNumber, 'Its the last page of the pagination table');
				             	
				  //go to First page
				  system.assertEquals( true, extension.hasPrevious, 'The page has previous page');
            	  extension.first();
            	  system.assertEquals( 1, extension.pageNumber, 'Its the first page of the pagination table');
            	 
            	 //rebalance button
            	 extension.rebalanceNow();	           	 
            	
            	
           
        }
         Test.stopTest();
         delete TestDataCreationUtil.invAccList;
    }
   
      /**
	@Method Name : testExceptions
    @description: Method to test all exception messages
    @param: None
    @return: None
    **/    
    static testMethod void testExceptions(){
        
        Test.startTest();
        System.runAs(investorSMIUser) {
            TestDataCreationUtil.createInvAccount(1);
        } 
        
        System.runAs(fundManagerSMIUser) {
            TestDataCreationUtil.createInvestmentFunds(101);
        }
        
        System.runAs(investorSMIUser) {
            TestDataCreationUtil.createbulkInvestments(100);
            
            TestDataCreationUtil.investmentList[0].Active__c = false;
            TestDataCreationUtil.investmentList[0].Auto_Invest_Percent__c = 4;
            update  TestDataCreationUtil.investmentList[0];
            
            Investment__c investmentobj = TestDataCreationUtil.createSingleInvestments();
             
            
            
            	 ApexPages.StandardController stdCtlr = new ApexPages.StandardController(TestDataCreationUtil.invAccList[0]);
            	 InvestmentAccViewPageExt extension = new InvestmentAccViewPageExt(stdCtlr);
            	 PageReference pageRef = Page.investmentAccountViewPage;           		
            	 Test.setCurrentPage(pageRef);
            	 
            	 extension.rebalance();  
            	 
            	 //check exception when investment is inactive and auto invest percentage in not zero, as the top investment is already false 
            	 //and auto invest percentage is more thatn zero             	 
            	 
            	 //rebalance button
            	 PageReference pr =  extension.rebalanceNow();
            	 System.assertEquals(NULL, pr, 'The page reference is null');            	 
            	
            	 
            	 //check exceptions when the there are more than 100 active investments.            	
            	 
            	 System.debug('---extension.tempinvList --- '+extension.tempinvList);
            	 extension.tempinvList[0].Auto_Invest_Percent__c = 0.25;   
            	 extension.tempinvList[1].Auto_Invest_Percent__c = 0.25;         	 
            	 extension.tempinvList[0].Active__c = true;   
            	 
            	  System.debug('---extension.invList--- '+extension.tempinvList);
            	 
            	 //rebalance button
            	 System.debug('---extension.tempinvList before rebalance--- '+extension.tempinvList);
            	 pr = extension.rebalanceNow();	           	
            	 System.assertEquals(NULL, pr, 'The page reference is null'); 
            	 
            	  
            	 //check exceptions when the sum of active auto invest percentage is more than 100.            	 
            	 
            	 extension.tempinvList[1].Auto_Invest_Percent__c = 70;
            	 
            	 //rebalance button
            	 pr = extension.rebalanceNow();	           	
            	System.assertEquals(NULL, pr, 'The page reference is null'); 
            	 
           	
            
        }
        
        Test.stopTest();
    }
}