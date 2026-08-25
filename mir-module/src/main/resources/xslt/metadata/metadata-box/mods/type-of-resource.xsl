<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:local="http://www.w3.org/2005/xquery-local-functions"
  xmlns:mcrclass="http://www.mycore.de/xslt/classification"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:import href="xslImport:metadatabox:metadata/metadata-box/mods/type-of-resource.xsl" />
  <xsl:import href="resource:xslt/metadata/metadata-box/mods/shared/metadata-row.xsl" />

  <xsl:template mode="display-metadata" match="mycoreobject">
    <xsl:apply-imports />

    <xsl:call-template name="mods-meta-row">
      <xsl:with-param name="nodes" select="metadata/def.modsContainer/modsContainer/mods:mods/mods:typeOfResource" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:typeOfResource" mode="value-content">
    <xsl:value-of select="local:type-of-resource-display(.)" />
  </xsl:template>

  <xsl:function name="local:type-of-resource-display" as="xs:string?">
    <xsl:param name="raw-value" as="xs:string" />

    <xsl:variable name="sanitized" select="translate($raw-value, ' ', '_')" />
    <xsl:variable name="category" select="mcrclass:category('typeOfResource', $sanitized)" />
    <xsl:sequence select="mcrclass:current-label-text($category)" />
  </xsl:function>

</xsl:stylesheet>
