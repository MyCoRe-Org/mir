<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mirstrutils="http://www.mycore.de/xslt/mirstrutils"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:include href="resource:xslt/layout/mir-layout-utils.xsl" />
  <xsl:include href="resource:xslt/MyCoReLayout.xsl" />

  <xsl:variable
    name="PageTitle"
    select="mcri18n:translate-with-params('titles.pageTitle.error', concat(' ', /mcr_error/@HttpError))" />

  <xsl:template match="/mcr_error">
    <div class="jumbotron text-center">
      <h1>
        <xsl:value-of select="mcri18n:translate-with-params('mir.error.headline', @HttpError)" />
      </h1>
      <h2>
        <xsl:value-of select="mcri18n:translate('mir.error.subheadline')" />
      </h2>
      <p class="lead">
        <xsl:copy-of
          select="
            parse-xml-fragment(
              mcri18n:translate-with-params(
                concat('mir.error.codes.', @HttpError),
                mirstrutils:escape-xml(string(@requestURI))
              )
            )/node()" />
      </p>
      <xsl:choose>
        <xsl:when test="(@errorServlet and string-length(text()) gt 1) or exception">
          <xsl:if test="@errorServlet and string-length(text()) gt 1">
            <div class="alert alert-info" role="alert">
              <xsl:attribute name="title">
                <xsl:value-of select="mcri18n:translate('mir.error.message')" />
              </xsl:attribute>
              <xsl:call-template name="lf2br">
                <xsl:with-param name="string" select="text()" />
              </xsl:call-template>
            </div>
          </xsl:if>
          <xsl:if test="exception">
            <div class="card">
              <div class="card-header bg-danger">
                <xsl:value-of select="concat(mcri18n:translate('error.stackTrace'),' :')" />
              </div>
              <div class="card-body text-start">
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
              <xsl:value-of select="mcri18n:translate('error.noInfo')" />
            </small>
          </p>
        </xsl:otherwise>
      </xsl:choose>
      <p>
        <strong>
          <xsl:value-of select="mcri18n:translate('mir.error.finalLine')" />
        </strong>
      </p>
    </div>
  </xsl:template>

  <xsl:template match="/mcr_error[@HttpError = ('401', '403')]">
    <xsl:call-template name="mir.printNotLoggedIn" />
  </xsl:template>

  <xsl:template name="lf2br">
    <xsl:param name="string" as="xs:string" />

    <xsl:for-each select="tokenize($string, '\r?\n')">
      <xsl:value-of select="." />
      <xsl:if test="position() ne last()">
        <br />
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
