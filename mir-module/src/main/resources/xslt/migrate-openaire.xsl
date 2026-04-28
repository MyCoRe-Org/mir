<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="xml" indent="yes" encoding="UTF-8" omit-xml-declaration="no" />

  <xsl:mode on-no-match="shallow-copy" />

  <xsl:template match="mods:mods/mods:identifier[@type='open-aire']">
    <xsl:variable name="split" select="tokenize(text(), '/')" />
    <xsl:choose>
      <xsl:when test="$split[3] != 'EC'">
        <xsl:message terminate="yes">ERROR: Only EC as funder is allowed. Migration failed!</xsl:message>
        <xsl:variable name="force-error" select="1 div 0" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="create-ec-funding">
          <xsl:with-param name="awardNumber" select="$split[5]" />
          <xsl:with-param name="awardTitle" select="$split[7]" />
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="create-ec-funding">
    <xsl:param name="awardNumber" />
    <xsl:param name="awardTitle" />
    <mods:extension type="datacite-funding">
      <datacite:fundingReferences
        xmlns:datacite="http://datacite.org/schema/kernel-4"
        xsi:schemaLocation="http://datacite.org/schema/kernel-4 http://schema.datacite.org/meta/kernel-4.3/metadata.xsd">
        <datacite:fundingReference>
          <datacite:funderName>European Commission</datacite:funderName>
          <datacite:funderIdentifier funderIdentifierType="Crossref Funder ID">https://doi.org/10.13039/501100000780</datacite:funderIdentifier>
          <datacite:awardNumber awardURI="{concat('https://cordis.europa.eu/project/id/', $awardNumber)}">
            <xsl:value-of select="$awardNumber" />
          </datacite:awardNumber>
          <datacite:awardTitle>
            <xsl:value-of select="$awardTitle" />
          </datacite:awardTitle>
        </datacite:fundingReference>
      </datacite:fundingReferences>
    </mods:extension>
  </xsl:template>
  
</xsl:stylesheet>
