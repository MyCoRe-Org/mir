<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exslt="http://exslt.org/common"
                exclude-result-prefixes="xsl exslt">

  <!-- Central badge creation template -->
  <xsl:template name="create-badge">
    <xsl:param name="label" />
    <xsl:param name="color" select="'primary'" />
    <xsl:param name="URL" select="''" />
    <xsl:param name="class" select="''" />
    <xsl:param name="title" select="''" />
    <xsl:param name="dataAttributes" />
    <xsl:param name="tooltip" select="''" />
    <xsl:param name="tooltip-data-placement" select="'top'" />

    <div class="badge-item">
      <xsl:variable name="badge-content">
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
        <xsl:value-of select="$label" />
      </xsl:variable>

      <xsl:choose>
        <xsl:when test="$URL != ''">
          <a href="{$URL}" class="badge badge-{$color} {$class}">
            <xsl:copy-of select="$badge-content"/>
          </a>
        </xsl:when>
        <xsl:otherwise>
          <span class="badge badge-{$color} {$class}">
            <xsl:copy-of select="$badge-content"/>
          </span>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>

</xsl:stylesheet>
