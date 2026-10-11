<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mirdateconverter="http://www.mycore.de/xslt/mirdateconverter"
  xmlns:mirdates="http://www.mycore.de/xslt/mirdates"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:function name="mirdates:format" as="xs:string">
    <xsl:param name="date" as="element()" />

    <xsl:variable name="normalized" select="mirdateconverter:convert-date($date, 'ISO8601')" />

    <xsl:sequence select="
      if (matches($normalized, '^\d{4}$'))
      then $normalized
      else if (matches($normalized, '^\d{4}-\d{2}$'))
      then format-date(xs:date($normalized || '-01'), mcri18n:translate('mir.xsl3.formate.yearMonth'))
      else if (matches($normalized, '^\d{4}-\d{2}-\d{2}$'))
      then format-date(xs:date($normalized), mcri18n:translate('mir.xsl3.formate.date'))
      else $normalized
    " />
  </xsl:function>

</xsl:stylesheet>
