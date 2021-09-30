<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions" xmlns:encoder="xalan://java.net.URLEncoder"
  exclude-result-prefixes="i18n xlink mcrxsl encoder">
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
    <div class="alert alert-warning">
      <h1>
        <xsl:value-of select="i18n:translate(concat('mir.error.headline.', @HttpError))" />
      </h1>
      <p>
        <xsl:choose>
          <xsl:when test=" mcrxsl:isCurrentUserGuestUser()">
            <xsl:value-of disable-output-escaping="yes" select="i18n:translate(concat('mir.error.codes.', @HttpError), @requestURI)" />
            <xsl:text>&#160;</xsl:text>
            <a href="{concat( $ServletsBaseURL, 'MCRLoginServlet', $HttpSession,'?url=', encoder:encode(string($RequestURL)))}">
              <xsl:value-of select="i18n:translate('component.user2.button.login')" />
            </a>
          </xsl:when>
          <xsl:when test="contains(@requestURI, '/receive/')">
            <xsl:variable name="objectId" select="substring-after(@requestURI,'/receive/')" />
            <xsl:variable name="accKP" select="document(concat('accesskeys:', $objectId))" />
            <xsl:variable name="hasAccKP" select="count($accKP/accesskeys[@readkey|@writekey]) &gt; 0" />

            <xsl:choose>
              <xsl:when test="$hasAccKP">
                <xsl:value-of disable-output-escaping="yes" select="i18n:translate('mir.error.accessKeyRequired', $objectId)" />
                <xsl:text>&#160;</xsl:text>
                <a
                  href="{concat($WebApplicationBaseURL, 'authorization/accesskey.xed', '?objId=', $objectId, '&amp;url=', encoder:encode(string($RequestURL)))}">
                  <xsl:value-of select="i18n:translate('mir.accesskey.setOnUser')" />
                </a>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of disable-output-escaping="yes" select="i18n:translate('mir.error.blocked')" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
        </xsl:choose>
      </p>
    </div>
  </xsl:template>

  <xsl:include href="MyCoReLayout.xsl" />
</xsl:stylesheet>
