<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mcrproperty="http://www.mycore.de/xslt/property"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:include href="resource:xslt/default-parameters.xsl" />
  <xsl:include href="xslInclude:functions" />

  <xsl:variable name="i18n-prefix" select="'selfRegistration.step.verified.email.admin.'" />
  <xsl:variable name="newline" select="'&#xA;'" />
  <xsl:variable name="email-verification" select="
    lower-case(mcrproperty:one('MIR.SelfRegistration.EmailVerification.setDisabled')) = 'false'
  " />
  <xsl:variable name="unlock-via-admin-link" select="
    lower-case(mcrproperty:one('MIR.SelfRegistration.DisabledStatus.UnlockViaAdminLink')) = 'true'
  " />

  <xsl:template match="/">
    <email>
      <from>
        <xsl:value-of select="mcrproperty:one('MCR.mir-module.MailSender')" />
      </from>
      <xsl:apply-templates select="/*" mode="email" />
    </email>
  </xsl:template>

  <xsl:template match="user" mode="email">
    <to>
      <xsl:value-of select="mcrproperty:one('MCR.mir-module.NewUserMail')" />
    </to>
    <xsl:variable name="name" select="@name || ' (' || @realm || ')'" />
    <subject>
      <xsl:value-of select="mcri18n:translate-with-params($i18n-prefix || 'subject', $name)" />
    </subject>
    <body>
      <xsl:value-of select="mcri18n:translate($i18n-prefix || 'info')" />
      <xsl:value-of select="$newline" />
      <xsl:value-of select="$newline" />
      <xsl:value-of select="mcri18n:translate($i18n-prefix || 'info.userId')" />
      <xsl:value-of select="$name || $newline" />
      <xsl:if test="realName">
        <xsl:value-of select="mcri18n:translate($i18n-prefix || 'info.name')" />
        <xsl:value-of select="realName || $newline" />
      </xsl:if>
      <xsl:value-of select="mcri18n:translate($i18n-prefix || 'info.mail')" />
      <xsl:value-of select="eMail || $newline" />
      <xsl:value-of select="mcri18n:translate($i18n-prefix || 'info.link')" />
      <xsl:value-of select="concat($ServletsBaseURL,'MCRUserServlet?action=show&amp;id=',@name,'@',@realm,$newline)" />
      <xsl:value-of select="$newline" />

      <xsl:choose>
        <xsl:when test="not($email-verification) and not($unlock-via-admin-link)">
          <xsl:value-of select="mcri18n:translate($i18n-prefix || 'info.forDisabled')" />
          <xsl:value-of select="$newline" />
        </xsl:when>
        <xsl:when test="not($email-verification) and $unlock-via-admin-link">
          <xsl:value-of select="mcri18n:translate($i18n-prefix || 'info.forDisabled.UnlockViaAdminLink')" />
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
