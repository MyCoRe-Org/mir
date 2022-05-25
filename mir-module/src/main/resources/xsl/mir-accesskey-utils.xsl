<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:import href="accesskey.xsl" />
  <xsl:param name="MCR.ACL.AccessKey.Strategy.AllowedObjectTypes" />
  <xsl:param name="MCR.ACL.AccessKey.Strategy.AllowedSessionPermissionTypes" />
  <xsl:param name="isAccessKeyForDerivateEnabled" select="contains($MCR.ACL.AccessKey.Strategy.AllowedObjectTypes, 'derivate')" />
  <xsl:param name="isReadAccessKeyForSessionEnabled" select="contains($MCR.ACL.AccessKey.Strategy.AllowedSessionPermissionTypes, 'read')" />
  <xsl:param name="isWriteAccessKeyForSessionEnabled" select="contains($MCR.ACL.AccessKey.Strategy.AllowedSessionPermissionTypes, 'writedb')" />
  <xsl:param name="isAccessKeyForSessionEnabled" select="$isReadAccessKeyForSessionEnabled or $isWriteAccessKeyForSessionEnabled" />
  <xsl:param name="isAccessKeyForModsEnabled" select="contains($MCR.ACL.AccessKey.Strategy.AllowedObjectTypes, 'mods')" />
  <xsl:param name="isAccessKeyEnabled" select="$isAccessKeyForDerivateEnabled or $isAccessKeyForModsEnabled" />

  <xsl:template name="isCurrentUserAllowedToManageAccessKeys">
    <xsl:param name="typeId" />
    <xsl:choose>
      <xsl:when test="not(contains($MCR.ACL.AccessKey.Strategy.AllowedObjectTypes, $typeId))">
        <xsl:value-of select="false()" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="checkRestAccessKeyPathPermission">
          <xsl:with-param name="typeId" select="$typeId" />
          <xsl:with-param name="permission" select="'writedb'" />
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="isCurrentUserAllowedToSetAccessKey">
    <xsl:param name="typeId"/>
    <xsl:param name="isUserGuest">
      <xsl:value-of select="document('userobjectrights:isCurrentUserGuestUser:')/boolean" />
    </xsl:param>
    <xsl:variable name="isAllowed">
      <xsl:choose>
        <xsl:when test="not($typeId)">
          <xsl:value-of select="$isAccessKeyEnabled" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select= "contains($MCR.ACL.AccessKey.Strategy.AllowedObjectTypes, $typeId)" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$isAllowed='false'" >
        <xsl:value-of select="false()" />
      </xsl:when>
      <xsl:when test="$isUserGuest='false'">
        <xsl:value-of select="true()" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$isAccessKeyForSessionEnabled" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
