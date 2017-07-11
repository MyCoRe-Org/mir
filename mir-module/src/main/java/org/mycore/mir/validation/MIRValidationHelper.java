package org.mycore.mir.validation;

import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;

import org.mycore.common.config.MCRConfiguration;
import org.mycore.datamodel.classifications2.MCRCategoryDAO;
import org.mycore.datamodel.classifications2.MCRCategoryDAOFactory;
import org.mycore.datamodel.classifications2.MCRCategoryID;
import org.mycore.mir.impexp.MIRClassificationMapper;

public class MIRValidationHelper {

    public static String validateSDNB(String sdnb) {
        MCRCategoryDAO dao = MCRCategoryDAOFactory.getInstance();
        if (dao.exist(new MCRCategoryID("SDNB", sdnb))) {
            return sdnb;
        }
        if (sdnb.length() == 2) {
            String newdSDNB = MIRClassificationMapper.getSDNBfromOldSDNB(sdnb);
            if (dao.exist(new MCRCategoryID("SDNB", newdSDNB))) {
                return newdSDNB;
            }
        }
        return "";
    }

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
