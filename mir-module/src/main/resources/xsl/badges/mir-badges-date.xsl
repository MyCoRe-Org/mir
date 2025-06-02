<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:mods="http://www.loc.gov/mods/v3"
                exclude-result-prefixes="mods">

  <xsl:import href="xslImport:badges:badges/mir-badges-date.xsl"/>
  <xsl:include href="resource:xsl/badges/mir-badges-utils.xsl"/>

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
    <xsl:variable name="format">
      <xsl:call-template name="get-dateformat">
        <xsl:with-param name="date" select="$date"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="label" select="document(concat('callJava:org.mycore.common.xml.MCRXMLFunctions:formatISODate:', $date, ':', $format, ':', $CurrentLang))"/>

    <xsl:call-template name="output-badge">
      <xsl:with-param name="class" select="'mir-badge-date'"/>
      <xsl:with-param name="badge-type" select="'bg-primary'"/>
      <xsl:with-param name="label" select="$label"/>
      <xsl:with-param name="link" select="concat($ServletsBaseURL, 'solr/find?condQuery=*&amp;fq=mods.dateIssued:%22', $date, '%22')"/>
      <xsl:with-param name="link-class" select="'date_published'"/>
      <xsl:with-param name="tooltip" select="document('i18n:mir.date.published')/i18n/text()"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="get-dateformat">
    <xsl:param name="date"/>

    <xsl:choose>
      <xsl:when test="string-length(normalize-space($date))=4">
        <xsl:value-of select="document('i18n:metaData.dateYear')/i18n/text()"/>
      </xsl:when>
      <xsl:when test="string-length(normalize-space($date))=7">
        <xsl:value-of select="document('i18n:metaData.dateYearMonth')/i18n/text()"/>
      </xsl:when>
      <xsl:when test="string-length(normalize-space($date))=10">
        <xsl:value-of select="document('i18n:metaData.dateYearMonthDay')/i18n/text()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="document('i18n:metaData.dateTime')/i18n/text()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
