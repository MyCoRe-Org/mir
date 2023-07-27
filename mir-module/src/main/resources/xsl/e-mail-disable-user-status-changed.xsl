<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0"
                xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
                exclude-result-prefixes="i18n">
  <xsl:param name="DefaultLang"/>
  <xsl:param name="WebApplicationBaseURL"/>
  <xsl:param name="ServletsBaseURL"/>
  <xsl:param name="MCR.mir-module.MailSender"/>
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
      <xsl:value-of select="eMail/text()"/>
    </to>
    <subject>
      <xsl:choose>
        <xsl:when test="@disabled='false'">
          <xsl:value-of select="i18n:translate('selfRegistration.step.disableUserChanged.email.user.enabled.subject')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="i18n:translate('selfRegistration.step.disableUserChanged.email.user.disabled.subject')"/>
        </xsl:otherwise>
      </xsl:choose>
    </subject>
    <body>
      <xsl:choose>
        <xsl:when test="@disabled='false'">
          <xsl:value-of select="i18n:translate('selfRegistration.step.disableUserChanged.email.user.enabled.subject')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="i18n:translate('selfRegistration.step.disableUserChanged.email.user.disabled.subject')"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:value-of select="$newline"/>

      <!-- User ID -->
      <xsl:value-of select="i18n:translate('selfRegistration.step.disableUserChanged.email.user.info.userId')"/>
      <xsl:value-of select="concat(@name,' (',@realm,')',$newline)"/>
      <!-- Name -->
      <xsl:value-of select="i18n:translate('selfRegistration.step.disableUserChanged.email.user.info.name')"/>
      <xsl:value-of select="concat(realName,$newline)"/>
      <!-- Email -->
      <xsl:value-of select="i18n:translate('selfRegistration.step.disableUserChanged.email.user.info.mail')"/>
      <xsl:value-of select="concat(eMail,$newline)"/>
      <xsl:if test="@disabled='false'">
        <!-- Link -->
        <xsl:value-of select="i18n:translate('selfRegistration.step.disableUserChanged.email.user.info.link')"/>
        <xsl:value-of select="concat($ServletsBaseURL,'MCRUserServlet?action=show&amp;id=',@name,'@',@realm,$newline)"/>
        <xsl:value-of select="$newline"/>
      </xsl:if>
    </body>
  </xsl:template>
</xsl:stylesheet>
