<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:miraccesskeyutil="http://www.mycore.de/xslt/miraccesskeyutil"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template match="action[@name='manage-access-keys']" mode="derivate-action">
    <xsl:param name="derivate-id" as="xs:string" tunnel="yes" />

    <xsl:if test="miraccesskeyutil:is-access-key-allowed($derivate-id)">
      <xsl:call-template name="print-manage-access-keys-menu-item">
        <xsl:with-param name="reference" select="$derivate-id" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
