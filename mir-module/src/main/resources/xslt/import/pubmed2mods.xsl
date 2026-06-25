<?xml version="1.0" encoding="UTF-8"?>

<!-- Converts PubMed core format to MODS -->
<!-- http://www.ebi.ac.uk/europepmc/webservices/rest/search/resulttype=core&query=ext_id:26063869 -->

<xsl:stylesheet version="1.0"
  xmlns:mcrpages="xalan://org.mycore.mods.MCRMODSPagesHelper"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="mcrpages mods xalan xsl">

  <xsl:output method="xml" encoding="UTF-8" indent="yes" xalan:indent-amount="2" />

  <xsl:template match="/responseWrapper">
    <mods:mods>
      <xsl:apply-templates />
    </mods:mods>
  </xsl:template>
  
  <xsl:template match="resultList[result]">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="resultList">
    <xsl:message>Warning: no data returned for <xsl:value-of select="../request/query" /></xsl:message>
    <mods:genre>ignore</mods:genre>
  </xsl:template>
  
  <xsl:template match="version|hitCount|request|result/id|result/source|result/authorString" />
  
  <xsl:template match="resultList/result">
    <xsl:apply-templates />
    <xsl:apply-templates select="journalInfo/yearOfPublication" mode="dateIssued" />
  </xsl:template>
  
  <xsl:template match="result/pmid">
    <mods:identifier type="pubmed"><xsl:value-of select="." /></mods:identifier>
  </xsl:template>

  <xsl:template match="result/doi">
    <mods:identifier type="doi"><xsl:value-of select="." /></mods:identifier>
  </xsl:template>

  <xsl:template match="result/title">
    <mods:titleInfo>
      <mods:title>
        <xsl:value-of select="." />
      </mods:title>
    </mods:titleInfo>
  </xsl:template>

  <xsl:template match="authorList">
    <xsl:apply-templates select="author[lastName|collectiveName]" />
  </xsl:template>

  <xsl:template match="author[lastName|collectiveName]">
    <mods:name type="personal">
      <xsl:apply-templates />
      <mods:role>
        <mods:roleTerm type="code" authority="marcrelator">aut</mods:roleTerm>
      </mods:role>
    </mods:name>
  </xsl:template>

  <xsl:template match="author/fullName|author/initials" />

  <xsl:template match="author/firstName">
    <mods:namePart type="given">
      <xsl:value-of select="." />
    </mods:namePart>
  </xsl:template>

  <xsl:template match="author/lastName|author/collectiveName">
    <mods:namePart type="family">
      <xsl:value-of select="." />
    </mods:namePart>
  </xsl:template>

  <xsl:template match="author/affiliation">
    <mods:affiliation>
      <xsl:value-of select="." />
    </mods:affiliation>
  </xsl:template>

  <xsl:template match="author/authorId[@type='ORCID']">
    <mods:nameIdentifier type="orcid">
      <xsl:value-of select="." />
    </mods:nameIdentifier>
  </xsl:template>

  <xsl:template match="authorIdList" />

  <xsl:template match="journalInfo">
    <mods:relatedItem type="host">
      <mods:genre>journal</mods:genre>
      <xsl:apply-templates />
      <mods:part>
        <xsl:apply-templates select="volume|issue|../pageInfo" mode="part" />
      </mods:part>
    </mods:relatedItem>
  </xsl:template>

  <xsl:template match="journalIssueId" />

  <xsl:template match="journalInfo/journal">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="journal/title">
    <mods:titleInfo>
      <mods:title>
        <xsl:value-of select="." />
      </mods:title>
    </mods:titleInfo>
  </xsl:template>

  <xsl:template match="journal/ISOAbbreviation">
    <mods:titleInfo type="abbreviated">
      <mods:title>
        <xsl:value-of select="." />
      </mods:title>
    </mods:titleInfo>
  </xsl:template>

  <xsl:template match="journal/medlineAbbreviation">
    <xsl:if test="not(../ISOAbbreviation)">
      <mods:titleInfo type="abbreviated">
        <mods:title>
          <xsl:value-of select="." />
        </mods:title>
      </mods:titleInfo>
    </xsl:if>
  </xsl:template>

  <xsl:template match="journal/ISSN|journal/ESSN">
    <mods:identifier type="issn">
      <xsl:value-of select="." />
    </mods:identifier>
  </xsl:template>

  <xsl:template match="journalInfo/issue|journalInfo/volume|result/pageInfo" />

  <xsl:template match="journalInfo/issue|journalInfo/volume" mode="part">
    <mods:detail type="{name()}">
      <mods:number>
        <xsl:value-of select="." />
      </mods:number>
    </mods:detail>
  </xsl:template>

  <xsl:template match="result/pageInfo" mode="part">
    <xsl:copy-of select="mcrpages:buildExtentPagesNodeSet(text())" />
  </xsl:template>

  <xsl:template match="abstractText">
    <mods:abstract>
      <xsl:copy-of select="text()" />
    </mods:abstract>
  </xsl:template>

  <xsl:template match="result/affiliation" />

  <!-- xsl:variable name="authorityOA">https://bibliographie.ub.uni-due.de/classifications/oa</xsl:variable>

  <xsl:template match="result/isOpenAccess">
    <xsl:if test=".='Y'">
      <mods:classification authorityURI="{$authorityOA}" valueURI="{$authorityOA}#oa" />
    </xsl:if>
  </xsl:template -->
  <xsl:template match="language">
    <xsl:apply-templates select="document(concat('language:',.))/language/@xmlCode" />
  </xsl:template>

  <xsl:template match="language/@xmlCode">
    <mods:language>
      <mods:languageTerm authority="rfc5646" type="code">
        <xsl:value-of select="." />
      </mods:languageTerm>
    </mods:language>
  </xsl:template>

  <xsl:template match="pubTypeList">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="pubType">
    <mods:genre>
      <xsl:value-of select="." />
    </mods:genre>
  </xsl:template>

  <xsl:template match="subsetList|chemicalList" />

  <xsl:template match="keywordList">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="keywordList/keyword">
    <mods:subject>
      <mods:topic>
        <xsl:value-of select="." />
      </mods:topic>
    </mods:subject>
  </xsl:template>

  <xsl:template match="meshHeadingList">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="meshHeading">
    <mods:subject authority="mesh">
      <mods:topic>
        <xsl:value-of select="descriptorName" />
      </mods:topic>
    </mods:subject>
  </xsl:template>

  <xsl:template match="fullTextUrlList">
    <xsl:apply-templates select="fullTextUrl/url[not(contains(text(),'doi.org'))]" />
  </xsl:template>

  <xsl:template match="fullTextUrl/url">
    <mods:location>
      <mods:url>
        <xsl:value-of select="." />
      </mods:url>
    </mods:location>
  </xsl:template>

  <xsl:template match="journalInfo/yearOfPublication" />

  <xsl:template match="journalInfo/yearOfPublication" mode="dateIssued">
    <mods:originInfo eventType="publication">
      <mods:dateIssued encoding="w3cdtf">
        <xsl:value-of select="." />
      </mods:dateIssued>
    </mods:originInfo>
  </xsl:template>

  <xsl:template match="inEPMC|inPMC|hasPDF|hasBook|hasSuppl|citedByCount|hasReferences|hasTextMinedTerms|hasDbCrossReferences|hasLabsLinks|epmcAuthMan|hasTMAccessionNumbers|luceneScore|dbCrossReferenceList|dateOfCompletion|dateOfCreation|electronicPublicationDate|firstPublicationDate|pubModel|NLMid|dateOfPublication|monthOfPublication|printPublicationDate" />

  <xsl:template match="text()" />

  <xsl:template match="*">
    <xsl:message>Warning: ignored element &lt;<xsl:value-of select="name()" />&gt;</xsl:message>
    <xsl:apply-templates />
  </xsl:template>

</xsl:stylesheet>