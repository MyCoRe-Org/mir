<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
                exclude-result-prefixes="i18n xsl">

  <xsl:include href="resource:xsl/badges/template/create-badge-util.xsl" />

  <!-- Doc state badge -->
  <xsl:template name="doc-state-badge">
    <xsl:variable name="doc-state" select="mycoreobject/service/servstates/servstate/@categid" />
    <xsl:if test="$doc-state">
      <xsl:variable name="status-i18n">
        <xsl:call-template name="get-doc-state-label">
          <xsl:with-param name="state-categ-id" select="$doc-state"/>
        </xsl:call-template>
      </xsl:variable>

      <xsl:variable name="state-color">
        <xsl:choose>
          <xsl:when test="$doc-state = 'published'">success</xsl:when>
          <xsl:when test="$doc-state = 'deleted'">danger</xsl:when>
          <xsl:when test="$doc-state = 'submitted'">info</xsl:when> <!-- Still use info as base class -->
          <xsl:otherwise>secondary</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="text-color">
        <xsl:if test="$state-color = 'success'">white</xsl:if>
      </xsl:variable>

      <xsl:variable name="custom-bg-color">
        <xsl:if test="$doc-state = 'submitted'">orange</xsl:if>
      </xsl:variable>

      <xsl:call-template name="create-badge">
        <xsl:with-param name="label" select="$status-i18n" />
        <xsl:with-param name="color" select="$state-color" /> <!-- Bootstrap base class -->
        <xsl:with-param name="class" select="concat('mir-', $doc-state)" />
        <xsl:with-param name="tooltip" select="i18n:translate('component.mods.metaData.dictionary.status')"/>
        <xsl:with-param name="color-label" select="$text-color"/> <!-- White text for success -->
        <xsl:with-param name="background-color" select="$custom-bg-color"/> <!-- Orange for submitted -->
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
