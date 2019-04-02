global class AngularRemoting {  
    // hardcode an account id for demo purposes
    static String accountId = '001900000095Iti';

    global static String getAccount() {
        return JSON.serialize([select name, billingstreet,
            billingcity, billingstate, billingpostalcode
            from account where id = :accountId][0]);
    }    
    
    // this is global class hellooo 0067
    global static String getContacts() {
        return JSON.serialize([select id, name, email 
            from contact where accountId = :accountId]);
    }
 }