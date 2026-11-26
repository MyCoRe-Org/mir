<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all">

  <xsl:param name="derivateId" select="'mir_derivate_00000001'"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <!-- already migrated root element -->
  <xsl:template match="/guidance">
    <xsl:copy-of select="."/>
  </xsl:template>

  <!-- not yet migrated root element -->
  <xsl:template match="/item">
    <guidance>
      <xsl:variable name="banner" select="if (starts-with(@banner, '/')) then substring(@banner, 2) else @banner"/>
      <xsl:variable name="fileNodeServletPath" select="'servlets/MCRFileNodeServlet/'"/>
      <xsl:variable name="localBannerPrefix" select="concat($fileNodeServletPath, $derivateId, '/')"/>
      <title>
        <xsl:apply-templates select="label"/>
      </title>
      <xsl:if test="$banner">
        <banners>
          <banner>
            <xsl:choose>
              <xsl:when test="starts-with($banner, $localBannerPrefix)">
                <image file="{substring($banner, string-length($localBannerPrefix) + 1)}"/>
              </xsl:when>
              <xsl:when test="starts-with($banner, 'http://') or starts-with($banner, 'https://')">
                <image href="{$banner}"/>
              </xsl:when>
              <xsl:otherwise>
                <image ref="{$banner}"/>
              </xsl:otherwise>
            </xsl:choose>
          </banner>
        </banners>
      </xsl:if>
      <items search="true">
        <xsl:apply-templates select="item"/>
      </items>
    </guidance>
  </xsl:template>

  <!-- not yet migrated inner element -->
  <xsl:template match="item">
    <item>
      <xsl:variable name="ref" select="if (starts-with(@ref, '/')) then substring(@ref, 2) else @ref"/>
      <xsl:variable name="derivateContentServletPath" select="'servlets/MCRDerivateContentTransformerServlet/'"/>
      <xsl:variable name="localRefPrefix" select="concat($derivateContentServletPath, $derivateId, '/')"/>
      <xsl:if test="$ref">
        <xsl:choose>
          <xsl:when test="starts-with($ref, $localRefPrefix) and ends-with($ref, '.xml')">
            <link file="{substring($ref, string-length($localRefPrefix) + 1)}"/>
          </xsl:when>
          <xsl:when test="starts-with($ref, 'http://') or starts-with($ref, 'https://')">
            <link href="{$ref}"/>
          </xsl:when>
          <xsl:otherwise>
            <link ref="{$ref}"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      <xsl:apply-templates/>
    </item>
  </xsl:template>

</xsl:stylesheet>
