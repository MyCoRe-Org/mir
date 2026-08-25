<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:local="http://www.w3.org/2005/xquery-local-functions"
  xmlns:mcrmods="http://www.mycore.de/xslt/mods"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:import href="resource:xslt/metadata/metadata-box/mods/shared/classification-link.xsl" />

  <xsl:template match="mods:name" mode="name">
    <xsl:choose>
      <xsl:when test="mods:role/mods:roleTerm = 'aut'">
        <xsl:variable name="propType" select="if (@type='corporate') then 'Organisation' else 'Person'" />
        <span property="author" typeof="{$propType}">
          <xsl:apply-templates select="." mode="name-value" />
          <meta property="name" content="{local:mods-name-string(.)}" />
        </span>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="." mode="name-value" />
      </xsl:otherwise>
    </xsl:choose>

    <xsl:if test="mods:nameIdentifier/@type">
      <xsl:call-template name="name-identifier-link">
        <xsl:with-param name="identifier" select="string(mods:nameIdentifier)" />
        <xsl:with-param name="identifier-type" select="mods:nameIdentifier/@type" />
      </xsl:call-template>
    </xsl:if>
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
            <xsl:apply-templates select="." mode="value-suffix" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="mods:namePart[@type='given'] and mods:namePart[@type='family']">
        <xsl:value-of select="concat(mods:namePart[@type='family'], ', ', mods:namePart[@type='given'])" />
      </xsl:when>
      <xsl:when test="mods:namePart">
        <xsl:value-of select="mods:namePart" />
      </xsl:when>
      <xsl:when test="mods:displayForm">
        <xsl:value-of select="mods:displayForm" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="." />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:function name="local:mods-name-string" as="xs:string">
    <xsl:param name="name" as="element(mods:name)" />
    <xsl:variable name="value">
      <xsl:apply-templates select="$name" mode="name-value" />
    </xsl:variable>
    <xsl:sequence select="string($value)" />
  </xsl:function>

  <xsl:template name="name-identifier-link">
    <xsl:param name="identifier" as="xs:string" />
    <xsl:param name="identifier-type" as="xs:string" />
    <!-- TODO use xslt function -->
    <xsl:variable name="classi" select="
      document(concat('classification:metadata:all:children:','nameIdentifier',':', $identifier-type))
        /mycoreclass/categories/category[@ID=$identifier-type]
    " />
    <xsl:variable name="uri" select="$classi/label[@xml:lang='x-uri']/@text" />
    <xsl:variable name="idType" select="$classi/label[@xml:lang='de']/@text" />
    <xsl:text>&#160;</xsl:text>
    <a href="{$uri}{$identifier}" title="Link zu {$idType}">
      <sup>
        <xsl:value-of select="$idType" />
      </sup>
    </a>
  </xsl:template>

</xsl:stylesheet>
