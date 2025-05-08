<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="xslImport:badges:badges/mir-badges-genre.xsl"/>
  <xsl:include href="resource:xsl/badges/mir-badges-style-template.xsl"/>

  <xsl:template match="doc" mode="resultList">
    <xsl:apply-imports/>

    <xsl:choose>
      <xsl:when test="arr[@name='mods.genre']">
        <xsl:for-each select="arr[@name='mods.genre']/str">
          <xsl:call-template name="output-badge">
            <xsl:with-param name="of-type" select="'hit_type'"/>
            <xsl:with-param name="badge-type" select="'badge-primary'"/>
            <xsl:with-param name="label" select="document(concat('callJava:org.mycore.common.xml.MCRXMLFunctions:getDisplayName:mir_genres:', .))"/>
            <xsl:with-param name="link"  select="concat($ServletsBaseURL, 'solr/find?condQuery=*&amp;fq=category.top:%22mir_genres:', ., '%22')"/>
            <xsl:with-param name="tooltip" select="substring-before(document('i18n:component.mods.genre')/i18n/text(), ':')"/>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="output-badge">
          <xsl:with-param name="of-type" select="'hit_type'"/>
          <xsl:with-param name="badge-type" select="'badge-primary'"/>
          <xsl:with-param name="label" select="document('callJava:org.mycore.common.xml.MCRXMLFunctions:getDisplayName:mir_genres:article')"/>
          <xsl:with-param name="tooltip" select="substring-before(document('i18n:component.mods.genre')/i18n/text(), ':')"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <xsl:template match="mycoreobject" mode="mycoreobject-badge">
    <xsl:apply-imports/>
  </xsl:template>
</xsl:stylesheet>
