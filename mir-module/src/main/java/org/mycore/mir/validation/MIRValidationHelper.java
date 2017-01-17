package org.mycore.mir.validation;

import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;

public class MIRValidationHelper {

    public static boolean validatePPN(String ppn) {
        try {
            URL url = new URL("http://uri.gbv.de/document/gvk:ppn:" + ppn);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("GET");
            connection.connect();
            int resCode = connection.getResponseCode();
            if (resCode == 200 || resCode == 302) {
                return true;
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return false;
    }
}
