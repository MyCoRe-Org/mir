<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:include href="resource:xslt/MyCoReLayout.xsl" />

  <xsl:param name="i18n-prefix" select="'selfRegistration.step.disableUserChanged.'" />

  <xsl:variable name="PageTitle" select="mcri18n:translate($i18n-prefix || 'title')" />

  <xsl:template match="/disable-user-status-changed">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="user">
    <h1>
      <xsl:value-of select="$PageTitle" />
    </h1>
    <p>
      <xsl:value-of select="mcri18n:translate($i18n-prefix || 'email.user.info.userId')" />
      <xsl:value-of select="@name || ' (' || @realm || ')'" />
      <br />
      <xsl:if test="realName">
        <xsl:value-of select="mcri18n:translate($i18n-prefix || 'email.user.info.name')" />
        <xsl:value-of select="realName" />
        <br />
      </xsl:if>
      <xsl:if test="eMail">
        <xsl:value-of select="mcri18n:translate($i18n-prefix || 'email.user.info.mail')" />
        <xsl:value-of select="eMail" />
        <br />
      </xsl:if>
      <xsl:value-of select="mcri18n:translate($i18n-prefix || 'email.user.info.link')" />
      <xsl:variable name="url" select="
        $ServletsBaseURL || 'MCRUserServlet?action=show&amp;id=' || @name || '@' || @realm
      " />
      <a href="{$url}">
        <xsl:value-of select="$url" />
      </a>
      <br />
    </p>
  </xsl:template>

</xsl:stylesheet>
