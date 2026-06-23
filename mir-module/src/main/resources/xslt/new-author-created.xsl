<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:include href="resource:xslt/MyCoReLayout.xsl" />

  <xsl:param name="i18n-prefix" select="'selfRegistration.step.created.'" />

  <xsl:variable name="PageTitle" select="mcri18n:translate($i18n-prefix || 'title')" />

  <xsl:template match="/new-author-created">
    <h1>
      <xsl:value-of select="$PageTitle" />
    </h1>
    <p>
      <xsl:value-of select="mcri18n:translate($i18n-prefix || 'info.1') || ' '" />
      <b>
        <xsl:value-of select="user/eMail" />
      </b>
      <xsl:value-of select="' ' || mcri18n:translate($i18n-prefix || 'info.2')" />
      <br />
      <xsl:value-of select="mcri18n:translate($i18n-prefix || 'info.3')" />
    </p>
  </xsl:template>

</xsl:stylesheet>
