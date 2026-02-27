<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:include href="resource:xslt/default-parameters.xsl" />
  <xsl:include href="xslInclude:functions" />

  <xsl:param name="MCR.mir-module.MailSender" />
  <xsl:param name="MIR.SelfRegistration.EmailVerification.setDisabled"/>
  <xsl:param name="MCR.NameOfProject"/>

  <xsl:variable name="newline" select="'&#xA;'" />

  <xsl:template match="/">
    <email>
      <from>
        <xsl:value-of select="$MCR.mir-module.MailSender" />
      </from>
      <xsl:apply-templates select="/*" mode="email" />
    </email>
  </xsl:template>

  <xsl:template match="user" mode="email">
    <to>
      <xsl:value-of select="eMail/text()" />
    </to>
    <subject>
      <xsl:value-of select="mcri18n:translate('selfRegistration.step.created.email.user.subject')"/>
    </subject>
    <body>
      <xsl:value-of select="mcri18n:translate('selfRegistration.user.contacting')"/>
      <xsl:value-of select="$newline" />
      <xsl:value-of select="$newline" />

      <xsl:choose>
        <xsl:when test="
          $MIR.SelfRegistration.EmailVerification.setDisabled = 'true'
          or  $MIR.SelfRegistration.EmailVerification.setDisabled = 'TRUE'
        ">
          <xsl:value-of select="mcri18n:translate('selfRegistration.step.created.email.user.disabled.info.0')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="mcri18n:translate('selfRegistration.step.created.email.user.info.0')"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:value-of select="$newline" />

      <xsl:value-of select="mcri18n:translate('selfRegistration.step.created.email.user.info.1')"/>
      <xsl:value-of select="$newline" />
      <xsl:value-of select="
        concat(
          $ServletsBaseURL,
          'MirSelfRegistrationServlet?action=verify&amp;user=',
          @name,
          '&amp;realm=',
          @realm,
          '&amp;token=',
          attributes/attribute[@name='mailtoken']/@value
        )
      " />
      <xsl:value-of select="$newline" />

      <xsl:choose>
        <xsl:when test="
          $MIR.SelfRegistration.EmailVerification.setDisabled = 'true'
          or  $MIR.SelfRegistration.EmailVerification.setDisabled = 'TRUE'
        ">
          <xsl:value-of select="mcri18n:translate('selfRegistration.step.created.email.user.disabled.info.1')"/>
          <xsl:value-of select="$newline" />
        </xsl:when>
      </xsl:choose>
      <xsl:value-of select="$newline" />
      <xsl:value-of select="mcri18n:translate('selfRegistration.user.goodbye', $MCR.NameOfProject)"/>
      <xsl:value-of select="$newline" />
    </body>
  </xsl:template>

</xsl:stylesheet>
