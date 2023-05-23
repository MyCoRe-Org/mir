<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
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
      Ihre Benutzerkennung wurde angelegt!
    </subject>
    <body>

      <xsl:choose>
        <xsl:when
                test="$MIR.SelfRegistration.EmailVerification.setDisabled = 'true' or  $MIR.SelfRegistration.EmailVerification.setDisabled = 'TRUE'">
          <xsl:text>Ihre Benutzerkennung wurde angelegt, aber zunächst gesperrt.</xsl:text>
          <xsl:value-of select="$newline" />
        </xsl:when>
      </xsl:choose>

      <xsl:text>Bitte benutzen Sie folgenden Link, um ihre E-Mail-Adresse zu bestätigen.</xsl:text>
      <xsl:value-of select="$newline" />
      <xsl:value-of
        select="concat('&lt;', $ServletsBaseURL, 'MirSelfRegistrationServlet?action=verify&amp;user=', @name, '&amp;realm=', @realm, '&amp;token=', attributes/attribute[@name='mailtoken']/@value, '&gt;')" />
      <xsl:value-of select="$newline" />

      <xsl:choose>
        <xsl:when
                test="$MIR.SelfRegistration.EmailVerification.setDisabled = 'true' or  $MIR.SelfRegistration.EmailVerification.setDisabled = 'TRUE'">
          <xsl:text>Sobald Sie Ihre E-Mail-Adresse bestätigt haben, wird Ihre Benutzerkennung von einem Administrator der Anwendung überprüft.</xsl:text>
          <xsl:text> Erwarten Sie eine E-Mail vom Administrator der Anwendung.</xsl:text>
        </xsl:when>
      </xsl:choose>

    </body>
  </xsl:template>
</xsl:stylesheet>
