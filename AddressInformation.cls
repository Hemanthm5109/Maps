public class AddressInformation {
    public class DirectionInfo {
        @AuraEnabled
        public String directions;
        @AuraEnabled
        public Decimal distance;
        @AuraEnabled
        public String travelTime;
        @AuraEnabled
        public Decimal cost;
    }
    @RemoteAction
    @AuraEnabled
    public static directionInfo getDirections(String originAddress, String destinationAddress) {
        DirectionInfo directionInfo = new DirectionInfo();

        String directions = fetchDirections(originAddress, destinationAddress);

        // Calculating the distance, travel time, and rate of travel
        Decimal distance = calculateDistance(originAddress, destinationAddress);
        String travelTime = calculateTravelTime(originAddress, destinationAddress);
        Decimal cost = calculateCost(distance, 'driving'); 

        // Set the values in the DirectionInfo object
        directionInfo.directions = directions;
        directionInfo.distance = distance;
        directionInfo.travelTime = travelTime;
        directionInfo.cost = cost;

        // Set the encoded name in the vHash variable
        String vHash = EncodingUtil.base64Encode(Blob.valueOf('Hemanth Muppuri')); // Replace with your Base64-encoded full name

        // Returning the DirectionInfo object to the JS
        return directionInfo;
    }

    private static String fetchDirections(String originAddress, String destinationAddress) {

        // Example of HTTP callout using the HttpRequest and HttpResponse classes
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://maps.googleapis.com/maps/api/directions/json?origin=' 
        + EncodingUtil.urlEncode(originAddress, 'UTF-8') + '&destination=' + EncodingUtil.urlEncode
        (destinationAddress, 'UTF-8') + '&key=AIzaSyDEiWATR0xXwQRMhRD7QSKHonN0QnI-otk');
        request.setMethod('GET');

        HttpResponse response = new Http().send(request);
        if (response.getStatusCode() == 200) {
            // Response and extracting the directions
            String responseBody = response.getBody();
            // Implement logic to extract distance and travel time from the response JSON

            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            Map<String, Object> route = (Map<String, Object>) result.get('routes');
            List<Object> legs = (List<Object>) route.get('legs');
            Map<String, Object> leg = (Map<String, Object>) legs.get(0);
            Map<String, Object> distance = (Map<String, Object>) leg.get('distance');
            Map<String, Object> duration = (Map<String, Object>) leg.get('duration');

            String distanceText = (String) distance.get('text');
            String durationText = (String) duration.get('text');

            return 'Distance: ' + distanceText + ', Travel Time: ' + durationText;
        } else {
            // Handle any errors
            return 'Error fetching directions: ' + response.getStatus();
        }
    }
    private static Decimal calculateDistance(String originAddress, String destinationAddress) {
  
        String endpoint = 'https://maps.googleapis.com/maps/api/distancematrix/json';
        
        // Building the request URL with the origin and destination addresses
        String requestUrl = endpoint + '?origins=' + EncodingUtil.urlEncode(originAddress, 'UTF-8') +
        '&destinations=' + EncodingUtil.urlEncode(destinationAddress, 'UTF-8') 
        +'&key=AIzaSyDEiWATR0xXwQRMhRD7QSKHonN0QnI-otk' ;
        
        // HTTP GET request
        HttpRequest request = new HttpRequest();
        request.setEndpoint(requestUrl);
        request.setMethod('GET');
        Http http = new Http();
        HttpResponse response = http.send(request);
        
        // JSON response
        Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        List<Object> rows = (List<Object>) jsonResponse.get('rows');
        Map<String, Object> row = (Map<String, Object>) rows[0];
        List<Object> elements = (List<Object>) row.get('elements');
        Map<String, Object> element = (Map<String, Object>) elements[0];
        Map<String, Object> distance = (Map<String, Object>) element.get('distance');
        String distanceText = (String) distance.get('text');
        Decimal distanceValue = Decimal.valueOf(distanceText.replaceAll('[^0-9.]+', ''));
        
        return distanceValue;
    }
        
    private static String calculateTravelTime(String originAddress, String destinationAddress) {

        String endpoint = 'https://maps.googleapis.com/maps/api/distancematrix/json';
        
        // Building the request URL with the input address
        String requestUrl = endpoint + '?origins=' + EncodingUtil.urlEncode(originAddress, 'UTF-8') +
        '&destinations=' + EncodingUtil.urlEncode(destinationAddress, 'UTF-8') +
        '&key= AIzaSyDEiWATR0xXwQRMhRD7QSKHonN0QnI-otk';
        
        // HTTP GET request
        HttpRequest request = new HttpRequest();
        request.setEndpoint(requestUrl);
        request.setMethod('GET');
        Http http = new Http();
        HttpResponse response = http.send(request);
        
        // JSON response
        Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        List<Object> rows = (List<Object>) jsonResponse.get('rows');
        Map<String, Object> row = (Map<String, Object>) rows[0];
        List<Object> elements = (List<Object>) row.get('elements');
        Map<String, Object> element = (Map<String, Object>) elements[0];
        Map<String, Object> duration = (Map<String, Object>) element.get('duration');
        String travelTime = (String) duration.get('text');
        
        return travelTime;
        
    }
    private static Decimal calculateCost(Decimal distance, String mode) {
        // Fetch the transportation rate from the Custom Metadata Type based on the mode
        Map__mdt rate = [SELECT Rate__c FROM Map__mdt WHERE Mode__c = :mode LIMIT 1];
        
        // Calculate the cost of travel based on the distance and rate per mile
        return distance * rate.Rate__c;
    }
}
