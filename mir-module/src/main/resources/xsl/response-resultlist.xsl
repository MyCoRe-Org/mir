<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="xsl">

  <xsl:output method="html" encoding="UTF-8" omit-xml-declaration="yes" />
  <xsl:param name="WebApplicationBaseURL" />
  <xsl:param name="ServletsBaseURL" />
  <xsl:include href="resource:xsl/response-utils.xsl" />
  <xsl:include href="resource:xsl/response-mir.xsl" />
  <xsl:include href="resource:xsl/layout-utils.xsl" />
  <xsl:variable name="PageTitle">
    <xsl:value-of select="''" />
  </xsl:variable>

  <xsl:key name="derivate" match="response/response[@subresult='derivate']/result/doc" use="str[@name='returnId']" />

  <xsl:template match="/">
    <xsl:for-each select="//response[@subresult='groupOwner']/result/doc">
      <xsl:apply-templates select="." mode="resultList">
        <xsl:with-param name="hitNumberOnPage" select="position()" />
      </xsl:apply-templates>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
