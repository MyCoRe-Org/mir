<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcrclassification="http://www.mycore.de/xslt/classification"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:import href="xslImport:badges:badges/mir-badges-genre.xsl"/>
  <xsl:include href="resource:xslt/badges/mir-badges-utils.xsl"/>

  <xsl:template match="doc" mode="badge">
    <xsl:apply-imports/>

    <xsl:choose>
      <xsl:when test="arr[@name='mods.genre']">
        <xsl:for-each select="arr[@name='mods.genre']/str">
          <xsl:call-template name="output-genre-badge">
            <xsl:with-param name="genre" select="."/>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:when>
      <xsl:when test="field[@name='mods.genre']">
        <xsl:for-each select="field[@name='mods.genre']">
          <xsl:call-template name="output-genre-badge">
            <xsl:with-param name="genre" select="."/>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="output-genre-badge">
          <xsl:with-param name="genre" select="'article'"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="output-genre-badge">
    <xsl:param name="genre"/>
    <xsl:call-template name="output-badge">
      <xsl:with-param name="class" select="concat('mir-badge-genre-', $genre)"/>
      <xsl:with-param name="label" select="mcrclassification:current-label-text(mcrclassification:category('mir_genres', $genre))"/>
      <xsl:with-param name="link"  select="concat($ServletsBaseURL, 'solr/find?condQuery=*&amp;fq=category.top:%22mir_genres:', $genre, '%22')"/>
      <xsl:with-param name="tooltip" select="substring-before(document('i18n:component.mods.genre')/i18n/text(), ':')"/>
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
