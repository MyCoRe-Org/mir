<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:mcri18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:mcrutils="xalan://org.mycore.common.MCRUtils"
  xmlns:mcrxml="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="mcri18n mcrutils mcrxml">

  <xsl:include href="resource:xsl/MyCoReLayout.xsl" />
  <xsl:include href="resource:xsl/datatable.xsl" />

  <xsl:variable name="PageTitle" select="mcri18n:translate('metadata.files.file')" />

  <xsl:variable name="mainUri" select="/mcr_directory/uri" />
  <xsl:variable name="ownerId" select="/mcr_directory/ownerID" />
  <xsl:variable name="path" select="/mcr_directory/path" />

  <xsl:template match="/mcr_directory">
    <head>
      <meta name="robots" content="noindex, follow" />
    </head>

    <h2>
      <xsl:value-of select="mcri18n:translate('metadata.files.file')" />
    </h2>
    <p>
      <a href="{$WebApplicationBaseURL}receive/{mcrxml:getMCRObjectID(string(ownerID))}">
        <xsl:value-of select="mcri18n:translate('metadata.files.backToObject')" />
      </a>
    </p>

    <xsl:apply-templates mode="dataTable" select="children">
      <xsl:with-param name="id" select="'files'" />
      <xsl:with-param name="disableFilter" select="true()"></xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template mode="dataTableHeader" match="children">
    <col sortBy="name">
      <xsl:value-of select="mcri18n:translate('metadata.files.name')" />
    </col>
    <col style="width: 12%">
      <xsl:value-of select="mcri18n:translate('metadata.files.date')" />
    </col>
    <col sortBy="size" sortType="number" style="width: 8%">
      <xsl:value-of select="mcri18n:translate('metadata.files.size')" />
    </col>
  </xsl:template>

  <xsl:template mode="dataTableRow" match="child">
    <col>
      <a>
        <xsl:attribute name="href">
          <xsl:value-of select="concat($WebApplicationBaseURL, mcrxml:encodeURIPath(concat('servlets/MCRFileNodeServlet/', $ownerId, $path, name/text())))" />
        </xsl:attribute>
        <xsl:value-of select="name" />
      </a>
    </col>
    <col>
      <xsl:value-of select="mcrxml:formatISODate(string(date[@type='lastModified']), 'dd.MM.yyyy', 'de')" />
    </col>
    <col align="right">
      <xsl:value-of select="mcrutils:getSizeFormatted(number(size))" />
    </col>
  </xsl:template>

</xsl:stylesheet>
