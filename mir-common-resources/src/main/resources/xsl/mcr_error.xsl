<?xml version="1.0" encoding="ISO-8859-1"?>
<!DOCTYPE xsl:stylesheet [
  <!ENTITY html-output SYSTEM "xsl/xsl-output-html.fragment">
]>
<!-- ============================================== -->
<!-- $Revision: 1.2 $ $Date: 2006-05-26 15:28:26 $ -->
<!-- ============================================== -->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" exclude-result-prefixes="xlink">
  &html-output;
  <xsl:variable name="Type" select="'document'" />

  <xsl:variable name="MainTitle" select="concat(/mcr_error/@HttpError,': DocPortal')" />

  <xsl:variable name="PageTitle" select="i18n:translate('titles.pageTitle.error',concat(' ',/mcr_error/@HttpError))" />

  <xsl:template match="/mcr_error">
    <div id="errormessage" class="errormessage">
      <!-- Here put in dynamic search mask -->
      <table border="0" width="90%">
        <xsl:choose>
          <xsl:when test="@errorServlet">
            <!-- MCRErrorServlet generated this page -->
            <tr>
              <td class="errormain">
                <xsl:call-template name="lf2br">
                  <xsl:with-param name="string" select="text()" />
                </xsl:call-template>
                <p>
                  <xsl:value-of select="i18n:translate('error.requestURI',@requestURI)" />
                </p>
              </td>
            </tr>
            <xsl:if test="exception">
              <tr>
                <td class="errortrace">
                  <p>
                    <xsl:value-of select="concat(i18n:translate('error.stackTrace'),' :')" />
                  </p>
                  <xsl:for-each select="exception/trace">
                    <pre style="font-size:0.8em;">
                      <xsl:value-of select="." />
                    </pre>
                  </xsl:for-each>
                </td>
              </tr>
            </xsl:if>
          </xsl:when>
          <xsl:otherwise>
            <!-- MCRServlet.generateErrorMessage() was called -->
            <tr>
              <td class="errormain">
                <xsl:value-of select="concat(i18n:translate('error.intro'),' :')" />
              </td>
            </tr>
            <tr>
              <td class="errortrace">
                <pre>
                  <xsl:value-of select="text()" />
                </pre>
              </td>
            </tr>
            <tr>
              <xsl:choose>
                <xsl:when test="exception">
                  <td class="errortrace">
                    <p>
                      <xsl:value-of select="concat(i18n:translate('error.stackTrace'),' :')" />
                    </p>
                    <xsl:for-each select="exception/trace">
                      <pre style="font-size:0.8em;">
                        <xsl:value-of select="." />
                      </pre>
                    </xsl:for-each>
                  </td>
                </xsl:when>
                <xsl:otherwise>
                  <td class="errortrace" style="text-align:center;">
                    <xsl:value-of select="i18n:translate('error.noInfo')" />
                  </td>
                </xsl:otherwise>
              </xsl:choose>
            </tr>
          </xsl:otherwise>
        </xsl:choose>
      </table>
    </div>
  </xsl:template>
  <xsl:include href="MyCoReLayout.xsl" />
</xsl:stylesheet>
