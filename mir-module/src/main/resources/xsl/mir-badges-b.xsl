<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="xslImport:badges:mir-badges-b.xsl"/>

  <xsl:include href="mir-badges-style-template.xsl"/>

  <xsl:template match="doc" mode="resultList">
    <xsl:call-template name="ouput-badge">
      <xsl:with-param name="text" select="'mir-badges-b.xsl'"/>
    </xsl:call-template>
    <xsl:apply-imports/>
  </xsl:template>
</xsl:stylesheet>
