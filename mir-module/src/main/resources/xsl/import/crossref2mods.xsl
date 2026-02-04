<?xml version="1.0" encoding="UTF-8"?>

<!--xslStyle:import/simplify-json-xml:xslTransform:json2xml:https://api.crossref.org/works/10.1038/ncomms11620 -->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:xalan="http://xml.apache.org/xalan"
  exclude-result-prefixes="xsl xsi xalan">

  <xsl:output method="xml" encoding="UTF-8" indent="yes" xalan:indent-amount="2" />

  <xsl:template match="/entry">
    <xsl:apply-templates select="message" />
  </xsl:template>

  <xsl:template match="message">
    <mods:mods>
      <xsl:apply-templates select="title" />
      <xsl:apply-templates select="short-title" />
      <xsl:apply-templates select="author|editor" />
      <xsl:apply-templates select="type" />
      <xsl:apply-templates select="container-title" mode="container" />
      <xsl:call-template name="originInfo" />
      <xsl:apply-templates select="DOI" />
      <xsl:apply-templates select="isbn-type[../type='book']/entry/value" />
    </mods:mods>
  </xsl:template>

  <xsl:template match="title|container-title">
    <mods:titleInfo>
      <mods:title>
        <xsl:value-of select="text()" />
      </mods:title>
    </mods:titleInfo>
  </xsl:template>

  <xsl:template match="short-title|short-container-title">
    <mods:titleInfo type="abbreviated">
      <mods:title>
        <xsl:value-of select="text()" />
      </mods:title>
    </mods:titleInfo>
  </xsl:template>

  <xsl:template match="author|editor">
    <xsl:apply-templates select="entry" />
  </xsl:template>

  <xsl:template match="author/entry|editor/entry">
    <mods:name type="personal">
      <xsl:apply-templates select="family" />
      <xsl:apply-templates select="given" />
      <xsl:apply-templates select="ORCID" />
      <mods:role>
        <xsl:apply-templates select=".." mode="role" />
      </mods:role>
    </mods:name>
  </xsl:template>

  <xsl:template match="author" mode="role">
    <mods:roleTerm type="code" authority="marcrelator">aut</mods:roleTerm>
  </xsl:template>

  <xsl:template match="editor" mode="role">
    <mods:roleTerm type="code" authority="marcrelator">edt</mods:roleTerm>
  </xsl:template>

  <xsl:template match="family">
    <mods:namePart type="family">
      <xsl:value-of select="text()" />
    </mods:namePart>
  </xsl:template>

  <xsl:template match="given">
    <mods:namePart type="given">
      <xsl:value-of select="text()" />
    </mods:namePart>
  </xsl:template>

  <xsl:template match="ORCID">
    <mods:nameIdentifier type="orcid">
      <xsl:value-of select="substring-after(.,'orcid.org/')" />
    </mods:nameIdentifier>
  </xsl:template>

  <xsl:template match="type">
    <mods:genre>
      <xsl:value-of select="text()" />
    </mods:genre>
  </xsl:template>

  <xsl:template match="container-title" mode="container">
    <mods:relatedItem type="host">
      <xsl:apply-templates select="." />
      <xsl:apply-templates select="../short-container-title" />
      <xsl:apply-templates select="../issn-type/entry/value" />
      <xsl:apply-templates select="../isbn-type[../type[contains(.,'book-')]]/entry/value" />
      <xsl:apply-templates select=".." mode="part" />
    </mods:relatedItem>
  </xsl:template>

  <xsl:template match="message" mode="part">
    <mods:part>
      <xsl:apply-templates select="volume" />
      <xsl:apply-templates select="journal-issue/issue" />
      <xsl:apply-templates select="page" />
    </mods:part>
  </xsl:template>

  <xsl:template match="DOI">
    <mods:identifier type="doi">
      <xsl:value-of select="text()" />
    </mods:identifier>
  </xsl:template>

  <xsl:template match="issn-type/entry/value">
    <mods:identifier type="issn">
      <xsl:value-of select="text()" />
    </mods:identifier>
  </xsl:template>

  <xsl:template match="isbn-type/entry/value">
    <mods:identifier type="isbn">
      <xsl:value-of select="text()" />
    </mods:identifier>
  </xsl:template>

  <xsl:template match="volume">
    <mods:detail type="volume">
      <mods:number>
        <xsl:value-of select="text()" />
      </mods:number>
    </mods:detail>
  </xsl:template>

  <xsl:template match="issue">
    <mods:detail type="issue">
      <mods:number>
        <xsl:value-of select="text()" />
      </mods:number>
    </mods:detail>
  </xsl:template>

  <xsl:template match="page">
    <xsl:copy-of xmlns:pages="xalan://org.mycore.mods.MCRMODSPagesHelper" select="pages:buildExtentPagesNodeSet(text())" />
  </xsl:template>

  <xsl:template name="originInfo">
    <mods:originInfo eventType="publication">
      <xsl:apply-templates select="issued" />
      <xsl:apply-templates select="publisher" />
    </mods:originInfo>
  </xsl:template>

  <xsl:template match="issued">
    <mods:dateIssued encoding="w3cdtf">
      <xsl:value-of select="substring(date-parts,1,4)" />
    </mods:dateIssued>
  </xsl:template>

  <xsl:template match="publisher">
    <mods:publisher>
      <xsl:value-of select="text()" />
    </mods:publisher>
  </xsl:template>

</xsl:stylesheet>
