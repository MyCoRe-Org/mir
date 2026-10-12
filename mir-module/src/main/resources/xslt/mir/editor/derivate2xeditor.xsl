<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:mode on-no-match="shallow-copy" />

  <xsl:template match="classification[@classid and @categid]">
    <classification><xsl:value-of select="@classid"/>:<xsl:value-of select="@categid"/></classification>
  </xsl:template>

</xsl:stylesheet>
