<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:import href="xslImport:metadatabox:metadata/metadata-box/metadata/mods/conference.xsl" />
  <xsl:import href="resource:xslt/metadata/metadata-box/mods/shared/metadata-row.xsl" />

  <xsl:template mode="display-metadata" match="mycoreobject">
    <xsl:apply-imports />

    <xsl:call-template name="meta-row-from-nodes">
      <xsl:with-param name="label-key" select="'component.mods.metaData.dictionary.conference.title'" />
      <xsl:with-param name="nodes" select="
        metadata/def.modsContainer/modsContainer/mods:mods/mods:name[@type='conference']/mods:namePart[not(@type)]
      " />
    </xsl:call-template>

  </xsl:template>

</xsl:stylesheet>
