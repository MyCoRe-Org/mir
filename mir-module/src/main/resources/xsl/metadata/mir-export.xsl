<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:mods="http://www.loc.gov/mods/v3" exclude-result-prefixes="i18n mods">
  <xsl:import href="xslImport:modsmeta:metadata/mir-export.xsl" />
  <xsl:template match="/">
    <xsl:variable name="mods" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods" />
    <div id="mir-export">
      <xsl:call-template name="exportLink">
        <xsl:with-param name="transformer" select="'bibtex'"/>
        <xsl:with-param name="linkText" select="'BibTeX'"/>
      </xsl:call-template>
      <xsl:call-template name="printSeperator" />
      <xsl:call-template name="exportLink">
        <xsl:with-param name="transformer" select="'mods'"/>
        <xsl:with-param name="linkText" select="'MODS'"/>
      </xsl:call-template>
      <xsl:call-template name="printSeperator" />
      <xsl:call-template name="exportLink">
        <xsl:with-param name="transformer" select="'ris'"/>
        <xsl:with-param name="linkText" select="'RIS'"/>
      </xsl:call-template>
      <xsl:call-template name="printSeperator" />
      <xsl:call-template name="exportLink">
        <xsl:with-param name="transformer" select="'isi'"/>
        <xsl:with-param name="linkText" select="'ISI'"/>
      </xsl:call-template>
      <xsl:call-template name="printSeperator" />
      <xsl:call-template name="exportLink">
        <xsl:with-param name="transformer" select="'pica3'"/>
        <xsl:with-param name="linkText" select="'PICA'"/>
      </xsl:call-template>
      <xsl:call-template name="printSeperator" />
      <xsl:call-template name="exportLink">
        <xsl:with-param name="transformer" select="'mods2csv'"/>
        <xsl:with-param name="linkText" select="'CSV'"/>
      </xsl:call-template>
      <xsl:call-template name="printSeperator" />
      <xsl:call-template name="exportLink">
        <xsl:with-param name="transformer" select="'mods2dc'"/>
        <xsl:with-param name="linkText" select="'DC'"/>
      </xsl:call-template>
    </div>
    <xsl:apply-imports />
  </xsl:template>
  <xsl:template name="exportLink">
    <xsl:param name="transformer" />
    <xsl:param name="linkText" />
    <a>
      <xsl:attribute name="href">
        <xsl:value-of select="concat($WebApplicationBaseURL,'receive/',/mycoreobject/@ID,'?XSL.Transformer=',$transformer)" />
      </xsl:attribute>
      <xsl:value-of select="$linkText" />
    </a>
  </xsl:template>
  <xsl:template name="printSeperator">
    <span><xsl:text>, </xsl:text></span>
  </xsl:template>
</xsl:stylesheet>