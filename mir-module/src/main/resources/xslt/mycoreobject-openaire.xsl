<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns="http://namespace.openaire.eu/schema/oaire/"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array"
  xmlns:datacite="http://datacite.org/schema/kernel-4"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:openaire_utils="http://www.mycore.de/xslt/openaire_utils"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  exclude-result-prefixes="mods openaire_utils xlink xs xsl array">

  <xsl:import href="resource:/xslt/mycoreobject-datacite-mir.xsl"/>
  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

  <xsl:param name="MIR.OpenAIRE.ResourceType.Literature.MODSTypes"/>
  <xsl:param name="MIR.OpenAIRE.ResourceType.Dataset.MODSTypes"/>
  <xsl:param name="MIR.OpenAIRE.ResourceType.Software.MODSTypes"/>

  <xsl:variable name="schemaLocation">http://namespace.openaire.eu/schema/oaire/ https://www.openaire.eu/schema/repo-lit/4.0/openaire.xsd</xsl:variable>

  <xsl:variable name="literatureModsTypes" select="array { tokenize($MIR.OpenAIRE.ResourceType.Literature.MODSTypes, ',') }"/>
  <xsl:variable name="datasetModsTypes" select="array { tokenize($MIR.OpenAIRE.ResourceType.Dataset.MODSTypes, ',') }"/>
  <xsl:variable name="softwareModsTypes" select="array { tokenize($MIR.OpenAIRE.ResourceType.Software.MODSTypes, ',') }"/>

  <xsl:template match="/">
    <xsl:apply-templates select="mycoreobject"/>
  </xsl:template>

  <xsl:template match="mycoreobject">
    <xsl:apply-templates select="metadata/def.modsContainer/modsContainer/mods:mods"/>
  </xsl:template>

  <xsl:template match="mods:mods">
    <resource xsi:schemaLocation="{$schemaLocation}">
      <xsl:variable name="datacitePart">
        <xsl:call-template name="creators"/>
        <xsl:call-template name="contributors"/>
        <xsl:call-template name="alternateIdentifiers"/>
        <xsl:call-template name="relatedIdentifiers"/>
        <xsl:call-template name="dates"/>
        <xsl:call-template name="titles"/>
        <xsl:call-template name="identifier"/>
        <xsl:call-template name="rights"/>
        <xsl:call-template name="subjects"/>
        <!-- datacite:geoLocations -->
        <!-- datacite:sizes -->
      </xsl:variable>
      <xsl:apply-templates select="$datacitePart" mode="add-datacite-namespace"/>
      <xsl:call-template name="fundingReferences"/>
      <xsl:call-template name="resourceType"/>
      <xsl:call-template name="dc-language"/>
      <xsl:call-template name="dc-description"/>
      <xsl:call-template name="dc-publisher"/>

      <!-- Mandatory if applicable -->
      <!-- file -->

      <!-- Optional or Recommended fields -->
      <!-- dc:coverage -->
      <!-- dc:format -->
      <!-- dc:source -->
      <!-- citationTitle -->
      <!-- citationVolumne -->
      <!-- citationIssue -->
      <!-- citationStartPage -->
      <!-- citationEndPage -->
      <!-- citationEdition -->
      <!-- citationConferencePlace -->
      <!-- citationConferenceDate -->
      <!-- version -->
      <!-- licenseCondition -->
      <!-- dcterms:audience -->
    </resource>
  </xsl:template>

  <xsl:function name="openaire_utils:getResourceTypeGeneral" as="xs:string">
    <xsl:param name="modsType" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="some $item in array:flatten($literatureModsTypes) satisfies $item = $modsType">
        <xsl:text>literature</xsl:text>
      </xsl:when>
      <xsl:when test="some $item in array:flatten($softwareModsTypes) satisfies $item = $modsType">
        <xsl:text>software</xsl:text>
      </xsl:when>
      <xsl:when test="some $item in array:flatten($datasetModsTypes) satisfies $item = $modsType">
        <xsl:text>dataset</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>other research product</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="openaire_utils:getCoarResourceTypeId" as="xs:string">
    <xsl:param name="modsType" as="xs:string"/>
    <xsl:variable name="classificationUri" select="concat('classification:metadata:0:children:mir_genres:', $mods-type)"/>
    <xsl:analyze-string select="document($classificationUri)//category/label[@xml:lang='x-mapping']/@text" regex="coarResourceTypes32:([^ ]+)">
      <xsl:matching-substring>
        <xsl:value-of select="regex-group(1)"/>
      </xsl:matching-substring>
    </xsl:analyze-string>
  </xsl:function>

  <xsl:function name="openaire_utils:getCoarResourceTypeName" as="xs:string">
    <xsl:param name="coarResourceTypeId" as="xs:string"/>
    <xsl:variable name="classificationUri" select="concat('classification:metadata:0:children:coarResourceTypes32:', $coarResourceTypeId)"/>
    <xsl:value-of select="document($classificationUri)//category/label[@xml:lang='en']/@text"/>
  </xsl:function>

  <xsl:template name="resourceType">
    <resourceType resourceTypeGeneral="{openaire_utils:getResourceTypeGeneral($mods-type)}">
      <xsl:variable name="coarResourceTypeId" select="openaire_utils:getCoarResourceTypeId($mods-type)"/>
      <xsl:attribute name="uri" select="concat('http://purl.org/coar/resource_type/', $coarResourceTypeId)"/>
      <xsl:value-of select="openaire_utils:getCoarResourceTypeName($coarResourceTypeId)"/>
    </resourceType>
  </xsl:template>

  <xsl:template name="dc-language">
    <xsl:if test="mods:language/mods:languageTerm">
      <!-- guidlines specify 0-n occurrences, but the schema specifies 0-1 occurrences -->
      <dc:language>
        <xsl:variable name="classificationUri" select="concat('classification:metadata:0:children:rfc5646:', mods:language[1]/mods:languageTerm[1])"/>
        <xsl:value-of select="document($classificationUri)//category/label[@xml:lang='x-term']/@text"/>
      </dc:language>
    </xsl:if>
  </xsl:template>

  <xsl:template name="dc-publisher">
    <xsl:for-each select="mods:originInfo/mods:publisher">
      <dc:publisher>
        <xsl:value-of select="text()"/>
      </dc:publisher>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="dc-description">
    <xsl:for-each select="mods:abstract[not(@altFormat)]">
      <dc:description>
        <xsl:if test="@xml:lang">
          <xsl:attribute name="xml:lang" select="@xml:lang"/>
        </xsl:if>
        <xsl:value-of select="text()"/>
      </dc:description>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="*" mode="add-datacite-namespace">
    <xsl:element name="datacite:{local-name()}">
      <xsl:apply-templates select="@* | node()" mode="add-datacite-namespace"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="@*" mode="add-datacite-namespace">
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="text() | comment() | processing-instruction()" mode="add-datacite-namespace">
    <xsl:copy/>
  </xsl:template>

  <!-- Override to strip datacite elements to openaire namespace-->
  <xsl:template match="*" mode="strip-to-default-ns">
    <xsl:element name="{local-name()}">
      <xsl:apply-templates select="@* | node()" mode="strip-to-default-ns"/>
    </xsl:element>
  </xsl:template>

</xsl:stylesheet>
