<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:mir="http://www.mycore.de/mir"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="mir">

  <xsl:include href="resource:xsl/copynodes.xsl"/>

  <xsl:template match="classification[@classid and @categid]">
    <classification><xsl:value-of select="@classid"/>:<xsl:value-of select="@categid"/></classification>
  </xsl:template>

</xsl:stylesheet>
