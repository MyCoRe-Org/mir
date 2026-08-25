<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:import href="xslImport:metadatabox:metadata/metadata-box/mods/publisher.xsl" />
  <xsl:import href="resource:xslt/metadata/metadata-box/mods/shared/metadata-row.xsl" />

  <xsl:template mode="display-metadata" match="mycoreobject">
    <xsl:apply-imports />

    <xsl:variable name="origin-info" select="metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo" />

    <xsl:call-template name="meta-row-from-nodes">
      <xsl:with-param name="label-key" select="'component.mods.metaData.dictionary.publisher'" />
      <xsl:with-param name="nodes" select="$origin-info[not(@eventType) or @eventType='publication']/mods:publisher" />
    </xsl:call-template>

    <xsl:call-template name="meta-row-from-nodes">
      <xsl:with-param name="label-key" select="'component.mods.metaData.dictionary.publisher.creation'" />
      <xsl:with-param name="nodes" select="$origin-info[@eventType='creation']/mods:publisher" />
    </xsl:call-template>

  </xsl:template>

</xsl:stylesheet>
