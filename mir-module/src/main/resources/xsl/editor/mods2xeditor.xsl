<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:mcrmods="xalan://org.mycore.mods.MCRMODSClassificationSupport" exclude-result-prefixes="mcrmods" version="1.0"
>

  <xsl:include href="copynodes.xsl" />

  <!-- put value string (after authority URI) in attribute valueURIxEditor -->
  <xsl:template match="@valueURI">
    <xsl:choose>
      <xsl:when test="(name(..) = 'mods:name') and (../@type = 'personal')">
        <xsl:choose>
          <xsl:when test="starts-with(., 'http://d-nb.info/gnd/')">
            <xsl:attribute name="valueURIxEditor"><xsl:value-of select="." /></xsl:attribute>
          </xsl:when>
          <xsl:when test="starts-with(., 'http://www.viaf.org/')">
            <xsl:attribute name="valueURIxEditor"><xsl:value-of select="." /></xsl:attribute>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="valueURIxEditor">
          <xsl:value-of select="substring-after(.,'#')" />
        </xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- A single page (entered as start=end) must be represented as mods:detail/@type='page' -->
  <xsl:template match="mods:extent[(@unit='pages') and (mods:start=mods:end)]">
    <mods:detail type="page">
      <mods:number>
        <xsl:value-of select="mods:start" />
      </mods:number>
    </mods:detail>
  </xsl:template>

  <!-- Derive dateIssued from dateOther if not present -->
  <xsl:template match="mods:dateOther[(@type='accepted') and not(../mods:dateIssued)]">
    <mods:dateIssued>
      <xsl:copy-of select="@encoding" />
      <xsl:value-of select="substring(.,1,4)" />
    </mods:dateIssued>
    <xsl:copy-of select="." />
  </xsl:template>
</xsl:stylesheet>