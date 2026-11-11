<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template match="node()" mode="value-content">
    <xsl:call-template name="lf2br">
      <xsl:with-param name="string" select="." />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="node()" mode="value-suffix" />

</xsl:stylesheet>
