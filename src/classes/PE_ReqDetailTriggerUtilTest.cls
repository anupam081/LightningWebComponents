/* @author : Dev_Innovation
* Date : 25 May 17
* Description : Test Method for class PE_ReqDetailTriggerUtil
*/

@isTest
private class PE_ReqDetailTriggerUtilTest {
    
    /*@Param : None
    * @return : None
    * @Description : Test Method for class PE_ReqDetailTriggerUtil
    * @author : Dev_Innovation
    * @Date : 25 May 17
    */
    static testMethod void testProjectestimation (){
        DEV_Innovation__Projects__c proObj = new DEV_Innovation__Projects__c(Name = 'Test Project',
                                                                            DEV_Innovation__Module__c = 'Sales Cloud',
                                                                            DEV_Innovation__Project_Description__c = 'Account Management',
                                                                            DEV_Innovation__SubModule_Details__c = 'testing',
                                                                            DEV_Innovation__Start_Date__c = System.today(),
                                                                           DEV_Innovation__End_Date__c = System.today() + 7);
        insert proObj;   
        
        DEV_Innovation__Requirement_Details__c rdObj1 = new DEV_Innovation__Requirement_Details__c(Name = 'Create custom field',
                                                                                                 DEV_Innovation__Complexity__c = '1',
                                                                                                 DEV_Innovation__Description__c = 'create fields',
                                                                                                 DEV_Innovation__Number_of_Items__c = 1,
                                                                                                 DEV_Innovation__Project__c = proObj.id,
                                                                                                 DEV_Innovation__Type__c = 'Configuration',
                                                                                                 DEV_Innovation__SubType__c = 'CustomObject');
        
        DEV_Innovation__Requirement_Details__c rdObj2 = new DEV_Innovation__Requirement_Details__c(Name = 'Create custom field',
                                                                                                 DEV_Innovation__Complexity__c = '1',
                                                                                                 DEV_Innovation__Description__c = 'create fields',
                                                                                                 DEV_Innovation__Number_of_Items__c = 1,
                                                                                                 DEV_Innovation__Project__c = proObj.id,
                                                                                                 DEV_Innovation__Type__c = 'Configuration',
                                                                                                 DEV_Innovation__SubType__c = 'CustomObject');
        Test.startTest();
        	insert rdObj1;
        test.stopTest();
        
        //Check results
        DEV_Innovation__Requirement_Details__c queryRd = [select id, DEV_Innovation__Effort__c 
                                                         from DEV_Innovation__Requirement_Details__c
                                                         where id =: rdObj1.id];
        Map<String, Integer> baseLineEstimateMap = PE_Utils.fetchBaselineEstimates();
        
        system.assertEquals((baseLineEstimateMap.get(rdObj1.DEV_Innovation__SubType__c) * Integer.valueof(rdObj1.DEV_Innovation__Complexity__c) * rdObj1.DEV_Innovation__Number_of_Items__c), queryRd.DEV_Innovation__Effort__c,'The effort is not correct');
    }
    									

}