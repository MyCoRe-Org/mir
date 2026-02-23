<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:mcri18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="mcri18n xalan">
  
  <xsl:include href="MyCoReLayout.xsl" />
  <xsl:include href="classificationBrowser.xsl" />
  
  <xsl:variable name="Navigation.title" select="mcri18n:translate('mir.classification.select')" />
  <xsl:variable name="MainTitle" select="mcri18n:translate('mir.classification')" />
  <xsl:variable name="PageTitle" select="$Navigation.title" />
  
  <xsl:param name="WebApplicationBaseURL" />
  
	<xsl:template match="classifications[@classID]">
    <xsl:call-template name="mcrClassificationBrowser">
      <xsl:with-param name="classification" select="@classID" />
      <xsl:with-param name="category" select="@categID" />
      <xsl:with-param name="style" select="'roleSubselect'" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="classifications[group]">
 		<xsl:apply-templates select="classification" />
  </xsl:template>

  <xsl:template match="classification">
    <xsl:variable name="session">
			<xsl:value-of select="../@queryParams" />
		</xsl:variable>
		<xsl:variable name="id">
			<xsl:value-of select="@authority"></xsl:value-of>
		</xsl:variable>
			<a class="list-group-item" href="{$ServletsBaseURL}MIRClassificationServlet?{$session}&amp;categID={$id}&amp;action=chooseCategory" >
				<xsl:value-of select="text()" />
			</a>
  </xsl:template>
</xsl:stylesheet>
