<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0"
                xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
                exclude-result-prefixes="i18n">
  <xsl:param name="DefaultLang" />
  <xsl:param name="WebApplicationBaseURL" />
  <xsl:param name="ServletsBaseURL" />
  <xsl:param name="MCR.mir-module.MailSender" />
  <xsl:param name="MIR.SelfRegistration.EmailVerification.setDisabled"/>
  <xsl:variable name="newline" select="'&#xA;'" />

  <xsl:template match="/">
    <email>
      <from><xsl:value-of select="$MCR.mir-module.MailSender" /></from>
      <xsl:apply-templates select="/*" mode="email" />
    </email>
  </xsl:template>

  <xsl:template match="user" mode="email">
    <to>
      <xsl:value-of select="eMail/text()" />
    </to>
    <subject>
      <xsl:value-of select="i18n:translate('selfRegistration.step.created.email.user.subject')"/>
    </subject>
    <body>

      <xsl:choose>
        <xsl:when
            test="$MIR.SelfRegistration.EmailVerification.setDisabled = 'true' or  $MIR.SelfRegistration.EmailVerification.setDisabled = 'TRUE'">
          <xsl:value-of select="i18n:translate('selfRegistration.step.created.email.user.disabled.info.0')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="i18n:translate('selfRegistration.step.created.email.user.info.0')"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:value-of select="$newline" />

      <xsl:value-of select="i18n:translate('selfRegistration.step.created.email.user.info.1')"/>
      <xsl:value-of select="$newline" />
      <xsl:value-of
        select="concat($ServletsBaseURL, 'MirSelfRegistrationServlet?action=verify&amp;user=', @name, '&amp;realm=',@realm, '&amp;token=', attributes/attribute[@name='mailtoken']/@value)" />
      <xsl:value-of select="$newline" />

      <xsl:choose>
        <xsl:when
            test="$MIR.SelfRegistration.EmailVerification.setDisabled = 'true' or  $MIR.SelfRegistration.EmailVerification.setDisabled = 'TRUE'">
          <xsl:value-of select="i18n:translate('selfRegistration.step.created.email.user.disabled.info.1')"/>
        </xsl:when>
      </xsl:choose>

    </body>
  </xsl:template>
</xsl:stylesheet>
