<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:encoder="xalan://java.net.URLEncoder"
  xmlns:orcid="xalan://org.mycore.orcid.user.MCRORCIDSession"
  xmlns:mods="http://www.loc.gov/mods/v3"
  exclude-result-prefixes="xsl xalan i18n encoder orcid mods">

<xsl:param name="error" />

<xsl:param name="CurrentLang" />
<xsl:param name="WebApplicationBaseURL" />
<xsl:param name="MCR.ORCID.LinkURL" />
<xsl:param name="MIR.DefaultLayout.CSS" />
<xsl:param name="MIR.CustomLayout.CSS" select="''" />
<xsl:param name="MIR.CustomLayout.JS" select="''" />
<xsl:param name="MIR.Layout.Theme" />

<xsl:output method="html" encoding="UTF-8" media-type="text/html" indent="yes" xalan:indent-amount="2" />

<xsl:template match="/">
  <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html>

  </xsl:text>
  <html lang="{$CurrentLang}">
    <head>
      <title>
        <xsl:value-of select="i18n:translate('orcid.integration.popup.title')" />
      </title>
      <link href="{$WebApplicationBaseURL}assets/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
      <script type="text/javascript" src="{$WebApplicationBaseURL}mir-layout/assets/jquery/jquery.min.js"></script>
      <script type="text/javascript" src="{$WebApplicationBaseURL}mir-layout/assets/jquery/plugins/jquery-migrate/jquery-migrate.min.js"></script>
      <xsl:copy-of select="head/*" />
      <link href="{$WebApplicationBaseURL}rsc/sass/mir-layout/scss/{$MIR.Layout.Theme}-{$MIR.DefaultLayout.CSS}.css" rel="stylesheet" />
      <xsl:if test="string-length($MIR.CustomLayout.CSS) &gt; 0">
        <link href="{$WebApplicationBaseURL}css/{$MIR.CustomLayout.CSS}" rel="stylesheet" />
      </xsl:if>
      <xsl:if test="string-length($MIR.CustomLayout.JS) &gt; 0">
        <script type="text/javascript" src="{$WebApplicationBaseURL}js/{$MIR.CustomLayout.JS}"></script>
      </xsl:if>
    </head>
    <body>
      <xsl:apply-templates select="user" />
    </body>
  </html>
</xsl:template>

<xsl:template match="user">

  <script type="text/javascript">
    function closeWindowAndReloadProfilePage() {
      window.opener.location.reload(); 
      window.close();
    }
  </script>

  <article class="highlight1">
    <xsl:choose>
      <xsl:when test="string-length($error) &gt; 0">
        <xsl:call-template name="orcidIntegrationRejected" />
      </xsl:when>
      <xsl:when test="attributes/attribute[@name='token_orcid']">
        <xsl:call-template name="orcidIntegrationConfirmed" />
      </xsl:when>
    </xsl:choose>
    <p>
      <button id="orcid-oauth-button" onclick="window.location='{$WebApplicationBaseURL}';">
        <xsl:value-of select="i18n:translate('orcid.integration.popup.close')" />
      </button>
    </p>
  </article>
  
</xsl:template>

<xsl:template name="orcidIntegrationRejected">
  <h3 style="margin-bottom: 0.5em;">
    <xsl:value-of select="i18n:translate('orcid.integration.rejected.headline')" />
  </h3>
  <p style="background-color:red; color:yellow; padding:0 1ex 0 1ex;">
    <xsl:choose>
      <xsl:when test="$error='access_denied'">
        <xsl:value-of select="i18n:translate('orcid.integration.rejected.denied')" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="i18n:translate('orcid.integration.rejected.error')" />
        <xsl:text> :</xsl:text>
        <xsl:value-of select="$error" />
      </xsl:otherwise>
    </xsl:choose>
  </p>
</xsl:template>

<xsl:template name="orcidIntegrationConfirmed">
  <h3 style="margin-bottom: 0.5em;">
    <span class="fas fa-check" aria-hidden="true" />
    <xsl:text> </xsl:text>
    <xsl:value-of select="i18n:translate('orcid.integration.confirmed.thanks')" />
    <xsl:text>, </xsl:text>
    <xsl:value-of select="i18n:translate('orcid.integration.confirmed.headline')" />
  </h3>
  <p>
    <xsl:value-of select="i18n:translate('orcid.integration.confirmed.text')" />
  </p>
  <xsl:if test="string-length(normalize-space(i18n:translate('orcid.integration.import'))) &gt; 0 and
                string-length(normalize-space(i18n:translate('orcid.integration.publish'))) &gt; 0">
    <ul style="margin-top:1ex;">
      <li>
        <xsl:value-of select="i18n:translate('orcid.integration.import')" />
      </li>
      <li>
        <xsl:value-of select="i18n:translate('orcid.integration.publish')" />
      </li>
    </ul>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>
