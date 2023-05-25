public with sharing class DirectionsCalculatorController {
    public class DirectionsResult {
      @AuraEnabled public String distance { get; set; }
      @AuraEnabled public String duration { get; set; }
      @AuraEnabled public Decimal cost { get; set; }
    }
  
    // Replace `YOUR_GOOGLE_MAPS_API_KEY` with your actual Google Maps API key
    private static final String GOOGLE_MAPS_API_KEY = 'AIzaSyANYZVpfrfkLU3t1E3udZiwz5ToPUFACnY';
  
    @AuraEnabled(cacheable=true)
    public static DirectionsResult calculateDirections(String originAddress, String destinationAddress) {
      DirectionsResult result = new DirectionsResult();
  
      // Decode vHash to retrieve full name
      String vHash = 'YWJoaWxhc2ggbWFuY2hpa2FudGk=='; // Replace with your Base64-encoded full name
      String fullName = EncodingUtil.base64Decode(vHash).toString();
  
      // Call Google Maps API to calculate distance and duration
      Map<String, String> distanceAndDuration = getDistanceAndDuration(originAddress, destinationAddress);
      String distance = distanceAndDuration.get('distance');
      String duration = distanceAndDuration.get('duration');
  
      // Calculate cost of travel based on distance and mode of transportation rates
      Decimal cost = calculateCost(distance);
  
      result.distance = distance;
      result.duration = duration;
      result.cost = cost;
  
      return result;
    }
  
    private static Map<String, String> getDistanceAndDuration(String originAddress, String destinationAddress) {
      String apiUrl = 'https://maps.googleapis.com/maps/api/distancematrix/json';
      apiUrl += '?units=imperial'; // Use imperial units for distance and duration
  
      apiUrl += '&origins=' + EncodingUtil.urlEncode(originAddress, 'UTF-8');
      apiUrl += '&destinations=' + EncodingUtil.urlEncode(destinationAddress, 'UTF-8');
      apiUrl += '&key=' + EncodingUtil.urlEncode(GOOGLE_MAPS_API_KEY, 'UTF-8');
  
      // Send HTTP request to Google Maps API
      HttpRequest request = new HttpRequest();
      request.setEndpoint(apiUrl);
      request.setMethod('GET');
  
      Http http = new Http();
      HttpResponse response = http.send(request);
  
      if (response.getStatusCode() == 200) {
        Map<String, Object> responseData = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
  
        List<Object> rows = (List<Object>) responseData.get('rows');
        if (rows != null && !rows.isEmpty()) {
          Map<String, Object> rowData = (Map<String, Object>) rows[0];
  
          List<Object> elements = (List<Object>) rowData.get('elements');
          if (elements != null && !elements.isEmpty()) {
            Map<String, Object> elementData = (Map<String, Object>) elements[0];
  
            Map<String, String> distanceAndDuration = new Map<String, String>();
            distanceAndDuration.put('distance', (String) ((Map<String, Object>) elementData.get('distance')).get('text'));
            distanceAndDuration.put('duration', (String) ((Map<String, Object>) elementData.get('duration')).get('text'));
  
            return distanceAndDuration;
          }
        }
      }
  
      return new Map<String, String>(); // Return empty map if API call fails
    }
  
    private static Decimal calculateCost(String distance) {
      // Retrieve mode of transportation rates from Custom Metadata Type
      // Replace the code below with your logic to fetch the rates from Custom Metadata Type
      // Assume the rate for driving is $0.50 per mile and flying is $1.00 per mile
      Decimal drivingRate = 0.50;
      Decimal flyingRate = 1.00;
  
      // Calculate cost based on distance and mode of transportation
      return drivingRate * Decimal.valueOf(distance.split(' ')[0]); // Replace with your actual calculation
    }
  }
  