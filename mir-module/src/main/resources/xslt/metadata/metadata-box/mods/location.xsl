<?xml version="1.0" encoding="UTF-8"?>
<!-- READY -->
<xsl:stylesheet version="3.0"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:import href="xslImport:metadatabox:metadata/metadata-box/mods/location.xsl" />
  <xsl:import href="resource:xslt/metadata/metadata-box/mods/shared/metadata-row.xsl" />
  <xsl:import href="resource:xslt/metadata/metadata-box/mods/shared/gnd.xsl" />

  <xsl:template mode="display-metadata" match="mycoreobject">
    <xsl:apply-imports />

    <xsl:variable name="location" select="metadata/def.modsContainer/modsContainer/mods:mods/mods:location" />

    <xsl:for-each select="$location/mods:url">
      <xsl:call-template name="meta-row">
        <xsl:with-param name="label-key" select="
          if (@access) then concat('component.mods.metaData.dictionary.url.', replace(@access, ' ', '_'))
          else 'component.mods.metaData.dictionary.url'
        " />
        <xsl:with-param name="value">
          <xsl:call-template name="location-url">
            <xsl:with-param name="url" select="." />
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>

    <xsl:call-template name="meta-row-from-nodes">
      <xsl:with-param name="label-key" select="'component.mods.metaData.dictionary.physicalLocation'" />
      <xsl:with-param name="nodes" select="$location/mods:physicalLocation[not(starts-with(@xlink:href, '#'))]" />
    </xsl:call-template>

    <xsl:call-template name="meta-row-from-nodes">
      <xsl:with-param name="label-key" select="'mir.shelfmark'" />
      <xsl:with-param name="nodes" select="$location/mods:shelfLocator" />
    </xsl:call-template>

  </xsl:template>

  <xsl:template name="location-url">
    <xsl:param name="url" as="element(mods:url)" />

    <a href="{$url}">
      <xsl:choose>
        <xsl:when test="string-length(@displayLabel) &gt; 0">
          <xsl:value-of select="@displayLabel" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="." />
        </xsl:otherwise>
      </xsl:choose>
    </a>
  </xsl:template>

</xsl:stylesheet>
