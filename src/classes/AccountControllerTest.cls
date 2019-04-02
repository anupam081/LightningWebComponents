@isTest
public class AccountControllerTest {
    
    //testing
    static testMethod void testFindByParent() {
        Boolean success = true;
        try {
	        List<Account> accounts = AccountController.findByParent(null);
        } catch (Exception e) {
            success = false;
        } finally {
	        System.assert(success);
        }
    }

}