public class UserUtilityApexController {

    //fetch all users with search name
    @AuraEnabled
    public static List<User> findUsers(String searchKey) {
        String name = '%' + searchKey + '%';
        return [SELECT id, name, email FROM User WHERE name LIKE :name LIMIT 50];
    }
    
    //fetch login history of the user
    @AuraEnabled
    public static List<LoginHistory> loginhistory(String userid){
        
        if(!String.ISBlANK(userid)){
        	return [select id, Application, UserId, LoginTime from LoginHistory where UserId =: userid order by LoginTime desc limit 50];
        }
        
        return new List<LoginHistory>();
    }
}