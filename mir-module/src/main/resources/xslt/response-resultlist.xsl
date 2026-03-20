<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:output method="html" encoding="UTF-8" omit-xml-declaration="yes" />

  <xsl:include href="resource:xslt/default-parameters.xsl" />
  <xsl:include href="xslInclude:functions" />
  <xsl:include href="resource:xslt/solr/response/response-utils.xsl" />
  <xsl:include href="resource:xslt/response-mir.xsl" />

  <xsl:variable name="PageTitle" select="''" />

  <xsl:template match="/">
    <xsl:for-each select="//response[@subresult='groupOwner']/result/doc">
      <xsl:apply-templates select="." mode="resultList">
        <xsl:with-param name="hitNumberOnPage" select="position()" />
      </xsl:apply-templates>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
