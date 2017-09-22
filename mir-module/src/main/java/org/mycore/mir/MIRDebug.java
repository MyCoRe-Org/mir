package org.mycore.mir;

import javax.persistence.EntityManager;
import javax.persistence.Query;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.mycore.backend.jpa.MCREntityManagerProvider;

import com.google.gson.Gson;

public class MIRDebug {
    private static final Logger LOGGER = LogManager.getLogger();

    @SuppressWarnings("unchecked")
    public static boolean printTable(String name) {
        try {
        EntityManager em = MCREntityManagerProvider.getCurrentEntityManager();
        Query query = em.createQuery("SELECT x FROM " + name + " x");
        Gson gson = new Gson();
        LOGGER.info("Printing Table {}", name);
        query.getResultList().stream().map(gson::toJson).forEach(LOGGER::info);
            return true;
        } catch (Exception e) {
            LOGGER.warn("Error while selecting " + name, e);
            return false;
        }
    }

}
