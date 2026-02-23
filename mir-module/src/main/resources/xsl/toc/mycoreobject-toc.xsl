<?xml version="1.0" encoding="UTF-8"?>

<!--
  Displays a table of contents as <div id="toc" />
  There are multiple toc layouts defined in toc-layouts.xml.
  The toc layout to use is defined in
    /mycoreobject/service/servflags/servflag[@type='tocLayout']
  There are custom toc layout templates for HTML display of
  toc levels and publications in custom-toc-layouts.xsl

  Add ?XSL.TOC.Debug=true to display transformation steps in debug mode
  Add ?XSL.TOC.LayoutID=[ID] to override configured layout
-->

<xsl:stylesheet version="1.0"
  xmlns:encoder="xalan://java.net.URLEncoder"
  xmlns:mcrxml="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="encoder mcrxml xalan xsl">

  <xsl:import href="xslImport:modsmeta:toc/mycoreobject-toc.xsl" />

  <xsl:param name="TOC.Debug" />
  <xsl:param name="TOC.LayoutID" />

  <xsl:template match="/">

    <!-- Transform toc-layouts.xml to SOLR parameters to get a TOC via JSON facet API-->
    <xsl:variable name="tocLayouts" select="document('xslStyle:toc/toc-layouts2solr-json-facet-query#xsl:resource:toc-layouts.xml')/*" />

    <!-- get preferred ID of toc layout to use from URL parameter of service flag -->
    <xsl:variable name="preferredLayoutID">
      <xsl:choose>
        <xsl:when test="string-length($TOC.LayoutID) &gt; 0">
          <xsl:value-of select="$TOC.LayoutID"/>
        </xsl:when>
        <xsl:when test="mycoreobject/service/servflags/servflag[@type='tocLayout'][string-length(text()) &gt; 0]">
          <xsl:value-of select="mycoreobject/service/servflags/servflag[@type='tocLayout']"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <!-- select actual ID of toc layout to use. Use preferred ID, if available, or fallback to toc-layouts.xml @default -->
    <xsl:variable name="layoutID">
      <xsl:choose>
        <xsl:when test="$preferredLayoutID and $tocLayouts/toc-layout[@id=$preferredLayoutID]">
          <xsl:value-of select="$preferredLayoutID"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$tocLayouts/@default"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- Query to find all objects below this one (children, grand-children) -->
    <xsl:variable name="q">
      <xsl:value-of select="$tocLayouts/toc-layout[@id=$layoutID]/@field" />
      <xsl:text>:</xsl:text>
      <xsl:value-of select="mycoreobject/@ID" />
      <xsl:text> AND (</xsl:text>
      <xsl:text>state:</xsl:text>
      <xsl:choose>
        <xsl:when test="mcrxml:isCurrentUserInRole('admin')">*</xsl:when>
        <xsl:when test="mcrxml:isCurrentUserInRole('editor')">*</xsl:when>
        <xsl:otherwise>published OR createdby:<xsl:value-of select="$CurrentUser" /></xsl:otherwise>
      </xsl:choose>
      <xsl:text>)</xsl:text>
    </xsl:variable>

    <!-- Complete SOLR URI including facet parameters to build TOC -->
    <xsl:variable name="solrURI">
      <xsl:text>solr:q=</xsl:text><xsl:value-of select="encoder:encode($q)" />
      <xsl:value-of select="$tocLayouts/toc-layout[@id=$layoutID]" />
    </xsl:variable>

    <!-- First transform SOLR facet response to simpler XML... -->
    <xsl:variable name="prepURI">
      <xsl:text>xslStyle:toc/solr-facets2toc#xsl</xsl:text>
      <xsl:text>?tocLayoutID=</xsl:text><xsl:value-of select="$layoutID" />
      <xsl:text>:</xsl:text>
      <xsl:value-of select="$solrURI" />
    </xsl:variable>

    <!-- ... then render to HTML -->
    <xsl:variable name="htmlURI">
      <xsl:text>notnull:xslStyle:toc/render-toc#xsl:</xsl:text>
      <xsl:value-of select="$prepURI" />
    </xsl:variable>

    <xsl:if test="$TOC.Debug='true'">
      <div id="toc" class="detail_block mt-4 mb-4">
        <xsl:call-template name="toc.debug">
          <xsl:with-param name="headline">TOC Layout ID</xsl:with-param>
          <xsl:with-param name="content"  >
            <xsl:text>URL parameter = </xsl:text>
            <xsl:value-of select="$TOC.LayoutID"/>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>Service flag = </xsl:text>
            <xsl:value-of select="mycoreobject/service/servflags/servflag[@type='tocLayout']"/>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>Actually used = </xsl:text>
            <xsl:value-of select="$layoutID"/>
          </xsl:with-param>
          <xsl:with-param name="rows">3</xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="toc.debug">
          <xsl:with-param name="headline">TOC SOLR Query</xsl:with-param>
          <xsl:with-param name="content" select="$q" />
          <xsl:with-param name="rows">1</xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="toc.debug">
          <xsl:with-param name="headline">TOC SOLR URI</xsl:with-param>
          <xsl:with-param name="content" select="$solrURI" />
          <xsl:with-param name="rows">10</xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="toc.debug">
          <xsl:with-param name="headline">TOC SOLR Response</xsl:with-param>
          <xsl:with-param name="content" select="document($solrURI)" />
        </xsl:call-template>
        <xsl:call-template name="toc.debug">
          <xsl:with-param name="headline">Preprocessed TOC</xsl:with-param>
          <xsl:with-param name="content" select="document($prepURI)" />
        </xsl:call-template>
      </div>
    </xsl:if>

    <!-- if the response returned any documents, show a table of contents now -->
    <xsl:copy-of select="document($htmlURI)/div[@id='toc']" />

    <xsl:apply-imports />
  </xsl:template>

  <xsl:template name="toc.debug">
    <xsl:param name="headline" />
    <xsl:param name="content" />
    <xsl:param name="rows" select="'20'" />

    <h3 class="mt-1">
      <xsl:value-of select="$headline" />
      <xsl:text>:</xsl:text>
    </h3>
    <textarea rows="{$rows}" style="border:none; width:100%; font-size:1em; font-family:monospace; margin:2ex;">
      <xsl:copy-of select="$content" />
    </textarea>
  </xsl:template>

</xsl:stylesheet>
