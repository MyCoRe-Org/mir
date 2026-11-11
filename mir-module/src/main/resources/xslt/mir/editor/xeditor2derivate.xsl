<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:mode on-no-match="shallow-copy" />

  <xsl:template match="classification[contains(text(), ':')]">
    <xsl:variable name="classid" select="substring-before(text(),':')"/>
    <xsl:variable name="categid" select="substring-after(text(),':')"/>
    <classification classid="{$classid}" categid="{$categid}"/>
  </xsl:template>

</xsl:stylesheet>
