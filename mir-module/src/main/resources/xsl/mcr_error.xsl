<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  exclude-result-prefixes="i18n">
  <xsl:include href="layout/mir-layout-utils.xsl" />
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
        <xsl:value-of disable-output-escaping="yes"
          select="i18n:translate(concat('mir.error.codes.',/mcr_error/@HttpError),/mcr_error/@requestURI)" />
      </p>
      <xsl:choose>
        <xsl:when test="@errorServlet and string-length(text()) &gt; 1 or exception">
          <xsl:if test="@errorServlet and string-length(text()) &gt; 1">
            <div class="alert alert-info" role="alert">
              <xsl:attribute name="title">
                <xsl:value-of select="i18n:translate('mir.error.message')" />
              </xsl:attribute>
              <xsl:call-template name="lf2br">
                <xsl:with-param name="string" select="text()" />
              </xsl:call-template>
            </div>
          </xsl:if>
          <xsl:if test="exception">
            <div class="card">
              <div class="card-header bg-danger">
                <xsl:value-of select="concat(i18n:translate('error.stackTrace'),' :')" />
              </div>
              <div class="card-body">
                <xsl:for-each select="exception/trace">
                  <pre style="font-size:0.8em;">
                    <xsl:value-of select="." />
                  </pre>
                </xsl:for-each>
              </div>
            </div>
          </xsl:if>
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

  <xsl:template match="/mcr_error[contains('401|403', @HttpError)]">
    <xsl:call-template name="mir.printNotLoggedIn" />
  </xsl:template>

  <xsl:include href="MyCoReLayout.xsl" />
</xsl:stylesheet>
