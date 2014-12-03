<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  exclude-result-prefixes="i18n xlink"
>
  <xsl:variable name="PageTitle" select="i18n:translate('selfRegistration.title.verified')" />

  <xsl:template match="/new-author-verified">
    <h1>
      <xsl:value-of select="i18n:translate('selfRegistration.title.verified')" />
    </h1>
    <p>
      Danke für die Bestätigung Ihrer E-Mail Adresse! Sie können sich nun mit Ihrer eingerichteten Benutzerkennung (
      <xsl:value-of select="user/@name" />
      ) anmelden!
    </p>
  </xsl:template>
  <xsl:include href="MyCoReLayout.xsl" />
</xsl:stylesheet>
