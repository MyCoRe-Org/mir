<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mcr="http://www.mycore.org/" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:mcrmods="xalan://org.mycore.mods.classification.MCRMODSClassificationSupport" exclude-result-prefixes="mcrmods xlink mcr" version="1.0"
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
  <xsl:template match="mods:accessCondition[@type='restriction on access'][@xlink:href='http://www.mycore.org/classifications/mir_access']">
    <mods:accessCondition type="restriction on access">
      <xsl:attribute name="xlink:href">
        <xsl:value-of select="concat(@xlink:href, '#', .)" />
      </xsl:attribute>
    </mods:accessCondition>
  </xsl:template>

  <xsl:template match="@mcr:categId" />
  <xsl:template match="*[@mcr:categId]">
    <xsl:copy>
      <xsl:variable name="classNodes" select="mcrmods:getClassNodes(.)" />
      <xsl:apply-templates select='$classNodes/@*|@*|node()|$classNodes/node()' />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mods:openAireID">
    <mods:identifier type="open-aire">
      <xsl:value-of select="." />
    </mods:identifier>
  </xsl:template>

</xsl:stylesheet>