<?xml version="1.0" encoding="ISO-8859-1"?>

<!-- Pre-processor for editor forms reading MODS -->

<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  exclude-result-prefixes="xsl">

  <xsl:include href="copynodes.xsl" />

  <!-- A single page (edited as start=end) is represented as mods:detail/@type='page' -->
  <xsl:template match="mods:detail[@type='page']">
    <mods:extent unit="pages">
      <mods:start>
        <xsl:value-of select="mods:number" />
      </mods:start>
      <mods:end>
        <xsl:value-of select="mods:number" />
      </mods:end>
    </mods:extent>
  </xsl:template>

</xsl:stylesheet>
