<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:marc="http://www.loc.gov/MARC21/slim"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="">

  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

  <xsl:template match="marc:collection">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- sort ascending by tag-number -->
  <xsl:template match="marc:record">
    <xsl:copy>
      <xsl:copy-of select="marc:leader"/>
      <xsl:for-each select="marc:*[@tag!='']">
        <xsl:sort select="@tag" data-type="text"/>
        <xsl:apply-templates select='.'/>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>

  <!-- delete empty datafields and subfields and datafields with only empty subfields -->
  <xsl:template match="*[not(.[normalize-space()])]"/>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>

    <!-- über marc-marc Transformation abgeändert:
    - Felder ohne Tag und Subfields ohne Inhalt gelöscht, Datanfields mit nur leeren Subfields gelöscht
    - Felder aufsteigend nach tag-Nr. sortiert
    -->
