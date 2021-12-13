<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:encoder="xalan://java.net.URLEncoder"
  exclude-result-prefixes="i18n encoder">

  <xsl:include href="mir-accesskey-utils.xsl" />

  <xsl:param name="HttpSession" />
  <xsl:param name="RequestURL" select="bla" />
  <xsl:param name="WebApplicationBaseURL" />

  <xsl:template name="extractObjectIdFromRequestURL">
    <xsl:choose>
      <xsl:when test="contains($RequestURL, '/receive/')">
        <xsl:variable name="id" select="substring-after($RequestURL,'/receive/')" />
        <xsl:choose>
          <xsl:when test="contains($id, ';')">
            <xsl:value-of select="substring-before($id, ';')" />
          </xsl:when>
          <xsl:when test="contains($id, '?')">
            <xsl:value-of select="substring-before($id, '?')" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$id" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="''" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="displayLogin">
    <xsl:variable name="loginURL" select="concat($ServletsBaseURL, 'MCRLoginServlet', $HttpSession,'?url=', encoder:encode(string($RequestURL)))" />
    <br></br>
    <xsl:value-of disable-output-escaping="yes" select="i18n:translate('mir.loginRequiredInfo', $loginURL)" />
  </xsl:template>

  <xsl:template name="displaySetAccessKey">
    <xsl:param name="objectId" />
    <xsl:variable name="loginURL" select="concat($WebApplicationBaseURL, 'accesskey/set.xed', '?objId=', $objectId, '&amp;url=', encoder:encode(string($RequestURL)))" />
    <br></br>
    <xsl:value-of disable-output-escaping="yes" select="i18n:translate('mir.accesskey.setInfo', $loginURL)" />
  </xsl:template>

  <xsl:template name="mir.printNotLoggedIn">
    <xsl:param name="objectId">
      <xsl:call-template name="extractObjectIdFromRequestURL" />
    </xsl:param>
    <xsl:param name="isUserGuest" select="document('userobjectrights:isCurrentUserGuestUser:')/boolean" />
    <div class="alert alert-danger">
      <h1>
        <xsl:value-of select="i18n:translate('mir.error.headline.401')" />
      </h1>
      <p>
        <xsl:value-of disable-output-escaping="yes" select="i18n:translate('mir.error.codes.401')" />
        <xsl:if test="$isUserGuest='true'">
          <xsl:call-template name="displayLogin" />
        </xsl:if>
        <xsl:variable name="typeId">
          <xsl:call-template name="getTypeId">
            <xsl:with-param name="objectId" select="$objectId" />
          </xsl:call-template>
        </xsl:variable>
        <xsl:if test="$typeId!='' and $isAccessKeyEnabled='true'">
          <xsl:variable name="isSetAllowed">
            <xsl:call-template name="isCurrentUserAllowedToSetAccessKey">
              <xsl:with-param name="typeId" select="$typeId" />
            </xsl:call-template>
          </xsl:variable>
          <xsl:if test="$isSetAllowed='true'">
            <xsl:call-template name="displaySetAccessKey">
              <xsl:with-param name="objectId" select="$objectId" />
            </xsl:call-template>
          </xsl:if>
        </xsl:if>
      </p>
    </div>
  </xsl:template>

  <xsl:template name="getTypeId">
    <xsl:param name="objectId" />
    <xsl:choose>
      <xsl:when test="contains($objectId, '_derivate_')">
        <xsl:value-of select="'derivate'" />
      </xsl:when>
      <xsl:when test="contains($objectId, '_mods')">
        <xsl:value-of select="'mods'" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="''" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
