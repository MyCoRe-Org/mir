<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mods="http://www.loc.gov/mods/v3">
  <xsl:include href="copynodes.xsl" />
  
  <xsl:template match="//mods:originInfo[not(@eventType)]">
    <mods:originInfo>
      <xsl:attribute name="eventType">publication</xsl:attribute>
      <xsl:copy-of select="@*" />
      <xsl:apply-templates />
    </mods:originInfo>
  </xsl:template>
</xsl:stylesheet>