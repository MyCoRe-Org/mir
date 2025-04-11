<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exslt="http://exslt.org/common"
                exclude-result-prefixes="xsl exslt">

  <!-- Shared content for badges -->
  <xsl:template name="badge-content">
    <xsl:param name="tooltip" select="''"/>
    <xsl:param name="tooltip-data-placement" select="'top'"/>
    <xsl:param name="title" select="''"/>
    <xsl:param name="dataAttributes"/>
    <xsl:param name="label" select="''"/>
    <xsl:param name="color-label" select="''"/>
    <xsl:param name="background-color" select="''"/>

    <!-- Handle tooltip if specified -->
    <xsl:if test="$tooltip != ''">
      <xsl:attribute name="data-toggle">tooltip</xsl:attribute>
      <xsl:attribute name="data-placement">
        <xsl:value-of select="$tooltip-data-placement"/>
      </xsl:attribute>
      <xsl:attribute name="title">
        <xsl:value-of select="$tooltip"/>
      </xsl:attribute>
    </xsl:if>
    <!-- Regular title attribute (non-tooltip) -->
    <xsl:if test="$title != '' and $tooltip = ''">
      <xsl:attribute name="title">
        <xsl:value-of select="$title"/>
      </xsl:attribute>
    </xsl:if>
    <!-- Handle data attributes -->
    <xsl:if test="$dataAttributes">
      <xsl:for-each select="exslt:node-set($dataAttributes)/@*">
        <xsl:attribute name="{name()}">
          <xsl:value-of select="."/>
        </xsl:attribute>
      </xsl:for-each>
    </xsl:if>
    <!-- Handle custom colors if specified -->
    <xsl:if test="$color-label != '' or $background-color != ''">
      <xsl:attribute name="style">
        <xsl:if test="$color-label != ''">color: <xsl:value-of select="$color-label"/>;</xsl:if>
        <xsl:if test="$background-color != ''">background-color: <xsl:value-of select="$background-color"/>;</xsl:if>
      </xsl:attribute>
    </xsl:if>
    <xsl:value-of select="$label"/>
  </xsl:template>

  <!-- Central badge creation template -->
  <xsl:template name="create-badge">
    <xsl:param name="label" select="''"/>
    <xsl:param name="color" select="'primary'"/> <!-- Bootstrap color class -->
    <xsl:param name="URL" select="''"/>
    <xsl:param name="class" select="''"/>
    <xsl:param name="title" select="''"/>
    <xsl:param name="dataAttributes"/>
    <xsl:param name="tooltip" select="''"/>
    <xsl:param name="tooltip-data-placement" select="'top'"/>
    <xsl:param name="color-label" select="''"/> <!-- Custom text color -->
    <xsl:param name="background-color" select="''"/> <!-- Custom bg color -->

    <div class="badge-item">
      <xsl:choose>
        <xsl:when test="$URL != ''">
          <a href="{$URL}" class="badge badge-{$color} {$class}">
            <xsl:call-template name="badge-content">
              <xsl:with-param name="tooltip" select="$tooltip"/>
              <xsl:with-param name="tooltip-data-placement" select="$tooltip-data-placement"/>
              <xsl:with-param name="title" select="$title"/>
              <xsl:with-param name="dataAttributes" select="$dataAttributes"/>
              <xsl:with-param name="label" select="$label"/>
              <xsl:with-param name="color-label" select="$color-label"/>
              <xsl:with-param name="background-color" select="$background-color"/>
            </xsl:call-template>
          </a>
        </xsl:when>
        <xsl:otherwise>
          <span class="badge badge-{$color} {$class}">
            <xsl:call-template name="badge-content">
              <xsl:with-param name="tooltip" select="$tooltip"/>
              <xsl:with-param name="tooltip-data-placement" select="$tooltip-data-placement"/>
              <xsl:with-param name="title" select="$title"/>
              <xsl:with-param name="dataAttributes" select="$dataAttributes"/>
              <xsl:with-param name="label" select="$label"/>
              <xsl:with-param name="color-label" select="$color-label"/>
              <xsl:with-param name="background-color" select="$background-color"/>
            </xsl:call-template>
          </span>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>

</xsl:stylesheet>
