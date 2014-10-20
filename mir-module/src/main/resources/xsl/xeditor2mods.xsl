<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:mcrmods="xalan://org.mycore.mods.MCRMODSClassificationSupport" exclude-result-prefixes="mcrmods" version="1.0">

  <xsl:include href="copynodes.xsl" />

  <!-- create value URI using valueURIxEditor and authorityURI -->
  <xsl:template match="@valueURIxEditor">
    <xsl:attribute name="valueURI">
      <xsl:value-of select="concat(../@authorityURI,'#',.)" />
    </xsl:attribute>
  </xsl:template>


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