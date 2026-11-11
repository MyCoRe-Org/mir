<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mirmapper="http://www.mycore.de/xslt/mirmapper"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:include href="resource:xslt/default-parameters.xsl" />
  <xsl:include href="xslInclude:functions" />

  <xsl:param name="value" />

  <xsl:template match="/test-classid">
    <result>
      <xsl:value-of select="mirmapper:classid($value)" />
    </result>
  </xsl:template>

  <xsl:template match="/test-categid">
    <result>
      <xsl:value-of select="mirmapper:categid($value)" />
    </result>
  </xsl:template>

  <xsl:template match="/test-class-uri">
    <result>
      <xsl:value-of select="mirmapper:class-uri($value)" />
    </result>
  </xsl:template>

  <xsl:template match="/test-old-sdnb">
    <result>
      <xsl:value-of select="mirmapper:getSDNBfromOldSDNB($value)" />
    </result>
  </xsl:template>

  <xsl:template match="/test-ddc">
    <result>
      <xsl:value-of select="mirmapper:getSDNBfromDDC($value)" />
    </result>
  </xsl:template>

</xsl:stylesheet>
