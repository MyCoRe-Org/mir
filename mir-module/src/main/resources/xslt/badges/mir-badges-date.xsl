<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mirdateconverter="http://www.mycore.de/xslt/mirdateconverter"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:import href="xslImport:badges:badges/mir-badges-date.xsl"/>
  <xsl:include href="resource:xslt/badges/mir-badges-utils.xsl"/>

  <xsl:template match="doc" mode="badge">
    <xsl:apply-imports/>

    <xsl:choose>
      <xsl:when test="str[@name='mods.dateIssued'] or str[@name='mods.dateIssued.host']">
        <xsl:call-template name="output-date-badge">
          <xsl:with-param name="date" select="str[@name='mods.dateIssued'] | str[@name='mods.dateIssued.host']"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="field[@name='mods.dateIssued'] or field[@name='mods.dateIssued.host']">
        <xsl:call-template name="output-date-badge">
          <xsl:with-param name="date" select="field[@name='mods.dateIssued'] | field[@name='mods.dateIssued.host']"/>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="output-date-badge">
    <xsl:param name="date"/>
    <xsl:variable name="label">
      <xsl:call-template name="format-date-label">
        <xsl:with-param name="date" select="string(($date)[1])"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:call-template name="output-badge">
      <xsl:with-param name="class" select="'mir-badge-date'"/>
      <xsl:with-param name="label" select="$label"/>
      <xsl:with-param name="link" select="concat($ServletsBaseURL, 'solr/find?condQuery=*&amp;fq=mods.dateIssued:%22', string(($date)[1]), '%22')"/>
      <xsl:with-param name="tooltip" select="mcri18n:translate('mir.date.published')"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="format-date-label">
    <xsl:param name="date" as="xs:string?"/>
    <xsl:variable name="normalized" select="mirdateconverter:convert-date($date, 'ISO8601')"/>

    <xsl:choose>
      <xsl:when test="matches($normalized, '^\d{4}$')">
        <xsl:value-of select="$normalized"/>
      </xsl:when>
      <xsl:when test="matches($normalized, '^\d{4}-\d{2}$')">
        <xsl:value-of select="$normalized"/>
      </xsl:when>
      <xsl:when test="matches($normalized, '^\d{4}-\d{2}-\d{2}$')">
        <xsl:value-of select="format-date(xs:date($normalized), mcri18n:translate('metaData.dateYearMonthDay.xsl3'))"/>
      </xsl:when>
      <xsl:when test="$normalized castable as xs:dateTime">
        <xsl:value-of select="format-dateTime(xs:dateTime($normalized), mcri18n:translate('metaData.dateTime.xsl3'))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$normalized"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
