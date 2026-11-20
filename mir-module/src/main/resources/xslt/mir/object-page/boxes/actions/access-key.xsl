<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:miraccesskeyutil="http://www.mycore.de/xslt/miraccesskeyutil"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template match="action[@name='manage-access-keys']" mode="object-action">
    <xsl:param name="object-id" as="xs:string" tunnel="yes" />
    <xsl:param name="write" as="xs:boolean" tunnel="yes" />
    <xsl:param name="guest" as="xs:boolean" tunnel="yes" />

    <xsl:if test="(not($guest) or $write) and miraccesskeyutil:is-access-key-allowed($object-id)">
      <xsl:call-template name="print-manage-access-keys-menu-item">
        <xsl:with-param name="reference" select="$object-id" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="action[@name='set-access-key']" mode="object-action">
    <xsl:param name="object-id" as="xs:string" tunnel="yes" />
    <xsl:param name="write" as="xs:boolean" tunnel="yes" />
    <xsl:param name="delete" as="xs:boolean" tunnel="yes" />

    <xsl:if test="not($write or $delete) and miraccesskeyutil:can-current-user-redeem-access-key($object-id)">
      <xsl:call-template name="print-set-access-key-menu-item">
        <xsl:with-param name="reference" select="$object-id" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
