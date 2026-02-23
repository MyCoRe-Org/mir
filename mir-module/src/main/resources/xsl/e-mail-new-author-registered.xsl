<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:mcri18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="mcri18n">

  <xsl:param name="DefaultLang"/>
  <xsl:param name="WebApplicationBaseURL"/>
  <xsl:param name="ServletsBaseURL"/>
  <xsl:param name="MCR.mir-module.NewUserMail"/>
  <xsl:param name="MCR.mir-module.MailSender"/>
  <xsl:param name="MIR.SelfRegistration.EmailVerification.setDisabled"/>
  <xsl:variable name="newline" select="'&#xA;'"/>

  <xsl:template match="/">
    <email>
      <from>
        <xsl:value-of select="$MCR.mir-module.MailSender"/>
      </from>
      <xsl:apply-templates select="/*" mode="email"/>
    </email>
  </xsl:template>

  <xsl:template match="user" mode="email">
    <to>
      <xsl:value-of select="$MCR.mir-module.NewUserMail"/>
    </to>
    <subject>
      <xsl:value-of select="mcri18n:translate('selfRegistration.step.created.email.admin.subject', concat(@name,' (',@realm,')'))"/>
    </subject>
    <body>
      <xsl:value-of select="mcri18n:translate('selfRegistration.step.created.email.admin.info')"/>
      <xsl:value-of select="$newline"/>
      <xsl:value-of select="$newline"/>
      <!-- User ID -->
      <xsl:value-of select="mcri18n:translate('selfRegistration.step.created.email.admin.info.userId')"/>
      <xsl:value-of select="concat(@name,' (',@realm,')',$newline)"/>
      <!-- Name -->
      <xsl:if test="realName">
        <xsl:value-of select="mcri18n:translate('selfRegistration.step.created.email.admin.info.name')"/>
        <xsl:value-of select="concat(realName,$newline)"/>
      </xsl:if>
      <!-- Email -->
      <xsl:if test="eMail">
        <xsl:value-of select="mcri18n:translate('selfRegistration.step.created.email.admin.info.mail')"/>
        <xsl:value-of select="concat(eMail,$newline)"/>
      </xsl:if>
      <!-- Link -->
      <xsl:value-of select="mcri18n:translate('selfRegistration.step.created.email.admin.info.link')"/>
      <xsl:value-of select="concat($ServletsBaseURL,'MCRUserServlet?action=show&amp;id=',@name,'@',@realm,$newline)"/>
      <xsl:value-of select="$newline"/>
      <xsl:choose>
        <xsl:when
          test="$MIR.SelfRegistration.EmailVerification.setDisabled = 'true' or  $MIR.SelfRegistration.EmailVerification.setDisabled = 'TRUE'">
          <xsl:value-of select="mcri18n:translate('selfRegistration.step.created.email.admin.info.forDisabled')"/>
          <xsl:value-of select="$newline"/>
        </xsl:when>
      </xsl:choose>
    </body>
  </xsl:template>
</xsl:stylesheet>
