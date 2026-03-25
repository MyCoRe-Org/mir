<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:param name="CurrentLang"/>
  <xsl:param name="ServletsBaseURL"/>
  <xsl:param name="WebApplicationBaseURL"/>
  <xsl:param name="isCurrentUserGuest" select="document('userobjectrights:isCurrentUserGuestUser:')/boolean = 'true'"/>

  <xsl:template name="output-badge">
    <xsl:param name="class"/>
    <xsl:param name="label"/>
    <xsl:param name="link"/>
    <xsl:param name="tooltip"/>
    <xsl:param name="icon-class"/>
    <xsl:choose>
      <xsl:when test="$link">
        <a class="badge {$class}" href="{$link}">
          <xsl:if test="$tooltip">
            <xsl:attribute name="data-bs-toggle" select="'tooltip'"/>
            <xsl:attribute name="title" select="$tooltip"/>
          </xsl:if>
          <xsl:if test="$icon-class">
            <i class="{$icon-class}"/>
          </xsl:if>
          <xsl:value-of select="$label"/>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <span class="badge {$class}">
          <xsl:if test="$tooltip">
            <xsl:attribute name="data-bs-toggle" select="'tooltip'"/>
            <xsl:attribute name="title" select="$tooltip"/>
          </xsl:if>
          <xsl:if test="$icon-class">
            <i class="{$icon-class}"/>
          </xsl:if>
          <xsl:value-of select="$label"/>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
