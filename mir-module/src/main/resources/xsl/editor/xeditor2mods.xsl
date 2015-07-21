<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:mcrmods="xalan://org.mycore.mods.classification.MCRMODSClassificationSupport" exclude-result-prefixes="mcrmods" version="1.0"
>

  <xsl:include href="copynodes.xsl" />

  <!-- create value URI using valueURIxEditor and authorityURI -->
  <xsl:template match="@valueURIxEditor">
    <xsl:choose>
      <xsl:when test="(name(..) = 'mods:name') and (../@type = 'personal')">
        <xsl:choose>
          <xsl:when test="starts-with(., 'http://d-nb.info/gnd/')">
            <xsl:attribute name="authorityURI">http://d-nb.info/gnd/</xsl:attribute>
            <xsl:attribute name="valueURI"><xsl:value-of select="." /></xsl:attribute>
          </xsl:when>
          <xsl:when test="starts-with(., 'http://www.viaf.org/')">
            <xsl:attribute name="authorityURI">http://www.viaf.org/</xsl:attribute>
            <xsl:attribute name="valueURI"><xsl:value-of select="." /></xsl:attribute>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="valueURI">
          <xsl:value-of select="concat(../@authorityURI,'#',.)" />
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

  <!-- Copy content of mods:accessCondtition to mods:classification to enable classification support (see MIR-161) -->
  <xsl:template match="mods:accessCondition[@type='restriction on access']">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
    <mods:classification authority="accessRestriction"><xsl:value-of select="." /></mods:classification>
  </xsl:template>

</xsl:stylesheet>