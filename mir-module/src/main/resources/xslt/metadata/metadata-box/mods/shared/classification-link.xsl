<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcrmods="http://www.mycore.de/xslt/mods"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mcrproperty="http://www.mycore.de/xslt/property"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template match="category" mode="classification">
    <xsl:variable name="categurl">
      <xsl:if test="url">
        <xsl:choose>
          <xsl:when test="contains(url/@xlink:href, ':')">
            <xsl:value-of select="url/@xlink:href" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$WebApplicationBaseURL || 'receive/'  || url/@xlink:href" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="selectLang" select="mcri18n:select-lang(label)" />
    <xsl:for-each select="label[lang($selectLang)]">
      <xsl:choose>
        <xsl:when test="string-length($categurl) != 0">
          <a href="{$categurl}">
            <xsl:if test="mcrproperty:get('wcms.useTargets')">
              <xsl:attribute name="target">_blank</xsl:attribute>
            </xsl:if>
            <xsl:value-of select="@text" />
          </a>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@text" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="*" mode="classification">
    <xsl:variable name="category" select="mcrmods:to-category(.)" />
    <xsl:choose>
      <xsl:when test="$category">
        <xsl:apply-templates select="$category" mode="classification" />
      </xsl:when>
      <xsl:when test="@valueURI">
        <xsl:apply-templates select="." mode="external-link" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="text()" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*[@valueURI]" mode="external-link">
    <a href="{@valueURI}">
      <xsl:choose>
        <xsl:when test="mods:displayForm">
          <xsl:value-of select="mods:displayForm" />
        </xsl:when>
        <xsl:when test="@displayLabel">
          <xsl:value-of select="@displayLabel" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@valueURI" />
        </xsl:otherwise>
      </xsl:choose>
    </a>
  </xsl:template>

</xsl:stylesheet>
