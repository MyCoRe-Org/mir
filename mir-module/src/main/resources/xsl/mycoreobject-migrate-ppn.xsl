<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
     version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     xmlns:mcriw="xalan://org.mycore.mir.imageware.MIRImageWarePacker"
     xmlns:mods="http://www.loc.gov/mods/v3"
     exclude-result-prefixes="mcriw">

  <xsl:include href="copynodes.xsl" />
  <xsl:include href="coreFunctions.xsl" />

  <xsl:template match="//mods:mods/mods:identifier[@type='uri']">
    <xsl:choose>
      <xsl:when test="contains(.,'ppn') or contains(.,'PPN')">
        <xsl:call-template name="migrate_ppn" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="//mods:mods/mods:identifier[@type='ppn']">
    <xsl:call-template name="migrate_ppn" />
  </xsl:template>

  <xsl:template name="migrate_ppn">
    <mods:identifier type="uri">
      <xsl:variable name="ppn" select="mcriw:detectPPN(//mycoreobject/@ID)" />
      <xsl:variable name="ppn_replace">
        <xsl:call-template name="ersetzen">
          <xsl:with-param name="vorlage" select="$ppn" />
          <xsl:with-param name="raus" select="'_'" />
          <xsl:with-param name="rein" select="':'" />
        </xsl:call-template>
      </xsl:variable>
      <xsl:value-of select="concat('http://uri.gbv.de/document/',$ppn_replace)" />
    </mods:identifier>
  </xsl:template>
</xsl:stylesheet>