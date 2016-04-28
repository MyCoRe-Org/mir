<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  exclude-result-prefixes="i18n xlink"
>
  <xsl:variable name="PageTitle" select="i18n:translate('selfRegistration.step.verified.title')" />

  <xsl:template match="/new-author-verified">
    <h1>
      <xsl:value-of select="i18n:translate('selfRegistration.step.verified.title')" />
    </h1>
    <p>
      <xsl:value-of
        select="i18n:translate('selfRegistration.step.verified.info', concat(user/eMail, ';', concat($ServletsBaseURL, 'MCRLoginServlet?url=', $WebApplicationBaseURL, 'content/index.xml')))"
        disable-output-escaping="yes" />
    </p>
  </xsl:template>
  <xsl:include href="MyCoReLayout.xsl" />
</xsl:stylesheet>
