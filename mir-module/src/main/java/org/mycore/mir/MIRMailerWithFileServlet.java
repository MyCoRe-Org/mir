package org.mycore.mir;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

import org.apache.log4j.Logger;
import org.mycore.common.MCRMailer;
import org.mycore.common.config.MCRConfiguration;
import org.mycore.frontend.servlets.MCRServlet;
@MultipartConfig

/**
 * Servlet implementation class MIRMailerWithFileServlet
 */
public class MIRMailerWithFileServlet extends MCRServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(MIRMailerWithFileServlet.class);

    /**
     * @see MCRServlet#doPost(HttpServletRequest request, HttpServletResponse response)
     */
    public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        MCRConfiguration config = MCRConfiguration.instance();

        String ReqCharEncoding = config.getString("MCR.Request.CharEncoding", "UTF-8");
        request.setCharacterEncoding(ReqCharEncoding);

        String sender    = request.getParameter("name") + "<" + request.getParameter("mail") + ">"; // Retrieves <input type="text" name="name"> and <input type="text" name="mail">
        List<String> recipients = new ArrayList<String>();
        recipients.add(config.getString("MCR.mir-module.EditorMail"));
        if (request.getParameterMap().containsKey("copy")) {
            recipients.add(request.getParameter("mail"));
        }
        String subject   = "[Publikationsserver] - Online-Einreichung";
        String body      = request.getParameter("name") + " sendet folgende Publikation zur Einreichung:"
                           + System.lineSeparator() + System.lineSeparator() + System.lineSeparator()


                           + "Angaben zur Person:" + System.lineSeparator()
                           + "-------------------" + System.lineSeparator()
                           + "Name:      " + request.getParameter("name") + System.lineSeparator()
                           + "E-Mail:    " + request.getParameter("mail") + System.lineSeparator()
                           + "Institut:  " + request.getParameter("institute") + System.lineSeparator()
                           + "Fakultät:  " + request.getParameter("faculty") + System.lineSeparator()
                           + System.lineSeparator() + System.lineSeparator()


                           + "Angaben zur Publikation:    " + System.lineSeparator()
                           + "------------------------    " + System.lineSeparator()
                           + "Titel (deutsch):            " + request.getParameter("title_de") + System.lineSeparator()
                           + "Titel (englisch):           " + request.getParameter("title_en") + System.lineSeparator()
                           + "Lizenz:                     " + request.getParameter("license") + System.lineSeparator()
                           + "Schlagworte (deutsch):      " + request.getParameter("keywords_de") + System.lineSeparator()
                           + "Schlagworte (englisch):     " + request.getParameter("keywords_en") + System.lineSeparator() + System.lineSeparator()
                           + "Zusammenfassung (deutsch):  " + System.lineSeparator() + request.getParameter("abstract_de") + System.lineSeparator() + System.lineSeparator() + System.lineSeparator()
                           + "Zusammenfassung (englisch): " + System.lineSeparator() + request.getParameter("abstract_en") + System.lineSeparator() + System.lineSeparator() + System.lineSeparator()
                           + "Anmerkungen:                " + System.lineSeparator() + request.getParameter("comment") + System.lineSeparator();

        List<String> parts = new ArrayList<String>();
        Part filePart = request.getPart("file"); // Retrieves <input type="file" name="file">

        if (filePart.getSize() != 0) {
            String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString(); // MSIE fix.

            File uploads = new File(config.getString("MIR.UploadForm.path"));
            File file = new File(uploads, fileName);

            try {
                InputStream fileContent = filePart.getInputStream();
                Files.copy(fileContent, file.toPath());
                parts.add(file.toURI().toString());
                MCRMailer.send(sender, recipients, subject, body, parts, false);
            } catch (Exception e) {
                LOGGER.warn("Will not send e-mail, file upload failed of file " + fileName);
            }
            try {
                file.delete();
            } catch (Exception e) {
                LOGGER.warn("Error while try to delete file " + fileName);
            }
        }

        else {
            MCRMailer.send(sender, recipients, subject, body, parts, false);
        }

        response.sendRedirect(request.getParameter("goto"));
    }

}
