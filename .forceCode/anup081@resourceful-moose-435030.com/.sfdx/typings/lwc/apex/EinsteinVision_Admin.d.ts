declare module "@salesforce/apex/EinsteinVision_Admin.createDatasetFromUrl" {
  export default function createDatasetFromUrl(param: {zipUrl: any}): Promise<any>;
}
declare module "@salesforce/apex/EinsteinVision_Admin.getDatasets" {
  export default function getDatasets(): Promise<any>;
}
declare module "@salesforce/apex/EinsteinVision_Admin.trainDataset" {
  export default function trainDataset(param: {datasetId: any}): Promise<any>;
}
declare module "@salesforce/apex/EinsteinVision_Admin.deleteDataset" {
  export default function deleteDataset(param: {datasetId: any}): Promise<any>;
}
declare module "@salesforce/apex/EinsteinVision_Admin.getModels" {
  export default function getModels(param: {datasetId: any}): Promise<any>;
}
declare module "@salesforce/apex/EinsteinVision_Admin.getCatPrediction" {
  export default function getCatPrediction(param: {catId: any, fileName: any, base64: any}): Promise<any>;
}
declare module "@salesforce/apex/EinsteinVision_Admin.getCatLabels" {
  export default function getCatLabels(): Promise<any>;
}
declare module "@salesforce/apex/EinsteinVision_Admin.getImageUrlFromAttachment" {
  export default function getImageUrlFromAttachment(param: {catId: any}): Promise<any>;
}
