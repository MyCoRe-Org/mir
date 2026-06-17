<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcracl="http://www.mycore.de/xslt/acl"
  xmlns:mirorcidutil="http://www.mycore.de/xslt/mirorcidutil"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:import href="xslImport:modsmeta:metadata/mir-orcid.xsl" />
  <xsl:include href="resource:xslt/orcid/mir-orcid-export-ui.xsl" />

  <xsl:template match="/">
    <div id="mir-orcid">
      <xsl:if test="mirorcidutil:is-orcid-enabled() and not(mcracl:is-current-user-guest-user())">
        <xsl:variable name="current-user" select="document('user:current')/user" />

        <xsl:variable name="state" select="/mycoreobject/service/servstates/servstate[@classid='state']/@categid" />
        <xsl:variable name="object-name-ids" select="mirorcidutil:get-name-ids(/mycoreobject)" />

        <xsl:call-template name="render-export-to-orcid-menu-item">
          <xsl:with-param name="object-id" select="/mycoreobject/@ID" />
          <xsl:with-param name="disabled" select="
            not(mirorcidutil:is-publishable-state($state))
            or not(mirorcidutil:has-orcid-credential($current-user))
            or not(mirorcidutil:has-trusted-matching-id($current-user, $object-name-ids))
          " />
        </xsl:call-template>
      </xsl:if>
      <xsl:call-template name="render-export-to-orcid-modal" />
      <script type="module" src="{$WebApplicationBaseURL}js/mir/orcid-metadata.js" />
    </div>

    <xsl:apply-imports />
  </xsl:template>

</xsl:stylesheet>
