public class AnimalLocator {
    
    public static String getAnimalNameById(Integer aid){
        String animalName;
        try{
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint('https://th-apex-http-callout.herokuapp.com/animals/'+aid);
                request.setMethod('GET');
                HttpResponse response = http.send(request);
                System.debug('response == '+response.getBody());
                
                // If the request is successful, parse the JSON response.
                if (response.getStatusCode() == 200) {
                    // Deserialize the JSON string into collections of primitive data types.
                    Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                    // Cast the values in the 'animals' key as a list
                    
                    System.debug('results == '+results);
                    
                    Map<String, Object> animals = (Map<String, Object>) results.get('animal');
                    System.debug('Received the following animals:');
                    
                    if(animals.size() > 0){
                         animalName = String.valueof(animals.get('name'));
                         System.debug('animalName == '+animalName);
                         return animalName;
                    }
                        
                }
                
                
        }catch(Exception e){
            System.debug('Error Message is =='+e.getMessage());
            
        }
        return animalName;
    }

}