<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:strutils="http://www.mycore.de/xslt/strutils"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="mods strutils">
  
  <!-- 
   - Applys a nodeset with given namespace (default: 'mods') to given maximal depth.
   - If maximal depth is reached and $serialize is true() sub-tags encode as string.
   -->
  <xsl:template match="*" mode="asXmlNode">
    <xsl:param name="ns" select="'mods'" />
    <xsl:param name="serialize" select="true()" />
    <xsl:param name="levels" select="1" />
    <xsl:param name="curLevel" select="0" />

    <xsl:choose>
      <xsl:when test="node() and (number($curLevel) &lt; number($levels))">
        <xsl:variable name="name">
          <xsl:choose>
            <xsl:when test="string-length($ns) &gt; 0">
              <xsl:value-of select="concat('mods:', local-name(.))" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="local-name(.)" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:element name="{$name}">
          <xsl:apply-templates select="@*" />
          <xsl:apply-templates mode="asXmlNode">
            <xsl:with-param name="ns" select="$ns" />
            <xsl:with-param name="serialize" select="$serialize" />
            <xsl:with-param name="levels" select="number($levels)" />
            <xsl:with-param name="curLevel" select="number($curLevel + 1)" />
          </xsl:apply-templates>
        </xsl:element>
      </xsl:when>
      <xsl:when test="not($serialize)">
        <xsl:message>
          <xsl:apply-templates />
        </xsl:message>
      </xsl:when>
      <xsl:otherwise>
        <!-- serialize node to string -->
        <xsl:apply-templates select="." mode="serialize" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="text()" mode="asXmlNode">
    <xsl:param name="serialize" select="true()" />

    <xsl:choose>
      <xsl:when test="$serialize">
        <xsl:value-of select="strutils:unescapeXml(strutils:unescapeHtml(.))" disable-output-escaping="no" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="strutils:escapeXml(.)" disable-output-escaping="yes" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    - nodeset with plain text content
    -->
  <xsl:template match="*" mode="asPlainTextNode">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:apply-templates mode="asPlainTextNode" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="text()" mode="asPlainTextNode">
    <xsl:value-of select="strutils:stripHtml(.)" />
  </xsl:template>
  
  <!-- 
    - nodeset to string serializer
    -->
  <xsl:template match="*" mode="serialize">
    <xsl:text>&lt;</xsl:text>
    <xsl:value-of select="name()" />
    <xsl:apply-templates select="@*" mode="serialize" />
    <xsl:choose>
      <xsl:when test="node()">
        <xsl:text>&gt;</xsl:text>
        <xsl:apply-templates mode="serialize" />
        <xsl:text>&lt;/</xsl:text>
        <xsl:value-of select="name()" />
        <xsl:text>&gt;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text> /&gt;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="@*" mode="serialize">
    <xsl:text> </xsl:text>
    <xsl:value-of select="name()" />
    <xsl:text>="</xsl:text>
    <xsl:value-of select="." />
    <xsl:text>"</xsl:text>
  </xsl:template>

  <xsl:template match="text()" mode="serialize">
    <xsl:value-of select="strutils:unescapeXml(.)" disable-output-escaping="yes" />
  </xsl:template>
</xsl:stylesheet>