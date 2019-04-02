/*
Description: Class to hold all the exception messages related to investment account trigger and  page extensions
                                        
    Owner:  Certification Candidate (207295)
    Associated APEX class: InvestmentAccViewPageExt
    Dependencies: none 
    Change History: 
    Date           Person                                   Responsible Details 
    10/13/2016     Certification Candidate (207295)         Created
*/

public with sharing class CustomExceptionMessagesUtil {
	
	/**
	@Method Name : getInactiveAutoPercentageExceptionMessage
    @description: Method to return message when auto invest percentage is not zero on inactive investment
    @param: None
    @return: Exception message
    **/
    public static String getInactiveAutoPercentageExceptionMessage(){
        return 'The Auto Invest Percent must be 0 for any Investment that is not Active';
    }
    
    /**
    @Method Name : getTotalInvestPercentageExceptionMessage
    @description: Method to return message when sum of auto invest percentage on active investment for investment account
    @param: None
    @return: Exception message
    **/
    public static String getTotalInvestPercentageExceptionMessage(){
        return 'The sum of Auto Invest Percent must be 100 for all Active Investments.';
    }
        
     /**
    @Method Name : getActiveInvestmentExceptionMessage
    @description: Method to return message when there are more than 100 active investments on investment account.
    @param: None
    @return: Exception message
    **/
    public static String getActiveInvestmentExceptionMessage(){
        return 'There must not be more than 100 Active Investments in the Investment Account.';
    }
    
    /**
    @Method Name : getDMLExceptionMessage
    @description: Method to return DML exception message on Save process
    @param: (A)strException : Exception caused by the DML process
    @return: Exception message
    **/
    public static String getDMLExceptionMessage(String strException){
        return 'Data cannot be saved due to following error : ' + strException;
    }
}