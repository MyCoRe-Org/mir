<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mirorcidutil="http://www.mycore.de/xslt/mirorcidutil"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template match="action[@name='orcid-export']" mode="result-action">
    <xsl:param name="doc" as="element(doc)" tunnel="yes" />
    <xsl:param name="object-id" as="xs:string" tunnel="yes" />

    <xsl:if test="mirorcidutil:is-orcid-enabled()">
      <xsl:variable name="current-user" select="document('user:current')/user" />
      <xsl:variable name="object-name-ids" select="$doc/arr[@name='mods.nameIdentifier']/str/string()" />

      <xsl:call-template name="render-export-to-orcid-menu-item">
        <xsl:with-param name="object-id" select="$object-id" />
        <xsl:with-param name="disabled" select="
          not(mirorcidutil:is-publishable-state($doc/str[@name='state']))
          or not(mirorcidutil:has-trusted-matching-id($current-user, $object-name-ids))
          or not(mirorcidutil:has-orcid-credential($current-user))
        " />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
