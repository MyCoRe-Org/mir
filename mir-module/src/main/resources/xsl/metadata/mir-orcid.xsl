<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns:mods="http://www.loc.gov/mods/v3"
  extension-element-prefixes="exsl"
  exclude-result-prefixes="mods">

  <xsl:import href="xslImport:modsmeta:metadata/mir-orcid.xsl"/>
  <xsl:include href="resource:xsl/orcid/mir-orcid-export-ui.xsl"/>
  <xsl:include href="resource:xsl/orcid/mir-orcid-user.xsl"/>
  <xsl:include href="resource:xsl/orcid/mir-orcid-work.xsl"/>

  <xsl:template match="/">
    <div id="mir-orcid">
      <xsl:if test="$isOrcidEnabled and not($isGuestUser)">
        <xsl:variable name="isPublishable">
          <xsl:call-template name="check-state-is-publishable">
            <xsl:with-param name="state" select="/mycoreobject/service/servstates/servstate[@classid='state']/@categid"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="nameIdsXml">
          <xsl:call-template name="extract-name-ids-from-current-object"/>
        </xsl:variable>
        <xsl:variable name="nameIds" select="exsl:node-set($nameIdsXml)/str"/>
        <xsl:variable name="currentUserHasTrustedMatchingId">
          <xsl:call-template name="check-current-user-has-trusted-matching-id">
            <xsl:with-param name="nameIds" select="$nameIds"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:call-template name="render-export-to-orcid-menu-item">
          <xsl:with-param name="objectId" select="/mycoreobject/@ID"/>
          <xsl:with-param name="disabled"
            select="$isPublishable='false' or not($hasLinkedOrcidCredential) or $currentUserHasTrustedMatchingId='false'"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:call-template name="render-export-to-orcid-modal"/>
      <script type="module" src="{$WebApplicationBaseURL}js/mir/orcid-metadata.js"/>
    </div>

    <xsl:apply-imports/>
  </xsl:template>

  <xsl:template name="extract-name-ids-from-current-object">
    <xsl:for-each select="//modsContainer/mods:mods/mods:name/mods:nameIdentifier">
      <str><xsl:value-of select="concat(./@type, ':', text())"/></str>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
