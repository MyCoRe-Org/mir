<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcrmods="http://www.mycore.de/xslt/mods"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template match="mods:name" mode="name">
    <xsl:choose>
      <xsl:when test="mods:role/mods:roleTerm = 'aut'">
        <xsl:variable name="prop-type" select="if (@type='corporate') then 'Organisation' else 'Person'" />
        <xsl:variable name="name-value">
          <xsl:apply-templates select="." mode="name-value" />
        </xsl:variable>
        <span property="author" typeof="{$prop-type}">
          <xsl:copy-of select="$name-value" />
          <meta property="name" content="{$name-value}" />
        </span>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="." mode="name-value" />
      </xsl:otherwise>
    </xsl:choose>

    <xsl:for-each select="mods:nameIdentifier[@type]">
      <xsl:call-template name="name-identifier-link">
        <xsl:with-param name="identifier" select="string(.)" />
        <xsl:with-param name="identifier-type" select="string(@type)" />
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="mods:name[@valueURI]" mode="external-link">
    <a href="{@valueURI}">
      <xsl:choose>
        <xsl:when test="mods:displayForm">
          <xsl:value-of select="mods:displayForm" />
        </xsl:when>
        <xsl:when test="mods:namePart">
          <xsl:apply-templates select="." mode="name-parts" />
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

  <xsl:template match="mods:name" mode="name-parts">
    <xsl:choose>
      <xsl:when test="mods:namePart[@type='given'] and mods:namePart[@type='family']">
        <xsl:value-of select="concat(mods:namePart[@type='family'][1], ', ', mods:namePart[@type='given'][1])" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="mods:namePart" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mods:name" mode="name-value">
    <xsl:choose>
      <xsl:when test="@valueURI">
        <xsl:variable name="class" select="mcrmods:to-mycoreclass(., 'parent')" />
        <xsl:choose>
          <xsl:when test="$class">
            <xsl:for-each select="$class//category[position()=1 or position()=last()]">
              <xsl:if test="position() > 1">
                <xsl:value-of select="', '" />
              </xsl:if>
              <xsl:apply-templates select="." mode="classification" />
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="." mode="external-link" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="mods:namePart">
        <xsl:apply-templates select="." mode="name-parts" />
      </xsl:when>
      <xsl:when test="mods:displayForm">
        <xsl:value-of select="mods:displayForm" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="." />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="name-identifier-link">
    <xsl:param name="identifier" as="xs:string" />
    <xsl:param name="identifier-type" as="xs:string" />
    <!-- TODO use xslt function -->
    <xsl:variable name="classi" select="
      document(concat('classification:metadata:all:children:','nameIdentifier',':', $identifier-type))
        /mycoreclass/categories/category[@ID=$identifier-type]
    " />
    <xsl:variable name="uri" select="$classi/label[@xml:lang='x-uri']/@text" />
    <xsl:variable name="id-type" select="$classi/label[@xml:lang='de']/@text" />
    <xsl:text>&#160;</xsl:text>
    <a href="{$uri}{$identifier}" title="Link zu {$id-type}">
      <sup>
        <xsl:value-of select="$id-type" />
      </sup>
    </a>
  </xsl:template>

</xsl:stylesheet>
