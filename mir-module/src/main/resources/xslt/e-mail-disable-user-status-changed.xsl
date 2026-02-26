<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:include href="resource:xslt/default-parameters.xsl" />
  <xsl:include href="xslInclude:functions" />

  <xsl:param name="MCR.mir-module.MailSender"/>
  <xsl:param name="MCR.NameOfProject"/>

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
          <xsl:value-of select="
            mcri18n:translate('selfRegistration.step.disableUserChanged.email.user.enabled.subject')
          " />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="
            mcri18n:translate('selfRegistration.step.disableUserChanged.email.user.disabled.subject')
          " />
        </xsl:otherwise>
      </xsl:choose>
    </subject>
    <body>
      <xsl:value-of select="mcri18n:translate('selfRegistration.user.contacting')" />
      <xsl:value-of select="$newline" />
      <xsl:value-of select="$newline"/>

      <xsl:choose>
        <xsl:when test="@disabled='false'">
          <xsl:value-of select="
            mcri18n:translate('selfRegistration.step.disableUserChanged.email.user.enabled.info')
          "/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="
            mcri18n:translate('selfRegistration.step.disableUserChanged.email.user.disabled.info')
          " />
        </xsl:otherwise>
      </xsl:choose>
      <xsl:value-of select="$newline"/>

      <!-- User ID -->
      <xsl:value-of select="mcri18n:translate('selfRegistration.step.disableUserChanged.email.user.info.userId')"/>
      <xsl:value-of select="concat(@name,' (',@realm,')',$newline)"/>
      <!-- Name -->
      <xsl:if test="realName">
        <xsl:value-of select="mcri18n:translate('selfRegistration.step.disableUserChanged.email.user.info.name')"/>
        <xsl:value-of select="concat(realName,$newline)"/>
      </xsl:if>
      <!-- Email -->
      <xsl:value-of select="mcri18n:translate('selfRegistration.step.disableUserChanged.email.user.info.mail')"/>
      <xsl:value-of select="concat(eMail,$newline)"/>
      <xsl:if test="@disabled='false'">
        <!-- Link -->
        <xsl:value-of select="mcri18n:translate('selfRegistration.step.disableUserChanged.email.user.info.link')"/>
        <xsl:value-of select="concat($ServletsBaseURL,'MCRUserServlet?action=show&amp;id=',@name,'@',@realm,$newline)"/>
        <xsl:value-of select="$newline"/>
      </xsl:if>
      <xsl:value-of select="$newline" />
      <xsl:value-of select="mcri18n:translate('selfRegistration.user.goodbye', $MCR.NameOfProject)"/>
      <xsl:value-of select="$newline" />
    </body>
  </xsl:template>

</xsl:stylesheet>
