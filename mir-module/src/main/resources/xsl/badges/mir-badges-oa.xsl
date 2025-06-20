<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="xslImport:badges:badges/mir-badges-oa.xsl"/>
  <xsl:include href="resource:xsl/badges/mir-badges-utils.xsl"/>

  <xsl:template match="doc" mode="badge">
    <xsl:apply-imports/>

    <xsl:call-template name="output-oa-badge">
      <xsl:with-param name="isOpenAccess" select="bool[@name='worldReadableComplete']='true' or field[@name='worldReadableComplete']='true'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="output-oa-badge">
    <xsl:param name="isOpenAccess"/>

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
      <xsl:with-param name="class" select="concat('mir-badge-oa-', $isOpenAccess)"/>
      <xsl:with-param name="tooltip" select="document(concat('i18n:mir.response.openAccess.', $isOpenAccess))/i18n/text()"/>
      <xsl:with-param name="icon-class" select="$icon-class"/>
    </xsl:call-template>
  </xsl:template>
</xsl:stylesheet>
