<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  exclude-result-prefixes="i18n xlink"
>
  <xsl:variable name="PageTitle" select="i18n:translate('selfRegistration.title.created')" />

  <xsl:template match="/new-author-created">
    <h1>
      <xsl:value-of select="i18n:translate('selfRegistration.title.created')" />
    </h1>
    <p>
      Es wurde eine Mail an Ihre eMail-Adresse
      <b>
        <xsl:value-of select="user/eMail" />
      </b>
      gesendet um diese zu validieren.
      <br />
      Bitte benutzen Sie den darin enthaltenen Link um die Registrierung abzuschliessen.
    </p>
  </xsl:template>
  <xsl:include href="MyCoReLayout.xsl" />
</xsl:stylesheet>
