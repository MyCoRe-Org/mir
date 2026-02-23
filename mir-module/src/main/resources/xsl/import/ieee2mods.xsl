<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="xalan xsl">

<!-- http://ieeexplore.ieee.org/gateway/ipsSearch.jsp?an=4731412 -->

  <xsl:template match="/articles">
    <xsl:apply-templates select="article[1]" />
  </xsl:template>
  
  <xsl:template match="article">
    <mods:mods>
      <xsl:apply-templates select="content_type" />
      <xsl:apply-templates select="title" />
      <xsl:apply-templates select="authors" />
      <xsl:apply-templates select="self::node()[publication_title|issn|isbn|volume|issue|start_page|end_page]" mode="host" />
      <xsl:apply-templates select="doi" />
      <xsl:apply-templates select="article_number" />
      <xsl:apply-templates select="pdf_url" />
      <xsl:apply-templates select="abstract" />
    </mods:mods>
  </xsl:template>
  
  <xsl:template match="content_type">
    <mods:genre>
      <xsl:value-of select="." />
    </mods:genre>
  </xsl:template>
  
  <xsl:template match="title|publication_title">
    <mods:titleInfo>
      <mods:title>
        <xsl:value-of select="text()" />
      </mods:title>
    </mods:titleInfo>
  </xsl:template>
  
  <xsl:template match="authors">
    <xsl:apply-templates select="author">
      <xsl:sort select="author_order" data-type="number" />
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="author">
    <mods:name type="personal">
      <xsl:apply-templates select="full_name" />
      <xsl:apply-templates select="affiliation" />
      <mods:role>
        <mods:roleTerm authority="marcrelator" type="code">aut</mods:roleTerm>
      </mods:role>
    </mods:name>
  </xsl:template>
  
  <xsl:template match="full_name">
    <mods:namePart type="given">
      <xsl:for-each select="xalan:tokenize(.,' ')">
        <xsl:if test="position() != last()">
          <xsl:if test="position() &gt; 1">
            <xsl:text> </xsl:text>
          </xsl:if>
          <xsl:value-of select="." />
        </xsl:if>
      </xsl:for-each>
    </mods:namePart>
    <mods:namePart type="family">
      <xsl:for-each select="xalan:tokenize(.,' ')">
        <xsl:if test="position() = last()">
          <xsl:value-of select="." />
        </xsl:if>
      </xsl:for-each>
    </mods:namePart>
  </xsl:template>

  <xsl:template match="affiliation">
    <mods:affiliation>
      <xsl:value-of select="text()" />
    </mods:affiliation>
  </xsl:template>
  
  <xsl:template match="article" mode="host">
    <mods:relatedItem type="host">
      <xsl:apply-templates select="publication_title" />
      <xsl:apply-templates select="issn|isbn" />
      <xsl:apply-templates select="self::node()[publisher]" mode="origin" />
      <xsl:apply-templates select="self::node()[volume|issue|start_page|end_page]" mode="part" />
    </mods:relatedItem>
  </xsl:template>
  
  <xsl:template match="article" mode="origin">
    <mods:originInfo eventType="publication">
      <xsl:apply-templates select="publisher" />
    </mods:originInfo>
  </xsl:template>
  
  <xsl:template match="publisher">
    <mods:publisher>
      <xsl:value-of select="text()" />
    </mods:publisher>
  </xsl:template>
  
  <xsl:template match="py">
    <mods:dateIssued encoding="w3cdtf">
      <xsl:value-of select="text()" />
    </mods:dateIssued>
  </xsl:template>
  
  <xsl:template match="article" mode="part">
    <mods:part>
      <xsl:apply-templates select="volume" />
      <xsl:apply-templates select="issue" />
      <xsl:apply-templates select="self::node()[spage|epage]" mode="pages" />
    </mods:part>
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
  
  <xsl:template match="article" mode="pages">
    <mods:extent unit="pages">
      <xsl:apply-templates select="spage" />
      <xsl:apply-templates select="epage" />
    </mods:extent>
  </xsl:template>
  
  <xsl:template match="start_page">
    <mods:start>
      <xsl:value-of select="text()" />
    </mods:start>
  </xsl:template>

  <xsl:template match="end_page">
    <mods:end>
      <xsl:value-of select="text()" />
    </mods:end>
  </xsl:template>
  
  <xsl:template match="article_number">
    <mods:identifier type="ieee">
      <xsl:value-of select="text()" />
    </mods:identifier>
  </xsl:template>
  
  <xsl:template match="doi">
    <mods:identifier type="doi">
      <xsl:value-of select="text()" />
    </mods:identifier>
  </xsl:template>

  <xsl:template match="issn">
    <mods:identifier type="isse">
      <xsl:value-of select="text()" />
    </mods:identifier>
  </xsl:template>

  <xsl:template match="isbn[contains(.,'Electronic_')]">
    <mods:identifier type="isbn">
      <xsl:value-of select="substring-after(.,'Electronic_')" />
    </mods:identifier>
  </xsl:template>

  <xsl:template match="isbn">
    <mods:identifier type="isbn">
      <xsl:value-of select="text()" />
    </mods:identifier>
  </xsl:template>

  <xsl:template match="pdf_url">
    <mods:location>
      <mods:url>
        <xsl:value-of select="." />
      </mods:url>
    </mods:location>
  </xsl:template>

  <xsl:template match="abstract">
    <mods:abstract>
      <xsl:value-of select="text()" />
    </mods:abstract>
  </xsl:template>

</xsl:stylesheet>