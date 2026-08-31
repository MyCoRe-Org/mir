<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:datacite="http://datacite.org/schema/kernel-4"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all"
  extension-element-prefixes="datacite">

  <xsl:import href="xslImport:metadatabox:metadata/metadata-box/mods/funding.xsl" />
  <xsl:import href="resource:xslt/metadata/metadata-box/mods/shared/metadata-row.xsl" />

  <xsl:template mode="display-metadata" match="mycoreobject">
    <xsl:apply-imports />

    <xsl:for-each select="
      metadata/def.modsContainer/modsContainer/mods:mods/mods:extension[@type='datacite-funding']
        /datacite:fundingReferences/datacite:fundingReference
    ">
      <xsl:call-template name="meta-row">
        <xsl:with-param name="label-key" select="'mir.project'" />
        <xsl:with-param name="value">
          <xsl:call-template name="funding-reference">
            <xsl:with-param name="reference" select="." />
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <!-- TODO validation award title and number -->
  <xsl:template name="funding-reference">
    <xsl:param name="reference" as="element(datacite:fundingReference)" />

    <xsl:value-of select="$reference/datacite:funderName" />
    <xsl:if test="$reference/datacite:awardTitle or $reference/datacite:awardNumber">
      <br />
      <xsl:if test="$reference/datacite:awardTitle">
        <i>
          <xsl:value-of select="$reference/datacite:awardTitle" />
        </i>
      </xsl:if>
      <xsl:if test="$reference/datacite:awardNumber">
        <xsl:text> [</xsl:text>
        <xsl:choose>
          <xsl:when test="$reference/datacite:awardNumber/@awardURI">
            <a target="_blank" href="{$reference/datacite:awardNumber/@awardURI}">
              <xsl:value-of select="$reference/datacite:awardNumber" />
            </a>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$reference/datacite:awardNumber" />
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>]</xsl:text>
      </xsl:if>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
