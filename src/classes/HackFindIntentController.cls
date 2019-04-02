/**
 * This class is created to make a
 * playground to try out Intent APIs
 * and predict a block of text.
 * 
 * @author      Anupam Tripathi
 * @since       26/12/2017
 * @revisions   N/A
 **/

public class HackFindIntentController {   
    
    public Attachment att{get;set;}

    /**
     * This method is created to upload
     * a CSV file from a downloadable link
     * to the server for creating a dataset
     * when the 'Create' button is clicked.
     **/
    @RemoteAction @Auraenabled
    public static DatasetUploadResponse uploadDataset() {
        EinsteinAPI api = new EinsteinAPI();
        
        DatasetUploadResponse datasetUploadResp = api.uploadDataset();
        
        return datasetUploadResp;
    }
    
    /**
     * This method is written to get the status
     * of the upload of the CSV file into their
     * server.
     * 
     * @param       datasetId       The Id of the dataset that was created after uploading the CSV file
     **/
    @RemoteAction
    public static DatasetDetailsResponse getDatasetDetails( String datasetId ) {
        EinsteinAPI api = new EinsteinAPI();
        
        DatasetDetailsResponse datasetDetailsResp = api.getDatasetDetails( datasetId );
        
        return datasetDetailsResp;
    }
    
    /**
     * This method is written to start 
     * training the AI when the 'Train'
     * button is clicked.
     * 
     * @param       datasetId       The Id of the dataset that was created after uploading the CSV file
     **/
    @RemoteAction
    public static TrainDatasetResponse trainDataset( String datasetId ) {
        EinsteinAPI api = new EinsteinAPI();
        
        TrainDatasetResponse trainDatasetResp = api.trainDataset( datasetId );
        
        return trainDatasetResp;
    }
    
    /**
     * This method is created to get
     * the status of the training process
     * 
     * @param       modelId         The Id of the model that was created
     **/
    @RemoteAction
    public static Object getDatasetTrainingStatus( String modelId ) {
        EinsteinAPI api = new EinsteinAPI();
        
        Object resp = api.getDatasetTrainingStatus( modelId );
        
        return resp;
    }
    
    /**
     * This method is written to identify
     * the intent in a given block of text.
     * 
     * @param       modelId         The Id of the model that was created
     * @param       textToPredict   The text that has to be predicted
     **/
    @RemoteAction
    public static PredictionResponse predictIntent( String modelId, String textToPredict ) {
        EinsteinAPI api = new EinsteinAPI();
        
        PredictionResponse predictionResp = api.predictIntent( modelId, textToPredict );
        
        return predictionResp;
    }

    @remoteAction
    public static PageReference openPage() {
        PageReference newpage = NEW Pagereference('/003');
        newpage.setRedirect(false);
        return newpage;
    }

}