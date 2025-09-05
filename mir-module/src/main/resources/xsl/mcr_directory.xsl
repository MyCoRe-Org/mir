<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:mcrxml="xalan://org.mycore.common.xml.MCRXMLFunctions" xmlns:utils="xalan://org.mycore.common.MCRUtils" exclude-result-prefixes="i18n mcrxml utils"
>

  <xsl:include href="MyCoReLayout.xsl" />
  <xsl:include href="datatable.xsl" />

  <xsl:variable name="PageTitle" select="i18n:translate('metadata.files.file')" />

  <xsl:variable name="mainUri" select="/mcr_directory/uri" />
  <xsl:variable name="ownerId" select="/mcr_directory/ownerID" />

  <xsl:template match="/mcr_directory">
    <head>
      <meta name="robots" content="noindex, follow" />
    </head>

    <h2>
      <xsl:value-of select="i18n:translate('metadata.files.file')" />
    </h2>
    <p>
      <a href="{$WebApplicationBaseURL}receive/{mcrxml:getMCRObjectID(string(ownerID))}">
        <xsl:value-of select="i18n:translate('metadata.files.backToObject')" />
      </a>
    </p>

    <xsl:apply-templates mode="dataTable" select="children">
      <xsl:with-param name="id" select="'files'" />
      <xsl:with-param name="disableFilter" select="true()"></xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template mode="dataTableHeader" match="children">
    <col sortBy="name">
      <xsl:value-of select="i18n:translate('metadata.files.name')" />
    </col>
    <col style="width: 12%">
      <xsl:value-of select="i18n:translate('metadata.files.date')" />
    </col>
    <col sortBy="size" sortType="number" style="width: 8%">
      <xsl:value-of select="i18n:translate('metadata.files.size')" />
    </col>
  </xsl:template>

  <xsl:template mode="dataTableRow" match="child">
    <col>
      <a>
        <xsl:attribute name="href">
          <xsl:value-of select="concat($WebApplicationBaseURL, 'servlets/MCRFileNodeServlet/', $ownerId, '/', substring-after(uri, $mainUri))" />
        </xsl:attribute>
        <xsl:value-of select="name" />
      </a>
    </col>
    <col>
      <xsl:value-of select="mcrxml:formatISODate(string(date[@type='lastModified']), 'dd.MM.yyyy', 'de')" />
    </col>
    <col align="right">
      <xsl:value-of select="utils:getSizeFormatted(number(size))" />
    </col>
  </xsl:template>

</xsl:stylesheet>