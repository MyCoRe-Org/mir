<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="xslImport:badges:badges/mir-badges-oa.xsl"/>
  <xsl:import href="resource:xsl/coreFunctions.xsl"/>
  <xsl:include href="resource:xsl/badges/mir-badges-style-template.xsl"/>

  <xsl:param name="RequestURL"/>
  <xsl:variable name="revision">
    <xsl:call-template name="UrlGetParam">
      <xsl:with-param name="url" select="$RequestURL" />
      <xsl:with-param name="par" select="'r'" />
    </xsl:call-template>
  </xsl:variable>

  <xsl:template match="doc" mode="resultList">
    <xsl:apply-imports/>

    <xsl:call-template name="render-oa-badge">
      <xsl:with-param name="isOpenAccess" select="bool[@name='worldReadableComplete']='true'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mycoreobject" mode="mycoreobject-badge">
    <xsl:apply-imports/>

    <xsl:choose>
      <xsl:when test="not(string-length($revision) &gt; 0)">
        <xsl:variable name="isWorldReadableComplete" select="document(concat('notnull:callJava:org.mycore.common.xml.MCRXMLFunctions:isWorldReadableComplete:', @ID))"/>
        <xsl:call-template name="render-oa-badge">
          <xsl:with-param name="isOpenAccess" select="$isWorldReadableComplete = 'true'"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="output-badge">
          <xsl:with-param name="of-type" select="'hit_oa'"/>
          <xsl:with-param name="tooltip" select="document(concat('i18n:mir.response.openAccess.history.unknown:', @ID))/i18n/text()"/>
          <xsl:with-param name="badge-type" select="'badge-light'"/>
          <xsl:with-param name="icon-class" select="'fas fa-question'"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="render-oa-badge">
    <xsl:param name="isOpenAccess"/>

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
      <xsl:with-param name="tooltip" select="document(concat('i18n:mir.response.openAccess.', $isOpenAccess))/i18n/text()"/>
      <xsl:with-param name="badge-type" select="$badge-type"/>
      <xsl:with-param name="icon-class" select="$icon-class"/>
    </xsl:call-template>
  </xsl:template>
</xsl:stylesheet>
