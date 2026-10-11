<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:local="http://www.mycore.de/xslt/mirlocal/admindata-box/shared/date"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mirdateconverter="http://www.mycore.de/xslt/mirdateconverter"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template name="service-date-row">
    <xsl:param name="date" as="element()?" />
    <xsl:param name="label-key" as="xs:string" />

    <xsl:if test="$date">
      <xsl:call-template name="meta-row">
        <xsl:with-param name="label-key" select="$label-key" />
        <xsl:with-param name="value" select="local:format-service-date($date)" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:function name="local:format-service-date" as="xs:string">
    <xsl:param name="date" as="element()" />

    <xsl:variable name="normalized" select="mirdateconverter:convert-date($date, 'ISO8601')" />

    <xsl:sequence select="
      if (matches($normalized, '^\d{4}-\d{2}-\d{2}$'))
      then format-date(xs:date($normalized), mcri18n:translate('metaData.dateYearMonthDay.xsl3'))
      else if ($normalized castable as xs:dateTime)
      then format-dateTime(xs:dateTime($normalized), mcri18n:translate('metaData.dateTime.xsl3'))
      else $normalized
    " />
  </xsl:function>

</xsl:stylesheet>
