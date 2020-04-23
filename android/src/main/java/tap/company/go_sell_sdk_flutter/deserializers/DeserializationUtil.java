package tap.company.go_sell_sdk_flutter.deserializers;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.google.gson.reflect.TypeToken;

import org.json.JSONException;
import org.json.JSONObject;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import company.tap.gosellapi.internal.api.models.PhoneNumber;
import company.tap.gosellapi.open.enums.CardType;
import company.tap.gosellapi.open.enums.TransactionMode;
import company.tap.gosellapi.open.models.AuthorizeAction;
import company.tap.gosellapi.open.models.Customer;
import company.tap.gosellapi.open.models.Destinations;
import company.tap.gosellapi.open.models.PaymentItem;
import company.tap.gosellapi.open.models.Receipt;
import company.tap.gosellapi.open.models.Reference;
import company.tap.gosellapi.open.models.Shipping;
import company.tap.gosellapi.open.models.Tax;

public class DeserializationUtil {

    static private boolean validJsonString(String jsonString) {
        System.out.println("json string:::: " + jsonString);
        if (jsonString == null || "null".equalsIgnoreCase(jsonString.toString()) || "".equalsIgnoreCase(jsonString.toString().trim())
        ) return false;
        return true;
    }

    static private JsonElement getJsonElement(String jsonString, String type) {
        JsonParser jsonParser = new JsonParser();
        JsonElement jsonElement;
        if ("array".equalsIgnoreCase(type)) {
            JsonArray jsonArray = (JsonArray) jsonParser.parse(jsonString);
            jsonElement = jsonArray;
        } else {
            JsonObject jsonArray = (JsonObject) jsonParser.parse(jsonString);
            jsonElement = jsonArray;
        }
        return jsonElement;
    }

    // shipping
    static public ArrayList<Shipping> getShipping(Object jsonString) {
        if (!validJsonString(jsonString.toString())) return null;
        JsonElement jsonElement = getJsonElement(jsonString.toString(), "array");
        Type listType = new TypeToken<List<Shipping>>() {
        }.getType();
        List<Shipping> shippingList = new Gson().fromJson(jsonElement, listType);
        return (ArrayList<Shipping>) shippingList;
    }

    // taxes
    static public ArrayList<Tax> getTaxes(Object jsonString) {
        if (!validJsonString(jsonString.toString())) return null;
        JsonElement jsonElement = getJsonElement(jsonString.toString(), "array");
        Type listType = new TypeToken<List<Tax>>() {
        }.getType();
        List<Tax> taxesList = new Gson().fromJson(jsonElement, listType);
        return (ArrayList<Tax>) taxesList;
    }


    // taxes
    static public ArrayList<PaymentItem> getPaymentItems(Object jsonString) {
        if (!validJsonString(jsonString.toString())) return null;
        JsonElement jsonElement = getJsonElement(jsonString.toString(), "array");
        Type listType = new TypeToken<List<PaymentItem>>() {
        }.getType();
        List<PaymentItem> taxesList = new Gson().fromJson(jsonElement, listType);
        return (ArrayList<PaymentItem>) taxesList;
    }


    // metadata
    static public HashMap<String, String> getMetaData(Object jsonString) {
        if (!validJsonString(jsonString.toString())) return null;
        JsonElement jsonElement = getJsonElement(jsonString.toString(), "object");
        Type listType = new TypeToken<HashMap<String, String>>() {
        }.getType();
        HashMap<String, String> metaMap = new Gson().fromJson(jsonElement, listType);
        System.out.println(metaMap.size());
        return metaMap;
    }


    public static Reference getReference(Object jsonString) {
        if (!validJsonString(jsonString.toString())) return null;
        JsonElement jsonElement = getJsonElement(jsonString.toString(), "object");
        Type listType = new TypeToken<Reference>() {
        }.getType();
        Reference reference = new Gson().fromJson(jsonElement, listType);
        System.out.println(reference.getOrder());
        return reference;
    }

