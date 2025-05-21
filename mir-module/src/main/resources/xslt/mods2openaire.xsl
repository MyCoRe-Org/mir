<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="mods xlink xs">

  <xsl:include href="mycoreobject-datacite-mir.xsl" />

  <xsl:output method="xml" indent="yes" encoding="UTF-8" />

  <xsl:variable name="schemaLocation">http://datacite.org/schema/kernel-4 http://schema.datacite.org/meta/kernel-4.3/metadata.xsd</xsl:variable>

  <xsl:template match="mycoreobject">
    <xsl:apply-templates select="metadata/def.modsContainer/modsContainer/mods:mods" />
  </xsl:template>

  <xsl:template match="mods:mods">
    <resource xsi:schemaLocation="{$schemaLocation}">
      <xsl:call-template name="creators" />
      <!-- funding references -->
      <xsl:call-template name="alternateIdentifiers" />
      <xsl:call-template name="relatedIdentifiers" />
      <xsl:call-template name="titles" />
      <xsl:call-template name="dates" />
      <!-- dc description -->
      <!-- resource type -->
      <xsl:call-template name="identifier" />
      <xsl:call-template name="rights" />
      <!-- license condition -->
      <xsl:call-template name="subjects" />
      <!-- file -->
      <!-- citationTitle -->
      <!-- citationVolumne -->
      <!-- citationIssue -->
      <!-- citationStartPage -->
      <!-- citationEndPage -->
    </resource>
  </xsl:template>

<xsl:stylesheet>
