package fr.ratp.nefertari.mongotocsv;

/**
 * @author Rami SOLTANI created on 20/01/2021
 **/
public class JsonFileNotFoundException extends RuntimeException {
    public JsonFileNotFoundException(String message) {
        super(message);
    }
}
