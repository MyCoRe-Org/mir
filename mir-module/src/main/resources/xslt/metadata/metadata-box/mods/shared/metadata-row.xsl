<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:import href="resource:xslt/metadata/common/metadata-row.xsl" />

  <xsl:template name="mods-meta-row">
    <xsl:param name="nodes" as="node()*" />
    <xsl:param name="label" as="xs:string?" />
    <xsl:param name="sep" select="''" as="xs:string" />
    <xsl:param name="value-property" as="xs:string?" />
    <xsl:param name="filter" select="true()" as="xs:boolean" />

    <xsl:call-template name="meta-row-from-nodes">
      <xsl:with-param name="nodes" select="$nodes" />
      <xsl:with-param name="label" select="$label" />
      <xsl:with-param name="label-key" select="concat('component.mods.metaData.dictionary.', local-name($nodes[1]))" />
      <xsl:with-param name="sep" select="$sep" />
      <xsl:with-param name="value-property" select="$value-property" />
      <xsl:with-param name="filter" select="$filter" />
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
