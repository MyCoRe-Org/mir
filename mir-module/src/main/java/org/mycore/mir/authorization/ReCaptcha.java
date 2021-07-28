/*
 * $Id$ 
 * $Revision$ $Date$
 *
 * This file is part of ***  M y C o R e  ***
 * See http://www.mycore.de/ for details.
 *
 * This program is free software; you can use it, redistribute it
 * and / or modify it under the terms of the GNU General Public License
 * (GPL) as published by the Free Software Foundation; either version 2
 * of the License or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program, in a file called gpl.txt or license.txt.
 * If not, write to the Free Software Foundation Inc.,
 * 59 Temple Place - Suite 330, Boston, MA  02111-1307 USA
 */
package org.mycore.mir.authorization;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.http.HttpServletRequest;

import org.apache.http.HttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClientBuilder;
import org.apache.http.util.EntityUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Attribute;
import org.mycore.common.MCRSessionMgr;
import org.mycore.common.config.MCRConfiguration2;

import com.google.gson.Gson;

/**
 * @author Ren\u00E9 Adler (eagle)
 */
public class ReCaptcha {
    private static final Logger LOGGER = LogManager.getLogger();

    private static final String RECAPTCHA_RESPONSE_FIELD = "g-recaptcha-response";

    private final String secretKey;

    /**
     * Checks if capcha was correct submitted.
     * 
     * @param attributes a list of attributes
     * @return <code>true</code> if captcha was solved and <code>false</code> if not
     */
    public static Boolean isSubmittedCaptchaCorrect(List<Attribute> attributes) {
        String ip = MCRSessionMgr.getCurrentSession().getCurrentIP();
        String response = attributes.get(0).getValue();

        LOGGER.info("Verify ReCaptcha: ip-" + ip + " response-" + response + ".");

        return MCRConfiguration2.getString("MIR.ReCaptcha.secret.key")
            .map(ReCaptcha::new)
            .map(rc -> response.trim().length() > 0 && rc.verifyResponse(response, ip))
            .orElseGet(() -> {
                LOGGER.warn("ReCaptcha secret key wasn't set, disable captcha check!");
                return false;
            });
    }

    /**
     * The Google ReCaptcha response checker.
     * 
     * @param secretKey the secret key. (not the site key)
     */
    public ReCaptcha(final String secretKey) {
        this.secretKey = secretKey;
    }

    /**
     * Checks if capcha was correct submitted.
     * 
     * @param request the HTTP request
     * @return <code>true</code> if captcha was solved and <code>false</code> if not
     */
    public Boolean isSubmittedCaptchaCorrect(final HttpServletRequest request) {
        final String response = request.getParameter(RECAPTCHA_RESPONSE_FIELD);

        final Boolean ignoreCaptcha = Boolean.getBoolean("ignoreCaptcha");
        return ignoreCaptcha || verifyResponse(response, request.getRemoteAddr());
    }

    private Boolean verifyResponse(final String response, final String ip) {
        final CloseableHttpClient client = HttpClientBuilder.create().build();

        final String url = "https://www.google.com/recaptcha/api/siteverify?secret=" + secretKey + "&response="
            + response + "&remoteip=" + ip;

        final HttpGet get = new HttpGet(url);

        try {
            final HttpResponse res = client.execute(get);
            final String json = EntityUtils.toString(res.getEntity());

            final Gson gson = new Gson();
            final ReCaptchaResult rcResult = gson.fromJson(json, ReCaptchaResult.class);

            return Boolean.valueOf(rcResult.success);
        } catch (final IOException e) {
            LOGGER.warn("ReCaptcha response could not be verified!", e);
            return Boolean.FALSE;
        }
    }

    /**
     * ReCaptcha Result.
     * 
     * @author Ren\u00E9 Adler (eagle)
     */
    class ReCaptchaResult {
        public boolean success;
    }
}
