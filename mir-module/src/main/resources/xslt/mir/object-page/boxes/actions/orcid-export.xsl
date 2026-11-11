<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mirorcidutil="http://www.mycore.de/xslt/mirorcidutil"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template match="action[@name='orcid-export']" mode="object-action">
    <xsl:param name="object" as="element(mycoreobject)" tunnel="yes" />
    <xsl:param name="object-id" as="xs:string" tunnel="yes" />
    <xsl:param name="guest" as="xs:boolean" tunnel="yes" />

    <xsl:if test="not($guest) and mirorcidutil:is-orcid-enabled()">
      <xsl:variable name="current-user" select="document('user:current')/user" />
      <xsl:variable name="state" select="$object/service/servstates/servstate[@classid='state']/@categid" />

      <xsl:call-template name="render-export-to-orcid-menu-item">
        <xsl:with-param name="object-id" select="$object-id" />
        <xsl:with-param name="disabled" select="
          not(mirorcidutil:is-publishable-state($state))
          or not(mirorcidutil:has-orcid-credential($current-user))
          or not(mirorcidutil:has-trusted-matching-id($current-user, mirorcidutil:get-name-ids($object)))
        " />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
