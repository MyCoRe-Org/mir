<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcracl="http://www.mycore.de/xslt/acl"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:mode name="object-action" on-no-match="deep-skip" on-multiple-match="fail" />

  <xsl:template name="object-actions">
    <xsl:param name="names" as="xs:string*" />
    <xsl:param name="object" as="element(mycoreobject)" />
    <xsl:param name="genres" as="xs:string*" />
    <xsl:param name="mods-type" as="xs:string" />

    <xsl:variable name="write" select="mcracl:check-permission($object/@ID, 'writedb')" />
    <xsl:variable name="actions">
      <xsl:for-each select="$names">
        <action name="{.}" genres="{$genres}" />
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="edit-url" as="xs:string">
      <xsl:choose>
        <xsl:when test="$write">
          <xsl:variable name="url">
            <xsl:call-template name="mods.getObjectEditURL">
              <xsl:with-param name="id" select="string($object/@ID)" />
              <xsl:with-param name="layout" select="'$'" />
            </xsl:call-template>
          </xsl:variable>
          <xsl:sequence select="string($url)" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="''" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:apply-templates select="$actions/action" mode="object-action">
      <xsl:with-param name="object" select="$object" tunnel="yes" />
      <xsl:with-param name="object-id" select="string($object/@ID)" tunnel="yes" />
      <xsl:with-param name="mods-type" select="$mods-type" tunnel="yes" />
      <xsl:with-param name="edit-url" select="$edit-url" tunnel="yes" />
      <xsl:with-param name="write" select="$write" tunnel="yes" />
      <xsl:with-param name="delete" select="mcracl:check-permission($object/@ID, 'deletedb')" tunnel="yes" />
      <xsl:with-param name="guest" select="mcracl:is-current-user-guest-user()" tunnel="yes" />
    </xsl:apply-templates>
  </xsl:template>

</xsl:stylesheet>