    public static Receipt getReceipt(Object jsonString) {
        if (!validJsonString(jsonString.toString())) return null;
        JsonElement jsonElement = getJsonElement(jsonString.toString(), "object");
        Type listType = new TypeToken<Receipt>() {
        }.getType();
        Receipt receipt = new Gson().fromJson(jsonElement, listType);
        System.out.println(receipt.getId());
        System.out.println(receipt.isEmail());
        System.out.println(receipt.isSms());
        return receipt;
    }

    public static AuthorizeAction getAuthorizeAction(Object jsonString) {
        if (!validJsonString(jsonString.toString())) return null;
        JsonElement jsonElement = getJsonElement(jsonString.toString(), "object");
        Type listType = new TypeToken<AuthorizeAction>() {
        }.getType();
        AuthorizeAction authorizeAction = new Gson().fromJson(jsonElement, listType);
        System.out.println("authorizeAction : " + authorizeAction.getType());
        System.out.println("authorizeAction : " + authorizeAction.getTimeInHours());
        return authorizeAction;
    }

    public static Destinations getDestinations(Object jsonString) {
        if (!validJsonString(jsonString.toString())) return null;
        JsonElement jsonElement = getJsonElement(jsonString.toString(), "object");
        Type listType = new TypeToken<Destinations>() {
        }.getType();
        Destinations destinations = new Gson().fromJson(jsonElement, listType);
        System.out.println("destinations : " + destinations.getCurrency());
        if (destinations.getDestination() != null)
            System.out.println("destinations : " + destinations.getDestination().size());
        return destinations;
    }


    public static Customer getCustomer(HashMap<String, Object> sessionParameters) {
        System.out.println("customer object >>>>> " + sessionParameters.get("customer"));
        if (sessionParameters.get("customer") == null || "null".equalsIgnoreCase(sessionParameters.get("customer").toString()))
            return null;
        String customerString = (String) sessionParameters.get("customer");
        JSONObject jsonObject;
        try {
            jsonObject = new JSONObject(customerString);
            PhoneNumber phoneNumber = new PhoneNumber(jsonObject.get("isdNumber").toString(), jsonObject.get("number").toString());
            return new Customer.CustomerBuilder(jsonObject.get("customerId").toString()).email(jsonObject.get("email").toString()).firstName(jsonObject.get("first_name").toString())
                    .lastName(jsonObject.get("last_name").toString()).phone(phoneNumber)
                    .middleName(jsonObject.get("middle_name").toString()).build();
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static TransactionMode getTransactionMode(String jsonString) {
        if (jsonString == null ||
                "null".equalsIgnoreCase(jsonString) ||
                "".equalsIgnoreCase(jsonString.trim())
        ) return TransactionMode.PURCHASE;
        System.out.println("trxMode >>>> " + jsonString);
        switch (jsonString) {
            case "TransactionMode.PURCHASE":
                return TransactionMode.PURCHASE;
            case "TransactionMode.AUTHORIZE_CAPTURE":
                return TransactionMode.AUTHORIZE_CAPTURE;
            case "TransactionMode.SAVE_CARD":
                return TransactionMode.SAVE_CARD;
            case "TransactionMode.TOKENIZE_CARD":
                return TransactionMode.TOKENIZE_CARD;
        }
        return TransactionMode.PURCHASE;
    }

    public static CardType getCardType(String jsonString) {
        if (jsonString == null ||
                "null".equalsIgnoreCase(jsonString) ||
                "".equalsIgnoreCase(jsonString.trim())
        ) return null;
        System.out.println("card type >>>> " + jsonString);
        if ("CardType.CREDIT".equalsIgnoreCase(jsonString)) return CardType.CREDIT;
        return CardType.DEBIT;
    }

    public static String getPaymentType(String jsonString) {
        if (jsonString == null ||
                "null".equalsIgnoreCase(jsonString) ||
                "".equalsIgnoreCase(jsonString.trim())
        ) return "All";

        System.out.println("payment type >>>> " + jsonString);
        switch (jsonString) {
            case "PaymentType.CARD":
                return "CARD";
            case "PaymentType.WEB":
                return "WEB";
            case "PaymentType.APPLE_PAY":
                return "APPLE_PAY";
        }
        return "ALL";

    }

}
