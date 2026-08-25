<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:local="http://www.w3.org/2005/xquery-local-functions"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:import href="xslImport:metadatabox:metadata/metadata-box/mods/classification.xsl" />
  <xsl:import href="resource:xslt/metadata/metadata-box/mods/shared/metadata-row.xsl" />
  <xsl:import href="resource:xslt/metadata/metadata-box/mods/shared/classification-link.xsl" />

  <xsl:template mode="display-metadata" match="mycoreobject">
    <xsl:apply-imports />

    <xsl:for-each select="metadata/def.modsContainer/modsContainer/mods:mods/mods:classification[not(@generator)]">
      <xsl:call-template name="meta-row">
        <xsl:with-param name="label-key" select="local:classification-label-key(.)" />
        <xsl:with-param name="value">
          <xsl:apply-templates mode="classification" select="." />
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:function name="local:classification-label-key" as="xs:string">
    <xsl:param name="classification" as="element(mods:classification)" />

    <xsl:variable name="display-label-key" select="
      'component.mods.metaData.dictionary.' || $classification/@displayLabel
    " />

    <xsl:choose>
      <xsl:when test="$classification/@authority = 'sdnb'">
        <xsl:sequence select="'component.mods.metaData.dictionary.sdnb'" />
      </xsl:when>
      <xsl:when test="$classification/@displayLabel = 'status'">
        <xsl:sequence select="'component.mods.metaData.dictionary.status'" />
      </xsl:when>
      <xsl:when test="mcri18n:exists($display-label-key)">
        <xsl:sequence select="$display-label-key" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="'component.mods.metaData.dictionary.classification'" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

</xsl:stylesheet>
