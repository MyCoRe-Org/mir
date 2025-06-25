<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="xsl">

  <xsl:import href="xslImport:badges:badges/mir-badges-orcid.xsl"/>
  <xsl:import href="resource:xsl/orcid/mir-orcid-user.xsl"/>
  <xsl:include href="resource:/xsl/orcid/mir-orcid-work.xsl"/>

  <xsl:template match="doc" mode="badge">
    <xsl:apply-imports/>

    <xsl:if test="not($isCurrentUserGuest) 
                  and $isOrcidEnabled
                  and count($userOrcids) &gt; 0
                  and (
                    str[@name='state'][. = 'published'] 
                    or field[@name='state'][. = 'published']
                  )">
      <xsl:variable name="currentUserMatchingTrustedIds">
        <xsl:call-template name="check-current-user-has-trusted-matching-id">
          <xsl:with-param name="nameIds" select="arr[@name='mods.nameIdentifier']/str | field[@name='mods.nameIdentifier']"/>
        </xsl:call-template>
      </xsl:variable>

      <xsl:if test="boolean($currentUserMatchingTrustedIds)">
        <xsl:variable name="objectId" select="string((str[@name='id'] | field[@name='id'])[1])"/>
        <span class="badge mir-badge-orcid-in-profile" data-object-id="{$objectId}">
          <i class="fa-brands fa-orcid"></i>
          <span class="mir-badge-orcid-in-profile-text">
            <xsl:value-of select="document('i18n:mir.orcid.publication.badge.inProfile.loading')/i18n/text()"/>
          </span>
        </span>
      </xsl:if>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
