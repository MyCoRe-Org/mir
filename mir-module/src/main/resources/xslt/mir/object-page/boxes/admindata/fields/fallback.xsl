<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template match="field" mode="admindata-box-field">
    <xsl:message>WARN: unknown admin box field '<xsl:value-of select="@name" />'</xsl:message>
  </xsl:template>

</xsl:stylesheet>
