<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:param name="CurrentLang"/>
  <xsl:param name="ServletsBaseURL"/>
  <xsl:param name="WebApplicationBaseURL"/>
  <xsl:param name="isCurrentUserGuest" select="document('callJava:org.mycore.common.xml.MCRXMLFunctions:isCurrentUserGuestUser') = 'true'"/>

  <xsl:template name="output-badge">
    <xsl:param name="class"/>
    <xsl:param name="badge-type" select="'bg-info'"/>
    <xsl:param name="label"/>
    <xsl:param name="link"/>
    <xsl:param name="link-class"/>
    <xsl:param name="tooltip"/>
    <xsl:param name="icon-class"/>

    <div class="{$class}">
      <xsl:if test="$tooltip">
        <xsl:attribute name="data-toggle">
          <xsl:value-of select="'tooltip'"/>
        </xsl:attribute>

        <xsl:attribute name="title">
          <xsl:value-of select="$tooltip"/>
        </xsl:attribute>
      </xsl:if>

      <xsl:choose>
        <xsl:when test="$link">
          <a class="badge {$badge-type} {$link-class}" href="{$link}">
            <xsl:if test="$icon-class">
              <i class="{$icon-class}"/>
            </xsl:if>
            <xsl:value-of select="$label"/>
          </a>
        </xsl:when>
        <xsl:otherwise>
          <span class="badge {$badge-type} {$link-class}">
            <xsl:if test="$icon-class">
              <i class="{$icon-class}"/>
            </xsl:if>
            <xsl:value-of select="$label"/>
          </span>
        </xsl:otherwise>
      </xsl:choose>
    </div>

  </xsl:template>
</xsl:stylesheet>
