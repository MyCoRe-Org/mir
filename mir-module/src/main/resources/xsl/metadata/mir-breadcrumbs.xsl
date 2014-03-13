<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mcrxml="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:mods="http://www.loc.gov/mods/v3" exclude-result-prefixes="mcrxml mods">
  <xsl:import href="xslImport:modsmeta:metadata/mir-breadcrumbs.xsl" />
  <xsl:template match="/">
    <xsl:variable name="mods" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods" />
    <div id="mir-breadcrumb">
      <ul class="breadcrumb" itemprop="breadcrumb">
        <li>
          <a href="{$WebApplicationBaseURL}" class="navtrail">Home</a>
        </li>
        <li>
          <xsl:variable name="collectionType">
            <xsl:apply-templates mode="mods.type" select="$mods" />
          </xsl:variable>
          <a href="{$WebApplicationBaseURL}collection/{$collectionType}" class="navtrail">Publications</a>
        </li>
        <li class="active">
          <xsl:variable name="completeTitle">
            <xsl:apply-templates select="$mods" mode="mods.title" />
          </xsl:variable>
          <xsl:value-of select="mcrxml:shortenText($completeTitle,70)" />
        </li>
      </ul>
    </div>
    <xsl:apply-imports />
  </xsl:template>
</xsl:stylesheet>