<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
                exclude-result-prefixes="i18n">

  <xsl:import href="xslImport:badges:badges/mir-badges-oa.xsl"/>
  <xsl:include href="resource:xsl/badges/mir-badges-style-template.xsl"/>

  <xsl:template match="doc" mode="resultList">
    <xsl:apply-imports/>

    <xsl:variable name="isOpenAccess" select="bool[@name='worldReadableComplete']='true'"/>
    <xsl:variable name="badge-type">
      <xsl:choose>
        <xsl:when test="$isOpenAccess">
          <xsl:value-of select="'badge-success'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'badge-warning'"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="icon-class">
      <xsl:choose>
        <xsl:when test="$isOpenAccess">
          <xsl:value-of select="'fas fa-unlock-alt'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'fas fa-lock'"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:call-template name="output-badge">
      <xsl:with-param name="of-type" select="'hit_oa'"/>
      <xsl:with-param name="tooltip" select="i18n:translate(concat('mir.response.openAccess.', $isOpenAccess))"/>
      <xsl:with-param name="badge-type" select="$badge-type"/>
      <xsl:with-param name="icon-class" select="$icon-class"/>
    </xsl:call-template>
  </xsl:template>
</xsl:stylesheet>
