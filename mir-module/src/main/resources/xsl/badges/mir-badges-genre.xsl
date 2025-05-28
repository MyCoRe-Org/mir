<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                exclude-result-prefixes="mods xlink">

  <xsl:import href="xslImport:badges:badges/mir-badges-genre.xsl"/>
  <xsl:include href="resource:xsl/badges/mir-badges-utils.xsl"/>

  <xsl:variable name="tooltip-genre" select="substring-before(document('i18n:component.mods.genre')/i18n/text(), ':')"/>

  <xsl:template match="doc" mode="badge">
    <xsl:apply-imports/>
        <!-- TODO include solr request field -->
    <xsl:choose>
      <xsl:when test="arr[@name='mods.genre']">
        <xsl:for-each select="arr[@name='mods.genre']/str">
          <xsl:call-template name="output-badge">
            <xsl:with-param name="class" select="'mir-badge-genre'"/>
            <xsl:with-param name="badge-type" select="'bg-primary'"/>
            <xsl:with-param name="label" select="document(concat('callJava:org.mycore.common.xml.MCRXMLFunctions:getDisplayName:mir_genres:', .))"/>
            <xsl:with-param name="link"  select="concat($ServletsBaseURL, 'solr/find?condQuery=*&amp;fq=category.top:%22mir_genres:', ., '%22')"/>
            <xsl:with-param name="tooltip" select="$tooltip-genre"/>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="output-badge">
          <xsl:with-param name="class" select="'mir-badge-genre'"/>
          <xsl:with-param name="badge-type" select="'bg-primary'"/>
          <xsl:with-param name="label" select="document('callJava:org.mycore.common.xml.MCRXMLFunctions:getDisplayName:mir_genres:article')"/>
          <xsl:with-param name="tooltip" select="$tooltip-genre"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
