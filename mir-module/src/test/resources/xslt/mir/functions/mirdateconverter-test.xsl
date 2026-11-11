<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mirdateconverter="http://www.mycore.de/xslt/mirdateconverter"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:include href="resource:xslt/default-parameters.xsl" />
  <xsl:include href="xslInclude:functions" />

  <xsl:param name="date" />
  <xsl:param name="format" />
  <xsl:param name="value" />

  <xsl:template match="/test-convert-date">
    <result>
      <xsl:value-of select="mirdateconverter:convert-date($date, $format)" />
    </result>
  </xsl:template>

  <xsl:template match="/test-normalize-w3cdtf-to-utc">
    <result>
      <xsl:value-of select="mirdateconverter:normalize-w3cdtf-to-utc($value)" />
    </result>
  </xsl:template>

</xsl:stylesheet>
