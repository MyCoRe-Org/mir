<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:import href="xslImport:metadatabox:metadata/metadata-box/mods/language.xsl" />
  <xsl:import href="resource:xslt/metadata/metadata-box/mods/shared/metadata-row.xsl" />
  <xsl:import href="resource:xslt/metadata/metadata-box/mods/shared/classification-link.xsl" />

  <xsl:template mode="display-metadata" match="mycoreobject">
    <xsl:apply-imports />

    <xsl:variable name="languages" select="metadata/def.modsContainer/modsContainer/mods:mods/mods:language" />
    <xsl:if test="$languages">
      <xsl:call-template name="languages">
        <xsl:with-param name="languages" select="$languages" />
      </xsl:call-template>
    </xsl:if>

  </xsl:template>

  <xsl:template name="languages">
    <xsl:param name="languages" as="element(mods:language)*" />

    <xsl:call-template name="meta-row-from-nodes">
      <xsl:with-param name="nodes" select="$languages/mods:languageTerm[@authority='rfc5646']" />
      <xsl:with-param name="label-key" select="'component.mods.metaData.dictionary.language'" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:languageTerm[@authority='rfc5646']" mode="value-content">
    <xsl:apply-templates select="." mode="classification" />
  </xsl:template>

  <xsl:template match="mods:languageTerm[@authority='rfc5646']" mode="value-suffix">
    <meta property="inLanguage" content="{.}" />
  </xsl:template>

</xsl:stylesheet>
