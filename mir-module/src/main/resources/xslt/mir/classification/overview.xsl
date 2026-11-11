<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mcrurl="http://www.mycore.de/xslt/url"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">
  
  <xsl:include href="resource:xslt/MyCoReLayout.xsl" />
  <xsl:include href="resource:xslt/classificationBrowser.xsl" />
  
  <xsl:variable name="Navigation.title" select="mcri18n:translate('mir.classification.select')" />
  <xsl:variable name="MainTitle" select="mcri18n:translate('mir.classification')" />
  <xsl:variable name="PageTitle" select="$Navigation.title" />
  
	<xsl:template match="classifications[@classID]">
    <xsl:call-template name="mcrClassificationBrowser">
      <xsl:with-param name="classification" select="@classID" />
      <xsl:with-param name="category" select="@categID" />
      <!-- reuse role subselect -->
      <xsl:with-param name="style" select="'roleSubselect'" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="classifications[group]">
 		<xsl:apply-templates select="classification" />
  </xsl:template>

  <xsl:template match="classification">
    <xsl:variable name="url1" select="mcrurl:set-param($RequestURL, 'categID', @authority)" />
    <xsl:variable name="url2" select="mcrurl:set-param($url1, 'action', 'chooseCategory')" />
    <xsl:variable name="url" select="mcrurl:add-session($url2)" />

    <a class="list-group-item" href="{$url}">
      <xsl:value-of select="text()" />
    </a>
  </xsl:template>
</xsl:stylesheet>
