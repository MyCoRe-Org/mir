<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcrderivate="http://www.mycore.de/xslt/derivate"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mcrstringutils="http://www.mycore.de/xslt/stringutils"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:include href="resource:xslt/MyCoReLayout.xsl" />
  <xsl:include href="resource:xslt/datatable.xsl" />

  <xsl:param name="i18n-prefix" select="'metadata.files.'" />

  <xsl:variable name="PageTitle" select="mcri18n:translate($i18n-prefix || 'file')" />

  <xsl:variable name="mainUri" select="/mcr_directory/uri" />
  <xsl:variable name="ownerId" select="/mcr_directory/ownerID" />
  <xsl:variable name="path" select="/mcr_directory/path" />

  <xsl:template match="/mcr_directory">
    <head>
      <meta name="robots" content="noindex, follow" />
    </head>
    <h2>
      <xsl:value-of select="$PageTitle" />
    </h2>
    <p>
      <a href="{$WebApplicationBaseURL}receive/{mcrderivate:get-owner-id($ownerId)}">
        <xsl:value-of select="mcri18n:translate($i18n-prefix || 'backToObject')" />
      </a>
    </p>
    <xsl:apply-templates mode="dataTable" select="children">
      <xsl:with-param name="id" select="'files'" />
      <xsl:with-param name="disableFilter" select="true()" />
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template mode="dataTableHeader" match="children">
    <col sortBy="name">
      <xsl:value-of select="mcri18n:translate($i18n-prefix || 'name')" />
    </col>
    <col style="width: 12%">
      <xsl:value-of select="mcri18n:translate($i18n-prefix || 'date')" />
    </col>
    <col sortBy="size" sortType="number" style="width: 8%">
      <xsl:value-of select="mcri18n:translate($i18n-prefix || 'size')" />
    </col>
  </xsl:template>

  <xsl:template mode="dataTableRow" match="child">
    <col>
      <a href="{concat($ServletsBaseURL, encode-for-uri(concat('MCRFileNodeServlet/', $ownerId, $path, name/text())))}">
        <xsl:value-of select="name" />
      </a>
    </col>
    <col>
      <xsl:value-of select="format-dateTime(date[@type='lastModified'], mcri18n:translate('metaData.date.xsl3'))" />
    </col>
    <col align="right">
      <xsl:value-of select="mcrstringutils:pretty-filesize(size)" />
    </col>
  </xsl:template>

</xsl:stylesheet>
