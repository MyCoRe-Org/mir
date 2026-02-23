<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:mcrpages="xalan://org.mycore.mods.MCRMODSPagesHelper"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="mcrpages xalan xsl">

  <xsl:include href="copynodes.xsl" />

  <xsl:template match="@xsi:schemaLocation" />
  <xsl:template match="mods:mods/@version" />
  <xsl:template match="mods:titleInfo[@nameTitleGroup]" />
  <xsl:template match="mods:name[@nameTitleGroup]" />
  <xsl:template match="mods:name/@authorityURI" />
  <xsl:template match="mods:name/@authority" />
  <xsl:template match="mods:name/@usage" />
  <xsl:template match="mods:role[mods:roleTerm/@type='text']" />
  <xsl:template match="mods:typeOfResource" />
  <xsl:template match="mods:place[mods:placeTerm[@type='code']]" />
  <xsl:template match="mods:physicalDescription" />
  <xsl:template match="mods:relatedItem/@displayLabel" />
  <xsl:template match="mods:identifier[@type='local']" />
  <xsl:template match="mods:part[mods:text]" />
  <xsl:template match="mods:location" />
  <xsl:template match="mods:recordInfo" />
  <xsl:template match="mods:language[@objectPart]" />
  <xsl:template match="mods:classification" />
  <xsl:template match="mods:note/@language" />
  <xsl:template match="mods:subject/@authority" />

  <xsl:template match="mods:name/@valueURI">
    <xsl:if test="contains(.,'/gnd/')">
      <mods:nameIdentifier type="gnd">
        <xsl:value-of select="substring-after(.,'/gnd/')" />
      </mods:nameIdentifier>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="mods:identifier[@type='issn'][string-length(.)=8]">
    <mods:identifier type="issn">
      <xsl:value-of select="substring(.,1,4)" />
      <xsl:text>-</xsl:text>
      <xsl:value-of select="substring(.,5)" />
    </mods:identifier>
  </xsl:template>

  <xsl:template match="mods:dateIssued">
    <xsl:if test="translate(text(),'0123456789','YYYYYYYYYY')='YYYY'">
      <mods:dateIssued encoding="w3cdtf">
        <xsl:value-of select="text()" />
      </mods:dateIssued>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mods:languageTerm">
    <!-- Find language with matching label in any language, or with matching ID in any supported code schema -->
    <xsl:variable name="given" select="translate(text(),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')" />
    <xsl:for-each select="document('classification:metadata:-1:children:rfc5646')/mycoreclass/categories/category[@ID=$given or label[translate(@text,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')=$given]][1]">
      <mods:languageTerm authority="rfc5646" type="code">
        <xsl:value-of select="@ID" />
      </mods:languageTerm>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="mods:detail">
    <xsl:choose>
      <xsl:when test="string-length(mods:number) = 0" />
      <xsl:when test="@level &gt; 2" />
      <xsl:otherwise>
        <mods:detail>
          <xsl:attribute name="type">
            <xsl:if test="@level='1'">volume</xsl:if>
            <xsl:if test="@level='2'">issue</xsl:if>
          </xsl:attribute>
          <xsl:apply-templates select="*" />
        </mods:detail>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="mods:extent[@unit='page']">
    <xsl:copy-of select="mcrpages:buildExtentPagesNodeSet(string(mods:start/text()))" />
  </xsl:template>

</xsl:stylesheet>
