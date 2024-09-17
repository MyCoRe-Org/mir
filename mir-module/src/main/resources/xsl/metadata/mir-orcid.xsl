<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns:mods="http://www.loc.gov/mods/v3"
  extension-element-prefixes="exsl" exclude-result-prefixes="mods" version="1.0">

  <xsl:import href="xslImport:modsmeta:metadata/mir-orcid.xsl"/>
  <xsl:include href="resource:xsl/mir-orcid-utils.xsl"/>

  <xsl:param name="objectId" select="/mycoreobject/@ID"/>
  <xsl:param name="state" select="/mycoreobject/service/servstates/servstate[@classid='state']/@categid"/>
  <xsl:param name="orcidIntegrationEnabled" select="true()"/>

  <xsl:template name="extractObjectIdsFromCurrentObject">
    <xsl:for-each select="//modsContainer/mods:mods/mods:name/mods:nameIdentifier">
      <str>
        <xsl:value-of select="concat(./@type,':',./text())"/>
      </str>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="/">
    <div id="mir-orcid">
      <xsl:variable name="isPublished">
        <xsl:call-template name="checkStateIsAllowedToPublish">
          <xsl:with-param name="state" select="$state"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:if test="$isPublished='true'">
        <xsl:variable name="user" select="document('user:current')/user"/>
        <xsl:variable name="isGuest" select="$user/@name='guest'"/>
        <xsl:variable name="hasLinkdedOrcidCredential" select="count($user/attributes/attribute[starts-with(@name, 'orcid_credential')]) &gt; 0"/>
        <xsl:if test="$orcidIntegrationEnabled and not($isGuest) and $hasLinkdedOrcidCredential">
          <xsl:variable name="userIdsXml">
            <xsl:call-template name="extractUserIdsFromUserAttributes">
              <xsl:with-param name="userAttributes" select="$user/attributes"/>
            </xsl:call-template>
          </xsl:variable>
          <xsl:variable name="userIds" select="exsl:node-set($userIdsXml)/str"/>
          <xsl:variable name="objectIdsXml">
            <xsl:call-template name="extractObjectIdsFromCurrentObject"/>
          </xsl:variable>
          <xsl:variable name="objectIds" select="exsl:node-set($objectIdsXml)/str"/>
          <xsl:if test="count($userIds) &gt; 0 and count($objectIds) &gt; 0">
            <xsl:variable name="matchingTrustedIdsXml">
              <xsl:call-template name="getMatchingTrustedIds">
                <xsl:with-param name="idsA" select="$userIds"/>
                <xsl:with-param name="idsB" select="$objectIds"/>
              </xsl:call-template>
            </xsl:variable>
            <xsl:variable name="matchingTrustedIds" select="exsl:node-set($matchingTrustedIdsXml)/str"/>
            <xsl:if test="count($matchingTrustedIds) &gt; 0">
              <xsl:call-template name="printExportToOrcidMenuItem"/>
              <xsl:call-template name="printExportToOrcidModal"/>
              <script type="module" src="{$WebApplicationBaseURL}js/mir/metadata.js"/>
            </xsl:if>
          </xsl:if>
        </xsl:if>
      </xsl:if>
    </div>
    <xsl:apply-imports/>
  </xsl:template>

  <xsl:template name="printExportToOrcidModal">
    <div id="exportToOrcidModal" class="modal fade" tabindex="-1"
      aria-labelledby="exportToOrcidModalLabel" aria-hidden="true" role="dialog">
      <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <h5 id="exportToOrcidModalLabel" class="modal-title">
              <xsl:value-of select="document('i18n:mir.orcid.export.modal.title')"/>
            </h5>
            <button class="close" type="button" data-dismiss="modal" aria-label="Close">
              <span aria-hidden="true">&#215;</span>
            </button>
          </div>
          <div class="modal-body">
            <div id="alertDiv" class="alert alert-danger" role="alert">
              <xsl:value-of select="document('i18n:mir.orcid.export.modal.error')"/>
            </div>
            <div class="form-group">
              <label class="mr-1" for="orcidProfileSelect">
                <xsl:value-of select="document('i18n:mir.orcid.export.modal.description')"/>
              </label>   
              <select class="form-control" id="orcidProfileSelect">
                <option value="" selected="selected">
                  <xsl:value-of select="document('i18n:mir.select')"/>
                </option>
              </select>
            </div>
          </div>
          <div class="modal-footer">
            <button id="exportToOrcidBtn" class="btn btn-primary" type="button">
              <xsl:value-of select="document('i18n:mir.orcid.export.modal.button.export')"/>
            </button>
            <button class="btn btn-secondary" type="button" data-dismiss="modal">
              <xsl:value-of select="document('i18n:button.cancel')"/>
            </button>
          </div>
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="printExportToOrcidMenuItem">
    <li id="publishToOrcidMenuItem">
      <a id="openPublishToOrcidModal" class="dropdown-item" role="menuitem" data-object-id="{$objectId}">
        <xsl:value-of select="document('i18n:mir.orcid.export.openExportModal.button')"/>
      </a>
    </li>
  </xsl:template>
</xsl:stylesheet>
