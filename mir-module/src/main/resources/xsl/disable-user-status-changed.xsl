<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
                exclude-result-prefixes="i18n xlink"
>
  <xsl:param name="ServletsBaseURL"/>
  <xsl:variable name="PageTitle" select="i18n:translate('selfRegistration.step.disableUserChanged.title')"/>

  <xsl:template match="/disable-user-status-changed">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="user">
    <h1>
      <xsl:choose>
        <xsl:when test="@disabled='false'">
          <xsl:value-of select="i18n:translate('selfRegistration.step.disableUserChanged.info.enabled')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="i18n:translate('selfRegistration.step.disableUserChanged.info.disabled')"/>
        </xsl:otherwise>
      </xsl:choose>
    </h1>

    <p>
      <!-- User ID -->
      <xsl:value-of select="i18n:translate('selfRegistration.step.disableUserChanged.email.user.info.userId')"/>
      <xsl:value-of select="concat(@name,' (',@realm,')')"/>
      <br/>
      <!-- Name -->
      <xsl:if test="realName">
        <xsl:value-of select="i18n:translate('selfRegistration.step.disableUserChanged.email.user.info.name')"/>
        <xsl:value-of select="realName"/>
        <br/>
      </xsl:if>
      <!-- Email -->
      <xsl:if test="eMail">
        <xsl:value-of select="i18n:translate('selfRegistration.step.disableUserChanged.email.user.info.mail')"/>
        <xsl:value-of select="eMail"/>
        <br/>
      </xsl:if>
      <!-- Link -->
      <xsl:value-of select="i18n:translate('selfRegistration.step.disableUserChanged.email.user.info.link')"/>
      <xsl:element name="a">
        <xsl:attribute name="href">
          <xsl:value-of select="concat($ServletsBaseURL,'MCRUserServlet?action=show&amp;id=',@name,'@',@realm)"/>
        </xsl:attribute>
        <xsl:value-of select="concat($ServletsBaseURL,'MCRUserServlet?action=show&amp;id=',@name,'@',@realm)"/>
      </xsl:element>
      <br/>
    </p>
  </xsl:template>
  <xsl:include href="MyCoReLayout.xsl"/>
</xsl:stylesheet>
