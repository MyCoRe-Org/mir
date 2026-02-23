<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [
  <!ENTITY html-output SYSTEM "xsl/xsl-output-html.fragment">
]>

<xsl:stylesheet version="1.0"
  xmlns:encoder="xalan://java.net.URLEncoder"
  xmlns:mcri18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="encoder">

  &html-output;
  <xsl:variable name="Navigation.title" select="mcri18n:translate('subselect.category.title')" />
  <xsl:variable name="MainTitle" select="mcri18n:translate('common.titles.mainTitle')" />
  <xsl:variable name="PageTitle" select="$Navigation.title" />

<!-- ========== Subselect Parameter ========== -->
  <xsl:param name="subselect.session" />
  <xsl:param name="subselect.varpath" />
  <xsl:param name="subselect.webpage" />
  <xsl:param name="RequestURL" />
  <xsl:param name="template" />

  <xsl:variable name="cancelURL"
    select="concat($ServletsBaseURL,'XMLEditor',
    '?_action=end.subselect&amp;subselect.session=',$subselect.session,
    '&amp;subselect.webpage=', encoder:encode($subselect.webpage))" />

  <xsl:variable name="url"
    select="concat($ServletsBaseURL,'XMLEditor',
    '?_action=end.subselect&amp;subselect.session=',$subselect.session,
    '&amp;subselect.varpath=', $subselect.varpath,
    '&amp;subselect.webpage=', encoder:encode($subselect.webpage))" />
	
<!-- The main template -->
  <xsl:template match="classsubselect">

    <xsl:variable name="classid">
      <xsl:call-template name="UrlGetParam">
        <xsl:with-param name="url" select="$RequestURL" />
        <xsl:with-param name="par" select="'classid'" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="category">
      <xsl:call-template name="UrlGetParam">
        <xsl:with-param name="url" select="$RequestURL" />
        <xsl:with-param name="par" select="'category'" />
      </xsl:call-template>
    </xsl:variable>

    <a href="{$cancelURL}" class="btn btn-warning">
      <xsl:value-of select="mcri18n:translate('subselect.category.cancel')" />
    </a>
    <xsl:call-template name="mcrClassificationBrowser">
      <xsl:with-param name="classification" select="$classid" />
      <xsl:with-param name="category" select="$category" />
      <xsl:with-param name="parameters" select="$url" />
      <xsl:with-param name="adduri" select="'true'" />
      <xsl:with-param name="adddescription" select="'true'" />
      <xsl:with-param name="style" select="'subselect'" />
      <xsl:with-param name="countresults" select="'false'" />
      <xsl:with-param name="addParameter" select="concat('XSL.template=', $template)" />
    </xsl:call-template>

  </xsl:template>

  <xsl:include href="MyCoReLayout.xsl" />
  <xsl:include href="classificationBrowser.xsl" />
</xsl:stylesheet>
