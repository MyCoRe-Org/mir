<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:include href="resource:xslt/default-parameters.xsl" />
  <xsl:include href="xslInclude:functions" />

  <xsl:param name="MCR.mir-module.NewUserMail"/>
  <xsl:param name="MCR.mir-module.MailSender"/>
  <xsl:param name="MIR.SelfRegistration.EmailVerification.setDisabled"/>
  <xsl:param name="MIR.SelfRegistration.DisabledStatus.UnlockViaAdminLink"/>

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
      <xsl:value-of select="
        mcri18n:translate('selfRegistration.step.verified.email.admin.subject', concat(@name,' (',@realm,')'))
      " />
    </subject>
    <body>
      <xsl:value-of select="mcri18n:translate('selfRegistration.step.verified.email.admin.info')"/>
      <xsl:value-of select="$newline"/>
      <xsl:value-of select="$newline"/>
      <!-- User ID -->
      <xsl:value-of select="mcri18n:translate('selfRegistration.step.verified.email.admin.info.userId')"/>
      <xsl:value-of select="concat(@name,' (',@realm,')',$newline)"/>
      <!-- Name -->
      <xsl:if test="realName">
        <xsl:value-of select="mcri18n:translate('selfRegistration.step.verified.email.admin.info.name')"/>
        <xsl:value-of select="concat(realName,$newline)"/>
      </xsl:if>
      <!-- Email -->
      <xsl:value-of select="mcri18n:translate('selfRegistration.step.verified.email.admin.info.mail')"/>
      <xsl:value-of select="concat(eMail,$newline)"/>
      <!-- Link -->
      <xsl:value-of select="mcri18n:translate('selfRegistration.step.verified.email.admin.info.link')"/>
      <xsl:value-of select="concat($ServletsBaseURL,'MCRUserServlet?action=show&amp;id=',@name,'@',@realm,$newline)"/>
      <xsl:value-of select="$newline"/>

      <xsl:choose>
        <xsl:when test="
          (
            $MIR.SelfRegistration.EmailVerification.setDisabled = 'true'
            or  $MIR.SelfRegistration.EmailVerification.setDisabled = 'TRUE'
          )
          and (
            $MIR.SelfRegistration.DisabledStatus.UnlockViaAdminLink = 'false'
            or $MIR.SelfRegistration.DisabledStatus.UnlockViaAdminLink = 'FALSE'
          )
        ">
          <xsl:value-of select="mcri18n:translate('selfRegistration.step.verified.email.admin.info.forDisabled')"/>
          <xsl:value-of select="$newline"/>
        </xsl:when>
        <xsl:when test="
          (
            $MIR.SelfRegistration.EmailVerification.setDisabled = 'true'
            or  $MIR.SelfRegistration.EmailVerification.setDisabled = 'TRUE'
          )
          and (
            $MIR.SelfRegistration.DisabledStatus.UnlockViaAdminLink = 'true'
            or $MIR.SelfRegistration.DisabledStatus.UnlockViaAdminLink = 'TRUE'
          )
        ">
          <xsl:value-of select="
            mcri18n:translate('selfRegistration.step.verified.email.admin.info.forDisabled.UnlockViaAdminLink')
          "/>
          <xsl:value-of select="$newline" />
          <xsl:value-of select="
            concat(
              $ServletsBaseURL,
              'MirSelfRegistrationServlet?action=changeDisableUserStatus&amp;user=',
              @name,
              '&amp;realm=',
              @realm,
              '&amp;disabled=false'
            )
          " />
          <xsl:value-of select="$newline" />
        </xsl:when>
      </xsl:choose>
    </body>
  </xsl:template>

</xsl:stylesheet>
