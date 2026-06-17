<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcracl="http://www.mycore.de/xslt/acl"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mirorcidutil="http://www.mycore.de/xslt/mirorcidutil"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:import href="xslImport:badges:badges/mir-badges-orcid.xsl" />
  <xsl:include href="resource:xslt/badges/mir-badges-utils.xsl" />

  <xsl:template match="doc" mode="badge">
    <xsl:apply-imports />

    <xsl:if test="not(mcracl:is-current-user-guest-user()) and mirorcidutil:is-orcid-enabled()">
      <xsl:variable name="current-user" select="document('user:current')/user" />

      <xsl:if test="
        exists(mirorcidutil:get-orcids($current-user))
        and (str[@name='state'][. = 'published'] or field[@name='state'][. = 'published'])
      ">
        <xsl:variable name="object-name-ids" select="
          (arr[@name='mods.nameIdentifier']/str | field[@name='mods.nameIdentifier'])/string()
        " />

        <xsl:if test="mirorcidutil:has-trusted-matching-id($current-user, $object-name-ids)">
          <xsl:variable name="object-id" select="string((str[@name='id'] | field[@name='id'])[1])" />

          <span class="badge mir-badge-orcid-in-profile" data-object-id="{$object-id}">
            <i class="fa-brands fa-orcid"></i>
            <span class="mir-badge-orcid-in-profile-text">
              <xsl:value-of select="mcri18n:translate('mir.orcid.publication.badge.inProfile.loading')" />
            </span>
          </span>
        </xsl:if>
      </xsl:if>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
