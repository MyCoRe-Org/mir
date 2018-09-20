<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:java="http://xml.apache.org/xalan/java"
  xmlns:srw="http://www.loc.gov/zing/srw/"
  xmlns:marc="http://www.loc.gov/MARC21/slim"
  exclude-result-prefixes="xsl xalan java">
  
  <xsl:template match="srw:searchRetrieveResponse">
    <xsl:apply-templates select="srw:records/srw:record[1]/srw:recordData/marc:record" />
  </xsl:template>
  
  <xsl:template match="marc:record">
    <mods:mods>
      <mods:genre type="intern">journal</mods:genre>
      <xsl:apply-templates select="marc:datafield[@tag='245']" />
      <xsl:apply-templates select="marc:datafield[@tag='210']" />
      <xsl:apply-templates select="marc:datafield[@tag='264']" />
      <xsl:apply-templates select="marc:datafield[@tag='022']" />
      <xsl:apply-templates select="marc:datafield[@tag='041']" />
    </mods:mods>
  </xsl:template>
  
  <xsl:template match="marc:datafield[@tag='245']">
    <mods:titleInfo>
      <mods:title>
        <xsl:value-of select="marc:subfield[@code='a']" />
      </mods:title>
    </mods:titleInfo>
  </xsl:template>
  
  <xsl:template match="marc:datafield[@tag='210']">
    <mods:titleInfo type="abbreviated">
      <mods:title>
        <xsl:value-of select="marc:subfield[@code='a']" />
      </mods:title>
    </mods:titleInfo>
  </xsl:template>

  <xsl:template match="marc:datafield[@tag='264']">
    <mods:originInfo>
      <xsl:apply-templates select="marc:subfield" />
    </mods:originInfo>
  </xsl:template>

  <xsl:template match="marc:datafield[@tag='264']/marc:subfield[@code='a']">
    <mods:place>
      <mods:placeTerm type="text">
        <xsl:value-of select="text()" />
      </mods:placeTerm>
    </mods:place>
  </xsl:template>

  <xsl:template match="marc:datafield[@tag='264']/marc:subfield[@code='b']">
    <mods:publisher>
      <xsl:value-of select="text()" />
    </mods:publisher>
  </xsl:template>

  <xsl:template match="marc:datafield[@tag='022']">
    <mods:identifier type="issn">
      <xsl:value-of select="marc:subfield[@code='a']" />
    </mods:identifier>
  </xsl:template>

  <xsl:template match="marc:datafield[@tag='041']">
    <mods:language>
      <mods:languageTerm type="code" authority="rfc4646">
        <xsl:variable name="given" select="translate(marc:subfield[@code='a'],'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')" />
        <xsl:value-of select="document('classification:metadata:-1:children:rfc4646')/mycoreclass/categories/category[@ID=$given or label[translate(@text,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')=$given]][1]/@ID" />
      </mods:languageTerm>
    </mods:language>
  </xsl:template>
  
  <xsl:template match="*" />

</xsl:stylesheet>