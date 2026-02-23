<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:mcri18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="mcri18n xlink">

<xsl:variable name="PageTitle" select="mcri18n:translate('selfRegistration.step.created.title')" />

  <xsl:template match="/new-author-created">
    <h1>
      <xsl:value-of select="mcri18n:translate('selfRegistration.step.created.title')" />
    </h1>
    <p>
      <xsl:value-of select="mcri18n:translate('selfRegistration.step.created.info', user/eMail)" disable-output-escaping="yes" />
    </p>
  </xsl:template>
  <xsl:include href="MyCoReLayout.xsl" />
</xsl:stylesheet>
