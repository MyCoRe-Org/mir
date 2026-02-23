<?xml version="1.0" encoding="UTF-8"?>

<!-- Converts Scopus abstracts-retrieval-response format to MODS -->
<!-- http://api.elsevier.com/content/abstract/scopus_id/84946429507?apikey=... -->

<xsl:stylesheet version="1.0"
  xmlns:ce="http://www.elsevier.com/xml/ani/common"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:scopus="http://www.elsevier.com/xml/svapi/abstract/dtd"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="">

  <xsl:output method="xml" encoding="UTF-8" indent="yes" xalan:indent-amount="2" />

  <xsl:template match="scopus:abstracts-retrieval-response">
    <mods:mods>
      <xsl:apply-templates select="item/bibrecord/head/citation-info/citation-type/@code" />
      <xsl:apply-templates select="item/bibrecord/head/citation-title/titletext" />
      <xsl:apply-templates select="scopus:authors/scopus:author">
        <xsl:sort select="@seq" data-type="number" order="ascending" />
      </xsl:apply-templates>
      <xsl:apply-templates select="item/bibrecord/head/source[not((@type='b') and (../citation-info/citation-type/@code='bk'))]" />
      <xsl:apply-templates select="item/bibrecord/item-info/itemidlist" />
      <xsl:apply-templates select="item/bibrecord/head[citation-info/citation-type/@code='bk']/source[@type='b']/isbn" />
      <mods:originInfo eventType="publication">
        <xsl:apply-templates select="item/bibrecord/head[citation-info/citation-type/@code='bk']/source[@type='b']/publisher/publishername" />
        <xsl:apply-templates select="item/bibrecord/head/source/publicationdate/year" />
      </mods:originInfo>
      <xsl:apply-templates select="item/bibrecord/head/citation-info/author-keywords/author-keyword" />
      <xsl:apply-templates select="scopus:language[@xml:lang]" />
    </mods:mods>
  </xsl:template>

  <xsl:template match="citation-title/titletext">
    <mods:titleInfo>
      <xsl:apply-templates select="@xml:lang" />
      <mods:title>
        <xsl:apply-templates select="*|text()" />
      </mods:title>
    </mods:titleInfo>
  </xsl:template>
  
  <xsl:template match="inf"> <!-- subscript / inferior -->
    <xsl:value-of select="translate(text(),'-+=()aeox0123456789','₋₊₌₍₎ₐₑₒₓ₀₁₂₃₄₅₆₇₈₉')" />
  </xsl:template>
  
  <xsl:template match="sup"> <!-- superscript / superior -->
    <xsl:value-of select="translate(text(),'-+=()ni0123456789','⁻⁺⁼⁽⁾ⁿⁱ⁰¹²³⁴⁵⁶⁷⁸⁹')" />
  </xsl:template>

  <xsl:template match="titletext/text()|ce:para/text()" priority="1">
    <xsl:copy-of select="." />
  </xsl:template>

  <xsl:template match="scopus:authors/scopus:author">
    <mods:name type="personal">
      <xsl:apply-templates select="ce:surname" />
      <xsl:apply-templates select="ce:given-name" />
      <xsl:apply-templates select="ce:initials[not(../ce:given-name)]" />
      <xsl:apply-templates select="@orcid" />
      <xsl:apply-templates select="@auid" />
      <mods:role>
        <mods:roleTerm type="code" authority="marcrelator">aut</mods:roleTerm>
      </mods:role>
      <xsl:apply-templates select="scopus:affiliation" />
      <xsl:apply-templates select="//author[@auid=current()/@auid][1]/ce:e-address[@type='email']" />
    </mods:name>
  </xsl:template>

  <xsl:template match="ce:e-address[@type='email']">
    <mods:affiliation>
      <xsl:value-of select="." />
    </mods:affiliation>
  </xsl:template>

  <xsl:template match="scopus:affiliation">
    <xsl:apply-templates select="//affiliation[@afid=current()/@id][1]" />
  </xsl:template>

  <xsl:template match="affiliation">
    <mods:affiliation>
      <xsl:apply-templates select="organization|address-part|city|country" />
    </mods:affiliation>
  </xsl:template>

  <xsl:template match="organization|address-part|city|country">
    <xsl:value-of select="text()" />
    <xsl:if test="position() != last()">, </xsl:if>
  </xsl:template>

  <xsl:template match="@orcid">
    <mods:nameIdentifier type="orcid">
      <xsl:value-of select="." />
    </mods:nameIdentifier>
  </xsl:template>

  <xsl:template match="scopus:author/@auid">
    <mods:nameIdentifier type="scopus">
      <xsl:value-of select="." />
    </mods:nameIdentifier>
  </xsl:template>

  <xsl:template match="ce:surname">
    <mods:namePart type="family">
      <xsl:value-of select="text()" />
    </mods:namePart>
  </xsl:template>

  <xsl:template match="ce:given-name|ce:initials">
    <mods:namePart type="given">
      <xsl:value-of select="text()" />
    </mods:namePart>
  </xsl:template>

  <xsl:template match="@xml:lang">
    <xsl:attribute name="xml:lang">
      <xsl:value-of select="document(concat('language:',.))/language/@xmlCode" />
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="scopus:language">
    <mods:language>
      <mods:languageTerm authority="rfc5646" type="code">
        <xsl:value-of select="document(concat('language:',@xml:lang))/language/@xmlCode" />
      </mods:languageTerm>
    </mods:language>
  </xsl:template>

  <xsl:template match="source">
    <mods:relatedItem type="host">
      <xsl:apply-templates select="@type" />
      <xsl:apply-templates select="sourcetitle|sourcetitle-abbrev" />
      <xsl:call-template name="part" />
      <xsl:apply-templates select="issn|isbn" />
      <mods:originInfo eventType="publication">
        <xsl:apply-templates select="publisher/publishername" />
      </mods:originInfo>
    </mods:relatedItem>
  </xsl:template>

  <xsl:template match="citation-type/@code">
    <mods:genre>
      <xsl:choose>
        <xsl:when test=".='ab'">Abstract Report</xsl:when>
        <xsl:when test=".='ar'">Article</xsl:when>
        <xsl:when test=".='bk'">Book</xsl:when>
        <xsl:when test=".='br'">Book Review</xsl:when>
        <xsl:when test=".='bz'">Business Article</xsl:when>
        <xsl:when test=".='cb'">Conference Abstract</xsl:when>
        <xsl:when test=".='cp'">Conference Paper</xsl:when>
        <xsl:when test=".='cr'">Conference Review</xsl:when>
        <xsl:when test=".='di'">Dissertation</xsl:when>
        <xsl:when test=".='ed'">Editorial</xsl:when>
        <xsl:when test=".='er'">Erratum</xsl:when>
        <xsl:when test=".='ip'">Article in Press</xsl:when>
        <xsl:when test=".='le'">Letter</xsl:when>
        <xsl:when test=".='no'">Note</xsl:when>
        <xsl:when test=".='pa'">Patent</xsl:when>
        <xsl:when test=".='pr'">Press Release</xsl:when>
        <xsl:when test=".='re'">Review</xsl:when>
        <xsl:when test=".='rp'">Report</xsl:when>
        <xsl:when test=".='sh'">Short Survey</xsl:when>
        <xsl:when test=".='wp'">Working Paper</xsl:when>
      </xsl:choose>
    </mods:genre>
  </xsl:template>

  <xsl:template match="source/@type">
    <mods:genre>
      <xsl:choose>
        <xsl:when test=".='b'">Book</xsl:when>
        <xsl:when test=".='d'">Trade Journal</xsl:when>
        <xsl:when test=".='j'">Journal</xsl:when>
        <xsl:when test=".='k'">Book Series</xsl:when>
        <xsl:when test=".='m'">Multi-volume Reference Works</xsl:when>
        <xsl:when test=".='p'">Conference Proceedings</xsl:when>
        <xsl:when test=".='n'">Newsletter</xsl:when>
        <xsl:when test=".='w'">Newspaper</xsl:when>
      </xsl:choose>
    </mods:genre>
  </xsl:template>

  <xsl:template match="sourcetitle">
    <mods:titleInfo>
      <mods:title>
        <xsl:value-of select="text()" />
      </mods:title>
    </mods:titleInfo>
  </xsl:template>

  <xsl:template match="sourcetitle-abbrev">
    <mods:titleInfo type="abbreviated">
      <mods:title>
        <xsl:value-of select="text()" />
      </mods:title>
    </mods:titleInfo>
  </xsl:template>

  <xsl:template name="part">
    <mods:part>
      <xsl:for-each select="volisspag">
        <xsl:apply-templates select="voliss/@volume|voliss/@issue" />
        <xsl:apply-templates select="pagerange" />
      </xsl:for-each>
      <xsl:apply-templates select="article-number" />
    </mods:part>
  </xsl:template>

  <xsl:template match="voliss/@volume|voliss/@issue">
    <mods:detail type="{name()}">
      <mods:number>
        <xsl:value-of select="." />
      </mods:number>
    </mods:detail>
  </xsl:template>

  <xsl:template match="article-number">
    <mods:detail type="article_number">
      <mods:number>
        <xsl:value-of select="." />
      </mods:number>
    </mods:detail>
  </xsl:template>

  <xsl:template match="pagerange">
    <mods:extent unit="pages">
      <xsl:apply-templates select="@first|@last" />
    </mods:extent>
  </xsl:template>

  <xsl:template match="@first">
    <mods:start>
      <xsl:value-of select="." />
    </mods:start>
  </xsl:template>

  <xsl:template match="@last">
    <mods:end>
      <xsl:value-of select="." />
    </mods:end>
  </xsl:template>

  <xsl:template match="publicationdate/year">
    <mods:dateIssued encoding="w3cdtf">
      <xsl:value-of select="." />
    </mods:dateIssued>
  </xsl:template>

  <xsl:template match="publisher/publishername">
    <mods:publisher>
      <xsl:value-of select="." />
    </mods:publisher>
  </xsl:template>

  <xsl:template match="issn">
    <mods:identifier type="issn">
      <xsl:value-of select="substring(.,1,4)" />
      <xsl:text>-</xsl:text>
      <xsl:value-of select="substring(.,5)" />
    </mods:identifier>
  </xsl:template>

  <xsl:template match="isbn">
    <mods:identifier type="isbn">
      <xsl:value-of select="text()" />
    </mods:identifier>
  </xsl:template>

  <xsl:template match="scopus:pubmed-id">
    <mods:identifier type="pubmed">
      <xsl:value-of select="text()" />
    </mods:identifier>
  </xsl:template>

  <xsl:template match="itemidlist">
    <xsl:apply-templates select="ce:doi" />
    <xsl:apply-templates select="itemid[@idtype='SCP']" />
  </xsl:template>

  <xsl:template match="ce:doi">
    <mods:identifier type="doi">
      <xsl:value-of select="." />
    </mods:identifier>
  </xsl:template>

  <xsl:template match="itemid[@idtype='SCP']">
    <mods:identifier type="scopus">
      <xsl:value-of select="." />
    </mods:identifier>
  </xsl:template>

  <xsl:template match="author-keywords/author-keyword">
    <mods:subject>
      <mods:topic>
        <xsl:value-of select="." />
      </mods:topic>
    </mods:subject>
  </xsl:template>

  <xsl:template match="text()" />

  <xsl:template match="*">
    <xsl:message>Warning: ignored element &lt;<xsl:value-of select="name()" />&gt;</xsl:message>
    <xsl:apply-templates />
  </xsl:template>

</xsl:stylesheet>
