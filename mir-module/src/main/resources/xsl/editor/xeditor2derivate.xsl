<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                exclude-result-prefixes="xlink" version="1.0"
>

  <xsl:include href="copynodes.xsl"/>

  <xsl:template match="classification[contains(text(), ':')]">
    <xsl:variable name="classid" select="substring-before(text(),':')"/>
    <xsl:variable name="categid" select="substring-after(text(),':')"/>
    <classification classid="{$classid}" categid="{$categid}" />
  </xsl:template>

</xsl:stylesheet>