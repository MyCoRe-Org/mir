<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mirstrutils="http://www.mycore.de/xslt/mirstrutils"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:include href="resource:xslt/default-parameters.xsl" />
  <xsl:include href="xslInclude:functions" />

  <xsl:param name="value" />

  <xsl:template match="/test-escape-xml">
    <result>
      <xsl:value-of select="mirstrutils:escape-xml($value)" />
    </result>
  </xsl:template>

  <xsl:template match="/test-unescape-xml">
    <result>
      <xsl:value-of select="mirstrutils:unescape-xml($value)" />
    </result>
  </xsl:template>

  <xsl:template match="/test-unescape-html">
    <result>
      <xsl:value-of select="mirstrutils:unescape-html($value)" />
    </result>
  </xsl:template>

</xsl:stylesheet>
