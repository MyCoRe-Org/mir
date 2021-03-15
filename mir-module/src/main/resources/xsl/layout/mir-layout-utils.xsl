<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions" xmlns:encoder="xalan://java.net.URLEncoder" exclude-result-prefixes="i18n mcrxsl encoder"
>

  <xsl:include href="layout-utils.xsl" />

  <xsl:template name="mir.printNotLoggedIn">
    <xsl:param name="objectId" select="''" />
    <xsl:param name="hasAccessKey" select="false()" />

    <div class="alert alert-danger">
      <h1>
        <xsl:value-of select="i18n:translate('mir.error.headline.401')" />
      </h1>
      <p>
        <xsl:choose>
          <xsl:when test=" mcrxsl:isCurrentUserGuestUser()">
            <xsl:value-of disable-output-escaping="yes" select="i18n:translate('mir.error.codes.401')" />
            <xsl:text>&#160;</xsl:text>
            <a href="{concat( $ServletsBaseURL, 'MCRLoginServlet', $HttpSession,'?url=', encoder:encode(string($RequestURL)))}">
              <xsl:value-of select="i18n:translate('component.user2.button.login')" />
            </a>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="objId">
              <xsl:choose>
                <xsl:when test="string-length($objectId) &gt; 0">
                  <xsl:value-of select="$objectId" />
                </xsl:when>
                <xsl:when test="contains($RequestURL, '/receive/')">
                  <xsl:variable name="id" select="substring-after($RequestURL,'/receive/')" />
                  <xsl:choose>
                    <xsl:when test="contains($id, ';')">
                      <xsl:value-of select="substring-before($id, ';')" />
                    </xsl:when>
                    <xsl:when test="contains($id, '?')">
                      <xsl:value-of select="substring-before($id, '?')" />
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="$id" />
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
              </xsl:choose>
            </xsl:variable>
            
            <xsl:variable name="hasAccKP">
              <xsl:choose>
                <xsl:when test="$hasAccessKey">
                  <xsl:value-of select="$hasAccessKey" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:variable name="accKP" select="document(concat('accesskeys:', $objId))" />
                  <xsl:value-of select="count($accKP/accesskeys[@readkey|@writekey]) &gt; 0" />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <xsl:choose>
              <xsl:when test="$hasAccKP">
                <xsl:value-of disable-output-escaping="yes" select="i18n:translate('mir.error.accessKeyRequired', $objId)" />
                <xsl:text>&#160;</xsl:text>
                <a href="{concat($WebApplicationBaseURL, 'authorization/accesskey.xed', '?objId=', $objId, '&amp;url=', encoder:encode(string($RequestURL)))}">
                  <xsl:value-of select="i18n:translate('mir.accesskey.setOnUser')" />
                </a>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of disable-output-escaping="yes" select="i18n:translate('mir.error.blocked')" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </p>
    </div>
  </xsl:template>
</xsl:stylesheet>