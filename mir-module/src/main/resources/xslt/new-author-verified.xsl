<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mcrproperty="http://www.mycore.de/xslt/property"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:include href="resource:xslt/MyCoReLayout.xsl" />

  <xsl:param name="i18n-prefix" select="'selfRegistration.step.verified.'" />

  <xsl:variable name="PageTitle" select="mcri18n:translate($i18n-prefix || 'title')" />

  <xsl:template match="/new-author-verified">
    <h1>
      <xsl:value-of select="$PageTitle" />
    </h1>
    <p>
      <xsl:choose>
        <xsl:when test="lower-case(mcrproperty:one('MIR.SelfRegistration.EmailVerification.setDisabled')) = 'true'">
          <xsl:value-of select="mcri18n:translate($i18n-prefix || 'user.disabled.info')" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="mcri18n:translate($i18n-prefix || 'user.info.1') || ' '" />
          <b>
            <xsl:value-of select="user/eMail" />
          </b>
          <xsl:value-of select="' ' || mcri18n:translate($i18n-prefix || 'user.info.2')" />
          <a href="{$ServletsBaseURL || 'MCRLoginServlet?url=' || $WebApplicationBaseURL || 'content/index.xml'}">
            <xsl:value-of select="' ' || mcri18n:translate($i18n-prefix || 'user.info.3')" />
          </a>
          <xsl:value-of select="mcri18n:translate($i18n-prefix || 'user.info.4')" />
        </xsl:otherwise>
      </xsl:choose>
    </p>
  </xsl:template>

</xsl:stylesheet>
