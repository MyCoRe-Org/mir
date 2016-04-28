<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  exclude-result-prefixes="i18n xlink"
>
  <xsl:variable name="PageTitle" select="i18n:translate('selfRegistration.step.created.title')" />

  <xsl:template match="/new-author-created">
    <h1>
      <xsl:value-of select="i18n:translate('selfRegistration.step.created.title')" />
    </h1>
    <p>
      <xsl:value-of select="i18n:translate('selfRegistration.step.created.info', user/eMail)" disable-output-escaping="yes" />
    </p>
  </xsl:template>
  <xsl:include href="MyCoReLayout.xsl" />
</xsl:stylesheet>
