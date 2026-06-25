<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="fn xsl">

  <xsl:output method="xml" />

  <xsl:include href="resource:xsl/copynodes.xsl"/>

  <xsl:template match="fn:array[@key='title']">
    <xsl:for-each select="fn:string">
      <array xmlns="http://www.w3.org/2005/xpath-functions" key="title">
        <xsl:copy-of select="."/>
      </array>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
