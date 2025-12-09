<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:encoder="xalan://java.net.URLEncoder"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:str="http://exslt.org/strings"
  xmlns:acl="xalan://org.mycore.access.MCRAccessManager" xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions" exclude-result-prefixes="i18n mods str acl mcrxsl encoder"
>

  <xsl:output method="html" encoding="UTF-8" omit-xml-declaration="yes" />
  <xsl:param name="WebApplicationBaseURL" />
  <xsl:param name="ServletsBaseURL" />
  <xsl:include href="response-utils.xsl" />
  <xsl:include href="response-mir.xsl" />
  <xsl:include href="layout-utils.xsl" />
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