<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" exclude-result-prefixes="i18n xlink">
  <xsl:variable name="Type" select="'document'" />

  <xsl:variable name="PageTitle" select="i18n:translate('titles.pageTitle.error',concat(' ',/mcr_error/@HttpError))" />

  <xsl:template match="/mcr_error">
    <div class="jumbotron text-center">
      <h1>
        <xsl:value-of select="i18n:translate('mir.error.headline',/mcr_error/@HttpError)" />
      </h1>
      <h2>
        <xsl:value-of select="i18n:translate('mir.error.subheadline')" />
      </h2>
      <p class="lead">
        <xsl:choose>
          <xsl:when test="@errorServlet and string-length(text()) &gt; 1">
            <xsl:call-template name="lf2br">
              <xsl:with-param name="string" select="text()" />
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of disable-output-escaping="yes" select="i18n:translate(concat('mir.error.codes.',/mcr_error/@HttpError),/mcr_error/@requestURI)" />
          </xsl:otherwise>
        </xsl:choose>
      </p>
      <xsl:choose>
        <xsl:when test="exception">
          <div class="panel panel-warning">
            <div class="panel-heading">
              <xsl:value-of select="concat(i18n:translate('error.stackTrace'),' :')" />
            </div>
            <div class="panel-body">
              <xsl:for-each select="exception/trace">
                <pre style="font-size:0.8em;">
                  <xsl:value-of select="." />
                </pre>
              </xsl:for-each>
            </div>
          </div>
        </xsl:when>
        <xsl:otherwise>
          <p>
            <small>
              <xsl:value-of select="i18n:translate('error.noInfo')" />
            </small>
          </p>
        </xsl:otherwise>
      </xsl:choose>
      <p>
        <strong>
          <xsl:value-of select="i18n:translate('mir.error.finalLine')" />
        </strong>
      </p>
    </div>
  </xsl:template>
  <xsl:include href="MyCoReLayout.xsl" />
</xsl:stylesheet>
