/**
 * This class is created to receive
 * the Response of Sentiment Analysis
 * API.
 * 
 * @author      Anupam Tripathi
 * @since       22/12/2017
 * @revisions   N/A
 **/
global class SentimentAnalysisResponse {
    webservice List<Probabilities> probabilities    { get; set; } 
    
    global class Probabilities {
        webservice String label                     { get; set; } 
        webservice Double probability               { get; set; }
    }
}