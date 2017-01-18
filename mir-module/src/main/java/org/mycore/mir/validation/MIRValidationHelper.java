package org.mycore.mir.validation;

import org.mycore.common.config.MCRConfiguration;

import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;

public class MIRValidationHelper {

    public static boolean validatePPN(String ppn) {
        MCRConfiguration config = MCRConfiguration.instance();
        String database = config.getString("MIR.PPN.DatabaseList", "gvk");
        try {
            URL url = new URL("http://uri.gbv.de/document/" + database + ":ppn:" + ppn);
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
