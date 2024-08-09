<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mods="http://www.loc.gov/mods/v3">
  <xsl:include href="copynodes.xsl" />
  
  <xsl:template match="//mods:note[@type='mcr_intern' or @type='mcr intern']">
    <mods:note>
      <xsl:attribute name="type">admin</xsl:attribute>
      <xsl:copy-of select="@*[name()!='type']" />
      <xsl:apply-templates />
    </mods:note>
  </xsl:template>
  
</xsl:stylesheet>