<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcracl="http://www.mycore.de/xslt/acl"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:param name="MCR.ACL.AccessKey.Strategy.AllowedObjectTypes" />
  <xsl:param name="MCR.ACL.AccessKey.Strategy.AllowedSessionPermissionTypes" />
  <xsl:param name="isAccessKeyForDerivateEnabled" select="contains($MCR.ACL.AccessKey.Strategy.AllowedObjectTypes, 'derivate')" />
  <xsl:param name="isReadAccessKeyForSessionEnabled" select="contains($MCR.ACL.AccessKey.Strategy.AllowedSessionPermissionTypes, 'read')" />
  <xsl:param name="isWriteAccessKeyForSessionEnabled" select="contains($MCR.ACL.AccessKey.Strategy.AllowedSessionPermissionTypes, 'writedb')" />
  <xsl:param name="isAccessKeyForSessionEnabled" select="$isReadAccessKeyForSessionEnabled or $isWriteAccessKeyForSessionEnabled" />
  <xsl:param name="isAccessKeyForModsEnabled" select="contains($MCR.ACL.AccessKey.Strategy.AllowedObjectTypes, 'mods')" />
  <xsl:param name="isAccessKeyEnabled" select="$isAccessKeyForDerivateEnabled or $isAccessKeyForModsEnabled" />

  <xsl:template name="isCurrentUserAllowedToSetAccessKey">
    <xsl:param name="typeId" as="xs:string" select="''" />
    <xsl:param name="isUserGuest" as="xs:boolean" select="mcracl:is-current-user-guest-user()" />

    <xsl:variable name="isAllowed" as="xs:boolean" select="
      if ($typeId = '') then $isAccessKeyEnabled
      else contains($MCR.ACL.AccessKey.Strategy.AllowedObjectTypes, $typeId)
    " />

    <xsl:choose>
      <xsl:when test="not($isAllowed)" >
        <xsl:value-of select="false()" />
      </xsl:when>
      <xsl:when test="not($isUserGuest)">
        <xsl:value-of select="true()" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$isAccessKeyForSessionEnabled" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
