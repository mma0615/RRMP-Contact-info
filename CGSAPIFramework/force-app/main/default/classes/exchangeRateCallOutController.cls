public with sharing class exchangeRateCallOutController {
       // endpoint URL
       //let endpointURL = 'https://www.alphavantage.co/query?function=CURRENCY_EXCHANGE_RATE&from_currency=' 
       //+ this.fromCurrencyValue + '&to_currency=' + this.toCurrencyValue + '&apikey=4W7NZUQNJ061YHHF';

    @AuraEnabled
    public static map<String, Object> retriveCurrencyConversionRates(string fromCurrencyValue,
            string toCurrencyValue)
    {
        map<String, Object> mapJsonData = new map<String, Object>();

        // Populatting parameters string
        String parameters = 'function=CURRENCY_EXCHANGE_RATE&from_currency=' 
            + fromCurrencyValue + '&to_currency=' + toCurrencyValue;
        // http callout
        String strResponse = CGSRestAPIController.APICallOut('ExchangeRate', parameters);

        if(!String.isBlank(strResponse)) {
            mapJsonData = (map<String, Object>)JSON.deserializeUntyped(strResponse);
            System.debug('mapJsonData ===> '+mapJsonData);
        }

        if(!mapJsonData.isEmpty()) {
            return mapJsonData;
        }
        else {
            return null;
        }
    }

}
