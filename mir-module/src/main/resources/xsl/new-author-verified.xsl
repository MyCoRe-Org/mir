<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:mcri18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="mcri18n xlink">

  <xsl:param name="MIR.SelfRegistration.EmailVerification.setDisabled"/>
  <xsl:variable name="PageTitle" select="mcri18n:translate('selfRegistration.step.verified.title')" />

  <xsl:template match="/new-author-verified">
    <h1>
      <xsl:value-of select="mcri18n:translate('selfRegistration.step.verified.title')" />
    </h1>
    <p>
      <xsl:choose>
        <xsl:when
                test="$MIR.SelfRegistration.EmailVerification.setDisabled = 'true' or  $MIR.SelfRegistration.EmailVerification.setDisabled = 'TRUE'">
          <xsl:value-of
                  select="mcri18n:translate('selfRegistration.step.verified.user.disabled.info')"
                  disable-output-escaping="yes" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of
                  select="mcri18n:translate('selfRegistration.step.verified.user.info', concat(user/eMail, ';', concat($ServletsBaseURL, 'MCRLoginServlet?url=', $WebApplicationBaseURL, 'content/index.xml')))"
                  disable-output-escaping="yes" />
        </xsl:otherwise>
      </xsl:choose>
    </p>
  </xsl:template>
  <xsl:include href="MyCoReLayout.xsl" />
</xsl:stylesheet>
