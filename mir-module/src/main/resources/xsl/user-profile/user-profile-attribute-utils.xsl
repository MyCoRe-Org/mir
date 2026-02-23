<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="xsl">

  <xsl:template match="user|owner" mode="name">
    <xsl:value-of select="@name"/>
    <xsl:text> [</xsl:text>
    <xsl:value-of select="@realm"/>
    <xsl:text>]</xsl:text>
  </xsl:template>

</xsl:stylesheet>
