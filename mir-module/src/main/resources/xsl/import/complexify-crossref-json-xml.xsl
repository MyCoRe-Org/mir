<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xpf="http://www.w3.org/2005/xpath-functions"
                exclude-result-prefixes="xsl xpf">

  <xsl:output method="xml" />

  <xsl:include href="copynodes.xsl"/>

  <xsl:template match="xpf:array[@key='title']">
    <xsl:for-each select="xpf:string">
      <array xmlns="http://www.w3.org/2005/xpath-functions" key="title">
        <xsl:copy-of select="."/>
      </array>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
