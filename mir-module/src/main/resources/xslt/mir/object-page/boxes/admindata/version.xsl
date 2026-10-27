<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mcrurl="http://www.mycore.de/xslt/url"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template match="field[@name='version']" mode="admindata-box-field">
    <xsl:param name="object" as="element(mycoreobject)" />

    <xsl:variable name="versions" select="document('notnull:staticcontent:mir-history:' || $object/@ID)/versions/version" />
    <xsl:variable name="revision" select="string(mcrurl:get-param($RequestURL, 'r'))" />

    <xsl:call-template name="meta-row">
      <xsl:with-param name="label-key" select="'metadata.versionInfo.version'" />
      <xsl:with-param name="value">
        <xsl:choose>
          <xsl:when test="$revision != ''">
            <xsl:value-of select="index-of($versions/@r ! string(), $revision)[1]" />
          </xsl:when>
          <xsl:when test="$versions">
            <xsl:value-of select="count($versions)" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="mcri18n:translate('metadata.versionInfo.inProgress')" />
          </xsl:otherwise>
        </xsl:choose>
        <br />
        <a id="historyStarter" role="button" style="cursor: pointer">
          <xsl:value-of select="mcri18n:translate('metadata.versionInfo.startLabel')" />
        </a>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
