public with sharing class WeatherController {

    static String baseURL = 'http://api.wunderground.com/api/';
    
    // Sign up for an API key here: http://www.wunderground.com/weather/api/d/login.html
    static String apiKey = 'ab0aaf9f0a22fd44';
    
    @AuraEnabled
    public static String getAccountWeather(Id accountId) {
	try {
            Account account = [SELECT BillingPostalCode FROM Account WHERE Id=:accountId];
            String zip = account.BillingPostalCode;
            String url = baseURL + apiKey + '/conditions/forecast/q/' + zip + '.json';
            HttpRequest req = new HttpRequest();
            Http http = new Http();
            req.setMethod('GET');    
            req.setEndpoint(url);
            HTTPResponse res = http.send(req);
            return res.getBody();        	
        } catch(Exception ex){
            return '{"error": "' + ex.getMessage() + '"}';
        }
    }
}