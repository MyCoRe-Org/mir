<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
                exclude-result-prefixes="mcrxsl">

  <xsl:import href="xslImport:badges:badges/mir-badges-genre.xsl"/>
  <xsl:include href="mir-badges-style-template.xsl"/>

  <xsl:template match="doc" mode="resultList">

    <xsl:choose>
      <xsl:when test="arr[@name='mods.genre']">
        <xsl:for-each select="arr[@name='mods.genre']/str">
          <xsl:call-template name="output-badge">
            <xsl:with-param name="of-type" select="'hit_type'"/>
            <xsl:with-param name="badge-type" select="'badge-primary'"/>
            <xsl:with-param name="label" select="mcrxsl:getDisplayName('mir_genres', .)"/>
            <xsl:with-param name="link" select="concat($ServletsBaseURL, 'solr/find?condQuery=*&amp;fq=category.top:%22mir_genres:', ., '%22')"/>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <span class="mr-1 hit_type">
          <xsl:call-template name="output-badge">
            <xsl:with-param name="of-type" select="'hit_type'"/>
            <xsl:with-param name="badge-type" select="'badge-primary'"/>
            <xsl:with-param name="label" select="mcrxsl:getDisplayName('mir_genres','article')"/>
          </xsl:call-template>
        </span>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:apply-imports/>
  </xsl:template>
</xsl:stylesheet>
