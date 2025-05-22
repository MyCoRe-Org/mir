<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns="http://namespace.openaire.eu/schema/oaire/"
  xmlns:datacite="http://datacite.org/schema/kernel-4"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  exclude-result-prefixes="mods xlink">

  <xsl:import href="mycoreobject-datacite-mir.xsl" />

  <xsl:output method="xml" indent="yes" encoding="UTF-8" />

  <xsl:variable name="schemaLocation">http://namespace.openaire.eu/schema/oaire/ https://www.openaire.eu/schema/repo-lit/4.0/openaire.xsd</xsl:variable>

  <xsl:template match="mycoreobject">
    <xsl:apply-templates select="metadata/def.modsContainer/modsContainer/mods:mods" />
  </xsl:template>

  <xsl:template match="mods:mods">
    <resource xsi:schemaLocation="{$schemaLocation}">
      <!-- dc:coverage -->
      <xsl:call-template name="creators" />
      <xsl:call-template name="contributors" />
      <xsl:call-template name="fundingReferences" />
      <xsl:call-template name="alternateIdentifiers" />
      <xsl:call-template name="relatedIdentifiers" />
      <xsl:call-template name="dates" />
      <xsl:call-template name="datacite:titles" />
      <!-- dc:language -->
      <!-- dc:publisher -->
      <xsl:call-template name="resourceType" />
      <!-- dc:description -->
      <!-- dc:format-->
      <xsl:call-template name="identifier" />
      <xsl:call-template name="rights" />
      <!-- dc:source -->
      <xsl:call-template name="subjects" />
      <!-- datacite:geoLocations -->
      <!-- datacite:sizes -->
      <!-- citationTitle Recommended -->
      <!-- citationVolumne Recommended -->
      <!-- citationIssue Recommended -->
      <!-- citationStartPage Recommended -->
      <!-- citationEndPage Recommended -->
      <!-- citationEdition Recommended -->
      <!-- citationConferencePlace Recommended -->
      <!-- citationConferenceDate Recommended -->
      <!-- TODO Recommended <xsl:call-template name="version" /> -->
      <!-- TODO Mandatory if applicable <xsl:call-template name="file" /> -->
      <!-- TODO Recommended <xsl:call-template name="licenseCondition" /> -->
      <!-- dcterms:audience -->
    </resource>
  </xsl:template>

  <xsl:template name="fundingReferences">
    <xsl:if test="mods:extension[@type='datacite-funding']">
      <fundingReferences>
        <xsl:apply-templates select="mods:extension[@type='datacite-funding']/resource/fundingReferences/fundingReference" />
      </fundingReferences>
    </xsl:if>
  </xsl:template>

  <xsl:template match="fundingReference">
    <fundingReference>
      <xsl:apply-templates select="*"/>
    </fundingReference>
  </xsl:template>

  <xsl:template match="funderName | funderIdentifier | awardNumber | awardTitle">
    <xsl:element name="{name()}">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="node()"/>
    </xsl:element>
  </xsl:template>

  <!-- TODO include COAR class -->
  <xsl:template name="resourceType">
    <xsl:variable name="resourceTypeGeneral">
      <xsl:choose>
        <xsl:when test="$mods-type='article'">
          <xsl:value-of select="'literature'" />
        </xsl:when>
        <xsl:when test="$mods-type='research_data'">
          <xsl:value-of select="'dataset'" />
        </xsl:when>
        <xsl:when test="$mods-type='software'">
          <xsl:value-of select="'software'" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'other research product'" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <resourceType resourceTypeGeneral="{$resourceTypeGeneral}" />
  </xsl:template>

  <!--
  <xsl:template name="version">
  </xsl:template>
  -->

  <!--
  <xsl:template name="file">
  </xsl:template>
  -->

  <!--
  <xsl:template name="licenseCondition">
  </xsl:template>
  -->
</xsl:stylesheet>
