<xsl:stylesheet version="3.0"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template name="format-extent">
    <xsl:choose>
      <xsl:when test="count(mods:start) &gt; 0">
        <xsl:choose>
          <xsl:when test="count(mods:end) &gt; 0">
            <xsl:value-of select="concat(mcri18n:translate('component.mods.metaData.dictionary.page.abbr'), ' ', mods:start, '-', mods:end)" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat(mcri18n:translate('component.mods.metaData.dictionary.page.abbr'), ' ', mods:start)" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="mods:total">
        <xsl:value-of select="concat(mods:total, ' ', mcri18n:translate('component.mods.metaData.dictionary.pages'))" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="." />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
