<?xml version="1.0" encoding="UTF-8"?>

<!--http://api.crossref.org/works/10.1038/ncomms11620/transform/application/rdf+xml -->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:dc="http://purl.org/dc/terms/"
  xmlns:foaf="http://xmlns.com/foaf/0.1/"
  xmlns:owl="http://www.w3.org/2002/07/owl#"
  xmlns:bibo="http://purl.org/ontology/bibo/"
  exclude-result-prefixes="xsl xsi xalan rdf dc foaf owl bibo">

  <xsl:output method="xml" encoding="UTF-8" indent="yes" xalan:indent-amount="2" />

  <xsl:template match="/rdf:RDF">
    <xsl:apply-templates select="rdf:Description" />
  </xsl:template>

  <xsl:template match="rdf:Description">
    <mods:mods>
      <xsl:apply-templates select="dc:title" />
      <xsl:apply-templates select="dc:creator" />
      <xsl:apply-templates select="dc:isPartOf/bibo:Journal" />
      <xsl:apply-templates select="dc:date[starts-with(@rdf:datatype,'http://www.w3.org/2001/XMLSchema')]" />
      <xsl:apply-templates select="bibo:doi" />
    </mods:mods>
  </xsl:template>

  <xsl:template match="dc:title">
    <mods:titleInfo>
      <mods:title>
        <xsl:value-of select="text()" />
      </mods:title>
    </mods:titleInfo>
  </xsl:template>

  <xsl:template match="dc:creator">
    <xsl:apply-templates select="foaf:Person" />
  </xsl:template>

  <xsl:template match="dc:creator/foaf:Person">
    <mods:name type="personal">
      <xsl:apply-templates select="foaf:familyName" />
      <xsl:apply-templates select="foaf:givenName" />
      <xsl:apply-templates select="owl:sameAs/@rdf:resource[contains(.,'orcid.org')]" />
      <mods:role>
        <mods:roleTerm type="code" authority="marcrelator">aut</mods:roleTerm>
      </mods:role>
    </mods:name>
  </xsl:template>

  <xsl:template match="foaf:familyName">
    <mods:namePart type="family">
      <xsl:value-of select="text()" />
    </mods:namePart>
  </xsl:template>

  <xsl:template match="foaf:givenName">
    <mods:namePart type="given">
      <xsl:value-of select="text()" />
    </mods:namePart>
  </xsl:template>

  <xsl:template match="owl:sameAs/@rdf:resource[contains(.,'orcid.org')]">
    <mods:nameIdentifier type="orcid">
      <xsl:value-of select="substring-after(.,'orcid.org/')" />
    </mods:nameIdentifier>
  </xsl:template>

  <xsl:template match="dc:isPartOf/bibo:Journal">
    <mods:relatedItem type="host">
      <mods:genre>journal</mods:genre>
      <xsl:apply-templates select="dc:title" />
      <xsl:apply-templates select="bibo:issn" />
      <xsl:apply-templates select="../.." mode="part" />
    </mods:relatedItem>
  </xsl:template>

  <xsl:template match="rdf:Description" mode="part">
    <mods:part>
      <xsl:apply-templates select="bibo:volume" />
      <mods:extent unit="pages">
        <xsl:apply-templates select="bibo:pageStart" />
        <xsl:apply-templates select="bibo:pageEnd" />
      </mods:extent>
    </mods:part>
  </xsl:template>

  <xsl:template match="bibo:doi">
    <mods:identifier type="doi">
      <xsl:value-of select="text()" />
    </mods:identifier>
  </xsl:template>

  <xsl:template match="bibo:issn">
    <mods:identifier type="issn">
      <xsl:value-of select="text()" />
    </mods:identifier>
  </xsl:template>

  <xsl:template match="bibo:volume">
    <mods:detail type="volume">
      <mods:number>
        <xsl:value-of select="text()" />
      </mods:number>
    </mods:detail>
  </xsl:template>

  <xsl:template match="bibo:pageStart">
    <mods:start>
      <xsl:value-of select="text()" />
    </mods:start>
  </xsl:template>

  <xsl:template match="bibo:pageEnd">
    <mods:end>
      <xsl:value-of select="text()" />
    </mods:end>
  </xsl:template>

  <xsl:template match="dc:date[starts-with(@rdf:datatype,'http://www.w3.org/2001/XMLSchema')]">
    <mods:originInfo eventType="publication">
      <mods:dateIssued encoding="w3cdtf">
        <xsl:value-of select="substring(text(),1,4)" />
      </mods:dateIssued>
    </mods:originInfo>
  </xsl:template>

</xsl:stylesheet>