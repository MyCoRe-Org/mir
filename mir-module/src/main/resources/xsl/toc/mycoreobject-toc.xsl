<?xml version="1.0" encoding="UTF-8"?>

<!-- 
  Displays a table of contents as <div id="toc" /> 
  There are multiple toc layouts defined in toc-layouts.xml.
  The toc layout to use is defined in
    /mycoreobject/service/servflags/servflag[@type='tocLayout']
  There are custom toc layout templates for HTML display of 
  toc levels and publications in custom-toc-layouts.xsl
-->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:encoder="xalan://java.net.URLEncoder"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  exclude-result-prefixes="mcrxsl encoder mods xalan i18n">
  
  <xsl:import href="xslImport:modsmeta:toc/mycoreobject-toc.xsl" />

  <xsl:template match="/">

    <!-- Transform toc-layouts.xml to SOLR parameters to get a TOC via JSON facet API-->
    <xsl:variable name="tocLayouts" select="document('xslStyle:toc/toc-layouts2solr-json-facet-query:resource:toc-layouts.xml')/*" />

    <!-- get ID of toc layout to use from service flag or toc-layouts.xml @default -->
    <xsl:variable name="layoutID">
      <xsl:choose>
        <xsl:when test="mycoreobject/service/servflags/servflag[@type='tocLayout'][string-length(text()) &gt; 0]">
          <xsl:value-of select="mycoreobject/service/servflags/servflag[@type='tocLayout']" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$tocLayouts/@default" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- query to find all objects below this one (children, grand-children) -->
    <xsl:variable name="q">
      <xsl:value-of select="$tocLayouts/toc-layout[@id=$layoutID]/@field" />
      <xsl:text>:</xsl:text>
      <xsl:value-of select="mycoreobject/@ID" />
      <xsl:text> AND (</xsl:text>
      <xsl:text>state:</xsl:text>
      <xsl:choose>
        <xsl:when test="mcrxsl:isCurrentUserInRole('admin')">*</xsl:when>
        <xsl:when test="mcrxsl:isCurrentUserInRole('editor')">*</xsl:when>
        <xsl:otherwise>published OR createdby:<xsl:value-of select="$CurrentUser" /></xsl:otherwise>
      </xsl:choose>
      <xsl:text>)</xsl:text>
    </xsl:variable>
    
    <xsl:variable name="uri">
      <!-- First transform SOLR facet response to simpler XML, then render to HTML -->
      <xsl:text>xslStyle:toc/solr-facets2toc,toc/render-toc</xsl:text>
      <xsl:text>?tocLayoutID=</xsl:text><xsl:value-of select="$layoutID" /> 
      <xsl:text>:solr:q=</xsl:text><xsl:value-of select="encoder:encode($q)" />
      <xsl:value-of select="$tocLayouts/toc-layout[@id=$layoutID]" />
    </xsl:variable>
    
    <!-- if the response returned any documents, show a table of contents now -->
    <xsl:copy-of select="document($uri)/*" />
    
    <xsl:apply-imports />
  </xsl:template>
    
</xsl:stylesheet>
