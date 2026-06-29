<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:output method="xml" />

  <xsl:mode on-no-match="shallow-copy" />

  <xsl:template match="fn:array[@key='title']">
    <xsl:for-each select="fn:string">
      <fn:array key="title">
        <xsl:copy-of select="."/>
      </fn:array>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
