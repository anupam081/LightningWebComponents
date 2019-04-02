public class HackMyMapCtrl {
    
    
    @AuraEnabled
    public static List<contact> getContacts() {
        return [
            SELECT Id, Name, DEV_Innovation__Home_Location__Latitude__s, 
            DEV_Innovation__Home_Location__Longitude__s
            FROM Contact
            WHERE OwnerId = :UserInfo.getUserId() AND DEV_Innovation__Home_Location__Latitude__s != NULL 
            AND DEV_Innovation__Home_Location__Longitude__s != NULL
        ];
    }

    @AuraEnabled
    public static User getUserInfo() {
        return [
            SELECT Id, Name, DEV_Innovation__Base_Location__Latitude__s, 
            DEV_Innovation__Base_Location__Longitude__s
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ];
    }


}